class_name PostParrot
extends StaticBody3D

## Cartita, the parrot of window 2 (escena-correo.md, "Las pistas"): green with a yellow head, on its perch on the
## counter. It repeats what it hears, and it's the witness: E with one of its cookies in hand (ParrotCookie) and, if the
## witness is one of the case's clues, it shouts what the culprit shouted that night, with their route. With empty
## hands, something it heard at the counter. A shout near it or the camera's flash scares it: it hides its head under
## its wing and says nothing more for the whole case. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_loro.glb")
const LINES := 3
## A shout this close scares it, in meters.
const SHOUT_REACH := 5.0

var case: CrimeSceneCase
## It heard the culprit: the witness is one of the case's clues.
var knows := false
var offended := false

var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("post_parrot")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.35, 0.65, 0.35)
	shape.shape = box
	shape.position.y = 0.33
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.0
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PARROT"


## E on it: with a cookie in hand, it eats it and talks; with empty hands, a line from the counter.
func use(cop: Cop) -> void:
	var held: Node = cop.get_node("Grabber").held if cop else null
	if held is ParrotCookie:
		cop.get_node("Grabber").release()
		feed(held as ParrotCookie)
	elif offended:
		say("PARROT_OFFENDED")
	else:
		say("PARROT_LINE_%d" % (_lines_said % LINES))
		_lines_said += 1


## A cookie: it eats it, and if it heard the culprit it shouts what they shouted, with their route.
func feed(cookie: ParrotCookie) -> void:
	if cookie:
		cookie.eat()
	if offended:
		say("PARROT_OFFENDED")
	elif knows and case:
		case.found("witness")
		say("PARROT_SAW_" + str(case.culprit().route), 6.0)
	else:
		say("PARROT_NOTHING")


func shouted_by(cop: Cop) -> void:
	if cop and cop.global_position.distance_to(global_position) <= SHOUT_REACH:
		offend()


## The camera's flash in its face.
func photographed(_cop: Cop) -> void:
	offend()


## Scared: head under the wing, and not a word more.
func offend() -> void:
	if offended:
		return
	offended = true
	say("PARROT_OFFENDED")
	# The parts turn about its feet, so they move instead: the head ducks and the left wing comes up over it.
	var head := part("head")
	if head:
		head.position += Vector3(0.02, -0.09, -0.03)
	var wing := part("wing_left")
	if wing:
		wing.position += Vector3(0.06, 0.1, 0.05)
	if knows and case:
		case.ruin("witness")


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## A part of its model by name (body, head, wing_left, wing_right, tail, perch).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D
