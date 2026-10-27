extends GutTest

## The car wash as a place to raid (docs/diseno/allanamiento-lavadero.md, step 1): the car wash on its lot, the tunnel
## with its conveyor, the cars waiting in line with the second one's trunk open, the locked office with its key in the
## till, the windshields and the wax shelf that break when something hits them fast, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash(case_seed := 5) -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.case_seed = case_seed
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func _prop(car_wash: CarWash, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", CarWash.TOKEN_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	car_wash.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_car_wash_has_its_tunnel_door_and_spots() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	assert_true(car_wash.office_door.locked)
	assert_true(car_wash.till.has_key, "the office's key is in the token machine's till")
	assert_eq(car_wash.cars.size(), 2, "two cars waiting in line")
	assert_true(CarWash.in_tunnel(Vector3(0, 0, 0)))
	assert_false(CarWash.in_tunnel(CarWash.CARS[0]), "the cars wait outside the tunnel")
	assert_eq(CarWash.SPOTS.size(), 12)
	assert_eq(CarWash.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in CarWash.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), CarWash.HALF_X, spot.id)
		assert_lt(absf(at.z), CarWash.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)
	for key: String in ["PLACE_CARWASH", "MENU_CARWASH", "CARWASH_WINDSHIELD_BROKEN", "CARWASH_WAX_BROKEN",
			"CASE_FAILED_LAWYER_CARWASH", "HINT_TILL_KEY_CARWASH"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_car_wash_stands_on_its_lot() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(1)
	assert_eq(CityLayout.place("carwash").block, Vector2i(8, 4))
	assert_eq((car_wash.get_node("City") as Node3D).transform, CityLayout.anchor("carwash"))


func test_something_hidden_in_every_spot_stays_there() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var props: Array[Grabbable] = []
	for spot: Dictionary in CarWash.SPOTS:
		props.append(_prop(car_wash, spot.at + Vector3.UP * 0.2, Vector3.ZERO))
	await wait_seconds(1.5)
	for i in props.size():
		var spot: Dictionary = CarWash.SPOTS[i]
		var at: Vector3 = spot.at
		assert_lt(props[i].global_position.distance_to(at + Vector3.UP * 0.15), 0.6, "%s keeps it" % spot.id)


func test_something_thrown_hard_at_a_windshield_breaks_it_once() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var pane := car_wash.windshields[0].global_position
	_prop(car_wash, pane + Vector3(2.0, 0.3, 0), Vector3(-9.0, 0, 0))
	await wait_physics_frames(30)
	assert_eq(car_wash.cracked, [0] as Array[int])
	assert_eq(car_wash.fines, CarWash.WINDSHIELD_FINE)
	car_wash.break_windshield(0)
	assert_eq(car_wash.fines, CarWash.WINDSHIELD_FINE, "only once")


func test_a_slow_prop_doesnt_break_the_wax_shelf_but_a_fast_one_does() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var shelf_front := CarWash.WAX_AT + Vector3(0, 1.2, -CarWash.WAX_SIZE.z / 2)
	_prop(car_wash, shelf_front + Vector3(0, 0, -0.6), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_false(car_wash.wax_broken_down)
	_prop(car_wash, shelf_front + Vector3(0, 0, -2.5), Vector3(0, 0, 9.0))
	await wait_physics_frames(30)
	assert_true(car_wash.wax_broken_down)
	assert_eq(car_wash.fines, CarWash.WAX_FINE * CarWash.WAX_BOTTLES)


func test_the_till_key_opens_the_office() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var cop: Cop = car_wash.get_node("Cop")
	car_wash.till.use(cop)
	assert_true(cop.has_key)
	car_wash.office_door.use(cop)
	assert_false(car_wash.office_door.locked)
