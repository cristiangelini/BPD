extends GutTest

## Brotecito and the watering can (docs/diseno/allanamiento-vivero.md, step 5): the tap fills the can when it's
## close, the can spills if it tips, if its cop falls or if the Dentuda bites, and Brotecito tells what he saw to
## whoever brings it to him full, once per cop.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery() -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.case_seed = 5
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func test_the_tap_fills_the_can_only_when_close() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var can := nursery.can
	nursery.tap.use(nursery.get_node("Cop"))
	assert_false(can.full, "too far from the tap")
	can.global_position = nursery.to_global(Nursery.TAP_AT + Vector3(-0.6, 0.8, 0))
	nursery.fill_at_tap()
	assert_true(can.full)
	for key: String in ["PROMPT_NURSERY_TAP", "PROMPT_BROTECITO", "HINT_NURSERY_CAN_FULL", "HINT_NURSERY_TAP_NO_CAN",
			"HINT_NURSERY_CAN_SPILLED", "BROTECITO_ASK", "BROTECITO_AGAIN", "BROTECITO_THANKS", "BROTECITO_NOTHING",
			"BROTECITO_IDLE_1", "BROTECITO_IDLE_2", "BROTECITO_IDLE_3"]:
		assert_ne(tr(key), key, key)


func test_it_spills_when_tipped() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var can := nursery.can
	can.fill()
	await wait_physics_frames(3)
	assert_true(can.full, "upright it keeps the water")
	watch_signals(can)
	can.rotation = Vector3(0, 0, PI / 2)
	await wait_physics_frames(2)
	assert_false(can.full)
	assert_signal_emitted(can, "spilled")


func test_it_spills_when_its_cop_falls() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var cop: Cop = nursery.get_node("Cop")
	var can := nursery.can
	cop.get_node("Grabber").grab(can)
	can.fill()
	await wait_physics_frames(3)
	assert_true(can.full)
	cop.knock_back(Vector3(3, 0, 0), 1.0)
	await wait_physics_frames(2)
	assert_false(can.full, "a cop who falls spills it")


func test_the_dentuda_spills_it() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	nursery.dentuda.set_physics_process(false)
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.to_global(Vector3(6.5, Nursery.FLOOR_TOP, 0.0))
	var can := nursery.can
	cop.get_node("Grabber").grab(can)
	can.fill()
	nursery.dentuda.bite(cop)
	assert_false(can.full)
	assert_eq(can.spills, 1)


func test_brotecito_tells_whoever_brings_it_full_once() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var kid := nursery.kid
	kid.clue = "clue line"
	kid.clue_speech = "what he saw"
	var cop: Cop = nursery.get_node("Cop")
	var grabber: Grabber = cop.get_node("Grabber")
	var can := nursery.can
	watch_signals(kid)
	grabber.grab(can)
	kid.take(can)
	assert_signal_not_emitted(kid, "told", "an empty can is no gift")
	can.fill()
	kid.take(can)
	assert_signal_emitted_with_parameters(kid, "told", ["clue line"])
	assert_false(can.full, "he waters with it")
	assert_eq(can.spills, 0, "watering isn't spilling")
	can.fill()
	kid.take(can)
	assert_signal_emit_count(kid, "told", 1, "once per cop")
	assert_eq(kid.cans_brought, 2)


func test_a_full_can_close_to_him_is_his() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var can := nursery.can
	can.global_position = nursery.kid.global_position + Vector3(0.5, 0.6, 0)
	can.fill()
	await wait_physics_frames(2)
	assert_eq(nursery.kid.cans_brought, 1)
	assert_false(can.full)
