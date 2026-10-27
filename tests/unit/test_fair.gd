extends GutTest

## The fun fair as a place to raid (docs/diseno/allanamiento-parque.md, step 1): the block with its rides standing
## still (the carousel's 12 horses, the six bumper cars, the wheel's 8 cabins), the locked trailer with its key in the
## ticket booth's till, the mirrors that break when something hits them fast and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair(case_seed := 5) -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.case_seed = case_seed
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func _prop(fair: Fair, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", StrengthTester.MALLET_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	fair.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_fair_has_its_rides_door_and_spots() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	assert_eq(fair.horses.size(), 12, "twelve horses on the carousel")
	assert_eq(fair.bumpers.size(), Fair.BUMPERS.size())
	assert_eq(fair.cabins.size(), Fair.CABINS)
	assert_almost_eq(fair.cabins[0].global_position.y, Fair.HUB_HEIGHT + Fair.WHEEL_RADIUS, 0.01,
		"the first at the top")
	assert_true(fair.trailer_door.locked)
	assert_true(fair.till.has_key, "the trailer's key is in the ticket booth's till")
	assert_eq(Fair.SPOTS.size(), 12)
	assert_eq(Fair.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in Fair.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), Fair.HALF, spot.id)
		assert_lt(absf(at.z), Fair.HALF, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_fair_fills_its_block() -> void:
	var fair := _fair()
	await wait_physics_frames(1)
	assert_true(CityLayout.is_park(CityLayout.place("fair").block), "no building of the city stands on it")
	assert_eq(fair.city.transform, CityLayout.anchor("fair"))
	assert_eq(PlaceDraw.pick(1, ["--place=fair"]), "fair")
	assert_almost_eq((fair.city as City).clock.hour, Fair.OPENS_AT, 0.1, "and it's night")


func test_the_way_into_the_ghost_train_goes_round_to_the_way_out() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var space := fair.get_world_3d().direct_space_state
	var knee := Vector3(0, 0.6, 0)
	# In by one doorway, beside the carts round the back, and out by the other.
	var way: Array[Vector3] = [Vector3(Fair.GHOST_DOORS[0], 0, -8.0), Vector3(Fair.GHOST_DOORS[0], 0, -11.5),
		Vector3(-16.0, 0, -11.5), Vector3(-16.0, 0, -19.4), Vector3(-10.0, 0, -19.4), Vector3(-10.0, 0, -11.5),
		Vector3(Fair.GHOST_DOORS[1], 0, -11.5), Vector3(Fair.GHOST_DOORS[1], 0, -8.0)]
	for i in way.size() - 1:
		var query := PhysicsRayQueryParameters3D.create(way[i] + knee, way[i + 1] + knee)
		query.collision_mask = 1
		assert_true(space.intersect_ray(query).is_empty(), "from %s to %s" % [way[i], way[i + 1]])
	var across := PhysicsRayQueryParameters3D.create(Vector3(-16.0, 0.6, -14.0), Vector3(-10.0, 0.6, -14.0))
	across.collision_mask = 1
	assert_false(space.intersect_ray(across).is_empty(), "the wall in the middle keeps the two sides apart")


func test_something_thrown_hard_at_a_mirror_breaks_it_once() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var spot: Vector4 = Fair.MIRRORS[0]
	_prop(fair, Vector3(spot.x + 2.0, spot.y, spot.z), Vector3(-9.0, 0, 0))
	await wait_physics_frames(30)
	assert_eq(fair.broken_mirrors, [0] as Array[int])
	assert_eq(fair.fines, Fair.MIRROR_FINE)
	fair.break_mirror(0)
	assert_eq(fair.fines, Fair.MIRROR_FINE, "only once")


func test_a_slow_prop_doesnt_break_a_mirror() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var spot: Vector4 = Fair.MIRRORS[4]
	_prop(fair, Vector3(spot.x, spot.y + 0.4, spot.z + 0.3), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_eq(fair.broken_mirrors.size(), 0)
	assert_eq(fair.fines, 0)


func test_the_till_key_opens_the_trailer() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var cop: Cop = fair.get_node("Cop")
	fair.till.use(cop)
	assert_true(cop.has_key)
	fair.trailer_door.use(cop)
	assert_false(fair.trailer_door.locked)
