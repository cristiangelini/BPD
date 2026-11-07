extends GutTest

## The supermarket's rigged raffle (allanamiento-super.md, step 6): the urn hidden with the cardboard prize car and the
## winners' photo, and the table by the entrance with the sign and the pad of coupons, the top one already filled in
## for the cousin (the clue).

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super(case_seed := 5) -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.story_id = "super_raffle"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_urn_is_hidden_with_its_extras_and_the_car_in_a_heavy_spot() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "super_raffle")
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 3.0, 0.01)
	assert_eq(store.extras.size(), 2)
	assert_true(Supermarket.SPOTS[store.hidden_spots[1]].heavy, "the prize car only fits a big spot")


func test_the_table_by_the_entrance_has_the_sign_and_the_coupons() -> void:
	var store := _super()
	await wait_physics_frames(30)
	var rig := store.rig
	assert_eq(rig.sign_label.text, tr("SUPER_RAFFLE_SIGN"))
	var at: Vector3 = store.to_local(rig.coupons.global_position)
	assert_lt(absf(at.x - Supermarket.ENTRANCE_X), Supermarket.ENTRANCE_WIDTH, "by the doorway")
	assert_gt(at.z, Supermarket.HALF_Z - 1.5, "against the front wall")


func test_looking_at_the_coupons_is_the_clue_once() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var cop: Cop = store.get_node("Cop")
	assert_eq(rig.coupons.prompt_key(cop), "PROMPT_SUPER_COUPONS")
	rig.coupons.use(cop)
	assert_has(store.raid.clues_found, tr("SUPER_RAFFLE_CLUE"))
	var clues: int = store.raid.clues_found.size()
	rig.coupons.use(cop)
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_SUPER_RAFFLE_B", "BRIEF_SUPER_RAFFLE_C", "BRIEF_SUPER_RAFFLE_D", "OBJ_FIND_RAFFLE_URN",
			"OBJ_EXTRA_PRIZE_CAR", "OBJ_EXTRA_WINNERS_PHOTO", "LALO_CLUE_super_raffle", "PROMPT_SUPER_COUPONS",
			"SUPER_RAFFLE_SIGN", "SUPER_RAFFLE_CLUE"]:
		assert_ne(tr(key), key)
