extends GutTest

## The garage as a raid with the swapped plates' story (allanamiento-taller.md, step 4): the suspicions, the crate of
## plates and its extras hidden with the seed, the car with fresh paint that stains whoever touches it, what Don Tuerca
## lets slip and what Grasita saw, and the crate in the trunk solving the case.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage(case_seed := 5) -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.story_id = "swapped_plates"
	garage.case_seed = case_seed
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.raid.suspicions.size(), 3)
	assert_has(garage.raid.suspicions, "swapped_plates")
	for id: String in garage.raid.suspicions:
		assert_has(Garage.SUSPICION_POOL, id)
	assert_eq(garage.raid.owner_npc, garage.tuerca)


func test_the_crate_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.main, garage.hidden[0])
	assert_almost_eq((garage.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(Garage.SPOTS[garage.hidden_spots[0]].heavy, "the crate in a spot it fits")
	assert_eq(garage.extras.size(), 2, "the list and the spray can")
	var other := _garage(6)
	await wait_physics_frames(2)
	assert_ne(garage.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_painted_car_stains_a_cop_and_the_first_time_is_a_clue() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var rig := garage.rig as SwappedPlatesRig
	assert_has([0, 2], rig.painted, "a car on the floor, not the one on the lift")
	var cop: Cop = garage.get_node("Cop")
	var side := garage.cars[rig.painted].position + Vector3(Garage.CAR_SIZE.x / 2 + 0.3, 0.1, 0)
	cop.global_position = garage.to_global(side)
	await wait_physics_frames(6)
	assert_true(rig.touched.has(cop))
	assert_has(garage.raid.clues_found, tr("CLUE_WET_PAINT"))
	var clues: int = garage.raid.clues_found.size()
	rig.touch(cop)
	assert_eq(garage.raid.clues_found.size(), clues, "the clue only once")


func test_tuerca_slips_and_grasita_saw_where() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.tuerca.slips.size(), 3)
	assert_true(garage.tuerca.ask(garage.get_node("Cop")))
	assert_eq(garage.raid.clues_found.size(), 1)
	var where := tr("LOC_" + Garage.SPOTS[garage.hidden_spots[5 % 3]].id)
	assert_eq(garage.grasita.clue, tr("CLUE_GRASITA") % where)
	var cop: Cop = garage.get_node("Cop")
	garage.grasita.use(cop)
	garage.grasita.hand(garage.tools[garage.grasita.wanted], cop)
	assert_has(garage.raid.clues_found, garage.grasita.clue, "on the checklist")


func test_the_lawyer_loses_the_case() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	garage.tuerca.scold(FloorBoss.MAX_COMPLAINT, "TUERCA_NOTICED")
	assert_true(garage.raid.case_failed)


func test_the_crate_in_the_trunk_solves_the_case() -> void:
	var garage := _garage()
	await wait_physics_frames(10)
	var crate := garage.main
	crate.global_position = garage.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(garage.car.is_delivered(crate))
	assert_true(garage.raid.mark(garage.raid.suspicions.find("swapped_plates")))
	assert_eq(garage.raid.objective_facts().extras.size(), 2)
	garage.car.enter(garage.get_node("Cop"))
	assert_true(garage.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_GARAGE_TIP_B", "BRIEF_GARAGE_TIP_D", "BRIEF_GARAGE_TIP_E",
		"BRIEF_SWAPPED_PLATES_B", "BRIEF_SWAPPED_PLATES_C", "BRIEF_SWAPPED_PLATES_D", "OBJ_FIND_PLATES_BOX",
		"OBJ_EXTRA_STOLEN_LIST", "OBJ_EXTRA_SPRAY_CAN", "OBJ_ENTER_GARAGE", "OBJ_GUESS_GARAGE", "OBJ_BROKEN_GARAGE",
		"OBJ_COMPLAINT_GARAGE", "TUERCA_SLIP", "CLUE_GRASITA", "GRASITA_CLUE_swapped_plates", "CLUE_WET_PAINT",
		"HINT_WET_PAINT", "GARAGE_WET_PAINT", "HINT_ESCAPE_garage", "CRIME_owner_garage", "CONFESS_owner_garage",
		"CASE_FAILED_LAWYER_GARAGE", "HINT_TILL_KEY_GARAGE"]
	for id: String in Garage.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_garage"))
	assert_true(ChaseSuspect.MODELS.has("garage"))
	assert_true(RaidEscape.PLACES.has("garage"))


func test_don_tuerca_gets_away_in_a_car() -> void:
	var garage := _garage(7)
	await wait_physics_frames(30)
	garage.raid.escape.flee()
	var chase := garage.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "garage")
