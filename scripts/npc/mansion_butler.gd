class_name MansionButler
extends MansionPerson

## Ceferino, the mansion's butler (escena-mansion.md, "La gente"): tailcoat, white gloves and his tray, by the bell
## board in the pantry. Whatever you ask him, it was him, señor (it never is). He's not on the board.

const MODEL := preload("res://assets/models/npc_mayordomo.glb")


func _init() -> void:
	model = MODEL
	prompt = "PROMPT_MANSION_BUTLER"
	line_key = "BUTLER_LINE_"
	lines = 3


func _ready() -> void:
	super()
	add_to_group("mansion_butler")
