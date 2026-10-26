extends GutTest

## The talent show case (carcel-talentos.md, step 6): done when the show ends, 100 less for each inmate gone, 25 more
## for each one in the punishment cell and 20 for each act voted, lost with 3 gone; drawn in Play with the other
## prison cases.

const LEVEL := preload("res://scenes/levels/prison_talent.tscn")

var prison: PrisonLevel
var case: TalentCase
var plan: TalentPlan


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	case = prison.talent_case
	plan = prison.talent
	case.give_tip()


## The whole show, with a cop at the jury table for `voting` acts.
func _whole_show(voting := TalentPlan.SHOW) -> void:
	var cop: Cop = prison.get_node("Cop")
	plan.start()
	for act in TalentPlan.SHOW:
		if act < voting and not plan.chairs[0].sitter:
			plan.chairs[0].use(cop)
		elif act >= voting and plan.chairs[0].sitter:
			plan.chairs[0].stand_up()
		for i in 4:
			plan.phase_left = 0.0
			await wait_physics_frames(2)
	assert_true(plan.is_over())


func test_the_comisario_tells_it() -> void:
	assert_true(case.tip_given)
	assert_eq(case.rows()[1].text, tr("OBJ_TALENT_WAITING"))


func test_the_end_of_the_show_solves_it() -> void:
	await _whole_show()
	assert_true(case.solved())
	assert_eq(case.report().salary, TalentCase.SALARY + TalentCase.PER_VOTE * TalentPlan.SHOW)
	assert_true(case.report().approved)
	assert_true(case.rows()[0].done)


func test_escapes_cost_and_the_punishment_cell_pays() -> void:
	plan.tricks._on_runner_escaped()
	plan.tricks._on_runner_escaped()
	plan.tricks.caught = 1
	await _whole_show(2)
	assert_eq(case.report().salary,
		TalentCase.SALARY - 2 * TalentCase.PER_ESCAPED + TalentCase.PER_CAUGHT + 2 * TalentCase.PER_VOTE)
	assert_true(case.report().approved, "just over the quota")


func test_three_gone_loses_it() -> void:
	for i in TalentCase.LOSE_AT:
		plan.tricks._on_runner_escaped()
	assert_eq(case.failed_reason, "CASE_FAILED_TALENT_ESCAPED")
	await _whole_show()
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)


func test_the_planilla_follows_the_show() -> void:
	plan.start()
	for i in 2:
		plan.phase_left = 0.0
		await wait_physics_frames(2)
	assert_eq(plan.phase, TalentPlan.Phase.ACT)
	assert_eq(case.rows()[0].text, tr("OBJ_TALENT_SHOW") % [1, TalentPlan.SHOW])
	assert_eq(case.rows()[1].text, tr("OBJ_TALENT_NOW") % tr("TALENT_ACT_%s" % plan.acts[0].to_upper()))


func test_play_draws_it_with_the_other_prison_cases() -> void:
	assert_has(PlaceDraw.PRISONS, "prison_talent")
	var seen := false
	for i in 3000:
		if PlaceDraw.pick(i + 1, [], 1) == "prison_talent":
			seen = true
			break
	assert_true(seen)
