class_name LooseChair
extends Grabbable

## One of the chair tower's twelve chairs, loose once it fell (ChairTower). Built in code, so online a guest makes its
## copy from this script (PropSync, net_setup).

const MODEL := preload("res://assets/models/dining_chair.glb")


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = ChairTower.CHAIR_KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = ChairTower.CHAIR_SIZE
	shape.shape = box
	add_child(shape)
	var look: Node3D = MODEL.instantiate()
	look.position = Vector3(0, -ChairTower.CHAIR_SIZE.y / 2, 0)
	add_child(look)


## Online: a guest's copy needs nothing beyond what it builds itself.
func net_setup() -> Dictionary:
	return {}
