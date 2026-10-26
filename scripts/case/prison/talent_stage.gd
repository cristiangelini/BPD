class_name TalentStage
extends Node3D

## The stage of the prison's talent show (carcel-talentos.md, step 2), against the canteen's back wall: a wooden
## platform, a red curtain in two halves that open to the sides and the hand-painted sign over it. Its origin is on the
## floor at the middle of the platform's front edge, and its +Z faces the audience. Every number here is (propuesta).

const SIZE := Vector3(6.0, 0.5, 2.5)
## The curtain hangs this far back from the front edge; the acts happen in front of it.
const CURTAIN_BACK := 1.2
const CURTAIN_HEIGHT := 3.0
const OPEN_TIME := 0.8
## Opened, each half is gathered to this much of its width at its side.
const GATHERED := 0.15
const WOOD := Color(0.5, 0.33, 0.2)
const RED := Color(0.65, 0.08, 0.1)
const SIGN := Color(0.95, 0.9, 0.75)

var is_open := false
var _halves: Array[MeshInstance3D] = []
var _sign: Label3D


func _ready() -> void:
	var body := StaticBody3D.new()
	body.name = "Platform"
	add_child(body)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position = Vector3(0, SIZE.y / 2, -SIZE.z / 2)
	body.add_child(shape)
	add_child(CopTool.piece(CopTool.box(SIZE), WOOD, Vector3(0, SIZE.y / 2, -SIZE.z / 2)))
	# The step up at its west end.
	var step := Vector3(0.8, SIZE.y / 2, 0.5)
	var step_at := Vector3(-SIZE.x / 2 + 0.5, step.y / 2, step.z / 2)
	var step_shape := CollisionShape3D.new()
	var step_box := BoxShape3D.new()
	step_box.size = step
	step_shape.shape = step_box
	step_shape.position = step_at
	body.add_child(step_shape)
	add_child(CopTool.piece(CopTool.box(step), WOOD, step_at))
	for side: float in [-1.0, 1.0]:
		var half := CopTool.piece(CopTool.box(Vector3(SIZE.x / 2, CURTAIN_HEIGHT, 0.06)), RED,
			Vector3(side * SIZE.x / 4, SIZE.y + CURTAIN_HEIGHT / 2, -CURTAIN_BACK))
		half.name = "Curtain%s" % ("West" if side < 0 else "East")
		add_child(half)
		_halves.append(half)
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x + 0.4, 0.3, 0.12)), RED,
		Vector3(0, SIZE.y + CURTAIN_HEIGHT + 0.15, -CURTAIN_BACK)))
	add_child(CopTool.piece(CopTool.box(Vector3(3.4, 0.6, 0.04)), SIGN,
		Vector3(0, SIZE.y + CURTAIN_HEIGHT + 0.75, -CURTAIN_BACK)))
	_sign = Label3D.new()
	_sign.name = "Sign"
	_sign.text = "TALENT_SIGN"
	_sign.font_size = 64
	_sign.pixel_size = 0.004
	_sign.modulate = Color(0.55, 0.1, 0.1)
	_sign.outline_size = 0
	_sign.position = Vector3(0, SIZE.y + CURTAIN_HEIGHT + 0.75, -CURTAIN_BACK + 0.03)
	add_child(_sign)


## Opens (each half gathered at its side) or closes the curtain.
func set_curtain(open: bool, instant := false) -> void:
	is_open = open
	for i in _halves.size():
		var side := -1.0 if i == 0 else 1.0
		var width := GATHERED if open else 1.0
		var x := side * (SIZE.x / 2 - SIZE.x / 4 * width)
		if instant:
			_halves[i].scale.x = width
			_halves[i].position.x = x
			continue
		var move := create_tween().set_parallel()
		move.tween_property(_halves[i], "scale:x", width, OPEN_TIME)
		move.tween_property(_halves[i], "position:x", x, OPEN_TIME)


## World position on the stage's floor, `ahead` metres back from its front edge and `across` to the east.
func spot(across: float, back: float) -> Vector3:
	return global_transform * Vector3(across, SIZE.y, -back)
