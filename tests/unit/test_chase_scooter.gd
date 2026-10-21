extends GutTest

## The delivery guy on the scooter (persecucion.md, "Los sospechosos"): he rides the sidewalks, and the window seat
## puts rows of cones across the street to block him.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "moto"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


func _chase(level: ChaseLevel) -> void:
	level.case.give_tip()
	level.case.car.enter(level.get_node("Cop"), 0)


## How far `point` (in the world) is from the middle of the street it's on, going along `heading`.
func _off_middle(level: ChaseLevel, point: Vector3, heading: Vector3) -> float:
	var city := level.case.city_transform
	var at := city.affine_inverse() * point
	var along := city.basis.inverse() * heading
	var crossing := ChaseRoute.corner_point(ChaseRoute.nearest_corner(at))
	return absf(at.z - crossing.z) if absf(along.x) > absf(along.z) else absf(at.x - crossing.x)


func test_he_rides_the_sidewalk_with_the_delivery_guy_on_top() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var scooter := level.truck
	assert_eq(scooter.kind, "moto")
	assert_not_null(scooter.get_node_or_null("Rider"), "the delivery guy rides it")
	for k in range(1, scooter.points.size() - 1):
		var into := scooter.points[k] - scooter.points[k - 1]
		var out := scooter.points[k + 1] - scooter.points[k]
		if absf(Vector2(into.x, into.z).angle_to(Vector2(out.x, out.z))) < 0.1:
			assert_almost_eq(_off_middle(level, scooter.points[k], into), ChaseRoute.SIDEWALK_LANE, 0.01,
				"going straight on, he's in the middle of the sidewalk")


func test_nothing_on_the_sidewalk_stops_him() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chase(level)
	var scooter := level.truck
	var worst := 0.0
	for i in 60 * 16:
		await wait_physics_frames(1)
		worst = maxf(worst, scooter.stuck_for)
	assert_gt(scooter.next, 2, "he got past a couple of corners")
	assert_lt(worst, 1.0, "nothing on the sidewalk got in his way")
	assert_false(level.case.stopped)


func test_the_window_puts_cones_across_the_street() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chase(level)
	var tasks := level.case.tasks
	assert_true(tasks.uses_cones())
	assert_eq(tasks._window_hint(), ChaseTasks.CONES_HINT)
	var cones := tasks.throw_cones()
	assert_not_null(cones)
	assert_eq(cones.kind, ChaseTrap.CONES)
	assert_eq(tasks.cones_left, ChaseTasks.CONES - 1)
	assert_eq(tasks.spikes_left, ChaseTasks.SPIKES, "no spikes against the scooter")
	var heading := level.case.car.global_basis.z
	assert_almost_eq(_off_middle(level, cones.global_position, heading), 0.0, 0.01, "lined up with the street's middle")
	var across := cones.global_basis.x
	assert_lt(absf(Vector2(across.x, across.z).normalized().dot(Vector2(heading.x, heading.z).normalized())), 0.3,
		"square to the street")
	for i in ChaseTasks.CONES:
		tasks.throw_cones()
	assert_eq(tasks.cones_left, 0)


func test_he_brakes_at_the_cones_and_gives_up() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chase(level)
	await wait_physics_frames(3)
	var scooter := level.truck
	var cones := ChaseTrap.new()
	cones.kind = ChaseTrap.CONES
	level.add_child(cones)
	cones.global_transform = Transform3D(scooter.global_basis, scooter.global_position + scooter.global_basis.z * 4.0)
	cones.global_position.y = 0.0
	await wait_physics_frames(roundi((ChaseCase.STOP_SECONDS + 1.5) * Engine.physics_ticks_per_second))
	assert_true(is_instance_valid(cones), "the cones stay where they are")
	assert_true(level.case.stopped, "boxed in by the cones, he gives up")
	assert_false((scooter.get_node("Rider") as Node3D).visible, "he got off")
	assert_not_null(level.case.suspect)
	assert_eq(level.case.suspect.kind, "moto")
