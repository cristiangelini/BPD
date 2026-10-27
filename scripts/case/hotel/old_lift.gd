class_name OldLift
extends StaticBody3D

## The lift of 1987 (hotel-allanamiento.md, "El ascensor de 1987"): its old cage stands out of the lobby's back wall,
## out of order. Its doors don't open with E: a cop holding the crank (LiftCrank) turns it in the doors for
## CRANK_SECONDS and they slide apart. What it hides waits inside. Every number here is (propuesta).

signal opened

const CRANK_SECONDS := 3.0
## The cage, from the back wall forward: width, height and depth, and how thick its sheet metal is.
const SIZE := Vector3(1.8, 2.4, 1.6)
const SHEET := 0.06
const METAL := Color(0.55, 0.58, 0.62)
const BRASS := Color(0.85, 0.68, 0.3)

var is_open := false
var turner: Cop
var _left := 0.0
var _doors: Array[MeshInstance3D] = []
var _door_shapes: Array[CollisionShape3D] = []


func _ready() -> void:
	# The cage's origin is at the middle of its foot against the wall; it reaches forward along +Z.
	var front := SIZE.z
	_wall(Vector3(-SIZE.x / 2, SIZE.y / 2, front / 2), Vector3(SHEET, SIZE.y, front))
	_wall(Vector3(SIZE.x / 2, SIZE.y / 2, front / 2), Vector3(SHEET, SIZE.y, front))
	_wall(Vector3(0, SIZE.y, front / 2), Vector3(SIZE.x, SHEET, front))
	_wall(Vector3(0, 0.03, front / 2), Vector3(SIZE.x, SHEET, front))
	for side: float in [-1.0, 1.0]:
		var at := Vector3(side * SIZE.x / 4, SIZE.y / 2, front)
		var size := Vector3(SIZE.x / 2, SIZE.y, SHEET)
		_door_shapes.append(_shape(at, size))
		_doors.append(_mesh(at, size, METAL.lightened(0.1)))
	_mesh(Vector3(0, SIZE.y + 0.15, front), Vector3(0.9, 0.25, 0.04), BRASS)


func prompt_key(cop: Cop) -> String:
	if is_open:
		return ""
	if turner == cop:
		return "PROMPT_LIFT_TURNING"
	return "PROMPT_LIFT_STUCK"


## E: with the crank in hand the cop starts turning it; without it the doors don't budge.
func use(cop: Cop) -> void:
	if is_open or turner:
		return
	if not cop.get_node("Grabber").held is LiftCrank:
		cop.show_hint("HINT_LIFT_STUCK")
		return
	turner = cop
	cop.seated_in = self
	_left = CRANK_SECONDS


## E again while turning: the cop stops, and the doors stay shut.
func stand_up() -> void:
	if turner:
		turner.seated_in = null
		turner = null


func open() -> void:
	if is_open:
		return
	is_open = true
	for i in _doors.size():
		_door_shapes[i].disabled = true
		var tween := create_tween()
		tween.tween_property(_doors[i], "position:x", (-1.0 if i == 0 else 1.0) * (SIZE.x / 2 + 0.4), 1.0)
	opened.emit()


func _physics_process(delta: float) -> void:
	if not turner:
		return
	_left -= delta
	if _left <= 0.0:
		stand_up()
		open()


func _wall(at: Vector3, size: Vector3) -> void:
	_shape(at, size)
	_mesh(at, size, METAL)


func _shape(at: Vector3, size: Vector3) -> CollisionShape3D:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	add_child(shape)
	return shape


func _mesh(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	look.mesh = box
	look.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	look.material_override = material
	add_child(look)
	return look
