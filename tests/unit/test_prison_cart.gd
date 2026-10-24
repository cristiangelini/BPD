extends GutTest

## The last ringleader's getaway (carcel-motin.md, step 5b, decision 104): with the other two in the punishment cell,
## the one still loose rolls off on the food cart and the chase starts; caught or not, the case can still be solved.

const LEVEL := preload("res://scenes/levels/prison.tscn")

var prison: PrisonLevel
var riot: PrisonRiot
var case: PrisonCase
var cop: Cop


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	riot = prison.riot
	case = prison.case
	cop = prison.get_node("Cop")
	await wait_physics_frames(2)
	riot.start()
	for inmate in riot.inmates:
		if not inmate.ringleader:
			inmate.anger = 0.0
			inmate.calm(0.0)


func _jail(leaders: Array[PrisonInmate]) -> void:
	for leader in leaders:
		leader.cuffed(Handcuffs.SECONDS)
		leader.global_position = prison.to_global(Vector3(-11.0, PrisonLevel.FLOOR_TOP, -5.5))
		leader.use(cop)
	await wait_physics_frames(3)


func test_the_last_loose_ringleader_runs_off_on_the_food_cart() -> void:
	await _jail(riot.ringleaders.slice(0, 2))
	assert_null(case.chase, "they get a moment first")
	await wait_seconds(PrisonCase.RUN_DELAY + 0.3)
	assert_not_null(case.chase)
	assert_eq(case.chase.truck.kind, SuspectCar.FOOD_CART)
	assert_eq(case.runner, riot.ringleaders[2])
	assert_false(case.runner.visible)
	var others := riot.inmates.filter(func(i: PrisonInmate) -> bool: return i != case.runner)
	assert_false(others.any(func(i: PrisonInmate) -> bool: return i.active), "the canteen holds still to watch")


func test_cuffed_in_time_there_is_no_chase() -> void:
	await _jail(riot.ringleaders.slice(0, 2))
	riot.ringleaders[2].cuffed(Handcuffs.SECONDS)
	await wait_seconds(PrisonCase.RUN_DELAY + 0.3)
	assert_null(case.chase)


func test_caught_on_the_cart_counts_as_jailed_with_the_extra() -> void:
	await _jail(riot.ringleaders.slice(0, 2))
	await wait_seconds(PrisonCase.RUN_DELAY + 0.3)
	case.chase.ended.emit(true)
	assert_true(case.caught)
	assert_true(case.solved())
	assert_eq(case.report().salary, PrisonCase.SALARY + PrisonCase.NO_ESCAPE)


func test_got_away_the_case_is_solved_without_the_extra() -> void:
	await _jail(riot.ringleaders.slice(0, 2))
	await wait_seconds(PrisonCase.RUN_DELAY + 0.3)
	case.chase.ended.emit(false)
	assert_eq(case.escaped, 1)
	assert_true(case.solved())
	assert_eq(case.report().salary, PrisonCase.SALARY)
	assert_true(riot.inmates.filter(func(i: PrisonInmate) -> bool: return i != case.runner).all(
		func(i: PrisonInmate) -> bool: return i.active), "the canteen goes back to it")
