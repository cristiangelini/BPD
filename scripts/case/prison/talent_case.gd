class_name TalentCase
extends Node

## The talent show case (carcel-talentos.md, step 6): the comisario tells it in his office and Q opens the planilla.
## Done when the show ends (TalentPlan.show_ended): SALARY, PER_ESCAPED less for each inmate gone during the show,
## PER_CAUGHT more for each one in the punishment cell and PER_VOTE more for each act the jury voted. Quota of its
## own, like the other prison cases. With LOSE_AT gone the case is lost. Step 7: online the host's case decides and a
## guest's follows it (CaseSync, snapshot): the show's phase and act, the curtain, the cards up, the votes, the smoke,
## the windows, the counts and how it ended. The inmates, the box and the machine go by NpcSync, sitting down, the score
## cards and E on the box, the machine, the sawyer and the offended by ActionSync. Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 6.0
const SALARY := 600
const PER_ESCAPED := 100
const PER_CAUGHT := 25
const PER_VOTE := 20
const QUOTA := 400
const LOSE_AT := 3
const STORY := "prison_talent"
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
			prison.talent.follower = value
			prison.talent.tricks.follower = value
var online: CaseSync
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("talent_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_TALENT"))
	prison.talent.tricks.escaped_one.connect(_on_escaped.unbind(1))
	prison.talent.show_ended.connect(_on_show_ended.unbind(1))
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
			briefing.start(PackedStringArray(["BRIEF_TALENT_A", "BRIEF_TALENT_B", "BRIEF_TALENT_C"]))
			break
	checklist.show_rows(rows())


func escaped() -> int:
	return prison.talent.tricks.escaped


func caught() -> int:
	return prison.talent.tricks.caught


func votes() -> int:
	return prison.talent.voted_ok.count(true)


func solved() -> bool:
	return solved_it and failed_reason == ""


## SALARY, less PER_ESCAPED for each inmate gone, plus PER_CAUGHT for each one in the punishment cell and PER_VOTE for
## each act voted.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = maxi(SALARY - PER_ESCAPED * escaped(), 0) + PER_CAUGHT * caught() + PER_VOTE * votes()
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
		lose("CASE_FAILED_TALENT_ESCAPED")
	checklist.show_rows(rows())


func _on_show_ended() -> void:
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
	var plan := prison.talent
	var raised: Array[bool] = []
	for chair in plan.chairs:
		raised.append(chair.raised)
	return {"tip": tip_given, "phase": plan.phase, "act": plan.act_now, "left": plan.phase_left,
		"points": plan.points, "voted": plan.voted_ok, "winner": plan.winner, "fight": plan.fight_left,
		"curtain": plan.stage.is_open, "raised": raised, "tricks": plan.tricks.net_state(), "solved": solved_it,
		"failed": failed_reason, "result": _result}


func apply_snapshot(state: Dictionary) -> void:
	var plan := prison.talent
	if state.tip:
		give_tip()
	plan.phase = state.phase
	plan.act_now = state.act
	plan.phase_left = state.left
	plan.points.assign(state.points)
	plan.voted_ok.assign(state.voted)
	plan.winner = state.winner
	plan.fight_left = state.fight
	if state.curtain != plan.stage.is_open:
		plan.stage.set_curtain(state.curtain)
	for i in mini(state.raised.size(), plan.chairs.size()):
		if plan.chairs[i].raised != state.raised[i]:
			plan.chairs[i].set_raised(state.raised[i])
	plan.tricks.apply_net_state(state.tricks)
	solved_it = state.solved
	failed_reason = state.failed
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var plan := prison.talent
	var list: Array[Dictionary] = []
	list.append(_row(tr("OBJ_TALENT_SHOW") % [maxi(plan.act_now + 1, 0), TalentPlan.SHOW], plan.is_over()))
	if plan.phase == TalentPlan.Phase.ACT or plan.phase == TalentPlan.Phase.VOTE:
		list.append(_status(tr("OBJ_TALENT_NOW") % tr("TALENT_ACT_%s" % plan.act_name(plan.act_now).to_upper())))
	elif plan.phase == TalentPlan.Phase.WAITING:
		list.append(_status(tr("OBJ_TALENT_WAITING")))
	elif not plan.is_over():
		list.append(_status(tr("OBJ_TALENT_CURTAIN")))
	list.append(_status(tr("OBJ_TALENT_VOTES") % [votes(), TalentPlan.SHOW]))
	list.append(_status(tr("OBJ_TALENT_ESCAPED") % [escaped(), LOSE_AT]))
	list.append({"text": tr("OBJ_TALENT_CAUGHT") % caught(), "done": caught() > 0, "optional": true,
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
