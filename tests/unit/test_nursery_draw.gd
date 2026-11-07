extends GutTest

## The plant nursery in the raids' draw (allanamiento-vivero.md, step 8): Play can land on it, and Doña Hortensia gets
## away in her car like the other owners.


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_play_draws_the_nursery_among_the_raids() -> void:
	assert_has(PlaceDraw.ORDER, "nursery")
	assert_eq(PlaceDraw.PLACES.nursery, "res://scenes/levels/nursery.tscn")
	var drawn := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1, false) == "nursery":
			drawn = true
			break
	assert_true(drawn)


func test_hortensia_gets_away_in_her_car() -> void:
	var nursery: Nursery = preload("res://scenes/levels/nursery.tscn").instantiate()
	nursery.case_seed = 5
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	await wait_physics_frames(30)
	assert_true(RaidEscape.handles("nursery"))
	assert_not_null(nursery.raid.escape)
	nursery.raid.escape.flee()
	var chase := nursery.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (nursery.get_node("City") as Node3D).global_transform * RaidEscape.spot("nursery")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "nursery")
	for key: String in ["HINT_ESCAPE_nursery", "CHASE_NURSERY_LINE_1", "CHASE_NURSERY_LINE_2", "CHASE_NURSERY_LINE_3"]:
		assert_ne(tr(key), key, key)
