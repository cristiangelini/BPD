extends GutTest

## The radio's fake chart story (allanamiento-radio.md, step 6): the box of envelopes hidden in a heavy spot with the
## cardboard gold record and the chart written in advance, next week's chart on the wall as a clue once, and the same
## song again on air.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio(case_seed := 5) -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.story_id = "fake_chart"
	radio.case_seed = case_seed
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func test_the_envelopes_are_hidden_with_their_extras() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_has(radio.raid.suspicions, "fake_chart")
	assert_eq(radio.main, radio.hidden[0])
	assert_almost_eq((radio.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(RadioStation.SPOTS[radio.hidden_spots[0]].heavy)
	assert_eq(radio.extras.size(), 2)


func test_next_weeks_chart_is_a_clue_once() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as FakeChartRig
	var cop: Cop = radio.get_node("Cop")
	assert_eq(rig.next_chart.prompt_key(cop), "PROMPT_NEXT_RANKING")
	rig.next_chart.use(cop)
	rig.next_chart.use(cop)
	assert_eq(radio.raid.clues_found.count(tr("CLUE_NEXT_RANKING")), 1)


func test_the_same_song_plays_only_on_air() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as FakeChartRig
	rig.repeat_song()
	rig.repeat_song()
	assert_eq(rig.repeats, 2)
	radio.set_on_air(false)
	rig.repeat_song()
	assert_eq(rig.repeats, 2)


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_FAKE_CHART_B", "BRIEF_FAKE_CHART_C", "BRIEF_FAKE_CHART_D", "OBJ_FIND_BRIBE_ENVELOPES",
			"OBJ_EXTRA_CARDBOARD_GOLD", "OBJ_EXTRA_NEXT_RANKING", "RADIO_NEXT_RANKING", "PROMPT_NEXT_RANKING",
			"CLUE_NEXT_RANKING", "RADIO_SAME_SONG", "ROSA_CLUE_fake_chart"]:
		assert_ne(tr(key), key)
