extends GutTest

## The fun fair raid with the stuffed prizes (allanamiento-parque.md, step 5): the same case as every raid, the bag of
## stolen watches in the patrol car's trunk, the giant teddy going "tic tac", the heavy prize teddies, Don Tómbola's
## slips and Nube's clue.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair(case_seed := 5) -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.story_id = "stuffed_prizes"
	fair.case_seed = case_seed
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func test_the_watch_bag_solves_the_case() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	assert_has(fair.raid.suspicions, "stuffed_prizes")
	assert_eq(fair.raid.suspicions.size(), 3)
	assert_eq(fair.main.scene_file_path, "res://scenes/props/fair_watch_bag.tscn")
	assert_eq(fair.extras.size(), 2, "the client list and the needle")
	assert_eq(fair.raid.owner_npc, fair.owner_npc)
	fair.main.global_position = fair.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(fair.car.is_delivered(fair.main))
	assert_true(fair.raid.mark(fair.raid.suspicions.find("stuffed_prizes")))
	fair.car.enter(fair.get_node("Cop"))
	assert_true(fair.raid.case_solved)


func test_the_giant_teddy_ticks_near_a_cop_and_the_first_time_is_a_clue() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var rig := fair.rig as StuffedPrizesRig
	assert_eq(rig.ticks, 0, "nobody near it")
	fair.get_node("Cop").global_position = fair.to_global(Fair.TEDDY_AT + Vector3(0, 0.1, 1.5))
	await wait_seconds(StuffedPrizesRig.TICK_EVERY * 2 + 0.2)
	assert_gt(rig.ticks, 1, "tic tac, tic tac")
	assert_eq(fair.raid.clues_found.count(tr("CLUE_TEDDY_TICKS")), 1, "one clue")


func test_the_prize_teddies_weigh_triple_and_land_with_a_clonc() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	var rig := fair.rig as StuffedPrizesRig
	assert_eq(fair.plushes.size(), Fair.PLUSHES.size())
	assert_almost_eq(fair.plushes[0].mass, Fair.PLUSH_KG * StuffedPrizesRig.HEAVY, 0.01)
	assert_eq(rig.cloncs, 0, "they sit on the shelf")
	fair.plushes[0].global_position = fair.to_global(Fair.CANS_AT + Vector3(0, 0.5, 2.0))
	await wait_physics_frames(30)
	assert_eq(rig.cloncs, 1)


func test_don_tombola_slips_and_nube_tells_where_he_hid_something() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	assert_eq(fair.owner_npc.slips.size(), 3)
	assert_string_contains(fair.nube.clue_speech, tr("LOC_" + Fair.SPOTS[fair.hidden_spots[5 % 3]].id))
	fair.nube.won(fair.get_node("Cop"))
	assert_has(fair.raid.clues_found, fair.nube.clue)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_FAIR_TIP_B", "BRIEF_FAIR_TIP_D", "BRIEF_FAIR_TIP_E", "BRIEF_STUFFED_PRIZES_B",
			"BRIEF_STUFFED_PRIZES_C", "BRIEF_STUFFED_PRIZES_D", "OBJ_FIND_WATCH_BAG", "OBJ_EXTRA_CLIENT_LIST",
			"OBJ_EXTRA_NEEDLE_THREAD", "OBJ_ENTER_FAIR", "OBJ_GUESS_FAIR", "OBJ_BROKEN_FAIR", "OBJ_COMPLAINT_FAIR",
			"TOMBOLA_SLIP", "CLUE_NUBE", "NUBE_CLUE_stuffed_prizes", "CLUE_TEDDY_TICKS", "FAIR_TICK", "FAIR_CLONC",
			"CASE_FAILED_LAWYER_FAIR", "CRIME_owner_fair", "CONFESS_owner_fair"]:
		assert_ne(tr(key), key, key)
	for id: String in Fair.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id, id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id, id)
