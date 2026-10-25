class_name TrafficCase
extends Node

## The traffic control's case (control-transito.md, "Cómo es el caso", steps 1, 5 to 7): the comisario gives it in
## his office with the first clue (TrafficClues adds the rest by radio). Cuffing a stopped car's driver detains them:
## the wanted one gets out cuffed and the cops walk them to the patrol car (OwnerEscort), which solves the case; an
## innocent one complains, drives off and files a complaint, which comes off the pay, and the second one loses the
## case (decision 98). The wanted car getting past the checkpoint runs off and the chase starts (decision 96, like the
## pastry contest's culprit); caught, it's solved, and got away, lost. Online the host's case decides and a guest's
## follows it (CaseSync). In the clown convoy (control-payasos.md) the driver can be cuffed out of the car too, the
## other clowns hop back in, and the wanted clown runs off in his clown car, dropping inflatable clowns. Every number
## here is (propuesta). In the fruit truck control (control-frutas.md) every watermelon split from an innocent fruit
## seller's pickup is a complaint too, smaller, and a gold watch in the patrol car's trunk adds to a solved case's pay.
## In the crowded car control (control-auto-lleno.md, answer 2) each packed car fined for too many riders adds a bit.

signal detained(car: QueueCar, wanted: bool)

## A second innocent detained loses the case (decision 98).
const MAX_INNOCENTS := 2
## Each innocent's complaint comes off the pay (propuesta, like the raid's fines).
const COMPLAINT_FINE := 100
## Each watermelon split from an innocent fruit seller's pickup (control-frutas.md, answer 2).
const MELON_FINE := 20
## Each packed car fined for too many riders adds this to a solved case's pay (control-auto-lleno.md, answer 2).
const CROWD_FINE_BONUS := 20
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
## Watermelons split from innocent pickups, each a complaint.
var melon_complaints := 0
## Packed cars fined for too many riders.
var crowd_fines := 0
## The wanted driver, out of the car and cuffed; in the patrol car, the case is solved.
var suspect: ChaseSuspect
## The clown car the wanted clown was taken out of (its seat is left empty on every PC).
var taken_from := ""
## The paint of the car that ran off (a fruit pickup's is tinted, so guests need it).
var _run_off_look := 0
## How many rode in the car that ran off, and its plate (a packed one's faces, for guests too).
var _run_off_riders := [0, ""]
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
			var story := "BRIEF_CONVOY_" if plan.convoy else "BRIEF_FRUIT_" if plan.fruit \
				else "BRIEF_CROWD_" if plan.crowd else "BRIEF_TRAFFIC_"
			briefing.start(PackedStringArray([story + "A", tr("BRIEF_TRAFFIC_B") % plan.clue_text(0), story + "C"]))
			break
	add_child(clues)


## A watermelon split: an innocent fruit seller's is a complaint.
func melon_broken(melon: Watermelon) -> void:
	if follower or shift_over:
		return
	if melon.from_wanted:
		if melon.kind == "hollow":
			_hint_all("HINT_FRUIT_WATCHES")
		return
	melon_complaints += 1
	_hint_all("HINT_FRUIT_COMPLAINT")


## A cop fined a packed car for too many riders, once it was all counted (QueueCar.fine).
func crowd_fined(_car: QueueCar) -> void:
	if follower or shift_over:
		return
	crowd_fines += 1
	_hint_all("HINT_CROWD_FINED")


## What adds to a solved case's pay: a gold watch, and each packed car fined.
func extras() -> Array:
	var out := watch_bonus()
	for i in crowd_fines:
		out.append(CROWD_FINE_BONUS)
	return out


## The pay's complaints: the innocents detained and the watermelons split.
func fines() -> int:
	return innocents * COMPLAINT_FINE + melon_complaints * MELON_FINE


## Evidence in the patrol car's trunk: one gold watch is enough for the extra.
func watch_bonus() -> Array:
	if patrol_car:
		for item in patrol_car.delivered:
			if item is GoldWatch:
				return [GoldWatch.VALUE]
	return []


## A cop cuffed the driver of `car`, stopped in the queue.
func detain(car: QueueCar) -> void:
	if follower or shift_over or lost or solved_now or not car.waiting():
		return
	# The wanted clown gets out where he stands; the others hop back in.
	var out_at := car.driver_out_at()
	car.recall_clowns()
	queue.pull_over(car)
	detained.emit(car, car.wanted)
	if car.wanted:
		_take_out(car, out_at)
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


## The wanted driver gets out, cuffed, to be walked to the patrol car; a clown already out stays where he is (`at`).
func _take_out(car: QueueCar, at := Vector3.INF) -> void:
	suspect = ChaseSuspect.new()
	suspect.name = "Driver"
	suspect.kind = "clown" if car.clown else "driver"
	get_parent().add_child(suspect)
	if at == Vector3.INF:
		at = car.global_position + car.global_basis.x * DOOR_OUT
	suspect.global_position = at + Vector3.UP * 0.1
	if car.clown:
		car.empty_seat()
		taken_from = car.name
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
	if _run_off(car.global_transform, car.look, car.clown, car.fruit, car.crowd, car.plate):
		car.queue_free()
		return
	lost = true
	_hint_all("HINT_TRAFFIC_WANTED_GONE")
	_end()


