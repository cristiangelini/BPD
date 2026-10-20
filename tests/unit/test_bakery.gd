extends GutTest

## The bakery "El Pan Feliz" (docs/diseno/panaderia.md, step 1): the place itself, on its lot in the city.

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")
const TICK := 1.0 / 60.0


func _bakery() -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.get_node("Cop").input_enabled = false
	add_child_autofree(bakery)
	return bakery


func test_twelve_spots_inside_the_building_each_on_a_surface() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	assert_eq(Bakery.SPOTS.size(), 12)
	var space := bakery.get_world_3d().direct_space_state
	for spot: Dictionary in Bakery.SPOTS:
		var at: Vector3 = spot.at
		assert_true(absf(at.x) < Bakery.HALF_X and absf(at.z) < Bakery.HALF_Z, "%s is inside the bakery" % spot.id)
		var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, at.y, 0.03, "%s sits on its surface" % spot.id)


func test_the_shop_is_open_and_the_bakehouse_and_back_door_are_locked() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	assert_true(bakery.bakehouse_door.locked)
	assert_true(bakery.back_door.locked)
	# Nothing stands in the open entrance from the street into the shop.
	var space := bakery.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(Vector3(Bakery.ENTRANCE_X, 1.0, Bakery.HALF_Z + 2),
		Vector3(Bakery.ENTRANCE_X, 1.0, Bakery.HALF_Z - 2))
	assert_true(space.intersect_ray(query).is_empty(), "the shop entrance is open")


func test_the_bakery_sits_on_its_lot_and_the_car_starts_at_the_station() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var city: Node3D = bakery.get_node("City")
	var lot := CityLayout.place("bakery")
	var center := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	assert_lt((city.transform * center).distance_to(Vector3.ZERO), 0.01, "the bakery is at the origin of its scene")
	assert_lt(bakery.car.global_position.distance_to(bakery.station_parking.origin), 0.2)
	assert_lt(bakery.get_node("Cop").global_position.distance_to(bakery.car.global_position), 4.0)
	assert_eq(bakery.city_map.target, "bakery")


func test_cop_walks_up_to_martas_flat() -> void:
	var bakery := _bakery()
	var cop: Cop = bakery.get_node("Cop")
	cop.global_position = Vector3(Bakery.STAIR_X, Bakery.FLOOR_TOP + 0.1, Bakery.STAIR_FOOT + 0.5)
	for i in 20:
		cop.step(TICK, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	for i in 150:
		cop.step(TICK, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	assert_gt(cop.global_position.y, GameScale.FLOOR_HEIGHT - 0.1, "the cop reaches the upper floor")
