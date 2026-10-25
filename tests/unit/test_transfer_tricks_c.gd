extends GutTest

## The singer and accomplice tricks on the transfer bus (traslado-presos.md, step 3c, decision 105): the lullaby
## puts the nearest standing cop to sleep unless someone covers the singer's mouth, and the accomplice's car follows
## the bus and, when it stops, hands an inmate a file to saw the bars with.

const LEVEL := preload("res://scenes/levels/prisoner_transfer.tscn")
const COP := preload("res://scenes/player/cop.tscn")

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


func _start(inmate: BusInmate) -> void:
	inmate.set_plan(BusInmate.FULL)
	plan.plan_ready.emit(inmate)


func _stand_by(inmate: BusInmate) -> void:
	bus.get_on(cop, 1)
	cop.warp(bus.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3(0, 0.4, PrisonBus.seat_spot(inmate.seat).z - 1.5)))


func _wait(frames: int) -> void:
	for i in frames:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)


func test_all_six_tricks_come_up() -> void:
	var drawn := plan.inmates.map(func(inmate: BusInmate) -> String: return tricks.trick_of(inmate))
	for trick in TransferTricks.TRICKS:
		assert_has(drawn, trick)


func test_the_lullaby_puts_the_nearest_cop_to_sleep() -> void:
	var inmate := _with("singer")
	_stand_by(inmate)
	_start(inmate)
	assert_true(inmate.singing)
	await _wait(int(BusInmate.SING_TIME * 60) + 10)
	assert_false(inmate.singing)
	assert_true(cop.is_staggered(), "asleep on their feet")
	assert_false(plan.watches(cop, plan.inmates[0]), "and watching nobody")


func test_covering_their_mouth_stops_the_song() -> void:
	var inmate := _with("singer")
	_stand_by(inmate)
	_start(inmate)
	assert_eq(inmate.prompt_key(cop), "PROMPT_HUSH_INMATE")
	inmate.use(cop)
	assert_false(inmate.singing)
	await _wait(int(BusInmate.SING_TIME * 60) + 10)
	assert_false(cop.is_staggered())


func test_the_accomplice_follows_and_hands_a_file_when_the_bus_stops() -> void:
	var driver: Cop = COP.instantiate()
	driver.input_enabled = false
	level.add_child(driver)
	bus.get_on(driver, 0)
	bus.use(driver, PrisonBus.Act.DRIVE)
	var inmate := _with("accomplice")
	_start(inmate)
	assert_eq(tricks.cars.size(), 1)
	var car := tricks.cars[0]
	bus.drive(1.0, 0.0, false)
	await wait_seconds(5.0)
	assert_almost_eq(car.global_position.distance_to(bus.global_position), AccompliceCar.FOLLOW, 3.0, "it follows")
	watch_signals(car)
	bus.drive(0.0, 0.0, true)
	await wait_seconds(5.0)
	assert_signal_emitted(car, "handed")
	assert_true(inmate.pushing or inmate.out, "sawing with the file")


func test_the_accomplice_gives_up_if_the_bus_never_stops() -> void:
	var inmate := _with("accomplice")
	_start(inmate)
	var car := tricks.cars[0]
	car._left = 0.01
	inmate.seated = true
	await wait_physics_frames(5)
	assert_true(car.leaving)
	assert_eq(inmate.plan, 0.0, "their plan starts over")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key in ["PROMPT_HUSH_INMATE", "TRANSFER_SING", "TRANSFER_SANG", "TRANSFER_HUSHED", "HINT_TRANSFER_ASLEEP",
			"TRANSFER_ACCOMPLICE", "HINT_TRANSFER_ACCOMPLICE", "TRANSFER_FILE"]:
		assert_ne(tr(key), key)
