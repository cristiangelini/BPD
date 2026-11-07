extends GutTest

## The comisario's car story (allanamiento-taller.md, step 5): the taxi sign with the taximeter and the trips notebook
## hidden with the seed, the comisario's car on the floor with its sticker and a dashboard with 1500 km too many (a clue
## the first time a cop reads it) and the sign in the trunk solving the case.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage(case_seed := 5) -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.story_id = "comisario_taxi"
	garage.case_seed = case_seed
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func test_the_sign_and_its_extras_are_hidden() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.main, garage.hidden[0])
	assert_almost_eq((garage.main as RigidBody3D).mass, 2.0, 0.01)
	assert_eq(garage.extras.size(), 2, "the taximeter and the trips notebook")


func test_the_comisario_s_car_has_the_sticker_and_either_car_can_be_it() -> void:
	var cars := {}
	for case_seed in 12:
		var garage := _garage(case_seed)
		await wait_physics_frames(1)
		var rig := garage.rig as ComisarioTaxiRig
		assert_has([0, 2], rig.comisario_car, "a car on the floor, not the one on the lift")
		assert_not_null(garage.cars[rig.comisario_car].get_node_or_null("Sticker"))
		assert_eq(rig.dashboards[rig.comisario_car].reading, "HINT_COMISARIO_KM")
		cars[rig.comisario_car] = true
		garage.free()
	assert_eq(cars.size(), 2, "either car, with the seed")


func test_only_the_comisario_s_dashboard_is_a_clue_and_only_once() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var rig := garage.rig as ComisarioTaxiRig
	var cop: Cop = garage.get_node("Cop")
	var other: int = 2 - rig.comisario_car
	rig.dashboards[other].use(cop)
	assert_does_not_have(garage.raid.clues_found, tr("CLUE_COMISARIO_KM"))
	rig.dashboards[rig.comisario_car].use(cop)
	assert_has(garage.raid.clues_found, tr("CLUE_COMISARIO_KM"))
	var clues: int = garage.raid.clues_found.size()
	rig.dashboards[rig.comisario_car].use(cop)
	assert_eq(garage.raid.clues_found.size(), clues, "the clue only once")


func test_the_sign_in_the_trunk_solves_the_case() -> void:
	var garage := _garage()
	await wait_physics_frames(10)
	garage.main.global_position = garage.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(garage.car.is_delivered(garage.main))
	assert_true(garage.raid.mark(garage.raid.suspicions.find("comisario_taxi")))
	garage.car.enter(garage.get_node("Cop"))
	assert_true(garage.raid.case_solved)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_COMISARIO_TAXI_B", "BRIEF_COMISARIO_TAXI_C", "BRIEF_COMISARIO_TAXI_D", "OBJ_FIND_TAXI_SIGN",
			"OBJ_EXTRA_TAXIMETER", "OBJ_EXTRA_TRIPS_NOTEBOOK", "GRASITA_CLUE_comisario_taxi", "GARAGE_COMISARIO_STICKER",
			"HINT_COMISARIO_KM", "CLUE_COMISARIO_KM"]:
		assert_ne(tr(key), key)
