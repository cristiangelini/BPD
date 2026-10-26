class_name TunnelCase
extends Node

## The tunnel case (carcel-tunel.md, step 6): the comisario tells it in his office and Q opens the planilla, with the
## metres the tunnel still needs. Won when the hole is filled with cement (TunnelPlan.sealed): SALARY, PER_ESCAPED less
## for each inmate out by the far end, PER_CAUGHT more for each one in the punishment cell and EARLY more if it was
## sealed before the far end showed outside the wall. Quota of its own, like the other prison cases. With LOSE_AT gone
## the case is lost. Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_ESCAPED := 100
const PER_CAUGHT := 25
const EARLY := 50
const QUOTA := 400
const LOSE_AT := 3
const STORY := "prison_tunnel"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var prison: PrisonLevel
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var solved_it := false
## Sealed before the far end showed outside the wall.
var sealed_early := false
var failed_reason := ""
var shift_over := false
var follower := false:
	set(value):
		follower = value
		if prison:
			prison.tunnel.follower = value
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("tunnel_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_TUNNEL"))
	prison.tunnel.escaped_one.connect(_on_escaped.unbind(1))
	prison.tunnel.sealed.connect(_on_sealed)
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if shift_screen:
		shift_screen.play_again.connect(PlaceDraw.start.bind(get_tree()))
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_TUNNEL_A", "BRIEF_TUNNEL_B", "BRIEF_TUNNEL_C"]))
			break
	checklist.show_rows(rows())


func escaped() -> int:
	return prison.tunnel.escaped


func solved() -> bool:
	return solved_it and failed_reason == ""


## SALARY, less PER_ESCAPED for each inmate gone, plus PER_CAUGHT for each one in the punishment cell and EARLY if it
## was sealed before the far end showed.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = maxi(SALARY - PER_ESCAPED * escaped(), 0) + PER_CAUGHT * prison.tunnel.caught
		if sealed_early:
			salary += EARLY
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
		lose("CASE_FAILED_TUNNEL_ESCAPED")
	checklist.show_rows(rows())


func _on_sealed() -> void:
	if follower or failed_reason != "" or solved_it:
		return
	solved_it = true
	sealed_early = not prison.tunnel.exit.is_showing()
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


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var plan := prison.tunnel
	var list: Array[Dictionary] = []
	list.append(_row(tr("OBJ_TUNNEL_SEAL"), plan.is_sealed))
	if plan.is_sealed:
		list.append(_status(tr("OBJ_TUNNEL_SEALED")))
	elif plan.is_through():
		list.append(_status(tr("OBJ_TUNNEL_THROUGH")))
	else:
		list.append(_status(tr("OBJ_TUNNEL_LEFT") % [ceili(plan.left_to_dig()), roundi(TunnelPlan.LENGTH)]))
	if plan.is_found and not plan.is_sealed:
		list.append(_status(tr("OBJ_TUNNEL_FOUND")))
	list.append(_status(tr("OBJ_TUNNEL_ESCAPED") % [escaped(), LOSE_AT]))
	list.append({"text": tr("OBJ_TUNNEL_CAUGHT") % plan.caught, "done": plan.caught > 0, "optional": true,
		"status": false})
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
