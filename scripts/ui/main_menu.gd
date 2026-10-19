class_name MainMenu
extends Control

## Placeholder main menu. Every visible text goes through tr() keys in translations/texts.csv.

@onready var _play_button: Button = %PlayButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	# Nothing to play yet: the first case arrives with the first weekly goal.
	_play_button.disabled = true
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_quit_pressed() -> void:
	get_tree().quit()
