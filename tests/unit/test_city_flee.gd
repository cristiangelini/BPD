extends GutTest

## The fleeing car (docs/diseno/ciudad-viva.md, "Auto que huye"): it drives the street grid, boxed in it pays, through
## its last crossing it got away.


func test_the_route_stays_on_the_grid_and_never_turns_back() -> void:
	var rng := RandomNumberGenerator.new()
	for seed_value in 20:
		rng.seed = seed_value
		var points := FleeingCar.route(Vector2i(3, 2), rng)
		assert_eq(points.size(), FleeingCar.LEGS + 1)
		for i in range(1, points.size()):
			var step := points[i] - points[i - 1]
			assert_almost_eq(step.length(), CityLayout.PITCH, 0.01, "one block at a time")
			if i >= 2:
				assert_false(points[i].is_equal_approx(points[i - 2]), "never back the way it came")
			assert_between(points[i].x, -CityLayout.SIZE.x / 2, CityLayout.SIZE.x / 2)
			assert_between(points[i].z, -CityLayout.SIZE.y / 2, CityLayout.SIZE.y / 2)


func test_stuck_long_enough_it_pays() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	assert_true(events.start_flee(Vector2i(3, 2)))
	var flee := events.active as FleeingCar
	flee.car.stuck_for = FleeingCar.STOP_STUCK
	flee._physics_process(0.016)
	assert_eq(events.earned, FleeingCar.MONEY)
	assert_false(flee.car.driving, "it stays put")


func test_through_its_last_crossing_it_got_away() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	events.start_flee(Vector2i(3, 2))
	var flee := events.active as FleeingCar
	flee.car.next = flee.car.points.size()
	flee._physics_process(0.016)
	assert_eq(events.earned, 0)
	assert_null(events.active)
