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
	if not _has_target or cop.global_position.distance_to(at) > SNAP_DISTANCE:
		cop.global_position = at
		cop.global_rotation.y = yaw
	_has_target = true


func _follow(delta: float) -> void:
	var weight := 1.0 - exp(-EASE * delta)
	cop.global_position = cop.global_position.lerp(_target_position, weight)
	cop.global_rotation.y = lerp_angle(cop.global_rotation.y, _target_yaw, weight)
	cop.set_head_pitch(lerp_angle(cop.head_pitch(), _target_pitch, weight))
