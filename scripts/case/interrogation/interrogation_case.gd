class_name InterrogationCase
extends Node

## The interrogation (docs/diseno/interrogatorio.md): the comisario gives the case in his office, the suspect waits
## cuffed in the interrogation room, and the cops get a confession out of him before his lawyer gets there. Bad cop
## actions raise his nerves and the lawyer meter, good cop ones lower both; the same action twice in a row gives half
## the nerves, and good cop right after another cop's bad cop doubles the next bad cop's nerves. At 30, 60 and 90 nerves something slips out, at 100 he confesses (the case is solved) and at 100
## lawyer the lawyer takes him away (failed). No time limit (decision 66). Every number here is (propuesta).

## Each action: nerves and lawyer it adds (negative lowers) and its prompt. The bad cop's raise both.
const ACTIONS := {
	"slam_table": {"nerves": 12.0, "lawyer": 8.0, "prompt": "PROMPT_SLAM_TABLE", "react": "SUSPECT_REACT_SLAM"},
	"aim_lamp": {"nerves": 10.0, "lawyer": 6.0, "prompt": "PROMPT_AIM_LAMP", "react": "SUSPECT_REACT_LAMP"},
	"eat_donut": {"nerves": 6.0, "lawyer": 3.0, "prompt": "", "react": "SUSPECT_REACT_EAT_DONUT"},
	"give_donut": {"nerves": -3.0, "lawyer": -12.0, "prompt": "PROMPT_GIVE_DONUT", "react": "SUSPECT_REACT_GIVE_DONUT"},
	"calm": {"nerves": -2.0, "lawyer": -8.0, "prompt": "PROMPT_CALM_SUSPECT", "react": "SUSPECT_REACT_CALM"},
	"flick_lights": {"nerves": 8.0, "lawyer": 5.0, "prompt": "PROMPT_FLICK_LIGHTS", "react": "SUSPECT_REACT_LIGHTS"},
	"give_coffee": {"nerves": -3.0, "lawyer": -10.0, "prompt": "", "react": "SUSPECT_REACT_COFFEE"},
	"throw_chair": {"nerves": 15.0, "lawyer": 12.0, "prompt": "", "react": "SUSPECT_REACT_CHAIR"},
	"shout": {"nerves": 10.0, "lawyer": 10.0, "prompt": "", "react": "SUSPECT_REACT_SHOUT"},
	"offer_tissue": {"nerves": -2.0, "lawyer": -6.0, "prompt": "PROMPT_OFFER_TISSUE", "react": "SUSPECT_REACT_TISSUE"},
	"sit_down": {"nerves": -1.0, "lawyer": -4.0, "prompt": "", "react": "SUSPECT_REACT_SIT"},
	"show_folder": {"nerves": 20.0, "lawyer": 4.0, "prompt": "", "react": "TWIN_FOLDER"},
}
## The same action again in a row gives this much of its nerves, each time ("Ya no me asusta, oficial").
const REPEAT_FACTOR := 0.5
## Good cop right after bad cop (within CONTRAST_SECONDS): the next bad cop action gives this many times its nerves,
## if two cops took turns, or less if it was the same one.
const CONTRAST_SECONDS := 5.0
const CONTRAST := 2.0
const SOLO_CONTRAST := 1.3
## Seconds between two actions, whoever does them.
const ACTION_GAP := 1.0
const SLIPS_AT: Array[float] = [30.0, 60.0, 90.0]
const FULL := 100.0
## A cop eating a donut this close to the suspect counts as the bad cop's action.
const EAT_REACH := 3.0
## The quota of an interrogation shift (decision 91): the confession's salary, so confessing
## makes it and the lawyer loses it. The campaign's quota (800 and up) can't be made with one salary.
const QUOTA := ShiftReport.SALARY
## A shout counts from this close (propuesta): in the room, not from the hall.
const SHOUT_REACH := 5.0
## Seconds the lamp stays on his face, and the lights' blinks when a cop flicks them.
const LAMP_SECONDS := 4.0
const FLICKS := 3
const FLICK_SECONDS := 0.15
## Seconds between the confession or the lawyer and the end of shift screen.
const SHIFT_DELAY := 3.0
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## The crimes he can be in for, drawn with the seed: CRIME_<id> is what the comisario says, SLIP_<id>_1 to 3 what
## slips out and CONFESS_<id> the confession.
const CRIMES := ["bridge", "statue_nose", "violet_lights", "rubber_ducks"]
## The suspects drawn with the seed (interrogatorio.md, "Los sospechosos"), each changing a rule, and their model.
## --suspect=<id> forces one. The rest of the 10 come in later PRs.
const SUSPECTS := ["talker", "sweet_grandpa", "self_lawyer", "sleeper", "influencer", "dangerous", "twins", "mute", "foreigner", "fan"]
const SUSPECT_MODELS := {
	"talker": "res://assets/models/npc_sospechoso.glb",
	"sweet_grandpa": "res://assets/models/npc_abuelo.glb",
	"self_lawyer": "res://assets/models/npc_abogado.glb",
	"sleeper": "res://assets/models/npc_preso.glb",
	"influencer": "res://assets/models/npc_periodista.glb",
	"dangerous": "res://assets/models/npc_sospechoso.glb",
	"twins": "res://assets/models/npc_politico.glb",
	"mute": "res://assets/models/npc_cliente.glb",
	"foreigner": "res://assets/models/npc_sospechoso.glb",
	"translator": "res://assets/models/npc_preso.glb",
	"fan": "res://assets/models/npc_cliente.glb",
	"owner_grandpa": "res://assets/models/npc_abuelo.glb",
	"owner_baker": "res://assets/models/npc_panadera.glb",
	"owner_groomer": "res://assets/models/npc_peluquero.glb",
	"owner_hardware": "res://assets/models/npc_ferretero.glb",
	"owner_factory": "res://assets/models/npc_capataz.glb",
	"owner_insurance": "res://assets/models/npc_jefa.glb",
	"owner_cake_lab": "res://assets/models/npc_chef_bruno.glb",
	# The pastry contest's culprit (escena-del-crimen.md), accused at the board.
	"owner_cook": "res://assets/models/npc_pastelero.glb",
	# The circus's culprit (escena-circo.md), accused at the board.
	"owner_clown": "res://assets/models/npc_payaso.glb",
	# The museum's culprit (escena-museo.md), accused at the board.
	"owner_guard": "res://assets/models/npc_guardia_museo.glb",
	# The mansion's culprit (escena-mansion.md), accused at the board.
	"owner_member": "res://assets/models/npc_socio_club.glb",
	# The infiltrations' bosses, cuffed or caught (infiltracion.md, infiltracion-coro.md).
	"owner_chela": "res://assets/models/npc_chela.glb",
	"owner_ernesto": "res://assets/models/npc_ernesto.glb",
	"owner_pausa": "res://assets/models/npc_pausa.glb",
	"owner_trucho": "res://assets/models/npc_invitado.glb",
	"owner_toro": "res://assets/models/npc_toro.glb",
	"owner_director": "res://assets/models/npc_director.glb",
	"owner_flambe": "res://assets/models/npc_flambe.glb",
	"owner_alfil": "res://assets/models/npc_alfil.glb",
	"owner_cromado": "res://assets/models/npc_cromado.glb",
	"owner_martillo": "res://assets/models/npc_martillo.glb",
	"owner_oso": "res://assets/models/npc_ladron_oso.glb",
	# El Conejo, who robbed the town bank alone (robo-banco-pueblo.md).
	"owner_conejo": "res://assets/models/npc_ladron_conejo.glb",
	# El Conde, El Oso dressed as a vampire for the blood bank (robo-banco-sangre.md).
	"owner_conde": "res://assets/models/npc_ladron_oso.glb",
	# The bank's manager who was the gang's boss (robo-banco-gerente.md).
	"owner_manager": "res://assets/models/npc_gerente.glb",
}
## The owner brought in from the last raid (decision 93): what slips out of him is what he let slip there with R (his
## custody's slips, OWNER_SLIP_<n> when there aren't enough), and the confession pays the salary and OWNER_SHARE of
## what the evidence left behind was worth.
const OWNER_SLIPS := ["OWNER_SLIP_1", "OWNER_SLIP_2", "OWNER_SLIP_3"]
const OWNER_SHARE := 0.5
## The sweet grandpa cries when the nerves go up more than CRY_NERVES within CRY_SECONDS, and the lawyer goes up
## CRY_LAWYER on its own (propuesta).
const CRY_NERVES := 25.0
const CRY_SECONDS := 5.0
const CRY_LAWYER := 20.0
## His own lawyer: every bad cop action also adds this much lawyer, and coffee does nothing (he wants tea).
const SELF_LAWYER_EXTRA := 5.0
## The sleeper: SLEEP_SECONDS without anyone doing anything and he falls asleep, losing SLEEP_DRAIN nerves a second;
## asleep, only WAKE_ACTIONS reach him (propuesta).
const SLEEP_SECONDS := 10.0
const SLEEP_DRAIN := 2.0
const WAKE_ACTIONS := ["give_coffee", "flick_lights", "shout", "throw_chair"]
## The influencer streams it live (decision 92): a bad cop move with no good cop move in the last INFLUENCER_SECONDS
## adds INFLUENCER_LAWYER more lawyer (propuesta).
const INFLUENCER_SECONDS := 8.0
const INFLUENCER_LAWYER := 8.0
## The dangerous one (decision 92): LOOSE_SECONDS with no cop looking at him (within WATCH_ANGLE of where a cop
## looks, WATCH_REACH away at most, nothing but the one-way mirror in between) and he slips the cuffs and runs round
## the station, the lawyer going up LOOSE_LAWYER a second. A cop's E grabs him and slows him for GRIP_SECONDS; a second
## cop grabbing him meanwhile (or the only cop, playing alone) catches him, and back in the chair he's scared
## (CAUGHT_NERVES). All (propuesta).
const LOOSE_SECONDS := 5.0
const WATCH_ANGLE := 35.0
const WATCH_REACH := 12.0
const LOOSE_LAWYER := 1.5
const GRIP_SECONDS := 2.0
const CAUGHT_NERVES := 15.0
## The twins (decision 92): one in the room and his twin in the first cell of the station (InterrogationWing.TWIN_AT);
## each cop works the twin nearest to him, and only the guilty one (drawn with the seed) confesses. The other one's
## nerves go up too, but what slips out is about his brother and at 100 he only says it was him. The case folder
## (CaseFolder), set down by the twin it wasn't last shown to, is the "show_folder" bluff: your brother already talked.
const TWIN_SLIPS := ["TWIN_SLIP_1", "TWIN_SLIP_2", "TWIN_SLIP_3"]
## The mute (suspect 2): he answers with gestures, and what slips out are drawings on a sheet of paper on the table
## (MUTE_DRAW_<crime>_<n>, described in words until there's art) that he holds up for the cops; at 100 he writes the
## confession down.
const SHEET_AT := Vector3(3.0, 0.95, -14.85)
## The foreigner (suspect 8): he only speaks a made-up language (FOREIGN_LINES), and a detainee standing by the table
## (InterrogationWing.TRANSLATOR_AT) translates what slips out, adding his own lines (TRANSLATOR_EXTRAS).
const FOREIGN_LINES := ["FOREIGN_1", "FOREIGN_2", "FOREIGN_3", "FOREIGN_4", "FOREIGN_5", "FOREIGN_6"]
const TRANSLATOR_EXTRAS := ["TRANSLATOR_EXTRA_1", "TRANSLATOR_EXTRA_2", "TRANSLATOR_EXTRA_3"]
## The police fan (suspect 9): at the first action he confesses three crimes at once, held up on the table
## (FanConfession, at FAN_SHEETS_AT), and the cops pick the true one: the right one solves the case, a wrong one adds
## FAN_WRONG_LAWYER and goes. What slips out at 30, 60 and 90 is still true, so it helps to pick; at 100 he only
## begs them to choose (propuesta).
const FAN_SHEETS_AT: Array[Vector3] = [Vector3(2.45, 0.9, -14.25), Vector3(3.0, 0.9, -14.25), Vector3(3.55, 0.9, -14.25)]
const FAN_WRONG_LAWYER := 35.0
## The talker (suspect 1): before each slip he confesses something that has nothing to do with the case.
const TALKER_LINES := ["TALKER_1", "TALKER_2", "TALKER_3"]
const LAWYER_MODEL := preload("res://assets/models/npc_abogado.glb")
const COFFEE_SCENE := preload("res://scenes/props/coffee_cup.tscn")

