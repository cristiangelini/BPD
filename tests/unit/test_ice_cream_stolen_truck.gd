extends GutTest

## The ice cream shop's stolen truck story (allanamiento-heladeria.md, step 6): the truck's original plate hidden with
## the can of fresh paint and its papers, the wet paint sign on the truck, the other shop's jingle playing by itself,
## what Lucho hid, and the plate in the trunk solving the case.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop(case_seed := 5) -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.story_id = "stolen_truck"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_plate_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_has(shop.raid.suspicions, "stolen_truck")
	assert_almost_eq((shop.main as RigidBody3D).mass, 2.0, 0.01)
	assert_true(IceCreamShop.SPOTS[shop.hidden_spots[0]].heavy)
	assert_eq(shop.extras.size(), 2, "the paint can and the papers")


func test_the_wet_paint_is_a_clue() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as StolenTruckRig
	assert_lt(rig.paint_sign.position.z, IceCreamShop.BACK_WALL_Z, "out in the yard")
	rig.paint_sign.use(shop.get_node("Cop"))
	assert_has(shop.raid.clues_found, tr("CLUE_FRESH_PAINT"))


func test_the_truck_plays_the_other_shops_jingle() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as StolenTruckRig
	assert_eq(rig.jingle_text(), "")
	rig.play_jingle()
	assert_eq(rig.jingles, 1)
	assert_eq(rig.jingle_text(), tr("ICE_TRUCK_JINGLE"))
	rig._process(StolenTruckRig.JINGLE_SECONDS + 0.1)
	assert_eq(rig.jingle_text(), "", "it stops")


func test_lucho_hid_the_plate() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var where := tr("LOC_" + IceCreamShop.SPOTS[shop.hidden_spots[5 % 3]].id)
	assert_eq(shop.lucho.clue_speech, tr("LUCHO_CLUE_stolen_truck") % where)


func test_the_plate_in_the_trunk_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	var plate := shop.main
	plate.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.car.is_delivered(plate))
	assert_true(shop.raid.mark(shop.raid.suspicions.find("stolen_truck")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_STOLEN_TRUCK_B", "BRIEF_STOLEN_TRUCK_C", "BRIEF_STOLEN_TRUCK_D", "OBJ_FIND_TRUCK_PLATE",
			"OBJ_EXTRA_FRESH_PAINT", "OBJ_EXTRA_TRUCK_PAPERS", "LUCHO_CLUE_stolen_truck", "ICE_WET_PAINT",
			"CLUE_FRESH_PAINT", "ICE_TRUCK_JINGLE"]:
		assert_ne(tr(key), key)
