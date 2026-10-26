class_name ToyHelicopter
extends Grabbable

## The giant toy helicopter of the roof robbery (robo-banco-techo.md, step 1, decision 126): as big as a fridge,
## yellow, waiting on the bank's roof on its helipad with its rotors humming. It weighs KG, so one cop drags it and two
## carry it. El Oso's nephew flies it from the sidewalk across (BankNephew). Its origin is on the ground under the
## mast, its front to +Z. Every number here is (propuesta).

const KG := 40.0
const MODEL := preload("res://assets/models/toy_helicopter.glb")
## Its body without the rotors and the tail, which don't knock anything.
const SIZE := Vector3(1.0, 1.0, 1.4)
## How fast the rotors turn waiting on the ground (radians a second).
const IDLE_SPIN := 6.0

## How fast they turn now.
var spin := IDLE_SPIN
var _rotor: Node3D
var _tail_rotor: Node3D


func _ready() -> void:
	add_to_group("toy_helicopters")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var model := MODEL.instantiate()
	add_child(model)
	_rotor = model.find_child("rotor", true, false) as Node3D
	_tail_rotor = model.find_child("tail_rotor", true, false) as Node3D


func _process(delta: float) -> void:
	if _rotor:
		_rotor.rotate_y(spin * delta)
	if _tail_rotor:
		_tail_rotor.rotate_x(spin * 1.5 * delta)
