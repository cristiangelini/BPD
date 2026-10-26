extends GutTest

## The cake lab as a raid with the silver-filled cake's story (docs/diseno/laboratorio.md, step 4): the suspicions,
## the 12 kg cake and its extras hidden with the seed, the banknote in Pocha's sample, the mixers that spit banknotes,
## what the chef lets slip and what Pocha saw, the key in the till and the cake in the trunk solving the case.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab(case_seed := 5) -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	lab.story_id = "silver_cake"
	lab.case_seed = case_seed
	lab.get_node("Cop").input_enabled = false
	lab.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(lab)
	return lab


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.raid.suspicions.size(), 3)
	assert_has(lab.raid.suspicions, "silver_cake")
	for id: String in lab.raid.suspicions:
		assert_has(CakeLab.SUSPICION_POOL, id)
	assert_eq(lab.raid.owner_npc, lab.chef)


func test_the_cake_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.main, lab.hidden[0])
	assert_almost_eq((lab.main as RigidBody3D).mass, 12.0, 0.01)
	assert_true(CakeLab.SPOTS[lab.hidden_spots[0]].heavy, "the 12 kg cake in a spot it fits")
	assert_eq(lab.extras.size(), 2, "the bill mold and the special-orders notebook")
	var other := _lab(6)
	await wait_physics_frames(2)
	assert_ne(lab.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_a_sample_has_the_corner_of_a_bill() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.pocha.sample_hint, "HINT_SAMPLE_BILL")
	lab.pocha.use(lab.get_node("Cop"))
	assert_true(lab.pocha.has_told)


func test_a_mixer_spits_bills_and_the_first_time_is_a_clue() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as SilverCakeRig
	assert_eq(rig.switches.size(), CakeLab.MIXERS.size())
	var bills_before := lab.get_child_count()
	rig.switches[0].use(lab.get_node("Cop"))
	assert_eq(rig.spits, 1)
	assert_eq(lab.get_child_count() - bills_before, SilverCakeRig.BILLS, "the bills fly")
	assert_has(lab.raid.clues_found, tr("CLUE_MIXER_BILLS"))
	var clues: int = lab.raid.clues_found.size()
	rig.switches[1].use(lab.get_node("Cop"))
	assert_eq(rig.spits, 2)
	assert_eq(lab.raid.clues_found.size(), clues, "the clue only once")


func test_the_chef_slips_and_pocha_saw_where() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.chef.slips.size(), 3)
	assert_true(lab.chef.ask(lab.get_node("Cop")))
	assert_eq(lab.raid.clues_found.size(), 1)
	var where := tr("LOC_" + CakeLab.SPOTS[lab.hidden_spots[5 % 3]].id)
	assert_eq(lab.pocha.clue, tr("CLUE_POCHA") % where)
	var told := []
	lab.pocha.told.connect(func(text: String) -> void: told.append(text))
	lab.pocha.use(lab.get_node("Cop"))
	assert_eq(told, [lab.pocha.clue])
	assert_has(lab.raid.clues_found, lab.pocha.clue, "on the checklist")


func test_the_till_has_the_key_and_the_chef_minds_it() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.till.key_hint, "HINT_TILL_KEY_CAKE_LAB")
	var before := lab.chef.complaint
	lab.chef.global_position = Vector3(-4.0, CakeLab.FLOOR_TOP, 8.5) # in the tasting room
	await wait_physics_frames(2)
	lab.till.opened.emit(lab.till.global_position)
	assert_gt(lab.chef.complaint, before)


func test_the_cake_in_the_trunk_solves_the_case() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	var cake := lab.main
	cake.global_position = lab.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(lab.car.is_delivered(cake))
	assert_true(lab.raid.mark(lab.raid.suspicions.find("silver_cake")))
	assert_eq(lab.raid.objective_facts().extras.size(), 2)
	lab.car.enter(lab.get_node("Cop"))
	assert_true(lab.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_CAKE_LAB_TIP_B", "BRIEF_CAKE_LAB_TIP_D", "BRIEF_CAKE_LAB_TIP_E",
		"BRIEF_SILVER_CAKE_B", "BRIEF_SILVER_CAKE_C", "BRIEF_SILVER_CAKE_D", "OBJ_FIND_SILVER_CAKE",
		"OBJ_EXTRA_BILL_MOLD", "OBJ_EXTRA_ORDERS_NOTEBOOK", "OBJ_ENTER_CAKE_LAB", "OBJ_GUESS_CAKE_LAB",
		"OBJ_BROKEN_CAKE_LAB", "OBJ_COMPLAINT_CAKE_LAB", "CHEF_SLIP", "CLUE_POCHA", "POCHA_CLUE_silver_cake",
		"HINT_TILL_KEY_CAKE_LAB", "HINT_ESCAPE_cake_lab", "CRIME_owner_cake_lab", "CONFESS_owner_cake_lab",
		"CASE_FAILED_LAWYER_CAKE_LAB", "CLUE_MIXER_BILLS", "PROMPT_MIXER_SWITCH", "HINT_SAMPLE_BILL"]
	for id: String in CakeLab.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_cake_lab"))
	assert_true(ChaseSuspect.MODELS.has("cake_lab"))
