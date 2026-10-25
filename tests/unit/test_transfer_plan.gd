extends GutTest

## The inmates on the transfer bus (traslado-presos.md, step 2, decision 105): 8 sit cuffed in its seats, their
## escape plans stay put until the bus leaves, then fill while nobody watches them and go down while a cop standing
## close looks at them; a hard brake adds to everyone unwatched, and a full plan is plan_ready.

const LEVEL := preload("res://scenes/levels/prisoner_transfer.tscn")
const COP := preload("res://scenes/player/cop.tscn")

var level: PrisonLevel
var bus: PrisonBus
var plan: TransferPlan
var guard: Cop


func before_each() -> void:
	level = LEVEL.instantiate()
	level.case_seed = 7
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	bus = level.bus
	plan = level.transfer
	guard = level.get_node("Cop")
	await wait_physics_frames(30)


func _drive() -> void:
	var driver: Cop = COP.instantiate()
	driver.input_enabled = false
	level.add_child(driver)
	bus.get_on(driver, 0)
	bus.use(driver, PrisonBus.Act.DRIVE)
	bus.drive(1.0, 0.0, false)


func _wait(frames: int) -> void:
	for i in frames:
		if guard.riding:
			guard.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)


func test_eight_inmates_sit_cuffed_in_the_bus() -> void:
	assert_eq(plan.inmates.size(), 8)
	for inmate in plan.inmates:
		assert_true(inmate.seated)
		assert_eq(inmate.get_parent(), bus, "they go along with the bus")
		assert_true(bus.holds(inmate.global_position))
		assert_between(inmate.plan, 0.0, TransferPlan.START_MAX)


func test_the_plans_wait_until_the_bus_leaves() -> void:
	var before := plan.inmates.map(func(inmate: BusInmate) -> float: return inmate.plan)
	await _wait(120)
	assert_false(plan.started)
	assert_eq(plan.inmates.map(func(inmate: BusInmate) -> float: return inmate.plan), before)


func test_unwatched_plans_fill_and_a_watched_one_goes_down() -> void:
	bus.get_on(guard, 1)
	var watched := plan.inmates.filter(func(inmate: BusInmate) -> bool: return plan.watches(guard, inmate))
	assert_gt(watched.size(), 0, "the guard at the back door sees the last row")
	assert_lt(watched.size(), 8, "but not everyone")
	var far: BusInmate = plan.inmates[0]
	assert_false(plan.watched(far))
	var far_before := far.plan
	(watched[0] as BusInmate).set_plan(20.0)
	_drive()
	await _wait(360)
	assert_true(plan.started)
	assert_gt(far.plan, far_before, "nobody watches the front row")
	assert_lt((watched[0] as BusInmate).plan, 20.0, "the guard's look brings it down")


func test_the_driver_watches_the_road() -> void:
	_drive()
	for inmate in plan.inmates:
		assert_false(plan.watched(inmate))


func test_a_hard_brake_adds_to_the_unwatched() -> void:
	plan.started = true
	var inmate: BusInmate = plan.inmates[0]
	var before := inmate.plan
	bus.lurched.emit(8.0)
	assert_almost_eq(inmate.plan, before + TransferPlan.LURCH_PLAN, 0.01)


func test_a_full_plan_is_ready_and_shows() -> void:
	plan.started = true
	watch_signals(plan)
	var inmate: BusInmate = plan.inmates[0]
	inmate.set_plan(99.0)
	bus.lurched.emit(8.0)
	assert_signal_emitted(plan, "plan_ready")
	assert_eq(plan.count_ready(), 1)
	assert_ne(inmate.said(), "", "they say they're about to try something")


func test_fewer_cops_fill_the_plans_slower() -> void:
	assert_almost_eq(plan.cops_share(), 0.25, 0.01, "one cop alone")


func test_the_plan_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for i in BusInmate.READY_LINES:
		assert_ne(tr("TRANSFER_PLAN_READY_%d" % (i + 1)), "TRANSFER_PLAN_READY_%d" % (i + 1))
