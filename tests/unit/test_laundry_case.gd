extends GutTest

## The laundry case (carcel-lavanderia.md, step 6): done when the truck leaves after its last trip, 75 less for each
## inmate gone, 25 more for each one in the punishment cell, lost with 3 gone; drawn in Play with the other prison cases.

const LEVEL := preload("res://scenes/levels/prison_laundry.tscn")

var prison: PrisonLevel
var case: LaundryCase
var plan: LaundryPlan


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	case = prison.laundry_case
	plan = prison.laundry
	case.give_tip()
	plan.start()


## Every trip comes and every cart goes up the ramp, the hidden ones emptied first so nobody gets away.
func _end_the_day(empty_first := true) -> void:
	for trip in LaundryPlan.TRIPS:
		plan.start_trip()
		for cart in plan.carts_on_trip(trip):
			if empty_first:
				cart.hidden = false
			cart.load_up()
	await wait_physics_frames(2)


func test_the_comisario_tells_it() -> void:
	assert_true(case.tip_given)
	assert_eq(case.rows().size(), 5)


func test_the_last_trip_solves_it() -> void:
	await _end_the_day()
	assert_true(case.solved())
	assert_eq(case.report().salary, LaundryCase.SALARY)
	assert_true(case.report().approved)


func test_escapes_cost_and_the_punishment_cell_pays() -> void:
	plan._escape()
	plan._escape()
	var cart := plan.carts.filter(func(c: LaundryCart) -> bool: return c.hidden)[0] as LaundryCart
	cart.tip(1.0)
	var runner := plan.runners[0]
	plan._on_caught(runner)
	plan._on_caught(runner)
	assert_eq(plan.caught, 1, "once each")
	await _end_the_day()
	assert_eq(case.report().salary, LaundryCase.SALARY - 2 * LaundryCase.PER_ESCAPED + LaundryCase.PER_CAUGHT)


func test_three_gone_loses_it() -> void:
	for i in LaundryCase.LOSE_AT:
		plan._escape()
	assert_eq(case.failed_reason, "CASE_FAILED_LAUNDRY_ESCAPED")
	await _end_the_day()
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)


func test_the_planilla_shows_the_next_truck() -> void:
	plan.next_trip_in = 75.0
	assert_string_contains(case.rows()[1].text, "1:15")
	plan.trip_now = LaundryPlan.TRIPS - 1
	assert_eq(case.rows()[1].text, tr("OBJ_LAUNDRY_LAST"))


func test_the_snapshot_brings_a_guest_up_to_date() -> void:
	plan.trip_now = 1
	plan.next_trip_in = 50.0
	plan.found = 3
	plan.caught = 1
	plan.escaped = 1
	var state := case.snapshot()
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 7
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	other.laundry_case.follower = true
	other.laundry_case.apply_snapshot(state)
	assert_true(other.laundry.follower)
	assert_eq(other.laundry.trip_now, 1)
	assert_almost_eq(other.laundry.next_trip_in, 50.0, 0.01)
	assert_eq([other.laundry.found, other.laundry.caught, other.laundry.escaped], [3, 1, 1])


func test_play_draws_it_with_the_other_prison_cases() -> void:
	assert_has(PlaceDraw.PRISONS, "laundry")
	var seen := false
	for i in 400:
		if PlaceDraw.pick(i + 1, [], 1) == "laundry":
			seen = true
			break
	assert_true(seen)
