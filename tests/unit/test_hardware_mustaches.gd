extends GutTest

## The hardware store's deputy's mustaches (docs/diseno/ferreteria.md, step 6): the sprayed posters, the paint puddle,
## the trail of prints as the story's clue, the black soles of a cop who steps in it and the stencil in the trunk.

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store() -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.story_id = "mustaches"
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_stencil_is_hidden_with_three_sprays_and_the_poster() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.main.scene_file_path, "res://scenes/props/mustache_stencil.tscn")
	assert_eq(store.extras.size(), 4)
	assert_eq(store.extras.filter(func(item: Evidence) -> bool:
		return item.scene_file_path == "res://scenes/props/spray_can_black.tscn").size(), 3)
	var rig := store.rig as MustachesRig
	assert_eq(rig.prints, MustachesRig.TRAIL.size(), "the trail out of the workshop")


func test_the_footprints_are_the_storys_clue() -> void:
	var store := _store()
	await wait_physics_frames(2)
	(store.rig as MustachesRig).footprints.use(store.get_node("Cop"))
	assert_eq(store.raid.clues_found, [tr("CLUE_PAINT_FOOTPRINTS")] as Array[String])


func test_stepping_in_the_paint_leaves_black_prints_for_a_while() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	var rig := store.rig as MustachesRig
	assert_true(MustachesRig.in_puddle(MustachesRig.PUDDLE_AT))
	assert_false(MustachesRig.in_puddle(MustachesRig.PUDDLE_AT + Vector3(1, 0, 0)))
	cop.global_position = MustachesRig.PUDDLE_AT + Vector3(0, 0.01, 0)
	await wait_physics_frames(2)
	assert_eq(rig.soles.get(cop, 0), MustachesRig.PAINT_STEPS)
	var before := rig.prints
	cop.global_position = MustachesRig.PUDDLE_AT + Vector3(0, 0.01, 2.0)
	for i in MustachesRig.PAINT_STEPS + 3:
		cop.global_position += Vector3(0, 0, MustachesRig.STEP + 0.05)
		await wait_physics_frames(1)
	assert_eq(rig.prints - before, MustachesRig.PAINT_STEPS, "then the soles are clean")
	assert_eq(rig.soles[cop], 0)


func test_the_stencil_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(10)
	var stencil := store.main
	stencil.global_position = store.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(stencil))
	assert_true(store.raid.mark(store.raid.suspicions.find("mustaches")))
	assert_eq(store.raid.objective_facts().extras.size(), 4)
	store.car.enter(cop)
	assert_true(store.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_MUSTACHES_B", "BRIEF_MUSTACHES_C", "BRIEF_MUSTACHES_D", "OBJ_FIND_STENCIL",
			"OBJ_EXTRA_SPRAY", "OBJ_EXTRA_DEPUTY_POSTER", "COSME_CLUE_mustaches", "CLUE_PAINT_FOOTPRINTS",
			"PROMPT_FOOTPRINTS", "HINT_PAINT_SOLES"]:
		assert_ne(tr(key), key)
