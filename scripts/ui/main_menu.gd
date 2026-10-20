class_name MainMenu
extends Control

## Placeholder main menu. Every visible text goes through tr() keys in translations/texts.csv.

const CITY_SCENE := "res://scenes/levels/city.tscn"
const BAKERY_SCENE := "res://scenes/levels/bakery.tscn"
const TEST_ROOM_SCENE := "res://scenes/levels/grey_room.tscn"
const LOBBY_SCENE := "res://scenes/ui/lobby.tscn"

@onready var _play_button: Button = %PlayButton
@onready var _online_button: Button = %OnlineButton
@onready var _city_button: Button = %CityButton
@onready var _bakery_button: Button = %BakeryButton
@onready var _test_room_button: Button = %TestRoomButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	# Back at the menu, any room is over: Play is solo, and "Jugar con amigos" opens a fresh room. Play starts a new
	# campaign and Continue picks up the saved one (guardado.md); the test buttons play without one.
	Net.leave()
	Campaign.current = null
	%ContinueButton.visible = Campaign.can_continue()
	%ContinueButton.pressed.connect(_on_continue_pressed)
	# Play draws the case: the grandpa's house or the bakery (PlaceDraw). The bakery button stays as a shortcut.
	_play_button.pressed.connect(_on_play_pressed)
	_online_button.pressed.connect(_open_lobby)
	_city_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(CITY_SCENE))
	_bakery_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(BAKERY_SCENE))
	_test_room_button.pressed.connect(_on_test_room_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	# --host / --join=<ip> (two windows on one PC) go straight to the room, once per run.
	if Lobby.pending_arg(OS.get_cmdline_user_args()) != "":
		_open_lobby.call_deferred()


func _open_lobby() -> void:
	get_tree().change_scene_to_file(LOBBY_SCENE)


func _on_play_pressed() -> void:
	Campaign.start_new()
	PlaceDraw.start(get_tree())


func _on_continue_pressed() -> void:
	Campaign.current = Campaign.load_saved()
	PlaceDraw.start(get_tree())


func _on_test_room_pressed() -> void:
	get_tree().change_scene_to_file(TEST_ROOM_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
