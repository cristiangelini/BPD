extends GutTest

## The fun fair raid with the ghost train storeroom (allanamiento-parque.md, step 6): the box of stolen phones in the
## patrol car's trunk and the skeleton that rings like a phone.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair(case_seed := 5) -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.story_id = "ghost_storage"
	fair.case_seed = case_seed
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func test_the_phone_box_hides_where_it_fits_and_solves_the_case() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	assert_has(fair.raid.suspicions, "ghost_storage")
	assert_eq(fair.main.scene_file_path, "res://scenes/props/fair_phone_box.tscn")
	assert_true(Fair.SPOTS[fair.hidden_spots[0]].heavy, "the box only goes where it fits")
	assert_eq(fair.extras.size(), 2, "the price list and the sheet")
	fair.main.global_position = fair.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(fair.car.is_delivered(fair.main))
	assert_true(fair.raid.mark(fair.raid.suspicions.find("ghost_storage")))
	fair.car.enter(fair.get_node("Cop"))
	assert_true(fair.raid.case_solved)


func test_a_skeleton_rings_and_lights_up_and_heard_close_by_it_is_the_clue() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var rig := fair.rig as GhostStorageRig
	assert_false(rig.screen.visible)
	rig.ring()
	assert_true(rig.screen.visible, "its screen lights up")
	assert_false(rig.heard, "nobody near the tunnel")
	await wait_seconds(GhostStorageRig.SCREEN_ON + 0.2)
	assert_false(rig.screen.visible, "and goes off")
	fair.get_node("Cop").global_position = rig.screen.global_position + Vector3(1.5, -1.0, 0)
	rig._since_ring = GhostStorageRig.RING_EVERY
	await wait_physics_frames(2)
	assert_eq(rig.rings, 2, "it rings every 15 s")
	rig.ring()
	assert_eq(fair.raid.clues_found.count(tr("CLUE_SKELETON_RINGS")), 1)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_GHOST_STORAGE_B", "BRIEF_GHOST_STORAGE_C", "BRIEF_GHOST_STORAGE_D", "OBJ_FIND_PHONE_BOX",
			"OBJ_EXTRA_PRICE_LIST", "OBJ_EXTRA_GHOST_SHEET", "NUBE_CLUE_ghost_storage", "CLUE_SKELETON_RINGS",
			"FAIR_PHONE_RING"]:
		assert_ne(tr(key), key, key)
