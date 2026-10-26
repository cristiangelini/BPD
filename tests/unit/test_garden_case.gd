extends GutTest

## The garden case (carcel-huerta.md, step 6): done when garden time is over, 100 less for each one over the wall, 50
## more for each bean pulled early, 25 for each one pulled off a giant and 10 less for each vegetable pulled by
## mistake; lost with 3 over the wall; drawn in Play with the other prison cases.

const LEVEL := preload("res://scenes/levels/prison_garden.tscn")

var prison: PrisonLevel
var case: GardenCase
var plan: GardenPlan


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 9
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	case = prison.garden_case
	plan = prison.garden
	case.give_tip()


func test_the_planilla_shows_the_garden() -> void:
	assert_true(case.tip_given)
	var rows := case.rows()
	assert_eq(rows[0].text, tr("OBJ_GARDEN_TIME") % int(GardenPlan.TIME))
	assert_eq(rows[1].text, tr("OBJ_GARDEN_BEANS") % [0, GardenPlan.MAGIC])
	plan.wrong = 1
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, tr("OBJ_GARDEN_WRONG") % 1)


func test_garden_time_ends_it() -> void:
	plan.start()
	plan.time = GardenPlan.TIME - 0.01
	await wait_physics_frames(3)
	assert_true(plan.over)
	assert_true(case.solved())
	assert_true(case.rows()[0].done)


func test_the_pay() -> void:
	plan.escaped = 1
	plan.early = 2
	plan.down = 2
	plan.wrong = 3
	plan.ended.emit()
	var pay := case.report()
	assert_eq(pay.salary, 600 - 100 + 2 * 50 + 2 * 25 - 3 * 10)
	assert_true(pay.approved)


func test_three_over_the_wall_and_its_lost() -> void:
	for i in GardenCase.LOSE_AT:
		plan.escaped += 1
		plan.escaped_one.emit(plan.escaped)
	assert_eq(case.failed_reason, "CASE_FAILED_GARDEN_ESCAPED")
	plan.ended.emit()
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)


func test_the_shift_ends_with_the_report() -> void:
	plan.ended.emit()
	case.finish_shift()
	assert_true(case.shift_over)


func test_play_draws_it_with_the_other_prisons() -> void:
	assert_has(PlaceDraw.PRISONS, "prison_garden")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "prison_garden":
			drawn = true
			break
	assert_true(drawn)
