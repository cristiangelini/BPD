extends GutTest

## The furniture store's wardrobe hotel story (allanamiento-muebleria.md, step 5): the guest book and its extras hidden
## with the seed, the shut wardrobe that snores (the clue, once, for a cop close enough) and the guest in pyjamas who
## steps out of it and walks off to the street.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store(case_seed := 5) -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.story_id = "wardrobe_hotel"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_guest_book_is_hidden_with_its_extras() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "wardrobe_hotel")
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 0.5, 0.01)
	assert_eq(store.extras.size(), 2, "the pillow and the toothbrush")
	assert_eq(store.raid.find_key, "OBJ_FIND_GUEST_BOOK")


func test_one_wardrobe_is_shut_and_snores_for_a_cop_close_by() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as WardrobeHotelRig
	var cop: Cop = store.get_node("Cop")
	var wardrobe := store.wardrobes[rig.hotel]
	assert_true(wardrobe.shut)
	assert_false(store.wardrobes[1 - rig.hotel].shut, "the other one is open as always")
	assert_eq(wardrobe.prompt_key(cop), "PROMPT_OPEN_WARDROBE")
	assert_not_null(wardrobe.get_node_or_null("Closed"), "its doors shut")
	rig.snore()
	assert_false(rig.heard, "the cop is out by the patrol car")
	cop.global_position = wardrobe.to_global(Vector3(0, 0.1, 2.0))
	await wait_physics_frames(3)
	rig.snore()
	assert_true(rig.heard)
	assert_has(store.raid.clues_found, tr("CLUE_SNORING_WARDROBE"))
	var clues: int = store.raid.clues_found.size()
	rig.snore()
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_it_snores_by_itself_with_a_cop_near() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as WardrobeHotelRig
	var cop: Cop = store.get_node("Cop")
	cop.global_position = store.wardrobes[rig.hotel].to_global(Vector3(0, 0.1, 2.0))
	await wait_seconds(WardrobeHotelRig.SNORE_EVERY + 0.5)
	assert_true(rig.heard)


func test_opening_it_lets_a_guest_out_who_walks_to_the_street() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as WardrobeHotelRig
	var cop: Cop = store.get_node("Cop")
	var wardrobe := store.wardrobes[rig.hotel]
	watch_signals(rig)
	wardrobe.use(cop)
	assert_false(wardrobe.shut)
	assert_false(wardrobe.is_tipped, "opening it doesn't pull it")
	assert_null(wardrobe.get_node_or_null("Closed"))
	assert_eq(wardrobe.prompt_key(cop), "PROMPT_PULL_WARDROBE")
	assert_not_null(rig.guest, "out in his pyjamas")
	var from := rig.guest.global_position
	await wait_seconds(1.0)
	assert_gt(rig.guest.global_position.distance_to(from), 0.8, "on his way")
	rig.guest.global_position = store.to_global(WardrobeHotelRig.WAY_OUT[2]) + Vector3(0, 0, -0.5)
	rig._path.assign([store.to_global(WardrobeHotelRig.WAY_OUT[2])])
	await wait_seconds(1.0)
	assert_signal_emitted(rig, "guest_left")
	assert_null(rig.guest)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_WARDROBE_HOTEL_B", "BRIEF_WARDROBE_HOTEL_C", "BRIEF_WARDROBE_HOTEL_D",
			"OBJ_FIND_GUEST_BOOK", "OBJ_EXTRA_DROOLY_PILLOW", "OBJ_EXTRA_TOOTHBRUSH", "TABLITA_CLUE_wardrobe_hotel",
			"PROMPT_OPEN_WARDROBE", "FURNITURE_SNORE", "FURNITURE_GUEST", "HINT_WARDROBE_SNORES", "CLUE_SNORING_WARDROBE"]:
		assert_ne(tr(key), key)
