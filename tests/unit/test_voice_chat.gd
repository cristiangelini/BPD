extends GutTest

## Steam voice (docs/diseno/voz.md). CI has no Steam or microphone, so these feed voice straight into play_pcm.

const PCS := preload("res://tests/unit/online_pcs.gd")
const TEST_SETTINGS := "user://test_ajustes.cfg"

var pcs: PCS


func before_each() -> void:
	VoiceChat.settings_path = TEST_SETTINGS
	DirAccess.remove_absolute(TEST_SETTINGS)
	pcs = PCS.new(self)


func after_each() -> void:
	pcs.free_all()
	Net.voice.always_open = false
	DirAccess.remove_absolute(TEST_SETTINGS)
	VoiceChat.settings_path = VoiceChat.SETTINGS_PATH
	await wait_process_frames(2)


## A short tone as Steam hands it over: 16 bit mono samples.
func _tone(samples := 480) -> PackedByteArray:
	var pcm := PackedByteArray()
	pcm.resize(samples * 2)
	for i in samples:
		pcm.encode_s16(i * 2, int(sin(i * 0.2) * 12000))
	return pcm


func test_v_talks_near_t_talks_on_the_radio() -> void:
	assert_eq(VoiceChat.channel_for(false, false, false), -1, "quiet")
	assert_eq(VoiceChat.channel_for(true, false, false), VoiceChat.Channel.NEAR)
	assert_eq(VoiceChat.channel_for(false, true, false), VoiceChat.Channel.RADIO)
	assert_eq(VoiceChat.channel_for(true, true, false), VoiceChat.Channel.RADIO, "the radio wins")
	assert_eq(VoiceChat.channel_for(false, false, true), VoiceChat.Channel.NEAR, "always open")


func test_always_open_is_saved_on_this_pc() -> void:
	assert_false(VoiceChat.load_always_open(), "off by default")
	Net.voice.set_always_open(true)
	assert_true(VoiceChat.load_always_open())
	Net.voice.set_always_open(false)
	assert_false(VoiceChat.load_always_open())


func test_the_room_has_the_always_open_box() -> void:
	var lobby: Control = add_child_autofree(load("res://scenes/ui/lobby.tscn").instantiate())
	var box: CheckBox = lobby.get_node("%VoiceOpen")
	assert_eq(box.text, "LOBBY_VOICE_OPEN")
	box.button_pressed = true
	assert_true(Net.voice.always_open)
	assert_true(VoiceChat.load_always_open())
	box.button_pressed = false


func test_close_voice_comes_out_of_the_speakers_cop() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest_id: int = pair[1].multiplayer.get_unique_id()
	var voice: VoiceChat = host.voice
	voice.play_pcm(guest_id, VoiceChat.Channel.NEAR, _tone())
	var cop: Node3D = host.cop_syncs[guest_id].cop
	var player := cop.get_node("Head").get_node_or_null("Voice%d_0" % guest_id) as AudioStreamPlayer3D
	assert_not_null(player, "the voice plays from the guest's cop")
	assert_eq(player.unit_size, VoiceChat.NEAR_FULL)
	assert_eq(player.max_distance, VoiceChat.NEAR_SILENT, "silent beyond 20 m")
	assert_true(player.playing)


func test_the_radio_sounds_everywhere_with_interference() -> void:
	var pair: Array[Node] = await pcs.two_pcs()
	var host: Node = pair[0]
	var guest_id: int = pair[1].multiplayer.get_unique_id()
	var voice: VoiceChat = host.voice
	voice.play_pcm(guest_id, VoiceChat.Channel.RADIO, _tone())
	var player := voice.get_node_or_null("Voice%d_1" % guest_id) as AudioStreamPlayer
	assert_not_null(player, "flat, not on the cop")
	assert_eq(player.bus, VoiceChat.RADIO_BUS)
	var bus := AudioServer.get_bus_index(VoiceChat.RADIO_BUS)
	assert_true(AudioServer.get_bus_effect(bus, 0) is AudioEffectBandPassFilter, "thinner, like a radio")


func test_in_the_room_voice_is_flat() -> void:
	var voice: VoiceChat = Net.voice
	voice.play_pcm(7, VoiceChat.Channel.NEAR, _tone())
	assert_not_null(voice.get_node_or_null("Voice7_0") as AudioStreamPlayer, "no cops in the room")


func test_solo_nobody_talks() -> void:
	await wait_process_frames(2)
	assert_eq(Net.voice.talking, -1)
	assert_false(Net.voice._label.visible)
