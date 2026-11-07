class_name BallPitSpot
extends StaticBody3D

## The sea of balls in the toy store's ball pit (allanamiento-jugueteria.md, "El pelotero"): whatever is hidden there
## can't be seen. A cop stirs it with E; after STIRS stirs it turns up what was in it (if anything). Every number here
## is (propuesta).

signal stirred_out(spot: BallPitSpot)

const STIRS := 3
const SIZE := Vector3(3.6, 0.3, 3.6)

## What waits under the balls (hidden and frozen until stirred out), if anything.
var hidden: RigidBody3D
var stirs := 0


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = -SIZE.y / 2
	add_child(shape)


## Hides `item` among the balls until it's stirred out.
func hide_item(item: RigidBody3D) -> void:
	hidden = item
	item.freeze = true
	item.visible = false
	item.collision_layer = 0
	item.global_position = global_position + Vector3.DOWN * 0.2


func is_open() -> bool:
	return stirs >= STIRS


func prompt_key(_cop: Cop) -> String:
	return "" if is_open() else "PROMPT_STIR_PIT"


## E: one more stir among the balls; the last one turns up what was there.
func use(cop: Cop) -> void:
	if is_open():
		return
	stirs += 1
	if not is_open():
		cop.show_hint("HINT_PIT_STIRRING")
		return
	if hidden:
		hidden.global_position = global_position + Vector3.UP * 0.5
		hidden.collision_layer = 4
		hidden.visible = true
		hidden.freeze = false
		hidden = null
		cop.show_hint("HINT_PIT_FOUND")
	else:
		cop.show_hint("HINT_PIT_NOTHING")
	stirred_out.emit(self)
