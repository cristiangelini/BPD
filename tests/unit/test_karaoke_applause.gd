extends GutTest

## The karaoke as a raid with the applause machine's story (allanamiento-karaoke.md, step 5): the suspicions, the
## machine and its extras hidden with the seed, the applause out of the ceiling speaker while a customer sings, what
## Rosaura lets slip and what Toto saw, and the machine in the trunk solving the case.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke(case_seed := 5) -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.story_id = "karaoke_applause"
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_eq(place.raid.suspicions.size(), 3)
	assert_has(place.raid.suspicions, "karaoke_applause")
	for id: String in place.raid.suspicions:
		assert_has(Karaoke.SUSPICION_POOL, id)
	assert_eq(place.raid.owner_npc, place.owner_boss)


func test_the_machine_and_its_extras_are_hidden_with_the_seed() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_eq(place.main, place.hidden[0])
	assert_almost_eq(place.main.full_value, 1000.0, 0.01)
	assert_eq(place.extras.size(), 2, "the tapes and the list")
	assert_true(Karaoke.SPOTS[place.hidden_spots[0]].heavy, "the machine is heavy")
	var other := _karaoke(6)
	await wait_physics_frames(2)
	assert_ne(place.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_applause_plays_while_a_customer_sings() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: ApplauseRig = place.rig
	assert_eq(rig.applauses, 0)
	place._turn_left = 0.0
	await wait_until(func() -> bool: return place.on_turn != null and place.on_turn.singing, 8.0)
	await wait_seconds(ApplauseRig.APPLAUSE_EVERY + 0.5)
	assert_gt(rig.applauses, 0, "however off key")
	assert_false(rig.heard, "nobody was under the speaker")


func test_a_cop_under_the_speaker_hears_where_it_comes_from_once() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: ApplauseRig = place.rig
	var cop: Cop = place.get_node("Cop")
	cop.global_position = place.to_global(Vector3(ApplauseRig.SPEAKER_AT.x + 1.0, Karaoke.FLOOR_TOP + 0.05,
		ApplauseRig.SPEAKER_AT.z))
	await wait_physics_frames(2)
	rig.applaud()
	assert_true(rig.heard)
	assert_has(place.raid.clues_found, tr("KARAOKE_APPLAUSE_CLUE"))
	var clues: int = place.raid.clues_found.size()
	rig.applaud()
	assert_eq(place.raid.clues_found.size(), clues, "the clue is there once")


func test_rosaura_slips_and_toto_saw_where() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_eq(place.owner_boss.slips.size(), 3)
	assert_true(place.owner_boss.ask(place.get_node("Cop")))
	assert_eq(place.raid.clues_found.size(), 1)
	var where := tr("LOC_" + Karaoke.SPOTS[place.hidden_spots[5 % 3]].id)
	assert_eq(place.toto.clue, tr("CLUE_TOTO") % where)
	place.toto.volume_down(place.get_node("Cop"))
	assert_has(place.raid.clues_found, place.toto.clue, "on the checklist")


func test_the_machine_in_the_trunk_solves_the_case() -> void:
	var place := _karaoke()
	await wait_physics_frames(10)
	var machine := place.main
	machine.global_position = place.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(place.car.is_delivered(machine))
	assert_true(place.raid.mark(place.raid.suspicions.find("karaoke_applause")))
	assert_eq(place.raid.objective_facts().extras.size(), 2)
	place.car.enter(place.get_node("Cop"))
	assert_true(place.raid.case_solved)


func test_the_fines_go_to_the_case_and_the_lawyer_fails_it() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	place.break_screen()
	assert_eq(place.raid.fines, Karaoke.SCREEN_FINE)
	assert_eq(place.raid.objective_facts().broken, 1)
	place.owner_boss.blame(FloorBoss.MAX_COMPLAINT, "DIVA_SINGER")
	assert_true(place.raid.case_failed)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_KARAOKE_TIP_B", "BRIEF_KARAOKE_TIP_D", "BRIEF_KARAOKE_TIP_E",
		"BRIEF_KARAOKE_APPLAUSE_B", "BRIEF_KARAOKE_APPLAUSE_C", "BRIEF_KARAOKE_APPLAUSE_D", "OBJ_FIND_APPLAUSE_MACHINE",
		"OBJ_EXTRA_APPLAUSE_TAPES", "OBJ_EXTRA_WINNERS_LIST", "OBJ_ENTER_KARAOKE", "OBJ_GUESS_KARAOKE",
		"OBJ_BROKEN_KARAOKE", "OBJ_COMPLAINT_KARAOKE", "DIVA_SLIP", "CLUE_TOTO", "TOTO_CLUE_karaoke_applause",
		"KARAOKE_APPLAUSE", "KARAOKE_APPLAUSE_CLUE", "KARAOKE_NEPHEW_FRAME", "CRIME_owner_karaoke",
		"CONFESS_owner_karaoke", "CASE_FAILED_LAWYER_KARAOKE", "HINT_TILL_KEY_KARAOKE"]
	for id: String in Karaoke.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key, key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_karaoke"))
