class_name FootballStretcher
extends Grabbable

## The stretcher by the deputy's bench (politico-futbol.md, step 4, decision 179). Empty, one cop carries it. Laid
## next to the deputy when he's down, he gets on it (FootballLustre) and then it weighs like the safe: it takes two
## cops to carry him to the bench. Every number here is (propuesta).

const MODEL := preload("res://assets/models/stretcher.glb")
const EMPTY_KG := 10.0
## The deputy on it, in carrying weight: more than one cop can lift, less than two.
const DEPUTY_KG := 40.0
const SIZE := Vector3(0.7, 0.3, 2.2)

## The deputy is lying on it.
var loaded := false


func _ready() -> void:
	add_to_group("football_stretchers")
	mass = EMPTY_KG
	collision_layer = 4
	collision_mask = 15
	angular_damp = 2.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.name = "Model"
	add_child(model)


## The deputy gets on it or off it.
func carry(on: bool) -> void:
	loaded = on
	mass = EMPTY_KG + (DEPUTY_KG if on else 0.0)
	sleeping = false


## Where he lies, on the canvas.
func bed() -> Vector3:
	return global_position + global_basis.y * 0.3

