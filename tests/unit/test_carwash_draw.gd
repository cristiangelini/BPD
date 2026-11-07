extends GutTest

## The car wash in the raids' draw (allanamiento-lavadero.md, step 7): Play can land on it, and Don Chorro gets away in
## his car like the other owners.


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_play_draws_the_car_wash_among_the_raids() -> void:
	assert_has(PlaceDraw.ORDER, "carwash")
	assert_eq(PlaceDraw.PLACES.carwash, "res://scenes/levels/car_wash.tscn")
	var drawn := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1, false) == "carwash":
			drawn = true
			break
	assert_true(drawn)


func test_don_chorro_gets_away_in_his_car() -> void:
	var car_wash: CarWash = preload("res://scenes/levels/car_wash.tscn").instantiate()
	car_wash.case_seed = 7
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	await wait_physics_frames(30)
	assert_true(RaidEscape.handles("carwash"))
	assert_not_null(car_wash.raid.escape)
	car_wash.raid.escape.flee()
	var chase := car_wash.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (car_wash.get_node("City") as Node3D).global_transform * RaidEscape.spot("carwash")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "carwash")
	for key: String in ["HINT_ESCAPE_carwash", "CHASE_CARWASH_LINE_1", "CHASE_CARWASH_LINE_2", "CHASE_CARWASH_LINE_3"]:
		assert_ne(tr(key), key, key)
