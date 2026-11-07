extends GutTest

## The pawn shop's case (allanamiento-empenos.md, step 5): its suspicions and their clue notes, the train's watches (the
## suitcase hidden where it fits, the watches that all show the robbery's time and ring together), what Don Regateo
## lets slip, what Chicharra heard, the checklist, the lawyer and what the cops paid the shop.

const SCENE := preload("res://scenes/levels/pawn_shop.tscn")


func _shop(seed_value := 5, story := "train_watches") -> PawnShop:
	var place: PawnShop = SCENE.instantiate()
	place.case_seed = seed_value
	place.story_id = story
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_every_suspicion_is_written_and_has_its_note_in_the_shop() -> void:
	TranslationServer.set_locale("es")
	for id: String in PawnShop.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id)
	var place := _shop()
	assert_has(place.raid.suspicions, "train_watches")
	assert_eq(place.raid.suspicions.size(), CaseSuspicions.COUNT)
	var texts := []
	for child in place.get_children():
		if child is ClueNote:
			texts.append((child as ClueNote).text)
			assert_false(place.counter.overlaps_body(child), "never on the counter")
	for id in place.raid.suspicions:
		assert_has(texts, tr("CLUE_SUSPECT_" + id))
	for line in PawnShop.TIP_BRIEFING + PackedStringArray(PawnShop.STORIES.train_watches.briefing):
		assert_ne(tr(line), line, "%s is written" % line)


func test_the_suitcase_is_the_main_evidence_hidden_where_it_fits() -> void:
	var spots := {}
	for seed_value in range(1, 12):
		var place := _shop(seed_value)
		assert_eq(place.main, place.hidden[0])
		assert_eq(place.raid.main_evidence, place.main)
		assert_eq(place.main.value, 1000)
		assert_eq(place.extras.size(), 2)
		assert_true(PawnShop.SPOTS[place.hidden_spots[0]].heavy, "a 10 kg suitcase needs room")
		var unique := {}
		for spot: int in place.hidden_spots:
			unique[spot] = true
		assert_eq(unique.size(), 3, "each in its own spot")
		spots[place.hidden_spots[0]] = true
		place.free()
	assert_gt(spots.size(), 2, "the seed moves it around")


func test_the_watches_show_the_robbery_time_and_ring_together() -> void:
	TranslationServer.set_locale("es")
	var place := _shop()
	var rig := place.rig as TrainWatchesRig
	assert_not_null(rig)
	assert_eq(rig.watches.prompt, "PROMPT_PAWN_WATCHES")
	assert_string_contains(rig.watches.text, TrainWatchesRig.STOPPED_AT)
	rig._ring_left = 0.01
	await wait_physics_frames(3)
	assert_eq(rig.rings, 1)
	assert_true(rig._ring_left > TrainWatchesRig.RING_EVERY - 1.0, "and again in a while")


func test_regateo_lets_slip_where_things_are_and_chicharra_heard_one() -> void:
	TranslationServer.set_locale("es")
	var place := _shop()
	await wait_physics_frames(1)
	var boss := place.owner_boss
	assert_eq(boss.slips.size(), 3)
	for spot: int in place.hidden_spots:
		var line := tr("REGATEO_SLIP") % tr("LOC_" + PawnShop.SPOTS[spot].id)
		assert_has(boss.slips, line)
	watch_signals(place.raid)
	assert_true(boss.ask(place.get_node("Cop")))
	assert_has(place.raid.clues_found, boss.slips[0])
	assert_string_contains(place.parrot.clue, "Chicharra")
	assert_ne(place.parrot.clue_speech, "")
	place.parrot.told.emit(place.parrot.clue)
	assert_has(place.raid.clues_found, place.parrot.clue)


func test_the_checklist_has_the_shops_rows_and_the_extras_after_the_right_mark() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var facts := place._place_facts()
	assert_eq(facts.enter_key, "OBJ_ENTER_PAWN")
	assert_eq(facts.broken_key, "OBJ_BROKEN_PAWN")
	assert_eq(facts.extras, [], "the extras would give the story away")
	assert_true(place.raid.mark(place.raid.suspicions.find("train_watches")))
	var texts: Array = place._place_facts().extras.map(func(row: Dictionary) -> String: return row.text)
	assert_eq(texts, ["OBJ_EXTRA_PASSENGER_LIST", "OBJ_EXTRA_TRAIN_TICKET"])
	var rows := CaseObjectives.rows(place.raid.objective_facts()).map(func(r: Dictionary) -> String: return r.text)
	assert_has(rows, "OBJ_FIND_TRAIN_WATCHES")


func test_what_the_cops_paid_comes_off_the_pay_and_what_they_were_paid_back() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	place.fines = 20
	place.counter.spent = 12
	place.counter.cash_out = 5
	await wait_physics_frames(2)
	assert_eq(place.raid.fines, 27)
	place.counter.cash_out = 100
	await wait_physics_frames(2)
	assert_eq(place.raid.fines, 0, "never a bonus")


func test_the_lawyer_fails_the_case() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	place.owner_boss.blame(FloorBoss.MAX_COMPLAINT, "")
	assert_true(place.raid.case_failed)
	assert_eq(place.get_node("%CaseFailed").text, "CASE_FAILED_LAWYER_PAWN")
