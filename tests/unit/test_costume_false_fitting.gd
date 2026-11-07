extends GutTest

## The costume shop's fitting room with a false back (allanamiento-disfraces.md, step 6): fitting room 3 is out of
## order and the customers skip it, a cop inside hears the sewing machine behind its mirror (the clue), and E on the
## mirror lifts it and shows the machine, the main evidence.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop(seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = seed
	place.story_id = "false_fitting_room"
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_machine_waits_behind_the_mirror_of_fitting_room_3() -> void:
	var place := _shop()
	await wait_physics_frames(3)
	var rig := place.rig as FalseFittingRoomRig
	assert_eq(place.main, rig.machine)
	assert_almost_eq(rig.machine.mass, 15.0, 0.01)
	assert_lt(rig.machine.position.x, FalseFittingRoomRig.BACK_X, "behind the false back")
	assert_almost_eq(rig.machine.position.z, CostumeShop.FITTING_Z[2], 0.05)
	assert_eq(place.extras.size(), 2, "the labels and the pattern")
	assert_eq(rig.back.prompt_key(place.get_node("Cop")), "PROMPT_FALSE_BACK")


func test_the_customers_skip_fitting_room_3() -> void:
	var place := _shop()
	assert_eq(place.closed_fitting, 2)
	var rooms := {}
	for i in 6:
		place.on_turn = null
		place._turn_left = 0.0
		place._physics_process(0.01)
		rooms[place.on_turn.room] = true
	assert_false(rooms.has(2), "nobody goes to the one out of order")
	assert_eq(rooms.size(), 2)


func test_a_cop_in_fitting_room_3_hears_the_machine() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	cop.global_position = place.to_global(Vector3(-10.3, CostumeShop.FLOOR_TOP + 0.1, CostumeShop.FITTING_Z[2]))
	await wait_physics_frames(4)
	assert_true(place.raid.clues_found.has(tr("CLUE_SEWING_SOUND")), "the sound is the clue")


func test_pushing_the_mirror_lifts_it() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var rig := place.rig as FalseFittingRoomRig
	rig.back.use(place.get_node("Cop"))
	assert_true(rig.is_open)
	await wait_seconds(FalseFittingRoomRig.LIFT_TIME + 0.2)
	assert_almost_eq(rig.back.position.y, CostumeShop.FLOOR_TOP + FalseFittingRoomRig.LIFT, 0.01)
	assert_eq(rig.back.prompt_key(place.get_node("Cop")), "")
	for key: String in ["BRIEF_FALSE_FITTING_B", "BRIEF_FALSE_FITTING_C", "BRIEF_FALSE_FITTING_D",
			"OBJ_FIND_FALSE_FITTING", "OBJ_EXTRA_FAKE_BRAND_LABELS", "OBJ_EXTRA_COSTUME_PATTERN", "COSTUME_OUT_OF_ORDER",
			"PROMPT_FALSE_BACK", "SEWING_SOUND", "CLUE_SEWING_SOUND", "MIMI_CLUE_false_fitting_room"]:
		assert_ne(tr(key), key, key)
