class_name TrafficCase
extends Node

## The traffic control's case (control-transito.md, "Cómo es el caso", steps 1, 5 to 7): the comisario gives it in
## his office with the first clue (TrafficClues adds the rest by radio). Cuffing a stopped car's driver detains them:
## the wanted one gets out cuffed and the cops walk them to the patrol car (OwnerEscort), which solves the case; an
## innocent one complains, drives off and files a complaint, which comes off the pay, and the second one loses the
## case (decision 98). The wanted car getting past the checkpoint runs off and the chase starts (decision 96, like the
## pastry contest's culprit); caught, it's solved, and got away, lost. Online the host's case decides and a guest's
## follows it (CaseSync). Every number here is (propuesta).

signal detained(car: QueueCar, wanted: bool)

## A second innocent detained loses the case (decision 98).
const MAX_INNOCENTS := 2
## Each innocent's complaint comes off the pay (propuesta, like the raid's fines).
const COMPLAINT_FINE := 100
## Its own quota, like the chase and the crime scene (decision 91).
const QUOTA := ShiftReport.SALARY
const SHIFT_DELAY := 3.0
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## The detained driver gets out this far to the car's left.
const DOOR_OUT := 1.7

var case_seed := 0
var plan: WantedPlan
var queue: TrafficQueue
var clues: TrafficClues
var patrol_car: PatrolCar
var shift_screen: ShiftScreen
var briefing: CaseBriefing
var tip_given := false
var innocents := 0
## The wanted driver, out of the car and cuffed; in the patrol car, the case is solved.
var suspect: ChaseSuspect
var escort: OwnerEscort
var solved_now := false
## The wanted car got past the checkpoint and the chase is on; whether it got away.
var chase: ChaseCase
var escaped := false
var lost := false
var shift_over := false
## Online (docs/diseno/online.md): the host's case decides and a guest's follows it (CaseSync); `online` is that sync.
var follower := false:
	set(value):
		follower = value
		if queue:
			queue.follower = value
		if clues:
			clues.follower = value
var online: CaseSync
## The end of shift numbers, once it's over (sent to the guests).
var _result := {}


## The traffic control's case of the level `node` is in (online tests hold one level per PC in the same tree).
static func of(node: Node) -> TrafficCase:
	for case: TrafficCase in node.get_tree().get_nodes_in_group("traffic_case"):
		if case.get_parent().is_ancestor_of(node):
			return case
	return null


