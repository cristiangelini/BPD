class_name AirportCase
extends Node

## The deputy's trip as a case (politico-aeropuerto.md, step 5, decision 231): the comisario tells it in his office, Q
## opens the planilla, and the clock is the boarding (AirportBoarding). The case is solved if the deputy boards on time
## and the odd suitcase never went through the X-ray machine; the scandal on the screen loses it there and then, and so
## does the gate closing without him. It pays SALARY, OPENED less for each of his own suitcases opened for nothing,
## WRONG_CUFF less for each honest employee cuffed and PORTER more if the porter is in the patrol car; quota of its own,
## like the plaza (decision 103). If the porter is still loose when it ends, he runs for the baggage tug parked out
## front and the chase starts there (decision 96, step 6): caught, he counts as detained. Online (step 7) the host's
## case decides and a guest's follows it (CaseSync, snapshot): the belt and the boarding clock, the deputy's errands,
## what the X-ray showed, the suitcases opened, the clues, how it ended and the getaway; the people come from the host
## (NpcSync) and the suitcases too (PropSync). Every number here is (propuesta).

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
## The porter's run on the baggage tug and how it ended.
var chase: ChaseCase
var caught := false
var escaped := false
var shift_over := false
var follower := false:
	set(value):
		follower = value
		if airport:
			airport.belt.follower = value
			airport.boarding.follower = value
			airport.deputy.follower = value
			OddCargo.of(airport.odd).follower = value
var online: CaseSync
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
	if airport.porter.loose():
		_run_off()
	else:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The porter drops everything and drives off on the baggage tug: the chase is on.
func _run_off() -> void:
	if chase:
		return
	var porter := airport.porter
	porter.hide()
	porter.collision_layer = 0
	porter.process_mode = Node.PROCESS_MODE_DISABLED
	airport.tug.get_node("Rider").show()
	airport.tug.driving = true
	chase = ChaseCase.begin(airport, SuspectCar.BAGGAGE_TUG, airport.tug.global_transform, airport.car, airport.city,
		airport.case_seed, null, airport.tug)
	chase.who = "porter"
	chase.online = online
	chase.follower = follower
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_PORTER")


func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = not was_caught
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


## The porter in the patrol car, from the terminal or caught off the tug.
func porter_detained() -> bool:
	return jailed or caught


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


## What every guest's case shows (CaseSync).
func snapshot() -> Dictionary:
	var boarding := airport.boarding
	var state := {"tip": tip_given, "belt": airport.belt.running,
		"boarding": [boarding.running, snappedf(boarding.left, 0.1), boarding.done], "deputy": airport.deputy.state,
		"xray": [airport.xray.scanned, airport.xray.caption()], "scandal": scandal, "boarded": boarded, "missed": missed,
		"opened": opened.duplicate(), "odd": odd_found, "wrong": wrong_cuffs, "jailed": jailed, "clues": clues.duplicate(),
		"tricks": tricks, "caught": caught, "escaped": escaped, "result": _result}
	if chase:
		state.chase = chase.snapshot()
	return state


func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	airport.belt.running = state.belt
	boarded = state.boarded
	airport.boarding.follow(state.boarding[0], state.boarding[1], state.boarding[2], boarded)
	airport.deputy.state = state.deputy as AirportDeputy.State
	airport.xray.follow(state.xray[0], state.xray[1])
	scandal = state.scandal
	missed = state.missed
	opened.assign(state.opened)
	odd_found = state.odd
	wrong_cuffs = state.wrong
	jailed = state.jailed
	for kind: String in state.clues:
		if not clues.has(kind):
			clues.append(kind)
	tricks = state.tricks
	caught = state.caught
	escaped = state.escaped
	if state.has("chase"):
		_run_off()
		chase.apply_snapshot(state.chase)
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_AIRPORT_ARRIVE", airport.belt.running))
	list.append(_row("OBJ_AIRPORT_ODD", odd_found))
	list.append(_row(tr("OBJ_AIRPORT_CLUES") % [clues.size(), CLUES], clues.size() >= CLUES))
	list.append(_row("OBJ_AIRPORT_PORTER", porter_detained()))
	list.append(_row("OBJ_AIRPORT_BOARD", boarded))
	if chase:
		list.append(_row("OBJ_AIRPORT_CATCH_TUG", caught))
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
