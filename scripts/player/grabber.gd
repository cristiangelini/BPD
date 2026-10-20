class_name Grabber
extends Node

## Lets its cop grab what the camera points at: hold left click to carry, right click to throw,
## mouse wheel to bring it closer or push it away.

@export var input_enabled := true

var held: Grabbable
var hold_distance := GameScale.HOLD_MAX

@onready var _cop: Cop = get_parent()


func _physics_process(_delta: float) -> void:
	if input_enabled:
		if Input.is_action_just_pressed("grab"):
			try_grab()
		elif Input.is_action_just_released("grab"):
			release()
		elif Input.is_action_just_pressed("throw"):
			throw()
	if held:
		held.hold(get_instance_id(), hold_point())


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled or not held:
		return
	if event.is_action_pressed("hold_closer"):
		nudge(true)
	elif event.is_action_pressed("hold_farther"):
		nudge(false)


## Brings what it holds a bit closer, or pushes it a bit away.
func nudge(closer: bool) -> void:
	if _asks_host():
		_cop.sync.request("closer" if closer else "farther")
	hold_distance = clampf(hold_distance + (-0.25 if closer else 0.25), GameScale.HOLD_MIN, GameScale.HOLD_MAX)


## Online on a guest: the host moves the props, so this cop's hands are only asked of it (docs/diseno/online.md).
func _asks_host() -> bool:
	return _cop.sync != null and _cop.sync.is_multiplayer_authority() and not _cop.sync.net.is_host()


func hold_point() -> Vector3:
	var eye := _cop.camera.global_transform
	return eye.origin - eye.basis.z * hold_distance


## Grabs the object in front of the camera within reach. Returns true if it got one.
func try_grab() -> bool:
	if _cop.ram or _cop.is_busy() or _cop.is_eating():
		return false
	var eye := _cop.camera.global_transform
	var hit := _cop.aim_hit(GameScale.GRAB_REACH)
	if hit.is_empty() or not hit.collider is Grabbable:
		return false
	if _asks_host():
		_cop.sync.request("grab")
		return false
	held = hit.collider
	hold_distance = clampf(eye.origin.distance_to(hit.position), GameScale.HOLD_MIN, GameScale.HOLD_MAX)
	held.hold(get_instance_id(), hold_point())
	return true


func release() -> void:
	if _asks_host():
		_cop.sync.request("release")
	if held:
		held.let_go(get_instance_id())
	held = null


func throw() -> void:
	if not held:
		return
	if _asks_host():
		_cop.sync.request("throw")
		held.let_go(get_instance_id())
		held = null
		return
	held.throw_toward(get_instance_id(), -_cop.camera.global_transform.basis.z)
	held = null