signal meters_changed(nerves: float, lawyer: float)
signal twin_changed(nerves: float)

var case_seed := 0
var crime := ""
## The owner's custody (RaidCase.custody), when it's him in the chair.
var custody := {}
var suspect_id := "talker"
var suspect: InterrogationSuspect
var nerves := 0.0
var lawyer := 0.0
var slips := 0
var confessed := false
var lawyer_came := false
var tip_given := false
var shift_over := false
var briefing: CaseBriefing
var shift_screen: ShiftScreen
var solved_label: Label
var failed_label: Label
var _last := ""
var _streak := 0
var _gap_left := 0.0
var _talking_until := 0.0
## The bad cop's nerves of the last seconds, [time, nerves], for the sweet grandpa.
var _recent: Array[Vector2] = []
## The sleeper: seconds since the last action, and whether he's asleep.
var _idle := 0.0
var asleep := false
## When the last good cop move was, for the influencer.
var _good_at := -INF
## The dangerous one: seconds nobody has been looking at him, whether he's loose, and who holds on to him and for how long.
var _unwatched := 0.0
var loose := false
var _seen := false
var _grip_by: Cop
var _grip_left := 0.0
## The dangerous one out the front door takes the old patrol car (`getaway`, parked by the station) and the cops chase
## him in the good one (`car`) through the city (persecucion-final.md, decision 96): caught, he's back in his chair;
## got away, the interrogation is lost. The level hands over the cars, the city and the copilot's map.
var car: PatrolCar
var getaway: SuspectCar
var city: Node3D
var city_map: CityMap
var chase: ChaseCase
var escaping := false
var escaped := false
## The twins: the one in the cell, his nerves and slips, whether he's the guilty one, which twin the folder was last
## shown to (null: the one in the room, where it starts), and whether the two are swapped while working the cell's.
var twin: InterrogationSuspect
var twin_nerves := 0.0
var twin_slips := 0
var guilty_in_cell := false
var _folder_with: InterrogationSuspect
var _swapped := false
## The fan's three confessions on the table.
var confessions: Array[FanConfession] = []
## The foreigner's translator.
var translator: InterrogationSuspect
## The mute's sheet of paper and what's drawn on it.
var sheet: Label3D
## The last bad cop action: who did it and when (ms), and the bonus waiting for the next one.
var _bad_by: Cop
var _bad_at := -INF
var _contrast := 1.0
## Online (docs/diseno/online.md): the host's case decides and a guest's follows it (CaseSync); `online` is that sync.
var follower := false
var online: CaseSync
## The end of shift numbers, once it's over (sent to the guests).
var _result := {}


