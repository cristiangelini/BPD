class_name GymRoutine
extends Node3D

## El Toro's routine (infiltracion-gimnasio.md, step 3, decision 172): 20 s in and then every 40 s he blows his whistle
## and shouts an exercise drawn with the seed, and for 10 s everyone in the gym does it. Squats: crouch or stand up (C)
## at least every 2 s. Jumps: jump (Space) at least every 2 s. Treadmill: run (Shift) on a treadmill. Weight: hold a
## dumbbell from the rack. The exercises spend the cop's stamina (the running one); a cop that runs out gives up,
## panting for 2 s, and the members who see it get much more suspicious than with one who just doesn't do it. Each PC
## judges its own cop once a second and tells the host (`missed`), where ClubSuspicion makes the members who see it
## suspicious. The host decides the routines and the exercise and tells the guests. Every number here is (propuesta).

signal routine_started(exercise: String)
signal missed(cop: Cop, amount: float)

const EXERCISES: Array[String] = ["squats", "jumps", "treadmill", "weight"]
const FIRST := 20.0
## Seconds between one routine's end and the next one's start, and how long a routine lasts (one every 40 s).
const BREAK := 30.0
const ROUTINE := 10.0
## El Toro warns this long before.
const WARNING := 5.0
## Squats and jumps: one at least this often (s).
const EVERY := 2.0
## After the whistle, this long to start before it counts.
const GRACE := 1.0
const JUDGE_EVERY := 1.0
## What it adds to the members who see it: each second not doing it, and giving up.
const NOT_DOING := 20.0
const GAVE_UP := 30.0
## Panting after giving up (s).
const GIVE_UP_TIME := 2.0
## Stamina a squat, jump or weight routine spends per second (s of running), over what resting gives back; the
## treadmill gives back this much of running's cost. Both last 12 s from full: a rested cop makes it, a tired one doesn't.
const EXERCISE_DRAIN := 0.5
const TREADMILL_REFUND := 0.5
const DUMBBELL_KG := 6.0
## How the members move along: down for squats, up for jumps (m).
const SQUAT_DIP := 0.25
const JUMP_HOP := 0.3

## Seconds to the next routine (host) and left of this one (every PC; 0: no routine).
var next_left := FIRST
var routine_left := 0.0
var exercise := ""
var since_start := 0.0
var case_seed := 0
## Whether a world position is inside the gym, and the treadmill it stands on or -1 (GymHall sets them).
var inside: Callable = func(_at: Vector3) -> bool: return false
var treadmill_at: Callable = func(_at: Vector3) -> int: return -1
var toro: ClubMember
var members: Array[ClubMember] = []
## This PC's cop this routine: seconds right and wrong, and whether it gave up.
var good_seconds := 0
var bad_seconds := 0
var gave_up := false
var _rng := RandomNumberGenerator.new()
var _judge_left := JUDGE_EVERY
var _warned := false
## Seconds since this PC's cop last crouched or stood up, and last left the floor.
var _since_crouch := INF
var _since_jump := INF
var _was_crouching := false
var _member_floor := {}
var _whistle: AudioStreamPlayer3D
var _mark: Label3D
var _hud: CanvasLayer
var _cue: Label
var _verdict: Label


func _ready() -> void:
	add_to_group("gym_routine")
	_rng.seed = hash(["gym routine", case_seed])
	_whistle = AudioStreamPlayer3D.new()
	_whistle.stream = MimeRehearsal.whistle_stream()
	_whistle.max_distance = 40.0
	_whistle.volume_db = -4.0
	add_child(_whistle)
	_mark = Label3D.new()
	_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_mark.no_depth_test = true
	_mark.pixel_size = 0.006
	_mark.font_size = 48
	_mark.outline_size = 12
	_mark.modulate = Color(1, 0.4, 0.3)
	_mark.hide()
	add_child(_mark)
	for member in members:
		_member_floor[member] = member.position.y
	_build_hud()


func is_routine() -> bool:
	return routine_left > 0.0


## Host: a routine starts now on every PC, with an exercise drawn with the seed (or this one: tests).
func start_routine(drawn := "") -> void:
	next_left = BREAK
	_warned = false
	if drawn.is_empty():
		drawn = EXERCISES[_rng.randi_range(0, EXERCISES.size() - 1)]
	_begin(drawn, ROUTINE)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_started.rpc_id(peer, drawn, routine_left)


@rpc("authority", "call_remote", "reliable")
func _started(drawn: String, left: float) -> void:
	if EXERCISES.has(drawn):
		_begin(drawn, left)


## Every PC: the whistle, el Toro shouts the exercise, and `left` seconds of it.
func _begin(drawn: String, left: float) -> void:
	exercise = drawn
	routine_left = left
	since_start = 0.0
	good_seconds = 0
	bad_seconds = 0
	gave_up = false
	_judge_left = JUDGE_EVERY
	_whistle.play()
	if toro:
		toro.say("TORO_ROUTINE_" + exercise.to_upper())
	var cop := VoiceChat.local_cop(get_tree())
	if cop and inside.call(cop.global_position):
		cop.show_hint("HINT_GYM_" + exercise.to_upper())
	routine_started.emit(exercise)


