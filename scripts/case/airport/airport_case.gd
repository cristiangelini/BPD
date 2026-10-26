class_name AirportCase
extends Node

## The deputy's trip as a case (politico-aeropuerto.md, step 5, decision 231): the comisario tells it in his office, Q
## opens the planilla, and the clock is the boarding (AirportBoarding). The case is solved if the deputy boards on time
## and the odd suitcase never went through the X-ray machine; the scandal on the screen loses it there and then, and so
## does the gate closing without him. It pays SALARY, OPENED less for each of his own suitcases opened for nothing,
## WRONG_CUFF less for each honest employee cuffed and PORTER more if the porter is in the patrol car; quota of its own,
## like the plaza (decision 103). Every number here is (propuesta).

const SHIFT_DELAY := 4.0
const REFRESH := 0.5
const SALARY := 600
const OPENED := 50
const WRONG_CUFF := 100
const PORTER := 100
const QUOTA := 400
const CLUES := 3
const STORY := "politician_airport"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var airport: Airport
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var scandal := false
var boarded := false
var missed := false
## His own suitcases opened for nothing (their numbers), and whether the odd one was found (given away or opened).
var opened: Array[int] = []
var odd_found := false
var wrong_cuffs := 0
var jailed := false
var clues: Array[String] = []
var tricks := 0
var shift_over := false
var follower := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("airport_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_AIRPORT"))
	airport.xray.scandal.connect(_on_scandal.unbind(1))
	airport.boarding.closed.connect(_on_closed)
	OddCargo.of(airport.odd).noticed.connect(func(_kind: String, _cop: Cop) -> void: _found_odd())
	for suitcase in airport.suitcases:
		suitcase.opened_now.connect(_on_opened)
	var porter := airport.porter
	porter.found_clue.connect(_on_clue)
	porter.tricked.connect(func() -> void: tricks += 1)
	OwnerEscort.of(porter).boarded.connect(_on_jailed)
	for worker in airport.staff:
		worker.wrongly_cuffed.connect(_on_wrong_cuff)
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
			briefing.start(PackedStringArray(["BRIEF_AIRPORT_A", "BRIEF_AIRPORT_B", "BRIEF_AIRPORT_C"]))
			break
	checklist.show_rows(rows())


func _found_odd() -> void:
	odd_found = true
	checklist.show_rows(rows())


func _on_opened(suitcase: Suitcase) -> void:
	if suitcase == airport.odd:
		_found_odd()
		return
	if opened.has(suitcase.number):
		return
	opened.append(suitcase.number)
	airport.politician.say("AIRPORT_DEPUTY_OPENED")
	checklist.show_rows(rows())


## The odd suitcase on the screen in front of the press: the case is lost.
func _on_scandal() -> void:
	if scandal or boarded or missed:
		return
	scandal = true
	_hint_all("HINT_AIRPORT_LOST_SCANDAL")
	_end()


func _on_closed(on_time: bool) -> void:
	if scandal:
		return
	boarded = on_time
	missed = not on_time
	_end()


func _end() -> void:
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func _on_clue(kind: String) -> void:
	if not clues.has(kind):
		clues.append(kind)
	checklist.show_rows(rows())


func _on_wrong_cuff() -> void:
	wrong_cuffs += 1
	_hint_all("HINT_AIRPORT_WRONG_CUFF")
	checklist.show_rows(rows())


func _on_jailed() -> void:
	jailed = true
	_hint_all("HINT_PORTER_IN_CAR")
	checklist.show_rows(rows())


func porter_detained() -> bool:
	return jailed


func solved() -> bool:
	return boarded and not scandal


## SALARY, less OPENED for each of his opened for nothing and WRONG_CUFF for each honest employee cuffed, plus PORTER if
## the porter is detained; nothing if the deputy didn't board or the press saw the odd suitcase.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = SALARY - OPENED * opened.size() - WRONG_CUFF * wrong_cuffs + (PORTER if porter_detained() else 0)
		salary = maxi(salary, 0)
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
	list.append(_row("OBJ_AIRPORT_ARRIVE", airport.belt.running))
	list.append(_row("OBJ_AIRPORT_ODD", odd_found))
	list.append(_row(tr("OBJ_AIRPORT_CLUES") % [clues.size(), CLUES], clues.size() >= CLUES))
	list.append(_row("OBJ_AIRPORT_PORTER", porter_detained()))
	list.append(_row("OBJ_AIRPORT_BOARD", boarded))
	var state := tr("OBJ_AIRPORT_OPENED") % opened.size()
	if scandal:
		state = "OBJ_AIRPORT_SCANDAL"
	elif missed:
		state = "OBJ_AIRPORT_MISSED"
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
