extends GutTest

## The VIP inmate case (carcel-vip.md, step 6): won when his manager takes him, 600 plus 25 for each request in time
## and 50 for each piece found, less 100 for each lawyer; lost if he gets to his limo; drawn in Play with the other
## prison cases.

const LEVEL := preload("res://scenes/levels/prison_vip.tscn")

var prison: PrisonLevel
var case: VipCase
var plan: VipPlan


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 8
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	case = prison.vip_case
	plan = prison.vip
	case.give_tip()


func test_the_comisario_tells_it_and_the_planilla_shows_his_day() -> void:
	assert_not_null(case)
	assert_true(case.tip_given)
	var rows := case.rows()
	assert_eq(rows[0].text, tr("OBJ_VIP_REQUESTS") % [0, VipRequests.REQUESTS])
	assert_false(rows[0].done)
	plan.requests.started = true
	plan.requests.ask_next()
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_true(texts.any(func(text: String) -> bool: return text.begins_with(tr("OBJ_VIP_WANTS").split("%")[0])))


func test_released_it_pays_for_his_day() -> void:
	plan.requests.on_time = 4
	plan.seized = 2
	plan.lawyers = 1
	plan.released_rulo.emit()
	assert_true(case.solved())
	var pay := case.report()
	assert_eq(pay.salary, 600 + 4 * 25 + 2 * 50 - 100)
	assert_true(pay.approved)


func test_too_many_lawyers_and_it_misses_the_quota() -> void:
	plan.lawyers = 3
	plan.released_rulo.emit()
	assert_true(case.solved())
	assert_false(case.report().approved)


func test_if_he_gets_to_his_limo_its_lost() -> void:
	plan.escaped_rulo.emit()
	assert_false(case.solved())
	assert_eq(case.failed_reason, "CASE_FAILED_VIP_ESCAPED")
	assert_eq(case.report().salary, 0)
	plan.released_rulo.emit()
	assert_false(case.solved(), "lost stays lost")


func test_the_shift_ends_with_the_report() -> void:
	plan.released_rulo.emit()
	case.finish_shift()
	assert_true(case.shift_over)


func test_play_draws_it_with_the_other_prisons() -> void:
	assert_has(PlaceDraw.PRISONS, "prison_vip")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "prison_vip":
			drawn = true
			break
	assert_true(drawn)
