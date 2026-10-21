extends GutTest

## The golf club (persecucion-lugares.md, "Ladrones en carrito de golf"): outside the ring on the east side, reached
## from the east ramp; its sand slows the patrol car, its lakes sink it, and its golfers shout "¡Fore!".

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "ice_cream"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


func _flat(point: Vector3) -> Vector2:
	return Vector2(point.x, point.z)


func test_the_club_is_past_the_ring_and_everything_fits_in_it() -> void:
	assert_gt(GolfLayout.CENTER.x - GolfLayout.HALF.x, HighwayLayout.OUTER.x, "outside the ring")
	assert_almost_eq(GolfLayout.CENTER.z, HighwayLayout.ramp_point("e").z, 0.01, "its gate on the east ramp")
	var spots: Array = GolfLayout.HOLES.duplicate()
	for ellipse: Array in GolfLayout.BUNKERS + GolfLayout.LAKES:
		var middle: Vector3 = ellipse[0]
		spots.append(middle + Vector3(ellipse[1], 0, ellipse[2]))
		spots.append(middle - Vector3(ellipse[1], 0, ellipse[2]))
	for spot: Vector3 in spots:
		assert_true(GolfLayout.inside(spot), "%s is inside the fence" % spot)
	assert_eq(GolfLayout.HOLES.size(), 6)
	assert_eq(GolfLayout.BUNKERS.size(), 5)
	assert_eq(GolfLayout.LAKES.size(), 2)
	for bunker: Array in GolfLayout.BUNKERS:
		assert_false(GolfLayout.in_lake(bunker[0]), "no bunker in a lake")


func test_the_path_keeps_out_of_the_lakes() -> void:
	for piece in GolfLayout.path():
		for k in 41:
			var at: Vector3 = (piece[0] as Vector3).lerp(piece[1], k / 40.0)
			for side: float in [-1.0, 1.0]:
				var edge := at + Vector3(0, 0, side * GolfLayout.PATH_WIDTH / 2)
				assert_false(GolfLayout.in_lake(edge), "the path at %s is dry" % edge)


func test_the_east_ramp_runs_on_to_the_gate() -> void:
	var level := _level()
	await wait_physics_frames(3)
	var city: Node3D = level.get_node("City")
	var space := city.get_world_3d().direct_space_state
	var from := city.to_global(HighwayLayout.ramp_point("e", -HighwayLayout.WIDTH / 2 - 10.0) + Vector3.UP)
	var to := city.to_global(GolfLayout.CENTER + GolfLayout.GATE + Vector3(10, 1, 0))
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	assert_true(hit.is_empty(), "nothing in the way from the city to the club: %s" % [hit.get("collider")])
	var golf: GolfClub = level.get_node("City/Built/Golf")
	assert_true(golf.inside(to))
	assert_false(golf.inside(from))
	assert_lt(_flat(golf.gate()).distance_to(_flat(city.to_global(GolfLayout.CENTER + GolfLayout.GATE))), 0.01)


func test_in_the_sand_the_car_goes_at_half_speed_and_slides() -> void:
	var level := _level()
	await wait_physics_frames(3)
	var golf: GolfClub = level.get_node("City/Built/Golf")
	var car := level.case.car
	car.global_position = golf.to_global(GolfLayout.HOLES[0]) + Vector3.UP * 0.6
	await wait_physics_frames(3)
	assert_false(car.in_sand())
	assert_almost_eq(car.top_speed(), PatrolCar.MAX_SPEED, 0.01)
	var bunker: Vector3 = GolfLayout.BUNKERS[3][0]
	car.global_position = golf.to_global(bunker) + Vector3.UP * 0.6
	await wait_physics_frames(3)
	assert_true(car.in_sand())
	assert_almost_eq(car.top_speed(), PatrolCar.MAX_SPEED * PatrolCar.SAND_SHARE, 0.01)
	assert_almost_eq(car.get_node("WheelFrontLeft").wheel_friction_slip, PatrolCar.GRIP * PatrolCar.SAND_GRIP, 0.01,
		"the wheels slide")


func test_a_car_in_a_lake_sinks_and_turns_up_at_the_gate_with_a_fine() -> void:
	var level := _level()
	await wait_physics_frames(3)
	var golf: GolfClub = level.get_node("City/Built/Golf")
	var car := level.case.car
	var lake: Vector3 = GolfLayout.LAKES[0][0]
	car.global_position = golf.to_global(lake) + Vector3.UP * 0.6
	await wait_physics_frames(3)
	assert_true(car.freeze, "it's sinking")
	var top := car.global_position.y
	await wait_seconds(2.0)
	assert_lt(car.global_position.y, top - 0.3, "going down")
	await wait_seconds(GolfClub.SINK_SECONDS - 1.5)
	assert_false(car.freeze)
	assert_true(golf.inside(car.global_position))
	assert_lt(_flat(car.global_position).distance_to(_flat(golf.gate())), 12.0, "at the gate")
	assert_eq(level.case.damages.sinks, 1)
	assert_eq(level.case.damages.fines, ChaseDamages.FINE)
	TranslationServer.set_locale("es")
	assert_ne(tr("HINT_GOLF_SUNK"), "HINT_GOLF_SUNK")


func test_a_golfer_shouts_fore_and_hits_a_ball_at_a_cop() -> void:
	var level := _level()
	await wait_physics_frames(3)
	var golf: GolfClub = level.get_node("City/Built/Golf")
	assert_eq(golf.golfers.size(), 6, "one by each hole")
	var golfer := golf.golfers[0]
	var cop: Cop = level.get_node("Cop")
	assert_eq(golfer.swings, 0, "nobody near yet")
	cop.global_position = golfer.global_position + Vector3(15, 0.1, 0)
	golfer.wait = 0.0
	await wait_physics_frames(2)
	assert_eq(golfer.swings, 1)
	assert_true(golfer._shout.visible)
	TranslationServer.set_locale("es")
	assert_eq(tr(golfer._shout.text), "¡Fore!")
	var ball := get_tree().get_first_node_in_group("golf_balls") as RigidBody3D
	assert_not_null(ball)
	assert_gt(ball.linear_velocity.x, 5.0, "toward the cop")
	await wait_physics_frames(2)
	assert_eq(golfer.swings, 1, "not again right away")
