class_name Copito
extends Grabbable

## Copito, the baby penguin (escena-zoo.md): found in his hiding spot, a cop carries him in their arms (he wriggles) back
## to his ice floe. Let go on the floe, or near it, he's home: he stays there and the zoo tells the case (+100).

const MODEL := preload("res://assets/models/animal_copito.glb")
## How close to the floe's middle counts as on it, along the ground.
const HOME_REACH := 1.4
const FLAP_SPEED := 18.0

var zoo: Node3D
var home := false
var _model: Node3D
var _flap := 0.0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 4.0
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.16
	capsule.height = 0.5
	shape.shape = capsule
	shape.position.y = 0.25
	add_child(shape)


func _ready() -> void:
	_model = MODEL.instantiate()
	add_child(_model)


func _physics_process(delta: float) -> void:
	if home:
		return
	if not holders.is_empty():
		_flap += delta * FLAP_SPEED
		_model.rotation.z = sin(_flap) * 0.25
		return
	_model.rotation.z = 0.0
	if zoo and zoo.call("on_floe", global_position):
		zoo.call("copito_home")


## Home, he stays put.
func hold(holder_id: int, point: Vector3) -> void:
	if not home:
		super.hold(holder_id, point)


## Stays on his floe, still.
func settle(at: Vector3) -> void:
	home = true
	freeze = true
	global_position = at
	rotation = Vector3.ZERO
