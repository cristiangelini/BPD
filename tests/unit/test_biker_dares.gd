extends GutTest

## The biker bar's courage dares (infiltracion-motos.md, step 4, decision 176): a biker dares a cop to arm wrestle, to
## lift the heavy bike or to stand still on the line; not showing up, failing or walking off make the bikers
## suspicious, passing pleases them, and while a dare is on the bikers out of the patio watch it.

const LEVEL := preload("res://scenes/levels/biker_bar.tscn")

var bar: BikerBar
var cop: Cop
var dares: BikerDares


func before_each() -> void:
	bar = LEVEL.instantiate()
	cop = bar.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bar)
	await wait_physics_frames(2)
	dares = bar.dares
	dares.set_physics_process(false)


func _step(seconds: float) -> void:
	var left := seconds
	while left > 0.0:
		dares._physics_process(minf(left, 0.1))
		left -= 0.1


func _bikers_suspicion() -> float:
	var total := 0.0
	for member in bar.members:
		total += member.suspicion
	return total


## The cop dared to `kind` (the next ones skipped until it comes up).
func _dare(kind: String) -> void:
	while dares.order[dares.next_kind % dares.order.size()] != kind:
		dares.next_kind += 1
	assert_true(dares.challenge(cop))


## The cop at the dare's place, and the dare on.
func _go() -> void:
	cop.global_position = dares.spot() + Vector3(0, 0.1, 0)
	_step(0.1)


func test_the_seed_orders_the_three_kinds() -> void:
	assert_eq(dares.order.size(), 3)
	for kind: String in BikerDares.KINDS:
		assert_has(dares.order, kind)


func test_the_first_dare_comes_after_a_while_to_a_cop_in_the_bar() -> void:
	cop.global_position = bar.global_transform * Vector3(-4.0, 0.1, 5.0)
	watch_signals(dares)
	_step(BikerDares.FIRST - 1.0)
	assert_signal_not_emitted(dares, "challenged")
	_step(1.5)
	assert_signal_emitted(dares, "challenged")
	assert_eq(dares.challenger.said(), "BIKER_DARE_" + dares.kind)


func test_no_cop_in_the_bar_no_dare() -> void:
	assert_false(dares.challenge())
	assert_eq(dares.state, BikerDares.IDLE)


func test_not_showing_up_is_chicken() -> void:
	_dare("arm")
	watch_signals(dares)
	_step(BikerDares.JOIN + 0.5)
	assert_signal_emitted_with_parameters(dares, "failed", [BikerDares.NO_SHOW])
	assert_eq(dares.challenger.said(), "BIKER_CHICKEN")
	assert_gt(_bikers_suspicion(), 0.0)


func test_arm_wrestling_with_enough_pushes_passes() -> void:
	_dare("arm")
	_go()
	assert_eq(dares.state, BikerDares.DOING)
	assert_true(bar.arm_table.is_wrestling(), "the arms on the table")
	watch_signals(dares)
	for i in BikerDares.ARM_PUSHES:
		bar.arm_table.use(cop)
	assert_signal_emitted_with_parameters(dares, "passed", ["arm"])
	assert_eq(dares.challenger.said(), dares.tip(), "a hint about evidence still missing")
	assert_string_starts_with(dares.tip(), "BIKER_TIP_")
	assert_false(bar.arm_table.is_wrestling())
	assert_eq(_bikers_suspicion(), 0.0)


func test_arm_wrestling_too_slowly_loses() -> void:
	_dare("arm")
	_go()
	bar.arm_table.use(cop)
	watch_signals(dares)
	_step(BikerDares.ARM_TIME + 0.2)
	assert_signal_emitted_with_parameters(dares, "failed", [BikerDares.FAIL])
	assert_eq(dares.challenger.said(), "BIKER_ARM_LOST")


func test_the_arms_lean_toward_the_biker_as_time_goes_by() -> void:
	_dare("arm")
	_go()
	_step(2.0)
	assert_lt(bar.arm_table.lean, 0.0, "no pushes: the biker wins")
	for i in 10:
		bar.arm_table.use(cop)
	_step(0.1)
	assert_gt(bar.arm_table.lean, 0.0, "pushing: the cop wins")


func test_lifting_the_bike_long_enough_passes() -> void:
	_dare("lift")
	_go()
	watch_signals(dares)
	bar.heavy_bike.freeze = true
	bar.heavy_bike.position.y += HeavyBike.LIFT + 0.2
	_step(BikerDares.LIFT_HOLD + 0.2)
	assert_signal_emitted_with_parameters(dares, "passed", ["lift"])


func test_not_lifting_the_bike_fails() -> void:
	_dare("lift")
	_go()
	watch_signals(dares)
	_step(BikerDares.LIFT_TIME + 0.2)
	assert_signal_emitted_with_parameters(dares, "failed", [BikerDares.FAIL])
	assert_eq(dares.challenger.said(), "BIKER_LIFT_FAILED")


func test_standing_still_while_the_bike_brakes_passes() -> void:
	_dare("still")
	_go()
	assert_true(bar.charge.charging, "off he goes")
	watch_signals(dares)
	for i in 120:
		bar.charge._physics_process(1.0 / 60.0)
		_step(1.0 / 60.0)
	assert_signal_emitted_with_parameters(dares, "passed", ["still"])
	assert_eq(bar.charge.position, bar.charge.start, "back at the start")


func test_moving_off_the_line_fails() -> void:
	_dare("still")
	_go()
	watch_signals(dares)
	cop.global_position += bar.global_basis.z * (BikerDares.MOVE_REACH + 0.3)
	_step(0.1)
	assert_signal_emitted_with_parameters(dares, "failed", [BikerDares.FAIL])
	assert_eq(dares.challenger.said(), "BIKER_MOVED")


func test_walking_off_in_the_middle_is_chicken() -> void:
	_dare("arm")
	_go()
	watch_signals(dares)
	cop.global_position = bar.global_transform * Vector3(-4.0, 0.1, 5.0)
	_step(0.1)
	assert_signal_emitted_with_parameters(dares, "failed", [BikerDares.NO_SHOW])


func test_the_bikers_out_of_the_patio_watch_the_dare() -> void:
	_dare("arm")
	_go()
	for member in bar.members:
		var in_patio := bar.in_patio(member.global_position + Vector3.UP)
		assert_eq(member.distracted, not in_patio, "out of the patio they're watching it")
	for i in BikerDares.ARM_PUSHES:
		bar.arm_table.use(cop)
	for member in bar.members:
		assert_false(member.distracted, "back to normal after it")


func test_the_dare_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["BIKER_CHICKEN", "BIKER_ARM_LOST", "BIKER_LIFT_FAILED", "BIKER_MOVED", "BIKER_RESPECT"]
	for kind: String in BikerDares.KINDS:
		keys.append("BIKER_DARE_" + kind)
		keys.append("HINT_BIKER_DARE_" + kind)
	for key in keys:
		assert_ne(tr(key), key)
