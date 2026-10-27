class_name PlanetariumSleeper
extends StaticBody3D

## Doña Nebulosa (escena-planetario.md, "El lugar"): the lady who goes to every show and sleeps in the front row, in her
## long coat, shawl and curlers. She's the witness (step 6); for now E on her only gets a snore, a different one each
## time. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_nebulosa.glb")
const LINES := 3

var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("planetarium_sleeper")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	part("eyes_open").visible = false
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.0
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SLEEPER"


func use(_cop: Cop) -> void:
	say("SLEEPER_LINE_%d" % (_lines_said % LINES))
	_lines_said += 1


func is_asleep() -> bool:
	return not part("eyes_open").visible


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


## A part of her model by name (eyes_open, eyes_shut, zzz, hair).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D
