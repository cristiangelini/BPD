extends GutTest

## The ice rink in the raids' draw (allanamiento-pista.md, step 7): Play can land on it, and Doña Pirueta gets away in
## her car like the other owners.


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_play_draws_the_rink_among_the_raids() -> void:
	assert_has(PlaceDraw.ORDER, "rink")
	assert_eq(PlaceDraw.PLACES.rink, "res://scenes/levels/rink.tscn")
	var drawn := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1, false) == "rink":
			drawn = true
			break
	assert_true(drawn)


func test_dona_pirueta_gets_away_in_her_car() -> void:
	var rink: Rink = preload("res://scenes/levels/rink.tscn").instantiate()
	rink.case_seed = 7
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	await wait_physics_frames(30)
	assert_true(RaidEscape.handles("rink"))
	assert_not_null(rink.raid.escape)
	rink.raid.escape.flee()
	var chase := rink.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (rink.get_node("City") as Node3D).global_transform * RaidEscape.spot("rink")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "rink")
	for key: String in ["HINT_ESCAPE_rink", "CHASE_RINK_LINE_1", "CHASE_RINK_LINE_2", "CHASE_RINK_LINE_3"]:
		assert_ne(tr(key), key, key)
