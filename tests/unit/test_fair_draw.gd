extends GutTest

## The fun fair in the raids' draw (allanamiento-parque.md, step 7): Play can land on it, and Don Tómbola gets away in
## his car like the other owners.


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_play_draws_the_fair_among_the_raids() -> void:
	assert_has(PlaceDraw.ORDER, "fair")
	assert_eq(PlaceDraw.PLACES.fair, "res://scenes/levels/fair.tscn")
	var drawn := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1, false) == "fair":
			drawn = true
			break
	assert_true(drawn)


func test_don_tombola_gets_away_in_his_car() -> void:
	var fair: Fair = preload("res://scenes/levels/fair.tscn").instantiate()
	fair.case_seed = 7
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	await wait_physics_frames(30)
	assert_true(RaidEscape.handles("fair"))
	assert_not_null(fair.raid.escape)
	fair.raid.escape.flee()
	var chase := fair.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (fair.get_node("City") as Node3D).global_transform * RaidEscape.spot("fair")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "fair")
	for key: String in ["HINT_ESCAPE_fair", "CHASE_FAIR_LINE_1", "CHASE_FAIR_LINE_2", "CHASE_FAIR_LINE_3"]:
		assert_ne(tr(key), key, key)
