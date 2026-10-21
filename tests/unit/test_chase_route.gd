extends GutTest

## The chase suspect's route and vehicle (persecucion.md; ChaseRoute, SuspectCar).

const PATROL_CAR_SCENE := preload("res://scenes/vehicles/patrol_car.tscn")


func test_the_route_goes_corner_to_corner_on_the_grid_and_the_seed_keeps_it() -> void:
	var route := ChaseRoute.draw(7)
	assert_eq(route.corners.size(), ChaseRoute.CORNERS)
	for k in range(1, route.corners.size()):
		var step := route.corners[k] - route.corners[k - 1]
		assert_eq(absi(step.x) + absi(step.y), 1, "one block at a time")
		assert_true(ChaseRoute.on_grid(route.corners[k]))
		if k > 1:
			assert_ne(step, route.corners[k - 2] - route.corners[k - 1], "never straight back")
	assert_eq(ChaseRoute.draw(7).corners, route.corners, "same seed, same route")
	assert_ne(ChaseRoute.draw(8).corners, route.corners)


func test_no_block_twice_while_there_is_another_way() -> void:
	var route := ChaseRoute.draw(3, 12)
	var seen := {}
	for k in range(1, route.corners.size()):
		var a := route.corners[k - 1]
		var b := route.corners[k]
		var key := Vector4i(mini(a.x, b.x), mini(a.y, b.y), maxi(a.x, b.x), maxi(a.y, b.y))
		assert_false(seen.has(key), "a short route doesn't need to repeat a block")
		seen[key] = true


func test_waypoints_keep_to_the_right_lane() -> void:
	var route := ChaseRoute.new()
	route.corners.assign([Vector2i(2, 2), Vector2i(2, 1), Vector2i(3, 1)])
	var points := route.waypoints()
	var middle := ChaseRoute.corner_point(Vector2i(2, 2))
	assert_eq(points[0], middle + Vector3(ChaseRoute.LANE, 0, 0), "going north, the lane is east of the middle")
	assert_eq(points[1], ChaseRoute.corner_point(Vector2i(2, 1)) + Vector3(ChaseRoute.LANE, 0, ChaseRoute.LANE),
		"turning right toward the east cuts the corner")


func _ground() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(400, 1, 400)
	shape.shape = box
	shape.position.y = -0.5
	floor_body.add_child(shape)
	add_child_autofree(floor_body)


func test_the_suspect_drives_his_route_and_turns_the_corner() -> void:
	_ground()
	var route := ChaseRoute.new()
	route.corners.assign([Vector2i(2, 2), Vector2i(2, 1), Vector2i(3, 1)])
	var car := SuspectCar.new()
	add_child_autofree(car)
	car.follow(route, Transform3D.IDENTITY)
	var start := car.global_position
	await wait_physics_frames(60)
	assert_gt(car.global_position.distance_to(start), 8.0, "it drives off on its own")
	await wait_physics_frames(900)
	assert_true(car.finished(), "it gets through every corner")
	assert_almost_eq(car.global_position.z, ChaseRoute.corner_point(Vector2i(3, 1)).z + ChaseRoute.LANE, 1.5,
		"and ends up in its lane going east")


func test_cut_off_by_the_patrol_car_it_gets_stuck() -> void:
	_ground()
	var route := ChaseRoute.new()
	route.corners.assign([Vector2i(2, 2), Vector2i(2, 1)])
	var car := SuspectCar.new()
	add_child_autofree(car)
	car.follow(route, Transform3D.IDENTITY)
	var patrol: PatrolCar = PATROL_CAR_SCENE.instantiate()
	add_child_autofree(patrol)
	patrol.global_position = car.global_position + Vector3(0, 0.2, -7.0)
	patrol.rotation.y = PI / 2
	await wait_physics_frames(150)
	assert_gt(car.stuck_for, 0.5, "the patrol car across its lane stops it")
	assert_false(car.finished())