## The case on in this tree, if any; with `near`, the one of the level `near` is in (online tests hold one level per PC
## in the same tree).
static func active(tree: SceneTree, near: Node = null) -> InterrogationCase:
	for node in tree.get_nodes_in_group("interrogation"):
		if not near or node.get_parent().is_ancestor_of(near):
			return node as InterrogationCase
	return null


static func pick_suspect(seed_value: int, args: PackedStringArray) -> String:
	for arg in args:
		if arg.begins_with("--suspect=") and SUSPECTS.has(arg.trim_prefix("--suspect=")):
			return arg.trim_prefix("--suspect=")
	return SUSPECTS[hash("suspect %d" % seed_value) % SUSPECTS.size()]


## Mixed through a generator: the low bits of hash() follow the suspect's draw, so it came out the same twin every time.
static func pick_guilty_in_cell(seed_value: int) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("twin %d" % seed_value)
	return rng.randi() % 2 == 1


static func pick_crime(seed_value: int) -> String:
	return CRIMES[hash("crime %d" % seed_value) % CRIMES.size()]


## Starts the case: the tip waits for a cop to talk to the comisario (right away without one).
func start(comisario: Comisario = null) -> void:
	add_to_group("interrogation")
	crime = "owner_" + str(custody.owner) if suspect_id == "owner" else pick_crime(case_seed)
	briefing = CaseBriefing.new()
	add_child(briefing)
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	shift_screen.play_again.connect(_play_again)
	shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))
	if suspect:
		suspect.outside.connect(_on_outside)


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			var lines := ["BRIEF_INTERROGATION_A", "CRIME_" + crime, "BRIEF_SUSPECT_" + suspect_id, "BRIEF_INTERROGATION_C"]
			if suspect_id == "owner":
				lines = ["CRIME_" + crime, "BRIEF_SUSPECT_owner", "BRIEF_OWNER_C"]
			briefing.start(PackedStringArray(lines))
			break
	briefing.finished.connect(_hint_all.bind("HINT_GO_INTERROGATION"), CONNECT_ONE_SHOT)


