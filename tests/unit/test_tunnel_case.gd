extends GutTest

## The tunnel case (carcel-tunel.md, step 6): won when the hole is filled with cement, 100 less for each inmate out by
## the far end, 25 more for each one in the punishment cell, 50 more if sealed before the far end shows, lost with 3
## gone; drawn in Play with the other prison cases.

const LEVEL := preload("res://scenes/levels/prison_tunnel.tscn")

var prison: PrisonLevel
var case: TunnelCase
var plan: TunnelPlan


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	case = prison.tunnel_case
	plan = prison.tunnel
	case.give_tip()
	plan.start()


## The hole found and filled, the way a cop does it.
func _seal() -> void:
	var hideout := plan.tunnel_hideout()
	hideout.set_checked(true)
	plan.is_found = true
	var cop: Cop = prison.get_node("Cop")
	var bag := plan.bags[0]
	cop.handed(bag)
	await wait_physics_frames(1)
	hideout.use(cop)
	await wait_physics_frames(2)


func test_the_comisario_tells_it() -> void:
	assert_true(case.tip_given)
	assert_eq(case.rows().size(), 4)
	assert_string_contains(case.rows()[1].text, "30")


func test_sealing_it_early_solves_it_with_the_bonus() -> void:
	await _seal()
	assert_true(plan.is_sealed)
	assert_true(case.solved())
	assert_true(case.sealed_early)
	assert_eq(case.report().salary, TunnelCase.SALARY + TunnelCase.EARLY)
	assert_true(case.report().approved)
	assert_true(case.rows()[0].done)


func test_no_bonus_once_the_far_end_shows() -> void:
	plan.exit.peek_out()
	await _seal()
	assert_true(case.solved())
	assert_false(case.sealed_early)
	assert_eq(case.report().salary, TunnelCase.SALARY)


func test_escapes_cost_and_the_punishment_cell_pays() -> void:
	plan._escape()
	plan._escape()
	plan.caught = 1
	plan.exit.peek_out()
	await _seal()
	assert_eq(case.report().salary, TunnelCase.SALARY - 2 * TunnelCase.PER_ESCAPED + TunnelCase.PER_CAUGHT)
	assert_true(case.report().approved, "just over the quota")


func test_three_gone_loses_it() -> void:
	for i in TunnelCase.LOSE_AT:
		plan._escape()
	assert_eq(case.failed_reason, "CASE_FAILED_TUNNEL_ESCAPED")
	await _seal()
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)


func test_the_planilla_follows_the_tunnel() -> void:
	plan.dug = 12.5
	assert_eq(case.rows()[1].text, tr("OBJ_TUNNEL_LEFT") % [18, 30])
	plan.is_found = true
	assert_eq(case.rows()[2].text, tr("OBJ_TUNNEL_FOUND"))
	plan.dug = TunnelPlan.LENGTH
	assert_eq(case.rows()[1].text, tr("OBJ_TUNNEL_THROUGH"))


func test_play_draws_it_with_the_other_prison_cases() -> void:
	assert_has(PlaceDraw.PRISONS, "prison_tunnel")
	var seen := false
	for i in 2000:
		if PlaceDraw.pick(i + 1, [], 1) == "prison_tunnel":
			seen = true
			break
	assert_true(seen)
