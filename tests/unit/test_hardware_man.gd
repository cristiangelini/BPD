extends GutTest

## Tobías, the counter bell and his complaint meter (docs/diseno/ferreteria.md, step 2).

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store() -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.get_node("Cop").input_enabled = false
	add_child_autofree(store)
	return store


func test_tobias_serves_behind_his_counter() -> void:
	var store := _store()
	await wait_seconds(1.0)
	var at := store.tobias.global_position
	var post := HardwareStore.TOBIAS_POST
	assert_lt(Vector2(at.x - post.x, at.z - post.z).length(), 0.05, "he doesn't leave it")
	assert_almost_eq(at.y, HardwareStore.FLOOR_TOP, 0.05, "standing on the floor")


func test_he_sees_a_jar_break_on_his_counter() -> void:
	var store := _store()
	await wait_physics_frames(30)
	store.jars[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(store.tobias.complaint, HardwareMan.SAW_BREAK)
	assert_eq(store.fines, Ornament.FINE)


func test_a_rammed_door_reaches_him() -> void:
	var store := _store()
	await wait_physics_frames(2)
	store.back_door.broken.emit()
	assert_eq(store.tobias.complaint, HardwareMan.DOOR_BROKEN)


func test_the_bell_sends_him_to_the_screw_wall_and_he_stops_watching() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(30)
	assert_eq(store.bell.prompt_key(cop), "PROMPT_SCREW_BELL")
	store.bell.use(cop)
	assert_true(store.tobias.is_searching())
	assert_eq(store.bell.prompt_key(cop), "", "nothing to ask while he looks")
	await wait_physics_frames(10)
	# Models face +Z (look_at with use_model_front).
	var facing := store.tobias.global_basis.z
	var to_wall := (HardwareStore.SCREW_WALL_AT - store.tobias.global_position) * Vector3(1, 0, 1)
	assert_gt(facing.dot(to_wall.normalized()), 0.9, "he turns to the screw wall")
	store.jars[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(store.tobias.complaint, 0.0, "his back is turned")
	assert_eq(store.fines, Ornament.FINE, "a fine anyway")


func test_the_search_ends_and_he_needs_a_rest() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	store.bell.use(cop)
	store.tobias._search_left = 0.05
	await wait_physics_frames(10)
	assert_false(store.tobias.is_searching(), "there are none left")
	assert_false(store.tobias.look_for_screw(), "he just looked")
	store.tobias._search_wait = 0.0
	assert_true(store.tobias.look_for_screw(), "he looks again after a while")


func test_a_push_ends_the_search() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_true(store.tobias.look_for_screw())
	assert_true(store.tobias.struck())
	assert_false(store.tobias.is_searching())
	assert_eq(store.tobias.complaint, HardwareMan.STRUCK)


func test_questions_let_two_things_slip_then_he_is_offended() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	store.tobias.slips.clear()
	assert_false(store.tobias.ask(cop), "nothing to say without a story")
	store.tobias.slips.assign(["a", "b", "c"])
	var said: Array[String] = []
	store.tobias.slipped.connect(func(text: String) -> void: said.append(text))
	assert_true(store.tobias.ask(cop))
	store.tobias._ask_wait = 0.0
	assert_true(store.tobias.ask(cop))
	store.tobias._ask_wait = 0.0
	assert_false(store.tobias.ask(cop), "offended after two")
	assert_eq(said, ["a", "b"] as Array[String])
	assert_eq(store.tobias.complaint, HardwareMan.ASKED * 2)


func test_at_100_he_calls_his_lawyer_and_the_case_is_lost() -> void:
	var store := _store()
	await wait_physics_frames(2)
	for i in 7:
		store.tobias._since_struck = HardwareMan.STRUCK_COOLDOWN
		store.tobias.struck()
	assert_true(store.tobias.has_called_lawyer)
	assert_true(store.raid.case_failed)