func _play_again() -> void:
	if online:
		online.play_again()
	else:
		PlaceDraw.start(get_tree())


## The cops can work on him: the case was given and it isn't over.
func is_on() -> bool:
	return tip_given and not confessed and not lawyer_came and not escaped


func _process(delta: float) -> void:
	_gap_left -= delta
	if suspect_id == "sleeper" and is_on() and not follower:
		_doze(delta)


func _physics_process(delta: float) -> void:
	if suspect_id == "dangerous" and is_on() and not follower:
		_watch(delta)


## The dangerous one: loose, the lawyer goes up and the grip wears off; cuffed, he slips them unwatched.
func _watch(delta: float) -> void:
	if escaping:
		return
	if loose:
		lawyer = minf(lawyer + LOOSE_LAWYER * delta, FULL)
		_emit()
		_grip_left -= delta
		if _grip_left <= 0.0:
			suspect.slowed = false
		_check(null)
		return
	var seen := watched()
	# The clock starts once a cop has come in and seen him, not while they walk over from the office.
	_seen = _seen or seen
	_unwatched = 0.0 if seen or not _seen else _unwatched + delta
	if _unwatched >= LOOSE_SECONDS:
		loose = true
		_unwatched = 0.0
		suspect.run()
		suspect.can_leave = getaway != null
		_say("SUSPECT_BREAKS_LOOSE", true)
		_hint_all("HINT_SUSPECT_LOOSE")


## Whether a cop is looking at the suspect (WATCH_ANGLE, WATCH_REACH), with nothing but the one-way mirror in between.
func watched() -> bool:
	if not suspect:
		return false
	var head := suspect.global_position + Vector3.UP * 1.2
	var exclude: Array[RID] = []
	for body in get_tree().get_nodes_in_group("see_through"):
		exclude.append((body as CollisionObject3D).get_rid())
	for cop in get_tree().get_nodes_in_group("cops"):
		var eye: Vector3 = (cop as Cop).camera.global_position
		var to := head - eye
		if to.length() > WATCH_REACH or (-cop.camera.global_basis.z).angle_to(to) > deg_to_rad(WATCH_ANGLE):
			continue
		var ray := PhysicsRayQueryParameters3D.create(eye, head, 1, exclude)
		if suspect.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			return true
	return false


## A cop grabs the dangerous one on the loose: the first slows him down, a second one (or a cop alone) catches him.
func grab_loose(cop: Cop) -> void:
	if not loose or not is_on() or follower:
		return
	var alone := get_tree().get_nodes_in_group("cops").size() <= 1
	if not alone and (_grip_left <= 0.0 or _grip_by == cop):
		_grip_by = cop
		_grip_left = GRIP_SECONDS
		suspect.slowed = true
		_say("SUSPECT_STRUGGLES", false)
		return
	loose = false
	_grip_left = 0.0
	suspect.sit()
	nerves = clampf(nerves + CAUGHT_NERVES, 0.0, FULL)
	_emit()
	_say("SUSPECT_CAUGHT", true)
	_check(cop)


## Out the front door: he's off in the old patrol car and the chase is on.
func _on_outside() -> void:
	if not loose or not is_on() or not getaway or follower:
		return
	_escape()


