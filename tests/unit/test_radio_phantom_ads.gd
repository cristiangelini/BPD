extends GutTest

## The radio's phantom ads story (allanamiento-radio.md, step 6): the box of contracts hidden in a heavy spot with the
## billing notebook and the stamp, the empty ads grid as a clue once, and the silence on air where the ad should go.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio(case_seed := 5) -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.story_id = "phantom_ads"
	radio.case_seed = case_seed
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func test_the_contracts_are_hidden_with_their_extras() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_has(radio.raid.suspicions, "phantom_ads")
	assert_eq(radio.main, radio.hidden[0])
	assert_almost_eq((radio.main as RigidBody3D).mass, 6.0, 0.01)
	assert_true(RadioStation.SPOTS[radio.hidden_spots[0]].heavy)
	assert_eq(radio.extras.size(), 2)


func test_the_empty_grid_is_a_clue_once() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as PhantomAdsRig
	var cop: Cop = radio.get_node("Cop")
	assert_eq(rig.grid.prompt_key(cop), "PROMPT_AD_GRID")
	rig.grid.use(cop)
	rig.grid.use(cop)
	assert_eq(radio.raid.clues_found.count(tr("CLUE_EMPTY_AD_GRID")), 1)


func test_silence_where_the_ad_goes_only_on_air() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as PhantomAdsRig
	rig.silence()
	assert_eq(rig.silences, 1)
	radio.set_on_air(false)
	rig.silence()
	assert_eq(rig.silences, 1)


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_PHANTOM_ADS_B", "BRIEF_PHANTOM_ADS_C", "BRIEF_PHANTOM_ADS_D", "OBJ_FIND_AD_CONTRACTS",
			"OBJ_EXTRA_BILLING_BOOK", "OBJ_EXTRA_PAID_STAMP", "RADIO_AD_GRID", "PROMPT_AD_GRID", "CLUE_EMPTY_AD_GRID",
			"RADIO_AD_SILENCE", "ROSA_CLUE_phantom_ads"]:
		assert_ne(tr(key), key)
