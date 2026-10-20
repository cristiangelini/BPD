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
## The quota of an interrogation shift (propuesta, until Cristian decides): the confession's salary, so confessing
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
const SUSPECTS := ["talker", "sweet_grandpa", "self_lawyer", "sleeper"]
const SUSPECT_MODELS := {
	"talker": "res://assets/models/npc_sospechoso.glb",
	"sweet_grandpa": "res://assets/models/npc_abuelo.glb",
	"self_lawyer": "res://assets/models/npc_abogado.glb",
	"sleeper": "res://assets/models/npc_preso.glb",
}
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
## The talker (suspect 1): before each slip he confesses something that has nothing to do with the case.
const TALKER_LINES := ["TALKER_1", "TALKER_2", "TALKER_3"]
const LAWYER_MODEL := preload("res://assets/models/npc_abogado.glb")
const COFFEE_SCENE := preload("res://scenes/props/coffee_cup.tscn")

signal meters_changed(nerves: float, lawyer: float)

var case_seed := 0
var crime := ""
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
## The last bad cop action: who did it and when (ms), and the bonus waiting for the next one.
var _bad_by: Cop
var _bad_at := -INF
var _contrast := 1.0


## The case on in this tree, if any.
static func active(tree: SceneTree) -> InterrogationCase:
	return tree.get_first_node_in_group("interrogation") as InterrogationCase


static func pick_suspect(seed_value: int, args: PackedStringArray) -> String:
	for arg in args:
		if arg.begins_with("--suspect=") and SUSPECTS.has(arg.trim_prefix("--suspect=")):
			return arg.trim_prefix("--suspect=")
	return SUSPECTS[hash("suspect %d" % seed_value) % SUSPECTS.size()]


static func pick_crime(seed_value: int) -> String:
	return CRIMES[hash("crime %d" % seed_value) % CRIMES.size()]


## Starts the case: the tip waits for a cop to talk to the comisario (right away without one).
func start(comisario: Comisario = null) -> void:
	add_to_group("interrogation")
	crime = pick_crime(case_seed)
	briefing = CaseBriefing.new()
	add_child(briefing)
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	shift_screen.play_again.connect(func() -> void: PlaceDraw.start(get_tree()))
	shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_INTERROGATION_A", "CRIME_" + crime, "BRIEF_SUSPECT_" + suspect_id,
				"BRIEF_INTERROGATION_C"]))
			break
	briefing.finished.connect(_hint_all.bind("HINT_GO_INTERROGATION"), CONNECT_ONE_SHOT)


## The cops can work on him: the case was given and it isn't over.
func is_on() -> bool:
	return tip_given and not confessed and not lawyer_came


func _process(delta: float) -> void:
	_gap_left -= delta
	if suspect_id == "sleeper" and is_on():
		_doze(delta)


func _doze(delta: float) -> void:
	_idle += delta
	if asleep and nerves > 0.0:
		nerves = maxf(nerves - SLEEP_DRAIN * delta, 0.0)
		meters_changed.emit(nerves, lawyer)
	elif not asleep and _idle >= SLEEP_SECONDS:
		asleep = true
		_say("SUSPECT_FALLS_ASLEEP", true)


## A cop does action `id` (ACTIONS) on the suspect. Returns whether it counted.
func act(id: String, cop: Cop = null) -> bool:
	if not is_on() or _gap_left > 0.0:
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
	_streak = _streak + 1 if id == _last else 0
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
	nerves = clampf(nerves + gain, 0.0, FULL)
	lawyer = clampf(lawyer + lawyer_gain, 0.0, FULL)
	if suspect_id == "sweet_grandpa" and gain > 0.0 and _cries(now, gain):
		lawyer = clampf(lawyer + CRY_LAWYER, 0.0, FULL)
		react = "SUSPECT_CRIES"
	if waking:
		react = "SUSPECT_WAKES"
	meters_changed.emit(nerves, lawyer)
	if id == "aim_lamp":
		_aim_lamp()
	elif id == "flick_lights":
		_flick_lights()
	if _streak > 0 and gain > 0.0:
		_say("SUSPECT_REACT_REPEAT", false)
	else:
		_say(react, react == "SUSPECT_CRIES" or react == "SUSPECT_WAKES")
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
	if not is_on() or cop.get_node("Grabber").held:
		return
	var cup: CoffeeCup = COFFEE_SCENE.instantiate()
	cop.get_parent().add_child(cup)
	cup.global_position = cop.camera.global_position - cop.camera.global_basis.z * 0.6
	cop.get_node("Grabber").grab(cup)


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


