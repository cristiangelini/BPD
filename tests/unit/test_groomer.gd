extends GutTest

## The pet salon "Pelito Feliz" (docs/diseno/peluqueria.md, step 1): the place itself, on its lot in the city.

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer() -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.get_node("Cop").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func test_twelve_spots_each_on_a_surface() -> void:
	var groomer := _groomer()
	await wait_physics_frames(2)
	assert_eq(Groomer.SPOTS.size(), 12)
	var heavy := Groomer.SPOTS.filter(func(s: Dictionary) -> bool: return s.heavy).size()
	assert_between(heavy, 4, 8, "some spots take the heavy evidence, some don't")
	var space := groomer.get_world_3d().direct_space_state
	for spot: Dictionary in Groomer.SPOTS:
		var at: Vector3 = spot.at
		var in_yard: bool = spot.id == "in_doghouse"
		var z_from := -Groomer.HALF_Z if in_yard else Groomer.BACK_Z
		var z_to := Groomer.BACK_Z if in_yard else Groomer.HALF_Z
		assert_true(absf(at.x) < Groomer.HALF_X and at.z > z_from and at.z < z_to, "%s is in its part of the lot" % spot.id)
		var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, at.y, 0.03, "%s sits on its surface" % spot.id)


func test_the_salon_is_open_and_the_storeroom_is_locked() -> void:
	var groomer := _groomer()
	await wait_physics_frames(2)
	assert_true(groomer.store_door.locked, "Solo personal")
	assert_true(groomer.back_door.locked, "the storeroom's door to the yard")
	var space := groomer.get_world_3d().direct_space_state
	# Street to reception, reception to grooming room, reception to cages, cages to yard: nothing in the way.
	var ways := [
		[Vector3(Groomer.ENTRANCE_X, 1.0, Groomer.HALF_Z + 2), Vector3(Groomer.ENTRANCE_X, 1.0, Groomer.HALF_Z - 1.5)],
		[Vector3(-1.0, 1.0, Groomer.GROOMING_DOOR_Z), Vector3(1.0, 1.0, Groomer.GROOMING_DOOR_Z)],
		[Vector3(Groomer.CAGES_DOOR_X, 1.0, Groomer.SPLIT_Z + 1), Vector3(Groomer.CAGES_DOOR_X, 1.0, Groomer.SPLIT_Z - 1)],
		[Vector3(Groomer.YARD_DOOR_X, 1.0, Groomer.BACK_Z + 1), Vector3(Groomer.YARD_DOOR_X, 1.0, Groomer.BACK_Z - 1.5)],
	]
	for way: Array in ways:
		var query := PhysicsRayQueryParameters3D.create(way[0], way[1])
		assert_true(space.intersect_ray(query).is_empty(), "open from %s to %s" % [way[0], way[1]])


func test_the_fragile_things_are_fines() -> void:
	var groomer := _groomer()
	await wait_physics_frames(30)
	assert_eq(groomer.shampoos.size(), 24)
	assert_eq(groomer.collars.size(), Groomer.COLLARS)
	for item: Ornament in groomer.shampoos + groomer.collars:
		assert_false(item.is_broken, "%s survives standing still" % item.name)
	groomer.shampoos[0].hit(Ornament.BREAK_SPEED + 1.0)
	groomer.collars[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(groomer.fines, Ornament.FINE * 2)


func test_the_salon_sits_on_its_lot_and_the_car_starts_at_the_station() -> void:
	var groomer := _groomer()
	await wait_physics_frames(2)
	var city: Node3D = groomer.get_node("City")
	var lot := CityLayout.place("pet_salon")
	var center := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	assert_lt((city.transform * center).distance_to(Vector3.ZERO), 0.01, "the salon is at the origin of its scene")
	assert_lt(groomer.car.global_position.distance_to(groomer.station_parking.origin), 0.2)
	assert_lt(groomer.get_node("Cop").global_position.distance_to(groomer.car.global_position), 4.0)
	assert_eq(groomer.city_map.target, "pet_salon")
