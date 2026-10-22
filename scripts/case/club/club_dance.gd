class_name ClubDance
extends Node3D

## The club's waltz (infiltracion.md, step 5): every DANCE_EVERY seconds a waltz plays for WALTZ seconds, and the cops
## have to go to the dance floor and dance like everyone else: H on the first beat of each bar (UN-dos-tres), with or
## without a partner. Each PC judges its own cop's steps and tells the host about the bad ones (`stumbled`); the host
## decides when the waltz plays and tells the guests, and ClubSuspicion makes a cop sitting it out, or stepping on
## feet, look suspicious. Every number here is (propuesta).

signal started
signal stumbled(cop: Cop)

const FIRST_WALTZ := 120.0
const DANCE_EVERY := 180.0
const WALTZ := 30.0
## Doña Chela calls it this long before.
const WARNING := 10.0
## The waltz's beat (90 a minute, three to a bar) and how close to the first beat H has to be.
const BEAT := 60.0 / 90.0
const WINDOW := 0.22
const MIX_RATE := 22050

## Seconds to the next waltz (host) and seconds left of this one (every PC; 0: no waltz).
var next_left := FIRST_WALTZ
var waltz_left := 0.0
## Whether a world position is on the dance floor, and inside the club (GrandpaClub sets them).
var on_floor: Callable = func(_at: Vector3) -> bool: return false
var inside: Callable = func(_at: Vector3) -> bool: return false
var chela: ClubMember
## This PC's cop this waltz: bars danced well and badly.
var good_bars := 0
var bad_bars := 0
var _bar := -1
var _stepped := false
var _warned := false
var _music: AudioStreamPlayer3D
var _hud: CanvasLayer
var _beats: Label
var _verdict: Label


func _ready() -> void:
	add_to_group("club_dance")
	_music = AudioStreamPlayer3D.new()
	_music.stream = waltz_stream()
	_music.max_distance = 35.0
	_music.volume_db = -6.0
	add_child(_music)
	_build_hud()


func is_waltz() -> bool:
	return waltz_left > 0.0


## Seconds since the waltz started.
func elapsed() -> float:
	return WALTZ - waltz_left


## Host: the waltz starts now on every PC.
func start_waltz() -> void:
	_begin()
	if multiplayer.is_server() and Net.is_online():
		for peer: int in Net.scene_peers:
			_begun.rpc_id(peer)


@rpc("authority", "call_remote", "reliable")
func _begun() -> void:
	_begin()


func _begin() -> void:
	waltz_left = WALTZ
	next_left = DANCE_EVERY
	good_bars = 0
	bad_bars = 0
	_bar = -1
	_stepped = false
	_warned = false
	_music.play()
	if chela:
		chela.say("CHELA_WALTZ")
	var cop := VoiceChat.local_cop(get_tree())
	if cop and inside.call(cop.global_position):
		cop.show_hint("HINT_WALTZ")
	started.emit()


func _process(delta: float) -> void:
	if multiplayer.is_server() and not is_waltz():
		next_left -= delta
		if next_left <= WARNING and not _warned:
			_warned = true
			if chela:
				chela.say("CHELA_WALTZ_SOON")
		if next_left <= 0.0:
			start_waltz()
	if is_waltz():
		_dance(delta)
	_refresh_hud()


## This PC's cop: a bar ends with a step on its first beat, or it was a bad one.
func _dance(delta: float) -> void:
	waltz_left = maxf(waltz_left - delta, 0.0)
	var bar := int(elapsed() / (BEAT * 3))
	if bar != _bar:
		if _bar >= 0:
			_end_bar(_stepped)
		_bar = bar
		_stepped = false
	if not is_waltz():
		_music.stop()


func _end_bar(stepped: bool) -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not cop or not on_floor.call(cop.global_position):
		return
	if stepped:
		good_bars += 1
		_verdict.text = "DANCE_GOOD"
	else:
		_stumble(cop)


## This PC's player pressed H: on the first beat it's a step, anywhere else a step on someone's feet.
func step() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	if not is_waltz() or not cop or not on_floor.call(cop.global_position):
		return
	var into_bar := fmod(elapsed(), BEAT * 3)
	var off := minf(into_bar, BEAT * 3 - into_bar)
	if off <= WINDOW:
		_stepped = true
	else:
		_stumble(cop)


func _stumble(cop: Cop) -> void:
	bad_bars += 1
	_verdict.text = "DANCE_BAD"
	if multiplayer.is_server():
		stumbled.emit(cop)
	else:
		_stumbled.rpc_id(Net.HOST_ID)


@rpc("any_peer", "call_remote", "reliable")
func _stumbled() -> void:
	var sync: CopSync = Net.cop_syncs.get(multiplayer.get_remote_sender_id())
	if multiplayer.is_server() and sync and is_instance_valid(sync.cop):
		stumbled.emit(sync.cop)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dance") and is_waltz():
		step()


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-160, 120)
	box.custom_minimum_size = Vector2(320, 0)
	_beats = Label.new()
	_beats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_beats.add_theme_font_size_override("font_size", 40)
	box.add_child(_beats)
	_verdict = Label.new()
	_verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verdict.add_theme_font_size_override("font_size", 24)
	box.add_child(_verdict)
	_hud.add_child(box)
	_hud.hide()
	add_child(_hud)


## UN-dos-tres, with the beat that's sounding in capitals.
func _refresh_hud() -> void:
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = is_waltz() and cop != null and inside.call(cop.global_position)
	if not _hud.visible:
		return
	var beat := int(elapsed() / BEAT) % 3
	var words := [tr("DANCE_BEAT_1"), tr("DANCE_BEAT_2"), tr("DANCE_BEAT_3")]
	for i in 3:
		words[i] = "[ %s ]" % words[i].to_upper() if i == beat else words[i]
	_beats.text = " ".join(words)
	if not on_floor.call(cop.global_position):
		_verdict.text = "DANCE_GO_TO_FLOOR"


## An oom-pah-pah to waltz to: a low note on the first beat and a chord on the other two, one bar that loops.
static func waltz_stream() -> AudioStreamWAV:
	var samples := int(BEAT * 3 * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / MIX_RATE
		var beat := int(t / BEAT)
		var since := t - beat * BEAT
		var fade := exp(-since * 5.0)
		var value := 0.0
		if beat == 0:
			value = sin(TAU * 110.0 * t) * 0.6
		else:
			value = (sin(TAU * 277.0 * t) + sin(TAU * 330.0 * t) + sin(TAU * 440.0 * t)) * 0.18
		data.encode_s16(i * 2, int(clampf(value * fade, -1.0, 1.0) * 32000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	return stream
