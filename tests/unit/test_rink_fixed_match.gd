extends GutTest

## The rink raid with the fixed match (allanamiento-pista.md, step 6): the scoreboard remote in the patrol car's trunk
## solves the case; the scoreboard adds a goal on its own every 20 s, and the first one a cop sees is a clue.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink(case_seed := 5) -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.story_id = "fixed_match"
	rink.case_seed = case_seed
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


func test_the_scoreboard_remote_solves_the_case() -> void:
	var rink := _rink()
	await wait_physics_frames(10)
	assert_has(rink.raid.suspicions, "fixed_match")
	assert_eq(rink.main.scene_file_path, "res://scenes/props/rink_score_remote.tscn")
	assert_eq(rink.extras.size(), 2, "the betting notebook and the envelope")
	rink.main.global_position = rink.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(rink.car.is_delivered(rink.main))
	assert_true(rink.raid.mark(rink.raid.suspicions.find("fixed_match")))
	rink.car.enter(rink.get_node("Cop"))
	assert_true(rink.raid.case_solved)


func test_the_scoreboard_scores_on_its_own() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as FixedMatchRig
	assert_eq(rig.home_label.text + rig.away_label.text, "00")
	rig._since = FixedMatchRig.GOAL_EVERY - 0.2
	await wait_seconds(0.5)
	assert_eq(rig.goals, 1, "a goal every 20 s")
	assert_eq(rig.home + rig.away, 1)
	assert_eq(rig.home_label.text, str(rig.home))
	assert_eq(rig.away_label.text, str(rig.away))
	assert_false(rink.raid.clues_found.has(tr("CLUE_SCORE_CHANGES")), "the cop by the car didn't see it")


func test_the_first_goal_a_cop_sees_is_a_clue() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as FixedMatchRig
	rink.get_node("Cop").global_position = rink.to_global(Vector3(0, Rink.FLOOR_TOP + 0.1, 9.0))
	await wait_physics_frames(2)
	rig.goal()
	rig.goal()
	assert_eq(rink.raid.clues_found.count(tr("CLUE_SCORE_CHANGES")), 1, "one clue")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_FIXED_MATCH_B", "BRIEF_FIXED_MATCH_C", "BRIEF_FIXED_MATCH_D", "OBJ_FIND_SCORE_REMOTE",
			"OBJ_EXTRA_BET_NOTEBOOK", "OBJ_EXTRA_MONEY_ENVELOPE", "COPITO_CLUE_fixed_match", "CLUE_SCORE_CHANGES",
			"RINK_GOAL"]:
		assert_ne(tr(key), key, key)
