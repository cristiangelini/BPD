class_name MainMenu
extends Control

## Placeholder main menu. Every visible text goes through tr() keys in translations/texts.csv.

const PLAY_SCENE := "res://scenes/levels/grandpa_house.tscn"
const CITY_SCENE := "res://scenes/levels/city.tscn"
const BAKERY_SCENE := "res://scenes/levels/bakery.tscn"
const TEST_ROOM_SCENE := "res://scenes/levels/grey_room.tscn"

@onready var _play_button: Button = %PlayButton
@onready var _city_button: Button = %CityButton
@onready var _bakery_button: Button = %BakeryButton
@onready var _test_room_button: Button = %TestRoomButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	# Until the station and the patrol car exist, Play opens the grandpa's house directly.
	_play_button.pressed.connect(_on_play_pressed)
	_city_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(CITY_SCENE))
	_bakery_button.pressed.connect(func() -> void: get_tree().change_scene_to_file(BAKERY_SCENE))
	_test_room_button.pressed.connect(_on_test_room_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(PLAY_SCENE)


func _on_test_room_pressed() -> void:
	get_tree().change_scene_to_file(TEST_ROOM_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
