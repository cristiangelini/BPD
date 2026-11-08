extends GutTest

## The toy store as a raid with the fake toys' story (allanamiento-jugueteria.md, step 5): the suspicions, the box of
## "Barbi" dolls and its extras hidden with the seed, the "Transformes" tag, a doll saying it's the original, what don
## Cucho lets slip and what doña Ramona saw for a toy, the ball pit hiding what lands in it, and the box in the trunk
## solving the case.

const SCENE := preload("res://scenes/levels/toy_store.tscn")


func _store(case_seed := 5) -> ToyStore:
	var store: ToyStore = SCENE.instantiate()
	store.story_id = "fake_toys"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


## A seed whose draw puts one of the story's things in the ball pit (spot 0).
func _pit_seed() -> int:
	var heavy: Array = ToyStore.SPOTS.map(func(spot: Dictionary) -> bool: return spot.heavy)
	for case_seed in range(1, 200):
		if HidingDraw.draw(case_seed, heavy, ToyStore.STORIES.fake_toys.heavy, 1).spots.has(0):
			return case_seed
	return -1


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.raid.suspicions.size(), 3)
	assert_has(store.raid.suspicions, "fake_toys")
	for id: String in store.raid.suspicions:
		assert_has(ToyStore.SUSPICION_POOL, id)
	assert_eq(store.raid.owner_npc, store.cucho)


func test_the_doll_box_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(ToyStore.SPOTS[store.hidden_spots[0]].heavy, "the box in a spot it fits")
	assert_eq(store.extras.size(), 2, "the stamp and the invoice")
	var other := _store(6)
	await wait_physics_frames(2)
	assert_ne(store.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_robot_tag_is_a_clue_and_a_doll_says_it_is_the_original() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as FakeToysRig
	rig.robot_tag.use(store.get_node("Cop"))
	assert_has(store.raid.clues_found, tr("CLUE_TRANSFORMES"))
	rig.talk()
	assert_eq(rig.talks, 1)
	assert_between(rig.last_shelf, 0, ToyStore.SHELVES.size() - 1)
	assert_eq(store.cucho.complaint, 0.0, "a doll talking costs no complaint")


func test_cucho_slips_and_ramona_saw_where() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.cucho.slips.size(), 3)
	assert_true(store.cucho.ask(store.get_node("Cop")))
	assert_eq(store.raid.clues_found.size(), 1)
	var where := tr("LOC_" + ToyStore.SPOTS[store.hidden_spots[5 % 3]].id)
	assert_eq(store.ramona.clue, tr("CLUE_RAMONA") % where)
	assert_eq(store.ramona.clue_speech, tr("RAMONA_CLUE_fake_toys") % where)
	var cop: Cop = store.get_node("Cop")
	store.shelves[0].use(cop)
	store.ramona.use(cop)
	assert_has(store.raid.clues_found, store.ramona.clue, "a toy for her puts it on the checklist")


func test_the_lawyer_loses_the_case() -> void:
	var store := _store()
	await wait_physics_frames(2)
	store.cucho.scold(FloorBoss.MAX_COMPLAINT, "CUCHO_NOTICED")
	assert_true(store.raid.case_failed)


func test_what_lands_in_the_ball_pit_waits_under_the_balls() -> void:
	var case_seed := _pit_seed()
	assert_gt(case_seed, 0, "some seed hides something in the pit")
	var store := _store(case_seed)
	await wait_physics_frames(2)
	var item: Evidence = store.pit.hidden
	assert_not_null(item)
	assert_false(item.visible, "can't be seen among the balls")
	for i in BallPitSpot.STIRS:
		store.pit.use(store.get_node("Cop"))
	assert_true(item.visible, "stirred out")
	assert_null(store.pit.hidden)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	await wait_physics_frames(10)
	var box := store.main
	if box == store.pit.hidden:
		for i in BallPitSpot.STIRS:
			store.pit.use(store.get_node("Cop"))
	box.global_position = store.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(box))
	assert_true(store.raid.mark(store.raid.suspicions.find("fake_toys")))
	assert_eq(store.raid.objective_facts().extras.size(), 2)
	store.car.enter(store.get_node("Cop"))
	assert_true(store.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_TOY_TIP_B", "BRIEF_TOY_TIP_D", "BRIEF_TOY_TIP_E", "BRIEF_FAKE_TOYS_B",
		"BRIEF_FAKE_TOYS_C", "BRIEF_FAKE_TOYS_D", "OBJ_FIND_FAKE_DOLLS", "OBJ_EXTRA_ORIGINAL_STAMP",
		"OBJ_EXTRA_DOLL_INVOICE", "OBJ_ENTER_TOY", "OBJ_GUESS_TOY", "OBJ_BROKEN_TOY", "OBJ_COMPLAINT_TOY", "CUCHO_SLIP",
		"CLUE_RAMONA", "RAMONA_CLUE_fake_toys", "TOY_TRANSFORMES", "CLUE_TRANSFORMES", "TOY_SOY_ORIGINAL",
		"HINT_ESCAPE_cucho", "CRIME_owner_cucho", "CONFESS_owner_cucho", "CASE_FAILED_LAWYER_TOY"]
	for id: String in ToyStore.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_cucho"))
	assert_true(ChaseSuspect.MODELS.has("cucho"))
	assert_eq(RaidEscape.PLACES.get("cucho"), "toy_store")


func test_don_cucho_gets_away_in_a_car() -> void:
	var store := _store(7)
	await wait_physics_frames(30)
	store.raid.escape.flee()
	var chase := store.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "cucho")