## The queue car (`look`, at `at`) becomes the chase's fleeing car, in its own paint, right where it is. A clown car
## runs off as the circus's, dropping inflatable clowns, and a fruit pickup drops watermelons (ChaseDrops). A packed
## car (`riders`) runs off slower, its faces on the windows, and one of the gang jumps out at every corner.
func _run_off(at: Transform3D, look: int, clown := false, fruit := false, riders := 0, plate := "") -> bool:
	var level := get_parent()
	_run_off_look = look
	var city := level.get_node_or_null("City") as Node3D
	if not city or not patrol_car:
		return false
	var kind := SuspectCar.CLOWN_CAR if clown else SuspectCar.FRUIT_TRUCK if fruit \
		else "traffic_%d" % (look % TrafficCar.MODELS.size())
	chase = ChaseCase.begin(level, kind, at, patrol_car, city, case_seed)
	if fruit:
		QueueCar.paint_model(chase.truck, look)
	_run_off_riders = [riders, plate]
	if CrowdedCar.packed(riders):
		chase.truck.heavy = true
		if not chase.truck.has_node("Faces"):
			CrowdedCar.dress(chase.truck, plate, riders)
		chase.drops.riders_left = riders - 1
	chase.who = "clown" if clown else "driver"
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
	var report := ShiftReport.pay(solved(), extras(), fines())
	var result := {"solved": solved(), "report": report, "awards": ShiftReport.awards(stats)}
	var campaign := Campaign.current
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.finish_shift(campaign_key(), solved(), report, QUOTA)
		campaign.save()
		result.campaign = {"shift": played, "money": campaign.money, "over": campaign.is_over(),
			"promoted": campaign.is_promoted()}
	_show_result(result)


## The case's name in the campaign: each traffic variant counts as its own.
func campaign_key() -> String:
	if plan and plan.convoy:
		return "traffic_clown_convoy"
	if plan and plan.fruit:
		return "traffic_fruit_truck"
	if plan and plan.crowd:
		return "traffic_crowded_car"
	return "traffic_rush_hour"


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
		"clues": clues.known, "innocents": innocents, "melons": melon_complaints, "crowd_fines": crowd_fines, "lost": lost, "solved": solved_now, "escaped": escaped,
		"suspect": suspect != null, "result": _result, "taken_from": taken_from, "clean": _clean_clowns()}
	if chase:
		state.chase = chase.snapshot()
		var clown := chase.suspect_id == SuspectCar.CLOWN_CAR
		var fruit := chase.suspect_id == SuspectCar.FRUIT_TRUCK
		state.run_off = [chase.truck.global_transform if is_instance_valid(chase.truck) else Transform3D(),
			_run_off_look if clown or fruit else int(chase.suspect_id.trim_prefix("traffic_")), clown, fruit,
			_run_off_riders[0], _run_off_riders[1]]
		state.riders_left = chase.drops.riders_left
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
	if state.get("melons", 0) > melon_complaints:
		_hint_all("HINT_FRUIT_COMPLAINT")
	melon_complaints = state.get("melons", 0)
	if state.get("crowd_fines", 0) > crowd_fines:
		_hint_all("HINT_CROWD_FINED")
	crowd_fines = state.get("crowd_fines", 0)
	if state.suspect and not suspect:
		suspect = get_parent().get_node_or_null("Driver") as ChaseSuspect
		if suspect and patrol_car:
			escort = OwnerEscort.attach(suspect, patrol_car)
			escort.follower = true
			escort.in_car_hint = "HINT_TRAFFIC_IN_CAR"
			_hint_all("HINT_TRAFFIC_GOT_IT")
	if state.has("chase") and not chase:
		var run_off: Array = state.run_off
		_run_off(run_off[0], run_off[1], run_off.size() > 2 and run_off[2], run_off.size() > 3 and run_off[3],
			run_off[4] if run_off.size() > 4 else 0, run_off[5] if run_off.size() > 5 else "")
	_follow_convoy(state.get("taken_from", ""), state.get("clean", []))
	if chase and state.has("chase"):
		chase.apply_snapshot(state.chase)
	if chase and state.get("riders_left", chase.drops.riders_left) != chase.drops.riders_left:
		# One more of the gang jumped out on the host: one face less on the guest's runaway too.
		chase.drops.riders_left = state.riders_left
		CrowdedCar.show_inside(chase.truck, chase.drops.riders_left + 1)
	if state.lost and not lost and not chase and not innocent_now:
		_hint_all("HINT_TRAFFIC_WANTED_GONE")
	lost = state.lost
	solved_now = state.solved
	escaped = state.escaped
	if not (state.result as Dictionary).is_empty() and not shift_over:
		_show_result(state.result)


## The convoy's clowns whose makeup is off, by name (they're named alike on every PC).
func _clean_clowns() -> Array[String]:
	var names: Array[String] = []
	for out: ConvoyClown in get_tree().get_nodes_in_group("convoy_clowns"):
		if not out.makeup_on and get_parent().is_ancestor_of(out):
			names.append(String(out.name))
	return names


## A guest's convoy: the wanted clown's seat left empty, and the faces the host's sponge cleaned.
func _follow_convoy(from_car: String, clean: Array) -> void:
	if from_car != "" and taken_from == "":
		taken_from = from_car
		var car := queue.get_node_or_null(NodePath(from_car)) as QueueCar
		if car:
			car.empty_seat()
	for clown_name: String in clean:
		var out := get_parent().get_node_or_null(NodePath(clown_name)) as ConvoyClown
		if out and out.makeup_on:
			out.clean()


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
