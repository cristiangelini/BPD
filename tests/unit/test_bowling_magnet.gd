extends GutTest

## The bowling alley as a raid with the magnet ball's story (allanamiento-bolera.md, step 5): the suspicions, the golden
## ball and its extras hidden with the seed, the rack ball that sticks to the metal bin, lane 1's pins falling before a
## league ball gets there, what Don Chuza lets slip and what Pipo saw, and the golden ball in the trunk solving the case.

const SCENE := preload("res://scenes/levels/bowling.tscn")


func _alley(case_seed := 5) -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.story_id = "bowl_magnet"
	alley.case_seed = case_seed
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.raid.suspicions.size(), 3)
	assert_has(alley.raid.suspicions, "bowl_magnet")
	for id: String in alley.raid.suspicions:
		assert_has(Bowling.SUSPICION_POOL, id)
	assert_eq(alley.raid.owner_npc, alley.owner_boss)


func test_the_golden_ball_and_its_extras_are_hidden_with_the_seed() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.main, alley.hidden[0])
	assert_almost_eq(alley.main.full_value, 1000.0, 0.01)
	assert_eq(alley.extras.size(), 2, "the remote and the bets")
	var other := _alley(6)
	await wait_physics_frames(2)
	assert_ne(alley.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_magnetic_ball_sticks_to_the_bin_once() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var rig := alley.rig
	var ball: BowlingBall = rig.magnetic
	ball.global_position = alley.to_global(rig.BIN_AT + Vector3(-1.0, BowlingBall.RADIUS + 0.01, 0))
	ball.sleeping = false
	await wait_seconds(1.5)
	assert_true(rig.stuck, "pulled to the bin")
	assert_has(alley.raid.clues_found, tr("BOWL_MAGNET_CLUE"))
	var clues: int = alley.raid.clues_found.size()
	rig.stuck = false
	rig._pull()
	assert_eq(alley.raid.clues_found.size(), clues, "the clue is there once")


func test_another_ball_isnt_pulled() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var rig := alley.rig
	var ball: BowlingBall = alley.balls[(alley.balls.find(rig.magnetic) + 1) % alley.balls.size()]
	var at := alley.to_global(rig.BIN_AT + Vector3(-1.0, BowlingBall.RADIUS + 0.01, 0))
	ball.global_position = at
	ball.sleeping = false
	await wait_seconds(1.0)
	assert_lt(ball.global_position.distance_to(at), 0.1)
	assert_false(rig.stuck)


func test_lane_1s_pins_fall_before_the_league_ball_gets_there() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var player: BowlPlayer
	for one: BowlPlayer in alley.players:
		if one.lane == 0:
			player = one
	var ball: BowlingBall = alley.balls[0]
	player.ball = ball
	ball.bowled = true
	ball.global_position = alley.to_global(Vector3(Bowling.LANE_X[0], 0.4, Bowling.HEAD_PIN_Z + 2.0))
	ball.freeze = true
	await wait_seconds(1.5)
	assert_gt(alley.knocked(0), 5, "down by themselves")


func test_don_chuza_slips_and_pipo_saw_where() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.owner_boss.slips.size(), 3)
	assert_true(alley.owner_boss.ask(alley.get_node("Cop")))
	assert_eq(alley.raid.clues_found.size(), 1)
	var where := tr("LOC_" + Bowling.SPOTS[alley.hidden_spots[5 % 3]].id)
	assert_eq(alley.pipo.clue, tr("CLUE_PIPO") % where)
	var cop: Cop = alley.get_node("Cop")
	alley.pipo.use(cop)
	alley.pipo.use(cop)
	assert_has(alley.raid.clues_found, alley.pipo.clue, "on the checklist")


func test_the_golden_ball_in_the_trunk_solves_the_case() -> void:
	var alley := _alley()
	await wait_physics_frames(10)
	var ball := alley.main
	ball.global_position = alley.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(alley.car.is_delivered(ball))
	assert_true(alley.raid.mark(alley.raid.suspicions.find("bowl_magnet")))
	assert_eq(alley.raid.objective_facts().extras.size(), 2)
	alley.car.enter(alley.get_node("Cop"))
	assert_true(alley.raid.case_solved)


func test_the_fines_go_to_the_case_and_the_lawyer_fails_it() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	alley.break_screen(1)
	assert_eq(alley.raid.fines, Bowling.SCREEN_FINE)
	assert_eq(alley.raid.objective_facts().broken, 1)
	alley.owner_boss.blame(FloorBoss.MAX_COMPLAINT, "CHUZA_PLAYER")
	assert_true(alley.raid.case_failed)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_BOWL_TIP_B", "BRIEF_BOWL_TIP_D", "BRIEF_BOWL_TIP_E", "BRIEF_BOWL_MAGNET_B",
		"BRIEF_BOWL_MAGNET_C", "BRIEF_BOWL_MAGNET_D", "OBJ_FIND_MAGNET_BALL", "OBJ_EXTRA_PIN_REMOTE", "OBJ_EXTRA_BET_LIST",
		"OBJ_ENTER_BOWL", "OBJ_GUESS_BOWL", "OBJ_BROKEN_BOWL", "OBJ_COMPLAINT_BOWL", "CHUZA_SLIP", "CLUE_PIPO",
		"PIPO_CLUE_bowl_magnet", "BOWL_MAGNET_CLONC", "BOWL_MAGNET_CLUE", "CRIME_owner_bowling", "CONFESS_owner_bowling",
		"CASE_FAILED_LAWYER_BOWLING", "HINT_TILL_KEY_BOWLING"]
	for id: String in Bowling.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key, key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_bowling"))
