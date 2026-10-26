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
## In the ghost car control (control-auto-fantasma.md) the wanted driver is the ghost car's pilot: cuffed, his remote
## falls out of his hands, and in the patrol car's trunk it adds 100 like a gold watch. In the street race check
## (control-carrera.md, answer 2) each racer punctured adds to a solved case's pay and each city car punctured is a
## complaint, like detaining an innocent; El Turbo, stopped on his rims, is cuffed out of his racer, and cuffing
## another racer is a complaint too. His trophy is then on his racer's trunk lid: in the patrol car's trunk it adds 100.
## Past the checkpoint, he runs off faster than anyone and spins round at every corner (ChaseDrops.race). In the fog
## check (control-neblina.md) La Bruma's lighthouse lamp is on his trunk lid once he's cuffed, +100 in the patrol car's
## trunk; past the checkpoint he runs off in the fog, headlights on, honking at every corner. In the circus move
## (control-circo.md) El Peludo is cuffed in his open cage, the jewels left in its straw (+100 in the patrol car's
## trunk); past the checkpoint he runs off in his circus truck, dropping banana peels at every corner.

signal detained(car: QueueCar, wanted: bool)

## A second innocent detained loses the case (decision 98).
const MAX_INNOCENTS := 2
## Each innocent's complaint comes off the pay (propuesta, like the raid's fines).
const COMPLAINT_FINE := 100
## Each watermelon split from an innocent fruit seller's pickup (control-frutas.md, answer 2).
const MELON_FINE := 20
## Each packed car fined for too many riders adds this to a solved case's pay (control-auto-lleno.md, answer 2).
const CROWD_FINE_BONUS := 20
## Each drunk driver's keys taken adds this to a solved case's pay, each drunk let through takes it off
## (control-boda.md, answer 3).
const DRUNK_KEYS := 25
## Each racer stopped with the spike strips adds this to a solved case's pay (control-carrera.md, answer 2).
const RACER_FINE := 25
## Its own quota, like the chase and the crime scene (decision 91).
const QUOTA := ShiftReport.SALARY
const SHIFT_DELAY := 3.0
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## The detained driver gets out this far to the car's left.
const DOOR_OUT := 1.7
## The pilot's remote lands this far to the cuffed driver's side.
const REMOTE_OUT := 0.8
## El Colado's gift envelopes show up on his car's trunk lid (control-boda.md), this far up from its middle.
const ENVELOPES_AT := Vector3(0, 1.3, -1.8)
## El Turbo's trophy shows up on his racer's trunk lid, before the spoiler.
const TROPHY_AT := Vector3(0, 1.05, -1.45)

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
## Drunk drivers whose keys a cop took, and drunk drivers let through (or sneaked) at the wheel.
var drunk_keys := 0
var drunks_passed := 0
## Racers stopped with the spike strips (city cars punctured count as innocents).
var racer_fines := 0
## The wanted driver, out of the car and cuffed; in the patrol car, the case is solved.
var suspect: ChaseSuspect
## The clown car the wanted clown was taken out of (its seat is left empty on every PC).
var taken_from := ""
## The paint of the car that ran off (a fruit pickup's is tinted, so guests need it).
var _run_off_look := 0
## How many rode in the car that ran off, and its plate (a packed one's faces, for guests too).
var _run_off_riders := [0, ""]
## El Turbo's racer's looks when he ran off (RaceCar.draw's), for guests too.
var _run_off_race := {}
## La Bruma's headlights and horn when he ran off (FogCar.draw's), for guests too.
var _run_off_fog := {}
var _run_off_circus := {}
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
	queue.punctured.connect(_on_punctured)
	queue.animal_lost.connect(_on_animal_lost)
	queue.dancer_wronged.connect(_on_dancer_wronged)
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
				else "BRIEF_CROWD_" if plan.crowd else "BRIEF_GHOST_" if plan.ghost \
				else "BRIEF_WEDDING_CHECK_" if plan.wedding else "BRIEF_RACE_" if plan.race \
				else "BRIEF_FOG_" if plan.fog else "BRIEF_CIRCUS_MOVE_" if plan.circus \
				else "BRIEF_PARADE_" if plan.parade else "BRIEF_TRAFFIC_"
			var first := story + "A"
			if plan.wedding:
				first = tr("BRIEF_WEDDING_CHECK_A") % WeddingCar.names(plan.couple)
			briefing.start(PackedStringArray([first, tr("BRIEF_TRAFFIC_B") % plan.clue_text(0), story + "C"]))
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


