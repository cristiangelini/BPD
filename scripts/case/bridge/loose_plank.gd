class_name LoosePlank
extends Grabbable

## A plank off the bridge (politico-puente.md, steps 3 and 4): one that fell into the canal, or a spare from the
## builders' pickup. 6 kg, one cop carries it. Online the host makes it and PropSync copies it from the script.

const KG := 6.0


func _ready() -> void:
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = BridgePark.PLANK
	shape.shape = box
	add_child(shape)
	add_child(BridgePark.PLANK_MODEL.instantiate())


## PropSync makes a guest's copy from the script.
func net_setup() -> Dictionary:
	return {}
