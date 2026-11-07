extends GutTest

## The fake fines story at the print shop (allanamiento-imprenta.md, step 7e): the fake stamp in the trunk solves it,
## the fine on the patrol car's windshield is a clue near a cop, and the press throws fines with the cops' names.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop(case_seed := 5) -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.story_id = "fake_fines"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_fake_stamp_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	assert_has(shop.raid.suspicions, "fake_fines")
	assert_eq(shop.main.scene_file_path, "res://scenes/props/fake_station_stamp.tscn")
	assert_eq(shop.extras.size(), 2, "the pad and the cap")
	shop.main.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.raid.mark(shop.raid.suspicions.find("fake_fines")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_windshield_fine_is_a_clue_near_a_cop() -> void:
	var shop := _shop()
	await wait_seconds(FakeFinesRig.CHECK_EVERY * 2.5)
	var rig := shop.rig as FakeFinesRig
	assert_eq(rig.windshield_fine.get_parent(), shop.car, "on the patrol car")
	assert_false(rig.noticed, "not from where the cop gets off")
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = shop.car.to_global(Vector3(0.6, 0.1, 2.6))
	await wait_seconds(FakeFinesRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(shop.raid.clues_found.count(tr("CLUE_WINDSHIELD_FINE")), 1, "one clue")


func test_the_press_throws_fines_with_the_cops_names() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FakeFinesRig
	assert_eq(shop.press.sheet_color, FakeFinesRig.FINE_YELLOW)
	shop.press.start()
	await wait_seconds(1.2)
	assert_gt(shop.press.sheets.size(), 0)
	var fine: MeshInstance3D = shop.press.sheets[0].node
	var label: Label3D = fine.get_node("FineName")
	assert_eq(label.text, tr("PRINT_SHOP_FINE_FOR") % Net.player_name(1), "the only cop's name")
	assert_eq(rig.printed_names.size(), shop.press.sheets.size())


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_FAKE_FINES_B", "BRIEF_FAKE_FINES_C", "BRIEF_FAKE_FINES_D",
			"OBJ_FIND_FAKE_STATION_STAMP", "OBJ_EXTRA_FINES_PAD", "OBJ_EXTRA_TOY_POLICE_CAP", "TIPITO_CLUE_fake_fines",
			"CLUE_WINDSHIELD_FINE", "PRINT_SHOP_FINE_FAKE", "PRINT_SHOP_WINDSHIELD_FINE", "PRINT_SHOP_FINE_FOR"]:
		assert_ne(tr(key), key, key)
