extends GutTest

## Tito and the clay oven at the pizzeria raid (allanamiento-pizzeria.md, step 4): Tito talks once for a slice from the
## counter's tray, the oven burns what stays in its mouth (half for evidence, all of it for paper), a hand in the oven
## lets go of what it held, and Don Muzza minds seeing something put in his oven.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria() -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


func _evidence(pizzeria: PizzaRaid, kg: float) -> Evidence:
	var item := Evidence.new()
	item.collision_layer = 4
	item.collision_mask = 15
	item.mass = kg
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.2, 0.1, 0.2)
	shape.shape = box
	item.add_child(shape)
	pizzeria.add_child(item)
	return item


func _hold(cop: Cop, item: Grabbable) -> void:
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.held = item
	item.hold(grabber.get_instance_id(), item.global_position)


func test_the_texts_are_translated() -> void:
	for key: String in ["MUZZA_OVEN", "PROMPT_OVEN_HAND", "HINT_OVEN_HOT", "PROMPT_TITO", "PROMPT_TITO_SLICE",
			"TITO_WANTS_SLICE", "TITO_AGAIN", "TITO_THANKS", "TITO_NOTHING", "TITO_IDLE_1", "TITO_IDLE_3"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_tito_tells_once_for_a_slice() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	assert_eq(pizzeria.slices.size(), PizzaRaid.SLICES)
	var cop: Cop = pizzeria.get_node("Cop")
	pizzeria.tito.clue = "the bin"
	pizzeria.tito.clue_speech = "In the bin!"
	watch_signals(pizzeria.tito)
	assert_eq(pizzeria.tito.prompt_key(cop), "PROMPT_TITO")
	pizzeria.tito.use(cop)
	assert_false(pizzeria.tito.has_told, "not without a slice")
	_hold(cop, pizzeria.slices[0])
	assert_eq(pizzeria.tito.prompt_key(cop), "PROMPT_TITO_SLICE")
	pizzeria.tito.use(cop)
	assert_true(pizzeria.tito.has_told)
	assert_signal_emitted_with_parameters(pizzeria.tito, "told", ["the bin"])
	assert_null(cop.get_node("Grabber").held, "he took the slice")
	_hold(cop, pizzeria.slices[1])
	pizzeria.tito.use(cop)
	assert_signal_emit_count(pizzeria.tito, "told", 1, "only once")
	assert_eq(pizzeria.tito.get_node("Bubble").text, "TITO_THANKS")


func test_evidence_in_the_oven_burns_to_half_and_paper_burns_whole() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var box := _evidence(pizzeria, 5.0)
	var paper := _evidence(pizzeria, 0.1)
	box.position = PizzaRaid.OVEN_MOUTH + Vector3(-0.2, 0, 0)
	paper.position = PizzaRaid.OVEN_MOUTH + Vector3(0.2, 0, 0)
	await wait_seconds(1.5)
	assert_eq(box.value, box.full_value, "not yet")
	await wait_seconds(2.0)
	assert_almost_eq(box.value, box.full_value * PizzaOven.BURN_SHARE, 1.0)
	assert_true(paper.is_broken, "paper burns whole")
	await wait_seconds(3.5)
	assert_almost_eq(box.value, box.full_value * PizzaOven.BURN_SHARE, 1.0, "it burns once")


func test_something_left_out_of_the_oven_does_not_burn() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var box := _evidence(pizzeria, 5.0)
	box.position = PizzaRaid.OVEN_AT + Vector3(2.0, 0.2, 2.0)
	await wait_seconds(3.5)
	assert_eq(box.value, box.full_value)


func test_a_hand_in_the_oven_lets_go() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var cop: Cop = pizzeria.get_node("Cop")
	_hold(cop, pizzeria.slices[0])
	pizzeria.oven.button.pressed.emit(cop)
	assert_null(cop.get_node("Grabber").held)


func test_don_muzza_minds_seeing_something_put_in_his_oven() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	pizzeria.muzza.global_position = pizzeria.to_global(Vector3(-3.0, PizzaRaid.FLOOR_TOP, 0.8))
	var route: Array[Vector3] = [Vector3(-3.0, PizzaRaid.FLOOR_TOP, 0.8), Vector3(-3.0, PizzaRaid.FLOOR_TOP, 0.9)]
	pizzeria.muzza.route = route
	pizzeria.muzza.start_at(0)
	await wait_physics_frames(2)
	var cop: Cop = pizzeria.get_node("Cop")
	var box := _evidence(pizzeria, 5.0)
	box.position = PizzaRaid.OVEN_MOUTH + Vector3(0, 0.6, 0.8)
	_hold(cop, box)
	cop.get_node("Grabber").release()
	box.position = PizzaRaid.OVEN_MOUTH
	await wait_physics_frames(4)
	assert_eq(pizzeria.muzza.complaint, PizzaRaid.SAW_OVEN)
	assert_eq(pizzeria.muzza.get_node("Bubble").text, "MUZZA_OVEN")
