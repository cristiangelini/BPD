extends GutTest

## The ring in the bread as a full case (docs/diseno/panaderia.md, step 3): the suspicions, the clues, Marta's
## slips, the gossiping customer and the delivery in the trunk.

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")


func _bakery(case_seed := 5) -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.story_id = "ring"
	bakery.case_seed = case_seed
	bakery.get_node("Cop").input_enabled = false
	bakery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(bakery)
	bakery._customer_wait = 999.0
	return bakery


func test_three_bakery_suspicions_with_the_ring_among_them() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	assert_eq(bakery.raid.suspicions.size(), CaseSuspicions.COUNT)
	assert_has(bakery.raid.suspicions, "ring")
	for id: String in bakery.raid.suspicions:
		assert_has(Bakery.SUSPICION_POOL, id)
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id)
	var texts := CaseObjectives.rows(bakery.raid.objective_facts()).map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_ENTER_BAKERY", "the checklist talks about the bakery, not the grandpa's house")
	assert_has(texts, "OBJ_GUESS_BAKERY")


func test_one_clue_note_for_each_suspicion() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var texts := bakery.find_children("*", "ClueNote", false, false).map(func(note: ClueNote) -> String: return note.text)
	assert_eq(texts.size(), CaseSuspicions.COUNT)
	for id: String in bakery.raid.suspicions:
		assert_has(texts, tr("CLUE_SUSPECT_" + id))


func test_the_ring_in_the_trunk_and_everyone_back_at_the_station_solves_the_case() -> void:
	var bakery := _bakery()
	await wait_physics_frames(10)
	bakery.loaves[bakery.ring_loaf].split()
	await wait_physics_frames(2)
	var ring := bakery.ring
	assert_true(ring.is_inside_tree(), "splitting the loaf drops the ring")
	ring.global_position = bakery.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(bakery.car.is_delivered(ring))
	assert_true(bakery.raid.mark(bakery.raid.suspicions.find("ring")))
	assert_eq(bakery.raid.objective_facts().extras.size(), 2, "the extras show once the story is known")
	bakery.car.enter(bakery.get_node("Cop"))
	assert_true(bakery.raid.case_solved, "the car waits at the station, so this ends the shift")
	assert_eq(bakery.fines, Bread.FINE, "the split loaf is still a fine")


func test_marta_lets_slip_where_the_extras_are_then_stops_answering() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var cop: Cop = bakery.get_node("Cop")
	var baker := bakery.baker
	assert_true(baker.ask(cop))
	baker._ask_wait = 0.0
	assert_true(baker.ask(cop))
	baker._ask_wait = 0.0
	assert_false(baker.ask(cop), "two slips and she's done")
	assert_eq(bakery.raid.clues_found.size(), 2)
	for i in bakery.extras.size():
		var where := tr("LOC_" + Bakery.SPOTS[bakery.hidden_spots[i]].id)
		assert_has(bakery.raid.clues_found, tr("BAKER_SLIP") % where)
	assert_almost_eq(baker.complaint, Baker.ASKED * 2, 0.5, "every question annoys her")


func test_the_gossip_eats_a_loaf_and_tells_where_marta_hid_something() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var gossip := bakery.gossip
	gossip.use(bakery.get_node("Cop"))
	assert_true(gossip.was_asked)
	var plain := (bakery.ring_loaf + 1) % bakery.loaves.size()
	var loaf := bakery.loaves[plain]
	loaf.global_position = gossip.global_position + Vector3.UP * 0.9
	await wait_physics_frames(5)
	assert_true(gossip.fed)
	assert_false(is_instance_valid(loaf), "he eats it")
	assert_eq(bakery.raid.clues_found, [gossip.clue] as Array[String])
	assert_eq(bakery.fines, 0, "a loaf for the gossip isn't a broken one")


func test_feeding_him_the_ring_loaf_drops_the_ring() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	bakery.gossip.feed(bakery.loaves[bakery.ring_loaf])
	await wait_physics_frames(2)
	assert_true(bakery.ring.is_inside_tree(), "he bites on the ring and it falls out")


func test_marta_calling_her_lawyer_fails_the_case() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	bakery.baker._set_complaint(Baker.MAX_COMPLAINT)
	assert_true(bakery.raid.case_failed)
	assert_eq(bakery.get_node("%CaseFailed").text, "CASE_FAILED_LAWYER_BAKER")
