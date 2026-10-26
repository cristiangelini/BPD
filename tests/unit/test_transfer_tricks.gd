extends GutTest

## The inmates' tricks on the transfer bus, first two (traslado-presos.md, step 3a, decision 105): the spoon opens
## the cuffs and the inmate walks to a door unless a cop blocks the aisle or sits them back; the bathroom wants a stop
## at the gas station, and too late the inmate gets angry and spreads it.

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
	# No city traffic: a car already in the gas station's parking spot shoves the bus that lands on it.
	level.get_node("City").traffic = false
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


func test_every_inmate_has_a_trick_and_both_come_up() -> void:
	var drawn := plan.inmates.map(func(inmate: BusInmate) -> String: return tricks.trick_of(inmate))
	for trick in TransferTricks.TRICKS:
		assert_has(drawn, trick)


func test_the_gas_station_is_in_the_city() -> void:
	assert_false(CityLayout.place("gas_station").is_empty())
	TranslationServer.set_locale("es")
	assert_ne(tr("PLACE_GAS_STATION"), "PLACE_GAS_STATION")


func test_the_spoon_opens_the_cuffs_and_e_sits_them_back() -> void:
	var inmate := _with("spoon")
	_fill(inmate)
	assert_true(inmate.loose)
	assert_false(inmate.seated)
	assert_eq(inmate.prompt_key(cop), "PROMPT_SEAT_INMATE")
	inmate.use(cop)
	assert_true(inmate.seated)
	assert_eq(inmate.plan, 0.0, "the plan starts over")


func test_the_handcuffs_sit_a_loose_one_back_too() -> void:
	var inmate := _with("spoon")
	_fill(inmate)
	inmate.cuffed(Handcuffs.SECONDS)
	assert_true(inmate.seated)


func test_left_alone_they_walk_to_a_door() -> void:
	var inmate := _with("spoon")
	_fill(inmate)
	watch_signals(inmate)
	await wait_seconds(BusInmate.LOOSE_WAIT + 9.0)
	assert_signal_emitted(inmate, "at_door")
	# The bus stands still, so at the door they step right out (step 4).
	assert_true(inmate.out, "out by the door")


func test_a_cop_in_the_aisle_blocks_the_way() -> void:
	var inmate: BusInmate = plan.inmates[0]
	inmate.open_cuffs()
	bus.get_on(cop, 0)
	cop.warp(bus.global_transform * Transform3D(Basis.IDENTITY, Vector3(0, 0.4, PrisonBus.CAB_Z)))
	for i in int((BusInmate.LOOSE_WAIT + 6.0) * 60):
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_eq(inmate.door, -1, "the front door is past the cop")


func test_a_stop_at_the_gas_station_calms_the_bathroom() -> void:
	var inmate := _with("bathroom")
	_fill(inmate)
	assert_true(tricks.bathroom.has(inmate))
	# Parked in the street in front of it, like the patrol car.
	var at := (level.city.transform * CityLayout.parking("gas_station")).translated_local(Vector3.UP * 0.3)
	PhysicsServer3D.body_set_state(bus.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, at)
	bus.global_transform = at
	await wait_seconds(TransferTricks.GAS_STOP + 1.5)
	assert_false(tricks.bathroom.has(inmate))
	assert_false(inmate.is_angry())
	assert_eq(plan.contagion, 0)


func test_too_late_for_the_bathroom_they_get_angry_and_spread_it() -> void:
	var inmate := _with("bathroom")
	_fill(inmate)
	tricks.bathroom[inmate] = 0.05
	await wait_physics_frames(10)
	assert_true(inmate.is_angry())
	assert_eq(plan.contagion, 1)
	assert_lt(inmate.plan, 10.0, "their plan starts over")


func test_the_trick_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key in ["PROMPT_SEAT_INMATE", "TRANSFER_SPOON", "TRANSFER_TO_DOOR", "TRANSFER_SAT_BACK_1", "TRANSFER_BATHROOM_1",
			"TRANSFER_BATHROOM_THANKS", "TRANSFER_BATHROOM_LATE", "HINT_TRANSFER_BATHROOM", "HINT_TRANSFER_BATHROOM_LATE"]:
		assert_ne(tr(key), key)
