extends GutTest

## The print shop raid with the fake bills (allanamiento-imprenta.md, step 6): the same case as every raid, the plate
## in the patrol car's trunk, the badly cut bill in the recycling basket near a cop, the press throwing bills, Don
## Renglón's slips and Tipito's clue.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop(case_seed := 5) -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.story_id = "fake_bills"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_plate_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	assert_has(shop.raid.suspicions, "fake_bills")
	assert_eq(shop.raid.suspicions.size(), 3)
	assert_eq(shop.main.scene_file_path, "res://scenes/props/bills_plate.tscn")
	assert_true(PrintShop.SPOTS[shop.hidden_spots[0]].heavy, "the 8 kg plate goes where heavy things fit")
	assert_eq(shop.extras.size(), 2, "the magnifier and the green ink")
	assert_eq(shop.raid.owner_npc, shop.owner_npc)
	shop.main.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.car.is_delivered(shop.main))
	assert_true(shop.raid.mark(shop.raid.suspicions.find("fake_bills")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_bad_bill_is_a_clue_near_a_cop() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FakeBillsRig
	assert_false(rig.noticed, "nobody near the basket")
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = shop.to_global(PrintShop.BASKET_AT + Vector3(1.2, 0.1, 0.5))
	await wait_seconds(FakeBillsRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(shop.raid.clues_found.count(tr("CLUE_BAD_BILL")), 1, "one clue")


func test_the_press_throws_bills() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_eq(shop.press.sheet_size, FakeBillsRig.BILL_SIZE)
	shop.press.start()
	await wait_seconds(0.6)
	var sheet: MeshInstance3D = shop.press.sheets[0].node
	assert_eq((sheet.mesh as BoxMesh).size, FakeBillsRig.BILL_SIZE, "a bill, not a sheet")


func test_renglon_slips_and_tipito_tells_where_he_hid_something() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_eq(shop.owner_npc.slips.size(), 3)
	var where := tr("LOC_" + PrintShop.SPOTS[shop.hidden_spots[5 % 3]].id)
	assert_string_contains(shop.kid.clue_speech, where)
	shop.kid.take(shop.wanted_letter(), shop.get_node("Cop"))
	assert_has(shop.raid.clues_found, shop.kid.clue)


func test_the_lawyer_loses_the_case_and_fines_count() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	shop.break_jar(0)
	assert_eq(shop.raid.fines, PrintShop.JAR_FINE)
	shop.owner_npc.scold(FloorBoss.MAX_COMPLAINT, "RENGLON_LAWYER")
	assert_true(shop.raid.case_failed)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_PRINT_SHOP_TIP_B", "BRIEF_PRINT_SHOP_TIP_D", "BRIEF_PRINT_SHOP_TIP_E",
			"BRIEF_FAKE_BILLS_B", "BRIEF_FAKE_BILLS_C", "BRIEF_FAKE_BILLS_D", "OBJ_FIND_BILLS_PLATE",
			"OBJ_EXTRA_BILL_LOUPE", "OBJ_EXTRA_GREEN_INK", "OBJ_ENTER_PRINT_SHOP", "OBJ_GUESS_PRINT_SHOP",
			"OBJ_BROKEN_PRINT_SHOP", "OBJ_COMPLAINT_PRINT_SHOP", "RENGLON_SLIP", "CLUE_TIPITO",
			"TIPITO_CLUE_fake_bills",
			"CLUE_BAD_BILL", "PRINT_SHOP_BAD_BILL", "PRINT_SHOP_BILL_FACE", "CASE_FAILED_LAWYER_PRINT_SHOP",
			"CRIME_owner_print_shop", "CONFESS_owner_print_shop"]:
		assert_ne(tr(key), key, key)
	for id: String in PrintShop.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id, id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id, id)
	assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS["owner_print_shop"]))
