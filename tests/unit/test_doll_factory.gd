extends GutTest

## The doll factory "Sonrisas" (docs/diseno/fabrica.md, step 1): the place itself, on its lot in the city.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory() -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.get_node("Cop").input_enabled = false
	add_child_autofree(factory)
	return factory


func test_twelve_spots_each_on_a_surface() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	assert_eq(DollFactory.SPOTS.size(), 12)
	var heavy := DollFactory.SPOTS.filter(func(s: Dictionary) -> bool: return s.heavy).size()
	assert_eq(heavy, 6, "half the spots take the heavy evidence")
	var space := factory.get_world_3d().direct_space_state
	for spot: Dictionary in DollFactory.SPOTS:
		var at: Vector3 = spot.at
		var on_dock := DollFactory.DOCK_SPOTS.has(spot.id)
		var z_from := -DollFactory.HALF_Z if on_dock else DollFactory.DOCK_Z
		var z_to := DollFactory.DOCK_Z if on_dock else DollFactory.HALF_Z
		assert_true(absf(at.x) < DollFactory.HALF_X and at.z > z_from and at.z < z_to, "%s is in its part of the lot" % spot.id)
		# Only the built factory (layer 1), not what lies there.
		var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2, 1)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, at.y, 0.03, "%s sits on its surface" % spot.id)
		assert_eq(tr("LOC_" + spot.id).begins_with("LOC_"), false, "%s has its place name" % spot.id)


func test_the_reception_is_open_and_the_office_locked() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	assert_true(factory.office_door.locked, "the foreman's office")
	var space := factory.get_world_3d().direct_space_state
	var door_z := DollFactory.STOREROOM_DOORS[0]
	# Street to reception, reception to the factory floor, floor to storeroom, side street to dock through the gate.
	var ways := [
		[Vector3(0, 1.0, DollFactory.HALF_Z + 2), Vector3(0, 1.0, DollFactory.HALF_Z - 1.5)],
		[Vector3(DollFactory.RECEPTION_DOORS[0], 1.0, DollFactory.RECEPTION_Z + 1), Vector3(DollFactory.RECEPTION_DOORS[0], 1.0, DollFactory.RECEPTION_Z - 1)],
		[Vector3(DollFactory.STOREROOM_X - 1, 1.0, door_z), Vector3(DollFactory.STOREROOM_X + 0.4, 1.0, door_z)],
		[Vector3(-DollFactory.HALF_X - 1, 0.6, DollFactory.GATE_Z), Vector3(-DollFactory.HALF_X + 1, 0.6, DollFactory.GATE_Z)],
	]
	for way: Array in ways:
		var query := PhysicsRayQueryParameters3D.create(way[0], way[1])
		assert_true(space.intersect_ray(query).is_empty(), "open from %s to %s" % [way[0], way[1]])


func test_the_dock_shutter_rolls_up_with_its_button() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var space := factory.get_world_3d().direct_space_state
	var through := PhysicsRayQueryParameters3D.create(Vector3(DollFactory.SHUTTER_X, 1.0, DollFactory.DOCK_Z + 1),
		Vector3(DollFactory.SHUTTER_X, 1.0, DollFactory.DOCK_Z - 1))
	assert_false(space.intersect_ray(through).is_empty(), "the shutter starts down")
	factory.shutter_button.use(factory.get_node("Cop"))
	await wait_seconds(DollFactory.SHUTTER_TIME + 0.3)
	assert_true(factory.shutter_open)
	assert_true(space.intersect_ray(through).is_empty(), "the shutter rolled up")


func test_the_fragile_things_are_fines() -> void:
	var factory := _factory()
	await wait_physics_frames(30)
	assert_eq(factory.dolls.size(), DollFactory.DOLLS)
	assert_eq(factory.molds.size(), DollFactory.MOLDS)
	for item: Ornament in factory.dolls + factory.molds:
		assert_false(item.is_broken, "%s survives standing still" % item.name)
	factory.dolls[0].hit(Ornament.BREAK_SPEED + 1.0)
	factory.molds[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(factory.fines, Ornament.FINE * 2)
	assert_eq(factory.broken_goods, 2)


func test_the_factory_sits_on_its_lot_and_the_car_starts_at_the_station() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var city: Node3D = factory.get_node("City")
	var lot := CityLayout.place("doll_factory")
	var center := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	assert_lt((city.transform * center).distance_to(Vector3.ZERO), 0.01, "the factory is at the origin of its scene")
	assert_eq(lot.size.x, DollFactory.HALF_X * 2, "as wide as its lot")
	assert_eq(lot.size.z, DollFactory.HALF_Z * 2, "as deep as its lot")
	assert_lt(factory.car.global_position.distance_to(factory.station_parking.origin), 0.2)
	assert_lt(factory.get_node("Cop").global_position.distance_to(factory.car.global_position), 4.0)
	assert_eq(factory.city_map.target, "doll_factory")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["doll_factory"]))
