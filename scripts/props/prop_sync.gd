class_name PropSync
extends Node

## Keeps the level's physics objects the same on every PC (docs/diseno/online.md, "Qué se sincroniza"): the host
## simulates every Grabbable and sends where the ones that moved are, about 20 times a second; the guests' copies are
## frozen and ease toward it. A prop that breaks on the host (an ornament) breaks on everyone. Levels build the same
## from the same seed, so each prop is known by its place in the level's list. Lives under the Net autoload as "Props".

const SEND_RATE := 20.0
const EASE := 18.0
## A copy further than this from where it should be jumps there instead of sliding.
const SNAP_DISTANCE := 3.0
## A prop that moved less than this since it was last sent isn't sent again (m).
const MOVED := 0.002
## At most this many props per packet, so a packet fits the network's MTU (about 1400 bytes).
const PER_PACKET := 20

## The Net that owns this sync: it knows which peers have the level loaded and who hosts.
var net: Node
var props: Array[Grabbable] = []
## Index -> transform last sent (host).
var _sent := {}
## Index -> transform to ease toward (guests).
var _targets := {}
## Indices of props that are gone, so it's only said once (host) or done once (guests).
var _gone := {}
var _send_left := 0.0


func _init(owner_net: Node, level: Node) -> void:
	net = owner_net
	name = "Props"
	for node in level.find_children("*", "Grabbable", true, false):
		props.append(node as Grabbable)


func _ready() -> void:
	if net.is_host():
		return
	for prop in props:
		# A frozen copy: no physics of its own, no hits, nothing that moves it but the host.
		prop.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		prop.freeze = true
		prop.contact_monitor = false
		prop.set_physics_process(false)


func index_of(prop: Grabbable) -> int:
	return props.find(prop) if prop else -1


## The prop at `index`, or null if there is none (or it's gone).
func prop_at(index: int) -> Grabbable:
	if index < 0 or index >= props.size() or not is_instance_valid(props[index]):
		return null
	return props[index]


## Host: sends every prop to `peer` on the next send, reliably (a peer that just loaded the level).
func resend_all(peer: int) -> void:
	var ids := PackedInt32Array()
	var places: Array[Transform3D] = []
	for i in props.size():
		if prop_at(i) and props[i].is_inside_tree():
			ids.append(i)
			places.append(props[i].global_transform)
	_moved_all.rpc_id(peer, ids, places, PackedInt32Array(_gone.keys()))


func _physics_process(delta: float) -> void:
	if net.is_host():
		_send_left -= delta
		if _send_left <= 0.0:
			_send_left = 1.0 / SEND_RATE
			_send()
	else:
		_follow(delta)


func _send() -> void:
	var ids := PackedInt32Array()
	var places: Array[Transform3D] = []
	var gone := PackedInt32Array()
	for i in props.size():
		var prop := prop_at(i)
		if not prop or not prop.is_inside_tree() or (prop is Ornament and (prop as Ornament).is_broken):
			if not _gone.has(i):
				_gone[i] = true
				gone.append(i)
			continue
		var place := prop.global_transform
		if _sent.has(i) and (_sent[i] as Transform3D).origin.distance_to(place.origin) < MOVED \
				and (_sent[i] as Transform3D).basis.is_equal_approx(place.basis):
			continue
		_sent[i] = place
		ids.append(i)
		places.append(place)
	for peer: int in net.scene_peers:
		for from in range(0, ids.size(), PER_PACKET):
			_moved.rpc_id(peer, ids.slice(from, from + PER_PACKET), places.slice(from, from + PER_PACKET))
		if not gone.is_empty():
			_removed.rpc_id(peer, gone)


@rpc("authority", "call_remote", "unreliable_ordered")
func _moved(ids: PackedInt32Array, places: Array) -> void:
	for n in ids.size():
		_set_target(ids[n], places[n])


@rpc("authority", "call_remote", "reliable")
func _moved_all(ids: PackedInt32Array, places: Array, gone: PackedInt32Array) -> void:
	_moved(ids, places)
	_removed(gone)


@rpc("authority", "call_remote", "reliable")
func _removed(gone: PackedInt32Array) -> void:
	for i in gone:
		var prop := prop_at(i)
		if _gone.has(i) or not prop:
			continue
		_gone[i] = true
		_targets.erase(i)
		if prop is Ornament:
			(prop as Ornament).hit(INF)
		else:
			prop.queue_free()


func _set_target(index: int, place: Transform3D) -> void:
	var prop := prop_at(index)
	if not prop:
		return
	if not _targets.has(index) or prop.global_position.distance_to(place.origin) > SNAP_DISTANCE:
		prop.global_transform = place
	_targets[index] = place


func _follow(delta: float) -> void:
	var weight := 1.0 - exp(-EASE * delta)
	for index: int in _targets:
		var prop := prop_at(index)
		if not prop:
			continue
		var target: Transform3D = _targets[index]
		prop.global_transform = prop.global_transform.interpolate_with(target, weight)