## A cop took a drunk driver's keys in the wedding check (QueueCar.take_keys).
func keys_taken(_car: QueueCar) -> void:
	if follower or shift_over:
		return
	drunk_keys += 1
	_hint_all("HINT_WEDDING_KEYS")


## What adds to a solved case's pay: a gold watch or the pilot's remote, each packed car fined and each drunk's keys.
func extras() -> Array:
	var out := watch_bonus() + remote_bonus() + envelope_bonus() + trophy_bonus() + lamp_bonus() + jewels_bonus()
	for i in crowd_fines:
		out.append(CROWD_FINE_BONUS)
	for i in drunk_keys:
		out.append(DRUNK_KEYS)
	for i in racer_fines:
		out.append(RACER_FINE)
	return out


## The pay's complaints: the innocents detained, the watermelons split and the drunks let through.
func fines() -> int:
	return innocents * COMPLAINT_FINE + melon_complaints * MELON_FINE + drunks_passed * DRUNK_KEYS


## Evidence in the patrol car's trunk: one gold watch is enough for the extra.
func watch_bonus() -> Array:
	if patrol_car:
		for item in patrol_car.delivered:
			if item is GoldWatch:
				return [GoldWatch.VALUE]
	return []


## The ghost car's pilot's remote in the patrol car's trunk.
func remote_bonus() -> Array:
	if patrol_car:
		for item in patrol_car.delivered:
			if item is RcRemote:
				return [RcRemote.VALUE]
	return []


## El Colado's gift envelopes in the patrol car's trunk.
func envelope_bonus() -> Array:
	if patrol_car:
		for item in patrol_car.delivered:
			if item is GiftEnvelopes:
				return [GiftEnvelopes.VALUE]
	return []


## El Turbo's trophy in the patrol car's trunk.
func trophy_bonus() -> Array:
	if patrol_car:
		for item in patrol_car.delivered:
			if item is RaceTrophy:
				return [RaceTrophy.VALUE]
	return []


## El Peludo's jewels in the patrol car's trunk.
func jewels_bonus() -> Array:
	if patrol_car:
		for item in patrol_car.delivered:
			if item is CircusJewels:
				return [CircusJewels.VALUE]
	return []


## La Bruma's lighthouse lamp in the patrol car's trunk.
func lamp_bonus() -> Array:
	if patrol_car:
		for item in patrol_car.delivered:
			if item is LighthouseLamp:
				return [LighthouseLamp.VALUE]
	return []


## A car rolled over a spike strip: a racer is a fine for the pay, a city car a complaint (control-carrera.md).
func _on_punctured(car: QueueCar) -> void:
	if follower or shift_over or lost or solved_now:
		return
	if car.racer:
		racer_fines += 1
		_hint_all("HINT_RACE_FINED")
		return
	_complaint()


## A circus animal let out of its cage ran off for good (control-circo.md, step 3): the circus complains.
func _on_animal_lost(_car: QueueCar) -> void:
	if follower or shift_over or lost or solved_now:
		return
	_hint_all("HINT_CIRCUS_ANIMAL_LOST")
	_complaint()


## An innocent's complaint; the second one loses the case.
func _on_dancer_wronged(_car: QueueCar) -> void:
	if follower or shift_over or lost or solved_now:
		return
	_hint_all("HINT_PARADE_WRONG_DANCER")
	_complaint()


func _complaint() -> void:
	innocents += 1
	lost = innocents >= MAX_INNOCENTS
	_hint_all("HINT_TRAFFIC_INNOCENT_LOST" if lost else "HINT_TRAFFIC_INNOCENT")
	if lost:
		_end()


