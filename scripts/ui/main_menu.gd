class_name MainMenu
extends Control

## Placeholder main menu. Every visible text goes through tr() keys in translations/texts.csv.

const PLAY_SCENE := "res://scenes/levels/grey_room.tscn"

@onready var _play_button: Button = %PlayButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	# Until the first case exists, Play opens the grey test room.
	_play_button.pressed.connect(_on_play_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(PLAY_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
