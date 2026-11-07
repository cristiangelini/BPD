extends GutTest

## The ice cream shop's frozen cash story (allanamiento-heladeria.md, step 6): the bucket full of bills hidden with the
## sales notebook and the "sold" stamp, the till saying 900 kg sold today, doña Nieve shutting the freezers when someone
## comes in, what Lucho asked for, and the bucket in the trunk solving the case.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop(case_seed := 5) -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.story_id = "frozen_cash"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_bucket_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_has(shop.raid.suspicions, "frozen_cash")
	assert_almost_eq((shop.main as RigidBody3D).mass, 4.0, 0.01)
	assert_true(IceCreamShop.SPOTS[shop.hidden_spots[0]].heavy)
	assert_eq(shop.extras.size(), 2, "the sales notebook and the sold stamp")


func test_the_till_display_is_a_clue() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FrozenCashRig
	rig.display.use(shop.get_node("Cop"))
	assert_has(shop.raid.clues_found, tr("CLUE_TILL_900"))


func test_she_shuts_the_freezers_when_someone_comes_in() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FrozenCashRig
	shop.freezers[0].set_open(true)
	shop.freezers[2].set_open(true)
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = shop.to_global(Vector3(IceCreamShop.ENTRANCE_X, 0.1, IceCreamShop.FRONT_WALL_Z + 1.5))
	await wait_physics_frames(5)
	cop.global_position = shop.to_global(FrozenCashRig.DOOR_AT - Vector3(0, 0.9, 0))
	await wait_physics_frames(5)
	assert_eq(rig.covers, 1, "she saw someone come in")
	assert_false(shop.freezers[0].is_open)
	assert_false(shop.freezers[2].is_open)
	rig.cover()
	assert_eq(rig.covers, 1, "not again right away")


func test_lucho_asked_for_the_bucket() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var where := tr("LOC_" + IceCreamShop.SPOTS[shop.hidden_spots[5 % 3]].id)
	assert_eq(shop.lucho.clue_speech, tr("LUCHO_CLUE_frozen_cash") % where)


func test_the_bucket_in_the_trunk_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	var bucket := shop.main
	bucket.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.car.is_delivered(bucket))
	assert_true(shop.raid.mark(shop.raid.suspicions.find("frozen_cash")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_FROZEN_CASH_B", "BRIEF_FROZEN_CASH_C", "BRIEF_FROZEN_CASH_D", "OBJ_FIND_CASH_BUCKET",
			"OBJ_EXTRA_SALES_NOTEBOOK", "OBJ_EXTRA_SOLD_STAMP", "LUCHO_CLUE_frozen_cash", "ICE_TILL_900", "CLUE_TILL_900",
			"NIEVE_COVER_FREEZERS"]:
		assert_ne(tr(key), key)
