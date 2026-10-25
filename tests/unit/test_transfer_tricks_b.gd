extends GutTest

## The inmates' sick and loose window tricks on the transfer bus (traslado-presos.md, step 3b, decision 105): sick,
## they lie in the aisle and run for the door when a cop crouches to help; at the window, they push its bars and jump
## out once the bus stands still, unless a cop stops them first.

const LEVEL := preload("res://scenes/levels/prisoner_transfer.tscn")

var level: PrisonLevel
var bus: PrisonBus
var plan: TransferPlan
var tricks: TransferTricks
var cop: Cop


func before_each() -> void:
	level = LEVEL.instantiate()
	level.case_seed = 7
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	bus = level.bus
	plan = level.transfer
	tricks = level.tricks
	cop = level.get_node("Cop")
	await wait_physics_frames(30)
	plan.started = true


func _with(trick: String) -> BusInmate:
	return plan.inmates.filter(func(inmate: BusInmate) -> bool: return tricks.trick_of(inmate) == trick)[0]


func _fill(inmate: BusInmate) -> void:
	inmate.set_plan(BusInmate.FULL - 0.01)
	bus.lurched.emit(8.0)


func _crouch_by(inmate: BusInmate, frames: int) -> void:
	bus.get_on(cop, 1)
	cop.warp(bus.global_transform * Transform3D(Basis(Vector3.UP, PI), inmate.position + Vector3(0, 0.05, -1.2)))
	for i in frames:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, true, false)
		await wait_physics_frames(1)


func test_all_four_tricks_come_up() -> void:
	var drawn := plan.inmates.map(func(inmate: BusInmate) -> String: return tricks.trick_of(inmate))
	for trick in ["spoon", "bathroom", "sick", "window"]:
		assert_has(drawn, trick)


func test_sick_they_lie_in_the_aisle_and_e_sits_them_back() -> void:
	var inmate := _with("sick")
	_fill(inmate)
	assert_true(inmate.lying)
	assert_almost_eq(inmate.position.x, 0.0, 0.01, "across the aisle")
	assert_eq(inmate.prompt_key(cop), "PROMPT_SEAT_INMATE")
	inmate.use(cop)
	assert_true(inmate.seated)
	assert_false(inmate.lying)


func test_a_cop_crouching_to_help_gets_fooled() -> void:
	var inmate := _with("sick")
	_fill(inmate)
	await _crouch_by(inmate, 30)
	assert_false(inmate.lying)
	assert_true(inmate.loose, "up and running")
	assert_eq(inmate.said(), "TRANSFER_SICK_RUN")


func test_the_window_gives_and_they_jump_out_when_the_bus_stops() -> void:
	var inmate := _with("window")
	_fill(inmate)
	assert_true(inmate.pushing)
	assert_eq(inmate.prompt_key(cop), "PROMPT_FIX_WINDOW")
	watch_signals(tricks)
	await wait_seconds(BusInmate.WINDOW_PUSH + 0.5)
	assert_true(inmate.out, "the bus stands at the station")
	assert_signal_emitted(tricks, "went_out")
	assert_has(tricks.out, inmate)
	assert_false(bus.holds(inmate.global_position))
	assert_lt(bus.global_position.y, 1.0)
	assert_gt(bus.global_position.y, -1.0, "the bus stays on the street")


func test_e_stops_them_pushing() -> void:
	var inmate := _with("window")
	_fill(inmate)
	inmate.use(cop)
	assert_false(inmate.pushing)
	assert_eq(inmate.plan, 0.0)
	await wait_seconds(BusInmate.WINDOW_PUSH + 0.5)
	assert_false(inmate.out)


func test_the_inmates_fit_between_the_window_and_the_aisle() -> void:
	var inmate: BusInmate = plan.inmates[0]
	assert_lt(absf(inmate.position.x) + BusInmate.BODY_RADIUS, PrisonBus.HALF_WIDTH)
	assert_gt(absf(inmate.position.x) - BusInmate.BODY_RADIUS, GameScale.COP_RADIUS, "a cop fits down the aisle")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key in ["PROMPT_FIX_WINDOW", "TRANSFER_SICK", "TRANSFER_SICK_RUN", "TRANSFER_WINDOW_PUSH", "TRANSFER_WINDOW_OPEN",
			"TRANSFER_WINDOW_OUT"]:
		assert_ne(tr(key), key)
