class_name TrafficCone
extends Grabbable

## A traffic cone (control-transito.md, step 1): 1.5 kg, one cop carries a few. The checkpoint counts the ones
## standing in the lane before the barrier. Its origin is on the ground. Every number here is (propuesta).

const KG := 1.5
const SIZE := Vector3(0.42, 0.7, 0.42)
const MODEL := "res://assets/models/traffic_cone.glb"


func _ready() -> void:
	add_to_group("traffic_cones")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child((load(MODEL) as PackedScene).instantiate())


## Still standing up: a knocked-over cone doesn't count.
func standing() -> bool:
	return global_basis.y.dot(Vector3.UP) > 0.8
