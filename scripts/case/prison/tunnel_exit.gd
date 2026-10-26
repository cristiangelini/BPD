class_name TunnelExit
extends StaticBody3D

## The tunnel's far end, outside the prison's wall (carcel-tunel.md, step 5). Close to through, the ground there
## starts to move (`peek_out`); through, it's a hole, and whoever comes along the tunnel sticks their head out of it a
## moment before they run: a cop waiting there catches them with E ("¡Cucú!"; TunnelPlan decides). Its origin is on
## the ground in its middle. Every number here is (propuesta).

signal grabbed(cop: Cop)

const RADIUS := 0.45
const WOBBLE := 0.06

## Someone's head sticking out of it now.
var peeking := false
var _mound: MeshInstance3D
var _hole: MeshInstance3D
var _wobble: Tween


func _ready() -> void:
	add_to_group("tunnel_exits")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(RADIUS * 2, 0.3, RADIUS * 2)
	shape.shape = box
	shape.position.y = 0.15
	add_child(shape)
	var dirt := CylinderMesh.new()
	dirt.top_radius = 0.2
	dirt.bottom_radius = RADIUS + 0.2
	dirt.height = 0.25
	_mound = CopTool.piece(dirt, TunnelDirt.COLOR, Vector3(0, 0.12, 0))
	_mound.visible = false
	add_child(_mound)
	_hole = CopTool.piece(CopTool.cylinder(RADIUS, 0.02), CellHideout.DARK, Vector3(0, 0.26, 0))
	_hole.visible = false
	add_child(_hole)


## Close to through: the dirt here bulges and wobbles.
func peek_out() -> void:
	if _mound.visible:
		return
	_mound.visible = true
	_wobble = create_tween().set_loops()
	_wobble.tween_property(_mound, "scale", Vector3(1, 1 + WOBBLE * 3, 1), 0.3)
	_wobble.tween_property(_mound, "scale", Vector3(1 + WOBBLE, 1, 1 + WOBBLE), 0.3)


## Through: the hole at its top is open.
func open() -> void:
	peek_out()
	if _wobble:
		_wobble.kill()
		_wobble = null
	_mound.scale = Vector3.ONE
	_hole.visible = true


func is_open() -> bool:
	return _hole.visible


func is_showing() -> bool:
	return _mound.visible


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_GRAB_ESCAPEE" if peeking else ""


func use(cop: Cop) -> void:
	if peeking:
		grabbed.emit(cop)
