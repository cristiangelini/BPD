class_name ChoirSinging
extends Node3D

## The choir's rehearsal (infiltracion-coro.md, step 4, decision 101): Maestro Ernesto leads a song every so often, and
## during it he raises and lowers the baton. Baton up, the whole choir sings; baton down, silence. A cop on the platform
## sings with their voice (the microphone, SongMeter) or holding H. Only the timing counts, not the note (decision
## 101). Each PC judges its own cop once a second: silent with the baton up, or singing with it down (the solo nobody
## asked for), and tells the host (`missed`), where ClubSuspicion makes the choristers who hear it suspicious; off the
## platform during a song, ClubSuspicion sees it itself. The host decides the songs and the baton and tells the
## guests. Every number here is (propuesta).

signal song_started
signal missed(cop: Cop, amount: float)

const FIRST_SONG := 20.0
## Seconds between one song's end and the next one's start, and how long a song lasts.
const BREAK := 30.0
const SONG := 45.0
## Ernesto calls it this long before.
const WARNING := 5.0
## Each stretch with the baton up, and each rest with it down, lasts between these (drawn with the seed).
const PHRASE := Vector2(4.0, 7.0)
const REST := Vector2(2.0, 4.0)
## After the baton moves, this long to catch up before it counts.
const GRACE := 0.6
const JUDGE_EVERY := 1.0
## What each second wrong adds to the choristers who hear it: silent with the baton up, singing with it down.
const SILENT := 15.0
const SOLO := 25.0
const MIX_RATE := 22050

## Seconds to the next song (host) and left of this one (every PC; 0: no song).
var next_left := FIRST_SONG
var song_left := 0.0
var baton_up := false
## Seconds since the baton last moved (every PC).
var since_baton := 0.0
var case_seed := 0
## Whether a world position is on the platform, and inside the chapel (ChurchChoir sets them).
var on_platform: Callable = func(_at: Vector3) -> bool: return false
var inside: Callable = func(_at: Vector3) -> bool: return false
var ernesto: ClubMember
## This PC's cop this song: seconds sung right and wrong.
var good_seconds := 0
var bad_seconds := 0
## Tests and the debug panel can make this PC's cop sing without a microphone or H.
var force_singing := false
var _rng := RandomNumberGenerator.new()
var _baton_left := 0.0
var _judge_left := JUDGE_EVERY
var _warned := false
var _voices: AudioStreamPlayer3D
var _baton_mark: Label3D
var _hud: CanvasLayer
var _cue: Label
var _verdict: Label


func _ready() -> void:
	add_to_group("choir_singing")
	_rng.seed = hash(["choir songs", case_seed])
	_voices = AudioStreamPlayer3D.new()
	_voices.stream = choir_stream()
	_voices.max_distance = 30.0
	_voices.volume_db = -8.0
	add_child(_voices)
	_baton_mark = Label3D.new()
	_baton_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_baton_mark.no_depth_test = true
	_baton_mark.pixel_size = 0.008
	_baton_mark.font_size = 64
	_baton_mark.outline_size = 12
	_baton_mark.hide()
	add_child(_baton_mark)
	_build_hud()


func is_song() -> bool:
	return song_left > 0.0


## Host: a song starts now on every PC, baton up.
func start_song() -> void:
	next_left = BREAK
	_warned = false
	_begin(SONG)
	_move_baton(true)


## Every PC: a song starts, with `left` seconds of it.
func _begin(left: float) -> void:
	song_left = left
	good_seconds = 0
	bad_seconds = 0
	if ernesto:
		ernesto.say("ERNESTO_SONG")
	var cop := VoiceChat.local_cop(get_tree())
	if cop and inside.call(cop.global_position):
		cop.show_hint("HINT_CHOIR_SONG")
	song_started.emit()


