class_name BoughtLot
extends Grabbable

## A lot the cops won at the auction (infiltracion-subasta.md, steps 4 and 6): delivered by the chair, theirs to carry
## or drop, with its weight and box from AuctionSale. Online the host makes it and PropSync copies it from its kind.

var kind := "painting"


func _ready() -> void:
	var size: Vector3 = AuctionSale.LOT_SIZES[kind]
	mass = AuctionSale.LOT_KG[kind]
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	var model: Node3D = (LotEasel.LOTS[kind] as PackedScene).instantiate()
	model.position.y = -size.y / 2
	add_child(model)


## PropSync makes a guest's copy from the script, with the same kind.
func net_setup() -> Dictionary:
	return {"kind": kind}
