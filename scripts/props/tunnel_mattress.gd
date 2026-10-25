class_name TunnelMattress
extends Grabbable

## A bunk's mattress in the spoon tunnel jailbreak (docs/diseno/fuga-tunel.md, step 3): picked up with the hands and
## laid over the cell's hole (TunnelHole), it hides it from the guard; it has to come off to dig on.

const MODEL := preload("res://assets/models/tunnel_mattress.glb")
const SIZE := Vector3(1.9, 0.12, 0.75)
## How far above or below it the hole can be and still be under it.
const COVER_HEIGHT := 0.3


func _ready() -> void:
	mass = 3.0
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


## Whether it lies over the point `at` (a hole on the floor), not in someone's hands.
func covers(at: Vector3) -> bool:
	if is_held():
		return false
	var local := global_transform.affine_inverse() * at
	return absf(local.x) <= SIZE.x / 2 and absf(local.z) <= SIZE.z / 2 and absf(local.y) <= COVER_HEIGHT
