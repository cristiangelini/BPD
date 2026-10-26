class_name MimeRehearsal
extends Node3D

## The mimes' rehearsal (infiltracion-mimos.md, step 4, decision 170): every so often Maestra Pausa blows her whistle
## and the troupe rehearses on the stage, switching between two things. "¡Mímica!": everyone presses on the invisible
## wall, and a cop on the stage holds H. "¡Estatua!": everyone freezes, and a cop on the stage neither moves nor holds
## H. During a statue the mimes don't turn their heads (their sight cone narrows), the moment to slip off. Each PC
## judges its own cop once a second and tells the host (`missed`), where ClubSuspicion makes the mimes who see it
## suspicious; off the stage during a rehearsal, ClubSuspicion sees it itself. The host decides the rehearsals and the
## switches and tells the guests. Every number here is (propuesta).

signal rehearsal_started
signal missed(cop: Cop, amount: float)

const FIRST := 20.0
## Seconds between one rehearsal's end and the next one's start, and how long a rehearsal lasts.
const BREAK := 30.0
const REHEARSAL := 40.0
## Pausa points at the stage this long before.
const WARNING := 5.0
## Each stretch of mime, and each statue, lasts between these (drawn with the seed).
const MIME := Vector2(4.0, 7.0)
const STATUE := Vector2(3.0, 6.0)
## After a switch, this long to catch up before it counts.
const GRACE := 0.6
const JUDGE_EVERY := 1.0
## What each second wrong adds to the mimes who see it: not miming during the mime, moving during the statue.
const NOT_MIMING := 15.0
const MOVED := 25.0
## Walking more than this in a second is moving during the statue (m).
const STILL := 0.3
## During a statue the mimes see this much of their usual cone.
const STATUE_SIGHT := 0.5
const MIX_RATE := 22050

## Seconds to the next rehearsal (host) and left of this one (every PC; 0: no rehearsal).
var next_left := FIRST
var rehearsal_left := 0.0
var statue := false
## Seconds since the last switch (every PC).
var since_switch := 0.0
var case_seed := 0
## Whether a world position is on the stage, and inside the theater (MimeTheater sets them).
var on_stage: Callable = func(_at: Vector3) -> bool: return false
var inside: Callable = func(_at: Vector3) -> bool: return false
var pausa: ClubMember
## The mimes, whose sight narrows during a statue.
var members: Array[ClubMember] = []
## This PC's cop this rehearsal: seconds right and wrong.
var good_seconds := 0
var bad_seconds := 0
## Tests and the debug panel can make this PC's cop mime without H.
var force_miming := false
var _rng := RandomNumberGenerator.new()
var _switch_left := 0.0
var _judge_left := JUDGE_EVERY
var _warned := false
## How far this PC's cop walked since the last judgement.
var _walked := 0.0
var _last_at := Vector3.INF
var _whistle: AudioStreamPlayer3D
var _mark: Label3D
var _hud: CanvasLayer
var _cue: Label
var _verdict: Label


func _ready() -> void:
	add_to_group("mime_rehearsal")
	_rng.seed = hash(["mime rehearsal", case_seed])
	_whistle = AudioStreamPlayer3D.new()
	_whistle.stream = whistle_stream()
	_whistle.max_distance = 40.0
	_whistle.volume_db = -6.0
	add_child(_whistle)
	_mark = Label3D.new()
	_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_mark.no_depth_test = true
	_mark.pixel_size = 0.006
	_mark.font_size = 48
	_mark.outline_size = 12
	_mark.hide()
	add_child(_mark)
	_build_hud()


func is_rehearsal() -> bool:
	return rehearsal_left > 0.0


## Host: a rehearsal starts now on every PC, with the mime first.
func start_rehearsal() -> void:
	next_left = BREAK
	_warned = false
	_begin(REHEARSAL)
	_switch(false)


## Every PC: a rehearsal starts, with `left` seconds of it.
func _begin(left: float) -> void:
	rehearsal_left = left
	good_seconds = 0
	bad_seconds = 0
	if pausa:
		pausa.say("PAUSA_REHEARSAL")
	var cop := VoiceChat.local_cop(get_tree())
	if cop and inside.call(cop.global_position):
		cop.show_hint("HINT_MIME_REHEARSAL")
	rehearsal_started.emit()


## Host: mime or statue, on every PC.
func _switch(to_statue: bool) -> void:
	_switch_left = _rng.randf_range(STATUE.x, STATUE.y) if to_statue else _rng.randf_range(MIME.x, MIME.y)
	_set_statue(to_statue)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_switched.rpc_id(peer, to_statue, rehearsal_left)


