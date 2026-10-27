extends GutTest

## The radio's collector's records story (allanamiento-radio.md, step 6): the crate of vinyls hidden in a heavy spot with
## the catalog and the golden record player, the private record in the archive as a clue once, and the "gems" on air.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio(case_seed := 5) -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.story_id = "collector_records"
	radio.case_seed = case_seed
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func test_the_vinyls_are_hidden_with_their_extras() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_has(radio.raid.suspicions, "collector_records")
	assert_eq(radio.main, radio.hidden[0])
	assert_almost_eq((radio.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(RadioStation.SPOTS[radio.hidden_spots[0]].heavy)
	assert_eq(radio.extras.size(), 2)


func test_the_private_record_is_a_clue_once() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as CollectorRecordsRig
	var cop: Cop = radio.get_node("Cop")
	assert_eq(rig.record.prompt_key(cop), "PROMPT_PRIVATE_RECORD")
	rig.record.use(cop)
	rig.record.use(cop)
	assert_eq(radio.raid.clues_found.count(tr("CLUE_PRIVATE_RECORD")), 1)


func test_gems_go_on_air_in_turn() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as CollectorRecordsRig
	rig.present()
	rig.present()
	assert_eq(rig.presented, 2)
	radio.set_on_air(false)
	rig.present()
	assert_eq(rig.presented, 2)


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_COLLECTOR_RECORDS_B", "BRIEF_COLLECTOR_RECORDS_C", "BRIEF_COLLECTOR_RECORDS_D",
			"OBJ_FIND_VINYL_CRATE", "OBJ_EXTRA_COLLECTOR_CATALOG", "OBJ_EXTRA_GOLDEN_PLAYER", "PROMPT_PRIVATE_RECORD",
			"CLUE_PRIVATE_RECORD", "RADIO_GEM_1", "RADIO_GEM_2", "RADIO_GEM_3", "ROSA_CLUE_collector_records"]:
		assert_ne(tr(key), key)
