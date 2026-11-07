extends GutTest

## The ice cream shop's rigged scale story (allanamiento-heladeria.md, step 6): the 5 kg scale hidden with the magnet
## and the complaints notebook, the "1 KG" sign over a tiny tub, the customer who says it isn't a kilo, what Lucho
## weighed, and the scale in the trunk solving the case.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop(case_seed := 5) -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.story_id = "rigged_scale"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_scale_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_has(shop.raid.suspicions, "rigged_scale")
	assert_almost_eq((shop.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(IceCreamShop.SPOTS[shop.hidden_spots[0]].heavy)
	assert_eq(shop.extras.size(), 2, "the magnet and the complaints notebook")


func test_the_kilo_sign_is_a_clue() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as RiggedScaleRig
	rig.kilo_sign.use(shop.get_node("Cop"))
	assert_has(shop.raid.clues_found, tr("CLUE_TINY_KILO"))


func test_a_customer_comes_back_to_complain() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as RiggedScaleRig
	assert_eq(rig.customer.said(), "", "not in yet")
	rig.complain()
	assert_eq(rig.customer.visits, 1)
	assert_eq(rig.customer.said(), tr("ICE_NOT_A_KILO"))
	rig.customer._process(IceVisitor.STAY + 0.1)
	assert_false(rig.customer.visible, "gone again")


func test_lucho_was_weighed() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var where := tr("LOC_" + IceCreamShop.SPOTS[shop.hidden_spots[5 % 3]].id)
	assert_eq(shop.lucho.clue_speech, tr("LUCHO_CLUE_rigged_scale") % where)


func test_the_scale_in_the_trunk_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	var rigged := shop.main
	rigged.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.car.is_delivered(rigged))
	assert_true(shop.raid.mark(shop.raid.suspicions.find("rigged_scale")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_RIGGED_SCALE_B", "BRIEF_RIGGED_SCALE_C", "BRIEF_RIGGED_SCALE_D", "OBJ_FIND_ICE_SCALE",
			"OBJ_EXTRA_SCALE_MAGNET", "OBJ_EXTRA_COMPLAINTS_NOTEBOOK", "LUCHO_CLUE_rigged_scale", "ICE_ONE_KILO",
			"CLUE_TINY_KILO", "ICE_NOT_A_KILO"]:
		assert_ne(tr(key), key)
