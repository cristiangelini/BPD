class_name GiantDoll
extends StaticBody3D

## The giant parade doll in the doll factory's storeroom (fabrica.md, "El muñeco gigante"): 3 m tall, in a wide dress.
## Its dress has a zipper down the back: E on it, from behind, opens the back flap, and what's inside the dress can be
## reached. It faces +z; the walls of its dress are boxes, the back one goes away when it opens.

signal opened(cop: Cop)

const MODEL := preload("res://assets/models/giant_doll.glb")
const FLAP_MODEL := preload("res://assets/models/giant_doll_flap.glb")
## The dress's walls (center, size), the back one last.
const WALLS := [
	[Vector3(0, 0.8, 0.6), Vector3(1.3, 1.6, 0.1)], [Vector3(-0.62, 0.8, 0), Vector3(0.1, 1.6, 1.2)],
	[Vector3(0.62, 0.8, 0), Vector3(0.1, 1.6, 1.2)], [Vector3(0, 0.8, -0.6), Vector3(1.3, 1.6, 0.1)],
]
const TORSO := [Vector3(0, 2.1, 0), Vector3(0.85, 1.0, 0.7)]

var is_open := false
var _flap: Node3D
var _back: CollisionShape3D


func _ready() -> void:
	add_child(MODEL.instantiate())
	_flap = FLAP_MODEL.instantiate()
	_flap.name = "Flap"
	add_child(_flap)
	for wall: Array in WALLS + [TORSO]:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = wall[1]
		shape.shape = box
		shape.position = wall[0]
		add_child(shape)
		if wall == WALLS[3]:
			_back = shape


## The zipper only shows from behind the doll.
func prompt_key(cop: Cop) -> String:
	return "PROMPT_GIANT_ZIPPER" if not is_open and to_local(cop.global_position).z < 0.0 else ""


func use(cop: Cop) -> void:
	if prompt_key(cop) != "":
		open(cop)


func open(cop: Cop = null) -> void:
	if is_open:
		return
	is_open = true
	_flap.hide()
	_back.disabled = true
	opened.emit(cop)
