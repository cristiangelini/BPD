class_name SeaLion
extends AnimatableBody3D

## Bigotes, the loose sea lion (escena-acuario.md, "Bigotes"): he waddles round and round the aquarium's hall along
## `route`, turning to face where he goes. E on him, he barks and claps. Stealing what cops leave about, the fish and the
## wet trail come in step 6. Every number here is (propuesta).

const MODEL := preload("res://assets/models/sea_lion_bigotes.glb")
const SPEED := 1.2
const LINES := 3

## The points he waddles through in a loop, in his parent's space. Empty, he stays put.
var route: Array[Vector3] = []
## Whether he is waddling (false: he stays where he is).
var waddling := true
var _next := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("sea_lion")
	collision_layer = 8
	sync_to_physics = false
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.2
	shape.shape = capsule
	shape.position.y = 0.6
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.6
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SEA_LION"


func use(_cop: Cop) -> void:
	say("SEA_LION_LINE_%d" % (_lines_said % LINES))
	_lines_said += 1


## Where he balances what he steals: the tip of his nose.
func nose() -> Node3D:
	return _model.find_child("nose", true, false) as Node3D


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
	if waddling and not route.is_empty():
		_waddle(delta)


func _waddle(delta: float) -> void:
	var target := route[_next % route.size()]
	var to := target - position
	to.y = 0.0
	if to.length() <= SPEED * delta:
		position = Vector3(target.x, position.y, target.z)
		_next = (_next + 1) % route.size()
		return
	position += to.normalized() * SPEED * delta
	rotation.y = atan2(to.x, to.z)
