extends GutTest

## The supermarket's false-bottomed carts story (allanamiento-super.md, step 6): the full cart hidden with the welder and
## the plan, and one of the store's carts with a false floor too: pushed, it pulls the cop to one side and clinks, and the
## first clink is the clue.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super(case_seed := 5) -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.story_id = "super_carts"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_full_cart_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "super_carts")
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 15.0, 0.01)
	assert_true(Supermarket.SPOTS[store.hidden_spots[0]].heavy)
	assert_eq(store.extras.size(), 2)


func test_the_crooked_cart_is_drawn_with_the_seed() -> void:
	var store := _super(5)
	assert_eq(store.rig.crooked, store.carts[5])
	var other := _super(3)
	assert_eq(other.rig.crooked, other.carts[3])


func test_pushed_it_pulls_the_cop_aside_and_clinks_once_a_clue() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var cop: Cop = store.get_node("Cop")
	rig.crooked.push(cop)
	var yaw := cop.global_rotation.y
	cop.velocity = Vector3(0, 0, -2)
	rig._physics_process(0.5)
	assert_almost_eq(cop.global_rotation.y - yaw, rig.PULL * 0.5, 0.001, "it pulls to one side")
	assert_eq(rig.clinks, 1)
	assert_has(store.raid.clues_found, tr("SUPER_CARTS_CLUE"))
	var clues: int = store.raid.clues_found.size()
	rig._physics_process(2.1)
	assert_eq(rig.clinks, 2, "it keeps clinking")
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_a_straight_cart_or_a_still_one_does_nothing() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var cop: Cop = store.get_node("Cop")
	var straight: ShoppingCart = store.carts[(store.case_seed + 1) % store.carts.size()]
	straight.push(cop)
	cop.velocity = Vector3(0, 0, -2)
	rig._physics_process(0.5)
	assert_eq(rig.clinks, 0, "another cart rolls straight")
	straight.park()
	rig.crooked.push(cop)
	cop.velocity = Vector3.ZERO
	rig._physics_process(0.5)
	assert_eq(rig.clinks, 0, "standing still it's quiet")


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_SUPER_CARTS_B", "BRIEF_SUPER_CARTS_C", "BRIEF_SUPER_CARTS_D", "OBJ_FIND_DOUBLE_CART",
			"OBJ_EXTRA_WELDER", "OBJ_EXTRA_CART_PLAN", "LALO_CLUE_super_carts", "SUPER_CARTS_CLUE", "SUPER_CARTS_CLINK"]:
		assert_ne(tr(key), key)