## Off in the old patrol car (online, a guest's follows the host's chase: CaseSync).
func _escape() -> void:
	loose = false
	escaping = true
	suspect.hide()
	chase = ChaseCase.begin(get_parent(), SuspectCar.OLD_PATROL, getaway.global_transform, car, city, case_seed,
		city_map, getaway)
	chase.who = "dangerous"
	chase.online = online
	chase.follower = follower
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_DANGEROUS_STREET")


func _on_chase_ended(caught: bool) -> void:
	escaping = false
	if not caught:
		escaped = true
		failed_label.text = "CASE_FAILED_SUSPECT_ESCAPED"
		failed_label.show()
		if not follower:
			_finish_soon()
		return
	# Back from the patrol car to his chair, scared (a guest's only shows it: the host's decides, NpcSync removes the
	# one who got out).
	if follower:
		suspect.sit()
		return
	if chase.home_car().prisoner == chase.suspect:
		chase.home_car().prisoner = null
	chase.suspect.queue_free()
	suspect.sit()
	nerves = clampf(nerves + CAUGHT_NERVES, 0.0, FULL)
	_emit()
	_say("SUSPECT_CAUGHT", true)
	_hint_all("HINT_DANGEROUS_BACK")
	_check(null)


func _doze(delta: float) -> void:
	_idle += delta
	if asleep and nerves > 0.0:
		nerves = maxf(nerves - SLEEP_DRAIN * delta, 0.0)
		_emit()
	elif not asleep and _idle >= SLEEP_SECONDS:
		asleep = true
		_say("SUSPECT_FALLS_ASLEEP", true)


## A cop does action `id` (ACTIONS) on the suspect (with twins, the one nearest to him). Returns whether it counted.
func act(id: String, cop: Cop = null) -> bool:
	# Online the host's case counts every action (the guest's E, donut or chair reaches it too).
	if follower:
		return false
	if twin and cop and twin.global_position.distance_to(cop.global_position) < \
			suspect.global_position.distance_to(cop.global_position):
		return _act_on_twin(id, cop)
	return _act(id, cop)


## The action on the twin in the cell: he takes the room twin's place for it.
func _act_on_twin(id: String, cop: Cop) -> bool:
	_swap()
	var counted := _act(id, cop)
	_swap()
	return counted


func _swap() -> void:
	_swapped = not _swapped
	var other := suspect
	suspect = twin
	twin = other
	var other_nerves := nerves
	nerves = twin_nerves
	twin_nerves = other_nerves
	var other_slips := slips
	slips = twin_slips
	twin_slips = other_slips


## The meters to the HUD: the room twin's nerves and the lawyer, and the cell twin's nerves.
func _emit() -> void:
	meters_changed.emit(twin_nerves if _swapped else nerves, lawyer)
	if twin:
		twin_changed.emit(nerves if _swapped else twin_nerves)


func _act(id: String, cop: Cop) -> bool:
	if not is_on() or _gap_left > 0.0 or loose:
		return false
	_gap_left = ACTION_GAP
	_idle = 0.0
	var waking := asleep
	if asleep:
		if not WAKE_ACTIONS.has(id):
			_say("SUSPECT_SNORES", false)
			return false
		asleep = false
	var action: Dictionary = ACTIONS[id]
	# The folder going back and forth between the twins isn't the same trick again.
	_streak = _streak + 1 if id == _last and id != "show_folder" else 0
	_last = id
	var gain: float = action.nerves
	var now := Time.get_ticks_msec() / 1000.0
	if gain > 0.0:
		gain *= pow(REPEAT_FACTOR, _streak) * _contrast
		_contrast = 1.0
		_bad_by = cop
		_bad_at = now
	elif now - _bad_at <= CONTRAST_SECONDS:
		_contrast = CONTRAST if cop != _bad_by else SOLO_CONTRAST
		_bad_at = -INF
	var lawyer_gain: float = action.lawyer
	var react: String = action.react
	if suspect_id == "self_lawyer":
		if gain > 0.0:
			lawyer_gain += SELF_LAWYER_EXTRA
		elif id == "give_coffee":
			gain = 0.0
			lawyer_gain = 0.0
			react = "SUSPECT_WANTS_TEA"
	if suspect_id == "influencer":
		if gain > 0.0 and now - _good_at > INFLUENCER_SECONDS:
			lawyer_gain += INFLUENCER_LAWYER
			react = "SUSPECT_STREAMS"
		elif action.nerves <= 0.0:
			_good_at = now
	nerves = clampf(nerves + gain, 0.0, FULL)
	lawyer = clampf(lawyer + lawyer_gain, 0.0, FULL)
	if suspect_id == "sweet_grandpa" and gain > 0.0 and _cries(now, gain):
		lawyer = clampf(lawyer + CRY_LAWYER, 0.0, FULL)
		react = "SUSPECT_CRIES"
	if waking:
		react = "SUSPECT_WAKES"
	if suspect_id == "fan" and confessions.is_empty():
		_blurt()
		react = "FAN_CONFESSES_ALL"
	if suspect_id == "mute":
		react = "MUTE_FLINCHES" if gain > 0.0 else "MUTE_THUMBS_UP"
	elif suspect_id == "foreigner":
		react = _foreign(react)
	_emit()
	if id == "aim_lamp":
		_aim_lamp()
	elif id == "flick_lights":
		_flick_lights()
	if _streak > 0 and gain > 0.0:
		var line := "SUSPECT_REACT_REPEAT"
		if suspect_id == "mute":
			line = "MUTE_YAWNS"
		elif suspect_id == "foreigner":
			line = _foreign(line)
		_say(line, false)
	else:
		_say(react, react in ["SUSPECT_CRIES", "SUSPECT_WAKES", "FAN_CONFESSES_ALL"])
	_check(cop)
	return true


