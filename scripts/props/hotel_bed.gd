class_name HotelBed
extends StaticBody3D

## An unmade bed in one of the hotel's rooms (hotel-allanamiento.md, "Doña Escoba, la mucama"): E and the cop makes
## it, MAKE_SECONDS with the hands busy (E again stops halfway). Doña Escoba talks to whoever helps her.

signal started(cop: Cop)
signal made_by(cop: Cop)

const MAKE_SECONDS := 3.0
## The bed's top, over the hotel's bed box: wide enough that the cop's aim lands here and not on the box under it.
const SIZE := Vector3(1.4, 0.2, 2.0)
const MESSY := Color(0.85, 0.75, 0.55)
const NEAT := Color(0.62, 0.12, 0.14)

var room := 0
var made := false
var maker: Cop
var _left := 0.0
var _messy: Node3D
var _neat: MeshInstance3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	# Unmade: a crumpled blanket, a lump and a pillow on the floor side; made: a flat red cover.
	_messy = Node3D.new()
	_messy.name = "Messy"
	add_child(_messy)
	_messy.add_child(_box(Vector3(1.2, 0.12, 1.1), Vector3(0.1, 0.06, 0.3), Vector3(0.1, 0.4, 0.15), MESSY))
	_messy.add_child(_box(Vector3(0.7, 0.18, 0.6), Vector3(-0.3, 0.09, -0.4), Vector3(-0.2, -0.6, 0.0), MESSY.darkened(0.1)))
	_messy.add_child(_box(Vector3(0.5, 0.12, 0.35), Vector3(0.4, 0.06, -0.75), Vector3(0.0, 0.9, 0.3), Color.WHITE))
	_neat = _box(Vector3(1.42, 0.04, 1.6), Vector3(0, 0.02, 0.15), Vector3.ZERO, NEAT)
	_neat.visible = false
	add_child(_neat)


func prompt_key(cop: Cop) -> String:
	if made:
		return ""
	if maker == cop:
		return "PROMPT_HOTEL_BED_MAKING"
	return "" if maker else "PROMPT_HOTEL_MAKE_BED"


## E: the cop lets go of what it held and starts making the bed.
func use(cop: Cop) -> void:
	if made or maker:
		return
	cop.get_node("Grabber").release()
	cop.seated_in = self
	maker = cop
	_left = MAKE_SECONDS
	started.emit(cop)


## E again while making it: the cop stops, and the bed stays unmade.
func stand_up() -> void:
	if maker:
		maker.seated_in = null
		maker = null


func _physics_process(delta: float) -> void:
	if not maker:
		return
	_left -= delta
	if _left > 0.0:
		return
	var cop := maker
	stand_up()
	made = true
	_messy.visible = false
	_neat.visible = true
	made_by.emit(cop)


func _box(size: Vector3, at: Vector3, turn: Vector3, color: Color) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	look.mesh = mesh
	look.position = at
	look.rotation = turn * 0.3
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	look.material_override = material
	return look
