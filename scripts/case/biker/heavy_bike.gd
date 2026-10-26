class_name HeavyBike
extends Grabbable

## The heavy bike in the biker bar's patio (infiltracion-motos.md, step 3, decision 176): a big chopper of KG kilos, a
## loose body like any other prop. One cop can't lift it (GameScale.COP_CARRY_KG); two together can. In the "lift the
## bike" dare (step 4) it has to be up in the air, LIFT above where it rests, for a while. Made with the level on every
## PC, so online it's kept the same like the other props (PropSync). Every number here is (propuesta).

const MODEL := preload("res://assets/models/heavy_bike.glb")
const KG := 50.0
const SIZE := Vector3(0.8, 1.1, 2.2)
## This high over where it rests is up in the air.
const LIFT := 0.25

## Where it rests on the patio's floor (its height, in its parent's space: the bar moves to its lot after this).
var rest_y := 0.0


func _ready() -> void:
	add_to_group("heavy_bikes")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	can_sleep = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	rest_y = position.y


## Whether it's up in the air.
func lifted() -> bool:
	return position.y > rest_y + LIFT
