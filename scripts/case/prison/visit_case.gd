class_name VisitCase
extends Node

## The visiting day case (carcel-visitas.md, step 6): the comisario tells it in his office and Q opens the planilla.
## Done when the last visitor has left after the bell (VisitPlan.ended): SALARY, PER_PASSED less for each hidden thing
## that got to an inmate, PER_BROKEN less for each innocent thing opened for nothing and PER_STOPPED more for each pass
## under the table stopped; quota of its own, like the other prison cases. With LOSE_AT things through the case is lost.
## Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_PASSED := 75
const PER_BROKEN := 25
const PER_STOPPED := 25
const QUOTA := 400
const LOSE_AT := 3
const STORY := "prison_visits"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var prison: PrisonLevel
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var solved_it := false
var failed_reason := ""
var shift_over := false
var follower := false:
	set(value):
		follower = value
		if prison:
			prison.visits.follower = value
var online: CaseSync
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("visit_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_VISITS"))
	prison.visits.got_through.connect(_on_got_through.unbind(1))
	prison.visits.ended.connect(_on_ended)
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if shift_screen:
		shift_screen.play_again.connect(_play_again)
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func _play_again() -> void:
	if online:
		online.play_again()
	else:
		PlaceDraw.start(get_tree())


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_VISITS_A", "BRIEF_VISITS_B", "BRIEF_VISITS_C"]))
			break
	checklist.show_rows(rows())


func passed() -> int:
	return prison.visits.passed


func solved() -> bool:
	return solved_it and failed_reason == ""


## SALARY, less PER_PASSED for each thing that got through and PER_BROKEN for each innocent thing broken, plus
## PER_STOPPED for each pass stopped under the table.
func report() -> Dictionary:
	var salary := 0
	if solved():
		var plan := prison.visits
		salary = maxi(SALARY - PER_PASSED * passed() - PER_BROKEN * plan.broken, 0) + PER_STOPPED * plan.stopped
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


func _physics_process(delta: float) -> void:
	if follower or shift_over or not tip_given:
		return
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _on_got_through() -> void:
	if not follower and passed() >= LOSE_AT:
		lose("CASE_FAILED_VISITS_PASSED")
	checklist.show_rows(rows())


func _on_ended() -> void:
	if follower or failed_reason != "" or solved_it:
		return
	solved_it = true
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Too many things got through: the shift is over.
func lose(reason: String) -> void:
	if failed_reason != "" or solved_it:
		return
	failed_reason = reason
	_hint_all(reason)
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func finish_shift() -> void:
	if shift_over or follower:
		return
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	var pay := report()
	var result := {"solved": solved(), "report": pay, "awards": ShiftReport.awards(stats)}
	var campaign := Campaign.current
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.finish_shift(STORY, solved(), pay, QUOTA)
		campaign.save()
		result.campaign = {"shift": played, "money": campaign.money, "over": campaign.is_over(),
			"promoted": campaign.is_promoted()}
	_show_result(result)


func _show_result(result: Dictionary) -> void:
	shift_over = true
	_result = result
	if not shift_screen:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	var awards: Array[Dictionary] = []
	awards.assign(result.awards)
	shift_screen.show_report(result.solved, result.report, 0, awards)
	var over := false
	if result.has("campaign"):
		shift_screen.show_campaign(result.campaign.shift, Campaign.SHIFTS, result.campaign.money, result.campaign.over,
			result.campaign.promoted)
		over = result.campaign.over
	shift_screen.get_node("%AgainButton").visible = not over and not follower


## What every guest's case shows (CaseSync).
func snapshot() -> Dictionary:
	var plan := prison.visits
	return {"tip": tip_given, "running": plan.running, "counts": [plan.confiscated, plan.broken, plan.passed,
		plan.stopped], "left": plan.visit_left, "over": plan.is_over, "solved": solved_it, "failed": failed_reason,
		"result": _result}


func apply_snapshot(state: Dictionary) -> void:
	var plan := prison.visits
	if state.tip:
		give_tip()
	plan.running = state.running
	plan.confiscated = state.counts[0]
	plan.broken = state.counts[1]
	plan.passed = state.counts[2]
	plan.stopped = state.counts[3]
	plan.visit_left = state.left
	plan.is_over = state.over
	solved_it = state.solved
	failed_reason = state.failed
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var plan := prison.visits
	var list: Array[Dictionary] = []
	var gone_in := VisitPlan.VISITORS - plan.line.size()
	list.append(_row(tr("OBJ_VISITS_SEARCHED") % [gone_in, VisitPlan.VISITORS], plan.line.is_empty()))
	list.append(_row(tr("OBJ_VISITS_TIME") % _clock(plan.visit_left), plan.is_over))
	list.append(_status(tr("OBJ_VISITS_CONFISCATED") % plan.confiscated))
	list.append(_status(tr("OBJ_VISITS_BROKEN") % plan.broken))
	list.append(_status(tr("OBJ_VISITS_PASSED") % [passed(), LOSE_AT]))
	list.append({"text": tr("OBJ_VISITS_STOPPED") % plan.stopped, "done": plan.stopped > 0, "optional": true,
		"status": false})
	if failed_reason != "":
		list.append({"text": failed_reason, "done": false, "optional": false, "status": true})
	return list


## The visit's clock, m:ss (the whole visit before it starts).
func _clock(seconds: float) -> String:
	var left := ceili(VisitPlan.VISIT_TIME if seconds < 0.0 else seconds)
	return "%d:%02d" % [left / 60, left % 60]


func _status(text: String) -> Dictionary:
	return {"text": text, "done": false, "optional": false, "status": true}


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
