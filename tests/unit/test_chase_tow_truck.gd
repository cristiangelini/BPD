extends GutTest

## The tow truck (persecucion-lugares.md, "La grúa"): it takes the patrol car from the door, the cops chase him in the
## old one or on foot, and once he gave up E on the hook gets the good one back.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "tow_truck"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


func test_the_patrol_car_hangs_behind_the_tow_truck_and_the_old_one_waits() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	var good: PatrolCar = level.get_node("PatrolCar")
	assert_eq(case.towed, good)
	assert_true(case.car.old, "the cops get the old one")
	assert_eq(case.home_car(), good, "but they bring him back in the good one")
	assert_true(good.freeze)
	assert_true(good.global_transform.origin.is_equal_approx(level.truck.towed_transform().origin), "hooked behind")
	var station: Transform3D = (level.get_node("City") as Node3D).transform * CityLayout.lot("station")
	assert_lt(case.car.global_position.distance_to(station.origin), 30.0, "the old one is by the station")
	var cop: Cop = level.get_node("Cop")
	good.use(cop)
	assert_lt(good.seat_of(cop), 0, "nobody gets in while it's hooked")


func test_it_tows_at_thirty_and_the_car_comes_along() -> void:
	var level := _level()
	await wait_physics_frames(5)
	level.case.give_tip()
	var truck := level.truck
	var cop: Cop = level.get_node("Cop")
	cop.global_position = truck.global_position - truck.global_basis.z * 15.0 + Vector3.UP * 0.1
	await wait_physics_frames(3)
	assert_true(level.case.chasing, "a cop walking out to him starts it")
	var from := truck.global_position
	await wait_physics_frames(Engine.physics_ticks_per_second * 2)
	var speed := Vector2(truck.global_position.x - from.x, truck.global_position.z - from.z).length() / 2.0
	assert_lt(speed, SuspectCar.SPEEDS["tow_truck"] + 0.3, "30 km/h at most")
	assert_gt(speed, 1.5)
	var good := level.case.towed
	assert_lt(good.global_position.distance_to(truck.towed_transform().origin), 0.05, "the patrol car comes along")
	cop.global_position = truck.global_position + Vector3(80, 0.1, 0)
	level.case.distance = 50.0
	await wait_physics_frames(Engine.physics_ticks_per_second)
	assert_gt(level.case.distance, 50.0, "far from every cop, he's getting away")


func test_the_old_car_has_nothing_in_the_trunk() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var tasks := level.case.tasks
	assert_eq(tasks.spikes_left, 0)
	assert_eq(tasks.nets_left, 0)
	assert_null(tasks.throw_spikes())
	assert_null(tasks.throw_net())
	assert_eq(tasks._window_hint(), ChaseTasks.EMPTY_TRUNK_HINT)


func test_stopped_and_unhooked_the_good_car_drives_again() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	case.give_tip()
	var truck := level.truck
	var cop: Cop = level.get_node("Cop")
	cop.global_position = truck.global_position + truck.global_basis.z * 4.0 + Vector3.UP * 0.1
	await wait_physics_frames(3)
	assert_true(case.chasing)
	case.unhook(cop)
	assert_false(case.unhooked, "not while he's driving off")
	await wait_physics_frames(roundi((ChaseCase.STOP_SECONDS + 1.5) * Engine.physics_ticks_per_second))
	assert_true(case.stopped, "a cop in his way stops him")
	assert_eq(case.escort.car, case.towed, "he goes in the good car")
	var hook: TowHook = truck.get_node("Hook")
	assert_eq(hook.prompt_key(cop), "PROMPT_UNHOOK")
	hook.use(cop)
	assert_true(case.unhooked)
	assert_false(case.towed.freeze)
	assert_eq(case.towed.locked_hint, "")
	await wait_physics_frames(Engine.physics_ticks_per_second)
	assert_lt(case.towed.global_position.y, 1.0, "back on its wheels")
	cop.global_position = case.towed.to_global(Vector3(2, 0, 0.55))
	case.towed.use(cop)
	assert_eq(case.towed.seat_of(cop), 0, "and a cop can drive it")
