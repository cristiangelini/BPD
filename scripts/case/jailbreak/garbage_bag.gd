class_name GarbageBag
extends StaticBody3D

## The night guard's giant garbage bag in the garbage truck jailbreak (docs/diseno/fuga-basura.md): open on a cell's
## floor while he empties the bin, then knotted and dragged behind him to the dumpster (GarbageGuard).

const MODEL := preload("res://assets/models/garbage_bag.glb")

## Lying open on the floor (he's emptying the bin into it), or knotted.
var is_open := true
var _model: Node3D


func _ready() -> void:
	add_to_group("garbage_bags")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.7, 0.9, 0.65)
	shape.shape = box
	shape.position.y = 0.45
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_refresh()


func knot() -> void:
	is_open = false
	_refresh()


## Open, it's flatter and wider on the floor.
func _refresh() -> void:
	_model.scale = Vector3(1.2, 0.45, 1.2) if is_open else Vector3.ONE
