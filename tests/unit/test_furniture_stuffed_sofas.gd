extends GutTest

## The furniture store as a raid with the stuffed sofas' story (allanamiento-muebleria.md, step 4): the suspicions, the
## cushion full of bills and its extras hidden with the seed, the sofa that crunches like paper and throws toy bills,
## what Don Cajón lets slip and what Tablita saw, and the cushion in the trunk solving the case.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store(case_seed := 5) -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.story_id = "stuffed_sofas"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.raid.suspicions.size(), 3)
	assert_has(store.raid.suspicions, "stuffed_sofas")
	for id: String in store.raid.suspicions:
		assert_has(FurnitureStore.SUSPICION_POOL, id)
	assert_eq(store.raid.owner_npc, store.cajon)


func test_the_cushion_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 6.0, 0.01)
	assert_true(FurnitureStore.SPOTS[store.hidden_spots[0]].heavy, "the cushion in a spot it fits")
	assert_eq(store.extras.size(), 2, "the book and the needle")
	var other := _store(6)
	await wait_physics_frames(2)
	assert_ne(store.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_crunchy_sofa_throws_bills_and_the_first_time_is_a_clue() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as StuffedSofasRig
	assert_between(rig.crunchy, 0, FurnitureStore.SOFAS.size() - 1)
	var cop: Cop = store.get_node("Cop")
	var plain := store.sofas[1 - rig.crunchy]
	plain.use(cop)
	assert_eq(rig.crunches, 0, "the other sofa is just a sofa")
	store.sofas[rig.crunchy].use(cop)
	assert_eq(rig.crunches, 1)
	assert_has(store.raid.clues_found, tr("CLUE_SOFA_CRUNCH"))
	await wait_physics_frames(10)
	var bills := get_tree().get_nodes_in_group("toy_bills")
	assert_eq(bills.size(), StuffedSofasRig.BILLS, "toy bills flying")
	var sofa_top := store.sofas[rig.crunchy].global_position.y + 0.7
	assert_gt((bills[0] as Node3D).global_position.y, sofa_top, "up in the air")
	var clues: int = store.raid.clues_found.size()
	rig.crunch(cop)
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")
	assert_eq(get_tree().get_nodes_in_group("toy_bills").size(), StuffedSofasRig.BILLS * 2, "but bills every time")


func test_cajon_slips_and_tablita_saw_where() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.cajon.slips.size(), 3)
	assert_true(store.cajon.ask(store.get_node("Cop")))
	assert_eq(store.raid.clues_found.size(), 1)
	var where := tr("LOC_" + FurnitureStore.SPOTS[store.hidden_spots[5 % 3]].id)
	assert_eq(store.tablita.clue, tr("CLUE_TABLITA") % where)
	store.tablita.held_by(store.get_node("Cop"))
	assert_has(store.raid.clues_found, store.tablita.clue, "on the checklist")


func test_the_lawyer_loses_the_case() -> void:
	var store := _store()
	await wait_physics_frames(2)
	store.cajon.scold(FloorBoss.MAX_COMPLAINT, "CAJON_NOTICED")
	assert_true(store.raid.case_failed)


func test_a_broken_lamp_is_a_fine_on_the_case() -> void:
	var store := _store()
	await wait_physics_frames(2)
	store.break_good(0)
	assert_eq(store.raid.fines, FurnitureStore.GOOD_FINE)
	assert_eq(store.raid.objective_facts().broken, 1)


func test_the_cushion_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	await wait_physics_frames(10)
	var cushion := store.main
	cushion.global_position = store.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(cushion))
	assert_true(store.raid.mark(store.raid.suspicions.find("stuffed_sofas")))
	assert_eq(store.raid.objective_facts().extras.size(), 2)
	store.car.enter(store.get_node("Cop"))
	assert_true(store.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_FURNITURE_TIP_B", "BRIEF_FURNITURE_TIP_D", "BRIEF_FURNITURE_TIP_E",
		"BRIEF_STUFFED_SOFAS_B", "BRIEF_STUFFED_SOFAS_C", "BRIEF_STUFFED_SOFAS_D", "OBJ_FIND_MONEY_CUSHION",
		"OBJ_EXTRA_OTHER_LEDGER", "OBJ_EXTRA_NEEDLE", "OBJ_ENTER_FURNITURE", "OBJ_GUESS_FURNITURE",
		"OBJ_BROKEN_FURNITURE", "OBJ_COMPLAINT_FURNITURE", "CAJON_SLIP", "CLUE_TABLITA", "TABLITA_CLUE_stuffed_sofas",
		"CLUE_SOFA_CRUNCH", "HINT_SOFA_CRUNCH", "FURNITURE_CRUNCH", "HINT_ESCAPE_furniture", "CRIME_owner_furniture",
		"CONFESS_owner_furniture", "CASE_FAILED_LAWYER_FURNITURE", "HINT_TILL_KEY_FURNITURE"]
	for id: String in FurnitureStore.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_furniture"))
	assert_true(ChaseSuspect.MODELS.has("furniture"))
	assert_true(RaidEscape.PLACES.has("furniture"))


func test_don_cajon_gets_away_in_a_car() -> void:
	var store := _store(7)
	await wait_physics_frames(30)
	store.raid.escape.flee()
	var chase := store.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "furniture")
