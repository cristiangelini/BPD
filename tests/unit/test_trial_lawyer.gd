extends GutTest

## The fast trial jailbreak, step 1 (fuga-juicio.md): drawn in tenths, in the morning; the day guard calls them to the
## trial and opens the cells, leaving the front row is out of place, and whoever wears the lost and found's lawyer
## jacket sees the alibi's file. Caught, the jacket goes back to its box and the next trial has another alibi.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_juicio_abogado.json"

var level: JailbreakLevel
var guard: TrialGuard
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "trial"
	level.case_seed = 6161
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as TrialGuard
	guard.set_physics_process(false)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _step(seconds: float) -> void:
	for i in int(seconds * 30):
		guard._physics_process(1.0 / 30.0)


func test_drawn_in_tenths() -> void:
	var seen := {}
	for drawn in range(1, 300):
		seen[JailbreakLevel.pick_variant(drawn, PackedStringArray(), BribeGuard.PRICE_MIN)] = true
	assert_eq(seen.size(), 10)
	assert_true(seen.has("trial"))
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=trial"])), "trial")


func test_the_alibi() -> void:
	var alibi := TrialAlibi.draw(6161, 0)
	assert_eq(alibi, TrialAlibi.draw(6161, 0), "same seed, same alibi")
	var others := 0
	for trial in range(1, 6):
		if TrialAlibi.draw(6161, trial) != alibi:
			others += 1
	assert_gt(others, 3, "each trial another one")
	for detail in TrialAlibi.DETAILS:
		var choices := TrialAlibi.choices(alibi, detail)
		assert_eq(choices.size(), TrialAlibi.OPTIONS)
		assert_has(choices, TrialAlibi.answer(alibi, detail))
		for key in choices:
			assert_ne(tr(key), key, "%s has a text" % key)
	assert_true(TrialAlibi.file_text(alibi).contains(tr(TrialAlibi.answer(alibi, "WHO"))))


func test_every_option_has_its_text() -> void:
	for detail in TrialAlibi.DETAILS:
		for group in TrialAlibi.GROUPS:
			for option in TrialAlibi.OPTIONS:
				var key := TrialAlibi.key(detail, group, option)
				assert_ne(tr(key), key, key)


func test_morning_and_the_call_to_trial() -> void:
	assert_eq(guard.phase, "")
	assert_true(level.city.cell_doors.all(func(door: CellDoor) -> bool: return door.locked))
	assert_true(level.outside_cells(lot * Vector3(0, 0.1, 6.0)), "before the trial the guard room is out")
	_step(TrialGuard.CALL_TIME + 0.1)
	assert_eq(guard.phase, "briefing")
	assert_eq(guard.said(), "TRIAL_GUARD_CALL")
	assert_true(level.city.cell_doors.all(func(door: CellDoor) -> bool: return not door.locked and door.is_open))
	assert_false(level.outside_cells(lot * Vector3(0, 0.1, 6.0)), "the guard room is the court now")
	assert_false(level.outside_cells(lot * Vector3(9.0, 0.1, 6.0)), "and the cells room")
	assert_true(level.outside_cells(lot * Vector3(0, 0.1, -3.0)), "the office isn't")
	assert_true(level.outside_cells(lot * Vector3(0, 0.1, StationRooms.HALF_Z + 2.0)), "nor the street")
	assert_true(level.outside_cells(lot * Vector3(-9.0, 0.1, 5.0)), "nor the armory")
	_step(TrialGuard.BRIEFING + 0.1)
	assert_eq(guard.phase, "court")


func test_on_the_bench_he_doesnt_mind() -> void:
	_step(TrialGuard.CALL_TIME + 0.1)
	cop.global_position = lot * Vector3(0, 0.1, 7.0)
	guard.global_transform = Transform3D(Basis.looking_at(lot.basis * Vector3(1, 0, 0)), guard.global_position)
	for i in 60:
		guard._watch(1.0 / 30.0)
	assert_eq(guard.times_caught, 0, "on the bench is fine")


func test_the_jacket_makes_the_lawyer_who_sees_the_file() -> void:
	var jacket: DisguisePiece = level.jacket
	assert_almost_eq(jacket.global_position.distance_to(lot * JailbreakLevel.JACKET_ON_BOX), 0.0, 0.3, "on the box")
	assert_null(level.lawyer())
	assert_false(level.file_label.visible)
	cop.put_on_disguise("lawyer_jacket", 0.0)
	assert_eq(level.lawyer(), cop)
	await wait_physics_frames(2)
	assert_true(level.file_label.visible, "the lawyer sees the file")
	assert_eq(level.file_label.text, TrialAlibi.file_text(level.alibi))


func test_caught_the_jacket_goes_back_and_another_alibi() -> void:
	var first := level.alibi
	_step(TrialGuard.CALL_TIME + 0.1)
	cop.put_on_disguise("lawyer_jacket", 0.0)
	level.jacket.queue_free()
	cop.global_position = lot * Vector3(0, 0.1, -3.0)
	await wait_physics_frames(2)
	guard.catch()
	await wait_physics_frames(3)
	assert_false(cop.disguise.has("lawyer_jacket"))
	assert_true(is_instance_valid(level.jacket))
	assert_almost_eq(level.jacket.global_position.distance_to(lot * JailbreakLevel.JACKET_ON_BOX), 0.0, 0.3,
		"back on the box")
	assert_eq(level.trials, 1)
	assert_eq(level.alibi, TrialAlibi.draw(6161, 1))
	assert_ne(level.alibi, first)
	assert_eq(guard.phase, "", "back in the cells")
	assert_true(level.city.cell_doors.all(func(door: CellDoor) -> bool: return door.locked))
	assert_false(level.outside_cells(cop.global_position))
