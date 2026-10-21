extends GutTest

## Each seat's job in a chase (persecucion.md, "Las cuatro tareas"): the copilot's map, the megaphone in the back.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "ice_cream"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


func _cop(level: ChaseLevel) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	level.add_child(cop)
	cop.get_node("Grabber").input_enabled = false
	cop.global_position = level.case.car.global_position + Vector3(4, 0.1, 0)
	return cop


func test_a_seat_nobody_took_hands_its_job_down() -> void:
	var level := _level()
	await wait_physics_frames(10)
	var tasks := level.case.tasks
	var car := level.case.car
	var driver: Cop = level.get_node("Cop")
	car.enter(driver, 0)
	assert_true(tasks.does(driver, ChaseTasks.MAP_SEATS), "alone, the driver reads the map")
	assert_true(tasks.does(driver, ChaseTasks.MEGAPHONE_SEATS), "and has the megaphone")
	var copilot := _cop(level)
	car.enter(copilot, 1)
	assert_true(tasks.does(copilot, ChaseTasks.MAP_SEATS), "the copilot reads the map")
	assert_false(tasks.does(driver, ChaseTasks.MAP_SEATS), "and the driver doesn't see the suspect any more")
	assert_true(tasks.does(copilot, ChaseTasks.MEGAPHONE_SEATS), "nobody in the back: the copilot shouts")
	var back := _cop(level)
	car.enter(back, 3)
	assert_true(tasks.does(back, ChaseTasks.MEGAPHONE_SEATS), "the back right seat has the megaphone")
	assert_false(tasks.does(copilot, ChaseTasks.MEGAPHONE_SEATS))
	assert_false(tasks.does(back, ChaseTasks.MAP_SEATS))


func test_the_map_shows_the_suspect() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var map: CityMap = (level.get_node("City") as City).map
	assert_eq(map.suspect, level.truck)
	assert_eq(map.car, level.case.car)
	assert_false(map.shows_suspect.call(), "nobody at the keys in the car: nobody sees him")


func test_the_megaphone_scares_him_and_waits_to_shout_again() -> void:
	var level := _level()
	await wait_physics_frames(10)
	var case := level.case
	case.give_tip()
	case.car.enter(level.get_node("Cop"), 0)
	await wait_physics_frames(5)
	case.tasks.shout()
	assert_eq(case.tasks.shouts, 1)
	assert_gt(level.truck.nervous_left, 0.0, "nervous, he slows down")
	case.tasks.shout()
	assert_eq(case.tasks.shouts, 1, "the megaphone needs a moment")


func test_a_wrong_turn_changes_his_way_but_never_turns_him_back() -> void:
	var level := _level()
	await wait_physics_frames(10)
	var case := level.case
	case.give_tip()
	case.car.enter(level.get_node("Cop"), 0)
	await wait_physics_frames(120)
	var k := level.truck.next
	var corners := case.route.corners.duplicate()
	assert_true(case.tasks.wrong_turn())
	var now := case.route.corners
	assert_eq(now.slice(0, k + 1), corners.slice(0, k + 1), "where he's been and the corner he's heading for stay")
	assert_ne(now[k + 1], corners[k + 1], "after it, another way")
	assert_ne(now[k + 1], now[k - 1], "never straight back")
	assert_eq(level.truck.points.size(), now.size())
	var at := level.truck.global_position
	await wait_physics_frames(60)
	assert_gt(level.truck.global_position.distance_to(at), 3.0, "and he keeps driving")


func _chasing(level: ChaseLevel) -> void:
	level.case.give_tip()
	level.case.car.enter(level.get_node("Cop"), 0)


func test_there_are_three_spike_strips_and_three_nets() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chasing(level)
	var tasks := level.case.tasks
	var car := level.case.car
	var spikes := tasks.throw_spikes()
	assert_not_null(spikes)
	assert_lt(car.to_local(spikes.global_position).z, 0.0, "the spikes land behind the car")
	assert_gt(car.to_local(tasks.throw_net().global_position).z, 0.0, "the net ahead")
	tasks.throw_spikes()
	tasks.throw_spikes()
	assert_null(tasks.throw_spikes(), "three of them")
	tasks.throw_net()
	tasks.throw_net()
	assert_null(tasks.throw_net())


func test_the_spikes_flatten_his_tires_and_he_gives_up() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chasing(level)
	await wait_physics_frames(30)
	var truck := level.truck
	var spikes := ChaseTrap.new()
	level.add_child(spikes)
	spikes.global_transform = Transform3D(Basis(Vector3.UP, truck.rotation.y),
		Vector3(truck.global_position.x, 0, truck.global_position.z) + truck.global_basis.z * 6.0)
	await wait_physics_frames(60)
	assert_true(truck.punctured, "he drove over them")
	await wait_physics_frames(roundi((SuspectCar.FLAT_STOP + ChaseCase.STOP_SECONDS + 1.0) * Engine.physics_ticks_per_second))
	assert_true(level.case.stopped, "flat, he gets out and gives up")


func test_the_net_on_top_of_him_holds_him_until_he_gives_up() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chasing(level)
	await wait_physics_frames(30)
	var truck := level.truck
	var car := level.case.car
	car.global_transform = Transform3D(truck.global_basis, truck.global_position - truck.global_basis.z * ChaseTasks.NET_AHEAD + Vector3.UP * 0.3)
	level.case.tasks.throw_net()
	await wait_physics_frames(5)
	assert_gt(truck.tangled_left, 0.0, "tangled up in the net")
	await wait_physics_frames(roundi((ChaseCase.STOP_SECONDS + 0.5) * Engine.physics_ticks_per_second))
	assert_true(level.case.stopped)
