extends GutTest

## The fire drill jailbreak, step 2 (fuga-simulacro.md): the alarm starts the drill, the guard opens both cells and
## leads everyone out to the meeting point on the sidewalk, the waiting room walks out too, and at the end everyone goes
## back in, the prisoners still out back to their cells, and the heater takes twice as long.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_simulacro_evacuacion.json"

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


func _step_until(done: Callable, seconds: float) -> bool:
	var step := 1.0 / 30.0
	var left := seconds
	while left > 0.0:
		guard._physics_process(step)
		for person: WaitingPerson in get_tree().get_nodes_in_group("waiting_people"):
			person._physics_process(step)
		if done.call():
			return true
		left -= step
	return false


func _people() -> Array:
	return get_tree().get_nodes_in_group("waiting_people")


func test_the_alarm_starts_the_drill() -> void:
	level.detectors[0].ring()
	assert_true(level.alarm_rung)
	assert_true(level.drilling)
	assert_almost_eq(level.drill_left, JailbreakLevel.DRILL_TIME, 0.01)
	assert_eq(guard.stage, "opening")
	assert_eq(guard._bubble.text, "DRILL_GUARD_WHISTLE")
	for person: WaitingPerson in _people():
		assert_true(person.is_walking(), "%s walks out" % person.name)


func test_he_opens_both_cells_and_leads_everyone_out() -> void:
	level.detectors[1].ring()
	assert_true(_step_until(func() -> bool: return guard.stage == "leading", 20.0), "both cells")
	for door: CellDoor in level.city.cell_doors:
		assert_false(door.locked)
		assert_true(door.is_open)
	cop.global_position = lot * Vector3(9.6, 0.1, 6.0)
	guard._physics_process(1.0)
	assert_lt(guard.suspicion, 1.0, "a prisoner out of a cell is what he wants now")
	assert_true(_step_until(func() -> bool: return guard.stage == "at_point", 30.0), "to the meeting point")
	var at := lot.affine_inverse() * guard.global_position
	assert_gt(at.z, StationRooms.HALF_Z, "on the sidewalk")
	assert_true(guard.facing().dot(lot.basis * Vector3(0, 0, -1)) > 0.9, "facing the station")
	assert_true(_step_until(func() -> bool: return not _people().any(func(p: WaitingPerson) -> bool: return p.is_walking()), 60.0))
	for person: WaitingPerson in _people():
		assert_almost_eq(person.global_position.distance_to(person.meeting), 0.0, 0.05, "%s at the meeting point" % person.name)


func test_at_the_end_everyone_goes_back_in() -> void:
	level.detectors[0].ring()
	_step_until(func() -> bool: return guard.stage == "at_point", 60.0)
	cop.global_position = lot * Vector3(-2.0, 0.1, 11.0)
	level.drill_left = 0.01
	await wait_physics_frames(2)
	assert_false(level.drilling)
	assert_eq(guard.stage, "back")
	assert_false(level.outside_cells(cop.global_position), "back in a cell")
	for door: CellDoor in level.city.cell_doors:
		assert_true(door.locked)
	for detector in level.detectors:
		assert_false(detector.ringing)
	for heater in level.heaters:
		assert_eq(heater.slow, JailbreakLevel.HEATER_SLOW, "NO TOCAR")
	assert_true(_step_until(func() -> bool: return guard.stage == "", 60.0), "back at his desk")
	assert_true(_step_until(func() -> bool: return not _people().any(func(p: WaitingPerson) -> bool: return p.is_walking()), 60.0))
	for person: WaitingPerson in _people():
		assert_almost_eq(person.global_position.distance_to(person.home), 0.0, 0.05, "%s back inside" % person.name)
	assert_eq(guard.times_caught, 0, "the drill isn't a catch")


func test_a_catch_ends_the_drill() -> void:
	level.detectors[0].ring()
	_step_until(func() -> bool: return guard.stage == "leading", 20.0)
	guard.catch()
	assert_false(level.drilling)
	assert_eq(guard.stage, "")
	assert_eq(guard.times_caught, 1)
	for door: CellDoor in level.city.cell_doors:
		assert_true(door.locked)


func test_the_next_smoke_takes_twice_as_long() -> void:
	level.detectors[0].ring()
	level.drill_left = 0.01
	await wait_physics_frames(2)
	var heater := level.heaters[0]
	cop.global_position = heater.global_position + (lot.basis * Vector3(1.0, 0.1, 0))
	cop.get_node("Grabber").grab(level.get_node("CellBlanket0"))
	heater.use(cop)
	for i in int(CellHeater.SMOKE_ALARM * 30) + 5:
		heater._physics_process(1.0 / 30.0)
	assert_false(heater.detector.ringing, "not after 8 s")
	for i in int(CellHeater.SMOKE_ALARM * 30):
		heater._physics_process(1.0 / 30.0)
	assert_true(heater.detector.ringing, "after 16 s")
	assert_true(level.drilling, "and the drill starts again")
