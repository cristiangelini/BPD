extends GutTest

## The hardware store "El Tornillo Flojo" (docs/diseno/ferreteria.md, step 1): the place itself, on its lot in the city.

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store() -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.get_node("Cop").input_enabled = false
	add_child_autofree(store)
	return store


func test_twelve_spots_each_on_a_surface() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(HardwareStore.SPOTS.size(), 12)
	var heavy := HardwareStore.SPOTS.filter(func(s: Dictionary) -> bool: return s.heavy).size()
	assert_eq(heavy, 6, "half the spots take the heavy evidence")
	var space := store.get_world_3d().direct_space_state
	for spot: Dictionary in HardwareStore.SPOTS:
		var at: Vector3 = spot.at
		var in_yard := HardwareStore.YARD_SPOTS.has(spot.id)
		var z_from := -HardwareStore.HALF_Z if in_yard else HardwareStore.BACK_Z
		var z_to := HardwareStore.BACK_Z if in_yard else HardwareStore.HALF_Z
		assert_true(absf(at.x) < HardwareStore.HALF_X and at.z > z_from and at.z < z_to, "%s is in its part of the lot" % spot.id)
		# Only the built store (layer 1), not what lies there.
		var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2, 1)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, at.y, 0.03, "%s sits on its surface" % spot.id)
		assert_eq(tr("LOC_" + spot.id).begins_with("LOC_"), false, "%s has its place name" % spot.id)


func test_the_shop_is_open_and_the_back_is_locked() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_true(store.store_door.locked, "Solo personal")
	assert_true(store.back_door.locked, "the workshop's door to the yard")
	var space := store.get_world_3d().direct_space_state
	# Street to shop, storeroom to workshop, side street to yard through the gate: nothing in the way.
	var ways := [
		[Vector3(HardwareStore.ENTRANCE_X, 1.0, HardwareStore.HALF_Z + 2), Vector3(HardwareStore.ENTRANCE_X, 1.0, HardwareStore.HALF_Z - 1.5)],
		[Vector3(0.0, 1.0, HardwareStore.WORKSHOP_DOOR_Z), Vector3(2.0, 1.0, HardwareStore.WORKSHOP_DOOR_Z)],
		[Vector3(-HardwareStore.HALF_X - 1, 0.6, HardwareStore.GATE_Z), Vector3(-HardwareStore.HALF_X + 1, 0.6, HardwareStore.GATE_Z)],
	]
	for way: Array in ways:
		var query := PhysicsRayQueryParameters3D.create(way[0], way[1])
		assert_true(space.intersect_ray(query).is_empty(), "open from %s to %s" % [way[0], way[1]])


func test_the_fragile_things_are_fines() -> void:
	var store := _store()
	await wait_physics_frames(30)
	assert_eq(store.paint_cans.size(), HardwareStore.PAINT_BOARDS.size() * HardwareStore.CANS_PER_BOARD)
	assert_eq(store.jars.size(), HardwareStore.JARS)
	for item: Ornament in store.paint_cans + store.jars:
		assert_false(item.is_broken, "%s survives standing still" % item.name)
	store.paint_cans[0].hit(Ornament.BREAK_SPEED + 1.0)
	store.jars[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(store.fines, Ornament.FINE * 2)
	assert_eq(store.broken_goods, 2)


func test_the_store_sits_on_its_lot_and_the_car_starts_at_the_station() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var city: Node3D = store.get_node("City")
	var lot := CityLayout.place("hardware")
	var center := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	assert_lt((city.transform * center).distance_to(Vector3.ZERO), 0.01, "the store is at the origin of its scene")
	assert_lt(store.car.global_position.distance_to(store.station_parking.origin), 0.2)
	assert_lt(store.get_node("Cop").global_position.distance_to(store.car.global_position), 4.0)
	assert_eq(store.city_map.target, "hardware")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["hardware"]))
