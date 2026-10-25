extends GutTest

## The street events (docs/diseno/ciudad-viva.md, step 7): the purse snatcher's route along the streets into a dead-end
## alley, the run itself (fence included), and the director paying for a caught thief, one event at a time.

const CITY_SCENE := preload("res://scenes/levels/city.tscn")


func test_the_route_follows_the_streets_into_the_alley() -> void:
	var from := CityLayout.block_center(Vector2i(3, 3)) + Vector3(10, CityLife.CURB, CityLayout.BLOCK / 2 - 1.5)
	for alley: Array in CityLife.ALLEYS:
		var route := CityRunaway.route_to(from, alley)
		for i in range(1, route.size()):
			var step := route[i] - route[i - 1]
			assert_true(absf(step.x) < 0.01 or absf(step.z) < 0.01, "straight along a street or the alley (%s)" % [alley])
		var end := route[route.size() - 1]
		assert_true(CityLife.alley_rect(alley[0], alley[1]).has_point(Vector2(end.x, end.z)), "it ends in the alley")


func test_the_thief_runs_into_the_alley_climbs_the_fence_and_is_trapped() -> void:
	var city: City = CITY_SCENE.instantiate()
	city.traffic = false
	add_child_autofree(city)
	var alley: Array = CityLife.ALLEYS[0]
	var normal := CityLayout.side_normal(alley[1])
	var mouth := CityLayout.block_center(alley[0]) + normal * (CityLayout.BLOCK / 2 - CityLayout.SIDEWALK)
	var start := mouth + normal * (CityLayout.SIDEWALK + CityLayout.STREET / 2) + Vector3(0, 0, 20)
	var thief := CityRunaway.new()
	thief.route = CityRunaway.route_to(start, alley)
	city.add_child(thief)
	thief.global_position = start + Vector3.UP * 0.1
	var climbed := false
	for i in 900:
		await wait_physics_frames(1)
		climbed = climbed or thief.state == CityRunaway.State.CLIMB
		if thief.state == CityRunaway.State.TRAPPED:
			break
	assert_true(climbed, "over the chain-link fence")
	assert_eq(thief.state, CityRunaway.State.TRAPPED, "and stuck at the end")
	var fence := mouth - normal * (CityLife.ALLEY_LENGTH - 6.0)
	assert_gt((fence - thief.global_position).dot(normal), 0.5, "past the fence")


func test_cuffing_the_thief_pays_and_the_next_event_waits() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	var walker := CityWalker.new()
	walker.path = CityTraffic.ring(Vector2i(3, 3))
	add_child_autofree(walker)
	walker.place_along(0.3)
	assert_true(events.start_snatch(walker))
	assert_not_null(events.active, "one event going")
	assert_true(walker.is_stopped(), "the victim stops to shout")
	var snatch := events.active as PurseSnatch
	snatch.thief.cuffed(Handcuffs.SECONDS)
	assert_eq(events.earned, PurseSnatch.MONEY, "a caught thief pays")
	assert_null(events.active)
	assert_gt(events.gap_left, CityEvents.GAP_MIN - 0.01, "and the next one waits its gap")


func test_a_thief_who_gets_away_pays_nothing() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	var walker := CityWalker.new()
	walker.path = CityTraffic.ring(Vector2i(3, 3))
	add_child_autofree(walker)
	walker.place_along(0.3)
	events.start_snatch(walker)
	(events.active as PurseSnatch).thief.got_away.emit()
	assert_eq(events.earned, 0)
	assert_null(events.active)


func test_events_happen_near_but_out_of_sight() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	var cop := Node3D.new()
	cop.add_to_group("cops")
	add_child_autofree(cop)
	var near_behind := CityWalker.new()
	near_behind.path = PackedVector3Array([Vector3(0, 0, 50), Vector3(0, 0, 51)])
	add_child_autofree(near_behind)
	near_behind.position = Vector3(0, 0, 50)
	var in_sight := CityWalker.new()
	in_sight.path = PackedVector3Array([Vector3(0, 0, -50), Vector3(0, 0, -51)])
	add_child_autofree(in_sight)
	in_sight.position = Vector3(0, 0, -50)
	var too_far := CityWalker.new()
	too_far.path = PackedVector3Array([Vector3(200, 0, 0), Vector3(201, 0, 0)])
	add_child_autofree(too_far)
	too_far.position = Vector3(200, 0, 0)
	for i in 10:
		assert_eq(events.pick_walker(), near_behind, "only the one behind the cop, at 50 m")
