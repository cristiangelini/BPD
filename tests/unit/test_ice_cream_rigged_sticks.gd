extends GutTest

## The ice cream shop's prize sticks story (allanamiento-heladeria.md, step 6): the box of prize sticks hidden with the
## engraving machine and the "winners" list, the bin full of losing sticks, the kid with nothing again, what Lucho saw,
## and the box in the trunk solving the case.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop(case_seed := 5) -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.story_id = "rigged_sticks"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_box_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_has(shop.raid.suspicions, "rigged_sticks")
	assert_almost_eq((shop.main as RigidBody3D).mass, 3.0, 0.01)
	assert_true(IceCreamShop.SPOTS[shop.hidden_spots[0]].heavy)
	assert_eq(shop.extras.size(), 2, "the engraver and the winners list")


func test_the_bin_is_a_clue() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as RiggedSticksRig
	assert_eq(rig.bin.prompt_key(shop.get_node("Cop")), "PROMPT_STICK_BIN")
	rig.bin.use(shop.get_node("Cop"))
	assert_has(shop.raid.clues_found, tr("CLUE_LOSING_STICKS"))


func test_a_kid_comes_back_with_nothing() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as RiggedSticksRig
	assert_eq(rig.kid.said(), "", "not in yet")
	rig.shout()
	assert_eq(rig.kid.visits, 1)
	assert_eq(rig.kid.said(), tr("ICE_NOTHING_AGAIN"))
	rig.kid._process(IceVisitor.STAY + 0.1)
	assert_false(rig.kid.visible, "gone again")


func test_lucho_saw_the_prizes() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var where := tr("LOC_" + IceCreamShop.SPOTS[shop.hidden_spots[5 % 3]].id)
	assert_eq(shop.lucho.clue_speech, tr("LUCHO_CLUE_rigged_sticks") % where)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	var rigged := shop.main
	rigged.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.car.is_delivered(rigged))
	assert_true(shop.raid.mark(shop.raid.suspicions.find("rigged_sticks")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_RIGGED_STICKS_B", "BRIEF_RIGGED_STICKS_C", "BRIEF_RIGGED_STICKS_D",
			"OBJ_FIND_PRIZE_STICKS", "OBJ_EXTRA_STICK_ENGRAVER", "OBJ_EXTRA_ICE_WINNERS_LIST", "LUCHO_CLUE_rigged_sticks",
			"PROMPT_STICK_BIN", "CLUE_LOSING_STICKS", "ICE_NOTHING_AGAIN"]:
		assert_ne(tr(key), key)
