extends GutTest

## The garage as a place to raid (docs/diseno/allanamiento-taller.md, step 1): the shed on its lot with the three
## clients' cars (one up on the lift, one over the pit), the locked office with its key in the till, the windshields that
## crack when something hits them fast and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage(case_seed := 5) -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.case_seed = case_seed
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func _prop(garage: Garage, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", Garage.DRUM_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	garage.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_garage_has_its_cars_door_and_spots() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.cars.size(), Garage.CARS.size())
	assert_almost_eq(garage.cars[1].position.y, Garage.FLOOR_TOP + Garage.LIFT_HEIGHT, 0.01, "the second one is up")
	assert_true(garage.office_door.locked)
	assert_true(garage.till.has_key, "the office's key is in the counter's till")
	assert_eq(Garage.SPOTS.size(), 12)
	assert_eq(Garage.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in Garage.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), Garage.HALF_X, spot.id)
		assert_lt(absf(at.z), Garage.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_garage_stands_on_its_lot() -> void:
	var garage := _garage()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("garage").size.x > 0.0)
	assert_eq((garage.get_node("City") as Node3D).transform, CityLayout.anchor("garage"))


func test_the_pit_holds_whatever_falls_in() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var prop := _prop(garage, Vector3(Garage.PIT_X, -0.4, -0.5), Vector3.ZERO)
	await wait_physics_frames(60)
	assert_almost_eq(prop.global_position.y, Garage.FLOOR_TOP - Garage.PIT_DEPTH + 0.15, 0.1, "on the pit's floor")


func test_something_thrown_hard_at_a_windshield_cracks_it_once() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var glass: Vector3 = garage.cars[0].position + Garage.WINDSHIELD_AT
	_prop(garage, glass + Vector3(0, 0, 2.0), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_eq(garage.broken_windshields, [0] as Array[int])
	assert_eq(garage.fines, Garage.WINDSHIELD_FINE)
	garage.break_windshield(0)
	assert_eq(garage.fines, Garage.WINDSHIELD_FINE, "only once")


func test_a_slow_prop_doesnt_crack_a_windshield() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var glass: Vector3 = garage.cars[2].position + Garage.WINDSHIELD_AT
	_prop(garage, glass + Vector3(0, 0.6, 0.0), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_eq(garage.broken_windshields.size(), 0)
	assert_eq(garage.fines, 0)


func test_the_till_key_opens_the_office() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var cop: Cop = garage.get_node("Cop")
	garage.till.use(cop)
	assert_true(cop.has_key)
	garage.office_door.use(cop)
	assert_false(garage.office_door.locked)
