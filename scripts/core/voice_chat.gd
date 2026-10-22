class_name VoiceChat
extends Node

## Steam voice (docs/diseno/voz.md): hold V to talk to the cops nearby, hold T to talk to everyone on the radio, or
## leave the voice always open. Each PC sends its compressed voice straight to the others over Steam; whoever hears
## it plays it from the speaker's cop, or everywhere for the radio. Without Steam (playing by IP) there is no voice.
## Child of Net, so its path matches on every PC.

enum Channel { NEAR, RADIO }

## Close voice is heard whole up to this many meters and goes silent at NEAR_SILENT (propuesta).
const NEAR_FULL := 3.0
const NEAR_SILENT := 20.0
## Behind a wall (anything on the world's layer between the ear and the speaker's head) the close voice sounds dull and
## lower (propuesta). In the open it keeps Godot's usual cutoff, which already dulls far voices a little.
const WALL_CUTOFF_HZ := 700.0
const WALL_DB := -8.0
const OPEN_CUTOFF_HZ := 5000.0
const WALL_LAYER := 1
## The radio's bus: thinner (band pass) and a bit crunchy, plus some static mixed into the voice.
const RADIO_BUS := "Radio"
const RADIO_STATIC := 0.04
## Seconds of voice each player can have queued; more than that is dropped instead of piling up delay.
const BUFFER_SECONDS := 0.5
## Where "Voz siempre abierta" is kept on this PC.
const SETTINGS_PATH := "user://ajustes.cfg"
## How often a singing player tells the jailbreak's guard it is still singing.
const SING_EVERY := 0.5

## Where settings are saved (tests point it elsewhere).
static var settings_path := SETTINGS_PATH

## Hear your own voice back, without a room and with the voice open: `godot --path . -- --voice-loopback` tries the
## microphone on one PC.
var loopback := false

## The close voice goes out without holding V.
var always_open := false
## The channel this PC is sending, or -1 while quiet.
var talking := -1
## Steam's voice rate, set once Steam is up.
var mix_rate := 48000
var _net: Node
## "<peer id>:<channel>" -> the player that plays that voice.
var _players := {}
var _label: Label
var _recording := false
## The player's own voice, to tell when they shout at a suspect.
var shout := ShoutMeter.new()
## The player's own voice going on and on, or H held: singing to the jailbreak's guard (NightGuard).
var song := SongMeter.new()
var _sing_left := 0.0


func _init(net: Node) -> void:
	_net = net
	name = "Voice"


func _ready() -> void:
	always_open = load_always_open()
	loopback = OS.get_cmdline_user_args().has("--voice-loopback")
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 22)
	_label.anchor_top = 1.0
	_label.anchor_bottom = 1.0
	_label.offset_left = 24
	_label.offset_top = -56
	_label.visible = false
	layer.add_child(_label)


## Which channel goes out for these keys: the radio wins, then V or the always open voice; -1 is quiet.
static func channel_for(talk_held: bool, radio_held: bool, open: bool) -> int:
	if radio_held:
		return Channel.RADIO
	if talk_held or open:
		return Channel.NEAR
	return -1


static func load_always_open() -> bool:
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		return false
	return bool(config.get_value("voz", "siempre_abierta", false))


func set_always_open(open: bool) -> void:
	always_open = open
	var config := ConfigFile.new()
	config.load(settings_path)
	config.set_value("voz", "siempre_abierta", open)
	config.save(settings_path)


func _process(delta: float) -> void:
	var steam: SteamRoom = _net.steam
	var online: bool = (_net.is_online() or loopback) and steam.available()
	var channel := channel_for(_held("talk"), _held("radio"), always_open or loopback) if online else -1
	_set_talking(channel)
	if _recording:
		_send(steam.steam)
	var camera := get_viewport().get_camera_3d()
	if camera:
		update_walls(camera.global_position)
	_check_singing(delta)


func _held(action: String) -> bool:
	# Typing in a text box (the room's IP) isn't talking.
	if get_viewport().gui_get_focus_owner() is LineEdit:
		return false
	return InputMap.has_action(action) and Input.is_action_pressed(action)


