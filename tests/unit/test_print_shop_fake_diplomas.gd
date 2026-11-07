extends GutTest

## The fake diplomas story at the print shop (allanamiento-imprenta.md, step 7b): the roll in the trunk solves it, the
## "Doctor en Astronautas" diploma on the office wall is a clue near a cop, and every run of the press prints a
## diploma with a cop's name and throws diplomas.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop(case_seed := 5) -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.story_id = "fake_diplomas"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_diploma_roll_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	assert_has(shop.raid.suspicions, "fake_diplomas")
	assert_eq(shop.main.scene_file_path, "res://scenes/props/diploma_roll.tscn")
	assert_eq(shop.extras.size(), 2, "the seal and the mortarboard")
	shop.main.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.raid.mark(shop.raid.suspicions.find("fake_diplomas")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_office_diploma_is_a_clue_near_a_cop() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FakeDiplomasRig
	assert_false(rig.noticed)
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = shop.to_global(FakeDiplomasRig.FRAME_AT + Vector3(-1.5, -1.6, 0))
	await wait_seconds(FakeDiplomasRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(shop.raid.clues_found.count(tr("CLUE_ASTRONAUT_DIPLOMA")), 1, "one clue")


func test_the_press_prints_diplomas_with_the_cops_names() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FakeDiplomasRig
	assert_eq(shop.press.sheet_color, FakeDiplomasRig.PARCHMENT)
	shop.press.start()
	assert_eq(rig.printed_names.size(), 1)
	assert_eq(rig.printed_names[0], Net.player_name(1), "the only cop's name")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_FAKE_DIPLOMAS_B", "BRIEF_FAKE_DIPLOMAS_C", "BRIEF_FAKE_DIPLOMAS_D",
			"OBJ_FIND_DIPLOMA_ROLL", "OBJ_EXTRA_UNIVERSITY_SEAL", "OBJ_EXTRA_MORTARBOARD", "TIPITO_CLUE_fake_diplomas",
			"CLUE_ASTRONAUT_DIPLOMA", "PRINT_SHOP_ASTRONAUT", "PRINT_SHOP_OFFICE_DIPLOMA", "PRINT_SHOP_DIPLOMA_FOR"]:
		assert_ne(tr(key), key, key)