## A cop cuffed the driver of `car`, stopped in the queue (or a racer, stopped on its rims).
func detain(car: QueueCar) -> void:
	if follower or shift_over or lost or solved_now or not (car.waiting() or car.stopped_racer()):
		return
	if car.racer and not car.wanted:
		# Fined already for racing, he isn't El Turbo: a complaint, like any innocent's (decision 98).
		car.say(tr("RACE_NOT_TURBO_LINE"))
		_complaint()
		return
	if not car.circus.is_empty():
		_detain_in_cage(car)
		return
	if car.racer:
		detained.emit(car, true)
		_take_out(car)
		if car.driver.get("trunk", "") == "trophy":
			drop_trophy(car)
			_hint_all("HINT_RACE_TROPHY")
		else:
			_hint_all("HINT_TRAFFIC_GOT_IT")
		return
	# The wanted clown gets out where he stands; the others hop back in.
	var out_at := car.driver_out_at()
	car.recall_clowns()
	queue.pull_over(car)
	detained.emit(car, car.wanted)
	if car.wanted:
		_take_out(car, out_at)
		if car.puppeteer:
			drop_remote()
			_hint_all("HINT_GHOST_REMOTE")
		elif car.driver.get("trunk", "") == "envelopes":
			drop_envelopes(car)
			_hint_all("HINT_WEDDING_ENVELOPES")
		elif car.driver.get("trunk", "") == "lamp":
			drop_lamp(car)
			_hint_all("HINT_FOG_LAMP")
		else:
			_hint_all("HINT_TRAFFIC_GOT_IT")
		return
	car.say(tr("TRAFFIC_INNOCENT_LINE"))
	# Let go, they drive off in a huff.
	car.state = "going"
	_complaint()


## The cuffs on a circus truck (control-circo.md) go on whoever's in its cage, the door open: El Peludo comes out,
## cuffed, and leaves the jewels in the straw; a real animal won't be cuffed. Its door shut, they wait.
func _detain_in_cage(car: QueueCar) -> void:
	var cage_door := car.get_node_or_null("Cage/Door") as CageDoor
	if not cage_door or not cage_door.is_open:
		car.say(tr("CIRCUS_OPEN_CAGE_FIRST"))
		return
	if not car.circus.get("costume", false):
		car.say(tr("CIRCUS_NO_CUFFS_FOR_ANIMALS") % tr(CircusTruck.animal_name(car.circus.get("animal", ""))))
		return
	queue.pull_over(car)
	detained.emit(car, car.wanted)
	_take_out(car, CircusTruck.cage_mouth(car))
	car.empty_seat()
	taken_from = car.name
	drop_jewels(car)
	_hint_all("HINT_CIRCUS_JEWELS")


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
	# Out of the car, he's no longer at his window (control-auto-fantasma.md).
	var leaning := car.get_node_or_null("WindowDriver")
	if leaning:
		leaning.queue_free()
	suspect.rotation.y = car.rotation.y
	suspect.cuffed(Handcuffs.SECONDS)
	if patrol_car:
		escort = OwnerEscort.attach(suspect, patrol_car)
		escort.in_car_hint = "HINT_TRAFFIC_IN_CAR"
		escort.boarded.connect(_on_boarded)


## The pilot's remote falls out of his hands, by his feet.
func drop_remote() -> RcRemote:
	var remote := RcRemote.new()
	remote.name = "RcRemote"
	get_parent().add_child(remote)
	remote.global_position = suspect.global_position + suspect.global_basis.x * REMOTE_OUT + Vector3.UP * 0.3
	return remote


## El Colado's envelopes, on his car's trunk lid for a cop to take.
func drop_envelopes(car: QueueCar) -> GiftEnvelopes:
	var envelopes := GiftEnvelopes.new()
	envelopes.name = "GiftEnvelopes"
	get_parent().add_child(envelopes)
	envelopes.global_position = car.global_transform * ENVELOPES_AT
	return envelopes


## El Turbo's trophy, on his racer's trunk lid for a cop to take.
func drop_trophy(car: QueueCar) -> RaceTrophy:
	var trophy := RaceTrophy.new()
	trophy.name = "RaceTrophy"
	get_parent().add_child(trophy)
	trophy.global_transform = car.global_transform * Transform3D(Basis(), TROPHY_AT)
	return trophy


## El Peludo's jewels, in his empty cage's straw for a cop to take.
func drop_jewels(car: QueueCar) -> CircusJewels:
	var jewels := CircusJewels.new()
	jewels.name = "CircusJewels"
	get_parent().add_child(jewels)
	jewels.global_transform = car.global_transform * Transform3D(Basis(), CircusTruck.JEWELS_AT)
	return jewels


## La Bruma's lighthouse lamp, on his car's trunk lid for a cop to take.
func drop_lamp(car: QueueCar) -> LighthouseLamp:
	var lamp := LighthouseLamp.new()
	lamp.name = "LighthouseLamp"
	get_parent().add_child(lamp)
	lamp.global_transform = car.global_transform * Transform3D(Basis(), ENVELOPES_AT)
	return lamp


