extends GutTest

## The fire drill jailbreak, step 1 (fuga-simulacro.md): the seventh way out, daytime with the waiting room full, the
## day guard with the key, the cops in orange vests, and a blanket against a cell's heater smoking until its detector
## rings, while the guard can see the smoke.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_simulacro.json"

var level: JailbreakLevel
var guard: DrillGuard
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "drill"
	level.case_seed = 7777
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as DrillGuard
	guard.set_physics_process(false)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _blanket(cell: int) -> CellBlanket:
	return level.get_node("CellBlanket%d" % cell)


## The cop in cell 0, by its heater, with the blanket in hand.
func _by_the_heater_with_the_blanket() -> CellHeater:
	var heater := level.heaters[0]
	cop.global_position = heater.global_position + (lot.basis * Vector3(1.0, 0.1, 0))
	cop.get_node("Grabber").grab(_blanket(0))
	return heater


func test_the_drill_is_one_of_the_ways_out() -> void:
	assert_true(JailbreakLevel.VARIANTS.has("drill"))
	assert_eq(JailbreakLevel.VARIANTS.size(), 7, "in sevenths")
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=drill"])), "drill")
	assert_true(level.is_drill())
	assert_not_null(guard, "the day guard")
	assert_true(guard.key_on_belt, "the key on his belt")
	assert_null(level.box, "no donuts")


func test_daytime_with_the_waiting_room_full() -> void:
	var people := get_tree().get_nodes_in_group("waiting_people")
	assert_between(people.size(), JailbreakLevel.WAITING_MIN, JailbreakLevel.WAITING_SPOTS.size())
	var kinds := {}
	for person: WaitingPerson in people:
		kinds[person.kind] = true
		var local := lot.affine_inverse() * person.global_position
		assert_lt(absf(local.x), StationRooms.FRONT_X, "%s in the guard room" % person.name)
		assert_true(local.z > StationRooms.SPLIT_Z and local.z < StationRooms.HALF_Z)
	assert_eq(kinds.size(), people.size(), "all different people")
	var sun: DirectionalLight3D = level.get_node("Moon")
	assert_gt(sun.light_energy, 1.0, "daylight")


func test_the_same_seed_brings_the_same_people() -> void:
	var names := get_tree().get_nodes_in_group("waiting_people").map(func(p: WaitingPerson) -> String: return p.kind)
	var other: JailbreakLevel = LEVEL.instantiate()
	other.variant = "drill"
	other.case_seed = 7777
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(2)
	var again := other.find_children("WaitingPerson*", "WaitingPerson", false, false) \
		.map(func(p: WaitingPerson) -> String: return p.kind)
	assert_eq(again, names)


func test_the_cops_wear_orange_vests() -> void:
	await wait_physics_frames(2)
	assert_true(cop.disguise.has("prison_vest"))
	assert_not_null(cop.get_node_or_null("Disguise/prison_vest"))


func test_a_heater_blanket_and_detector_in_each_cell() -> void:
	assert_eq(level.heaters.size(), 2)
	assert_eq(level.detectors.size(), 2)
	for cell in 2:
		var heater := level.heaters[cell]
		assert_false(level.outside_cells(heater.global_position + Vector3.UP * 0.3), "heater %d in a cell" % cell)
		assert_false(level.outside_cells(_blanket(cell).global_position), "blanket %d in a cell" % cell)
		assert_almost_eq(level.detectors[cell].global_position.y - lot.origin.y, StationRooms.CEILING, 0.01)
		assert_eq(heater.detector, level.detectors[cell])


func test_the_heater_needs_the_blanket() -> void:
	var heater := level.heaters[0]
	cop.global_position = heater.global_position + (lot.basis * Vector3(1.0, 0.1, 0))
	assert_eq(heater.prompt_key(cop), "PROMPT_HEATER")
	heater.use(cop)
	assert_false(heater.is_smoking())
	cop.get_node("Grabber").grab(_blanket(0))
	assert_eq(heater.prompt_key(cop), "PROMPT_HEATER_SMOKE")


func test_eight_seconds_of_smoke_ring_the_detector() -> void:
	var heater := _by_the_heater_with_the_blanket()
	watch_signals(heater.detector)
	heater.use(cop)
	assert_true(heater.is_smoking())
	assert_eq(heater.prompt_key(cop), "PROMPT_HEATER_STOP")
	for i in int((CellHeater.SMOKE_ALARM - 0.5) * 30):
		heater._physics_process(1.0 / 30.0)
	assert_false(heater.detector.ringing, "not yet")
	for i in 30:
		heater._physics_process(1.0 / 30.0)
	assert_true(heater.detector.ringing)
	assert_signal_emitted(heater.detector, "rang")
	assert_true(level.alarm_rung)
	assert_false(heater.is_smoking())


func test_letting_go_or_walking_away_starts_it_over() -> void:
	var heater := _by_the_heater_with_the_blanket()
	heater.use(cop)
	heater._physics_process(3.0)
	assert_almost_eq(heater.smoke, 3.0, 0.01)
	cop.get_node("Grabber").release()
	heater._physics_process(0.1)
	assert_false(heater.is_smoking())
	assert_eq(heater.smoke, 0.0, "starts over")
	cop.get_node("Grabber").grab(_blanket(0))
	heater.use(cop)
	cop.global_position += lot.basis * Vector3(3.0, 0, 0)
	heater._physics_process(0.1)
	assert_false(heater.is_smoking(), "too far")


func test_the_guard_sees_the_smoke() -> void:
	var heater := _by_the_heater_with_the_blanket()
	var calm := guard.alarm()
	heater.use(cop)
	# He's looking right at that cell.
	guard.look_at_noise(heater.global_position, 5.0, "")
	guard._physics_process(0.01)
	var rate := guard.alarm()
	assert_almost_eq(rate - calm, DrillGuard.SMOKE_SUSPICION, 0.01, "the smoke")
	assert_eq(guard._bubble.text.begins_with("DRILL_GUARD_SMOKE_"), true)