func _set_talking(channel: int) -> void:
	_label.visible = channel >= 0
	_label.text = "VOICE_RADIO" if channel == Channel.RADIO else "VOICE_TALKING"
	if channel == talking:
		return
	talking = channel
	var steam: SteamRoom = _net.steam
	if not steam.available():
		return
	if channel >= 0 and not _recording:
		mix_rate = steam.steam.call("getVoiceOptimalSampleRate")
		steam.steam.call("startVoiceRecording")
		_recording = true
	elif channel < 0 and _recording:
		steam.steam.call("stopVoiceRecording")
		_recording = false


func _send(steam: Object) -> void:
	var voice: Dictionary = steam.call("getVoice")
	var data: PackedByteArray = voice.get("buffer", PackedByteArray())
	var size := int(voice.get("size", data.size()))
	# Steam only has data while it hears speech (VOICE_RESULT_OK, 0).
	if int(voice.get("result", -1)) != 0 or size <= 0:
		return
	data = data.slice(0, size)
	_check_shout(steam, data)
	if loopback:
		_hear(0, maxi(talking, 0), data)
	if _net.is_online():
		_voice.rpc(maxi(talking, 0), data)


## Only in an interrogation (a shout near the suspect is the bad cop's shout), the jailbreak (the guard turns to it) or
## the choir (ChoirSinging listens to the song meter).
func _check_shout(steam: Object, data: PackedByteArray) -> void:
	if not is_inside_tree() or not (get_tree().has_group("interrogation") or get_tree().has_group("night_guard")
			or get_tree().has_group("choir_singing")):
		return
	var voice: Dictionary = steam.call("decompressVoice", data, mix_rate)
	var pcm: PackedByteArray = voice.get("uncompressed", voice.get("buffer", PackedByteArray()))
	pcm = pcm.slice(0, int(voice.get("size", pcm.size())))
	song.feed(pcm, mix_rate, Time.get_ticks_msec() / 1000.0)
	if shout.feed(pcm, mix_rate):
		shouted(local_cop(get_tree()))


## In the jailbreak (and on El Oso's phone at the bank): while the player sings (or hums with H), tells the guard
## (or the phone) every SING_EVERY seconds.
func _check_singing(delta: float) -> void:
	_sing_left -= delta
	if _sing_left > 0.0 or not is_inside_tree() \
			or not (get_tree().has_group("night_guard") or get_tree().has_group("bank_phone")):
		return
	if not (_held("hum") or song.is_singing(Time.get_ticks_msec() / 1000.0)):
		return
	_sing_left = SING_EVERY
	sang(local_cop(get_tree()))


## The player's cop is singing: the guard, on the host, hears it.
func sang(cop: Cop) -> void:
	if not cop:
		return
	if _net.is_host():
		get_tree().call_group("night_guard", "heard_singing", cop)
		get_tree().call_group("bank_phone", "heard_singing", cop)
	else:
		_guard_heard_singing.rpc_id(_net.HOST_ID)


@rpc("any_peer", "call_remote", "reliable")
func _guard_heard_singing() -> void:
	var sync: CopSync = _net.cop_syncs.get(multiplayer.get_remote_sender_id())
	if multiplayer.is_server() and sync and is_instance_valid(sync.cop):
		get_tree().call_group("night_guard", "heard_singing", sync.cop)
		get_tree().call_group("bank_phone", "heard_singing", sync.cop)


## Tells the interrogation, the crime scene, the jailbreak's guard or the club's grandparents that the player's cop
## shouted.
func shouted(cop: Cop) -> void:
	if cop:
		get_tree().call_group("interrogation", "shouted_by", cop)
		get_tree().call_group("crime_scene", "shouted_by", cop)
		if not get_tree().has_group("night_guard") and not get_tree().has_group("club_suspicion"):
			return
		# The jailbreak's guard and the club's grandparents live on the host.
		if _net.is_host():
			_host_heard_shout(cop)
		else:
			_guard_heard_shout.rpc_id(_net.HOST_ID)


@rpc("any_peer", "call_remote", "reliable")
func _guard_heard_shout() -> void:
	var sync: CopSync = _net.cop_syncs.get(multiplayer.get_remote_sender_id())
	if multiplayer.is_server() and sync and is_instance_valid(sync.cop):
		_host_heard_shout(sync.cop)


func _host_heard_shout(cop: Cop) -> void:
	get_tree().call_group("night_guard", "shouted_by", cop)
	get_tree().call_group("club_suspicion", "shouted_by", cop)


