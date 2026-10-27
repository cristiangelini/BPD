extends GutTest

## The sleepwalker (hotel-allanamiento.md, step 5d): the lost-and-found box hidden like its extras, the muddy slipper
## prints from the front door to it, and the sleepwalking guest who shouts when woken.

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid(case_seed := 5) -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.story_id = "sleepwalker"
	raid.case_seed = case_seed
	raid.get_node("Cop").input_enabled = false
	raid.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_the_box_is_hidden_with_its_extras_and_the_prints_lead_to_it() -> void:
	for case_seed in [1, 2, 3, 4, 5, 6]:
		var raid := _raid(case_seed)
		await wait_physics_frames(2)
		assert_eq(raid.main.scene_file_path, "res://scenes/props/lost_box.tscn")
		assert_true(HotelRaid.SPOTS[raid.hidden_spots[0]].heavy, "the box only goes where it fits")
		assert_eq(raid.extras.size(), 2)
		var rig := raid.rig as SleepwalkerRig
		assert_gt(rig.steps.size(), 5)
		var spot: Vector3 = HotelRaid.SPOTS[raid.hidden_spots[0]].at
		var first := rig.steps[0]
		var last := rig.steps[rig.steps.size() - 1]
		assert_lt(Vector2(first.x, first.z).distance_to(Vector2(0, 6.3)), 0.5, "from the front door")
		assert_lt(Vector2(last.x, last.z).distance_to(Vector2(spot.x, spot.z)), 1.2, "to the box")
		assert_almost_eq(last.y, (Hotel.UP if spot.y > Hotel.UP - 0.5 else Hotel.FLOOR_TOP) + 0.012, 0.01)
		raid.free()


func test_the_prints_upstairs_go_in_through_the_room_door() -> void:
	var corners := SleepwalkerRig.trail_to(Vector3(3.5, Hotel.UP, -4.0))
	assert_has(corners, Vector3(Hotel.ROOMS[13].door, Hotel.UP, -Hotel.CORRIDOR), "through the 13's door")
	corners = SleepwalkerRig.trail_to(Hotel.SUITE_BED_AT)
	assert_has(corners, Vector3(Hotel.SUITE_X - 0.4, Hotel.UP, Hotel.DOOR_SUITE_Z), "through the suite's door")
	assert_eq(SleepwalkerRig.trail_to(Vector3(1.2, Hotel.FLOOR_TOP, -7.6)).size(), 2, "straight across the lobby")


func test_the_prints_are_a_clue() -> void:
	var raid := _raid()
	var cop: Cop = raid.get_node("Cop")
	await wait_physics_frames(2)
	var rig := raid.rig as SleepwalkerRig
	assert_false(rig.steps_seen)
	cop.global_position = rig.steps[3] + Vector3.UP * 0.1
	await wait_physics_frames(3)
	assert_true(rig.steps_seen)
	assert_has(raid.raid.clues_found, tr("CLUE_SLEEPWALKER_STEPS"))


func test_waking_the_sleepwalker_makes_him_shout_and_wakes_don_bostezo() -> void:
	var raid := _raid()
	var cop: Cop = raid.get_node("Cop")
	await wait_physics_frames(2)
	var guest := (raid.rig as SleepwalkerRig).sleepwalker
	var from := guest.position.x
	await wait_seconds(1.0)
	assert_gt(guest.position.x, from, "he walks the corridor, asleep")
	raid.concierge.tuck_pillow()
	assert_true(raid.concierge.is_asleep())
	var complaint: float = raid.concierge.complaint
	cop.global_position = guest.global_position + Vector3(0.6, 0.1, 0.3)
	await wait_physics_frames(3)
	assert_true(guest.awake)
	assert_eq(guest.said(), "SLEEPWALKER_SHOUT")
	assert_almost_eq(raid.concierge.complaint, complaint + SleepwalkerRig.SHOUT, 0.01)
	assert_false(raid.concierge.is_asleep(), "the shout wakes him")
	assert_eq(guest.wakes, 1, "only once while he's awake")
	cop.global_position = Vector3(-6, 0.1, 0)
	await wait_seconds(Sleepwalker.AWAKE_SECONDS + 0.2)
	assert_false(guest.awake, "and back to sleep")


func test_the_box_in_the_trunk_solves_the_case_and_the_texts_are_translated() -> void:
	var raid := _raid()
	await wait_physics_frames(10)
	raid.main.global_position = raid.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(raid.car.is_delivered(raid.main))
	assert_true(raid.raid.mark(raid.raid.suspicions.find("sleepwalker")))
	raid.car.enter(raid.get_node("Cop"))
	assert_true(raid.raid.case_solved)
	for key: String in ["BRIEF_SLEEPWALKER_B", "BRIEF_SLEEPWALKER_C", "BRIEF_SLEEPWALKER_D", "OBJ_FIND_SLEEPWALKER",
			"OBJ_EXTRA_NEIGHBORHOOD_LIST", "OBJ_EXTRA_SLEEP_MASK", "PROMPT_SLEEPWALKER", "SLEEPWALKER_SHOUT",
			"SLEEPWALKER_ASLEEP", "SLEEPWALKER_MUMBLE_0", "SLEEPWALKER_MUMBLE_1", "SLEEPWALKER_MUMBLE_2",
			"HOTEL_CONCIERGE_SHOUT", "CLUE_SLEEPWALKER_STEPS"]:
		assert_ne(tr(key), key, key)
