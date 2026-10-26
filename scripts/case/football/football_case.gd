class_name FootballCase
extends Node

## The charity match as a case (politico-futbol.md, step 5, decision 179): the comisario tells it in his office, Q
## opens the planilla, and the clock is the match (FootballMatch). The case is solved if the deputy himself scores at
## least once before the end (the photo with the cup), and pays SALARY, INJURY less for each real injury, WIN more if
## his team wins the match and REFEREE more if the bought referee is in the patrol car; quota of its own, like the
## plaza (decision 103). The third real injury sends him off in an ambulance and the case is lost there. If the referee
## is still loose at the final whistle, he runs for Barullo's scooter parked on the street and the chase starts there
## (decision 96): caught, he counts as detained (step 6). Every number here is (propuesta).

const SHIFT_DELAY := 4.0
const REFRESH := 0.5
const SALARY := 600
const INJURY := 100
const WIN := 50
const REFEREE := 100
const QUOTA := 400
const AMBULANCE := 3
const STORY := "politician_football"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var pitch: FootballPitch
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
## Goals the deputy himself scored.
var lustre_goals := 0
var injuries := 0
var ambulance := false
var match_over := false
var jailed := false
var clues: Array[String] = []
var shift_over := false
## The referee's run on Barullo's scooter and how it ended.
var chase: ChaseCase
var caught := false
var escaped := false
var follower := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("football_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_FOOTBALL"))
	pitch.score.scored.connect(_on_scored)
	pitch.score.handball.connect(func(_cop: Cop) -> void: pitch.referee.call_foul())
	pitch.lustre.injured.connect(_on_injured)
	pitch.match_clock.finished.connect(_on_final_whistle)
	pitch.referee.found_clue.connect(_on_clue)
	OwnerEscort.of(pitch.referee).boarded.connect(_on_jailed)
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
			briefing.start(PackedStringArray(["BRIEF_FOOTBALL_A", "BRIEF_FOOTBALL_B", "BRIEF_FOOTBALL_C"]))
			break
	checklist.show_rows(rows())


func _on_scored(team: int, by: Node3D) -> void:
	if team == FootballScore.Team.LUSTRE and by == pitch.politician and not match_over and not ambulance:
		lustre_goals += 1
		if lustre_goals == 1:
			_hint_all("HINT_FOOTBALL_PHOTO")
	checklist.show_rows(rows())


func _on_injured(count: int) -> void:
	injuries = count
	if count >= AMBULANCE and not ambulance and not match_over:
		ambulance = true
		pitch.lustre.playing = false
		pitch.politician.hide()
		pitch.politician.process_mode = Node.PROCESS_MODE_DISABLED
		pitch.lustre.process_mode = Node.PROCESS_MODE_DISABLED
		_hint_all("HINT_FOOTBALL_AMBULANCE")
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)
	checklist.show_rows(rows())


func _on_final_whistle() -> void:
	if match_over or ambulance:
		return
	match_over = true
	_hint_all("HINT_FOOTBALL_PHOTO_CUP" if solved() else "HINT_FOOTBALL_NO_PHOTO")
	if pitch.referee.loose():
		_run_off()
	else:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)
	checklist.show_rows(rows())


## The referee leaves the pitch and rides off on Barullo's scooter: the chase is on.
func _run_off() -> void:
	if chase:
		return
	var referee := pitch.referee
	referee.hide()
	referee.collision_layer = 0
	referee.process_mode = Node.PROCESS_MODE_DISABLED
	pitch.moto.get_node("Rider").show()
	pitch.moto.driving = true
	chase = ChaseCase.begin(pitch, SuspectCar.BARULLO_MOTO, pitch.moto.global_transform, pitch.car, pitch.city,
		pitch.case_seed, null, pitch.moto)
	chase.who = "referee"
	chase.follower = follower
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_REFEREE")


func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = not was_caught
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func _on_clue(kind: String) -> void:
	if not clues.has(kind):
		clues.append(kind)
	checklist.show_rows(rows())


func _on_jailed() -> void:
	jailed = true
	_hint_all("HINT_REFEREE_IN_CAR")
	checklist.show_rows(rows())


## The referee in the patrol car, from the pitch or caught off the scooter.
func referee_detained() -> bool:
	return jailed or caught


func solved() -> bool:
	return lustre_goals > 0 and not ambulance


func won() -> bool:
	var goals := pitch.score.goals
	return goals[FootballScore.Team.LUSTRE] > goals[FootballScore.Team.VETERANS]


## SALARY, less INJURY for each real injury, plus WIN if his team won and REFEREE if the referee is detained; nothing
## without the deputy's goal or with him in the ambulance.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = SALARY - INJURY * injuries + (WIN if won() else 0) + (REFEREE if referee_detained() else 0)
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
	list.append(_row("OBJ_FOOTBALL_PLAY", pitch.match_clock.state != FootballMatch.State.WAITING))
	list.append(_row("OBJ_FOOTBALL_GOAL", lustre_goals > 0))
	list.append(_row(tr("OBJ_FOOTBALL_CLUES") % [clues.size(), 2], clues.size() >= 2))
	list.append(_row("OBJ_FOOTBALL_REFEREE", referee_detained()))
	if chase:
		list.append(_row("OBJ_FOOTBALL_CATCH_MOTO", caught))
	var state := tr("OBJ_FOOTBALL_INJURIES") % [injuries, AMBULANCE]
	if ambulance:
		state = "OBJ_FOOTBALL_AMBULANCE"
	elif match_over:
		state = "OBJ_FOOTBALL_OVER"
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
