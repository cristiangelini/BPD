extends GutTest

## The tools for sale and Tobías's bill (docs/diseno/ferreteria.md, step 3).

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store() -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.get_node("Cop").input_enabled = false
	add_child_autofree(store)
	return store


## The cop, in the shop in front of the counter, holding the first tool of the first gondola.
func _hold_a_tool(store: HardwareStore) -> Merchandise:
	var cop: Cop = store.get_node("Cop")
	cop.global_position = Vector3(-2.0, HardwareStore.FLOOR_TOP + 0.1, 4.2)
	var item := store.merchandise[0]
	item.global_position = cop.global_position + Vector3(0, 1.0, -0.8)
	cop.get_node("Grabber").grab(item)
	return item


func test_the_tools_lie_on_the_gondolas() -> void:
	var store := _store()
	await wait_seconds(1.0)
	assert_eq(store.merchandise.size(), 24)
	for item: Merchandise in store.merchandise:
		assert_lt(item.global_position.distance_to(item.home), 0.1, "%s stays on its board" % item.name)
		assert_true(item.is_home())
	assert_eq(store.bill, 0)
	assert_eq(store.fines, 0)


func test_a_tool_he_sees_in_a_hand_goes_on_the_bill() -> void:
	var store := _store()
	await wait_physics_frames(10)
	var item := _hold_a_tool(store)
	await wait_seconds(1.0)
	assert_false(item.charged, "not yet")
	await wait_seconds(Merchandise.SEEN_TO_CHARGE)
	assert_true(item.charged)
	assert_eq(store.bill, 1)
	assert_eq(store.fines, Merchandise.PRICE)
	assert_eq(store.tobias.complaint, 0.0, "it's a sale, not a complaint")


func test_putting_it_back_takes_it_off_the_bill() -> void:
	var store := _store()
	await wait_physics_frames(10)
	var item := _hold_a_tool(store)
	await wait_seconds(Merchandise.SEEN_TO_CHARGE + 0.5)
	assert_true(item.charged)
	store.get_node("Cop").get_node("Grabber").release()
	item.linear_velocity = Vector3.ZERO
	item.global_position = item.home
	item.rotation = Vector3(0, PI / 2, 0)
	await wait_physics_frames(5)
	assert_false(item.charged)
	assert_eq(store.bill, 0)
	assert_eq(store.fines, 0)


func test_nothing_goes_on_the_bill_while_he_looks_for_the_screw() -> void:
	var store := _store()
	await wait_physics_frames(10)
	assert_true(store.tobias.look_for_screw())
	var item := _hold_a_tool(store)
	await wait_seconds(Merchandise.SEEN_TO_CHARGE + 0.5)
	assert_false(item.charged, "his back is turned")
	assert_eq(store.fines, 0)
