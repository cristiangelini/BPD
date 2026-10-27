extends GutTest

## The dental office as a raid with the gold teeth story (allanamiento-dentista.md, step 5): the suspicions, the box of
## ingots and its extras hidden with the seed, the X-ray film with the ingot, what Dr. Molina lets slip and what Lucho
## saw, the lawyer failing the case and the box in the trunk solving it.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office(case_seed := 5) -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.story_id = "gold_teeth"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_eq(office.raid.suspicions.size(), 3)
	assert_has(office.raid.suspicions, "gold_teeth")
	for id: String in office.raid.suspicions:
		assert_has(DentistRaid.SUSPICION_POOL, id)
	assert_eq(office.raid.owner_npc, office.molina)


func test_the_box_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_eq(office.main, office.hidden[0])
	assert_almost_eq((office.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(DentistRaid.SPOTS[office.hidden_spots[0]].heavy)
	assert_eq(office.extras.size(), 2, "the crucible and the price list")
	var other := _office(6)
	await wait_physics_frames(2)
	assert_ne(office.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_one_xray_film_shows_the_ingot_and_the_first_time_is_a_clue() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as GoldTeethRig
	assert_between(rig.ingot_plate, 1, GoldTeethRig.PLATES - 1, "never the first film up")
	assert_eq(rig.plate, 0)
	var cop: Cop = office.get_node("Cop")
	for i in rig.ingot_plate:
		rig.button.use(cop)
	assert_eq(rig.plate, rig.ingot_plate)
	assert_true(rig.seen_ingot)
	assert_has(office.raid.clues_found, tr("CLUE_XRAY_INGOT"))
	var clues: int = office.raid.clues_found.size()
	for i in GoldTeethRig.PLATES:
		rig.next_plate()
	assert_eq(rig.plate, rig.ingot_plate, "around again")
	assert_eq(office.raid.clues_found.size(), clues, "the clue only once")


func test_molina_slips_and_lucho_saw_where() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_eq(office.molina.slips.size(), 3)
	assert_true(office.molina.ask(office.get_node("Cop")))
	assert_eq(office.raid.clues_found.size(), 1)
	var where := tr("LOC_" + DentistRaid.SPOTS[office.hidden_spots[5 % 3]].id)
	assert_eq(office.lucho.clue, tr("CLUE_LUCHO") % where)
	var cop: Cop = office.get_node("Cop")
	cop.get_node("Grabber").grab(office.candies[0])
	office.lucho.use(cop)
	assert_has(office.raid.clues_found, office.lucho.clue, "on the checklist")


func test_his_lawyer_fails_the_case() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.molina.praise(-FloorBoss.MAX_COMPLAINT, "MOLINA_SAW")
	assert_true(office.raid.case_failed)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var office := _office()
	await wait_physics_frames(10)
	var box := office.main
	box.global_position = office.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(office.car.is_delivered(box))
	assert_true(office.raid.mark(office.raid.suspicions.find("gold_teeth")))
	assert_eq(office.raid.objective_facts().extras.size(), 2)
	office.car.enter(office.get_node("Cop"))
	assert_true(office.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_DENTIST_TIP_B", "BRIEF_DENTIST_TIP_D", "BRIEF_DENTIST_TIP_E",
		"BRIEF_GOLD_TEETH_B", "BRIEF_GOLD_TEETH_C", "BRIEF_GOLD_TEETH_D", "OBJ_FIND_GOLD_CROWN_BOX",
		"OBJ_EXTRA_GOLD_CRUCIBLE", "OBJ_EXTRA_CROWN_PRICE_LIST", "OBJ_ENTER_DENTIST", "OBJ_GUESS_DENTIST",
		"OBJ_BROKEN_DENTIST", "OBJ_COMPLAINT_DENTIST", "MOLINA_SLIP", "CLUE_LUCHO", "LUCHO_CLUE_gold_teeth",
		"CLUE_XRAY_INGOT", "XRAY_INGOT", "PROMPT_XRAY_NEXT"]
	for id: String in DentistRaid.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
