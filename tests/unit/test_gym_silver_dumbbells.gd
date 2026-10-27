extends GutTest

## The gym as a raid with the silver dumbbells' story (allanamiento-gimnasio.md, step 4): the suspicions, the 20 kg
## dumbbell full of bills and its extras hidden with the seed, the rack dumbbell that jingles with coins, the ones that
## spill toy bills, what the profe lets slip and what Lula saw, and the dumbbell in the trunk solving the case.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")


func _gym(case_seed := 5) -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.story_id = "silver_dumbbells"
	gym.case_seed = case_seed
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	assert_eq(gym.raid.suspicions.size(), 3)
	assert_has(gym.raid.suspicions, "silver_dumbbells")
	for id: String in gym.raid.suspicions:
		assert_has(GymRaid.SUSPICION_POOL, id)
	assert_eq(gym.raid.owner_npc, gym.coach)


func test_the_dumbbell_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	assert_eq(gym.main, gym.hidden[0])
	assert_almost_eq((gym.main as RigidBody3D).mass, 20.0, 0.01)
	assert_true(GymRaid.SPOTS[gym.hidden_spots[0]].heavy, "the 20 kg dumbbell in a spot it fits")
	assert_eq(gym.extras.size(), 2, "the rigged scale and the special fees sheet")
	var other := _gym(6)
	await wait_physics_frames(2)
	assert_ne(gym.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_coins_dumbbell_jingles_and_the_first_time_is_a_clue() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as SilverDumbbellsRig
	assert_between(rig.coins, 0, gym.dumbbells.size() - 1)
	assert_false(rig.toys.has(rig.coins))
	var dumbbell := gym.dumbbells[rig.coins]
	dumbbell.global_position = gym.to_global(Vector3(0, GymHall.FLOOR_TOP + 1.0, 1.5))
	await wait_physics_frames(60)
	assert_eq(rig.jingles, 1)
	assert_has(gym.raid.clues_found, tr("CLUE_DUMBBELL_COINS"))
	var clues: int = gym.raid.clues_found.size()
	dumbbell.global_position = gym.to_global(Vector3(0, GymHall.FLOOR_TOP + 1.0, 1.5))
	await wait_physics_frames(60)
	assert_eq(rig.jingles, 2, "it jingles every time")
	assert_eq(gym.raid.clues_found.size(), clues, "the clue only once")


func test_the_other_dumbbells_burst_open_once_some_with_toy_bills() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as SilverDumbbellsRig
	var others: Array = range(gym.dumbbells.size()).filter(func(i: int) -> bool: return i != rig.coins)
	for i: int in others:
		var before := gym.get_child_count()
		rig.landed(i)
		assert_true(rig.opened.has(i))
		var spilled := gym.get_child_count() - before
		assert_eq(spilled > 0, rig.toys.has(i), "dumbbell %d" % i)
		var again := gym.get_child_count()
		rig.landed(i)
		assert_eq(gym.get_child_count(), again, "only once")
	assert_eq(rig.jingles, 0, "no coins in them")


func test_the_profe_slips_and_lula_saw_where() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	assert_eq(gym.coach.slips.size(), 3)
	assert_true(gym.coach.ask(gym.get_node("Cop")))
	assert_eq(gym.raid.clues_found.size(), 1)
	var where := tr("LOC_" + GymRaid.SPOTS[gym.hidden_spots[5 % 3]].id)
	assert_eq(gym.lula.clue, tr("CLUE_LULA") % where)
	var cop: Cop = gym.get_node("Cop")
	gym.lula.run_beside(cop, true, GymReceptionist.RUN_TIME + 0.1)
	assert_has(gym.raid.clues_found, gym.lula.clue, "on the checklist")


func test_the_dumbbell_in_the_trunk_solves_the_case() -> void:
	var gym := _gym()
	await wait_physics_frames(10)
	var dumbbell := gym.main
	dumbbell.global_position = gym.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(gym.car.is_delivered(dumbbell))
	assert_true(gym.raid.mark(gym.raid.suspicions.find("silver_dumbbells")))
	assert_eq(gym.raid.objective_facts().extras.size(), 2)
	gym.car.enter(gym.get_node("Cop"))
	assert_true(gym.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_GYM_TIP_B", "BRIEF_GYM_TIP_D", "BRIEF_GYM_TIP_E", "BRIEF_SILVER_DUMBBELLS_B",
		"BRIEF_SILVER_DUMBBELLS_C", "BRIEF_SILVER_DUMBBELLS_D", "OBJ_FIND_SILVER_DUMBBELL", "OBJ_EXTRA_FAKE_SCALE",
		"OBJ_EXTRA_QUOTA_SHEET", "OBJ_ENTER_GYM", "OBJ_GUESS_GYM", "OBJ_BROKEN_GYM", "OBJ_COMPLAINT_GYM", "COACH_SLIP",
		"CLUE_LULA", "LULA_CLUE_silver_dumbbells", "CLUE_DUMBBELL_COINS", "GYM_TOY_BILLS", "HINT_ESCAPE_gym",
		"CRIME_owner_gym", "CONFESS_owner_gym", "CASE_FAILED_LAWYER_GYM", "HINT_TILL_KEY_GYM"]
	for id: String in GymRaid.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_gym"))
	assert_true(ChaseSuspect.MODELS.has("gym"))
	assert_true(RaidEscape.PLACES.has("gym"))
