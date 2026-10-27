extends GutTest

## The lift of 1987 (hotel-allanamiento.md, step 5c): the cage out of order in the lobby with the case of fake bills
## inside, the crank that opens it, the printing plates and the worn button with green ink.

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid(case_seed := 5) -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.story_id = "lift_1987"
	raid.case_seed = case_seed
	raid.get_node("Cop").input_enabled = false
	raid.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_the_case_waits_in_the_lift_and_the_crank_hides_elsewhere() -> void:
	for case_seed in [1, 2, 3, 4]:
		var raid := _raid(case_seed)
		await wait_physics_frames(2)
		var lift := (raid.rig as Lift1987Rig).lift
		assert_eq(raid.main.scene_file_path, "res://scenes/props/fake_money_case.tscn")
		var inside := lift.to_local(raid.main.global_position)
		assert_true(absf(inside.x) < OldLift.SIZE.x / 2 and inside.z > 0 and inside.z < OldLift.SIZE.z, "in the cage")
		assert_eq(raid.extras.size(), 2)
		assert_true(raid.extras[0] is LiftCrank)
		for spot: int in raid.hidden_spots:
			assert_ne(HotelRaid.SPOTS[spot].id, "hotel_by_lift", "that spot is inside the cage")
		raid.free()


func test_the_doors_open_only_with_the_crank() -> void:
	var raid := _raid()
	var cop: Cop = raid.get_node("Cop")
	await wait_physics_frames(2)
	var lift := (raid.rig as Lift1987Rig).lift
	assert_eq(lift.prompt_key(cop), "PROMPT_LIFT_STUCK")
	lift.use(cop)
	assert_null(lift.turner, "no crank, the doors don't budge")
	var crank: LiftCrank = raid.extras[0]
	cop.get_node("Grabber").grab(crank)
	lift.use(cop)
	assert_eq(lift.turner, cop)
	assert_eq(cop.seated_in, lift, "the hands are busy turning")
	await wait_seconds(OldLift.CRANK_SECONDS * 0.5)
	lift.stand_up()
	await wait_seconds(OldLift.CRANK_SECONDS)
	assert_false(lift.is_open, "stopping halfway leaves it shut")
	lift.use(cop)
	await wait_seconds(OldLift.CRANK_SECONDS + 0.3)
	assert_true(lift.is_open)
	assert_null(cop.seated_in)
	assert_eq(lift.prompt_key(cop), "")


func test_the_case_in_the_trunk_solves_the_case() -> void:
	var raid := _raid()
	await wait_physics_frames(10)
	var case := raid.main
	case.global_position = raid.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(raid.car.is_delivered(case))
	assert_true(raid.raid.mark(raid.raid.suspicions.find("lift_1987")))
	raid.car.enter(raid.get_node("Cop"))
	assert_true(raid.raid.case_solved)


func test_the_button_is_a_clue_and_the_texts_are_translated() -> void:
	var raid := _raid()
	var cop: Cop = raid.get_node("Cop")
	await wait_physics_frames(2)
	var rig := raid.rig as Lift1987Rig
	rig.button.use(cop)
	assert_has(raid.raid.clues_found, tr("CLUE_LIFT_BUTTON"))
	assert_eq(HotelRaid.pick_story(3, PackedStringArray(["--story=lift_1987"])), "lift_1987")
	for key: String in ["BRIEF_LIFT_B", "BRIEF_LIFT_C", "BRIEF_LIFT_D", "OBJ_FIND_LIFT", "OBJ_EXTRA_LIFT_CRANK",
			"OBJ_EXTRA_PLATES", "PROMPT_LIFT_CRANK", "PROMPT_LIFT_STUCK", "PROMPT_LIFT_TURNING", "HINT_LIFT_STUCK",
			"PROMPT_LIFT_BUTTON", "CLUE_LIFT_BUTTON"]:
		assert_ne(tr(key), key, key)
