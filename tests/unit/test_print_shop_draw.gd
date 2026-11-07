extends GutTest

## The print shop in the raids' draw (allanamiento-imprenta.md, step 8): Play can land on it, and Don Renglón gets
## away in his car like the other owners.


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_play_draws_the_print_shop_among_the_raids() -> void:
	assert_has(PlaceDraw.ORDER, "print_shop")
	assert_eq(PlaceDraw.PLACES.print_shop, "res://scenes/levels/print_shop.tscn")
	var drawn := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1, false) == "print_shop":
			drawn = true
			break
	assert_true(drawn)


func test_renglon_gets_away_in_his_car() -> void:
	var shop: PrintShop = preload("res://scenes/levels/print_shop.tscn").instantiate()
	shop.case_seed = 5
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	await wait_physics_frames(30)
	assert_true(RaidEscape.handles("print_shop"))
	assert_not_null(shop.raid.escape)
	shop.raid.escape.flee()
	var chase := shop.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (shop.get_node("City") as Node3D).global_transform * RaidEscape.spot("print_shop")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "print_shop")
	for key: String in ["HINT_ESCAPE_print_shop", "CHASE_PRINT_SHOP_LINE_1", "CHASE_PRINT_SHOP_LINE_2",
			"CHASE_PRINT_SHOP_LINE_3"]:
		assert_ne(tr(key), key, key)
