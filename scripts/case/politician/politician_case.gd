class_name PoliticianCase
extends Node

## The politician protection case (proteccion-politico.md, step 6, decision 103): the comisario tells it in his
## office, Q opens the planilla, and the clock is deputy Lustre's speech. When it ends with fewer than
## Politician.STAINS_MAX stains on his suit the case is solved and pays SALARY, PER_STAIN less for each stain and
## PER_HECKLER more for each heckler in the patrol car; quota of its own, like the chase (decision 91). With
## STAINS_MAX stains he leaves furious and the case is lost there. When the speech ends, the last heckler still loose
## (neither cuffed nor taken away) runs off on a kick scooter and the chase starts there (decision 96): caught, they
## count as detained; got away, the case is solved all the same. Online the host's case decides and a guest's follows
## it (CaseSync, snapshot): the speech's clock, how it ended and the getaway; the host tells the guests where each egg
## and tomato burst (show_burst). Every number here is (propuesta).
## At the double's rally (politico-doble.md, step 3, decision 220) the double in the patrol car pays PER_DOUBLE more,
## and if he's still loose when the speech ends, it's him who runs off on the kick scooter, not a heckler.

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_STAIN := 50
const PER_HECKLER := 50
const PER_DOUBLE := 150
const QUOTA := 400
const STORY := "politician_rally"
## The snapshot's runner when it's the double, not a heckler.
const DOUBLE_RUNNER := -2
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var rally: PlazaRally
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var furious := false
var speech_over := false
var shift_over := false
## The last heckler's run on the kick scooter (or the double's), who it is and how it ended.
var chase: ChaseCase
var runner: Node3D
var caught := false
var escaped := false
var follower := false:
	set(value):
		follower = value
		if rally:
			rally.speech.follower = value
			rally.crowd.set_physics_process(not value)
			PoliticianWalks.of(rally.politician).set_physics_process(not value)
			if rally.double:
				PoliticianWalks.of(rally.double).set_physics_process(not value)
				rally.swap.set_physics_process(not value)
var online: CaseSync
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
	for heckler in rally.crowd.hecklers:
		heckler.threw.connect(_on_threw)
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
			var brief := "BRIEF_DOUBLE_" if rally.variant == "double" else "BRIEF_RALLY_"
			briefing.start(PackedStringArray([brief + "A", brief + "B", brief + "C"]))
			break
	checklist.show_rows(rows())


func _on_speech_finished() -> void:
	if follower or furious:
		return
	speech_over = true
	_hint_all("HINT_RALLY_SPEECH_OVER")
	runner = rally.double if double_loose() else rally.crowd.loose_heckler()
	if runner:
		_run_off()
	else:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)
	checklist.show_rows(rows())


## The last heckler gets on their kick scooter, with their own look, from where they stood: the chase is on.
func _run_off() -> void:
	if chase or not runner:
		return
	runner.hide()
	(runner as CollisionObject3D).collision_layer = 0
	runner.process_mode = Node.PROCESS_MODE_DISABLED
	chase = ChaseCase.begin(rally, SuspectCar.KICK_SCOOTER, runner.global_transform, rally.get_node("PatrolCar"),
		rally.get_node("City"), rally.case_seed)
	chase.who = ChaseSuspect.DOUBLE if runner is Politician else ChaseSuspect.HECKLER + (runner as RallyFan).look
	chase.online = online
	chase.follower = follower
	chase.truck.set_rider(ChaseSuspect.model_for(chase.who))
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_DOUBLE" if runner is Politician else "HINT_ESCAPE_HECKLER")


## Caught and in the patrol car, they count as detained; got away, the case is solved all the same.
func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = not was_caught
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


## The hecklers in the patrol car, the one caught on the scooter included (not the double).
func detained() -> int:
	return rally.crowd.detained + (1 if caught and not runner is Politician else 0)