## Host: up or down, on every PC.
func _move_baton(up: bool) -> void:
	_baton_left = _rng.randf_range(PHRASE.x, PHRASE.y) if up else _rng.randf_range(REST.x, REST.y)
	_set_baton(up)
	if multiplayer.is_server() and Net.is_online():
		for peer: int in Net.scene_peers:
			_baton.rpc_id(peer, up, song_left)


@rpc("authority", "call_remote", "reliable")
func _baton(up: bool, left: float) -> void:
	if not is_song():
		_begin(left)
	song_left = left
	_set_baton(up)


func _set_baton(up: bool) -> void:
	baton_up = up
	since_baton = 0.0
	if up:
		_voices.play()
	else:
		_voices.stop()


func _process(delta: float) -> void:
	if ernesto:
		_baton_mark.global_position = ernesto.global_position + Vector3.UP * 2.3
	if multiplayer.is_server():
		_lead(delta)
	if is_song():
		song_left = maxf(song_left - delta, 0.0)
		since_baton += delta
		_judge_left -= delta
		if _judge_left <= 0.0:
			_judge_left = JUDGE_EVERY
			judge()
		if not is_song():
			_set_baton(false)
	_refresh_marks()


## Host: counts down to the next song, and moves the baton during one.
func _lead(delta: float) -> void:
	if not is_song():
		next_left -= delta
		if next_left <= WARNING and not _warned:
			_warned = true
			if ernesto:
				ernesto.say("ERNESTO_SONG_SOON")
		if next_left <= 0.0:
			start_song()
		return
	_baton_left -= delta
	if _baton_left <= 0.0 and song_left > GRACE:
		_move_baton(not baton_up)


## Whether this PC's player is singing: the voice going on (SongMeter) or H held.
func is_singing() -> bool:
	if force_singing or Input.is_action_pressed("hum"):
		return true
	return Net.voice != null and Net.voice.song.is_singing(Time.get_ticks_msec() / 1000.0)


## Once a second during a song: this PC's cop on the platform sang when they should, or didn't.
func judge() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not cop or not is_song() or since_baton < GRACE or not on_platform.call(cop.global_position):
		return
	var singing := is_singing()
	if singing == baton_up:
		good_seconds += 1
		_verdict.text = "CHOIR_GOOD"
		return
	bad_seconds += 1
	_verdict.text = "CHOIR_SOLO" if singing else "CHOIR_SILENT"
	var amount := SOLO if singing else SILENT
	if multiplayer.is_server():
		missed.emit(cop, amount)
	else:
		_missed.rpc_id(Net.HOST_ID, amount)


@rpc("any_peer", "call_remote", "reliable")
func _missed(amount: float) -> void:
	var sync: CopSync = Net.cop_syncs.get(multiplayer.get_remote_sender_id())
	if multiplayer.is_server() and sync and is_instance_valid(sync.cop):
		missed.emit(sync.cop, minf(amount, SOLO))


func _refresh_marks() -> void:
	_baton_mark.visible = is_song()
	_baton_mark.text = "▲ ♪" if baton_up else "▼"
	_baton_mark.modulate = Color(1, 0.85, 0.3) if baton_up else Color(0.7, 0.75, 0.85)
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = is_song() and cop != null and inside.call(cop.global_position)
	if not _hud.visible:
		return
	_cue.text = "CHOIR_SING" if baton_up else "CHOIR_QUIET"
	if not on_platform.call(cop.global_position):
		_verdict.text = "CHOIR_GO_TO_PLATFORM"


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


## A held "aah" of the choir while the baton is up: a soft major chord with a slow wobble, one second that loops.
static func choir_stream() -> AudioStreamWAV:
	var samples := MIX_RATE
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / MIX_RATE
		var wobble := 1.0 + 0.004 * sin(TAU * 5.0 * t)
		var value := 0.0
		for note: float in [220.0, 277.0, 330.0, 440.0]:
			value += sin(TAU * note * wobble * t) * 0.16 + sin(TAU * note * 2.0 * t) * 0.04
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 30000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	return stream
