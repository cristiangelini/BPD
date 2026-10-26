extends GutTest

## The biker bar's patio (infiltracion-motos.md, step 3, decision 176): the arm-wrestling table where E is a push and
## the clasped arms lean toward who is winning, the heavy bike that one cop can't lift and two can, and the "don't
## move" lane where a biker charges at the line and brakes a meter before it.

const LEVEL := preload("res://scenes/levels/biker_bar.tscn")

var bar: BikerBar
var cop: Cop


func before_each() -> void:
	bar = LEVEL.instantiate()
	cop = bar.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bar)
	await wait_physics_frames(2)


func test_the_three_dares_are_in_the_patio() -> void:
	assert_true(bar.in_patio(bar.arm_table.global_position + Vector3.UP))
	assert_true(bar.in_patio(bar.heavy_bike.global_position + Vector3.UP))
	assert_true(bar.in_patio(bar.charge.global_position + Vector3.UP))
	assert_true(bar.in_patio(bar.global_transform * bar.line_at() + Vector3.UP), "the line too")


func test_e_on_the_table_is_a_push() -> void:
	watch_signals(bar.arm_table)
	assert_eq(bar.arm_table.prompt_key(cop), "PROMPT_BIKER_ARM")
	bar.arm_table.use(cop)
	assert_signal_emitted_with_parameters(bar.arm_table, "pushed", [cop])


func test_the_arms_lean_toward_who_is_winning() -> void:
	assert_false(bar.arm_table.is_wrestling(), "no arms until someone wrestles")
	bar.arm_table.set_wrestling(true)
	assert_true(bar.arm_table.is_wrestling())
	bar.arm_table.set_lean(2.0)
	assert_eq(bar.arm_table.lean, 1.0, "the cop wins, no further")
	assert_almost_eq(bar.arm_table.get_node("Arms").rotation.x, ArmTable.MAX_LEAN, 0.001)
	bar.arm_table.set_lean(-0.5)
	assert_lt(bar.arm_table.get_node("Arms").rotation.x, 0.0, "toward the biker")


func test_one_cop_cant_lift_the_heavy_bike_and_two_can() -> void:
	assert_gt(HeavyBike.KG, Grabbable.max_force_per_holder() / GameScale.GRAVITY, "too heavy for one")
	assert_lt(HeavyBike.KG, 2.0 * Grabbable.max_force_per_holder() / GameScale.GRAVITY, "but not for two")
	assert_false(bar.heavy_bike.lifted(), "resting on the floor")
	bar.heavy_bike.position.y += HeavyBike.LIFT + 0.1
	assert_true(bar.heavy_bike.lifted())


func test_the_biker_charges_and_brakes_before_the_line() -> void:
	var start := bar.charge.position
	watch_signals(bar.charge)
	bar.charge.charge()
	assert_true(bar.charge.charging)
	for i in 120:
		bar.charge._physics_process(1.0 / 60.0)
	assert_signal_emitted(bar.charge, "braked")
	assert_false(bar.charge.charging)
	var left := bar.charge.line_at().distance_to(bar.charge.position)
	assert_almost_eq(left, DareCharge.STOP_SHORT, 0.01, "a meter short of the line")
	bar.charge.back()
	assert_eq(bar.charge.position, start)


func test_the_patio_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	assert_ne(tr("PROMPT_BIKER_ARM"), "PROMPT_BIKER_ARM")