## The double in the patrol car, or caught on the scooter.
func double_detained() -> bool:
	if not rally.double:
		return false
	var escort := OwnerEscort.of(rally.double)
	return (escort and escort.in_car) or (caught and runner == rally.double)


## The double neither cuffed nor in the car: he'd run off at the end.
func double_loose() -> bool:
	return rally.double != null and not rally.double.caught


## SALARY, less PER_STAIN for each stain and plus PER_HECKLER for each heckler detained; nothing if he left furious.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = maxi(SALARY - PER_STAIN * rally.politician.stains + PER_HECKLER * detained()
			+ (PER_DOUBLE if double_detained() else 0), 0)
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


func _on_threw(_fan: RallyFan, thrown: RallyThrowable) -> void:
	thrown.burst.connect(_on_burst)


## Host: where it burst, for every guest (the deputy's stains go with him, NpcSync).
func _on_burst(thrown: RallyThrowable, on: Node) -> void:
	if not online or follower or on is Politician:
		return
	var cop_id := 0
	for id: int in online.net.cop_syncs:
		if on is Cop and online.net.cop_syncs[id].cop == on:
			cop_id = id
	online.tell("show_burst", [thrown.kind, thrown.global_position, cop_id])


## Guest: an egg or a tomato burst at `at` on the host: on that player's cop, or a splat on the ground.
func show_burst(kind: String, at: Vector3, cop_id: int) -> void:
	var sync: CopSync = online.net.cop_syncs.get(cop_id) if online and cop_id != 0 else null
	if sync and is_instance_valid(sync.cop):
		RallyThrowable.stain_cop(sync.cop, kind, at)
	else:
		RallyThrowable.splat_at(rally, kind, at)


## What every guest's case shows (CaseSync).
func snapshot() -> Dictionary:
	var state := {"tip": tip_given, "speaking": rally.speech.speaking, "over": rally.speech.over,
		"left": snappedf(rally.speech.left, 0.1), "furious": furious, "speech_over": speech_over,
		"runner": DOUBLE_RUNNER if runner and runner == rally.double else rally.crowd.hecklers.find(runner),
		"caught": caught, "escaped": escaped, "result": _result}
	if chase:
		state.chase = chase.snapshot()
	return state


func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	rally.speech.speaking = state.speaking
	rally.speech.over = state.over
	rally.speech.left = state.left
	furious = state.furious
	speech_over = state.speech_over
	caught = state.caught
	escaped = state.escaped
	if state.has("chase") and (state.runner >= 0 or state.runner == DOUBLE_RUNNER):
		runner = rally.double if state.runner == DOUBLE_RUNNER else rally.crowd.hecklers[state.runner]
		_run_off()
		chase.apply_snapshot(state.chase)
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_RALLY_GUARD", rally.speech.speaking or rally.speech.over))
	list.append(_row(tr("OBJ_RALLY_STAINS") % [rally.politician.stains, Politician.STAINS_MAX], false))
	list.append(_row(tr("OBJ_RALLY_HECKLERS") % [detained(), RallyCrowd.HECKLERS], detained() >= RallyCrowd.HECKLERS))
	if rally.double:
		list.append(_row("OBJ_DOUBLE_CATCH", double_detained()))
	if chase:
		list.append(_row("OBJ_DOUBLE_CATCH_SCOOTER" if runner is Politician else "OBJ_RALLY_CATCH_SCOOTER", caught))
	var state := "OBJ_RALLY_FURIOUS" if furious else ("OBJ_RALLY_OVER" if speech_over else "OBJ_RALLY_KEEP_CLEAN")
	list.append({"text": state, "done": false, "optional": false, "status": true})
	# The double's rally (politico-doble.md): the real deputy's file, to tell him from the double.
	if rally.variant == "double":
		list.append({"text": "OBJ_DOUBLE_FILE", "done": false, "optional": false, "status": true})
		for tell in DoubleTells.TELLS:
			list.append({"text": DoubleTells.file_key(tell), "done": false, "optional": false, "status": true})
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
