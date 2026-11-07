class_name ZooParrot
extends StaticBody3D

## Don Pico, the zoo's parrot (escena-zoo.md, "El lugar"), on his perch by the keepers' hut. He repeats what he hears,
## a different line each time he is asked. He is the witness: given peanuts (E with the ostrich's bucket in hand), if
## he saw it he repeats that morning, with the culprit's smell. A camera's flash in his face and he only says
## "¡Flash!" from then on: the witness is lost. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_pico.glb")
const LINES := 4

var case: CrimeSceneCase
## He saw who took Copito (the witness is one of the case's clues).
var knows := false
var offended := false
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("zoo_parrot")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = 0.25
	shape.shape = ball
	shape.position.y = 0.25
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 0.8
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	return "PROMPT_ZOO_PARROT_FEED" if cop and _seeds(cop) else "PROMPT_ZOO_PARROT"


func use(cop: Cop) -> void:
	if offended:
		say("PARROT_FLASH")
	elif cop and _seeds(cop):
		feed()
	else:
		say("PARROT_LINE_%d" % (_lines_said % LINES))
		_lines_said += 1


## Peanuts: what he heard that morning, if he saw it.
func feed() -> void:
	if offended:
		say("PARROT_FLASH")
	elif knows and case:
		case.found("witness")
		var smell := tr("SMELL_" + str(case.culprit().smell)).to_upper()
		say(tr("PARROT_SAW") % [smell, smell], 6.0)
	else:
		say("PARROT_SAW_NOTHING")


## The camera's flash: he learns the word and says nothing else.
func photographed(_cop: Cop) -> void:
	offended = true
	say("PARROT_FLASH")
	if knows and case:
		case.ruin("witness")


func _seeds(cop: Cop) -> bool:
	var held: Node = cop.get_node("Grabber").held
	return held is FoodBucket and (held as FoodBucket).food == "peanuts"


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
