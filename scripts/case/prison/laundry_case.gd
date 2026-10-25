class_name LaundryCase
extends Node

## The laundry case (carcel-lavanderia.md, step 6): the comisario tells it in his office and Q opens the planilla.
## Done when the truck leaves after its last trip (LaundryPlan.ended): SALARY, PER_ESCAPED less for each inmate gone
## (through the gate or up the ramp) and PER_CAUGHT more for each one walked into the punishment cell; quota of its own,
## like the other prison cases. With LOSE_AT gone the case is lost. Step 7: online the host's case decides and a
## guest's follows it (CaseSync, snapshot): the trip, the clock, the counts, the truck, who's in a machine and how it
## ended. The workers, the carts and the runners go by NpcSync, E and R on the carts and machines by ActionSync.
## Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_ESCAPED := 75
const PER_CAUGHT := 25
const QUOTA := 400
const LOSE_AT := 3
const STORY := "prison_laundry"
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
			prison.laundry.follower = value
var online: CaseSync
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("laundry_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_LAUNDRY"))
	prison.laundry.escaped_one.connect(_on_escaped.unbind(1))
	prison.laundry.ended.connect(_on_ended)
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
			briefing.start(PackedStringArray(["BRIEF_LAUNDRY_A", "BRIEF_LAUNDRY_B", "BRIEF_LAUNDRY_C"]))
			break
	checklist.show_rows(rows())


func escaped() -> int:
	return prison.laundry.escaped


func solved() -> bool:
	return solved_it and failed_reason == ""


## SALARY, less PER_ESCAPED for each inmate gone, plus PER_CAUGHT for each one walked into the punishment cell.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = maxi(SALARY - PER_ESCAPED * escaped(), 0) + PER_CAUGHT * prison.laundry.caught
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


func _physics_process(delta: float) -> void:
	if follower or shift_over or not tip_given:
		return
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _on_escaped() -> void:
	if not follower and escaped() >= LOSE_AT:
		lose("CASE_FAILED_LAUNDRY_ESCAPED")
	checklist.show_rows(rows())


func _on_ended() -> void:
	if follower or failed_reason != "" or solved_it:
		return
	solved_it = true
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Too many inmates got away: the shift is over.
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
	var plan := prison.laundry
	return {"tip": tip_given, "running": plan.running, "trip": plan.trip_now, "next": plan.next_trip_in,
		"counts": [plan.found, plan.caught, plan.escaped], "over": plan.is_over, "solved": solved_it,
		"failed": failed_reason, "truck": plan.truck.here, "machines": plan.machines_occupied(), "result": _result}


func apply_snapshot(state: Dictionary) -> void:
	var plan := prison.laundry
	if state.tip:
		give_tip()
	plan.running = state.running
	plan.trip_now = state.trip
	plan.next_trip_in = state.next
	plan.found = state.counts[0]
	plan.caught = state.counts[1]
	plan.escaped = state.counts[2]
	plan.is_over = state.over
	if state.truck and not plan.truck.here:
		plan.truck.arrive()
	elif not state.truck and plan.truck.here:
		plan.truck.leave()
	plan.apply_machines(state.machines)
	solved_it = state.solved
	failed_reason = state.failed
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var plan := prison.laundry
	var list: Array[Dictionary] = []
	list.append(_row(tr("OBJ_LAUNDRY_TRIPS") % [plan.trip_now + 1, LaundryPlan.TRIPS], plan.is_over))
	if plan.trip_now < LaundryPlan.TRIPS - 1:
		list.append(_status(tr("OBJ_LAUNDRY_NEXT") % _clock(plan.next_trip_in)))
	else:
		list.append(_status(tr("OBJ_LAUNDRY_LAST")))
	list.append(_status(tr("OBJ_LAUNDRY_FOUND") % plan.found))
	list.append(_status(tr("OBJ_LAUNDRY_ESCAPED") % [escaped(), LOSE_AT]))
	list.append({"text": tr("OBJ_LAUNDRY_CAUGHT") % plan.caught, "done": plan.caught > 0, "optional": true,
		"status": false})
	if failed_reason != "":
		list.append({"text": failed_reason, "done": false, "optional": false, "status": true})
	return list


## Seconds to the next truck, m:ss.
func _clock(seconds: float) -> String:
	var left := ceili(maxf(seconds, 0.0))
	return "%d:%02d" % [left / 60, left % 60]


func _status(text: String) -> Dictionary:
	return {"text": text, "done": false, "optional": false, "status": true}


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
