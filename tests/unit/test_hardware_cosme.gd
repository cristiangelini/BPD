extends GutTest

## Don Cosme and the key machine (docs/diseno/ferreteria.md, step 4).

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store() -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.get_node("Cop").input_enabled = false
	add_child_autofree(store)
	return store


func _file_the_key(store: HardwareStore, cop: Cop) -> void:
	for i in KeyMachine.PRESSES:
		store.key_machine.use(cop)


func test_the_machine_waits_for_him_to_ask() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	assert_eq(store.key_machine.prompt_key(cop), "", "nobody asked for a copy yet")
	store.key_machine.use(cop)
	assert_eq(store.key_machine.presses, 0)
	store.cosme.use(cop)
	assert_true(store.cosme.was_asked)
	assert_eq(store.key_machine.prompt_key(cop), "PROMPT_KEY_MACHINE")


func test_four_passes_drop_the_new_key_on_the_counter() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	store.cosme.use(cop)
	store.key_machine.use(cop)
	assert_null(store.key_machine.key, "one pass isn't enough")
	_file_the_key(store, cop)
	assert_true(store.key_machine.is_done())
	assert_not_null(store.key_machine.key)
	await wait_seconds(1.0)
	var key := store.key_machine.key
	assert_true(is_instance_valid(key), "it lies on the counter: Don Cosme is too far to grab it")
	assert_almost_eq(key.global_position.y, HardwareStore.FLOOR_TOP + HardwareStore.COUNTER_SIZE.y, 0.05)
	assert_false(store.cosme.served)
	assert_eq(store.key_machine.prompt_key(cop), "", "done")


func test_tobias_complains_about_his_machine_unless_he_looks_away() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(10)
	store.cosme.use(cop)
	store.key_machine.use(cop)
	assert_eq(store.tobias.complaint, KeyMachine.SEEN_PRESS)
	assert_true(store.tobias.look_for_screw())
	store.key_machine.use(cop)
	assert_eq(store.tobias.complaint, KeyMachine.SEEN_PRESS, "his back is turned")


func test_bringing_him_the_key_gets_what_he_saw() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(2)
	store.cosme.clue = "the clue"
	var told: Array[String] = []
	store.cosme.told.connect(func(text: String) -> void: told.append(text))
	store.cosme.use(cop)
	_file_the_key(store, cop)
	var key := store.key_machine.key
	key.global_position = store.cosme.to_global(Vector3(0, 0.9, 0.3))
	await wait_physics_frames(5)
	assert_true(store.cosme.served)
	assert_eq(told, ["the clue"] as Array[String])
	assert_false(is_instance_valid(key), "he pockets it")
