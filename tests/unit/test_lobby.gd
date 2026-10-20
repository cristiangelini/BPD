extends GutTest

## The room screen (docs/diseno/online.md, "La sala").

const LOBBY_SCENE := preload("res://scenes/ui/lobby.tscn")
const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")


func after_each() -> void:
	Net.leave()


func test_menu_opens_the_room() -> void:
	var menu: Control = add_child_autofree(MENU_SCENE.instantiate())
	assert_eq(menu.get_node("%OnlineButton").text, "MENU_ONLINE")
	assert_true(ResourceLoader.exists(MainMenu.LOBBY_SCENE))


func test_solo_room_hides_start() -> void:
	var lobby: Control = add_child_autofree(LOBBY_SCENE.instantiate())
	assert_false(lobby.get_node("%StartButton").visible, "only a host in a room starts the case")
	assert_eq(lobby.get_node("%Status").text, "LOBBY_SOLO")
	assert_eq(lobby.get_node("%Players").get_child_count(), 0)


func test_hosting_lists_the_host_and_shows_start() -> void:
	var lobby: Control = add_child_autofree(LOBBY_SCENE.instantiate())
	lobby.get_node("%HostButton").pressed.emit()
	if not Net.is_online():
		pending("port %d is busy on this machine" % Net.DEFAULT_PORT)
		return
	await wait_process_frames(2)
	assert_true(lobby.get_node("%StartButton").visible)
	assert_true(lobby.get_node("%HostButton").disabled)
	assert_eq(lobby.get_node("%Players").get_child_count(), 1, "the host is cop 1")


func test_command_line_opens_the_room() -> void:
	assert_eq(Lobby.room_arg(PackedStringArray(["--host"])), "host")
	assert_eq(Lobby.room_arg(PackedStringArray(["--join=192.168.0.7"])), "192.168.0.7")
	assert_eq(Lobby.room_arg(PackedStringArray(["--place=bakery"])), "")


func test_command_line_opens_the_room_only_once() -> void:
	add_child_autofree(LOBBY_SCENE.instantiate())
	assert_eq(Lobby.pending_arg(PackedStringArray(["--host"])), "", "coming back to the menu doesn't host again")


func test_each_slot_has_its_skin_color() -> void:
	assert_eq(Lobby.SKIN_COLORS.size(), Net.MAX_PLAYERS)