## The sweet grandpa: true when the bad cop's nerves of the last CRY_SECONDS pass CRY_NERVES (he starts over after).
func _cries(now: float, gain: float) -> bool:
	_recent = _recent.filter(func(entry: Vector2) -> bool: return now - entry.x <= CRY_SECONDS)
	_recent.append(Vector2(now, gain))
	var total := 0.0
	for entry in _recent:
		total += entry.y
	if total <= CRY_NERVES:
		return false
	_recent.clear()
	return true


## A cop uses a prop of the room: the coffee machine fills a cup in their hands, the rest are actions.
func use_prop(id: String, cop: Cop) -> void:
	if id != "pour_coffee":
		act(id, cop)
		return
	if not is_on() or follower or cop.get_node("Grabber").held:
		return
	var cup: CoffeeCup = COFFEE_SCENE.instantiate()
	cop.get_parent().add_child(cup)
	cup.global_position = cop.camera.global_position - cop.camera.global_basis.z * 0.6
	cop.get_node("Grabber").grab(cup)
	# A guest's cop: the host poured it (the guests get a copy of the cup), so the guest's own hands are told.
	if cop.sync and not cop.sync.is_multiplayer_authority():
		cop.sync.tell_held()


## A cup of coffee set down near him: he takes it.
func coffee_served(cup: CoffeeCup) -> bool:
	if not suspect or cup.global_position.distance_to(suspect.global_position + Vector3.UP * 0.8) > CoffeeCup.REACH:
		return false
	var cops := cup.handling_cops(CoffeeCup.SERVED_SECONDS)
	return act("give_coffee", cops[0] if not cops.is_empty() else null)


## A chair hit the floor hard: this close to him, it's the bad cop's chair.
func chair_thrown(chair: InterrogationChair) -> bool:
	if not suspect or chair.global_position.distance_to(suspect.global_position) > InterrogationChair.REACH:
		return false
	var cops := chair.handling_cops(InterrogationChair.THROWN_SECONDS)
	return act("throw_chair", cops[0] if not cops.is_empty() else null)


## A cop sat down on a chair: near him, it's the good cop sitting by his side.
func sat_down_by(chair: InterrogationChair, cop: Cop) -> bool:
	if not suspect or chair.global_position.distance_to(suspect.global_position) > InterrogationChair.REACH:
		return false
	return act("sit_down", cop)


## A cop shouted into the microphone (VoiceChat): near him, it's the bad cop's shout.
func shouted_by(cop: Cop) -> void:
	if follower:
		if online and is_on():
			online.request_shout()
		return
	if _near(cop, SHOUT_REACH):
		act("shout", cop)


## A cop ate a donut: in front of the suspect, it's torture.
func donut_eaten_by(cop: Cop) -> void:
	if _near(cop, EAT_REACH):
		act("eat_donut", cop)


## Whether the cop is this close to the suspect, or to his twin.
func _near(cop: Cop, reach: float) -> bool:
	for man: InterrogationSuspect in [suspect, twin]:
		if man and cop.global_position.distance_to(man.global_position) <= reach:
			return true
	return false


## The case folder set down: by the twin it wasn't last shown to, it's the bluff.
func folder_shown(folder: CaseFolder) -> bool:
	if not twin or follower:
		return false
	var cops := folder.handling_cops(CaseFolder.SHOWN_SECONDS)
	var cop: Cop = cops[0] if not cops.is_empty() else null
	var last := _folder_with if _folder_with else suspect
	for man: InterrogationSuspect in [suspect, twin]:
		if man != last and folder.global_position.distance_to(man.global_position + Vector3.UP * 0.8) <= CaseFolder.REACH:
			_gap_left = 0.0
			var counted := _act_on_twin("show_folder", cop) if man == twin else _act("show_folder", cop)
			if counted:
				_folder_with = man
			return counted
	return false


## With twins, whether the one being worked is the guilty one.
func _guilty_here() -> bool:
	return not twin or _swapped == guilty_in_cell


