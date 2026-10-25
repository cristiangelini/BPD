class_name ChaseFurniture
extends RigidBody3D

## A piece of furniture the moving truck loses in a curve, or a veggie off the market's trike (persecucion.md, ChaseDrops): loose, it slows the patrol car
## down but isn't a fine. Online the host's falls and the guests' copies follow it (NpcSync).

## Which one of ChaseDrops.FURNITURE, or of ChaseDrops.VEGGIES when it's a veggie (set before it's added).
var piece := 0
var veggie := false


func _ready() -> void:
	var data: Dictionary = (ChaseDrops.VEGGIES if veggie else ChaseDrops.FURNITURE)[piece]
	mass = data.mass
	add_to_group("chase_furniture")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = data.size
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	add_child((data.model as PackedScene).instantiate())


## Online (NpcSync): what a guest's copy needs before it's added.
func net_setup() -> Dictionary:
	return {"piece": piece, "veggie": veggie}
