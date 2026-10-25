class_name BlackoutCase
extends Node

## The blackout case (carcel-corte-de-luz.md, step 6): the comisario tells it in his office and Q opens the planilla.
## Solved when the light comes back (the three fuses in, BlackoutPlan.lights_back): SALARY, PER_ESCAPED less for each
## inmate who got out through the gate and CHISPA_BONUS more with El Chispa shut in the punishment cell; quota of its
## own, like the riot's. With LOSE_AT inmates escaped the case is lost. No time limit (decision 66). Every number here
## is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_ESCAPED := 75
const CHISPA_BONUS := 100
const QUOTA := 400
const LOSE_AT := 4
const STORY := "prison_blackout"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var prison: PrisonLevel
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var solved_it := false
var failed_reason := ""
var shift_over := false
var follower := false
var online: CaseSync
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("blackout_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_BLACKOUT"))
	prison.blackout.inmate_escaped.connect(_on_escaped.unbind(1))
	prison.blackout.lights_came_back.connect(_on_lights_back)
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
			briefing.start(PackedStringArray(["BRIEF_BLACKOUT_A", "BRIEF_BLACKOUT_B", "BRIEF_BLACKOUT_C"]))
			break
	checklist.show_rows(rows())


func escaped() -> int:
	return prison.blackout.escaped


func solved() -> bool:
	return solved_it and failed_reason == ""


## SALARY, less PER_ESCAPED for each inmate who got out, and CHISPA_BONUS with El Chispa in the punishment cell.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = maxi(SALARY - PER_ESCAPED * escaped(), 0)
		if prison.blackout.chispa_punished():
			salary += CHISPA_BONUS
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
		lose("CASE_FAILED_BLACKOUT_ESCAPED")
	checklist.show_rows(rows())


func _on_lights_back() -> void:
	if follower or failed_reason != "" or solved_it:
		return
	solved_it = true
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Too many got away: the shift is over.
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
	var plan := prison.blackout
	var list: Array[Dictionary] = []
	var filled := prison.fuse_board.filled if prison.fuse_board else 0
	list.append(_row(tr("OBJ_BLACKOUT_FUSES") % [filled, FuseBoard.SLOTS], plan.lights_on))
	list.append({"text": tr("OBJ_BLACKOUT_LOCKED") % [plan.count_locked_in(), BlackoutPlan.INMATES], "done": false,
		"optional": false, "status": true})
	list.append({"text": tr("OBJ_BLACKOUT_ESCAPED") % [escaped(), LOSE_AT], "done": false, "optional": false,
		"status": true})
	list.append({"text": "OBJ_BLACKOUT_CHISPA", "done": plan.chispa_punished(), "optional": true, "status": false})
	if failed_reason != "":
		list.append({"text": failed_reason, "done": false, "optional": false, "status": true})
	return list


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
