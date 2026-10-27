extends GutTest

## The Las Palomas building as a raid with the stolen aquarium's story (docs/diseno/edificio.md, step 6): the
## suspicions, the 2 m tank in the locked study and its extras hidden with the seed, the puddles, the goldfish that
## jumps, the intercom that brings Don Evaristo to the door, the key board, his slips and Doña Pepa's tips, and the
## tank in the trunk solving the case.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")


func _tower(case_seed := 5) -> ApartmentTower:
	var tower: ApartmentTower = TOWER_SCENE.instantiate()
	tower.story_id = "stolen_aquarium"
	tower.case_seed = case_seed
	tower.get_node("Cop").input_enabled = false
	tower.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(tower)
	return tower


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	assert_eq(tower.raid.suspicions.size(), 3)
	assert_has(tower.raid.suspicions, "stolen_aquarium")
	for id: String in tower.raid.suspicions:
		assert_has(ApartmentTower.SUSPICION_POOL, id)
	assert_eq(ApartmentTower.SUSPICION_POOL.size(), 6, "one per story of the building")


func test_the_tank_in_the_study_and_the_extras_hidden() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var tank := tower.main
	assert_not_null(tank)
	assert_almost_eq(tank.mass, 110.0, 0.01, "four cops can lift it")
	var at := tower.to_local(tank.global_position)
	assert_true(ApartmentTower.on_top_floor(at))
	assert_gt(at.x, ApartmentTower.STUDY_WEST, "in the locked study")
	var size := ((tank.get_node("Shape") as CollisionShape3D).shape as BoxShape3D).size
	assert_gt((size.x + size.z) / sqrt(2.0), TowerElevator.INSIDE.x, "it doesn't fit in the elevator, not even crosswise")
	assert_eq(tower.extras.size(), 2, "the net and the ticket")
	await wait_seconds(1.0)
	assert_eq(tank.value, tank.full_value, "it settles without a scratch")
	var other := _tower(6)
	await wait_physics_frames(2)
	assert_ne(tower.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_puddles_are_one_clue() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as StolenAquariumRig
	assert_eq(rig.puddles.size(), StolenAquariumRig.PUDDLES.size())
	rig.puddles[0].use(tower.get_node("Cop"))
	assert_has(tower.raid.clues_found, tr("CLUE_PUDDLES"))
	var clues: int = tower.raid.clues_found.size()
	rig.puddles[1].use(tower.get_node("Cop"))
	assert_eq(tower.raid.clues_found.size(), clues, "the clue only once")


func test_a_hard_hit_and_the_goldfish_jumps_out() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as StolenAquariumRig
	watch_signals(rig)
	tower.main.hit(4.0)
	assert_lt(tower.main.value, tower.main.full_value, "glass: it lost value")
	assert_signal_emitted(rig, "fish_jumped")
	tower.main.hit(4.0)
	assert_signal_emit_count(rig, "fish_jumped", 1, "there's only one fish")


func test_don_evaristo_opens_for_the_warrant() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var cop: Cop = tower.get_node("Cop")
	assert_true(tower.front_door.locked)
	assert_eq(tower.intercom.manager_button.prompt_key(cop), "PROMPT_INTERCOM_MANAGER")
	tower.intercom.manager_button.use(cop)
	assert_false(tower.front_door.locked, "he lets the cops in")
	assert_true(tower._place_facts().door_open, "the checklist knows")


func test_not_while_he_is_up_on_the_12th() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	tower.manager._fix_left = 5.0
	tower.intercom.manager_button.use(tower.get_node("Cop"))
	assert_true(tower.front_door.locked, "nobody answers")


func test_the_key_board_and_who_lets_slip_what() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	assert_eq(tower.key_board.key_hint, "HINT_KEY_BOARD_APARTMENTS")
	var cop: Cop = tower.get_node("Cop")
	tower.key_board.use(cop)
	assert_true(cop.has_key, "30B's key")
	assert_eq(tower.manager.slips.size(), 2)
	assert_true(tower.manager.ask(cop))
	assert_has(tower.raid.clues_found, tower.manager.slips[0])
	assert_eq(tower.pepa.tips[0], tr("PEPA_TIP_stolen_aquarium"))
	var where := tr("LOC_APT_" + ApartmentTower.SPOTS[tower.hidden_spots[5 % 2]].id)
	assert_eq(tower.pepa.tips[1], tr("PEPA_TIP_WHERE") % where)
	tower.pepa.told.emit(tower.pepa.tips[0])
	assert_has(tower.raid.clues_found, tower.pepa.tips[0], "on the checklist")


func test_the_lawyer_loses_the_case() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	tower.manager.lawyer_called.emit()
	assert_true(tower.raid.case_failed)


func test_the_tank_in_the_trunk_solves_the_case() -> void:
	var tower := _tower()
	await wait_physics_frames(10)
	var tank := tower.main
	tank.global_position = tower.car.to_global(Vector3(0, 0.8, -1.7))
	await wait_physics_frames(10)
	assert_true(tower.car.is_delivered(tank))
	assert_true(tower.raid.mark(tower.raid.suspicions.find("stolen_aquarium")))
	assert_eq(tower.raid.objective_facts().extras.size(), 2)
	tower.car.enter(tower.get_node("Cop"))
	assert_true(tower.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_APARTMENTS_TIP_B", "BRIEF_APARTMENTS_TIP_D", "BRIEF_APARTMENTS_TIP_E",
		"BRIEF_STOLEN_AQUARIUM_B", "BRIEF_STOLEN_AQUARIUM_C", "BRIEF_STOLEN_AQUARIUM_D", "OBJ_FIND_STOLEN_AQUARIUM",
		"OBJ_EXTRA_FISHING_NET", "OBJ_EXTRA_AQUARIUM_TICKET", "OBJ_ENTER_APARTMENTS", "OBJ_GUESS_APARTMENTS",
		"OBJ_BROKEN_APARTMENTS", "OBJ_COMPLAINT_APARTMENTS", "EVARISTO_SLIP", "PEPA_TIP_WHERE",
		"PEPA_TIP_stolen_aquarium", "HINT_KEY_BOARD_APARTMENTS", "CASE_FAILED_LAWYER_APARTMENTS", "CLUE_PUDDLES",
		"PROMPT_PUDDLE", "PROMPT_INTERCOM_MANAGER", "HINT_MANAGER_AWAY", "HINT_MANAGER_OPENS"]
	for id: String in ApartmentTower.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for spot: Dictionary in ApartmentTower.SPOTS:
		keys.append("LOC_APT_" + spot.id)
	for key: String in keys:
		assert_ne(tr(key), key)
