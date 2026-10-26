extends GutTest

## The fake reviews (hotel-allanamiento.md, step 5e): the typewriter hidden like its extras, the carbon paper in the
## lobby's bin and the "tac tac tac" while don Bostezo naps.

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid(case_seed := 5) -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.story_id = "fake_reviews"
	raid.case_seed = case_seed
	raid.get_node("Cop").input_enabled = false
	raid.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_the_typewriter_is_hidden_with_its_extras() -> void:
	for case_seed in [1, 2, 3, 4]:
		var raid := _raid(case_seed)
		await wait_physics_frames(2)
		assert_eq(raid.main.scene_file_path, "res://scenes/props/typewriter.tscn")
		assert_true(HotelRaid.SPOTS[raid.hidden_spots[0]].heavy, "the typewriter only goes where it fits")
		assert_eq(raid.extras.size(), 2)
		raid.free()


func test_the_carbon_paper_in_the_bin_is_a_clue() -> void:
	var raid := _raid()
	var cop: Cop = raid.get_node("Cop")
	await wait_physics_frames(30)
	var rig := raid.rig as ReviewsRig
	assert_gt(rig.bin_paper.global_position.y, ReviewsRig.BIN_AT.y + ReviewsRig.BIN_HEIGHT - 0.05, "on top of the bin")
	rig.bin_paper.use(cop)
	assert_has(raid.raid.clues_found, tr("CLUE_REVIEWS_CARBON"))


func test_it_types_while_don_bostezo_naps() -> void:
	var raid := _raid()
	var cop: Cop = raid.get_node("Cop")
	await wait_physics_frames(2)
	var rig := raid.rig as ReviewsRig
	cop.global_position = raid.main.global_position + Vector3(1.5, 0.1, 0)
	await wait_physics_frames(3)
	assert_false(rig.typing(), "awake, he doesn't type")
	assert_false(rig._tac.visible)
	assert_true(raid.concierge.tuck_pillow())
	await wait_physics_frames(3)
	assert_true(rig.typing())
	assert_true(rig._tac.visible, "tac tac tac")
	assert_true(rig.tac_heard)
	assert_has(raid.raid.clues_found, tr("CLUE_REVIEWS_TAC"))
	cop.global_position = raid.main.global_position + Vector3(ReviewsRig.HEARS + 2.0, 0.1, 0)
	await wait_physics_frames(3)
	assert_false(rig._tac.visible, "too far to hear it")


func test_the_typewriter_in_the_trunk_solves_the_case_and_the_texts_are_translated() -> void:
	var raid := _raid()
	await wait_physics_frames(10)
	raid.main.global_position = raid.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(raid.car.is_delivered(raid.main))
	assert_true(raid.raid.mark(raid.raid.suspicions.find("fake_reviews")))
	raid.car.enter(raid.get_node("Cop"))
	assert_true(raid.raid.case_solved)
	assert_eq(HotelRaid.STORIES.size(), HotelRaid.SUSPICION_POOL.size(), "every suspicion has its story")
	for key: String in ["BRIEF_REVIEWS_B", "BRIEF_REVIEWS_C", "BRIEF_REVIEWS_D", "OBJ_FIND_REVIEWS",
			"OBJ_EXTRA_POSTCARDS", "OBJ_EXTRA_POSTMARK", "PROMPT_CARBON_PAPER", "CLUE_REVIEWS_CARBON", "REVIEWS_TAC", "CLUE_REVIEWS_TAC"]:
		assert_ne(tr(key), key, key)
