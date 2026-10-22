extends GutTest

## The jailbreak, step 2 (fuga.md): the night guard eats a donut from his box every 40 s, and one has the key.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const BOX_SCENE := preload("res://scenes/props/guard_donut_box.tscn")


func _guard(case_seed := 7) -> NightGuard:
	var box: DonutBox = BOX_SCENE.instantiate()
	box.freeze = true
	add_child_autofree(box)
	var guard := NightGuard.new()
	add_child_autofree(guard)
	box.global_position = guard.global_position + Vector3(0, 0.9, -0.8)
	guard.setup(case_seed, box)
	return guard


func test_the_box_has_six_donuts() -> void:
	var box: DonutBox = BOX_SCENE.instantiate()
	add_child_autofree(box)
	assert_eq(box.donuts, 6)
	assert_not_null(box.find_child("donut_5", true, false), "a part per donut")


func test_the_seed_picks_the_key_donut() -> void:
	var seen := {}
	for case_seed in 40:
		var guard := _guard(case_seed + 1)
		assert_between(guard.key_donut, 0, 5)
		assert_eq(guard.key_donut, _guard(case_seed + 1).key_donut, "same seed, same donut")
		seen[guard.key_donut] = true
	assert_gt(seen.size(), 3, "different seeds, different donuts")


func test_he_eats_one_every_forty_seconds() -> void:
	var guard := _guard()
	guard.key_donut = 0
	for i in roundi(NightGuard.EAT_EVERY * 10) - 1:
		guard._physics_process(0.1)
	assert_eq(guard.box.donuts, 6, "not yet")
	guard._physics_process(0.2)
	assert_eq(guard.box.donuts, 5)
	assert_true(guard.said().begins_with("GUARD_MUNCH_"))


func test_eating_the_key_donut_puts_the_key_on_his_belt() -> void:
	var guard := _guard()
	guard.key_donut = 4
	watch_signals(guard)
	guard.eat()
	assert_false(guard.key_on_belt, "donut 5 had nothing")
	assert_true(guard.key_in_box())
	guard.eat()
	assert_true(guard.key_on_belt)
	assert_false(guard.key_in_box())
	assert_eq(guard.said(), "GUARD_KEY_FOUND")
	assert_signal_emitted(guard, "found_key")


func test_he_complains_when_the_box_is_gone() -> void:
	var guard := _guard()
	guard.box.global_position += Vector3(0, 0, -3)
	guard.eat()
	assert_eq(guard.box.donuts, 6, "out of his reach he can't eat")
	assert_eq(guard.said(), "GUARD_NO_DONUTS")


func test_a_guest_shows_the_same_box_belt_suspicion_and_sleep() -> void:
	var guard := _guard()
	guard.apply_net_state([3, true, 40.0, 1, 0.6, 5.0, "escaped"])
	assert_eq(guard.box.donuts, 3)
	assert_true(guard.key_on_belt)
	assert_false(guard.box.find_child("donut_4", true, false).visible, "eaten donuts are gone")
	assert_eq(guard.suspicion, 40.0)
	assert_eq(guard.times_caught, 1)
	assert_almost_eq(guard._model.rotation.y, 0.6, 0.001, "his head turned the same way")
	assert_true(guard.is_asleep(), "asleep too")
	assert_eq(guard.outcome, "escaped", "and how it ended")
	assert_eq(guard.net_state(), [3, true, 40.0, 1, 0.6, 5.0, "escaped"])


func test_the_guard_sits_in_front_of_the_cells_with_the_box_in_reach() -> void:
	var level: Node3D = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(10)
	var guard: NightGuard = level.guard
	assert_not_null(guard)
	assert_true(guard.box_in_reach(), "the box is on his desk")
	assert_eq(guard.box.donuts, 6)
	var lot: Transform3D = level.city.transform * CityLayout.lot("station")
	var box_at := lot.affine_inverse() * guard.box.global_position
	assert_almost_eq(box_at.z - StationRooms.CELL_FRONT_Z, 2.75, 0.3, "about 3 m from the bars")
	assert_gt(box_at.y, 0.75, "on the desk, not on the floor")
	var facing := lot.basis.inverse() * guard.global_transform.basis.z
	assert_lt(facing.z, -0.9, "he faces the cells")
