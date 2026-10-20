class_name DigSpot
extends StaticBody3D

## A patch of loose earth in the pet salon's yard (peluqueria.md, "Contrabando de huesos"). A cop with the shovel in
## hand digs it with E; after DIGS digs the hole is open and what was buried (if anything) comes up. Dogs dig here too,
## which only piles up dirt. Every number here is (propuesta).

signal dug_out(spot: DigSpot)

const DIGS := 3
const SIZE := Vector3(0.9, 0.03, 0.9)
const DIRT := Color(0.42, 0.3, 0.18)

## What waits under it (hidden and frozen until dug out), if anything.
var buried: Evidence
var digs := 0
## Dirt the dogs piled up digging here.
var mess := 0
var _pile: MeshInstance3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_pile = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.45
	sphere.height = 0.9
	var dirt := StandardMaterial3D.new()
	dirt.albedo_color = DIRT
	sphere.material = dirt
	_pile.mesh = sphere
	_pile.scale = Vector3(1, 0.06, 1)
	add_child(_pile)


## Hides `item` under this patch until it's dug out.
func bury(item: Evidence) -> void:
	buried = item
	item.freeze = true
	item.visible = false
	item.collision_layer = 0
	item.global_position = global_position + Vector3.DOWN * 0.5


func is_open() -> bool:
	return digs >= DIGS


func prompt_key(cop: Cop) -> String:
	if is_open():
		return ""
	return "PROMPT_DIG" if cop.get_node("Grabber").held is Shovel else "PROMPT_DIG_NEED_SHOVEL"


## E with the shovel in hand: one more dig. Without it, a hint.
func use(cop: Cop) -> void:
	if is_open():
		return
	if not cop.get_node("Grabber").held is Shovel:
		cop.show_hint("HINT_NEED_SHOVEL")
		return
	digs += 1
	_pile.scale.y = 0.06 + 0.12 * digs
	if not is_open():
		return
	if buried:
		buried.global_position = global_position + Vector3.UP * 0.4
		buried.collision_layer = 4
		buried.visible = true
		buried.freeze = false
		cop.show_hint("HINT_DIG_FOUND")
	else:
		cop.show_hint("HINT_DIG_NOTHING")
	dug_out.emit(self)


## A dog dug here: more dirt, nothing comes up.
func dog_dug() -> void:
	mess += 1
	_pile.scale = Vector3(1.0 + 0.15 * mini(mess, 4), 0.06 + 0.08 * mini(mess, 4), 1.0 + 0.15 * mini(mess, 4))