@rpc("authority", "call_remote", "reliable")
func _switched(to_statue: bool, left: float) -> void:
	if not is_rehearsal():
		_begin(left)
	rehearsal_left = left
	_set_statue(to_statue)


func _set_statue(value: bool) -> void:
	statue = value
	since_switch = 0.0
	_whistle.play()
	_narrow_sight(statue)


func _narrow_sight(narrow: bool) -> void:
	for member in members:
		member.sight_angle = ClubMember.SIGHT_ANGLE * (STATUE_SIGHT if narrow else 1.0)


func _process(delta: float) -> void:
	if pausa:
		_mark.global_position = pausa.global_position + Vector3.UP * 2.6
	if multiplayer.is_server():
		_lead(delta)
	_track_walk()
	if is_rehearsal():
		rehearsal_left = maxf(rehearsal_left - delta, 0.0)
		since_switch += delta
		_judge_left -= delta
		if _judge_left <= 0.0:
			_judge_left = JUDGE_EVERY
			judge()
		if not is_rehearsal():
			statue = false
			_narrow_sight(false)
	_refresh_marks()


## Host: counts down to the next rehearsal, and switches during one.
func _lead(delta: float) -> void:
	if not is_rehearsal():
		next_left -= delta
		if next_left <= WARNING and not _warned:
			_warned = true
			if pausa:
				pausa.say("PAUSA_REHEARSAL_SOON")
		if next_left <= 0.0:
			start_rehearsal()
		return
	_switch_left -= delta
	if _switch_left <= 0.0 and rehearsal_left > GRACE:
		_switch(not statue)


func _track_walk() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not cop:
		return
	var at := cop.global_position
	if _last_at != Vector3.INF:
		_walked += Vector2(at.x - _last_at.x, at.z - _last_at.z).length()
	_last_at = at


## Whether this PC's player is miming: H held.
func is_miming() -> bool:
	return force_miming or Input.is_action_pressed("mime")


## Once a second during a rehearsal: this PC's cop on the stage did what the troupe does, or didn't.
func judge() -> void:
	var walked := _walked
	_walked = 0.0
	var cop := VoiceChat.local_cop(get_tree())
	if not cop or not is_rehearsal() or since_switch < GRACE or not on_stage.call(cop.global_position):
		return
	var miming := is_miming()
	var wrong := (miming or walked > STILL) if statue else not miming
	if not wrong:
		good_seconds += 1
		_verdict.text = "MIME_GOOD"
		return
	bad_seconds += 1
	_verdict.text = ("MIME_MOVED" if walked > STILL else "MIME_FROZE_WRONG") if statue else "MIME_NOT_MIMING"
	var amount := MOVED if statue else NOT_MIMING
	if multiplayer.is_server():
		missed.emit(cop, amount)
	else:
		_missed.rpc_id(_net().HOST_ID, amount)


@rpc("any_peer", "call_remote", "reliable")
func _missed(amount: float) -> void:
	var sync: CopSync = _net().cop_syncs.get(multiplayer.get_remote_sender_id())
	if multiplayer.is_server() and sync and is_instance_valid(sync.cop):
		missed.emit(sync.cop, minf(amount, MOVED))


## The Net of this PC's multiplayer branch: the autoload in the game, each test PC's own in the online tests.
func _net() -> Node:
	var branch := multiplayer as SceneMultiplayer
	if branch and not branch.root_path.is_empty():
		var net := get_node_or_null(str(branch.root_path) + "/Net")
		if net:
			return net
	return Net


func _refresh_marks() -> void:
	_mark.visible = is_rehearsal()
	_mark.text = "MIME_STATUE" if statue else "MIME_MIME"
	_mark.modulate = Color(0.7, 0.75, 0.85) if statue else Color(1, 0.85, 0.3)
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = is_rehearsal() and cop != null and inside.call(cop.global_position)
	if not _hud.visible:
		return
	_cue.text = _mark.text
	if not on_stage.call(cop.global_position):
		_verdict.text = "MIME_GO_TO_STAGE"


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-180, 120)
	box.custom_minimum_size = Vector2(360, 0)
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


## Pausa's whistle at each switch: a short shrill trill.
static func whistle_stream() -> AudioStreamWAV:
	var samples := int(MIX_RATE * 0.35)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / MIX_RATE
		var trill := 1.0 + 0.03 * sin(TAU * 28.0 * t)
		var fade := minf(1.0, (0.35 - t) * 20.0)
		var value := sin(TAU * 2600.0 * trill * t) * 0.5 * fade
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 30000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	return stream
