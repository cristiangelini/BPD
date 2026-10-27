class_name RobotVacuum
extends StaticBody3D

## Pelusa, the office's robot vacuum (escena-oficina.md, step 2): goes round the first floor on its own, through the
## manager's office and out to the hall, at a vacuum's pace, turning toward where it goes. With the case it vacuums the
## coffee footprint if it gets to it (OfficeClues); E flips it over, wheels up, and it stops until flipped back. Every
## number here is (propuesta).

const MODEL := preload("res://assets/models/robot_vacuum.glb")
const SPEED := 0.3
const SIZE := Vector3(0.34, 0.1, 0.34)
## It vacuums what's this close to its middle, in meters.
const REACH := 0.4

## Its round, in the parent's space; it goes from one point to the next and starts again.
var route: Array[Vector3] = []
## The point of the route it goes to.
var target := 0
var running := true
var flipped := false
## The coffee footprint on its round, if the case has one.
var footprint: FlourPrint


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


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_VACUUM_UNFLIP" if flipped else "PROMPT_VACUUM_FLIP"


## E: over on its back, wheels spinning, or back on its wheels and on its way.
func use(_cop: Cop) -> void:
	flipped = not flipped
	running = not flipped
	rotation.z = PI if flipped else 0.0
	position.y += SIZE.y if flipped else -SIZE.y


func _physics_process(delta: float) -> void:
	if not running or route.is_empty():
		return
	if footprint and not footprint.wiped:
		var off := footprint.global_position - global_position
		if Vector2(off.x, off.z).length() <= REACH:
			footprint.wipe()
	var to := route[target] - position
	to.y = 0.0
	var step := SPEED * delta
	if to.length() <= step:
		position = Vector3(route[target].x, position.y, route[target].z)
		target = (target + 1) % route.size()
		return
	position += to.normalized() * step
	rotation.y = atan2(to.x, to.z)
