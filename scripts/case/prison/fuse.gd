class_name Fuse
extends Grabbable

## A new fuse for the prison's fuse board (carcel-corte-de-luz.md, step 5): a white ceramic cartridge with brass caps,
## small and light, lying somewhere in the dark. In hand, E on the board puts it in (FuseBoard).

const SIZE := Vector3(0.06, 0.06, 0.16)
const CERAMIC := Color(0.92, 0.9, 0.84)
const BRASS := Color(0.75, 0.6, 0.25)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var turn := Vector3(PI / 2, 0, 0)
	add_child(CopTool.piece(CopTool.cylinder(0.025, 0.12), CERAMIC, Vector3.ZERO, turn))
	for z: float in [-0.065, 0.065]:
		add_child(CopTool.piece(CopTool.cylinder(0.03, 0.025), BRASS, Vector3(0, 0, z), turn))


func _ready() -> void:
	add_to_group("blackout_fuses")


## Online (PropSync): the host makes the ones El Chispa drops or tosses; a guest's copy is made from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_FUSE"
