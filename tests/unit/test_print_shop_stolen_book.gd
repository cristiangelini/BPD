extends GutTest

## The stolen book story at the print shop (allanamiento-imprenta.md, step 7c): the manuscript in the trunk solves it,
## the posters out front (his name, somebody else's photo) are a clue near a cop, and the piles of the book fall over
## each time the press starts.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop(case_seed := 5) -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.story_id = "stolen_book"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_manuscript_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	assert_has(shop.raid.suspicions, "stolen_book")
	assert_eq(shop.main.scene_file_path, "res://scenes/props/manuscript.tscn")
	assert_eq(shop.extras.size(), 2, "the typewriter and the cover")
	shop.main.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.raid.mark(shop.raid.suspicions.find("stolen_book")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_posters_out_front_are_a_clue_near_a_cop() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as StolenBookRig
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = shop.to_global(Vector3(-2.0, PrintShop.FLOOR_TOP, 0.0))
	await wait_seconds(StolenBookRig.CHECK_EVERY * 2.5)
	assert_false(rig.noticed, "not from inside, by the press")
	cop.global_position = shop.to_global(StolenBookRig.POSTERS[1] + Vector3(0, -1.5, 1.5))
	await wait_seconds(StolenBookRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(shop.raid.clues_found.count(tr("CLUE_BOOK_POSTER")), 1, "one clue")


func test_the_piles_fall_when_the_press_starts() -> void:
	var shop := _shop()
	await wait_seconds(1.0)
	var rig := shop.rig as StolenBookRig
	assert_eq(rig.piles.size(), StolenBookRig.PILES.size())
	var top: RigidBody3D = rig.piles[0].back()
	var standing := top.global_position.y
	assert_almost_eq(standing, PrintShop.FLOOR_TOP + StolenBookRig.BOOK_SIZE.y * (StolenBookRig.BOOKS_PER_PILE - 0.5),
		0.05, "the piles stand still on their own")
	shop.press.start()
	assert_eq(rig.falls, 1)
	await wait_seconds(2.0)
	assert_lt(top.global_position.y, standing - 0.1, "the top book fell")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_STOLEN_BOOK_B", "BRIEF_STOLEN_BOOK_C", "BRIEF_STOLEN_BOOK_D", "OBJ_FIND_MANUSCRIPT",
			"OBJ_EXTRA_WRITER_TYPEWRITER", "OBJ_EXTRA_BOOK_COVER", "TIPITO_CLUE_stolen_book", "CLUE_BOOK_POSTER",
			"PRINT_SHOP_NOT_HIS_FACE", "PRINT_SHOP_BOOK_POSTER"]:
		assert_ne(tr(key), key, key)
