class_name CopSync
extends Node

## Keeps one cop the same on every PC (docs/diseno/online.md, "Qué se sincroniza"): its owner sends where it is about
## 20 times a second and the others ease their copy toward it. Lives under the Net autoload as "Cop<peer id>", so its
## path is the same everywhere whatever the level calls the cop.

const SEND_RATE := 20.0
## How fast a copy catches up with the last state it got (propuesta).
const EASE := 15.0
## A copy further than this from where it should be jumps there instead of sliding (a respawn, getting out of a car).
const SNAP_DISTANCE := 4.0

var cop: Cop
## The Net that owns this sync: it knows which peers have the level loaded.
var net: Node
var _send_left := 0.0
var _target_position := Vector3.ZERO
var _target_yaw := 0.0
var _target_pitch := 0.0
var _has_target := false


func _init(synced_cop: Cop, owner_net: Node, peer_id: int) -> void:
	cop = synced_cop
	net = owner_net
	name = "Cop%d" % peer_id
	set_multiplayer_authority(peer_id)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(cop) or not cop.is_inside_tree():
		return
	if is_multiplayer_authority():
		_send_left -= delta
		if _send_left <= 0.0:
			_send_left = 1.0 / SEND_RATE
			send_state()
	elif _has_target:
		_follow(delta)


## Sends this cop's state to every peer that has the level loaded.
func send_state() -> void:
	var state := [cop.global_position, cop.global_rotation.y, cop.head_pitch(), cop.is_crouching]
	for peer: int in net.scene_peers:
		_state.rpc_id(peer, state[0], state[1], state[2], state[3])


@rpc("authority", "call_remote", "unreliable_ordered")
func _state(at: Vector3, yaw: float, pitch: float, crouching: bool) -> void:
	_target_position = at
	_target_yaw = yaw
	_target_pitch = pitch
	cop.set_crouching(crouching)
	if cop.vehicle:
		# A seated cop rides the car, which the host moves for everyone.
		_has_target = true
		return
	if not _has_target or cop.global_position.distance_to(at) > SNAP_DISTANCE:
		cop.global_position = at
		cop.global_rotation.y = yaw
	_has_target = true


func _follow(delta: float) -> void:
	var weight := 1.0 - exp(-EASE * delta)
	cop.set_head_pitch(lerp_angle(cop.head_pitch(), _target_pitch, weight))
	if cop.vehicle:
		return
	cop.global_position = cop.global_position.lerp(_target_position, weight)
	cop.global_rotation.y = lerp_angle(cop.global_rotation.y, _target_yaw, weight)


## Owner on a guest: asks the host to do `action` with this cop's hands ("grab", "release", "throw", "closer",
## "farther"). The host does it with its copy of the cop, which looks where this one looks.
func request(action: String) -> void:
	_act.rpc_id(net.HOST_ID, action)


@rpc("any_peer", "call_remote", "reliable")
func _act(action: String) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != get_multiplayer_authority():
		return
	var grabber: Grabber = cop.get_node("Grabber")
	match action:
		"grab":
			grabber.try_grab()
		"release":
			grabber.release()
		"throw":
			grabber.throw()
		"closer", "farther":
			grabber.nudge(action == "closer")
	_held.rpc_id(get_multiplayer_authority(), net.props.index_of(grabber.held) if net.props else -1)


## The host says what this cop holds now (-1: nothing), so the owner's hands and prompts show it.
@rpc("any_peer", "call_remote", "reliable")
func _held(index: int) -> void:
	if multiplayer.get_remote_sender_id() != net.HOST_ID:
		return
	(cop.get_node("Grabber") as Grabber).held = net.props.prop_at(index) as Grabbable if net.props else null


## Host: shows `key` on the owner's screen (something only the host saw happen, like a heavy loaf in its hands).
func tell_hint(key: String) -> void:
	_hint.rpc_id(get_multiplayer_authority(), key)


@rpc("any_peer", "call_remote", "reliable")
func _hint(key: String) -> void:
	if multiplayer.get_remote_sender_id() == net.HOST_ID:
		cop.show_hint(key)


## Owner driving on a guest: sends the car's controls to the host every physics step; the host drives the car
## for everyone.
func send_controls(throttle: float, steer: float, handbrake: bool) -> void:
	if not net.is_host():
		_controls.rpc_id(net.HOST_ID, throttle, steer, handbrake)


@rpc("authority", "call_remote", "unreliable_ordered")
func _controls(throttle: float, steer: float, handbrake: bool) -> void:
	if multiplayer.is_server() and cop.vehicle and cop.vehicle.driver() == cop:
		cop.vehicle.drive(throttle, steer, handbrake)
