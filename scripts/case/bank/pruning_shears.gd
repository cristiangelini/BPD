class_name PruningShears
extends Grabbable

## Pruning shears from the seed bank's counter (robo-banco-semillas.md, step 2, decision 129): in hand, E on a vine
## wall (BankVine) snips it. They wait still on the counter until someone takes them.

const KG := 0.4
const BLADE := Color(0.75, 0.77, 0.8)
const HANDLE := Color(0.8, 0.15, 0.1)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.12, 0.05, 0.42)
	shape.shape = box
	add_child(shape)
	for side: float in [-1.0, 1.0]:
		add_child(CopTool.piece(CopTool.box(Vector3(0.03, 0.02, 0.2)), BLADE, Vector3(side * 0.015, 0, -0.1),
			Vector3(0, side * 0.12, 0)))
		add_child(CopTool.piece(CopTool.box(Vector3(0.035, 0.035, 0.22)), HANDLE, Vector3(side * 0.04, 0, 0.1),
			Vector3(0, -side * 0.2, 0)))


func _ready() -> void:
	add_to_group("pruning_shears")
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true


func hold(holder_id: int, point: Vector3) -> void:
	freeze = false
	super.hold(holder_id, point)


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_SHEARS"


## Online (PropSync): a guest's copy is made from this script.
func net_setup() -> Dictionary:
	return {}
