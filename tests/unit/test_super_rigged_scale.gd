extends GutTest

## The supermarket's scale that adds up (allanamiento-super.md, step 6): the magic screw hidden with the manual and the
## golden screwdriver, and the produce stand's scale showing 300 g too much, empty too; the first thing weighed is the
## clue.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super(case_seed := 5) -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.story_id = "super_scale"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_screw_is_hidden_with_its_extras() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "super_scale")
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 0.2, 0.01)
	assert_eq(store.extras.size(), 2)


func test_empty_it_shows_300_g_and_nothing_is_a_clue() -> void:
	var store := _super()
	await wait_physics_frames(30)
	var rig := store.rig
	assert_almost_eq(rig.shown_kg, 0.3, 0.001)
	assert_eq(rig.readout.text, tr("SUPER_SCALE_READOUT") % 0.3)
	assert_false(rig.weighed)
	assert_eq(rig.tomatoes.size(), 3)


func test_a_tomato_on_it_weighs_300_g_more_and_is_the_clue_once() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var tomato: Grabbable = rig.tomatoes[0]
	tomato.global_position = store.to_global(rig.PAN_AT + Vector3(0, 0.2, 0))
	await wait_physics_frames(40)
	assert_almost_eq(rig.shown_kg, 0.5, 0.001)
	assert_true(rig.weighed)
	assert_has(store.raid.clues_found, tr("SUPER_SCALE_CLUE"))
	var clues: int = store.raid.clues_found.size()
	(rig.tomatoes[1] as Grabbable).global_position = store.to_global(rig.PAN_AT + Vector3(0.05, 0.35, 0))
	await wait_physics_frames(40)
	assert_almost_eq(rig.shown_kg, 0.7, 0.001, "two tomatoes and the extra")
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_SUPER_SCALE_B", "BRIEF_SUPER_SCALE_C", "BRIEF_SUPER_SCALE_D", "OBJ_FIND_MAGIC_SCREW",
			"OBJ_EXTRA_WEIGH_MANUAL", "OBJ_EXTRA_GOLDEN_SCREWDRIVER", "LALO_CLUE_super_scale", "SUPER_SCALE_CLUE",
			"SUPER_SCALE_READOUT"]:
		assert_ne(tr(key), key)
