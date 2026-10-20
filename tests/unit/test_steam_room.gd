extends GutTest

## Steam rooms (docs/diseno/online.md, "Cómo se conectan"). CI has no Steam, so these check the parts that don't
## need it; the room itself is tried on a PC with Steam open (online.md, "Probar con Steam").

const LOBBY_SCENE := preload("res://scenes/ui/lobby.tscn")


func after_each() -> void:
	Lobby.invite_lobby = 0
	Net.change_scenes = true
	Net.leave()


func test_invite_launch_argument() -> void:
	assert_eq(SteamRoom.connect_lobby_arg(PackedStringArray(["+connect_lobby", "109775241021923456"])),
		109775241021923456)
	assert_eq(SteamRoom.connect_lobby_arg(PackedStringArray(["--host"])), 0)
	assert_eq(SteamRoom.connect_lobby_arg(PackedStringArray(["+connect_lobby"])), 0, "no id after it")


func test_spacewar_until_bpd_has_its_app_id() -> void:
	assert_eq(SteamRoom.APP_ID, 480)


func test_without_steam_the_room_offers_ip_only() -> void:
	if Net.steam.available():
		pending("Steam is running on this PC")
		return
	var lobby: Control = add_child_autofree(LOBBY_SCENE.instantiate())
	assert_false(lobby.get_node("%SteamButton").visible)
	assert_false(lobby.get_node("%InviteButton").visible)
	assert_true(lobby.get_node("%HostButton").visible)


func test_a_lobby_steam_refuses_ends_the_room() -> void:
	var room := SteamRoom.new()
	add_child_autofree(room)
	watch_signals(room)
	room._on_lobby_created(2, 0)
	assert_signal_emitted_with_parameters(room, "failed", ["NET_HOST_FAILED"])
	room._on_lobby_joined(5, 0, false, 4)
	assert_signal_emitted_with_parameters(room, "failed", ["NET_JOIN_FAILED"])
	assert_eq(room.lobby_id, 0)


func test_failing_steam_tells_the_room() -> void:
	watch_signals(Net)
	Net.steam.failed.emit("NET_JOIN_FAILED")
	assert_signal_emitted_with_parameters(Net, "session_ended", ["NET_JOIN_FAILED"])
	assert_false(Net.is_online())


func test_accepting_an_invite_joins_from_the_room() -> void:
	Net.change_scenes = false
	Net.steam.invited.emit(42)
	assert_eq(Lobby.invite_lobby, 42, "the room joins it when it opens")
	if Net.steam.available():
		pending("Steam is running on this PC")
		return
	var lobby: Control = add_child_autofree(LOBBY_SCENE.instantiate())
	assert_eq(Lobby.invite_lobby, 0, "joined once")
	assert_eq(lobby.get_node("%Status").text, "LOBBY_JOINING")
	await wait_process_frames(2)
	assert_eq(lobby.get_node("%Status").text, "NET_JOIN_FAILED", "no Steam here, so it can't get in")
