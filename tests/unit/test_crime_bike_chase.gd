extends GutTest

## The crime scene's culprit who runs off (escena-del-crimen.md, step 6b): accused, half of them get on the delivery
## bike by the tent and the chase starts in the middle of the case. Caught and in the patrol car, solved and in custody;
## got away, the case is lost. Seed 44 runs off.

const LEVEL := preload("res://scenes/levels/crime_scene.tscn")

var level: CrimeSceneLevel
var case: CrimeSceneCase


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	level = LEVEL.instantiate()
	level.case_seed = 44
	(level.get_node("Cop") as Cop).input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	case = level.case
	case.give_tip()


func after_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}


func test_half_the_culprits_run_off() -> void:
	var runs := 0
	for i in 200:
		var other := CrimeSceneCase.new()
		other.case_seed = i + 1
		other.plan = case.plan
		runs += int(other.runs_off())
		other.free()
	assert_between(runs, 70, 130, "half and half (propuesta)")


func test_accused_he_gets_on_his_bike_and_the_chase_starts() -> void:
	var cook: PastryCook = level.contest.cooks[case.plan.culprit]
	case.accuse(case.plan.culprit)
	assert_not_null(case.chase, "the chase is on")
	assert_false(cook.visible, "he left his table")
	assert_eq(case.chase.truck.kind, SuspectCar.BIKE)
	assert_eq(case.chase.who, "cook", "he gets off as the cook")
	assert_true(case.custody.is_empty(), "not in custody until he's caught")
	assert_false(level.contest.under_roof(case.chase.truck.global_position), "the bike waits out of the tent")
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_CRIME_CATCH")
	assert_false(case.shift_over)


func test_the_bike_rides_out_of_the_plaza() -> void:
	case.accuse(case.plan.culprit)
	var bike := case.chase.truck
	var start := bike.global_position
	bike.driving = true
	case.chase.chasing = true
	await wait_seconds(5.0)
	assert_gt(bike.global_position.distance_to(start), 15.0, "he pedals off")
	assert_lt(bike.stuck_for, 1.0, "the plaza's trees don't stop him")


func test_caught_he_is_taken_for_the_interrogation() -> void:
	case.accuse(case.plan.culprit)
	case.chase.ended.emit(true)
	assert_eq(case.custody.owner, "cook")
	case.finish_shift()
	assert_true(case.solved())
	assert_eq(PlaceDraw.custody.owner, "cook", "next shift is his interrogation")


func test_got_away_the_case_is_lost() -> void:
	case.accuse(case.plan.culprit)
	case.chase.ended.emit(false)
	assert_true(case.escaped)
	case.finish_shift()
	assert_false(case.solved())
	assert_true(PlaceDraw.custody.is_empty(), "nobody to interrogate")


func test_the_bike_and_the_cook_have_their_models_and_lines() -> void:
	assert_true(SuspectCar.MODELS.has(SuspectCar.BIKE))
	assert_true(ChaseSuspect.MODELS.has("cook"))
	for i in 3:
		assert_ne(tr("CHASE_COOK_LINE_%d" % (i + 1)), "CHASE_COOK_LINE_%d" % (i + 1))
	assert_ne(tr("HINT_ESCAPE_cook"), "HINT_ESCAPE_cook")
