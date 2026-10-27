extends GutTest

## The ice cream shop's smuggling in the ice story (allanamiento-heladeria.md, step 6): the 8 kg block with the watches
## hidden with the delivery list and the fake stamp, the cold room's thermometer at -40, the customer who asks whether
## "the cold" arrived, what Lucho carried, and the block in the trunk solving the case.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop(case_seed := 5) -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.story_id = "frozen_smuggling"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_block_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_has(shop.raid.suspicions, "frozen_smuggling")
	assert_almost_eq((shop.main as RigidBody3D).mass, 8.0, 0.01, "lift it together")
	assert_true(IceCreamShop.SPOTS[shop.hidden_spots[0]].heavy)
	assert_eq(shop.extras.size(), 2, "the delivery list and the fake stamp")


func test_the_thermometer_is_a_clue() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FrozenSmugglingRig
	assert_lt(rig.thermometer.position.x, IceCreamShop.COLD_X1, "inside the cold room")
	rig.thermometer.use(shop.get_node("Cop"))
	assert_has(shop.raid.clues_found, tr("CLUE_COLD_THERMOMETER"))


func test_the_customer_asks_for_the_cold_and_leaves() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FrozenSmugglingRig
	assert_eq(rig.customer.said(), "", "not in yet")
	rig.ask()
	assert_eq(rig.customer.visits, 1)
	assert_eq(rig.customer.said(), tr("ICE_COLD_ARRIVED"))
	rig.customer._process(IceVisitor.STAY + 0.1)
	assert_false(rig.customer.visible, "gone again")


func test_lucho_carried_the_block() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var where := tr("LOC_" + IceCreamShop.SPOTS[shop.hidden_spots[5 % 3]].id)
	assert_eq(shop.lucho.clue_speech, tr("LUCHO_CLUE_frozen_smuggling") % where)


func test_the_block_in_the_trunk_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	var block := shop.main
	block.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.car.is_delivered(block))
	assert_true(shop.raid.mark(shop.raid.suspicions.find("frozen_smuggling")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_FROZEN_SMUGGLING_B", "BRIEF_FROZEN_SMUGGLING_C", "BRIEF_FROZEN_SMUGGLING_D",
			"OBJ_FIND_ICE_BLOCK", "OBJ_EXTRA_DELIVERY_LIST", "OBJ_EXTRA_FAKE_STAMP_ICE", "LUCHO_CLUE_frozen_smuggling",
			"ICE_THERMOMETER", "CLUE_COLD_THERMOMETER", "ICE_COLD_ARRIVED"]:
		assert_ne(tr(key), key)
