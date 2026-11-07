extends GutTest

## The furniture store's comisario's armchair story (allanamiento-muebleria.md, step 5): the armchair in the shop window
## is the main evidence, its sticker is the clue for a cop close enough, sitting on it brings the comisario on the
## radio, and it solves the case in the trunk.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store(case_seed := 5) -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.story_id = "comisario_chair"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_armchair_in_the_window_is_the_evidence_and_the_rest_is_hidden() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as ComisarioChairRig
	assert_has(store.raid.suspicions, "comisario_chair")
	assert_eq(store.main, rig.armchair)
	assert_eq(store.raid.main_evidence, rig.armchair)
	assert_almost_eq(rig.armchair.mass, 18.0, 0.01)
	assert_lt(rig.armchair.mass, GameScale.COP_CARRY_KG, "one cop carries it")
	assert_eq(store.hidden.size(), 2)
	assert_eq(store.extras.size(), 2, "the photo and the screwdriver")
	assert_gt(rig.armchair.position.z, FurnitureStore.HALF_Z - 2.0, "in the shop window")


func test_a_cop_close_by_reads_the_sticker_once() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as ComisarioChairRig
	assert_false(rig.sticker_read, "the cop starts out by the patrol car")
	var cop: Cop = store.get_node("Cop")
	cop.global_position = rig.armchair.global_position + Vector3(0, 0, -1.5)
	await wait_physics_frames(3)
	assert_true(rig.sticker_read)
	assert_has(store.raid.clues_found, tr("CLUE_STATION_STICKER"))
	var clues: int = store.raid.clues_found.size()
	rig.read_sticker(cop)
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_sitting_on_it_brings_the_comisario_on_the_radio() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as ComisarioChairRig
	var cop: Cop = store.get_node("Cop")
	assert_eq(rig.armchair.prompt_key(cop), "PROMPT_SIT_ARMCHAIR")
	rig.armchair.use(cop)
	assert_eq(rig.calls, 1)
	assert_eq(cop._hint.text, "HINT_COMISARIO_CHAIR_RADIO", "on the radio")
	rig.armchair.use(cop)
	assert_eq(rig.calls, 1, "not again right away")


func test_the_armchair_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	await wait_physics_frames(10)
	var armchair := store.main
	armchair.global_position = store.car.to_global(Vector3(0, 1.0, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(armchair))
	assert_true(store.raid.mark(store.raid.suspicions.find("comisario_chair")))
	store.car.enter(store.get_node("Cop"))
	assert_true(store.raid.case_solved)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_COMISARIO_CHAIR_B", "BRIEF_COMISARIO_CHAIR_C", "BRIEF_COMISARIO_CHAIR_D",
			"OBJ_FIND_COMISARIO_CHAIR", "OBJ_EXTRA_COMISARIO_PHOTO", "OBJ_EXTRA_STATION_SCREWDRIVER",
			"TABLITA_CLUE_comisario_chair", "PROMPT_SIT_ARMCHAIR", "HINT_STATION_STICKER", "CLUE_STATION_STICKER",
			"HINT_COMISARIO_CHAIR_RADIO"]:
		assert_ne(tr(key), key)
