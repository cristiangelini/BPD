extends GutTest

## The dangerous suspect out on the street (persecucion-final.md, decision 96): loose long enough, he runs out the
## station's front door and takes the old patrol car; the cops chase him in the good one. Caught, he's back in his
## chair and the interrogation goes on; got away, it's lost.

const LEVEL_SCENE := preload("res://scenes/levels/interrogation.tscn")

var level: InterrogationLevel
var case: InterrogationCase


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	level = LEVEL_SCENE.instantiate()
	level.case_seed = _dangerous_seed()
	(level.get_node("Cop") as Cop).input_enabled = false
	(level.get_node("Cop/Grabber") as Node).input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	case = level.case
	case.give_tip()


func _dangerous_seed() -> int:
	for seed_value in range(1, 1000):
		if InterrogationCase.pick_suspect(seed_value, PackedStringArray()) == "dangerous":
			return seed_value
	return 0


func _loose() -> void:
	case._seen = true
	case._watch(InterrogationCase.LOOSE_SECONDS + 1.0)


func test_the_old_patrol_car_waits_by_the_station() -> void:
	assert_eq(case.suspect_id, "dangerous")
	assert_not_null(case.getaway)
	assert_eq(case.getaway.kind, SuspectCar.OLD_PATROL)
	assert_false(case.getaway.driving)
	assert_eq(case.car, level.get_node("PatrolCar"), "the good one is the cops'")


func test_after_a_lap_he_runs_out_the_front_door_and_takes_it() -> void:
	_loose()
	assert_true(case.loose)
	var out := level.suspect.outside
	watch_signals(level.suspect)
	await wait_for_signal(out, 25.0)
	assert_signal_emitted(level.suspect, "outside")
	assert_eq(level.suspect.laps, InterrogationWing.STREET_LAPS)
	assert_gt(level.suspect.position.z, StationRooms.HALF_Z, "out of the front door")
	await wait_physics_frames(2)
	assert_not_null(case.chase)
	assert_false(level.suspect.visible)
	assert_false(case.loose, "the lawyer stops going up meanwhile")
	assert_eq(case.chase.truck, case.getaway)
	assert_true(case.getaway.driving, "off he goes")
	assert_eq(case.chase.car, case.car)
	TranslationServer.set_locale("es")
	for key in ["HINT_DANGEROUS_STREET", "HINT_DANGEROUS_BACK", "CASE_FAILED_SUSPECT_ESCAPED", "CHASE_DANGEROUS_LINE_1"]:
		assert_ne(tr(key), key, "%s needs a text" % key)


func test_caught_he_is_back_in_his_chair() -> void:
	_loose()
	case._on_outside()
	var chase := case.chase
	var lawyer := case.lawyer
	case._watch(10.0)
	assert_eq(case.lawyer, lawyer, "not loose while they chase him")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "dangerous")
	chase.suspect.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(2)
	chase.escort.board()
	await wait_physics_frames(3)
	assert_true(level.suspect.visible)
	assert_eq(level.suspect.position, InterrogationWing.SUSPECT_AT)
	assert_almost_eq(case.nerves, InterrogationCase.CAUGHT_NERVES, 0.01)
	assert_true(case.is_on(), "the interrogation goes on")
	assert_null(case.car.prisoner)


func test_got_away_the_interrogation_is_lost() -> void:
	_loose()
	case._on_outside()
	case.chase.fail("CASE_FAILED_TIME")
	await wait_physics_frames(2)
	assert_true(case.escaped)
	assert_false(case.is_on())
	assert_true(case.failed_label.visible)
	assert_eq(case.failed_label.text, "CASE_FAILED_SUSPECT_ESCAPED")
