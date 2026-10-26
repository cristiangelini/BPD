class_name GardenCase
extends Node

## The garden case (carcel-huerta.md, step 6): the comisario tells it in his office and Q opens the planilla. Done when
## garden time is over (GardenPlan.ended): SALARY, PER_ESCAPED less for each one over the wall, PER_EARLY more for each
## magic bean pulled before its stage 4, PER_DOWN more for each one pulled off a giant and PER_WRONG less for each
## vegetable pulled by mistake. Quota of its own, like the other prison cases. With LOSE_AT over the wall the case is
## lost. Step 7: online the host's case decides and a guest's follows it (CaseSync, snapshot). Every number here is
## (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 6.0
const SALARY := 600
const PER_ESCAPED := 100
const PER_EARLY := 50
const PER_DOWN := 25
const PER_WRONG := 10
const QUOTA := 400
const LOSE_AT := 3
const STORY := "prison_garden"
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
			prison.garden.follower = value
var online: CaseSync
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("garden_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_GARDEN"))
	prison.garden.escaped_one.connect(_on_escaped.unbind(1))
	prison.garden.ended.connect(_on_ended)
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
			briefing.start(PackedStringArray(["BRIEF_GARDEN_A", "BRIEF_GARDEN_B", "BRIEF_GARDEN_C"]))
			break
	checklist.show_rows(rows())


func solved() -> bool:
	return solved_it and failed_reason == ""


func report() -> Dictionary:
	var salary := 0
	if solved():
		var plan := prison.garden
		salary = maxi(SALARY - PER_ESCAPED * plan.escaped + PER_EARLY * plan.early + PER_DOWN * plan.down
			- PER_WRONG * plan.wrong, 0)
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


func _physics_process(delta: float) -> void:
	if follower or shift_over or not tip_given:
		return
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _on_escaped() -> void:
	if not follower and prison.garden.escaped >= LOSE_AT:
		lose("CASE_FAILED_GARDEN_ESCAPED")
	checklist.show_rows(rows())


func _on_ended() -> void:
	if follower or failed_reason != "" or solved_it:
		return
	solved_it = true
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Too many got over the wall: the shift is over.
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
	return {"tip": tip_given, "plan": prison.garden.net_state(), "solved": solved_it, "failed": failed_reason,
		"result": _result}


func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	prison.garden.apply_net_state(state.plan)
	solved_it = state.solved
	failed_reason = state.failed
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var plan := prison.garden
	var list: Array[Dictionary] = []
	list.append(_row(tr("OBJ_GARDEN_TIME") % ceili(plan.time_left()), plan.over))
	list.append(_row(tr("OBJ_GARDEN_BEANS") % [plan.pulled, GardenPlan.MAGIC], plan.pulled >= GardenPlan.MAGIC))
	list.append(_status(tr("OBJ_GARDEN_ESCAPED") % [plan.escaped, LOSE_AT]))
	list.append({"text": tr("OBJ_GARDEN_DOWN") % plan.down, "done": plan.down > 0, "optional": true, "status": false})
	if plan.wrong > 0:
		list.append(_status(tr("OBJ_GARDEN_WRONG") % plan.wrong))
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
