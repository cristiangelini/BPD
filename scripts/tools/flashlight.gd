class_name Flashlight
extends CopTool

## The flashlight (herramientas.md): F turns it on and off even from the belt (it hangs on the shoulder); in hand,
## left click does too. Lit trails are seen from farther away.

## How far it lights, in meters, and the cone's half angle in degrees (propuesta).
const RANGE := 18.0
const ANGLE := 22.0
## A lit trail mark is seen from this far (without the light, GrandpaHouse.SEE_TRAIL) (propuesta).
const SEE_RANGE := 8.0

var is_on := false
var light: SpotLight3D


func _init() -> void:
	name_key = "TOOL_FLASHLIGHT"


func _ready() -> void:
	super()
	light = SpotLight3D.new()
	light.spot_range = RANGE
	light.spot_angle = ANGLE
	light.light_energy = 4.0
	light.light_color = Color(1, 0.96, 0.85)
	light.shadow_enabled = true
	light.position = Vector3(0.12, -0.08, -0.65)
	light.visible = is_on
	add_child(light)


func prompt_key() -> String:
	return "PROMPT_FLASHLIGHT_OFF" if is_on else "PROMPT_FLASHLIGHT_ON"


func press() -> void:
	cop.act("belt_flashlight", cop)


func toggle() -> void:
	is_on = not is_on
	light.visible = is_on


## Whether `point` is inside the lit cone and close enough to make out a trail.
func lights(point: Vector3) -> bool:
	if not is_on:
		return false
	var eye := global_transform
	var to := point - eye.origin
	return to.length() <= SEE_RANGE and rad_to_deg((-eye.basis.z).angle_to(to)) <= ANGLE


func build_model() -> Node3D:
	var root := Node3D.new()
	var turn := Vector3(PI / 2, 0, 0)
	root.add_child(piece(cylinder(0.025, 0.2), Color(0.12, 0.12, 0.14), Vector3.ZERO, turn))
	root.add_child(piece(cylinder(0.038, 0.05), Color(0.12, 0.12, 0.14), Vector3(0, 0, -0.11), turn))
	root.add_child(piece(cylinder(0.032, 0.01), Color(1, 0.95, 0.6), Vector3(0, 0, -0.14), turn))
	return root
