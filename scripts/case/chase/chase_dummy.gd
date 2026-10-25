class_name ChaseDummy
extends RigidBody3D

## An inflatable clown the clown car drops on the street (escena-circo.md, "El tablero y el final"; ChaseDrops): it
## looks just like him, has sand in its base so it's in the patrol car's way, and E (the one riding along, or anyone on
## foot) pops it. Every number here is (propuesta).

const MODEL := preload("res://assets/models/inflatable_clown.glb")
const SIZE := Vector3(0.8, 1.7, 0.6)
const MASS := 30.0

var popped := false


func _ready() -> void:
	mass = MASS
	add_to_group("chase_dummies")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_POP_DUMMY"


## E: ¡PLOP! It's gone.
func use(cop: Cop) -> void:
	pop()
	if cop:
		cop.show_hint("HINT_DUMMY_POPPED")


func pop() -> void:
	if popped:
		return
	popped = true
	queue_free()
