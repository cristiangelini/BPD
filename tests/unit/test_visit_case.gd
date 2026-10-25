extends GutTest

## The visiting day case (carcel-visitas.md, step 6): done when the last visitor leaves, 75 less for each thing that
## got to an inmate, 25 less for each innocent thing broken, 25 more for each pass stopped, lost with 3 through; drawn
## in Play with the other prison cases.

const LEVEL := preload("res://scenes/levels/prison_visits.tscn")

var prison: PrisonLevel
var case: VisitCase
var plan: VisitPlan


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	case = prison.visit_case
	plan = prison.visits
	case.give_tip()
	plan.start()


func _end_the_day() -> void:
	plan.end_visit()
	for visitor in plan.visitors:
		visitor.state = PrisonVisitor.State.GONE
	await wait_physics_frames(2)


func test_the_comisario_tells_it() -> void:
	assert_true(case.tip_given)
	assert_eq(case.rows().size(), 6)


func test_the_last_visitor_leaving_solves_it() -> void:
	await _end_the_day()
	assert_true(case.solved())
	assert_eq(case.report().salary, VisitCase.SALARY)
	assert_true(case.report().approved)


func test_what_got_through_and_what_broke_cost_and_stopped_passes_pay() -> void:
	plan._on_passed(plan.visitors[0])
	plan._on_passed(plan.visitors[1])
	plan._on_cried(plan.visitors[2])
	plan._on_stopped(plan.visitors[3])
	await _end_the_day()
	assert_eq(case.report().salary, VisitCase.SALARY - 2 * VisitCase.PER_PASSED - VisitCase.PER_BROKEN
		+ VisitCase.PER_STOPPED)


func test_three_through_loses_it() -> void:
	for i in VisitCase.LOSE_AT:
		plan._on_passed(plan.visitors[i])
	assert_eq(case.failed_reason, "CASE_FAILED_VISITS_PASSED")
	await _end_the_day()
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)


func test_the_planilla_shows_the_clock() -> void:
	assert_string_contains(case.rows()[1].text, "6:00")
	plan.visit_left = 75.0
	assert_string_contains(case.rows()[1].text, "1:15")


func test_the_snapshot_brings_a_guest_up_to_date() -> void:
	plan.confiscated = 2
	plan.broken = 1
	plan.passed = 1
	plan.stopped = 1
	plan.visit_left = 100.0
	var state := case.snapshot()
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 7
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	other.visit_case.follower = true
	other.visit_case.apply_snapshot(state)
	assert_eq(other.visits.confiscated, 2)
	assert_eq(other.visits.broken, 1)
	assert_eq(other.visits.passed, 1)
	assert_eq(other.visits.stopped, 1)
	assert_eq(other.visits.visit_left, 100.0)


func test_drawn_with_the_other_prison_cases() -> void:
	assert_has(PlaceDraw.PRISONS, "visits")
	assert_eq(PlaceDraw.PLACES.visits, "res://scenes/levels/prison_visits.tscn")
