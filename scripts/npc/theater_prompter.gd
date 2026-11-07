class_name TheaterPrompter
extends StaticBody3D

## Don Susurro, the prompter (escena-teatro.md, "El lugar"): small and old, in his shell at the stage's edge, standing
## in the pit so only his head shows over the boards. He is the witness (escena-teatro.md, "Las pistas"): E with a honey
## lozenge in hand (HoneyLozenge) and, if the witness is one of the case's clues, he whispers what he saw from his shell
## that night, with the embroidery. With empty hands, a line about the show. A shout near him or the camera's flash
## and he closes the lid of his shell and says nothing more for the whole case. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_susurro.glb")
const LINES := 4
## A shout this close offends him, in meters.
const SHOUT_REACH := 5.0

var case: CrimeSceneCase
## He saw the culprit: the witness is one of the case's clues.
var knows := false
var offended := false
## The lid of his shell, shut when he's offended (the theater makes it).
var lid: Node3D

var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("theater_prompter")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.1
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PROMPTER"


## E on him: with a lozenge in hand, he sucks it and talks; with empty hands, a line about the show.
func use(cop: Cop) -> void:
	var held: Node = cop.get_node("Grabber").held if cop else null
	if held is HoneyLozenge:
		cop.get_node("Grabber").release()
		feed(held as HoneyLozenge)
	elif offended:
		say("PROMPTER_SHELL_CLOSED")
	else:
		say("PROMPTER_LINE_%d" % (_lines_said % LINES))
		_lines_said += 1


## A lozenge: he sucks it, and if he saw the culprit he whispers it, with the embroidery.
func feed(lozenge: HoneyLozenge) -> void:
	if lozenge:
		lozenge.eat()
	if offended:
		say("PROMPTER_SHELL_CLOSED")
	elif knows and case:
		case.found("witness")
		say(tr("PROMPTER_SAW") % tr("EMBROIDERY_" + str(case.culprit().embroidery)), 6.0)
	else:
		say("PROMPTER_NOTHING")


func shouted_by(cop: Cop) -> void:
	if cop and cop.global_position.distance_to(global_position) <= SHOUT_REACH:
		offend()


## The camera's flash in his face.
func photographed(_cop: Cop) -> void:
	offend()


## Offended: the lid of the shell comes down, and not a word more.
func offend() -> void:
	if offended:
		return
	offended = true
	say("PROMPTER_SHELL_CLOSED")
	if lid:
		lid.visible = true
	if knows and case:
		case.ruin("witness")


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
