class_name RallyFan
extends CharacterBody3D

## Someone in the crowd at deputy Lustre's rally (proteccion-politico.md, step 2, decision 103): a neighbor standing in
## front of the stage. Most cheer now and then; a `heckler` hides a market bag of eggs and tomatoes and throws one at
## the politician when RallyCrowd says so (throw_at). Every number here is (propuesta).

signal threw(fan: RallyFan, throwable: RallyThrowable)

const SCALES := {"abuelo": 0.82, "abuela": 0.8}
const SAY_TIME := 4.0
## Where the throw leaves from: about their raised hand.
const HAND := Vector3(0.25, 1.5, 0)
## Seconds in the air: a high arc the cops can see coming.
const FLIGHT := 1.3

@export var look := "vecina"
var heckler := false
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("rally_fans")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	var model: Node3D = load("res://assets/models/npc_%s.glb" % look).instantiate()
	model.scale = Vector3.ONE * SCALES.get(look, 1.0)
	# The models face +Z; the fan faces -Z like everyone else.
	model.rotation.y = PI
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.8, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## Throws a `kind` ("egg" or "tomato") to land on `target` (world space). Returns what flies.
func throw_at(target: Vector3, kind: String) -> RallyThrowable:
	var thrown := RallyThrowable.new()
	thrown.kind = kind
	get_parent().add_child(thrown, true)
	thrown.launch(global_transform * HAND, target, FLIGHT)
	add_collision_exception_with(thrown)
	thrown.add_collision_exception_with(self)
	threw.emit(self, thrown)
	return thrown


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
