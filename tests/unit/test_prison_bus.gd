extends GutTest

## The prisoner transfer bus (traslado-presos.md, step 1, decision 105): it waits by the station with its doors on
## the sidewalk, cops get on and off by its doors and walk the aisle, one drives it, it goes slower than the patrol car
## and a hard brake throws the standing cops.

const LEVEL := preload("res://scenes/levels/prisoner_transfer.tscn")
const COP := preload("res://scenes/player/cop.tscn")

var level: PrisonLevel
var bus: PrisonBus
var cop: Cop


func before_each() -> void:
	level = LEVEL.instantiate()
	level.case_seed = 7
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	bus = level.bus
	cop = level.get_node("Cop")
	await wait_physics_frames(30)


func _walk(who: Cop, wish: Vector2, frames: int) -> void:
	for i in frames:
		who.step(1.0 / 60.0, wish, false, false, false)
		await wait_physics_frames(1)


func test_play_can_open_it() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=transfer"])), "transfer")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["transfer"]))


func test_it_waits_by_the_station_with_its_doors_on_the_sidewalk() -> void:
	var station := level.city.transform * CityLayout.door_of("station")
	assert_lt(bus.global_position.distance_to(station), 12.0, "parked by the station's door")
	var front_door := bus.to_global(PrisonBus.DOORS[0].outside)
	assert_lt(front_door.distance_to(station), bus.global_position.distance_to(station), "the doors face the station")
	assert_eq(level.riot, null, "no riot in the canteen")


func test_it_has_eight_inmate_seats_inside() -> void:
	for i in 8:
		assert_true(bus.holds(bus.to_global(PrisonBus.seat_spot(i))), "seat %d inside" % i)


func test_a_cop_gets_on_by_the_door_and_off_by_the_other() -> void:
	cop.warp(Transform3D(Basis.IDENTITY, bus.to_global(PrisonBus.DOORS[0].outside) + Vector3.UP * 0.1))
	assert_eq(bus.use_args(cop)[0], PrisonBus.Act.ON)
	bus.use(cop)
	assert_eq(cop.riding, bus)
	assert_eq(cop.get_parent(), bus, "it goes along with the bus")
	assert_true(bus.holds(cop.global_position))
	cop.warp(bus.global_transform * Transform3D(Basis.IDENTITY, PrisonBus.DOORS[1].inside))
	assert_eq(bus.use_args(cop), [PrisonBus.Act.OFF, 1])
	bus.use(cop)
	assert_null(cop.riding)
	assert_false(bus.holds(cop.global_position))


func test_far_from_a_door_e_does_nothing() -> void:
	cop.warp(Transform3D(Basis.IDENTITY, bus.to_global(Vector3(-2.4, 0, -1.0))))
	assert_eq(bus.use_args(cop)[0], PrisonBus.Act.NONE)
	bus.use(cop)
	assert_null(cop.riding)


func test_one_drives_and_stands_up_inside() -> void:
	bus.get_on(cop, 0)
	cop.warp(bus.global_transform * Transform3D(Basis.IDENTITY, PrisonBus.DRIVER_STAND))
	assert_eq(bus.use_args(cop)[0], PrisonBus.Act.DRIVE)
	bus.use(cop)
	assert_eq(bus.driver(), cop)
	bus.use(cop)
	assert_null(bus.driver())
	assert_eq(cop.riding, bus, "the driver stands up in the cab, not on the street")


func test_it_is_slower_than_the_patrol_car() -> void:
	assert_lt(PrisonBus.BUS_SPEED, PatrolCar.MAX_SPEED)
	assert_almost_eq(bus.top_speed(), PrisonBus.BUS_SPEED, 0.01)


func test_standing_cops_go_along_and_a_hard_brake_throws_them() -> void:
	var driver: Cop = COP.instantiate()
	driver.input_enabled = false
	level.add_child(driver)
	bus.get_on(driver, 0)
	bus.use(driver, PrisonBus.Act.DRIVE)
	bus.get_on(cop, 1)
	bus.drive(1.0, 0.0, false)
	await _walk(cop, Vector2.ZERO, 240)
	assert_gt(bus.forward_speed(), 6.0, "it got going")
	assert_true(bus.holds(cop.global_position), "the standing cop went along")
	watch_signals(bus)
	bus.drive(-1.0, 0.0, true)
	await _walk(cop, Vector2.ZERO, 60)
	assert_signal_emitted(bus, "lurched")
	assert_gt(bus.lurches, 0)
	assert_true(bus.holds(cop.global_position), "thrown about, but still inside")


func test_the_bus_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key in ["PROMPT_BUS_ON", "PROMPT_BUS_OFF", "PROMPT_BUS_DRIVE", "HINT_BUS_DOOR", "HINT_BUS_ON", "HINT_BUS_DRIVER"]:
		assert_ne(tr(key), key)
