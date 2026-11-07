class_name DebateCase
extends Node

## The TV debate as a case (politico-debate.md, step 5, decision 230): the comisario tells it in his office, Q opens
## the planilla, and the clock is the debate (TvDebate). The case is solved if Lustre's image ends at PASS or more; it
## pays SALARY, BLUNDER less for each blunder on air, WRONG_CUFF less for each honest technician cuffed and TECHNICIAN
## more if the bought one is in the patrol car; quota of its own, like the plaza (decision 103). With the bought
## technician cuffed or taken away there are no more tricks. A trick warned while a cop is in the control room shows
## whose place the warning light is at (his third clue). Step 7: a technician still loose at the end of the debate
## runs for the TV van parked on the street and the chase starts there (decision 96): caught, he counts as detained.
## Online (step 8) the host's case decides and a guest's follows it (CaseSync, snapshot): the debate's clock, turns and
## image, the trick on now and what it changed, the clues, the cuffs, how it ended and the getaway; the debate, the
## tricks and the deputy's trips only run on the host, and the people come from it (NpcSync). Every number here is
## (propuesta).

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
## The technician's run in the TV van and how it ended (step 7).
var chase: ChaseCase
var caught := false
var escaped := false
var follower := false:
	set(value):
		follower = value
		if studio:
			studio.debate.follower = value
			studio.sabotage.follower = value
			var walks := PoliticianWalks.of(studio.politician)
			if walks:
				walks.set_physics_process(not value)
var online: CaseSync
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
	if studio.technician.loose():
		_run_off()
	else:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)
	checklist.show_rows(rows())


## The technician leaves the console and drives off in the TV van: the chase is on.
func _run_off() -> void:
	if chase:
		return
	var tech := studio.technician
	tech.hide()
	tech.collision_layer = 0
	tech.process_mode = Node.PROCESS_MODE_DISABLED
	studio.sabotage.active = false
	var van := studio.van
	van.set_rider(ChaseSuspect.model_for(ChaseSuspect.TECHNICIAN + tech.look()))
	van.get_node("Rider").show()
	van.driving = true
	chase = ChaseCase.begin(studio, SuspectCar.TV_VAN, van.global_transform, studio.car, studio.city, studio.case_seed,
		null, van)
	chase.who = ChaseSuspect.TECHNICIAN + tech.look()
	chase.online = online
	chase.follower = follower
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_TECHNICIAN")


func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = not was_caught
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The technician in the patrol car, from the console or caught off the van.
func technician_detained() -> bool:
	return jailed or caught


func solved() -> bool:
	return studio.debate.state == TvDebate.State.OVER and studio.debate.image >= PASS


## SALARY, less BLUNDER for each blunder and WRONG_CUFF for each honest technician cuffed, plus TECHNICIAN if the
## bought one is in the patrol car; nothing if the debate went badly.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = SALARY - BLUNDER * studio.debate.blunders - WRONG_CUFF * wrong_cuffs + (TECHNICIAN if technician_detained() else 0)
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
		campaign.add_stats(stats)
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
	var debate := studio.debate
	var tricks := studio.sabotage
	var state := {"tip": tip_given, "debate": [debate.state, debate.block, snappedf(debate.left, 0.1), debate.image,
		debate.speaker, debate.question, debate.blunders], "trick": [tricks.phase, tricks.kind, tricks.active,
		studio.spot_on(TvSabotage.LUSTRE_SPOT), studio.prompter.plugged, studio.prompter.text(), studio.warning.visible],
		"clues": clues.duplicate(), "wrong_cuffs": wrong_cuffs, "jailed": jailed, "caught": caught, "escaped": escaped,
		"result": _result}
	if chase:
		state.chase = chase.snapshot()
	return state


func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	var debate := studio.debate
	var on: Array = state.debate
	var who: String = on[4]
	if who != debate.speaker or on[5] != debate.question:
		debate.question = on[5]
		if who == "":
			debate.speaker = ""
			studio.put_on_air(TvDebate.CAMERA_OF.moderator)
		else:
			debate._open_turn(who)
	debate.state = on[0]
	debate.block = on[1]
	debate.left = on[2]
	debate.image = on[3]
	debate.blunders = on[6]
	var trick: Array = state.trick
	var tricks := studio.sabotage
	tricks.phase = trick[0]
	tricks.kind = trick[1]
	tricks.active = trick[2]
	studio.set_spot(TvSabotage.LUSTRE_SPOT, trick[3])
	studio.prompter.follow(trick[4], trick[5])
	studio.set_warning(trick[6])
	for kind: String in state.clues:
		if not clues.has(kind):
			clues.append(kind)
	wrong_cuffs = state.wrong_cuffs
	jailed = state.jailed
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
	var debate := studio.debate
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_DEBATE_ON", debate.state != TvDebate.State.WAITING))
	list.append(_row(tr("OBJ_DEBATE_IMAGE") % [debate.image, PASS], debate.image >= PASS))
	list.append(_row(tr("OBJ_DEBATE_CLUES") % [clues.size(), CLUES], clues.size() >= CLUES))
	list.append(_row("OBJ_DEBATE_TECHNICIAN", technician_detained()))
	if chase:
		list.append(_row("OBJ_DEBATE_CATCH_VAN", caught))
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
