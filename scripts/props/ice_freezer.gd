class_name IceFreezer
extends StaticBody3D

## A chest freezer of the ice cream shop (docs/diseno/allanamiento-heladeria.md, "Lo que se derrite"): E opens or
## shuts its glass lid, and a lid left open MELT_AFTER seconds melts what's inside, once. The origin is at the floor
## in the middle; the lid hinges on the back (-Z).

signal melted

const MODEL := preload("res://assets/models/ice_freezer.glb")
const LID_MODEL := preload("res://assets/models/freezer_lid.glb")
const SIZE := Vector3(1.6, 0.85, 0.8)
const MELT_AFTER := 15.0
## How far the lid swings up, a bit past upright so it stays open.
const OPEN_ANGLE := -1.75

var is_open := false
var is_melted := false
## Seconds the lid has been open in a row.
var open_for := 0.0
var _lid: Node3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	_lid = LID_MODEL.instantiate()
	_lid.position = Vector3(0, SIZE.y, -SIZE.z / 2)
	add_child(_lid)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_FREEZER_CLOSE" if is_open else "PROMPT_FREEZER_OPEN"


func use(_cop: Cop) -> void:
	set_open(not is_open)


func set_open(open: bool) -> void:
	is_open = open
	if not open:
		open_for = 0.0
	_lid.rotation.x = OPEN_ANGLE if open else 0.0


func _physics_process(delta: float) -> void:
	# Online the host's freezers melt; the guests' take it from the shop's state (IceCreamShop.net_state).
	if not is_open or is_melted or not multiplayer.is_server():
		return
	open_for += delta
	if open_for >= MELT_AFTER:
		melt()


## What's inside melts, once.
func melt() -> void:
	if is_melted:
		return
	is_melted = true
	melted.emit()
