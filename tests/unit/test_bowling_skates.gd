extends GutTest

## The shoes on wheels' story at the bowling alley (allanamiento-bolera.md, step 6): the box and its extras hidden, the
## first pair Pipo hands out rolling on by itself as its cop walks (the clue, once), the next pairs fine, and Don
## Chuza's team on lane 1 gliding to the line.

const SCENE := preload("res://scenes/levels/bowling.tscn")


func _alley(case_seed := 5) -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.story_id = "bowl_skates"
	alley.case_seed = case_seed
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


func test_the_box_and_its_extras_are_hidden() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.main, alley.hidden[0])
	assert_almost_eq(alley.main.full_value, 1000.0, 0.01)
	assert_eq(alley.extras.size(), 2, "the skate and the manual")


func test_the_first_pair_rolls_on_by_itself() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	cop.global_position = alley.to_global(Vector3(2.0, 0.2, 6.0))
	alley.pipo.use(cop)
	assert_true(alley.rig.on_wheels(cop))
	cop.velocity = alley.global_basis * Vector3(1.2, 0, 0)
	alley.rig._physics_process(0.1)
	assert_true(cop.is_staggered(), "rolling on the carpet")
	assert_has(alley.raid.clues_found, tr("BOWL_WHEELS_CLUE"))
	var clues: int = alley.raid.clues_found.size()
	alley.rig._rolled.clear()
	alley.rig._physics_process(0.1)
	assert_eq(alley.raid.clues_found.size(), clues, "the clue once")


func test_the_next_pair_has_no_wheels() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	alley.pipo.use(cop)
	alley.pipo.use(cop)
	alley.pipo.use(cop)
	assert_true(alley.pipo.wears(cop))
	assert_false(alley.rig.on_wheels(cop), "the second pair")
	cop.velocity = alley.global_basis * Vector3(1.2, 0, 0)
	alley.rig._physics_process(0.1)
	assert_false(cop.is_staggered())


func test_don_chuzas_team_glides_to_the_line() -> void:
	var alley := _alley()
	for player: BowlPlayer in alley.players:
		if player.lane == 0:
			assert_lt(player.step_up, BowlPlayer.STEP_UP)
		else:
			assert_eq(player.step_up, BowlPlayer.STEP_UP)
	for key: String in ["BRIEF_BOWL_SKATES_B", "BRIEF_BOWL_SKATES_C", "BRIEF_BOWL_SKATES_D", "OBJ_FIND_SKATE_BOX",
			"OBJ_EXTRA_SKATE_PARTS", "OBJ_EXTRA_SKATE_MANUAL", "PIPO_CLUE_bowl_skates", "HINT_BOWL_WHEELS",
			"BOWL_WHEELS_CLUE"]:
		assert_ne(tr(key), key, key)
