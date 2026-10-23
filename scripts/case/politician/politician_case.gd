class_name PoliticianCase
extends Node

## The politician protection case (proteccion-politico.md, step 6, decision 103): the comisario tells it in his
## office, Q opens the planilla, and the clock is deputy Lustre's speech. When it ends with fewer than
## Politician.STAINS_MAX stains on his suit the case is solved and pays SALARY, PER_STAIN less for each stain and
## PER_HECKLER more for each heckler in the patrol car; quota of its own, like the chase (decision 91). With
## STAINS_MAX stains he leaves furious and the case is lost there. Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_STAIN := 50
const PER_HECKLER := 50
const QUOTA := 400
const STORY := "politician_rally"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var rally: PlazaRally
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var furious := false
var speech_over := false
var shift_over := false
var follower := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("politician_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_PLAZA"))
	rally.speech.finished.connect(_on_speech_finished)
	rally.politician.furious.connect(_on_furious)
	rally.crowd.jailed.connect(_on_jailed.unbind(1))
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
			briefing.start(PackedStringArray(["BRIEF_RALLY_A", "BRIEF_RALLY_B", "BRIEF_RALLY_C"]))
			break
	checklist.show_rows(rows())


func _on_speech_finished() -> void:
	if follower or furious:
		return
	speech_over = true
	_hint_all("HINT_RALLY_SPEECH_OVER")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Ten stains: he leaves the stage furious, and the shift is over.
func _on_furious() -> void:
	if follower or speech_over or furious:
		return
	furious = true
	rally.speech.set_physics_process(false)
	_hint_all("HINT_RALLY_FURIOUS")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func _on_jailed() -> void:
	checklist.show_rows(rows())


func solved() -> bool:
	return speech_over and not furious


func detained() -> int:
	return rally.crowd.detained


## SALARY, less PER_STAIN for each stain and plus PER_HECKLER for each heckler detained; nothing if he left furious.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = maxi(SALARY - PER_STAIN * rally.politician.stains + PER_HECKLER * detained(), 0)
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
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_RALLY_GUARD", rally.speech.speaking or rally.speech.over))
	list.append(_row(tr("OBJ_RALLY_STAINS") % [rally.politician.stains, Politician.STAINS_MAX], false))
	list.append(_row(tr("OBJ_RALLY_HECKLERS") % [detained(), RallyCrowd.HECKLERS], detained() >= RallyCrowd.HECKLERS))
	var state := "OBJ_RALLY_FURIOUS" if furious else ("OBJ_RALLY_OVER" if speech_over else "OBJ_RALLY_KEEP_CLEAN")
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
