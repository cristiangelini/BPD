extends GutTest

## The hotel raid with the regular guest (hotel-allanamiento.md, step 5): señor Ramón crossing the lobby in disguise,
## the guest book in one handwriting and his costume trunk in the patrol car's trunk.

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid(case_seed := 5) -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.story_id = "regular_guest"
	raid.case_seed = case_seed
	raid.get_node("Cop").input_enabled = false
	raid.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_the_trunk_hides_where_it_fits_and_solves_the_case() -> void:
	var raid := _raid()
	await wait_physics_frames(10)
	assert_has(raid.raid.suspicions, "regular_guest")
	assert_eq(raid.main.scene_file_path, "res://scenes/props/costume_trunk.tscn")
	assert_true(HotelRaid.SPOTS[raid.hidden_spots[0]].heavy, "the trunk only goes where it fits")
	assert_eq(raid.extras.size(), 2, "the guest book and the wig")
	raid.main.global_position = raid.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(raid.car.is_delivered(raid.main))
	assert_true(raid.raid.mark(raid.raid.suspicions.find("regular_guest")))
	raid.car.enter(raid.get_node("Cop"))
	assert_true(raid.raid.case_solved)


func test_the_guest_book_has_one_handwriting() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var rig := raid.rig as RegularGuestRig
	assert_eq(rig.book.prompt_key(raid.get_node("Cop")), "PROMPT_GUEST_BOOK")
	rig.book.use(raid.get_node("Cop"))
	assert_has(raid.raid.clues_found, tr("CLUE_REGULAR_GUEST_BOOK"))


func test_ramon_crosses_in_a_new_disguise_and_a_bump_unmasks_him() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var ramon := (raid.rig as RegularGuestRig).ramon
	assert_false(ramon.visible, "he waits off the lobby")
	ramon._wait = 0.0
	await wait_physics_frames(2)
	assert_true(ramon.walking)
	assert_true(ramon.visible)
	var first: int = ramon.disguise
	assert_eq(ramon.said(), "RAMON_HELLO_" + RegularGuest.DISGUISES[first].to_upper())
	ramon.position = RegularGuest.STAIRS
	await wait_physics_frames(3)
	assert_false(ramon.walking, "up the stairs and gone")
	assert_almost_eq(ramon._wait, RegularGuest.CROSS_EVERY, 0.2, "and back in 40 s")
	ramon._wait = 0.0
	await wait_physics_frames(2)
	assert_ne(ramon.disguise, first, "another disguise each time")
	var cop: Cop = raid.get_node("Cop")
	cop.global_position = ramon.global_position + Vector3(0.5, 0, 0)
	await wait_physics_frames(2)
	assert_true(ramon.fled)
	assert_eq(ramon.said(), "RAMON_UNMASKED")
	assert_has(raid.raid.clues_found, tr("CLUE_REGULAR_GUEST_MUSTACHE"))


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_REGULAR_GUEST_B", "BRIEF_REGULAR_GUEST_C", "BRIEF_REGULAR_GUEST_D",
			"OBJ_FIND_REGULAR_GUEST", "OBJ_EXTRA_GUEST_BOOK", "OBJ_EXTRA_WIG_SPARE", "PROMPT_GUEST_BOOK",
			"CLUE_REGULAR_GUEST_BOOK", "CLUE_REGULAR_GUEST_MUSTACHE", "RAMON_HELLO_MUSTACHE", "RAMON_HELLO_HAT",
			"RAMON_HELLO_WIG", "RAMON_UNMASKED"]:
		assert_ne(tr(key), key, key)
