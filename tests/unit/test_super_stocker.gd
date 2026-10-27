extends GutTest

## Lalo, the supermarket's stocker (docs/diseno/allanamiento-super.md, step 4): three cans dropped by his hands, one at a
## time, and he tells what he saw, once per cop; his pyramid falling starts the count over.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super() -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


## A restock can, as if `cop` had just dropped it by Lalo's hands.
func _drop(store: Supermarket, cop: Cop, index: int) -> Grabbable:
	var can: Grabbable = store.get_node("RestockCan%d" % index)
	can.last_holder = cop.get_node("Grabber").get_instance_id()
	can.global_position = store.stocker.global_position + Vector3(0.6, 0.3, 0)
	return can


func test_the_store_has_lalo_and_a_crate_of_cans() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_not_null(store.stocker)
	assert_eq(store.stocker.cans(), SuperStocker.BASE_CANS)
	assert_eq(get_tree().get_nodes_in_group("super_cans").size(), Supermarket.RESTOCK_CANS + store.cans.size())


func test_three_cans_one_at_a_time_and_he_talks() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	store.stocker.clue = "the clue"
	store.stocker.clue_speech = "I saw it"
	watch_signals(store.stocker)
	for i in SuperStocker.HAND_OVER:
		_drop(store, cop, i)
		await wait_seconds(SuperStocker.TAKE_EVERY + 0.2)
	assert_eq(store.stocker.cans(), SuperStocker.BASE_CANS + SuperStocker.HAND_OVER)
	assert_signal_emitted_with_parameters(store.stocker, "told", ["the clue"])
	assert_true(store.stocker.listeners.has(cop))
	_drop(store, cop, 3)
	await wait_seconds(SuperStocker.TAKE_EVERY + 0.2)
	assert_signal_emit_count(store.stocker, "told", 1, "once per cop")


func test_a_can_nobody_dropped_doesnt_count() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var can: Grabbable = store.get_node("RestockCan0")
	can.global_position = store.stocker.global_position + Vector3(0.6, 0.3, 0)
	await wait_seconds(0.5)
	assert_true(is_instance_valid(can))
	assert_eq(store.stocker.cans(), SuperStocker.BASE_CANS)


func test_his_pyramid_falling_starts_over() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	_drop(store, cop, 0)
	await wait_seconds(SuperStocker.TAKE_EVERY + 0.2)
	assert_eq(store.stocker.handed.get(cop, 0), 1)
	cop.global_position = store.stocker.to_global(SuperStocker.PYRAMID_AT + Vector3(0, 0.1, 0))
	await wait_physics_frames(3)
	assert_eq(store.stocker.handed.get(cop, 0), 0)
	assert_eq(store.stocker.cans(), SuperStocker.BASE_CANS)


func test_e_on_him_asks_for_cans() -> void:
	var stocker := SuperStocker.new()
	add_child_autofree(stocker)
	stocker.use(null)
	assert_eq(stocker._bubble.text, "LALO_HAND_ME")
