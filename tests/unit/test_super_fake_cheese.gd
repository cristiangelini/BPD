extends GutTest

## The supermarket's fake cheese story (allanamiento-super.md, step 6): the 25 kg plastic wheel full of bills hidden with
## its mold and the wax, and the cheese wheels on the table by the fridge, one of them plastic: it bounces, and the first bounce is
## the clue.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super(case_seed := 5) -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.story_id = "super_cheese"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_big_wheel_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "super_cheese")
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq((store.main as RigidBody3D).mass, 25.0, 0.01)
	assert_true(Supermarket.SPOTS[store.hidden_spots[0]].heavy)
	assert_eq(store.extras.size(), 2)


func test_the_wheels_lie_on_the_cheese_table_and_stay() -> void:
	var store := _super()
	var rig := store.rig
	assert_eq(rig.wheels.size(), 4)
	await wait_physics_frames(60)
	for wheel: Grabbable in rig.wheels:
		assert_gt(store.to_local(wheel.global_position).y, Supermarket.FLOOR_TOP + 0.8, wheel.name)
	assert_eq(rig.bounces, 0, "lying there, nothing bounces")


func test_dropped_the_plastic_one_bounces_and_the_first_time_is_a_clue() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var wheel: Grabbable = rig.wheels[rig.bouncy]
	wheel.global_position = store.to_global(Vector3(-6.0, 2.5, -8.0))
	wheel.linear_velocity = Vector3.ZERO
	await wait_physics_frames(90)
	assert_gt(rig.bounces, 0, "it bounced")
	assert_has(store.raid.clues_found, tr("SUPER_CHEESE_CLUE"))
	var clues: int = store.raid.clues_found.size()
	rig.bounced()
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_a_real_wheel_dropped_doesnt_bounce() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var real: Grabbable = rig.wheels[(rig.bouncy + 1) % rig.wheels.size()]
	real.global_position = store.to_global(Vector3(-6.0, 2.5, -8.0))
	await wait_physics_frames(90)
	assert_eq(rig.bounces, 0)


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_SUPER_CHEESE_B", "BRIEF_SUPER_CHEESE_C", "BRIEF_SUPER_CHEESE_D", "OBJ_FIND_FAKE_CHEESE",
			"OBJ_EXTRA_CHEESE_MOLD", "OBJ_EXTRA_WAX_BLOCK", "LALO_CLUE_super_cheese", "SUPER_CHEESE_CLUE"]:
		assert_ne(tr(key), key)
