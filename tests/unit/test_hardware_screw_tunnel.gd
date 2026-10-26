extends GutTest

## The hardware store's tunnel behind the screws (docs/diseno/ferreteria.md, step 6): the screw wall slides only for
## two cops pushing at once, the drill waits under it, the dirt is the story's clue and the drill in the trunk solves it.

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store(story := "screw_tunnel") -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.story_id = story
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func _second_cop(store: HardwareStore) -> Cop:
	var other: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	other.input_enabled = false
	store.add_child(other)
	other.global_position = store.screw_shelf.global_position + Vector3(1.0, 0.1, 1.0)
	return other


func test_the_screw_wall_only_slides_in_this_story() -> void:
	var store := _store("master_keys")
	await wait_physics_frames(2)
	assert_eq(store.screw_shelf.prompt_key(store.get_node("Cop")), "")
	store.screw_shelf.use(store.get_node("Cop"))
	assert_false(store.screw_shelf.is_open)


func test_one_cop_alone_cant_push_it_two_at_once_can() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	var shelf := store.screw_shelf
	assert_eq(shelf.prompt_key(cop), "PROMPT_PUSH_SHELF")
	shelf.use(cop)
	shelf.use(cop)
	assert_false(shelf.is_open, "the same cop twice is still one")
	await wait_seconds(ScrewShelf.PAIR_WINDOW + 0.2)
	var other := _second_cop(store)
	shelf.use(other)
	assert_false(shelf.is_open, "the first push wore off")
	shelf.use(cop)
	assert_true(shelf.is_open)
	await wait_seconds(ScrewShelf.SLIDE_TIME + 0.2)
	assert_almost_eq(shelf.position.z, HardwareStore.SCREW_WALL_AT.z - ScrewShelf.SLIDE, 0.01)


func test_the_drill_waits_under_the_wall_until_it_slides() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as TunnelRig
	assert_eq(store.main, rig.drill)
	assert_true(rig.drill.freeze)
	assert_false(rig.drill.visible)
	assert_eq(store.extras.size(), 2, "the helmet and the plan")
	store.screw_shelf.slide(store.get_node("Cop"))
	assert_true(rig.drill.visible)
	assert_false(rig.drill.freeze)


func test_the_dirt_is_the_storys_clue() -> void:
	var store := _store()
	await wait_physics_frames(2)
	(store.rig as TunnelRig).dirt.use(store.get_node("Cop"))
	assert_eq(store.raid.clues_found, [tr("CLUE_TUNNEL_DIRT")] as Array[String])


func test_the_drill_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(10)
	store.screw_shelf.slide(cop)
	var drill := store.main
	drill.global_position = store.car.to_global(Vector3(0, 0.7, -1.6))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(drill))
	assert_true(store.raid.mark(store.raid.suspicions.find("screw_tunnel")))
	store.car.enter(cop)
	assert_true(store.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_SCREW_TUNNEL_B", "BRIEF_SCREW_TUNNEL_C", "BRIEF_SCREW_TUNNEL_D", "OBJ_FIND_DRILL",
			"OBJ_EXTRA_MINER_HELMET", "OBJ_EXTRA_TUNNEL_PLAN", "COSME_CLUE_screw_tunnel", "CLUE_TUNNEL_DIRT",
			"PROMPT_DIRT", "PROMPT_PUSH_SHELF", "HINT_SHELF_HEAVY", "HINT_SCREW_TUNNEL_FOUND"]:
		assert_ne(tr(key), key)
