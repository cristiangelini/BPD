extends GutTest

## The insurance office as a raid with the fake crashes' story (docs/diseno/seguros.md, step 4): the suspicions, the
## crash diorama and its extras hidden with the seed, the claim folder as its clue, the toy cars cops slip on, what
## Mirta lets slip and what Coca saw, the key in the till and the diorama in the trunk solving the case.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office(case_seed := 5) -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.story_id = "fake_crashes"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_eq(office.raid.suspicions.size(), 3)
	assert_has(office.raid.suspicions, "fake_crashes")
	for id: String in office.raid.suspicions:
		assert_has(InsuranceOffice.SUSPICION_POOL, id)
	assert_eq(office.raid.owner_npc, office.mirta)


func test_the_diorama_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_eq(office.main, office.hidden[0])
	assert_almost_eq((office.main as RigidBody3D).mass, 8.0, 0.01)
	assert_true(InsuranceOffice.SPOTS[office.hidden_spots[0]].heavy, "the 8 kg diorama in a spot it fits")
	assert_eq(office.extras.size(), 2, "the photos and the box of toy cars")
	var other := _office(6)
	await wait_physics_frames(2)
	assert_ne(office.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_claim_folder_is_a_clue() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var folder := (office.rig as FakeCrashesRig).folder
	folder.use(office.get_node("Cop"))
	assert_has(office.raid.clues_found, tr("CLUE_CLAIM_PHOTOS"))


func test_stepping_on_a_toy_car_makes_a_cop_slip() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as FakeCrashesRig
	assert_eq(rig.cars.size(), FakeCrashesRig.CARS)
	var cop: Cop = office.get_node("Cop")
	var car := rig.cars[0]
	var at := car.global_position
	cop.global_position = Vector3(at.x, InsuranceOffice.FLOOR_TOP + 0.1, at.z)
	cop.velocity = Vector3(2.0, 0, 0)
	rig._physics_process(0.016)
	assert_eq(rig.slips, 1, "stepped on it")
	await wait_seconds(0.7)
	assert_gt(car.global_position.distance_to(at), 1.0, "the car shot off")
	cop.velocity = Vector3.ZERO
	rig._physics_process(0.016)
	assert_eq(rig.slips, 1, "standing still nothing happens")


func test_mirta_slips_and_coca_saw_where() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_eq(office.mirta.slips.size(), 3)
	assert_true(office.mirta.ask(office.get_node("Cop")))
	assert_eq(office.raid.clues_found.size(), 1)
	var where := tr("LOC_" + InsuranceOffice.SPOTS[office.hidden_spots[5 % 3]].id)
	assert_eq(office.coca.clue, tr("CLUE_COCA") % where)


func test_the_till_has_the_key_and_mirta_minds_it() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_eq(office.till.key_hint, "HINT_TILL_KEY_INSURANCE")
	var before := office.mirta.complaint
	office.mirta.global_position = Vector3(-1.8, InsuranceOffice.FLOOR_TOP, 6.8) # in the reception
	await wait_physics_frames(2)
	office.till.opened.emit(office.till.global_position)
	assert_gt(office.mirta.complaint, before)


func test_the_diorama_in_the_trunk_solves_the_case() -> void:
	var office := _office()
	await wait_physics_frames(10)
	var diorama := office.main
	diorama.global_position = office.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(office.car.is_delivered(diorama))
	assert_true(office.raid.mark(office.raid.suspicions.find("fake_crashes")))
	assert_eq(office.raid.objective_facts().extras.size(), 2)
	office.car.enter(office.get_node("Cop"))
	assert_true(office.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_INSURANCE_TIP_B", "BRIEF_INSURANCE_TIP_D", "BRIEF_INSURANCE_TIP_E",
		"BRIEF_FAKE_CRASHES_B", "BRIEF_FAKE_CRASHES_C", "BRIEF_FAKE_CRASHES_D", "OBJ_FIND_CRASH_MODEL",
		"OBJ_EXTRA_CRASH_PHOTOS", "OBJ_EXTRA_TOY_CAR_BOX", "OBJ_ENTER_INSURANCE", "OBJ_GUESS_INSURANCE",
		"OBJ_BROKEN_INSURANCE", "OBJ_COMPLAINT_INSURANCE", "BOSS_SLIP", "CLUE_COCA", "COCA_CLUE_fake_crashes",
		"HINT_TILL_KEY_INSURANCE", "HINT_ESCAPE_insurance", "CRIME_owner_insurance", "CONFESS_owner_insurance",
		"CASE_FAILED_LAWYER_INSURANCE", "CLUE_CLAIM_PHOTOS", "PROMPT_CLAIM_PHOTOS", "HINT_TOY_CAR"]
	for id: String in InsuranceOffice.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_insurance"))
	assert_true(ChaseSuspect.MODELS.has("insurance"))
