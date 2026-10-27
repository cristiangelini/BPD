extends GutTest

## The radio's coded dedications story (allanamiento-radio.md, step 6): the code box hidden in a heavy spot with the
## "listeners" list and the delivery clock, the Seagull's line on the dedications board as a clue once, and the odd
## dedications on air.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio(case_seed := 5) -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.story_id = "coded_dedications"
	radio.case_seed = case_seed
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func test_the_code_box_is_hidden_with_its_extras() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_has(radio.raid.suspicions, "coded_dedications")
	assert_eq(radio.main, radio.hidden[0])
	assert_almost_eq((radio.main as RigidBody3D).mass, 3.0, 0.01)
	assert_true(RadioStation.SPOTS[radio.hidden_spots[0]].heavy)
	assert_eq(radio.extras.size(), 2)


func test_the_gull_dedication_is_a_clue_once() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as CodedDedicationsRig
	var cop: Cop = radio.get_node("Cop")
	assert_eq(rig.dedications_board.prompt_key(cop), "PROMPT_DEDICATIONS_BOARD")
	rig.dedications_board.use(cop)
	rig.dedications_board.use(cop)
	assert_eq(radio.raid.clues_found.count(tr("CLUE_GULL_DEDICATION")), 1)


func test_dedications_go_on_air_in_turn() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as CodedDedicationsRig
	rig.dedicate()
	rig.dedicate()
	assert_eq(rig.dedicated, 2)
	radio.set_on_air(false)
	rig.dedicate()
	assert_eq(rig.dedicated, 2)


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_CODED_DEDICATIONS_B", "BRIEF_CODED_DEDICATIONS_C", "BRIEF_CODED_DEDICATIONS_D",
			"OBJ_FIND_CODE_BOX", "OBJ_EXTRA_LISTENER_LIST", "OBJ_EXTRA_DELIVERY_CLOCK", "RADIO_DEDICATIONS_BOARD",
			"PROMPT_DEDICATIONS_BOARD", "CLUE_GULL_DEDICATION", "RADIO_DEDICATION_1", "RADIO_DEDICATION_2",
			"RADIO_DEDICATION_3", "ROSA_CLUE_coded_dedications"]:
		assert_ne(tr(key), key)
