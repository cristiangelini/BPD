extends GutTest

## The furniture store's cardboard wood story (allanamiento-muebleria.md, step 5): the stamp and its extras hidden with
## the seed, the "oak" wardrobe one cop pulls over alone (the clue, once), and the dining chairs light enough to fly.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store(case_seed := 5) -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.story_id = "cardboard_wood"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_stamp_is_hidden_with_its_extras() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "cardboard_wood")
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 1.0, 0.01)
	assert_eq(store.extras.size(), 2, "the sticker roll and the invoices")
	assert_eq(store.raid.find_key, "OBJ_FIND_WOOD_STAMP")


func test_one_cop_pulls_the_cardboard_wardrobe_over_and_the_first_time_is_a_clue() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as CardboardWoodRig
	var cop: Cop = store.get_node("Cop")
	var oak := store.wardrobes[1 - rig.light_wardrobe]
	oak.use(cop)
	assert_false(oak.is_tipped, "the other one is still too heavy for one")
	var cardboard := store.wardrobes[rig.light_wardrobe]
	cardboard.use(cop)
	assert_true(cardboard.is_tipped, "one cop alone")
	assert_eq(rig.lifts, 1)
	assert_has(store.raid.clues_found, tr("CLUE_LIGHT_WARDROBE"))
	var clues: int = store.raid.clues_found.size()
	rig.lift(cop)
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_the_dining_chairs_are_light_and_fly_off() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as CardboardWoodRig
	assert_eq(rig.light_chairs.size(), FurnitureStore.CHAIR_XS.size() * FurnitureStore.CHAIR_ZS.size())
	var chair := rig.light_chairs[0]
	assert_almost_eq(chair.mass, CardboardWoodRig.CHAIR_KG, 0.01)
	assert_lt(chair.mass, GameScale.COP_CARRY_KG, "one cop carries it")
	await wait_physics_frames(10)
	var from := chair.global_position
	var cop: Cop = store.get_node("Cop")
	cop.global_position = from + Vector3(0.9, 0.1, 0)
	await wait_physics_frames(5)
	cop.global_position = from + Vector3(0.35, 0.1, 0)
	await wait_physics_frames(20)
	assert_gt(Vector2(chair.global_position.x - from.x, chair.global_position.z - from.z).length(), 0.5, "sent flying")
	assert_lt(chair.global_position.x, from.x, "away from the cop")


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_CARDBOARD_WOOD_B", "BRIEF_CARDBOARD_WOOD_C", "BRIEF_CARDBOARD_WOOD_D",
			"OBJ_FIND_WOOD_STAMP", "OBJ_EXTRA_DECAL_ROLL", "OBJ_EXTRA_CARDBOARD_INVOICES", "TABLITA_CLUE_cardboard_wood",
			"FURNITURE_LIGHT", "HINT_WARDROBE_LIGHT", "CLUE_LIGHT_WARDROBE"]:
		assert_ne(tr(key), key)
