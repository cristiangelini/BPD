extends GutTest

## The city's traffic and people (docs/diseno/ciudad-viva.md, step 3): cars keep to their right-hand lane and stop
## for what's in front of them, and walkers stay on their sidewalk.


func test_every_loop_drives_on_the_right() -> void:
	for loop: Array in CityTraffic.LOOPS:
		var points := CityTraffic.loop_points(loop[0], loop[1], loop[2], loop[3], loop[4])
		for i in points.size():
			var a := points[i]
			var b := points[(i + 1) % points.size()]
			var ahead := (b - a).normalized()
			var right := Vector3(-ahead.z, 0, ahead.x)
			var middle := (a + b) / 2
			# The middle of the street it's on: the nearest street line across `right`.
			var street := Vector3.ZERO
			if absf(ahead.x) > 0.5:
				street = Vector3(middle.x, 0, _nearest(middle.z, CityLayout.ROWS, false))
			else:
				street = Vector3(_nearest(middle.x, CityLayout.COLUMNS, true), 0, middle.z)
			assert_almost_eq((middle - street).dot(right), CityLayout.STREET / 4, 0.01,
				"loop %s piece %d keeps right" % [loop, i])


func _nearest(at: float, count: int, columns: bool) -> float:
	var best := INF
	for k in count + 1:
		var line := CityLayout.street_x(k) if columns else CityLayout.street_z(k)
		if absf(line - at) < absf(best - at):
			best = line
	return best


func test_a_car_drives_its_loop_and_stops_for_a_cop_in_front() -> void:
	var car := CityCar.new()
	car.path = CityTraffic.loop_points(1, 1, 4, 4, true)
	add_child_autofree(car)
	car.place_along(0.0)
	var start := car.global_position
	await wait_physics_frames(60)
	assert_gt(car.global_position.distance_to(start), 5.0, "a second of driving moves it")
	var cop := Node3D.new()
	cop.add_to_group("cops")
	add_child_autofree(cop)
	cop.global_position = car.to_global(Vector3(0, 0, 5))
	await wait_physics_frames(10)
	var stopped := car.global_position
	await wait_physics_frames(60)
	assert_almost_eq(car.global_position.distance_to(stopped), 0.0, 0.01, "it waits behind the cop")
	await wait_physics_frames(150)
	assert_gt(car.global_position.distance_to(stopped), 1.0, "and after a while it goes anyway")


func test_it_never_drives_through_a_parked_cops_vehicle() -> void:
	var car := CityCar.new()
	car.path = CityTraffic.loop_points(1, 1, 4, 4, true)
	add_child_autofree(car)
	car.place_along(0.0)
	await wait_physics_frames(2)
	# A stand-in for the patrol car or the transfer bus, parked in its lane.
	var parked := Node3D.new()
	parked.add_to_group("patrol_cars")
	add_child_autofree(parked)
	parked.global_position = car.to_global(Vector3(0, 0, 6))
	await wait_physics_frames(10)
	var stopped := car.global_position
	await wait_seconds(CityCar.PATIENCE + 1.5)
	assert_almost_eq(car.global_position.distance_to(stopped), 0.0, 0.01, "it waits for good")


func test_walkers_stay_on_their_sidewalk() -> void:
	var walkers: Array[CityWalker] = []
	for k in 6:
		var walker := CityWalker.new()
		walker.path = CityTraffic.ring(Vector2i(2, 1), 0.5 - k * 0.2, k % 2 == 0)
		add_child_autofree(walker)
		walker.place_along(k / 6.0)
		walkers.append(walker)
	await wait_seconds(3.0)
	var center := CityLayout.block_center(Vector2i(2, 1))
	for walker in walkers:
		var off := walker.global_position - center
		var reach := maxf(absf(off.x), absf(off.z))
		assert_between(reach, CityLayout.BLOCK / 2 - CityLayout.SIDEWALK, CityLayout.BLOCK / 2, "on the sidewalk")
		assert_almost_eq(walker.global_position.y, CityLife.CURB, 0.001, "on top of it")
