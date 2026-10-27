class_name MainMenu
extends Control

## Placeholder main menu. Every visible text goes through tr() keys in translations/texts.csv.

const CITY_SCENE := "res://scenes/levels/city.tscn"
const BAKERY_SCENE := "res://scenes/levels/bakery.tscn"
const GROOMER_SCENE := "res://scenes/levels/groomer.tscn"
const APARTMENTS_SCENE := "res://scenes/levels/apartment_tower.tscn"
const HARDWARE_SCENE := "res://scenes/levels/hardware_store.tscn"
const FACTORY_SCENE := "res://scenes/levels/doll_factory.tscn"
const INSURANCE_SCENE := "res://scenes/levels/insurance_office.tscn"
const CAKE_LAB_SCENE := "res://scenes/levels/cake_lab.tscn"
const HOTEL_RAID_SCENE := "res://scenes/levels/hotel_raid.tscn"
const GYM_RAID_SCENE := "res://scenes/levels/gym_raid.tscn"
const BOWLING_SCENE := "res://scenes/levels/bowling.tscn"
const TEST_ROOM_SCENE := "res://scenes/levels/grey_room.tscn"
const LOBBY_SCENE := "res://scenes/ui/lobby.tscn"

@onready var _play_button: Button = %PlayButton
@onready var _online_button: Button = %OnlineButton
@onready var _city_button: Button = %CityButton
@onready var _bakery_button: Button = %BakeryButton
@onready var _groomer_button: Button = %GroomerButton
@onready var _hotel_raid_button: Button = %HotelRaidButton
@onready var _test_room_button: Button = %TestRoomButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	# Back at the menu, any room is over: Play is solo, and "Jugar con amigos" opens a fresh room. Play starts a new
	# campaign and Continue picks up the saved one (guardado.md); the test buttons play without one.
	Net.leave()
	Campaign.current = null
	%ContinueButton.visible = Campaign.can_continue()
	%ContinueButton.pressed.connect(_on_continue_pressed)
	# Play draws the case: the grandpa's house, the bakery, the pet salon or the hotel (PlaceDraw). Their buttons stay
	# as shortcuts.
	_play_button.pressed.connect(_on_play_pressed)
	_online_button.pressed.connect(_open_lobby)
	_city_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(CITY_SCENE))
	_bakery_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(BAKERY_SCENE))
	_groomer_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(GROOMER_SCENE))
	%ApartmentsButton.pressed.connect(func() -> void: get_tree().change_scene_to_file(APARTMENTS_SCENE))
	%HardwareButton.pressed.connect(func() -> void: get_tree().change_scene_to_file(HARDWARE_SCENE))
	%FactoryButton.pressed.connect(func() -> void: get_tree().change_scene_to_file(FACTORY_SCENE))
	%InsuranceButton.pressed.connect(func() -> void: get_tree().change_scene_to_file(INSURANCE_SCENE))
	%CakeLabButton.pressed.connect(func() -> void: get_tree().change_scene_to_file(CAKE_LAB_SCENE))
	_hotel_raid_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(HOTEL_RAID_SCENE))
	%GymRaidButton.pressed.connect(func() -> void: get_tree().change_scene_to_file(GYM_RAID_SCENE))
	%BowlingButton.pressed.connect(func() -> void: get_tree().change_scene_to_file(BOWLING_SCENE))
	_test_room_button.pressed.connect(_on_test_room_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	# --host / --join=<ip> (two windows on one PC) go straight to the room, once per run.
	# A Steam invite that launched the game goes there too.
	if Lobby.pending_arg(OS.get_cmdline_user_args()) != "" or Lobby.invite_lobby != 0:
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
