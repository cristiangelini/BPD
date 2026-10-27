extends GutTest

## Don Fantoche at the costume shop (allanamiento-disfraces.md, step 3): he walks his round, the counter bell sends him
## to the stock room for the biggest size with his back to the shop, the rings rest and the third one gives the cops
## away, and the customers' complaints and what breaks reach his complaint.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop() -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = 5
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_he_walks_his_round() -> void:
	var place := _shop()
	assert_not_null(place.owner_boss)
	assert_eq(place.owner_boss.voice, "FANTOCHE")
	var start := place.owner_boss.global_position
	await wait_seconds(1.5)
	assert_gt(place.owner_boss.global_position.distance_to(start), 0.8, "on his way")
	assert_eq(place.owner_boss.complaint, 0.0)


func test_the_bell_sends_him_to_the_stock_room() -> void:
	var place := _shop()
	var boss := place.owner_boss
	boss.start_at(4)
	boss.fix_time = 3.0
	await wait_physics_frames(5)
	var bell: CounterBell = place.size_bell.get_child(0)
	assert_eq(bell.prompt_key(place.get_node("Cop")), "PROMPT_COSTUME_BELL")
	bell.use(place.get_node("Cop"))
	assert_true(place.size_bell.is_jammed, "rung")
	assert_eq(boss.errand(), "printer")
	await wait_until(func() -> bool: return boss.is_fixing(), 12.0)
	assert_true(boss.is_fixing(), "looking for the size")
	var spot := place.to_global(CostumeShop.SIZE_SPOT)
	assert_lt(Vector2(boss.global_position.x - spot.x, boss.global_position.z - spot.z).length(), 0.5, "by the shelf")
	assert_false(boss.can_see(place.to_global(CostumeShop.TILL_ON)), "his back to the shop")
	await wait_seconds(3.5)
	assert_false(boss.is_fixing(), "back to his round")
	assert_false(place.size_bell.is_jammed)


func test_rings_rest_and_the_third_gives_the_cops_away() -> void:
	var place := _shop()
	var bell := place.size_bell
	watch_signals(bell)
	bell.ring()
	assert_signal_emit_count(bell, "rung", 1)
	bell.fix()
	bell.ring()
	assert_signal_emit_count(bell, "rung", 1, "resting")
	bell.rest_left = 0.0
	bell.ring()
	assert_signal_emit_count(bell, "rung", 2)
	bell.fix()
	bell.rest_left = 0.0
	bell.ring()
	assert_signal_emitted(bell, "caught_on")
	assert_signal_emit_count(bell, "rung", 2, "no errand")
	assert_eq(place.owner_boss.complaint, CostumeShop.CAUGHT_ON)


func test_the_customers_complaints_reach_him() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	place.customers[0].complain("COSTUME_CUSTOMER_CRUSH")
	assert_eq(place.owner_boss.complaint, CostumeShop.CUSTOMER_COMPLAINT)
	place.customers[0].complain("COSTUME_CUSTOMER_CRUSH")
	assert_eq(place.owner_boss.complaint, CostumeShop.CUSTOMER_COMPLAINT, "each one's cooldown")
	place.customers[1].complain("COSTUME_CUSTOMER_BUSY")
	assert_eq(place.owner_boss.complaint, CostumeShop.CUSTOMER_COMPLAINT * 2)
	for key: String in ["FANTOCHE_LINE_1", "FANTOCHE_PRINTER", "FANTOCHE_FIX_3", "FANTOCHE_FIX_DONE", "FANTOCHE_HURT",
			"FANTOCHE_DOOR", "FANTOCHE_SAW", "FANTOCHE_NOTHING", "FANTOCHE_OFFENDED", "FANTOCHE_LAWYER",
			"FANTOCHE_CAUGHT_ON", "FANTOCHE_CUSTOMER", "FANTOCHE_MIRROR", "FANTOCHE_CASE", "PROMPT_COSTUME_BELL",
			"HINT_COSTUME_BELL_WAIT", "COSTUME_BELL_SIGN"]:
		assert_ne(tr(key), key, key)
