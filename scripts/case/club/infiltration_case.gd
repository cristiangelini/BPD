class_name InfiltrationCase
extends Node

## The grandparents' club case (infiltracion.md, step 6): the comisario tells it in his office, Q opens the planilla,
## the cops go in disguised, gather the evidence (`found`, step 6b) and cuff Doña Chela. Cuffed, the case is solved and
## pays SALARY, a third less for each piece of evidence missing; quota of its own, like the chase (decision 91).
## Found out (ClubSuspicion), she runs off (step 6c). Online the host's case decides and the guests' follow it
## (CaseSync). Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 3.0
const SALARY := 600
const EVIDENCE := 3
## Two pieces of evidence of three pass the shift.
const QUOTA := 400
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var case_seed := 0
var club: GrandpaClub
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
## A disguised cop got inside the club.
var got_in := false
var evidence_found: Array[String] = []
var chela_cuffed := false
var found_out := false
var shift_over := false
var follower := false
var online: CaseSync
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("infiltration")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_CLUB"))
	if club:
		club.suspicion.discovered.connect(_on_discovered.unbind(1))
		club.chela.cuffed_now.connect(_on_chela_cuffed.unbind(1))
		for member in club.members:
			member.cuffed_now.connect(_on_grandparent_cuffed)
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
			briefing.start(PackedStringArray(["BRIEF_CLUB_A", "BRIEF_CLUB_B", "BRIEF_CLUB_C"]))
			break
	checklist.show_rows(rows())


## The cops found a piece of evidence (step 6b). Returns whether it's new.
func found(kind: String) -> bool:
	if follower or evidence_found.has(kind) or evidence_found.size() >= EVIDENCE:
		return false
	evidence_found.append(kind)
	_hint_all("HINT_CLUB_EVIDENCE")
	checklist.show_rows(rows())
	return true


func _on_chela_cuffed() -> void:
	if follower or chela_cuffed or shift_over:
		return
	chela_cuffed = true
	_hint_all("HINT_CHELA_CUFFED")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Cuffing anyone else gives the cops away at once.
func _on_grandparent_cuffed(member: ClubMember) -> void:
	if follower or not club or club.suspicion.found_out:
		return
	club.suspicion.raise(member, 100.0)


func _on_discovered() -> void:
	found_out = true
	checklist.show_rows(rows())


func solved() -> bool:
	return chela_cuffed


## The pay: SALARY with all the evidence, a third less for each piece missing.
func report() -> Dictionary:
	var salary := SALARY * evidence_found.size() / EVIDENCE if solved() else 0
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


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
		campaign.finish_shift("infiltration_club", solved(), pay, QUOTA)
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
	return {"tip": tip_given, "in": got_in, "found": evidence_found.duplicate(), "cuffed": chela_cuffed,
		"found_out": found_out, "result": _result}


func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	got_in = state["in"]
	evidence_found.assign(state.found)
	if state.cuffed and not chela_cuffed:
		chela_cuffed = true
		_hint_all("HINT_CHELA_CUFFED")
	found_out = state.found_out
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_CLUB_GET_IN", got_in))
	list.append(_row(tr("OBJ_CLUB_EVIDENCE") % [evidence_found.size(), EVIDENCE], evidence_found.size() >= EVIDENCE))
	for kind in evidence_found:
		list.append({"text": "- " + tr("EVIDENCE_CLUB_" + kind), "done": false, "optional": false, "status": true,
			"clue": true})
	list.append(_row("OBJ_CLUB_CUFF_CHELA", chela_cuffed))
	if found_out:
		list.append({"text": "OBJ_CLUB_FOUND_OUT", "done": false, "optional": false, "status": true})
	else:
		list.append({"text": "OBJ_CLUB_CAREFUL", "done": false, "optional": false, "status": true})
	return list


func _physics_process(delta: float) -> void:
	if not tip_given or not club:
		return
	if not got_in and not follower:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if cop.is_disguised() and club.suspicion.inside.call(cop.global_position):
				got_in = true
				_hint_all("HINT_CLUB_IN")
				checklist.show_rows(rows())
				break
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
