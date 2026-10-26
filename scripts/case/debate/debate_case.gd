class_name DebateCase
extends Node

## The TV debate as a case (politico-debate.md, step 5, decision 230): the comisario tells it in his office, Q opens
## the planilla, and the clock is the debate (TvDebate). The case is solved if Lustre's image ends at PASS or more; it
## pays SALARY, BLUNDER less for each blunder on air, WRONG_CUFF less for each honest technician cuffed and TECHNICIAN
## more if the bought one is in the patrol car; quota of its own, like the plaza (decision 103). With the bought
## technician cuffed or taken away there are no more tricks. A trick warned while a cop is in the control room shows
## whose place the warning light is at (his third clue). Every number here is (propuesta).

const SHIFT_DELAY := 4.0
const REFRESH := 0.5
const SALARY := 600
const BLUNDER := 50
const WRONG_CUFF := 100
const TECHNICIAN := 100
const QUOTA := 400
const PASS := 50
const CLUES := 2
const STORY := "politician_debate"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var studio: TvStudio
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var clues: Array[String] = []
var wrong_cuffs := 0
var jailed := false
var shift_over := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("debate_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_DEBATE"))
	studio.debate.finished.connect(_on_finished)
	studio.sabotage.warned.connect(_on_warned.unbind(1))
	for tech in studio.technicians:
		tech.found_clue.connect(_on_clue)
		tech.wrongly_cuffed.connect(_on_wrong_cuff)
	studio.technician.cuffed_now.connect(_stop_tricks)
	OwnerEscort.of(studio.technician).boarded.connect(_on_jailed)
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if shift_screen:
		shift_screen.play_again.connect(func() -> void: PlaceDraw.start(get_tree()))
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_DEBATE_A", "BRIEF_DEBATE_B", "BRIEF_DEBATE_C"]))
			break
	checklist.show_rows(rows())


## The warning light goes on at the bought technician's place: a cop up in the control room sees whose.
func _on_warned() -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		if studio.in_control_room((cop as Node3D).global_position):
			studio.technician.light_seen(cop as Cop)
			return


func _on_clue(kind: String) -> void:
	if not clues.has(kind):
		clues.append(kind)
	checklist.show_rows(rows())


func _on_wrong_cuff() -> void:
	wrong_cuffs += 1
	_hint_all("HINT_TECH_WRONG_CUFF")
	checklist.show_rows(rows())


func _stop_tricks() -> void:
	studio.sabotage.active = false
	_hint_all("HINT_TECH_CUFFED")
	checklist.show_rows(rows())


func _on_jailed() -> void:
	jailed = true
	studio.sabotage.active = false
	checklist.show_rows(rows())


func _on_finished() -> void:
	_hint_all("HINT_DEBATE_WON" if solved() else "HINT_DEBATE_LOST")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func solved() -> bool:
	return studio.debate.state == TvDebate.State.OVER and studio.debate.image >= PASS


## SALARY, less BLUNDER for each blunder and WRONG_CUFF for each honest technician cuffed, plus TECHNICIAN if the
## bought one is in the patrol car; nothing if the debate went badly.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = SALARY - BLUNDER * studio.debate.blunders - WRONG_CUFF * wrong_cuffs + (TECHNICIAN if jailed else 0)
		salary = maxi(salary, 0)
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


func finish_shift() -> void:
	if shift_over:
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
	shift_screen.get_node("%AgainButton").visible = not over


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var debate := studio.debate
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_DEBATE_ON", debate.state != TvDebate.State.WAITING))
	list.append(_row(tr("OBJ_DEBATE_IMAGE") % [debate.image, PASS], debate.image >= PASS))
	list.append(_row(tr("OBJ_DEBATE_CLUES") % [clues.size(), CLUES], clues.size() >= CLUES))
	list.append(_row("OBJ_DEBATE_TECHNICIAN", jailed))
	var state := tr("OBJ_DEBATE_BLUNDERS") % debate.blunders
	if debate.state == TvDebate.State.OVER:
		state = "OBJ_DEBATE_OVER"
	list.append({"text": state, "done": false, "optional": false, "status": true})
	return list


func _physics_process(delta: float) -> void:
	if shift_over or not tip_given:
		return
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
