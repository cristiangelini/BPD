extends GutTest

## The cake lab "Dulce Ciencia" (docs/diseno/laboratorio.md, step 1): the place itself, on its lot in the city.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab() -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	# A story that leaves the ten flour sacks as they are (the gold flour swaps one).
	lab.story_id = "silver_cake"
	lab.get_node("Cop").input_enabled = false
	add_child_autofree(lab)
	return lab


func test_twelve_spots_each_on_a_surface() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(CakeLab.SPOTS.size(), 12)
	var heavy := CakeLab.SPOTS.filter(func(s: Dictionary) -> bool: return s.heavy).size()
	assert_eq(heavy, 6, "half the spots take the heavy evidence")
	var space := lab.get_world_3d().direct_space_state
	for spot: Dictionary in CakeLab.SPOTS:
		var at: Vector3 = spot.at
		assert_true(absf(at.x) < CakeLab.HALF_X and absf(at.z) < CakeLab.HALF_Z, "%s is inside" % spot.id)
		# Only the built lab (layer 1), not what lies there.
		var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2, 1)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, at.y, 0.03, "%s sits on its surface" % spot.id)
		assert_eq(tr("LOC_" + spot.id).begins_with("LOC_"), false, "%s has its place name" % spot.id)


func test_the_tasting_room_is_open_and_the_flavor_lab_and_cold_room_locked() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_true(lab.lab_door.locked, "the flavor lab")
	assert_true(lab.cold_door.locked, "the cold room")
	var space := lab.get_world_3d().direct_space_state
	var front := CakeLab.HALF_Z
	var tasting := CakeLab.TASTING_Z
	var opening := CakeLab.TASTING_OPENINGS[0]
	# Street to tasting room, tasting room to the kitchen, the kitchen to the storeroom and the storeroom to the
	# locker room.
	var ways := [
		[Vector3(0, 1.0, front + 2), Vector3(0, 1.0, front - 1.5)],
		[Vector3(opening, 1.0, tasting + 1), Vector3(opening, 1.0, tasting - 1)],
		[Vector3(CakeLab.WEST_X + 1, 1.0, CakeLab.STOREROOM_DOOR_Z), Vector3(CakeLab.WEST_X - 1, 1.0, CakeLab.STOREROOM_DOOR_Z)],
		[Vector3(CakeLab.LOCKER_DOOR_X, 1.0, CakeLab.BACK_Z + 1), Vector3(CakeLab.LOCKER_DOOR_X, 1.0, CakeLab.BACK_Z - 1)],
	]
	for way: Array in ways:
		var query := PhysicsRayQueryParameters3D.create(way[0], way[1], 1)
		assert_true(space.intersect_ray(query).is_empty(), "open from %s to %s" % [way[0], way[1]])


func test_the_showcase_cakes_are_fines() -> void:
	var lab := _lab()
	await wait_physics_frames(30)
	assert_eq(lab.cakes.size(), CakeLab.CAKES)
	for cake: Ornament in lab.cakes:
		assert_false(cake.is_broken, "%s survives standing still" % cake.name)
	lab.cakes[0].hit(Ornament.BREAK_SPEED + 1.0)
	lab.cakes[1].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(lab.fines, Ornament.FINE * 2)
	assert_eq(lab.broken_goods, 2)


func test_the_flour_sacks_stay_whole_until_one_falls() -> void:
	var lab := _lab()
	await wait_seconds(1.0)
	assert_eq(lab.sacks.size(), 10)
	for sack: FlourSack in lab.sacks:
		assert_false(sack.is_burst, "%s stays whole lying there" % sack.name)
	var sack := lab.sacks[0]
	sack.global_position += Vector3(2.0, 1.2, 0)
	await wait_seconds(1.0)
	assert_eq(lab.burst_sacks, 1, "dropped from carrying height, it bursts")
	assert_eq(lab.flour.patches.size(), 1, "and leaves flour on the floor")


func test_a_cop_through_the_flour_leaves_white_footprints() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var at := Vector3(0, CakeLab.FLOOR_TOP, 1.8)
	lab.flour.spill(at)
	var cop: Cop = lab.get_node("Cop")
	var hints := []
	lab.flour.floured.connect(func(who: Cop) -> void: hints.append(who))
	cop.global_position = at
	await wait_physics_frames(2)
	assert_true(lab.flour.is_floured(cop), "walking into the flour")
	assert_eq(hints.size(), 1)
	for i in 5:
		cop.global_position = at + Vector3(1.5 + i * 0.7, 0, 0)
		await wait_physics_frames(1)
	assert_gte(lab.flour.prints.size(), 4, "a print every step")
	lab.flour.floured_left[cop] = 0.01
	await wait_physics_frames(2)
	var printed: int = lab.flour.prints.size()
	cop.global_position += Vector3(2.0, 0, 0)
	await wait_physics_frames(2)
	assert_eq(lab.flour.prints.size(), printed, "clean boots after a while")


func test_the_lab_sits_on_its_lot_and_the_car_starts_at_the_station() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var city: Node3D = lab.get_node("City")
	var lot := CityLayout.place("cake_lab")
	var center := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	assert_lt((city.transform * center).distance_to(Vector3.ZERO), 0.01, "the lab is at the origin of its scene")
	assert_eq(lot.size.x, CakeLab.HALF_X * 2, "as wide as its lot")
	assert_eq(lot.size.z, CakeLab.HALF_Z * 2, "as deep as its lot")
	assert_eq(lot.size.y, CakeLab.BUILDING_TOP, "as tall as its lot")
	assert_lt(lab.car.global_position.distance_to(lab.station_parking.origin), 0.2)
	assert_lt(lab.get_node("Cop").global_position.distance_to(lab.car.global_position), 4.0)
	assert_eq(lab.city_map.target, "cake_lab")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["cake_lab"]))
