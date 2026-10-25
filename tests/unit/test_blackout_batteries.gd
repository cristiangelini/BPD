extends GutTest

## The blackout's flashlights run on batteries, and spare ones lie around (carcel-corte-de-luz.md, step 8).

const LEVEL := preload("res://scenes/levels/prison_blackout.tscn")

var prison: PrisonLevel
var cop: Cop
var light: Flashlight


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	light = cop.belt.flashlight


func _batteries() -> Array[Node]:
	return get_tree().get_nodes_in_group("blackout_batteries").filter(func(battery: Node) -> bool:
		return prison.is_ancestor_of(battery) and not battery.is_queued_for_deletion())


func test_the_flashlight_starts_with_a_full_battery() -> void:
	assert_eq(light.battery, Flashlight.BATTERY_FULL)


func test_it_only_drains_while_on() -> void:
	light._process(5.0)
	assert_eq(light.battery, Flashlight.BATTERY_FULL)
	light.toggle()
	light._process(5.0)
	assert_almost_eq(light.battery, Flashlight.BATTERY_FULL - 5.0, 0.001)


func test_it_dims_near_the_end() -> void:
	light.toggle()
	light._process(Flashlight.BATTERY_FULL - Flashlight.BATTERY_LOW / 2)
	assert_lt(light.light.light_energy, Flashlight.ENERGY)
	assert_eq(cop._hint.text, "HINT_FLASHLIGHT_LOW")


func test_a_flat_one_goes_out_and_wont_turn_on() -> void:
	light.toggle()
	light._process(Flashlight.BATTERY_FULL + 1.0)
	assert_true(light.is_flat())
	assert_false(light.is_on)
	assert_false(light.light.visible)
	assert_eq(light.prompt_key(), "PROMPT_FLASHLIGHT_FLAT")
	light.toggle()
	assert_false(light.is_on, "no battery, no light")
	assert_eq(cop._hint.text, "HINT_FLASHLIGHT_FLAT")


func test_a_flat_flashlight_freezes_nobody() -> void:
	light.toggle()
	light._process(Flashlight.BATTERY_FULL + 1.0)
	assert_false(light.reaches(light.global_position - light.global_basis.z * 3.0))


func test_spare_batteries_in_the_kitchen_and_around() -> void:
	var batteries := _batteries()
	assert_eq(batteries.size(), BlackoutPlan.KITCHEN_SPOTS.size() + BlackoutPlan.LOOSE_BATTERIES)
	var in_kitchen := batteries.filter(func(battery: Node3D) -> bool:
		var local := prison.global_transform.affine_inverse() * battery.global_position
		return local.x > PrisonLevel.KITCHEN_X)
	assert_eq(in_kitchen.size(), BlackoutPlan.KITCHEN_SPOTS.size())


func test_e_with_a_battery_fills_it_again() -> void:
	light.toggle()
	light._process(Flashlight.BATTERY_FULL + 1.0)
	var battery: FlashlightBattery = _batteries()[0]
	cop.get_node("Grabber").grab(battery)
	assert_eq(cop.current_prompt(), "PROMPT_CHANGE_BATTERY")
	assert_true(cop.use())
	assert_eq(light.battery, Flashlight.BATTERY_FULL)
	assert_null(cop.get_node("Grabber").held)
	assert_true(battery.is_queued_for_deletion(), "the old battery is gone")
	assert_eq(cop._hint.text, "HINT_BATTERY_CHANGED")
	light.toggle()
	assert_true(light.is_on)


func test_other_cases_never_run_out() -> void:
	var flashlight := Flashlight.new()
	add_child_autofree(flashlight)
	flashlight.toggle()
	flashlight._process(Flashlight.BATTERY_FULL * 3)
	assert_true(flashlight.is_on)
	assert_lt(flashlight.battery, 0.0)
