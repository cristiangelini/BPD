class_name VipCase
extends Node

## The VIP inmate case (carcel-vip.md, step 6): the comisario tells it in his office and Q opens the planilla. Won when
## his manager takes Rulo out the gate (VipPlan.released_rulo): SALARY, PER_ON_TIME more for each request brought in
## time, PER_SEIZED more for each piece found and PER_LAWYER less for each time his lawyer came. Lost if he gets out
## the gate to his limo. Quota of its own, like the other prison cases. Step 7: online the host's case decides and a
## guest's follows it (CaseSync, snapshot): the requests, his mood, the pieces, the counts, his door and how it ended.
## Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 6.0
const SALARY := 600
const PER_ON_TIME := 25
const PER_SEIZED := 50
const PER_LAWYER := 100
const QUOTA := 400
const STORY := "prison_vip"
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
			prison.vip.follower = value
var online: CaseSync
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("vip_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_VIP"))
	prison.vip.escaped_rulo.connect(lose.bind("CASE_FAILED_VIP_ESCAPED"))
	prison.vip.released_rulo.connect(_on_released)
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
			briefing.start(PackedStringArray(["BRIEF_VIP_A", "BRIEF_VIP_B", "BRIEF_VIP_C"]))
			break
	checklist.show_rows(rows())


func solved() -> bool:
	return solved_it and failed_reason == ""


## SALARY, plus PER_ON_TIME for each request in time and PER_SEIZED for each piece found, less PER_LAWYER for each
## lawyer.
func report() -> Dictionary:
	var salary := 0
	if solved():
		var plan := prison.vip
		salary = maxi(SALARY + PER_ON_TIME * plan.requests.on_time + PER_SEIZED * plan.seized
			- PER_LAWYER * plan.lawyers, 0)
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


func _physics_process(delta: float) -> void:
	if follower or shift_over or not tip_given:
		return
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _on_released() -> void:
	if follower or failed_reason != "" or solved_it:
		return
	solved_it = true
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## He got to his limo: the shift is over.
func lose(reason: String) -> void:
	if follower or failed_reason != "" or solved_it:
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
	return {"tip": tip_given, "plan": prison.vip.net_state(), "solved": solved_it, "failed": failed_reason,
		"result": _result}


func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	prison.vip.apply_net_state(state.plan)
	solved_it = state.solved
	failed_reason = state.failed
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var plan := prison.vip
	var list: Array[Dictionary] = []
	list.append(_row(tr("OBJ_VIP_REQUESTS") % [plan.requests.asked - plan.requests.open.size(), VipRequests.REQUESTS],
		plan.requests.finished))
	list.append(_row(tr("OBJ_VIP_RELEASED"), plan.released))
	list.append(_status(tr("OBJ_VIP_MOOD") % plan.requests.mood))
	for each in plan.requests.open:
		list.append(_status(tr("OBJ_VIP_WANTS") % [tr("VIP_WANT_%s" % VipRequests.Kind.keys()[each.kind]),
			ceili(each.left)]))
	list.append({"text": tr("OBJ_VIP_ON_TIME") % plan.requests.on_time, "done": plan.requests.on_time > 0,
		"optional": true, "status": false})
	list.append({"text": tr("OBJ_VIP_SEIZED") % [plan.seized, VipPlan.PIECES.size()], "done": plan.seized > 0,
		"optional": true, "status": false})
	if plan.lawyers > 0:
		list.append(_status(tr("OBJ_VIP_LAWYERS") % plan.lawyers))
	if plan.runner:
		list.append(_status(tr("OBJ_VIP_RUNNING")))
	if failed_reason != "":
		list.append({"text": failed_reason, "done": false, "optional": false, "status": true})
	return list


func _status(text: String) -> Dictionary:
	return {"text": text, "done": false, "optional": false, "status": true}


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
