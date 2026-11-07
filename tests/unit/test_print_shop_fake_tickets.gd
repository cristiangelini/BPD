extends GutTest

## The fake tickets story at the print shop (allanamiento-imprenta.md, step 7a): the box in the trunk solves it, a
## ticket sticks to the sole of a cop who steps near where it was hidden (one clue), and the fans outside scream when
## a cop goes through the door.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop(case_seed := 5) -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.story_id = "fake_tickets"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_the_ticket_box_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	assert_has(shop.raid.suspicions, "fake_tickets")
	assert_eq(shop.main.scene_file_path, "res://scenes/props/ticket_box.tscn")
	assert_eq(shop.extras.size(), 2, "the poster and the stamp")
	shop.main.global_position = shop.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.raid.mark(shop.raid.suspicions.find("fake_tickets")))
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_a_ticket_sticks_to_the_sole_near_the_hiding_spot() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FakeTicketsRig
	var cop: Cop = shop.get_node("Cop")
	assert_false(rig.stuck.has(cop), "far from it")
	cop.global_position = shop.to_global(rig.hiding_spot() + Vector3(0.8, 0.1, 0))
	await wait_seconds(FakeTicketsRig.CHECK_EVERY * 3)
	assert_true(rig.stuck.has(cop))
	assert_true(cop.model.has_node("SoleTicket"), "you can see it on the shoe")
	assert_eq(shop.raid.clues_found.count(tr("CLUE_TICKET_SOLE")), 1, "one clue")


func test_the_fans_scream_when_a_cop_goes_through_the_door() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as FakeTicketsRig
	assert_eq(rig.fans.size(), FakeTicketsRig.FANS)
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = Vector3(PrintShop.ENTRANCE_X, PrintShop.FLOOR_TOP + 0.1, PrintShop.HALF_Z)
	await wait_physics_frames(5)
	assert_eq(rig.screams, 1)
	rig.scream()
	assert_eq(rig.screams, 1, "not again so soon")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_FAKE_TICKETS_B", "BRIEF_FAKE_TICKETS_C", "BRIEF_FAKE_TICKETS_D", "OBJ_FIND_TICKET_BOX",
			"OBJ_EXTRA_CONCERT_POSTER", "OBJ_EXTRA_VIP_STAMP", "TIPITO_CLUE_fake_tickets", "CLUE_TICKET_SOLE",
			"HINT_TICKET_SOLE", "PRINT_SHOP_FANS_SCREAM"]:
		assert_ne(tr(key), key, key)
