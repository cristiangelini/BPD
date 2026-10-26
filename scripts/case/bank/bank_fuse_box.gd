class_name BankFuseBox
extends StaticBody3D

## The blood bank's fuse box (robo-banco-sangre.md, step 2, decision 128), on the corridor's back wall by the back
## door: E brings the bank's light back for a while (BankBlood.lights_on). Its origin is on the wall, at the box's
## middle, with its front to local +Z.

signal switched(cop: Cop)

const SIZE := Vector3(0.5, 0.7, 0.15)
const BOX := Color(0.5, 0.52, 0.55)
const LEVER := Color(0.75, 0.1, 0.1)

## Whether the light is on now (BankBlood says): nothing to do then.
var lights_on: Callable = func() -> bool: return false
var _lever: MeshInstance3D


func _ready() -> void:
	add_to_group("bank_fuse_boxes")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.z = SIZE.z / 2
	add_child(shape)
	add_child(CopTool.piece(CopTool.box(SIZE), BOX, Vector3(0, 0, SIZE.z / 2)))
	_lever = CopTool.piece(CopTool.box(Vector3(0.06, 0.22, 0.06)), LEVER, Vector3(0, 0, SIZE.z + 0.03))
	add_child(_lever)
	show_on(false)


func prompt_key(_cop: Cop) -> String:
	return "" if lights_on.call() else "PROMPT_BANK_LIGHTS"


func use(cop: Cop) -> void:
	if lights_on.call():
		return
	switched.emit(cop)


## The lever up while the light is on, down while it's off.
func show_on(on: bool) -> void:
	_lever.rotation.x = -0.6 if on else 0.6
