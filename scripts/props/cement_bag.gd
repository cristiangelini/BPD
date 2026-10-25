class_name CementBag
extends Grabbable

## A bag of quick-setting cement by the prison's gate in the tunnel case (carcel-tunel.md, step 5). In hand, E on the
## tunnel's open hole (CellHideout) pours it in and the tunnel is sealed for good.

const SIZE := Vector3(0.45, 0.16, 0.65)
const PAPER := Color(0.88, 0.85, 0.78)
const STRIPE := Color(0.25, 0.35, 0.6)


func _ready() -> void:
	mass = 12.0
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(CopTool.piece(CopTool.box(SIZE), PAPER))
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x + 0.005, SIZE.y * 0.3, SIZE.z * 0.25)), STRIPE))


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_CEMENT"