func _on_boarded() -> void:
	solved_now = true
	_end()


## The wanted car went by the checkpoint: it runs off and the chase starts. Without a city to chase it in, lost.
func _on_passed(car: QueueCar, _sneaked: bool) -> void:
	if not follower and not shift_over and car.drunk_at_wheel():
		drunks_passed += 1
		_hint_all("HINT_WEDDING_DRUNK_PASSED")
	if follower or not car.wanted or solved_now or lost or suspect or chase:
		return
	var ghost_look := -1
	if car.puppeteer:
		ghost_look = _ghost_follows()
	if _run_off(car.global_transform, car.look, car.clown, car.fruit, car.crowd, car.plate, ghost_look, car.guest,
			car.race if car.racer else {}, car.fog if car.fog_mode else {}, car.circus):
		car.queue_free()
		return
	lost = true
	_hint_all("HINT_TRAFFIC_WANTED_GONE")
	_end()


## The pilot ran: his ghost car leaves the queue to follow him. Its paint, for the chase's.
func _ghost_follows() -> int:
	for queued in queue.cars.duplicate():
		if queued.ghost:
			queue.pull_over(queued)
			queued.queue_free()
	return plan.cars[plan.ghost_index].look if plan and plan.ghost_index >= 0 else 0


## The queue car (`look`, at `at`) becomes the chase's fleeing car, in its own paint, right where it is. A clown car
## runs off as the circus's, dropping inflatable clowns, and a fruit pickup drops watermelons (ChaseDrops). A packed
## car (`riders`) runs off slower, its faces on the windows, and one of the gang jumps out at every corner. The ghost
## car's pilot has it follow him (`ghost_look`, its paint) and cut in at every corner. El Turbo (`race`, his racer's
## looks) runs off in his racer, faster, spinning at every corner. La Bruma (`fog`, his headlights and horn) runs off
## with his headlights on, honking at every corner. El Peludo (`circus`, his truck's) runs off in his circus truck, in
## his cage, dropping banana peels at every corner.
func _run_off(at: Transform3D, look: int, clown := false, fruit := false, riders := 0, plate := "",
		ghost_look := -1, wedding := false, race: Dictionary = {}, fog: Dictionary = {},
		circus: Dictionary = {}) -> bool:
	var level := get_parent()
	_run_off_look = look
	var city := level.get_node_or_null("City") as Node3D
	if not city or not patrol_car:
		return false
	var kind := SuspectCar.CLOWN_CAR if clown else SuspectCar.FRUIT_TRUCK if fruit \
		else SuspectCar.CIRCUS_TRUCK if not circus.is_empty() else "traffic_%d" % (look % TrafficCar.MODELS.size())
	chase = ChaseCase.begin(level, kind, at, patrol_car, city, case_seed)
	if fruit:
		QueueCar.paint_model(chase.truck, look)
	_run_off_riders = [riders, plate]
	if CrowdedCar.packed(riders):
		chase.truck.heavy = true
		if not chase.truck.has_node("Faces"):
			CrowdedCar.dress(chase.truck, plate, riders)
		chase.drops.riders_left = riders - 1
	chase.drops.ghost_look = ghost_look
	if wedding:
		# El Colado runs in a guest's car, its bow and cans on; he cuts the cans loose at the corners.
		chase.drops.wedding = true
		if not chase.truck.has_node("Cans"):
			WeddingCar.dress(chase.truck, plate)
	if not race.is_empty():
		chase.truck.racer = true
		chase.drops.race = true
		_run_off_race = race
		if not chase.truck.has_node("Spoiler") and not chase.truck.has_node("Exhaust"):
			RaceCar.dress(chase.truck, race)
	if not fog.is_empty():
		chase.drops.fog_horn = fog.get("horn", 0)
		_run_off_fog = fog
		if not chase.truck.has_node("Lamp"):
			FogCar.dress(chase.truck, fog)
	if not circus.is_empty():
		chase.drops.bananas = true
		_run_off_circus = circus
		if not chase.truck.has_node("Cage"):
			CircusTruck.dress_runaway(chase.truck, circus)
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
	if plan and plan.ghost:
		return "traffic_ghost_car"
	if plan and plan.wedding:
		return "traffic_wedding"
	if plan and plan.race:
		return "traffic_race"
	if plan and plan.fog:
		return "traffic_fog"
	if plan and plan.circus:
		return "traffic_circus_move"
	if plan and plan.parade:
		return "traffic_parade"
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
		"clues": clues.known, "innocents": innocents, "melons": melon_complaints, "crowd_fines": crowd_fines,
		"drunk_keys": drunk_keys, "drunks_passed": drunks_passed,
		"racer_fines": racer_fines, "lost": lost, "solved": solved_now, "escaped": escaped,
		"suspect": suspect != null, "result": _result, "taken_from": taken_from, "clean": _clean_clowns(),
		"spikes": _spikes(), "overruns": queue.overruns}
	if chase:
		state.chase = chase.snapshot()
		var clown := chase.suspect_id == SuspectCar.CLOWN_CAR
		var fruit := chase.suspect_id == SuspectCar.FRUIT_TRUCK
		state.run_off = [chase.truck.global_transform if is_instance_valid(chase.truck) else Transform3D(),
			_run_off_look if clown or fruit or not _run_off_circus.is_empty()
				else int(chase.suspect_id.trim_prefix("traffic_")), clown, fruit,
			_run_off_riders[0], _run_off_riders[1], chase.drops.ghost_look, chase.drops.wedding,
			_run_off_race, _run_off_fog, _run_off_circus]
		state.riders_left = chase.drops.riders_left
		state.honks = chase.drops.honks
	return state