## The cop this PC's player moves.
static func local_cop(tree: SceneTree) -> Cop:
	for cop: Node in tree.get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			return cop
	return null


@rpc("any_peer", "call_remote", "unreliable_ordered")
func _voice(channel: int, data: PackedByteArray) -> void:
	_hear(multiplayer.get_remote_sender_id(), channel, data)


func _hear(id: int, channel: int, data: PackedByteArray) -> void:
	var steam: SteamRoom = _net.steam
	if not steam.available():
		return
	var voice: Dictionary = steam.steam.call("decompressVoice", data, mix_rate)
	var pcm: PackedByteArray = voice.get("uncompressed", voice.get("buffer", PackedByteArray()))
	play_pcm(id, channel, pcm.slice(0, int(voice.get("size", pcm.size()))))


## Plays a player's voice (16 bit mono samples at mix_rate) on the channel it was sent on.
func play_pcm(id: int, channel: int, pcm: PackedByteArray) -> void:
	var playback := _player(id, channel).get_stream_playback() as AudioStreamGeneratorPlayback
	if not playback:
		return
	var frames := PackedVector2Array()
	var count := mini(pcm.size() / 2, playback.get_frames_available())
	frames.resize(count)
	for i in count:
		var sample := pcm.decode_s16(i * 2) / 32768.0
		if channel == Channel.RADIO:
			sample = clampf(sample + randf_range(-RADIO_STATIC, RADIO_STATIC), -1.0, 1.0)
		frames[i] = Vector2(sample, sample)
	playback.push_buffer(frames)


## The player for a peer's voice on a channel: on its cop's head for the close voice, flat for the radio or when
## there are no cops (the room).
func _player(id: int, channel: int) -> Node:
	var key := "%d:%d" % [id, channel]
	var cop := _cop_of(id)
	var existing: Node = _players.get(key)
	var near := channel == Channel.NEAR and cop != null
	if is_instance_valid(existing) and (existing is AudioStreamPlayer3D) == near:
		return existing
	if is_instance_valid(existing):
		existing.queue_free()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = mix_rate
	stream.buffer_length = BUFFER_SECONDS
	var player: Node
	if near:
		var spatial := AudioStreamPlayer3D.new()
		spatial.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		spatial.unit_size = NEAR_FULL
		spatial.max_distance = NEAR_SILENT
		spatial.stream = stream
		player = spatial
		cop.get_node("Head").add_child(player)
	else:
		var flat := AudioStreamPlayer.new()
		flat.stream = stream
		if channel == Channel.RADIO:
			flat.bus = radio_bus()
		player = flat
		add_child(player)
	player.name = "Voice%d_%d" % [id, channel]
	player.call("play")
	_players[key] = player
	return player


## Dulls every close voice with a wall between it and `ear`.
func update_walls(ear: Vector3) -> void:
	for player: Node in _players.values():
		if is_instance_valid(player) and player is AudioStreamPlayer3D and player.is_inside_tree():
			set_muffled(player, behind_wall(player, ear))


static func behind_wall(player: Node3D, ear: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(ear, player.global_position, WALL_LAYER)
	return not player.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


static func set_muffled(player: AudioStreamPlayer3D, muffled: bool) -> void:
	player.attenuation_filter_cutoff_hz = WALL_CUTOFF_HZ if muffled else OPEN_CUTOFF_HZ
	player.volume_db = WALL_DB if muffled else 0.0


func _cop_of(id: int) -> Node3D:
	var sync: Node = _net.cop_syncs.get(id)
	return sync.cop if sync and is_instance_valid(sync.cop) else null


## The radio's bus, made the first time it's needed.
static func radio_bus() -> String:
	if AudioServer.get_bus_index(RADIO_BUS) >= 0:
		return RADIO_BUS
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, RADIO_BUS)
	var band := AudioEffectBandPassFilter.new()
	band.cutoff_hz = 1600.0
	AudioServer.add_bus_effect(index, band)
	var crunch := AudioEffectDistortion.new()
	crunch.mode = AudioEffectDistortion.MODE_LOFI
	crunch.drive = 0.3
	AudioServer.add_bus_effect(index, crunch)
	return RADIO_BUS
