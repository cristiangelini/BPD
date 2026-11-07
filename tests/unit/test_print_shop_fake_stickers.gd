extends GutTest

## The fake stickers story at the print shop (allanamiento-imprenta.md, step 7d): the plate in the trunk solves it,
## the repeated stickers around the hiding spot are a clue near a cop, and while the press runs it sticks stickers on
## the faces of the cops near its tray.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop(case_seed := 5) -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.story_id = "fake_stickers"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_plate_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	assert_has(shop.raid.suspicions, "fake_stickers")
	assert_eq(shop.main.scene_file_path, "res://scenes/props/sticker_plate.tscn")
	assert_eq(shop.extras.size(), 2, "the album and the pack")
	shop.main.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.raid.mark(shop.raid.suspicions.find("fake_stickers")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_repeated_stickers_are_a_clue_near_a_cop() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FakeStickersRig
	assert_eq(rig.floor_stickers.size(), FakeStickersRig.FLOOR_STICKERS)
	var spot := rig.hiding_spot()
	for sticker: MeshInstance3D in rig.floor_stickers:
		var flat := Vector2(sticker.position.x - spot.x, sticker.position.z - spot.z)
		assert_lt(flat.length(), FakeStickersRig.SPREAD + 0.01, "around the hiding spot")
	assert_false(rig.noticed)
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = shop.to_global(Vector3(spot.x + 1.0, PrintShop.FLOOR_TOP, spot.z))
	await wait_seconds(FakeStickersRig.CHECK_EVERY * 3)
	assert_true(rig.noticed)
	assert_eq(shop.raid.clues_found.count(tr("CLUE_REPEATED_STICKERS")), 1, "one clue")


func test_the_press_sticks_stickers_on_faces_near_the_tray() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FakeStickersRig
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = shop.to_global(Vector3(PrintShop.TRAY_X.y + 1.0, PrintShop.FLOOR_TOP, 1.5))
	await wait_physics_frames(2)
	assert_false(rig.on_face.has(cop), "nothing while the press is still")
	shop.press.start()
	await wait_physics_frames(3)
	assert_true(rig.on_face.has(cop))
	assert_not_null(cop.camera.get_node_or_null("FaceSticker"), "in front of the eyes")
	await wait_seconds(FakeStickersRig.FACE_TIME + 0.3)
	assert_false(rig.on_face.has(cop), "it falls off after a while")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_FAKE_STICKERS_B", "BRIEF_FAKE_STICKERS_C", "BRIEF_FAKE_STICKERS_D",
			"OBJ_FIND_STICKER_PLATE", "OBJ_EXTRA_STICKER_ALBUM", "OBJ_EXTRA_STICKER_PACK", "TIPITO_CLUE_fake_stickers",
			"CLUE_REPEATED_STICKERS", "PRINT_SHOP_REPEATED", "HINT_STICKER_FACE"]:
		assert_ne(tr(key), key, key)
