class_name CleaningTool
extends HookStick

## Something from the cleaning closet of the cleaning crew's jailbreak (docs/diseno/fuga-limpieza.md, steps 3 and 4):
## the mop or the feather duster. In hand it points where the cop looks, like the jailbreak's broom (HookStick), so the
## mop's head goes to the floor by looking down. It's working while it's held and its head moves: the mop with its
## head on the floor (it scrubs FloorStains), the duster anywhere. Someone of the cleaning crew working with one passes
## in front of the early comisario (EarlyComisario). Every number here is (propuesta).

## "mop" or "duster".
@export var kind := "mop"

## How fast the head must go to count as working (m/s), and how far above the floor the mop's head can be.
const WORKING_SPEED := 0.3
const MOP_ABOVE := 0.3
## Seconds it still counts as working after its head stops (a mop going back and forth stops at each end).
const WORKING_MEMORY := 0.6

## How fast its head goes, measured from where it was the last tick.
var tip_speed := 0.0
var _last_tip := Vector3.ZERO
var _working_left := 0.0


static func held_by(cop: Cop) -> CleaningTool:
	return cop.get_node("Grabber").held as CleaningTool


func _ready() -> void:
	super()
	add_to_group("cleaning_tools")
	_last_tip = tip()


func _physics_process(delta: float) -> void:
	super(delta)
	var at := tip()
	tip_speed = at.distance_to(_last_tip) / delta
	_last_tip = at
	_working_left = WORKING_MEMORY if is_held() and tip_speed >= WORKING_SPEED and _head_down() \
		else maxf(_working_left - delta, 0.0)


## The mop's head on the floor (the duster works anywhere).
func _head_down() -> bool:
	if kind != "mop":
		return true
	var ray := PhysicsRayQueryParameters3D.create(tip() + Vector3.UP * 0.1, tip() + Vector3.DOWN * MOP_ABOVE, 1)
	return not get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


func is_working() -> bool:
	return is_held() and _working_left > 0.0


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_MOP" if kind == "mop" else "PROMPT_HOLDING_DUSTER"
