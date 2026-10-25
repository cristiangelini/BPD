class_name Flashlight
extends CopTool

## The flashlight (herramientas.md): F turns it on and off even from the belt (it hangs on the shoulder); in hand,
## left click does too. Lit trails are seen from farther away. In the blackout (carcel-corte-de-luz.md, step 8) its
## battery runs out: it dims and flickers near the end, goes out when it's flat and lights again with a new battery
## (FlashlightBattery).

## How far it lights, in meters, and the cone's half angle in degrees (propuesta).
const RANGE := 18.0
const ANGLE := 22.0
## A lit trail mark is seen from this far (without the light, GrandpaHouse.SEE_TRAIL) (propuesta).
const SEE_RANGE := 8.0
## Seconds of light in a full battery, and from how many seconds left it dims and flickers (propuesta).
const BATTERY_FULL := 60.0
const BATTERY_LOW := 10.0
const ENERGY := 4.0

var is_on := false
## Seconds of light left while it's on; below zero it never runs out (every case but the blackout).
var battery := -1.0
var light: SpotLight3D


func _init() -> void:
	name_key = "TOOL_FLASHLIGHT"


func _ready() -> void:
	super()
	light = SpotLight3D.new()
	light.spot_range = RANGE
	light.spot_angle = ANGLE
	light.light_energy = ENERGY
	light.light_color = Color(1, 0.96, 0.85)
	light.shadow_enabled = true
	light.position = Vector3(0.12, -0.08, -0.65)
	light.visible = is_on
	add_child(light)


func prompt_key() -> String:
	if is_flat():
		return "PROMPT_FLASHLIGHT_FLAT"
	return "PROMPT_FLASHLIGHT_OFF" if is_on else "PROMPT_FLASHLIGHT_ON"


func press() -> void:
	cop.act("belt_flashlight", cop)


func toggle() -> void:
	if not is_on and is_flat():
		_tell("HINT_FLASHLIGHT_FLAT")
		return
	is_on = not is_on
	light.visible = is_on


## Whether its battery ran out.
func is_flat() -> bool:
	return battery == 0.0


## A new battery: BATTERY_FULL seconds of light again.
func recharge() -> void:
	battery = BATTERY_FULL
	light.light_energy = ENERGY


## Every PC runs its copy of each cop's battery, since the clicks that turn it on and off reach all of them in order.
func _process(delta: float) -> void:
	if not is_on or battery < 0.0:
		return
	var was := battery
	battery = maxf(battery - delta, 0.0)
	if battery == 0.0:
		is_on = false
		light.visible = false
		_tell("HINT_FLASHLIGHT_FLAT")
		return
	if was > BATTERY_LOW and battery <= BATTERY_LOW:
		_tell("HINT_FLASHLIGHT_LOW")
	if battery <= BATTERY_LOW:
		var flicker := 0.25 if fmod(battery * 7.3, 1.0) < 0.12 else 1.0
		light.light_energy = ENERGY * (0.35 + 0.65 * battery / BATTERY_LOW) * flicker


## A hint on this cop's own screen only: every PC drains the battery, so each says it to its own player.
func _tell(key: String) -> void:
	if cop and (not cop.sync or cop.sync.is_multiplayer_authority()):
		cop.show_hint(key)


## Whether `point` is inside the lit cone and close enough to make out a trail.
func lights(point: Vector3) -> bool:
	if not is_on:
		return false
	var eye := global_transform
	var to := point - eye.origin
	return to.length() <= SEE_RANGE and rad_to_deg((-eye.basis.z).angle_to(to)) <= ANGLE


## Whether the lit cone reaches `point` (RANGE and ANGLE, the way the light shines) with no wall in between: what the
## blackout's inmates freeze under (carcel-corte-de-luz.md). `except` is left out of the wall check (who's lit).
func reaches(point: Vector3, except: CollisionObject3D = null) -> bool:
	if not is_on or not is_inside_tree():
		return false
	var eye := light.global_transform
	var to := point - eye.origin
	if to.length() > RANGE or rad_to_deg((-eye.basis.z).angle_to(to)) > ANGLE:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye.origin, point, 1)
	if except:
		ray.exclude = [except.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


func build_model() -> Node3D:
	var root := Node3D.new()
	var turn := Vector3(PI / 2, 0, 0)
	root.add_child(piece(cylinder(0.025, 0.2), Color(0.12, 0.12, 0.14), Vector3.ZERO, turn))
	root.add_child(piece(cylinder(0.038, 0.05), Color(0.12, 0.12, 0.14), Vector3(0, 0, -0.11), turn))
	root.add_child(piece(cylinder(0.032, 0.01), Color(1, 0.95, 0.6), Vector3(0, 0, -0.14), turn))
	return root
