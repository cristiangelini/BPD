extends GutTest

## Don Bostezo in the hotel raid (hotel-allanamiento.md, step 2): the complaint, the nap with the pillow and the bell.

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid() -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.case_seed = 7
	raid.get_node("Cop").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_he_waits_behind_the_desk_with_the_pillow_and_the_bell() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	assert_not_null(raid.concierge)
	assert_lt(raid.concierge.global_position.distance_to(Hotel.CONCIERGE_AT), 0.2, "behind the desk")
	var cop: Cop = raid.get_node("Cop")
	assert_eq(raid.pillow.prompt_key(cop), "PROMPT_HOTEL_PILLOW")
	assert_eq(raid.bell.prompt_key(cop), "PROMPT_HOTEL_BELL")
	assert_false(raid.concierge.is_asleep())


func test_the_master_key_counts_only_while_he_is_awake() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var cop: Cop = raid.get_node("Cop")
	raid.key_board.use(cop)
	assert_eq(raid.concierge.complaint, HotelConcierge.KEY_TAKEN, "taken in front of him")
	assert_eq(raid.complaint_bar.value, HotelConcierge.KEY_TAKEN, "the meter shows it")
	raid.pillow.use(cop)
	assert_true(raid.concierge.is_asleep())
	cop.has_key = false
	raid.key_board.use(cop)
	assert_true(cop.has_key)
	assert_eq(raid.concierge.complaint, HotelConcierge.KEY_TAKEN, "asleep, he doesn't see the second one")


func test_asleep_he_sees_nothing_and_wakes_up_on_his_own() -> void:
	var raid := _raid()
	await wait_physics_frames(30)
	var cop: Cop = raid.get_node("Cop")
	watch_signals(raid.concierge)
	raid.pillow.use(cop)
	assert_signal_emitted(raid.concierge, "fell_asleep")
	assert_eq(raid.pillow.prompt_key(cop), "", "already asleep")
	raid.vases[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(raid.concierge.complaint, 0.0, "the vase on his desk breaks and he snores on")
	assert_eq(raid.fines, Ornament.FINE, "it's still a fine")
	assert_false(raid.concierge.ask(cop), "no questions while he snores")
	raid.concierge._asleep_left = 0.05
	await wait_physics_frames(5)
	assert_false(raid.concierge.is_asleep())
	assert_signal_emitted(raid.concierge, "woke_up")
	assert_false(raid.concierge.tuck_pillow(), "not sleepy right after a nap")
	raid.concierge._nap_wait = 0.0
	assert_true(raid.concierge.tuck_pillow(), "sleepy again after NAP_COOLDOWN")


func test_awake_he_sees_what_breaks_on_the_desk() -> void:
	var raid := _raid()
	await wait_physics_frames(30)
	raid.vases[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(raid.concierge.complaint, HotelConcierge.SAW_BREAK)


func test_the_bell_wakes_him_angry_and_awake_it_costs_nothing() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var cop: Cop = raid.get_node("Cop")
	raid.bell.use(cop)
	assert_eq(raid.concierge.complaint, 0.0, "awake, he just yawns")
	raid.pillow.use(cop)
	raid.bell.use(cop)
	assert_false(raid.concierge.is_asleep())
	assert_eq(raid.concierge.complaint, HotelConcierge.RUDE_BELL)


func test_a_rammed_door_wakes_him_and_counts() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	raid.pillow.use(raid.get_node("Cop"))
	var door: FrontDoor = raid.doors[15]
	for i in FrontDoor.RAM_HITS:
		door.ram_hit()
	assert_false(raid.concierge.is_asleep())
	assert_eq(raid.concierge.complaint, HotelConcierge.DOOR_BROKEN)


func test_two_slips_then_offended_and_the_lawyer_at_100() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var concierge := raid.concierge
	var cop: Cop = raid.get_node("Cop")
	concierge.slips.assign(["one", "two", "three"])
	assert_true(concierge.ask(cop))
	concierge._ask_wait = 0.0
	assert_true(concierge.ask(cop))
	concierge._ask_wait = 0.0
	assert_false(concierge.ask(cop), "two things, then he's offended")
	assert_eq(concierge.complaint, HotelConcierge.ASKED * 2)
	watch_signals(concierge)
	concierge._raise(HotelConcierge.MAX_COMPLAINT)
	assert_signal_emitted(concierge, "lawyer_called")


func test_the_texts_are_translated() -> void:
	for key: String in ["PROMPT_HOTEL_PILLOW", "PROMPT_HOTEL_BELL", "HOTEL_CONCIERGE_ZZZ", "HOTEL_CONCIERGE_NOT_SLEEPY",
			"HOTEL_CONCIERGE_BELL_ANGRY", "HOTEL_CONCIERGE_BELL", "HOTEL_CONCIERGE_WOKE", "HOTEL_CONCIERGE_NOTHING",
			"HOTEL_CONCIERGE_OFFENDED", "HOTEL_CONCIERGE_KEY", "HOTEL_CONCIERGE_HURT", "HOTEL_CONCIERGE_DOOR",
			"HOTEL_CONCIERGE_SAW", "HOTEL_CONCIERGE_LAWYER"]:
		assert_ne(tr(key), key, key)
