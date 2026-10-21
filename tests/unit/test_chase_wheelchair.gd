extends GutTest

## The grandpa in the electric wheelchair (persecucion.md, "Los sospechosos"): 8 km/h down the sidewalk, chased on
## foot; the patrol car in his way doesn't stop him, a cop on foot does.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "wheelchair"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


## Puts `body` on his way, `ahead` meters in front of him.
func _in_his_way(level: ChaseLevel, body: Node3D, ahead: float) -> void:
	var chair := level.truck
	body.global_position = chair.global_position + chair.global_basis.z * ahead + Vector3.UP * 0.1


func test_the_chase_starts_when_a_cop_walks_up_to_him() -> void:
	var level := _level()
	await wait_physics_frames(5)
	level.case.give_tip()
	var cop: Cop = level.get_node("Cop")
	cop.global_position = level.truck.global_position + Vector3(ChaseCase.START_NEAR + 20.0, 0.1, 0)
	await wait_physics_frames(5)
	assert_false(level.case.chasing, "far away, he waits")
	_in_his_way(level, cop, -ChaseCase.START_NEAR / 2)
	await wait_physics_frames(3)
	assert_true(level.case.chasing, "a cop walks up, and off he goes")
	assert_true(level.case.on_foot())


func test_he_rolls_at_eight_an_hour_down_the_sidewalk() -> void:
	var level := _level()
	await wait_physics_frames(5)
	level.case.give_tip()
	var chair := level.truck
	_in_his_way(level, level.get_node("Cop"), -10.0)
	await wait_physics_frames(3)
	var from := chair.global_position
	await wait_physics_frames(Engine.physics_ticks_per_second * 2)
	var speed := Vector2(chair.global_position.x - from.x, chair.global_position.z - from.z).length() / 2.0
	assert_almost_eq(speed, SuspectCar.SPEEDS["wheelchair"], 0.4, "8 km/h")
	assert_not_null(chair.get_node_or_null("Rider"), "the grandpa sits in it")


func test_the_patrol_car_in_his_way_doesnt_stop_him() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	case.car.enter(cop, 0)
	await wait_physics_frames(3)
	assert_true(case.chasing)
	case.car.freeze = true
	var chair := level.truck
	case.car.global_transform = Transform3D(chair.global_basis.rotated(Vector3.UP, PI / 2),
		chair.global_position + chair.global_basis.z * 3.0 + Vector3.UP * 0.05)
	await wait_physics_frames(roundi((ChaseCase.STOP_SECONDS + 1.0) * Engine.physics_ticks_per_second))
	assert_gt(chair.stuck_for, ChaseCase.STOP_SECONDS, "the car is in his way")
	assert_false(case.stopped, "but he doesn't give up to a car")


func test_a_cop_on_foot_in_his_way_makes_him_give_up() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	_in_his_way(level, cop, 1.6)
	await wait_physics_frames(roundi((ChaseCase.STOP_SECONDS + 1.0) * Engine.physics_ticks_per_second))
	assert_true(case.chasing)
	assert_true(case.stopped, "a cop stands in his way: he gives up")
	assert_eq(case.suspect.kind, "wheelchair")


func test_on_foot_the_distance_counts_from_the_nearest_cop() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	_in_his_way(level, cop, -10.0)
	await wait_physics_frames(3)
	case.distance = 50.0
	await wait_physics_frames(Engine.physics_ticks_per_second)
	assert_lt(case.distance, 50.0, "the cop on foot is close, though the patrol car is far")
