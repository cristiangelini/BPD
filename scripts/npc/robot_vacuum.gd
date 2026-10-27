class_name RobotVacuum
extends StaticBody3D

## Pelusa, the office's robot vacuum (escena-oficina.md, step 2): goes round the first floor on its own, through the
## manager's office and out to the hall, at a vacuum's pace, turning toward where it goes. What it wipes (the coffee
## footprint) and how the cops stop it come with the case, in step 4. Every number here is (propuesta).

const MODEL := preload("res://assets/models/robot_vacuum.glb")
const SPEED := 0.3
const SIZE := Vector3(0.34, 0.1, 0.34)

## Its round, in the parent's space; it goes from one point to the next and starts again.
var route: Array[Vector3] = []
## The point of the route it goes to.
var target := 0
var running := true


func _ready() -> void:
	add_to_group("robot_vacuums")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func _physics_process(delta: float) -> void:
	if not running or route.is_empty():
		return
	var to := route[target] - position
	to.y = 0.0
	var step := SPEED * delta
	if to.length() <= step:
		position = Vector3(route[target].x, position.y, route[target].z)
		target = (target + 1) % route.size()
		return
	position += to.normalized() * step
	rotation.y = atan2(to.x, to.z)
