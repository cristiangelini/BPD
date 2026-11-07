extends GutTest

## The fixed tournament's story at the bowling alley (allanamiento-bolera.md, step 6): the engraved cup hidden with its
## extras, the screens' points, lane 1's screen adding 10 to every roll, the cop near the lane who notices (the clue,
## once) and the trophy case's plate.

const SCENE := preload("res://scenes/levels/bowling.tscn")


func _alley(story := "bowl_tournament") -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.story_id = story
	alley.case_seed = 5
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


## Knocks `count` of lane `lane`'s pins off their spots and lets the machine count them.
func _roll(alley: Bowling, lane: int, count: int) -> void:
	for i in count:
		(alley.pins[lane][i] as RigidBody3D).position += Vector3(0, 0, -1.0)
	alley.reset_pins(lane)


func test_the_cup_is_hidden_with_its_extras() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.main, alley.hidden[0])
	assert_almost_eq(alley.main.mass, 4.0, 0.01)
	assert_eq(alley.extras.size(), 2, "the score sheet and the envelope")
	var plate := alley.get_node("Built").get_children().filter(func(node: Node) -> bool:
		return node is Label3D and (node as Label3D).text == "BOWL_CUP_PLATE")
	assert_eq(plate.size(), 1, "the trophy case's plate")


func test_lane_1s_screen_adds_ten_to_every_roll() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	_roll(alley, 0, 3)
	_roll(alley, 1, 3)
	assert_eq(alley.scores[0], 13)
	assert_eq(alley.scores[1], 3, "lane 2 counts the pins")
	_roll(alley, 0, 0)
	assert_eq(alley.scores[0], 23, "even a gutter ball")


func test_other_stories_screens_count_only_the_pins() -> void:
	var alley := _alley("bowl_magnet")
	await wait_physics_frames(2)
	_roll(alley, 2, 4)
	assert_eq(alley.scores[2], 4)
	alley.break_screen(2)
	assert_false(alley._score_labels[2].visible, "a broken screen goes dark")


func test_a_cop_near_lane_1_notices_once() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	cop.global_position = alley.to_global(Vector3(Bowling.LANE_X[0], Bowling.FLOOR_TOP, Bowling.FOUL_Z + 15.0))
	_roll(alley, 0, 2)
	assert_false(alley.rig.noticed, "too far to see it")
	cop.global_position = alley.to_global(Vector3(Bowling.LANE_X[0], Bowling.FLOOR_TOP, Bowling.FOUL_Z + 2.0))
	_roll(alley, 0, 2)
	assert_true(alley.rig.noticed)
	assert_has(alley.raid.clues_found, tr("BOWL_SCORE_CLUE"))
	var clues: int = alley.raid.clues_found.size()
	_roll(alley, 0, 2)
	assert_eq(alley.raid.clues_found.size(), clues, "once")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_BOWL_CUP_B", "BRIEF_BOWL_CUP_C", "BRIEF_BOWL_CUP_D", "OBJ_FIND_RIGGED_CUP",
			"OBJ_EXTRA_FAKE_SCORES", "OBJ_EXTRA_JUDGE_ENVELOPE", "PIPO_CLUE_bowl_tournament", "BOWL_CUP_PLATE",
			"BOWL_SCORE_PLUS", "BOWL_SCORE_ODD", "BOWL_SCORE_CLUE"]:
		assert_ne(tr(key), key, key)
