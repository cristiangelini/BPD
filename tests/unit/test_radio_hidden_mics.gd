extends GutTest

## The radio's hidden mics story (allanamiento-radio.md, step 6): the box of recordings hidden in a heavy spot with the
## mic in a flowerpot and the map with crosses, the reception's flowerpot with a mic as a clue once, and a neighbor's
## gossip on air.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio(case_seed := 5) -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.story_id = "hidden_mics"
	radio.case_seed = case_seed
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func test_the_recordings_are_hidden_with_their_extras() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_has(radio.raid.suspicions, "hidden_mics")
	assert_eq(radio.main, radio.hidden[0])
	assert_almost_eq((radio.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(RadioStation.SPOTS[radio.hidden_spots[0]].heavy)
	assert_eq(radio.extras.size(), 2)


func test_the_flowerpot_is_a_clue_once() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as HiddenMicsRig
	var cop: Cop = radio.get_node("Cop")
	assert_eq(rig.plant.prompt_key(cop), "PROMPT_RECEPTION_PLANT")
	rig.plant.use(cop)
	rig.plant.use(cop)
	assert_eq(radio.raid.clues_found.count(tr("CLUE_PLANT_MIC")), 1)


func test_gossip_goes_on_air_in_turn() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as HiddenMicsRig
	rig.gossip()
	rig.gossip()
	assert_eq(rig.gossips, 2)
	radio.set_on_air(false)
	rig.gossip()
	assert_eq(rig.gossips, 2)


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_HIDDEN_MICS_B", "BRIEF_HIDDEN_MICS_C", "BRIEF_HIDDEN_MICS_D", "OBJ_FIND_NEIGHBOR_TAPES",
			"OBJ_EXTRA_POT_MIC", "OBJ_EXTRA_CROSSED_MAP", "PROMPT_RECEPTION_PLANT", "CLUE_PLANT_MIC", "RADIO_GOSSIP_1",
			"RADIO_GOSSIP_2", "RADIO_GOSSIP_3", "ROSA_CLUE_hidden_mics"]:
		assert_ne(tr(key), key)
