class_name RustyPart
extends Grabbable

## A "new" part that isn't (allanamiento-taller.md, "Las piezas cambiadas"): silver paint over rust, so whoever grabs it
## is left with an orange hand. `rusted` fires the first time each cop grabs it.

signal rusted(cop: Cop)

const MODEL := preload("res://assets/models/garage_rusty_disc.glb")
const SIZE := Vector3(0.28, 0.05, 0.28)

## The cops whose hands it already stained.
var stained := {}


func _init() -> void:
	mass = 3.0
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.position.y = -SIZE.y / 2
	add_child(model)


func hold(holder_id: int, point: Vector3) -> void:
	var holder := instance_from_id(holder_id) as Node
	var cop := holder.get_parent() as Cop if holder else null
	super.hold(holder_id, point)
	if cop and not stained.has(cop):
		stained[cop] = true
		rusted.emit(cop)
