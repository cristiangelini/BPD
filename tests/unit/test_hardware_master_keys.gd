extends GutTest

## The hardware store as a full case with the master keys (docs/diseno/ferreteria.md, step 5): the suspicions, the
## clues, Tobías's slips, Don Cosme, the filings, the key board instead of the till and the delivery in the trunk.

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store(case_seed := 5) -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.story_id = "master_keys"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_three_store_suspicions_with_the_master_keys_among_them() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.raid.suspicions.size(), CaseSuspicions.COUNT)
	assert_has(store.raid.suspicions, "master_keys")
	for id: String in HardwareStore.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id)
	var notes := store.find_children("*", "ClueNote", false, false).filter(func(note: ClueNote) -> bool:
		return note.prompt == "PROMPT_NOTE")
	assert_eq(notes.size(), CaseSuspicions.COUNT, "one note for each suspicion")
	var texts := CaseObjectives.rows(store.raid.objective_facts()).map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_ENTER_HARDWARE")


func test_the_key_ring_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	await wait_physics_frames(10)
	var ring := store.main
	assert_eq(ring.scene_file_path, "res://scenes/props/master_key_ring.tscn")
	ring.global_position = store.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(ring))
	assert_true(store.raid.mark(store.raid.suspicions.find("master_keys")))
	assert_eq(store.raid.objective_facts().extras.size(), 2, "the wax molds and the list")
	store.car.enter(store.get_node("Cop"))
	assert_true(store.raid.case_solved)


func test_tobias_lets_slip_and_cosme_tells_where_things_are() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	assert_true(store.tobias.ask(cop))
	assert_eq(store.raid.clues_found.size(), 1)
	store.cosme.take(KeyMachine.KEY_SCENE.instantiate())
	assert_eq(store.raid.clues_found.size(), 2)
	assert_ne(store.cosme.clue_speech.find(tr("LOC_" + HardwareStore.SPOTS[store.hidden_spots[5 % 3]].id)), -1)


func test_the_filings_by_the_machine_are_the_storys_clue() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as MasterKeysRig
	rig.filings.use(store.get_node("Cop"))
	assert_eq(store.raid.clues_found, [tr("CLUE_FILINGS")] as Array[String])


func test_the_storeroom_key_hangs_on_the_board_not_in_the_till() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(10)
	store.till.use(cop)
	assert_false(cop.has_key, "the till is empty in this story")
	var needed := HardwareKeyBoard.tries_for(5)
	assert_eq(store.key_board.tries_needed, needed)
	for i in needed - 1:
		store.key_board.use(cop)
		assert_false(cop.has_key, "try %d isn't it" % (i + 1))
	assert_eq(store.key_board.prompt_key(cop), "PROMPT_KEY_BOARD")
	store.key_board.use(cop)
	assert_true(cop.has_key)
	assert_eq(store.key_board.prompt_key(cop), "")
	assert_gt(store.tobias.complaint, 0.0, "he saw the till and the board")


func test_tobias_running_off_is_a_chase() -> void:
	assert_true(RaidEscape.handles("hardware"))
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_hardware"))
	assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS.owner_hardware))
	assert_ne(tr("HINT_ESCAPE_hardware"), "HINT_ESCAPE_hardware")
