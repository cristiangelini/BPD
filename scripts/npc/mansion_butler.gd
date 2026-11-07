class_name MansionButler
extends MansionPerson

## Ceferino, the mansion's butler (escena-mansion.md, "La gente"): tailcoat, white gloves and his tray, by the bell
## board in the pantry. Whatever you ask him, it was him, señor (it never is). He's not on the board. Once he has
## confessed, ask him again and he tells which bell rang at midnight (the bells clue, if it's one of the case's), unless
## someone pulled a cord and mixed up the board's flags.

const MODEL := preload("res://assets/models/npc_mayordomo.glb")

var case: CrimeSceneCase
## The bells are one of the case's clues; the room whose bell rang (the culprit's at midnight).
var knows := false
var bell_room := ""
## Someone pulled a bell cord: the flags are mixed up.
var mixed := false


func _init() -> void:
	model = MODEL
	prompt = "PROMPT_MANSION_BUTLER"
	line_key = "BUTLER_LINE_"
	lines = 3


func _ready() -> void:
	super()
	add_to_group("mansion_butler")


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_BUTLER_BELLS" if case and _lines_said > 0 else prompt


## First he confesses; with the case on, after that he tells the bells.
func use(_cop: Cop) -> void:
	if not case or _lines_said == 0:
		say_next()
	else:
		tell_bells()


func tell_bells() -> void:
	if mixed:
		say("BUTLER_BELLS_MIXED", 5.0)
	elif knows:
		case.found("bells")
		say(tr("BUTLER_BELLS") % tr("MANSION_ROOM_" + bell_room), 5.0)
	else:
		say("BUTLER_BELLS_ALL", 5.0)
