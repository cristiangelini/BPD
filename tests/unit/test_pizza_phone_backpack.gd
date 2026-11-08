extends GutTest

## The pizzeria raid with the phones in the backpack story (allanamiento-pizzeria.md, step 6): the thermal backpack of
## stolen phones and its extras hidden with the seed, the orders notebook with addresses that don't exist, and the
## phones that all ring at once, showing where the backpack is.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria() -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.story_id = "phone_backpack"
	pizzeria.case_seed = 5
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


func test_the_backpack_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	assert_has(pizzeria.raid.suspicions, "phone_backpack")
	assert_almost_eq((pizzeria.main as RigidBody3D).mass, 4.0, 0.01)
	assert_almost_eq((pizzeria.main as Evidence).full_value, 1000.0, 0.01)
	assert_true(PizzaRaid.SPOTS[pizzeria.hidden_spots[0]].heavy)
	assert_eq(pizzeria.extras.size(), 2, "the chargers and the fake orders")


func test_the_orders_notebook_on_the_counter_is_a_clue() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var notebook := (pizzeria.rig as PhoneBackpackRig).notebook
	assert_lt(pizzeria.to_local(notebook.global_position).distance_to(PhoneBackpackRig.NOTEBOOK_AT), 0.2, "on the counter")
	notebook.use(pizzeria.get_node("Cop"))
	assert_has(pizzeria.raid.clues_found, tr("CLUE_ORDERS_NOTEBOOK"))


func test_the_phones_ring_over_the_backpack_for_a_while() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as PhoneBackpackRig
	assert_false(rig.ring_label.visible, "quiet at first")
	rig.since_rang = PhoneBackpackRig.RING_EVERY - 0.05
	await wait_physics_frames(6)
	assert_eq(rig.rings, 1, "they rang after RING_EVERY")
	assert_true(rig.ring_label.visible)
	var over := rig.ring_label.global_position - pizzeria.main.global_position
	assert_lt(Vector2(over.x, over.z).length(), 0.05, "right over the backpack")
	assert_gt(over.y, 0.5)
	await wait_seconds(PhoneBackpackRig.RING_SHOW + 0.3)
	assert_false(rig.ring_label.visible, "gone after RING_SHOW")


func test_the_ring_follows_the_backpack_when_it_moves() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as PhoneBackpackRig
	rig.ring()
	(pizzeria.main as RigidBody3D).freeze = true
	pizzeria.main.global_position = pizzeria.to_global(Vector3(0, 1.0, 4.0))
	await wait_physics_frames(2)
	var over := rig.ring_label.global_position - pizzeria.main.global_position
	assert_lt(Vector2(over.x, over.z).length(), 0.05)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_PHONES_B", "BRIEF_PHONES_C", "BRIEF_PHONES_D", "OBJ_FIND_THERMAL_BACKPACK",
			"OBJ_EXTRA_CHARGERS_BOX", "OBJ_EXTRA_FAKE_ORDERS", "TITO_CLUE_phone_backpack", "PROMPT_ORDERS_NOTEBOOK",
			"CLUE_ORDERS_NOTEBOOK", "PHONES_RIIING"]:
		assert_ne(tr(key), key)
