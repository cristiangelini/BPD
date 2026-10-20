class_name Lobby
extends Control

## The room before a case (docs/diseno/online.md, "La sala"): create a room or join a friend's, see who is in with
## their color, and the host starts the case for everyone. With Steam running, the room is a Steam lobby and friends
## come in by Steam invite; by IP stays for testing on one PC.
## `godot --path . -- --host` or `-- --join=<ip>` opens it straight away, for two windows on one PC.

const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## Skin color of each slot, as the cop models (tools/modelgen/models/pear.js, decision 72).
const SKIN_COLORS: Array[Color] = [Color("ff86b0"), Color("ff9d3f"), Color("9ee05c"), Color("ac8cff")]

## The --host / --join arguments open the room only once per run, not every time the menu comes back.
static var _args_used := false
## A friend's Steam lobby to join as soon as the room opens (an invite accepted in Steam, or +connect_lobby), 0 if none.
static var invite_lobby := 0

@onready var _status: Label = %Status
@onready var _players: VBoxContainer = %Players
@onready var _address: LineEdit = %Address
@onready var _host_button: Button = %HostButton
@onready var _join_button: Button = %JoinButton
@onready var _start_button: Button = %StartButton


## The --host / --join=<ip> argument among `args`: "host", the IP, or "".
static func room_arg(args: PackedStringArray) -> String:
	for arg in args:
		if arg == "--host":
			return "host"
		if arg.begins_with("--join="):
			return arg.trim_prefix("--join=")
	return ""


## room_arg() of this run's arguments, if no room screen has used it yet.
static func pending_arg(args: PackedStringArray) -> String:
	return "" if _args_used else room_arg(args)


func _ready() -> void:
	_host_button.pressed.connect(_on_host_pressed)
	%SteamButton.pressed.connect(_on_steam_pressed)
	%InviteButton.pressed.connect(func() -> void: Net.steam.invite())
	_join_button.pressed.connect(func() -> void: _join(_address.text.strip_edges()))
	# Start case begins a new campaign; Continue picks up the host's saved one (guardado.md).
	_start_button.pressed.connect(func() -> void:
		Campaign.start_new()
		Net.start_match())
	%ContinueButton.pressed.connect(func() -> void:
		Campaign.current = Campaign.load_saved()
		Net.start_match())
	%BackButton.pressed.connect(_on_back_pressed)
	Net.players_changed.connect(_refresh)
	Net.session_ended.connect(_on_session_ended)
	Net.in_match = false
	_refresh()
	var arg := pending_arg(OS.get_cmdline_user_args())
	_args_used = true
	if invite_lobby != 0:
		var lobby_id := invite_lobby
		invite_lobby = 0
		Net.join_steam(lobby_id)
		_show_joining()
	elif arg == "host":
		_on_host_pressed()
	elif arg != "":
		_join(arg)


func _on_host_pressed() -> void:
	if Net.host() != OK:
		_status.text = "NET_HOST_FAILED"
		return
	_refresh()


func _on_steam_pressed() -> void:
	Net.host_steam()
	_status.text = "LOBBY_OPENING"
	%SteamButton.disabled = true


func _join(address: String) -> void:
	if address == "":
		address = "127.0.0.1"
	if Net.join(address) != OK:
		_status.text = "NET_JOIN_FAILED"
		return
	_show_joining()


func _show_joining() -> void:
	_status.text = "LOBBY_JOINING"
	_host_button.disabled = true
	_join_button.disabled = true
	%SteamButton.disabled = true


func _on_back_pressed() -> void:
	Net.leave()
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_session_ended(reason_key: String) -> void:
	_refresh()
	_status.text = reason_key


func _refresh() -> void:
	var online := Net.is_online() and not Net.players.is_empty()
	_host_button.disabled = online
	_join_button.disabled = online
	%SteamButton.visible = Net.steam.available()
	%SteamButton.disabled = online
	%InviteButton.visible = online and Net.is_steam() and Net.is_host()
	_address.editable = not online
	_start_button.visible = online and Net.is_host()
	%ContinueButton.visible = _start_button.visible and Campaign.can_continue()
	if not online:
		_status.text = "LOBBY_SOLO"
	elif Net.is_host() and Net.is_steam():
		_status.text = "LOBBY_HOSTING_STEAM"
	elif Net.is_host():
		_status.text = tr("LOBBY_HOSTING") % _local_ip()
	else:
		_status.text = "LOBBY_WAITING"
	for child in _players.get_children():
		child.queue_free()
	var ids: Array = Net.players.keys()
	ids.sort_custom(func(a: int, b: int) -> bool: return Net.players[a] < Net.players[b])
	for id: int in ids:
		_players.add_child(_player_row(id, Net.players[id]))


## One line of the list: the skin color and "Policía N", tagged as host and as you.
func _player_row(id: int, slot: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(32, 32)
	swatch.color = SKIN_COLORS[slot % SKIN_COLORS.size()]
	row.add_child(swatch)
	var label := Label.new()
	var text := tr("COP_NAME") % (slot + 1)
	if id == Net.HOST_ID:
		text += " · " + tr("LOBBY_HOST_TAG")
	if id == multiplayer.get_unique_id():
		text += " " + tr("LOBBY_YOU")
	label.text = text
	label.add_theme_font_size_override("font_size", 26)
	row.add_child(label)
	return row


## The first LAN address to share with friends (they can't use 127.0.0.1 from another PC).
func _local_ip() -> String:
	for address in IP.get_local_addresses():
		if address.count(".") == 3 and not address.begins_with("127.") and not address.begins_with("169.254."):
			return address
	return "127.0.0.1"
