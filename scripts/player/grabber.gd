class_name Grabber
extends Node

## Lets its cop grab what the camera points at: hold left click to carry, right click to throw,
## mouse wheel to bring it closer or push it away. Something small flying past (the "catchables" group: the rally's
## eggs and tomatoes) is caught when it's within CATCH_REACH of the hands and in front of the eyes, without aiming at
## it exactly. A football at the cop's feet is kicked instead: left click, held longer for a harder kick (FootballBall).

const CATCH_REACH := 1.2
const CATCH_ANGLE := 35.0

@export var input_enabled := true

var held: Grabbable
var hold_distance := GameScale.HOLD_MAX
## The ball being kicked while the click is held, and for how long it's held.
var kicking: FootballBall
var kick_held := 0.0

@onready var _cop: Cop = get_parent()


func _physics_process(delta: float) -> void:
	if input_enabled:
		if Input.is_action_just_pressed("grab"):
			if not start_kick():
				try_grab()
		elif Input.is_action_just_released("grab"):
			if kicking:
				end_kick()
			else:
				release()
		elif Input.is_action_just_pressed("throw"):
			throw()
	if held:
		held.hold(get_instance_id(), hold_point())
	if kicking:
		kick_held += delta


## Left click with a football at the feet and the hands free: the kick starts charging. Returns true if it did.
func start_kick() -> bool:
	if held or _cop.ram or _cop.wheelbarrow or _cop.belt.held_tool() or _cop.is_cuffed() or _cop.is_busy():
		return false
	kicking = FootballBall.near_feet(_cop)
	kick_held = 0.0
	return kicking != null


## Click let go: kicks where the camera looks, harder the longer it was held.
func end_kick() -> void:
	var ball := kicking
	kicking = null
	if is_instance_valid(ball) and ball.at_feet(_cop):
		_cop.act("kick", ball, [_cop, FootballBall.aim(-_cop.camera.global_basis.z), FootballBall.power_for(kick_held)])


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
	hold_distance = clampf(hold_distance + (-0.25 if closer else 0.25), closest(), GameScale.HOLD_MAX)


## How close to the eyes what it holds can come: a piece of disguise, right up to the face.
func closest() -> float:
	return DisguisePiece.HOLD_CLOSE if held is DisguisePiece else GameScale.HOLD_MIN


## Online on a guest: the host moves the props, so this cop's hands are only asked of it (docs/diseno/online.md).
func _asks_host() -> bool:
	return _cop.sync != null and _cop.sync.is_multiplayer_authority() and not _cop.sync.net.is_host()


func hold_point() -> Vector3:
	var eye := _cop.camera.global_transform
	return eye.origin - eye.basis.z * hold_distance


## Grabs the object in front of the camera within reach. Returns true if it got one.
func try_grab() -> bool:
	if _cop.ram or _cop.wheelbarrow or _cop.leash or _cop.belt.held_tool() or _cop.is_cuffed() or _cop.is_busy() or _cop.is_eating():
		return false
	var eye := _cop.camera.global_transform
	var hit := _cop.aim_hit(GameScale.GRAB_REACH)
	if hit.is_empty() or not hit.collider is Grabbable:
		var flying := catchable_near()
		if not flying:
			return false
		hit = {"collider": flying, "position": flying.global_position}
	if _asks_host():
		_cop.sync.request("grab")
		return false
	held = hit.collider
	hold_distance = clampf(eye.origin.distance_to(hit.position), GameScale.HOLD_MIN, GameScale.HOLD_MAX)
	held.hold(get_instance_id(), hold_point())
	return true


## A catchable within CATCH_REACH of the hands and within CATCH_ANGLE of where the eyes look, the nearest one.
func catchable_near() -> Grabbable:
	var eye := _cop.camera.global_transform
	var hands := hold_point()
	var best: Grabbable = null
	for body: Node3D in get_tree().get_nodes_in_group("catchables"):
		var to := body.global_position - eye.origin
		if body is Grabbable and not (body as Grabbable).is_held() and body.global_position.distance_to(hands) < CATCH_REACH \
				and (-eye.basis.z).angle_to(to) < deg_to_rad(CATCH_ANGLE) \
				and (not best or body.global_position.distance_to(hands) < best.global_position.distance_to(hands)):
			best = body
	return best


## Puts `body` in this cop's hands, as if grabbed from where it is (things handed out, like the armory's).
func grab(body: Grabbable) -> void:
	release()
	held = body
	hold_distance = GameScale.HOLD_MIN
	held.hold(get_instance_id(), hold_point())


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