func _check(_cop: Cop) -> void:
	var guilty := _guilty_here()
	while slips < SLIPS_AT.size() and nerves >= SLIPS_AT[slips]:
		slips += 1
		var slip := tr("SLIP_%s_%d" % [crime, slips]) if guilty else tr(TWIN_SLIPS[slips - 1])
		if suspect_id == "owner":
			var said: Array = custody.get("slips", [])
			slip = str(said[slips - 1]) if slips <= said.size() else tr(OWNER_SLIPS[slips - 1])
		if suspect_id == "mute":
			_draw(tr("MUTE_DRAW_%s_%d" % [crime, slips]), "MUTE_DRAWS")
			continue
		if suspect_id == "foreigner":
			_translate(tr("SLIP_%s_%d" % [crime, slips]), tr(TRANSLATOR_EXTRAS[slips - 1]))
			continue
		# The talker mixes his true slip with something that has nothing to do with it.
		_say(tr(TALKER_LINES[slips - 1]) + " " + slip if suspect_id == "talker" else slip, true)
	if nerves >= FULL and suspect_id == "fan":
		_say("FAN_PICK_ONE", true)
	elif nerves >= FULL and guilty:
		confessed = true
		if suspect_id == "mute":
			_draw(tr("CONFESS_" + crime), "MUTE_CONFESSES")
		elif suspect_id == "foreigner":
			_translate(tr("CONFESS_" + crime), "")
		else:
			_say("CONFESS_" + crime, true)
		solved_label.show()
		_finish_soon()
	elif lawyer >= FULL:
		lawyer_came = true
		if loose:
			loose = false
			suspect.sit()
		_lawyer_arrives()
		failed_label.text = "CASE_FAILED_LAWYER_INTERROGATION"
		failed_label.show()
		_finish_soon()
	elif nerves >= FULL:
		_say("TWIN_NOT_ME", true)


## The fan confesses his crime and two more from the list, in an order drawn with the seed.
func _blurt() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("fan %d" % case_seed)
	var others: Array = CRIMES.filter(func(id: String) -> bool: return id != crime)
	var picked: Array = [crime]
	while picked.size() < FAN_SHEETS_AT.size():
		picked.append(others.pop_at(rng.randi() % others.size()))
	for i in picked.size():
		var j := rng.randi() % picked.size()
		var swap: String = picked[i]
		picked[i] = picked[j]
		picked[j] = swap
	_hold_up(picked)


## The fan's confessions held up on the table, by crime. Named by their place, so a guest's E reaches the host's.
func _hold_up(crimes: Array) -> void:
	for i in crimes.size():
		var sheet_of := FanConfession.new()
		sheet_of.name = "FanConfession%d" % i
		sheet_of.crime = crimes[i]
		sheet_of.position = FAN_SHEETS_AT[i]
		# Held up toward the door side, leaning back a little.
		sheet_of.rotation.x = -0.3
		suspect.get_parent().add_child(sheet_of)
		confessions.append(sheet_of)


## A cop picks one of the fan's confessions: the true one solves the case, a wrong one brings the lawyer closer.
func pick_confession(sheet_of: FanConfession, _cop: Cop) -> void:
	if not is_on() or follower or not confessions.has(sheet_of):
		return
	if sheet_of.crime == crime:
		confessed = true
		_say("FAN_RIGHT", true)
		solved_label.show()
		_finish_soon()
		return
	confessions.erase(sheet_of)
	sheet_of.queue_free()
	lawyer = clampf(lawyer + FAN_WRONG_LAWYER, 0.0, FULL)
	_emit()
	_say("FAN_WRONG", true)
	_check(null)


## The foreigner's line for a reaction: always the same gibberish for the same reaction.
func _foreign(react: String) -> String:
	return FOREIGN_LINES[hash(react) % FOREIGN_LINES.size()]


## The foreigner says something in his language and the translator passes it on, with his own line at the end.
func _translate(text: String, extra: String) -> void:
	_say(FOREIGN_LINES[(slips + crime.length()) % FOREIGN_LINES.size()], true)
	if translator:
		var line := tr("TRANSLATOR_SAYS") % text
		translator.say(line + (" " + extra if extra != "" else ""), InterrogationSuspect.LINE_SECONDS * 2.0)


## The mute puts something on his sheet of paper (it shows up the first time), with a gesture over his head.
func _draw(text: String, gesture: String) -> void:
	_show_sheet(text)
	_say(gesture, true)


## The mute's sheet of paper on the table, with `text` drawn on it (it shows up the first time).
func _show_sheet(text: String) -> void:
	if not sheet:
		var paper := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(0.42, 0.3)
		paper.mesh = quad
		var white := StandardMaterial3D.new()
		white.albedo_color = Color(0.97, 0.96, 0.9)
		paper.material_override = white
		paper.position = SHEET_AT
		# Held up toward the door side, leaning back a little.
		paper.rotation.x = -0.3
		paper.name = "MuteSheet"
		suspect.get_parent().add_child(paper)
		sheet = Label3D.new()
		sheet.position.z = 0.002
		sheet.pixel_size = 0.001
		sheet.font_size = 36
		sheet.modulate = Color(0.15, 0.15, 0.2)
		sheet.outline_size = 0
		sheet.width = 380.0
		sheet.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		paper.add_child(sheet)
	sheet.text = text


## A line over the suspect's head; reactions don't cut off what slipped out.
func _say(text: String, important: bool) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if not suspect or (not important and now < _talking_until):
		return
	var seconds := InterrogationSuspect.LINE_SECONDS * (2.0 if important else 1.0)
	if important:
		_talking_until = now + seconds
	suspect.say(text, seconds)


## The hanging lamp of this level.
func _lamp() -> Light3D:
	for node in get_tree().get_nodes_in_group("interrogation_lamp"):
		if get_parent().is_ancestor_of(node):
			return node as Light3D
	return null


