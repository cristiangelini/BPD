extends GutTest

## The dents on purpose story (allanamiento-taller.md, step 5): the dent hammer with the plates list and the map with
## crosses hidden with the seed, the round dents on one car on the floor that are a clue the first time a cop looks at
## them, and the hammer in the trunk solving the case.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage(case_seed := 5) -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.story_id = "dented_on_purpose"
	garage.case_seed = case_seed
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func test_the_hammer_and_its_extras_are_hidden() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.main, garage.hidden[0])
	assert_almost_eq((garage.main as RigidBody3D).mass, 3.0, 0.01)
	assert_eq(garage.extras.size(), 2, "the plates list and the map")


func test_a_car_on_the_floor_has_the_dents() -> void:
	var dented := {}
	for case_seed in 12:
		var garage := _garage(case_seed)
		await wait_physics_frames(1)
		var rig := garage.rig as DentedOnPurposeRig
		assert_has([0, 2], rig.dented, "a car on the floor, not the one on the lift")
		var dents := garage.cars[rig.dented].get_children().filter(func(node: Node) -> bool:
			return node.name.begins_with("Dent") and node is MeshInstance3D)
		assert_eq(dents.size(), DentedOnPurposeRig.DENT_ZS.size())
		dented[rig.dented] = true
		garage.free()
	assert_eq(dented.size(), 2, "either car, with the seed")


func test_looking_at_the_dents_is_a_clue_once() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var rig := garage.rig as DentedOnPurposeRig
	var cop: Cop = garage.get_node("Cop")
	assert_eq(rig.spot.prompt_key(cop), "PROMPT_LOOK_DENTS")
	rig.spot.use(cop)
	assert_has(garage.raid.clues_found, tr("CLUE_DENTS"))
	var clues: int = garage.raid.clues_found.size()
	rig.spot.use(cop)
	assert_eq(garage.raid.clues_found.size(), clues, "the clue only once")


func test_the_hammer_in_the_trunk_solves_the_case() -> void:
	var garage := _garage()
	await wait_physics_frames(10)
	garage.main.global_position = garage.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(garage.car.is_delivered(garage.main))
	assert_true(garage.raid.mark(garage.raid.suspicions.find("dented_on_purpose")))
	garage.car.enter(garage.get_node("Cop"))
	assert_true(garage.raid.case_solved)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_DENTED_B", "BRIEF_DENTED_C", "BRIEF_DENTED_D", "OBJ_FIND_DENT_HAMMER",
			"OBJ_EXTRA_PLATES_LIST", "OBJ_EXTRA_CROSS_MAP", "GRASITA_CLUE_dented_on_purpose", "PROMPT_LOOK_DENTS",
			"HINT_DENTS", "CLUE_DENTS"]:
		assert_ne(tr(key), key)
