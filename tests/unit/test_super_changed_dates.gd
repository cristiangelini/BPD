extends GutTest

## The supermarket as a raid with the changed dates' story (allanamiento-super.md, step 5): the suspicions, the labeling
## gun and its extras hidden with the seed, the peeled can on aisle 3, the snack that tastes of another century, what
## Don Ofertón lets slip and what Lalo saw, and the gun in the trunk solving the case.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super(case_seed := 5) -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.story_id = "super_dates"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_eq(store.raid.suspicions.size(), 3)
	assert_has(store.raid.suspicions, "super_dates")
	for id: String in store.raid.suspicions:
		assert_has(Supermarket.SUSPICION_POOL, id)
	assert_eq(store.raid.owner_npc, store.manager)


func test_the_gun_and_its_extras_are_hidden_with_the_seed() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq(store.main.full_value, 1000.0, 0.01)
	assert_eq(store.extras.size(), 2, "the old labels and the yogurt")
	var other := _super(6)
	await wait_physics_frames(2)
	assert_ne(store.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_peeled_can_is_a_clue_and_the_snack_tastes_old() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var cop: Cop = store.get_node("Cop")
	rig.clue.use(cop)
	assert_has(store.raid.clues_found, tr("SUPER_DATES_CLUE"))
	var clues: int = store.raid.clues_found.size()
	rig.snack.use(cop)
	assert_eq(store.raid.clues_found.size(), clues, "the snack isn't a clue")
	for spot: ClueSpot in [rig.clue, rig.snack]:
		assert_lt(absf(spot.position.x), Supermarket.HALF_X)


func test_don_oferton_slips_and_lalo_saw_where() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_eq(store.manager.slips.size(), 3)
	assert_true(store.manager.ask(store.get_node("Cop")))
	assert_eq(store.raid.clues_found.size(), 1)
	var where := tr("LOC_" + Supermarket.SPOTS[store.hidden_spots[5 % 3]].id)
	assert_eq(store.stocker.clue, tr("CLUE_LALO") % where)
	var cop: Cop = store.get_node("Cop")
	for i in SuperStocker.HAND_OVER:
		var can: Grabbable = store.get_node("RestockCan%d" % i)
		store.stocker.take(can, cop)
	assert_has(store.raid.clues_found, store.stocker.clue, "on the checklist")


func test_the_gun_in_the_trunk_solves_the_case() -> void:
	var store := _super()
	await wait_physics_frames(10)
	var gun := store.main
	gun.global_position = store.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(gun))
	assert_true(store.raid.mark(store.raid.suspicions.find("super_dates")))
	assert_eq(store.raid.objective_facts().extras.size(), 2)
	store.car.enter(store.get_node("Cop"))
	assert_true(store.raid.case_solved)


func test_the_fines_go_to_the_case() -> void:
	var store := _super()
	await wait_physics_frames(2)
	store.topple_pyramid()
	assert_eq(store.raid.fines, Supermarket.PYRAMID_FINE)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_SUPER_TIP_B", "BRIEF_SUPER_TIP_D", "BRIEF_SUPER_TIP_E", "BRIEF_SUPER_DATES_B",
		"BRIEF_SUPER_DATES_C", "BRIEF_SUPER_DATES_D", "OBJ_FIND_PRICE_GUN", "OBJ_EXTRA_LABEL_BOX", "OBJ_EXTRA_OLD_YOGURT",
		"OBJ_ENTER_SUPER", "OBJ_GUESS_SUPER", "OBJ_BROKEN_SUPER", "OBJ_COMPLAINT_SUPER", "OFERTON_SLIP", "CLUE_LALO",
		"LALO_CLUE_super_dates", "SUPER_DATES_CLUE", "SUPER_DATES_GRIMACE", "CRIME_owner_supermarket",
		"CONFESS_owner_supermarket", "CASE_FAILED_LAWYER_SUPERMARKET", "HINT_TILL_KEY_SUPERMARKET"]
	for id: String in Supermarket.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_supermarket"))
