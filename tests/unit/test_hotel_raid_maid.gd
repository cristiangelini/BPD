extends GutTest

## Doña Escoba and the unmade beds in the hotel raid (hotel-allanamiento.md, step 3).

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid() -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.case_seed = 7
	raid.get_node("Cop").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_she_walks_the_corridor_with_her_cart() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var maid := raid.maid
	assert_not_null(maid.cart, "the crime scene's maid, with her cart")
	var start := maid.position.x
	await wait_seconds(1.0)
	assert_lt(maid.position.x, start - 0.4, "heading west")
	maid.position.x = HotelRaidMaid.WEST_X
	await wait_seconds(1.0)
	assert_gt(maid.position.x, HotelRaidMaid.WEST_X + 0.4, "and back east at the suite's end")
	assert_between(maid.position.x, HotelRaidMaid.WEST_X, HotelRaidMaid.EAST_X)
	assert_eq(raid.hotel.floor_of(maid.global_position + Vector3.UP), 1, "upstairs")
	assert_eq(raid.hotel.room_of(maid.global_position + Vector3.UP), -1, "in the corridor")


func test_a_bed_in_every_guest_room_unmade() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	assert_eq(raid.beds.size(), Hotel.GUEST_ROOMS.size())
	var cop: Cop = raid.get_node("Cop")
	for number: int in raid.beds:
		var bed: HotelBed = raid.beds[number]
		assert_false(bed.made)
		assert_eq(raid.hotel.room_of(bed.global_position + Vector3.UP * 0.1), number, "the %d's bed is in it" % number)
		assert_eq(bed.prompt_key(cop), "PROMPT_HOTEL_MAKE_BED")


func test_making_a_bed_takes_the_hands_and_she_tells_once() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var cop: Cop = raid.get_node("Cop")
	raid.maid.clue = "en el piano"
	watch_signals(raid.maid)
	var bed: HotelBed = raid.beds[12]
	var far := absf(raid.maid.position.x - Hotel.ROOMS[12].door)
	bed.use(cop)
	assert_true(cop.is_busy(), "hands busy while making it")
	assert_eq(bed.prompt_key(cop), "PROMPT_HOTEL_BED_MAKING")
	await wait_seconds(HotelBed.MAKE_SECONDS + 0.3)
	assert_true(bed.made)
	assert_false(cop.is_busy())
	assert_signal_emitted_with_parameters(raid.maid, "told", ["en el piano"])
	assert_eq(raid.maid.said(), "en el piano")
	assert_lt(absf(raid.maid.position.x - Hotel.ROOMS[12].door), far - HotelBed.MAKE_SECONDS * HotelRaidMaid.SPEED,
		"she hurried to its door to chat")
	assert_eq(bed.prompt_key(cop), "", "made")
	raid.beds[14].use(cop)
	await wait_seconds(HotelBed.MAKE_SECONDS + 0.3)
	assert_signal_emit_count(raid.maid, "told", 1, "once per cop")
	raid.maid.use(cop)
	assert_eq(raid.maid.said(), "HOTEL_MAID_THANKS")


func test_stopping_halfway_leaves_it_unmade() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var cop: Cop = raid.get_node("Cop")
	watch_signals(raid.maid)
	var bed: HotelBed = raid.beds[16]
	bed.use(cop)
	await wait_seconds(1.0)
	bed.stand_up()
	await wait_seconds(HotelBed.MAKE_SECONDS)
	assert_false(bed.made)
	assert_false(cop.is_busy())
	assert_signal_not_emitted(raid.maid, "told")


func test_without_help_she_is_busy_and_without_a_clue_she_saw_nothing() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var cop: Cop = raid.get_node("Cop")
	raid.maid.use(cop)
	assert_eq(raid.maid.said(), "HOTEL_MAID_BUSY")
	watch_signals(raid.maid)
	raid.maid.helped(cop)
	assert_signal_emitted_with_parameters(raid.maid, "told", [tr("HOTEL_MAID_SAW_NOTHING")])


func test_the_texts_are_translated() -> void:
	for key: String in ["PROMPT_HOTEL_MAKE_BED", "PROMPT_HOTEL_BED_MAKING", "HOTEL_MAID_BUSY", "HOTEL_MAID_HELP_1",
			"HOTEL_MAID_HELP_2", "HOTEL_MAID_THANKS", "HOTEL_MAID_SAW_NOTHING"]:
		assert_ne(tr(key), key, key)
