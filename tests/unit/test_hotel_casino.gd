extends GutTest

## The hotel raid as a full case with the casino of the 13 (hotel-allanamiento.md, step 4): the suspicions, the
## roulette in the 13, the chips, the footprints, the "tic tic tic", don Bostezo's slips, doña Escoba's chat and the
## delivery in the trunk.

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid(case_seed := 5) -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.story_id = "casino_13"
	raid.case_seed = case_seed
	raid.get_node("Cop").input_enabled = false
	raid.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_three_hotel_suspicions_with_the_casino_among_them() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	assert_eq(raid.raid.suspicions.size(), CaseSuspicions.COUNT)
	assert_has(raid.raid.suspicions, "casino_13")
	for id: String in HotelRaid.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id)
	var notes := raid.find_children("*", "ClueNote", false, false).filter(func(note: ClueNote) -> bool:
		return note.prompt == "PROMPT_NOTE")
	assert_eq(notes.size(), CaseSuspicions.COUNT, "one note for each suspicion")
	var texts := CaseObjectives.rows(raid.raid.objective_facts()).map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_ENTER_HOTEL")
	assert_eq(PlaceDraw.PLACES["hotel_raid"], LEVEL.resource_path)
	assert_eq(HotelRaid.pick_story(3, PackedStringArray(["--story=casino_13"])), "casino_13")


func test_the_roulette_waits_in_the_13_and_the_extras_hide_elsewhere() -> void:
	for case_seed in [1, 2, 3, 4, 5, 6]:
		var raid := _raid(case_seed)
		await wait_physics_frames(2)
		assert_eq(raid.main.scene_file_path, "res://scenes/props/roulette.tscn")
		assert_eq(raid.hotel.room_of(raid.main.global_position), Hotel.HIDDEN_ROOM, "the roulette is in the 13")
		assert_eq(raid.extras.size(), 2)
		for spot: int in raid.hidden_spots:
			assert_ne(HotelRaid.SPOTS[spot].id, "hotel_room_13", "the 13 is the roulette's")
		raid.free()


func test_the_roulette_in_the_trunk_solves_the_case() -> void:
	var raid := _raid()
	await wait_physics_frames(10)
	var roulette := raid.main
	roulette.global_position = raid.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(raid.car.is_delivered(roulette))
	assert_true(raid.raid.mark(raid.raid.suspicions.find("casino_13")))
	assert_eq(raid.raid.objective_facts().extras.size(), 2, "the chips and the debt book")
	raid.car.enter(raid.get_node("Cop"))
	assert_true(raid.raid.case_solved)


func test_don_bostezo_lets_slip_and_dona_escoba_tells_where_things_are() -> void:
	var raid := _raid()
	var cop: Cop = raid.get_node("Cop")
	await wait_physics_frames(2)
	assert_eq(raid.concierge.slips.size(), 2)
	assert_true(raid.concierge.ask(cop))
	assert_eq(raid.raid.clues_found.size(), 1)
	raid.maid.helped(cop)
	assert_eq(raid.raid.clues_found.size(), 2)
	var where := tr("LOC_" + HotelRaid.SPOTS[raid.hidden_spots[5 % 2]].id)
	assert_ne(raid.maid.clue.find(where), -1)


func test_the_chips_the_footprints_and_the_tick_are_clues() -> void:
	var raid := _raid()
	var cop: Cop = raid.get_node("Cop")
	await wait_physics_frames(2)
	var rig := raid.rig as CasinoRig
	assert_eq(rig.chips.size(), CasinoRig.CHIPS_AT.size())
	rig.chips[0].use(cop)
	assert_has(raid.raid.clues_found, tr("CLUE_CASINO_CHIPS"))
	assert_gt(rig.steps.size(), 8, "a trail from the stairs to the wardrobe")
	assert_false(rig.steps_seen)
	cop.global_position = Vector3(8.0, Hotel.UP + 0.1, 0.3)
	await wait_physics_frames(3)
	assert_true(rig.steps_seen)
	assert_has(raid.raid.clues_found, tr("CLUE_CASINO_STEPS"))
	assert_false(rig.tick_heard, "too far from the wardrobe")
	cop.global_position = Vector3(3.5, Hotel.UP + 0.1, 0.5)
	await wait_physics_frames(3)
	assert_true(rig.tick_heard)
	assert_true(rig._tick.visible, "tic tic tic")
	assert_has(raid.raid.clues_found, tr("CLUE_CASINO_TICK"))
	assert_not_null(raid.find_child("Smoke", false, false), "cigar smoke under the wardrobe")


func test_the_lawyer_loses_the_case_and_the_concierge_can_be_interrogated() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	raid.concierge._raise(HotelConcierge.MAX_COMPLAINT)
	assert_true(raid.raid.case_failed)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_concierge"))
	assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS["owner_concierge"]))
	for key: String in ["CRIME_owner_concierge", "CONFESS_owner_concierge", "CASE_FAILED_LAWYER_HOTEL"]:
		assert_ne(tr(key), key, key)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_HOTEL_TIP_B", "BRIEF_HOTEL_TIP_D", "BRIEF_HOTEL_TIP_E", "BRIEF_CASINO_B",
			"BRIEF_CASINO_C", "BRIEF_CASINO_D", "OBJ_FIND_CASINO", "OBJ_EXTRA_CHIP_BOX", "OBJ_EXTRA_DEBT_BOOK", "OBJ_ENTER_HOTEL",
			"OBJ_GUESS_HOTEL", "OBJ_BROKEN_HOTEL", "OBJ_COMPLAINT_HOTEL", "HOTEL_SLIP", "HOTEL_MAID_CLUE",
			"PROMPT_CASINO_CHIPS", "CASINO_TICK"]:
		assert_ne(tr(key), key, key)
	for spot: Dictionary in HotelRaid.SPOTS:
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, spot.id)
