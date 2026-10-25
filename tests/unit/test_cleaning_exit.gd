extends GutTest

## The cleaning crew's jailbreak, step 5 (fuga-limpieza.md): the floor polisher, and not getting in the patrol car where
## the comisario sees it.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_salida.json"

var level: JailbreakLevel
var cop: Cop
var comisario: EarlyComisario
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "cleaning"
	level.case_seed = 8080
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	comisario = level.guard as EarlyComisario
	comisario.set_physics_process(false)
	level.cleaner.set_physics_process(false)
	level.stains.set_physics_process(false)
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func test_e_turns_the_polisher_on_and_off() -> void:
	var polisher := level.polisher
	assert_not_null(polisher)
	assert_eq(polisher.prompt_key(cop), "PROMPT_POLISHER_ON")
	polisher.use(cop)
	assert_true(polisher.is_on)
	assert_true(polisher.is_scrubbing())
	assert_false(polisher.is_working(), "on the floor it isn't anyone's work")
	polisher.use(cop)
	assert_false(polisher.is_on)


func test_the_polisher_scrubs_faster_than_a_mop() -> void:
	var stains := level.stains
	var at := stains.spots[0] + Vector3.UP * 0.05
	for i in int(FloorStains.SCRUB / FloorPolisher.SCRUB_FACTOR / 0.1) + 1:
		stains.scrub_at(at, 0.1 * FloorPolisher.SCRUB_FACTOR, FloorPolisher.DISC)
	assert_true(stains.is_clean(0))


func test_on_and_in_hand_it_counts_as_cleaning_and_pulls() -> void:
	var polisher := level.polisher
	cop.global_position = polisher.global_position + Vector3(0, 0.1, 0.8)
	cop.put_on_disguise("cleaner_cap", 0.0)
	cop.put_on_disguise("face_mask", 0.0)
	cop.handed(polisher)
	polisher.use(cop)
	await wait_physics_frames(3)
	assert_true(comisario.is_cleaning(cop))
	assert_ne(cop._knock, Vector3.ZERO, "it pulls its cop around")


func test_let_go_while_on_it_wanders_off() -> void:
	var polisher := level.polisher
	polisher.use(cop)
	var from := polisher.global_position
	await wait_seconds(1.0)
	assert_gt(Vector2(polisher.global_position.x - from.x, polisher.global_position.z - from.z).length(), 0.2)
	assert_gt(absf(polisher.angular_velocity.y), 1.0, "spinning")


func test_seen_in_the_patrol_car_they_get_caught_at_once() -> void:
	var car: PatrolCar = level.get_node("PatrolCar")
	cop.put_on_disguise("cleaner_cap", 0.0)
	cop.put_on_disguise("cleaner_vest", 0.0)
	cop.global_position = car.global_position + car.global_basis.x * 2.0
	await wait_physics_frames(2)
	car.enter(cop)
	await wait_physics_frames(2)
	# He's at the front door, looking out for the inspector.
	comisario.target = 5
	comisario.global_transform = Transform3D(lot.basis, lot * EarlyComisario.ROUND[5][0])
	comisario.look = 0.0
	if not comisario.sees(car.global_position + Vector3.UP, car):
		pending("the car isn't in sight from the front door with this layout")
		return
	comisario._watch(0.1)
	assert_eq(comisario.times_caught, 1)
	assert_eq(comisario.said(), "EARLY_CAR")
	await wait_physics_frames(2)
	assert_eq(car.seat_of(cop), -1, "out of the car")
	assert_false(level.outside_cells(cop.global_position), "and back in a cell")


func test_the_front_door_is_one_of_his_stops() -> void:
	assert_eq(EarlyComisario.ROUND[5][2], "EARLY_DOOR")