func start(comisario: Comisario = null) -> void:
	add_to_group("traffic_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	queue.passed.connect(_on_passed)
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


## The comisario tells the case, with the first clue; then the radio starts.
func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			# The clown convoy has its own story (control-payasos.md, "La historia").
			var story := "BRIEF_CONVOY_" if plan.convoy else "BRIEF_TRAFFIC_"
			briefing.start(PackedStringArray([story + "A", tr("BRIEF_TRAFFIC_B") % plan.clue_text(0), story + "C"]))
			break
	add_child(clues)


## A cop cuffed the driver of `car`, stopped in the queue.
func detain(car: QueueCar) -> void:
	if follower or shift_over or lost or solved_now or not car.waiting():
		return
	queue.pull_over(car)
	detained.emit(car, car.wanted)
	if car.wanted:
		_take_out(car)
		_hint_all("HINT_TRAFFIC_GOT_IT")
		return
	innocents += 1
	lost = innocents >= MAX_INNOCENTS
	car.say(tr("TRAFFIC_INNOCENT_LINE"))
	# Let go, they drive off in a huff.
	car.state = "going"
	_hint_all("HINT_TRAFFIC_INNOCENT_LOST" if lost else "HINT_TRAFFIC_INNOCENT")
	if lost:
		_end()


## The wanted driver gets out, cuffed, to be walked to the patrol car.
func _take_out(car: QueueCar) -> void:
	suspect = ChaseSuspect.new()
	suspect.name = "Driver"
	suspect.kind = "driver"
	get_parent().add_child(suspect)
	suspect.global_position = car.global_position + car.global_basis.x * DOOR_OUT + Vector3.UP * 0.1
	suspect.rotation.y = car.rotation.y
	suspect.cuffed(Handcuffs.SECONDS)
	if patrol_car:
		escort = OwnerEscort.attach(suspect, patrol_car)
		escort.in_car_hint = "HINT_TRAFFIC_IN_CAR"
		escort.boarded.connect(_on_boarded)


func _on_boarded() -> void:
	solved_now = true
	_end()


## The wanted car went by the checkpoint: it runs off and the chase starts. Without a city to chase it in, lost.
func _on_passed(car: QueueCar, _sneaked: bool) -> void:
	if follower or not car.wanted or solved_now or lost or suspect or chase:
		return
	if _run_off(car.global_transform, car.look):
		car.queue_free()
		return
	lost = true
	_hint_all("HINT_TRAFFIC_WANTED_GONE")
	_end()


## The queue car (`look`, at `at`) becomes the chase's fleeing car, in its own paint, right where it is.
func _run_off(at: Transform3D, look: int) -> bool:
	var level := get_parent()
	var city := level.get_node_or_null("City") as Node3D
	if not city or not patrol_car:
		return false
	var kind := "traffic_%d" % (look % TrafficCar.MODELS.size())
	chase = ChaseCase.begin(level, kind, at, patrol_car, city, case_seed)
	chase.who = "driver"
	chase.online = online
	chase.follower = follower
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_TRAFFIC_RUNS")
	return true


func _on_chase_ended(caught: bool) -> void:
	escaped = not caught
	solved_now = caught
	lost = not caught
	if not follower:
		_end()


func solved() -> bool:
	return solved_now and not lost and not escaped


func _end() -> void:
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The end of shift screen: the salary if solved, less the complaints. A campaign moves on.
func finish_shift() -> void:
	if shift_over or follower:
		return
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	var report := ShiftReport.pay(solved(), [], innocents * COMPLAINT_FINE)
	var result := {"solved": solved(), "report": report, "awards": ShiftReport.awards(stats)}
	var campaign := Campaign.current
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.finish_shift("traffic_rush_hour", solved(), report, QUOTA)
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
	# Online only the host starts the next case.
	shift_screen.get_node("%AgainButton").visible = not over and not follower


## What every guest's case shows (CaseSync, 5 times a second when it changes): the meter, the clues, the detentions,
## the chase after the one who ran off and the end of shift.
func snapshot() -> Dictionary:
	var state := {"tip": tip_given, "patience": queue.patience, "sneaked": queue.sneaked,
		"clues": clues.known, "innocents": innocents, "lost": lost, "solved": solved_now, "escaped": escaped,
		"suspect": suspect != null, "result": _result}
	if chase:
		state.chase = chase.snapshot()
		state.run_off = [chase.truck.global_transform if is_instance_valid(chase.truck) else Transform3D(),
			int(chase.suspect_id.trim_prefix("traffic_"))]
	return state


## A guest's case takes the host's, and shows the same hints when something happens.
func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	queue.show_patience(state.patience, state.sneaked)
	clues.catch_up_to(state.clues)
	var innocent_now: bool = state.innocents > innocents
	if innocent_now:
		_hint_all("HINT_TRAFFIC_INNOCENT_LOST" if state.lost else "HINT_TRAFFIC_INNOCENT")
	innocents = state.innocents
	if state.suspect and not suspect:
		suspect = get_parent().get_node_or_null("Driver") as ChaseSuspect
		if suspect and patrol_car:
			escort = OwnerEscort.attach(suspect, patrol_car)
			escort.follower = true
			escort.in_car_hint = "HINT_TRAFFIC_IN_CAR"
			_hint_all("HINT_TRAFFIC_GOT_IT")
	if state.has("chase") and not chase:
		var run_off: Array = state.run_off
		_run_off(run_off[0], run_off[1])
	if chase and state.has("chase"):
		chase.apply_snapshot(state.chase)
	if state.lost and not lost and not chase and not innocent_now:
		_hint_all("HINT_TRAFFIC_WANTED_GONE")
	lost = state.lost
	solved_now = state.solved
	escaped = state.escaped
	if not (state.result as Dictionary).is_empty() and not shift_over:
		_show_result(state.result)


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
