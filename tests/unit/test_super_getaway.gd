extends GutTest

## The supermarket in Play's draw and Don Ofertón's getaway (allanamiento-super.md, step 7): he sees a cop pick up the
## main evidence close by and drives off in the getaway car from in front of the patrol car, and pulled over it's him
## who gets off.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func test_he_sees_the_evidence_picked_up_and_drives_off() -> void:
	var store: Supermarket = SCENE.instantiate()
	store.story_id = "super_dates"
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	await wait_physics_frames(30)
	var raid := store.raid
	assert_true(RaidEscape.handles("supermarket"))
	var cop: Cop = store.get_node("Cop")
	var evidence := raid.main_evidence
	evidence.global_position = store.manager.global_position + Vector3(3, 0.5, 0)
	cop.global_position = evidence.global_position + Vector3(1, -0.4, 0)
	evidence.hold(cop.get_node("Grabber").get_instance_id(), evidence.global_position)
	await wait_physics_frames(5)
	assert_true(raid.escape.fled, "he saw it")
	assert_false(store.manager.visible)
	var chase := raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (store.get_node("City") as Node3D).global_transform * RaidEscape.spot("supermarket")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "supermarket")
	for key: String in ["HINT_ESCAPE_supermarket"] + chase.suspect.lines():
		assert_ne(tr(key), key)


func test_play_draws_it() -> void:
	assert_has(PlaceDraw.ORDER, "supermarket")
	var drawn := false
	for i in 3000:
		if PlaceDraw.pick(i + 1, [], 1) == "supermarket":
			drawn = true
			break
	assert_true(drawn)