func _aim_lamp() -> void:
	_tell_guests("_aim_lamp")
	var lamp := _lamp() as SpotLight3D
	if not lamp or not suspect:
		return
	var rest := lamp.rotation
	var face := (lamp.get_parent() as Node3D).to_local(suspect.global_position + Vector3.UP * 1.2)
	var tween := lamp.create_tween()
	tween.tween_property(lamp, "rotation", Transform3D(Basis(), lamp.position).looking_at(face).basis.get_euler(), 0.25)
	tween.tween_interval(LAMP_SECONDS)
	tween.tween_property(lamp, "rotation", rest, 0.5)


func _flick_lights() -> void:
	_tell_guests("_flick_lights")
	var lamp := _lamp()
	if not lamp:
		return
	var tween := lamp.create_tween()
	for i in FLICKS:
		tween.tween_callback(lamp.hide)
		tween.tween_interval(FLICK_SECONDS)
		tween.tween_callback(lamp.show)
		tween.tween_interval(FLICK_SECONDS)


func _lawyer_arrives() -> void:
	var at := suspect.get_parent() as Node3D
	var man: Node3D = LAWYER_MODEL.instantiate()
	man.name = "Lawyer"
	man.position = InterrogationWing.LAWYER_AT
	man.rotation.y = PI
	at.add_child(man)
	var line := Label3D.new()
	line.text = "LAWYER_ARRIVES"
	line.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	line.pixel_size = 0.004
	line.outline_size = 10
	line.font_size = 40
	line.width = 600.0
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.position.y = 1.9
	man.add_child(line)


## Host: the guests see the same passing effect.
func _tell_guests(method: String) -> void:
	if online and not follower:
		online.tell(method)


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)


func _finish_soon() -> void:
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## What the owner's confession adds to the salary: OWNER_SHARE of the evidence left behind in his raid.
func owner_pay() -> float:
	return float(custody.get("missed", 0)) * OWNER_SHARE


## The end of shift screen: a confession pays the salary (decision 90), the lawyer nothing. Online the host's numbers
## go to the guests.
func finish_shift() -> void:
	if shift_over or follower:
		return
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	var report := ShiftReport.pay(confessed, [owner_pay()] if suspect_id == "owner" else [], 0)
	var result := {"solved": confessed, "report": report, "awards": ShiftReport.awards(stats)}
	# Interrogated, the owner goes home whatever he said.
	if suspect_id == "owner":
		PlaceDraw.release_custody()
	var campaign := Campaign.current
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.finish_shift("interrogation_" + crime, confessed, result.report, QUOTA)
		campaign.save()
		result.campaign = {"shift": played, "money": campaign.money, "over": campaign.is_over(),
			"promoted": campaign.is_promoted()}
	_show_result(result)


func _show_result(result: Dictionary) -> void:
	shift_over = true
	_result = result
	for cop in get_tree().get_nodes_in_group("cops"):
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	solved_label.hide()
	failed_label.hide()
	var awards: Array[Dictionary] = []
	awards.assign(result.awards)
	shift_screen.show_report(result.solved, result.report, 0, awards)
	var over := false
	if result.has("campaign"):
		shift_screen.show_campaign(result.campaign.shift, Campaign.SHIFTS, result.campaign.money, result.campaign.over,
			result.campaign.promoted)
		over = result.campaign.over
	# Only the host plays the next case for everyone, and not after the last shift.
	shift_screen.get_node("%AgainButton").visible = not follower and not over


## What a guest needs to show the same interrogation (CaseSync).
func snapshot() -> Dictionary:
	return {"tip": tip_given, "nerves": nerves, "lawyer": lawyer, "twin": twin_nerves, "loose": loose,
		"asleep": asleep, "confessed": confessed, "lawyer_came": lawyer_came,
		"confessions": confessions.map(func(sheet_of: FanConfession) -> String: return sheet_of.crime),
		"sheet": sheet.text if sheet else "", "result": _result,
		# The dangerous one out on the street, and the chase after him (persecucion-final.md).
		"chase": chase.snapshot() if chase else {}}


## A guest takes the host's interrogation: the meters, what's on the table, the confession or the lawyer, and the end
## of shift screen. What he says comes with him (NpcSync).
func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	nerves = state.nerves
	lawyer = state.lawyer
	twin_nerves = state.twin
	loose = state.loose
	asleep = state.asleep
	_emit()
	if not (state.chase as Dictionary).is_empty() and getaway:
		if not chase:
			_escape()
		chase.apply_snapshot(state.chase)
	if confessions.is_empty() and not (state.confessions as Array).is_empty():
		_hold_up(state.confessions)
	for sheet_of in confessions.duplicate():
		if not (state.confessions as Array).has(sheet_of.crime):
			confessions.erase(sheet_of)
			sheet_of.queue_free()
	if state.sheet != "":
		_show_sheet(state.sheet)
	if state.confessed and not confessed:
		confessed = true
		solved_label.show()
	if state.lawyer_came and not lawyer_came:
		lawyer_came = true
		_lawyer_arrives()
		failed_label.text = "CASE_FAILED_LAWYER_INTERROGATION"
		failed_label.show()
	if not (state.result as Dictionary).is_empty() and not shift_over:
		_show_result(state.result)
