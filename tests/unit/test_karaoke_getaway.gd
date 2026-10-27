extends GutTest

## The karaoke in Play's draw and Rosaura's getaway (allanamiento-karaoke.md, step 7): she sees a cop pick up the main
## evidence close by and drives off in the getaway car from in front of the patrol car, and pulled over it's her who
## gets off.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func test_she_sees_the_evidence_picked_up_and_drives_off() -> void:
	var place: Karaoke = SCENE.instantiate()
	place.story_id = "karaoke_applause"
	place.case_seed = 5
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	await wait_physics_frames(30)
	var raid := place.raid
	assert_true(RaidEscape.handles("karaoke"))
	var cop: Cop = place.get_node("Cop")
	var evidence := raid.main_evidence
	evidence.global_position = place.owner_boss.global_position + Vector3(3, 0.5, 0)
	cop.global_position = evidence.global_position + Vector3(1, -0.4, 0)
	evidence.hold(cop.get_node("Grabber").get_instance_id(), evidence.global_position)
	await wait_physics_frames(5)
	assert_true(raid.escape.fled, "she saw it")
	assert_false(place.owner_boss.visible)
	var chase := raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (place.get_node("City") as Node3D).global_transform * RaidEscape.spot("karaoke")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "karaoke")
	for key: String in ["HINT_ESCAPE_karaoke"] + chase.suspect.lines():
		assert_ne(tr(key), key)


func test_play_draws_it() -> void:
	assert_has(PlaceDraw.ORDER, "karaoke")
	var drawn := false
	for i in 3000:
		if PlaceDraw.pick(i + 1, [], 1) == "karaoke":
			drawn = true
			break
	assert_true(drawn)