## A cop shouted into the microphone (VoiceChat): near him, it's the bad cop's shout.
func shouted_by(cop: Cop) -> void:
	if suspect and cop.global_position.distance_to(suspect.global_position) <= SHOUT_REACH:
		act("shout", cop)


## A cop ate a donut: in front of the suspect, it's torture.
func donut_eaten_by(cop: Cop) -> void:
	if suspect and cop.global_position.distance_to(suspect.global_position) <= EAT_REACH:
		act("eat_donut", cop)


func _check(_cop: Cop) -> void:
	while slips < SLIPS_AT.size() and nerves >= SLIPS_AT[slips]:
		slips += 1
		var slip := tr("SLIP_%s_%d" % [crime, slips])
		# The talker mixes his true slip with something that has nothing to do with it.
		_say(tr(TALKER_LINES[slips - 1]) + " " + slip if suspect_id == "talker" else slip, true)
	if nerves >= FULL:
		confessed = true
		_say("CONFESS_" + crime, true)
		solved_label.show()
		_finish_soon()
	elif lawyer >= FULL:
		lawyer_came = true
		_lawyer_arrives()
		failed_label.text = "CASE_FAILED_LAWYER_INTERROGATION"
		failed_label.show()
		_finish_soon()


## A line over the suspect's head; reactions don't cut off what slipped out.
func _say(text: String, important: bool) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if not suspect or (not important and now < _talking_until):
		return
	var seconds := InterrogationSuspect.LINE_SECONDS * (2.0 if important else 1.0)
	if important:
		_talking_until = now + seconds
	suspect.say(text, seconds)


func _aim_lamp() -> void:
	var lamp := get_tree().get_first_node_in_group("interrogation_lamp") as SpotLight3D
	if not lamp or not suspect:
		return
	var rest := lamp.rotation
	var face := (lamp.get_parent() as Node3D).to_local(suspect.global_position + Vector3.UP * 1.2)
	var tween := lamp.create_tween()
	tween.tween_property(lamp, "rotation", Transform3D(Basis(), lamp.position).looking_at(face).basis.get_euler(), 0.25)
	tween.tween_interval(LAMP_SECONDS)
	tween.tween_property(lamp, "rotation", rest, 0.5)


func _flick_lights() -> void:
	var lamp := get_tree().get_first_node_in_group("interrogation_lamp") as Light3D
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


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)


func _finish_soon() -> void:
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The end of shift screen: a confession pays the salary (decision 90), the lawyer nothing.
func finish_shift() -> void:
	if shift_over:
		return
	shift_over = true
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	solved_label.hide()
	failed_label.hide()
	var report := ShiftReport.pay(confessed, [], 0)
	var awards := ShiftReport.awards(stats)
	var campaign := Campaign.current
	var over := false
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.finish_shift("interrogation_" + crime, confessed, report, QUOTA)
		campaign.save()
		over = campaign.is_over()
		shift_screen.show_report(confessed, report, 0, awards)
		shift_screen.show_campaign(played, Campaign.SHIFTS, campaign.money, over, campaign.is_promoted())
	else:
		shift_screen.show_report(confessed, report, 0, awards)
	shift_screen.get_node("%AgainButton").visible = not over
