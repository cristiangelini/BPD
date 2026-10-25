class_name FlashlightBattery
extends Grabbable

## A spare battery for the flashlight in the blackout (carcel-corte-de-luz.md, step 8): a fat little cell with a red
## band, lying in the kitchen or somewhere in the dark. E with it in hand puts it in your flashlight (Cop.change_battery).

const SIZE := Vector3(0.05, 0.05, 0.1)
const BODY := Color(0.1, 0.1, 0.12)
const BAND := Color(0.85, 0.2, 0.15)
const TIP := Color(0.8, 0.75, 0.6)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var turn := Vector3(PI / 2, 0, 0)
	add_child(CopTool.piece(CopTool.cylinder(0.022, 0.09), BODY, Vector3.ZERO, turn))
	add_child(CopTool.piece(CopTool.cylinder(0.023, 0.03), BAND, Vector3(0, 0, -0.025), turn))
	add_child(CopTool.piece(CopTool.cylinder(0.008, 0.01), TIP, Vector3(0, 0, -0.05), turn))


func _ready() -> void:
	add_to_group("blackout_batteries")


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_CHANGE_BATTERY"