func _process(delta: float) -> void:
	if toro:
		_mark.global_position = toro.global_position + Vector3.UP * 2.6
	if multiplayer.is_server():
		_lead(delta)
	_track(delta)
	if is_routine():
		routine_left = maxf(routine_left - delta, 0.0)
		since_start += delta
		_spend(delta)
		_judge_left -= delta
		if _judge_left <= 0.0:
			_judge_left = JUDGE_EVERY
			judge()
	_move_members()
	_refresh_marks()


## Host: counts down to the next routine, with el Toro's warning.
func _lead(delta: float) -> void:
	if is_routine():
		return
	next_left -= delta
	if next_left <= WARNING and not _warned:
		_warned = true
		if toro:
			toro.say("TORO_ROUTINE_SOON")
	if next_left <= 0.0:
		start_routine()


## How long since this PC's cop last crouched or stood up, and last was in the air.
func _track(delta: float) -> void:
	_since_crouch += delta
	_since_jump += delta
	var cop := VoiceChat.local_cop(get_tree())
	if not cop:
		return
	if cop.is_crouching != _was_crouching:
		_was_crouching = cop.is_crouching
		_since_crouch = 0.0
	if not cop.is_on_floor():
		_since_jump = 0.0


## Whether this PC's cop is doing the exercise right now.
func doing(cop: Cop) -> bool:
	match exercise:
		"squats":
			return _since_crouch <= EVERY
		"jumps":
			return _since_jump <= EVERY
		"treadmill":
			return cop.is_running and treadmill_at.call(cop.global_position) != -1
		"weight":
			return holds_dumbbell(cop)
	return false


static func holds_dumbbell(cop: Cop) -> bool:
	var held: Grabbable = cop.get_node("Grabber").held
	return held != null and held.is_in_group("gym_dumbbells")


## The exercise tires this PC's cop out: past resting, or running at a discount on a treadmill.
func _spend(delta: float) -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not cop or gave_up or not inside.call(cop.global_position) or not doing(cop):
		return
	if exercise == "treadmill":
		cop.stamina = minf(cop.stamina + delta * TREADMILL_REFUND, GameScale.RUN_STAMINA)
		return
	var resting := GameScale.RUN_STAMINA / GameScale.STAMINA_RECOVERY
	cop.stamina = maxf(cop.stamina - delta * (resting + EXERCISE_DRAIN), 0.0)


## Once a second during a routine: this PC's cop in the gym does the exercise, doesn't, or runs out of air and gives up.
func judge() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not cop or not is_routine() or gave_up or since_start < GRACE or not inside.call(cop.global_position):
		return
	if cop.stamina <= 0.0:
		gave_up = true
		bad_seconds += 1
		cop.stagger(GIVE_UP_TIME)
		_verdict.text = "GYM_GAVE_UP"
		_report(cop, GAVE_UP)
		return
	if doing(cop):
		good_seconds += 1
		_verdict.text = "GYM_GOOD"
		return
	bad_seconds += 1
	_verdict.text = "GYM_NOT_DOING_" + exercise.to_upper()
	_report(cop, NOT_DOING)


func _report(cop: Cop, amount: float) -> void:
	if multiplayer.is_server():
		missed.emit(cop, amount)
	else:
		_missed.rpc_id(_net().HOST_ID, amount)


@rpc("any_peer", "call_remote", "reliable")
func _missed(amount: float) -> void:
	var sync: CopSync = _net().cop_syncs.get(multiplayer.get_remote_sender_id())
	if multiplayer.is_server() and sync and is_instance_valid(sync.cop):
		missed.emit(sync.cop, minf(amount, GAVE_UP))


## The Net of this PC's multiplayer branch: the autoload in the game, each test PC's own in the online tests.
func _net() -> Node:
	var branch := multiplayer as SceneMultiplayer
	if branch and not branch.root_path.is_empty():
		var net := get_node_or_null(str(branch.root_path) + "/Net")
		if net:
			return net
	return Net


## The members squat and jump along (only how they look; their spots stay put).
func _move_members() -> void:
	var beat := absf(sin(since_start * PI))
	for member in members:
		if not is_instance_valid(member) or member.is_cuffed() or not _member_floor.has(member):
			continue
		var offset := 0.0
		if is_routine() and exercise == "squats":
			offset = -SQUAT_DIP * beat
		elif is_routine() and exercise == "jumps":
			offset = JUMP_HOP * beat
		member.position.y = _member_floor[member] + offset


func _refresh_marks() -> void:
	_mark.visible = is_routine()
	_mark.text = "GYM_EX_" + exercise.to_upper()
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = is_routine() and cop != null and inside.call(cop.global_position)
	if not _hud.visible:
		return
	_cue.text = "%s  %d" % [tr(_mark.text), ceili(routine_left)]
	if since_start < GRACE:
		_verdict.text = "GYM_HOW_" + exercise.to_upper()


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-200, 120)
	box.custom_minimum_size = Vector2(400, 0)
	_cue = Label.new()
	_cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cue.add_theme_font_size_override("font_size", 40)
	box.add_child(_cue)
	_verdict = Label.new()
	_verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verdict.add_theme_font_size_override("font_size", 24)
	box.add_child(_verdict)
	_hud.add_child(box)
	_hud.hide()
	add_child(_hud)