## A guest's case takes the host's, and shows the same hints when something happens.
func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	queue.show_patience(state.patience, state.sneaked, state.get("overruns", 0))
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
	if state.get("drunk_keys", 0) > drunk_keys:
		_hint_all("HINT_WEDDING_KEYS")
	drunk_keys = state.get("drunk_keys", 0)
	if state.get("drunks_passed", 0) > drunks_passed:
		_hint_all("HINT_WEDDING_DRUNK_PASSED")
	drunks_passed = state.get("drunks_passed", 0)
	if state.get("racer_fines", 0) > racer_fines:
		_hint_all("HINT_RACE_FINED")
	racer_fines = state.get("racer_fines", 0)
	for strip_name: String in state.get("spikes", {}):
		var strip := get_parent().get_node_or_null(strip_name) as SpikeStrip
		if strip:
			strip.show_unrolled(state.spikes[strip_name])
	if state.suspect and not suspect:
		suspect = get_parent().get_node_or_null("Driver") as ChaseSuspect
		if suspect and patrol_car:
			escort = OwnerEscort.attach(suspect, patrol_car)
			escort.follower = true
			escort.in_car_hint = "HINT_TRAFFIC_IN_CAR"
			_hint_all("HINT_RACE_TROPHY" if plan and plan.race else "HINT_FOG_LAMP" if plan and plan.fog
				else "HINT_CIRCUS_JEWELS" if plan and plan.circus else "HINT_TRAFFIC_GOT_IT")
	if state.has("chase") and not chase:
		var run_off: Array = state.run_off
		_run_off(run_off[0], run_off[1], run_off.size() > 2 and run_off[2], run_off.size() > 3 and run_off[3],
			run_off[4] if run_off.size() > 4 else 0, run_off[5] if run_off.size() > 5 else "",
			run_off[6] if run_off.size() > 6 else -1, run_off.size() > 7 and run_off[7],
			run_off[8] if run_off.size() > 8 else {}, run_off[9] if run_off.size() > 9 else {},
			run_off[10] if run_off.size() > 10 else {})
	_follow_convoy(state.get("taken_from", ""), state.get("clean", []))
	if chase and state.has("chase"):
		chase.apply_snapshot(state.chase)
	if chase and state.get("riders_left", chase.drops.riders_left) != chase.drops.riders_left:
		# One more of the gang jumped out on the host: one face less on the guest's runaway too.
		chase.drops.riders_left = state.riders_left
		CrowdedCar.show_inside(chase.truck, chase.drops.riders_left + 1)
	if chase and state.get("honks", 0) > chase.drops.honks:
		# La Bruma honked at a corner on the host: his horn shows over the guest's runaway too.
		chase.drops.honk()
		chase.drops.honks = state.honks
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


## The spike strips by name, and whether each is unrolled across the street (a guest's only show it).
func _spikes() -> Dictionary:
	var out := {}
	for strip: SpikeStrip in get_tree().get_nodes_in_group("spike_strips"):
		if strip.get_parent() == get_parent():
			out[String(strip.name)] = strip.deployed
	return out


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
