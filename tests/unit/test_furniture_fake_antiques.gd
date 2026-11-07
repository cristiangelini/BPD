extends GutTest

## The furniture store's fake antiques story (allanamiento-muebleria.md, step 5): the aging machine and its extras
## hidden with the seed, and the dining chairs that turn over (E) to show an absurd price and, underneath, "Made last
## week" (the clue, once).

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store(case_seed := 5) -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.story_id = "fake_antiques"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_aging_machine_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "fake_antiques")
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(FurnitureStore.SPOTS[store.hidden_spots[0]].heavy)
	assert_eq(store.extras.size(), 2, "the labels and the sawdust")


func test_a_chair_turns_over_shows_its_stamp_and_the_first_time_is_a_clue() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as FakeAntiquesRig
	assert_eq(rig.antiques.size(), FurnitureStore.CHAIR_XS.size() * FurnitureStore.CHAIR_ZS.size())
	var cop: Cop = store.get_node("Cop")
	var chair := rig.antiques[0]
	assert_eq(chair.prompt_key(cop), "PROMPT_FLIP_CHAIR")
	assert_gt(chair.price, 40000, "an absurd price")
	chair.use(cop)
	assert_true(chair.is_flipped())
	assert_lt(chair.global_basis.y.y, -0.9, "upside down")
	assert_has(store.raid.clues_found, tr("CLUE_LAST_WEEK_STAMP"))
	var clues: int = store.raid.clues_found.size()
	rig.antiques[1].use(cop)
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")
	await wait_seconds(AntiqueChair.FLIP_TIME + 0.3)
	assert_false(chair.is_flipped())
	assert_gt(chair.global_basis.y.y, 0.9, "back on its legs")


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_FAKE_ANTIQUES_B", "BRIEF_FAKE_ANTIQUES_C", "BRIEF_FAKE_ANTIQUES_D",
			"OBJ_FIND_AGING_MACHINE", "OBJ_EXTRA_ANTIQUE_LABELS", "OBJ_EXTRA_SAWDUST", "TABLITA_CLUE_fake_antiques",
			"PROMPT_FLIP_CHAIR", "FURNITURE_MADE_LAST_WEEK", "FURNITURE_ANTIQUE_PRICE", "HINT_CHAIR_STAMP",
			"CLUE_LAST_WEEK_STAMP"]:
		assert_ne(tr(key), key)
