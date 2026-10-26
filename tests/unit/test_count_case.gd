extends GutTest

## The count case (carcel-recuento.md, step 6): done when the whole list is crossed off at once, 100 less for each one
## out through the gate, 25 more for each hidden one found before he ran and 10 less for each worker chalked; lost
## with 2 out through the gate or when the time is up; drawn in Play with the other prison cases.

const LEVEL := preload("res://scenes/levels/prison_count.tscn")

var prison: PrisonLevel
var case: CountCase
var plan: CountPlan
var cop: Cop


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 4
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	case = prison.count_case
	plan = prison.count
	case.give_tip()


func _count_all() -> void:
	for inmate in plan.inmates.duplicate():
		inmate.use(cop)
	for number in plan.hidden:
		plan.hidden_in[number].use(cop)


func test_the_planilla_shows_the_count() -> void:
	assert_true(case.tip_given)
	var rows := case.rows()
	assert_eq(rows[0].text, tr("OBJ_COUNT_TIME") % int(CountPlan.TIME))
	assert_eq(rows[1].text, tr("OBJ_COUNT_LIST") % [0, CountPlan.LIST])
	plan.inmates[0].use(cop)
	plan.workers[0].use(cop)
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, tr("OBJ_COUNT_LIST") % [1, CountPlan.LIST])
	assert_has(texts, tr("OBJ_COUNT_WRONG") % 1)


func test_the_whole_list_wins_it() -> void:
	plan.start()
	_count_all()
	await wait_physics_frames(3)
	assert_true(plan.over)
	assert_true(case.solved())
	assert_true(case.rows()[1].done)


func test_the_pay() -> void:
	plan.found = 2
	plan.escaped = 1
	plan.wrong = 3
	plan.completed.emit()
	var pay := case.report()
	assert_eq(pay.salary, 600 - 100 + 2 * 25 - 3 * 10)
	assert_true(pay.approved)


func test_two_out_and_its_lost() -> void:
	for i in CountCase.LOSE_AT:
		plan.run(plan.hidden[i])._escape()
	assert_eq(case.failed_reason, "CASE_FAILED_COUNT_ESCAPED")
	plan.completed.emit()
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)


func test_time_up_and_its_lost() -> void:
	plan.start()
	plan.time = CountPlan.TIME - 0.01
	await wait_physics_frames(3)
	assert_true(plan.over)
	assert_eq(case.failed_reason, "CASE_FAILED_COUNT_TIME")
	assert_false(case.solved())


func test_the_shift_ends_with_the_report() -> void:
	plan.completed.emit()
	case.finish_shift()
	assert_true(case.shift_over)


func test_play_draws_it_with_the_other_prisons() -> void:
	assert_has(PlaceDraw.PRISONS, "prison_count")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "prison_count":
			drawn = true
			break
	assert_true(drawn)
