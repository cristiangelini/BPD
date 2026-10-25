class_name CitySync
extends Node

## The living city the same on every PC (ciudad-viva.md, step 11). Every PC runs its own cars and walkers from the
## same dice (CityTraffic's seed), so they start alike; twice a second the host sends its clock, its rain and where
## every car and walker is, and the guests' copies slide back there. Only the host's director starts street events:
## a guest gets an empty copy of each event with the same name, so the people in it (NpcSync's) land at the same path
## and the cuffs find them; what the host pays shows on every PC. Lives under the Net autoload as "City".
## Every number here is (propuesta).

const SEND_EVERY := 0.5
## A copy further than this from the host's jumps there instead of sliding.
const SNAP := 4.0
## How fast (per second) a copy slides back.
const PULL_RATE := 3.0
## Cars and walkers per packet, so each stays under a packet's size.
const PER_PACKET := 48

var net: Node
var city: City
var _level: Node
var _hooked := false
var _send_left := 0.0


func _init(owner_net: Node, level: Node) -> void:
	net = owner_net
	_level = level
	name = "City"
	# The test city is its own level; a case's city is inside it.
	var found := [level] if level is City else level.find_children("*", "City", true, false)
	city = found[0] if not found.is_empty() else null


func _physics_process(delta: float) -> void:
	if not city or not is_instance_valid(city):
		return
	# The city builds its traffic and events a frame after the level opens.
	if not _hooked:
		_hook()
	if not net.is_host():
		return
	_send_left -= delta
	if _send_left > 0.0:
		return
	_send_left = SEND_EVERY
	var state := snapshot()
	for peer: int in net.scene_peers:
		_weather.rpc_id(peer, state.slice(0, 4))
		var spots: PackedVector3Array = state[4]
		for from in range(0, spots.size(), PER_PACKET):
			_moved.rpc_id(peer, from, (state[4] as PackedVector3Array).slice(from, from + PER_PACKET),
				(state[5] as PackedInt32Array).slice(from, from + PER_PACKET),
				(state[6] as PackedFloat32Array).slice(from, from + PER_PACKET), _lines_in(state[7], from))


func _hook() -> void:
	if not city.events and city.get_node_or_null("Built/Traffic") == null:
		return
	_hooked = true
	if not city.events:
		return
	if net.is_host():
		city.events.paid.connect(_on_paid)
		city.events.started.connect(_on_started)
	else:
		city.events.director = false


## The cars and walkers of the city's own traffic (not the ones a street event brought), in the same order on every PC.
func traffic() -> Array[Node3D]:
	var bodies: Array[Node3D] = []
	var moving := city.get_node_or_null("Built/Traffic")
	if not moving:
		return bodies
	for body in moving.get_children():
		if body is CityCar or (body is CityWalker and not body is CrashDriver):
			bodies.append(body as Node3D)
	return bodies


## The host's city: [hour, rain start, rain length, rain time, positions, next points, walkers' stops, what they say].
func snapshot() -> Array:
	var spots := PackedVector3Array()
	var nexts := PackedInt32Array()
	var stops := PackedFloat32Array()
	var lines := {}
	for body in traffic():
		spots.append(body.position)
		nexts.append(body.get("next"))
		if body is CityWalker:
			var walker := body as CityWalker
			stops.append(walker.stopped_left())
			if walker.saying() != "":
				lines[spots.size() - 1] = walker.saying()
		else:
			stops.append(0.0)
	var hour := city.clock.hour if city.clock else -1.0
	var rain := [city.rain.start, city.rain.length, city.rain.time] if city.rain else [0.0, 0.0, -1.0]
	return [hour, rain[0], rain[1], rain[2], spots, nexts, stops, lines]


## A guest: the host's city (a whole snapshot()).
func apply(state: Array) -> void:
	apply_weather(state.slice(0, 4))
	apply_traffic(0, state[4], state[5], state[6], state[7])


## A guest: the host's hour and rain ([hour, rain start, rain length, rain time]).
func apply_weather(weather: Array) -> void:
	if city.clock and weather[0] >= 0.0:
		city.clock.hour = weather[0]
	if city.rain and weather[3] >= 0.0:
		city.rain.start = weather[1]
		city.rain.length = weather[2]
		city.rain.time = weather[3]


## A guest: where the host has its cars and walkers, from number `from` of traffic() on.
func apply_traffic(from: int, spots: PackedVector3Array, nexts: PackedInt32Array, stops: PackedFloat32Array,
		lines: Dictionary) -> void:
	var bodies := traffic()
	for k in spots.size():
		var i := from + k
		if i >= bodies.size():
			return
		if bodies[i] is CityWalker:
			(bodies[i] as CityWalker).net_pull(spots[k], nexts[k], stops[k], lines.get(i, ""))
		else:
			(bodies[i] as CityCar).net_pull(spots[k], nexts[k])


static func _lines_in(lines: Dictionary, from: int) -> Dictionary:
	var some := {}
	for i: int in lines:
		if i >= from and i < from + PER_PACKET:
			some[i] = lines[i]
	return some


@rpc("authority", "call_remote", "unreliable_ordered")
func _weather(weather: Array) -> void:
	if city and is_instance_valid(city):
		apply_weather(weather)


@rpc("authority", "call_remote", "unreliable_ordered")
func _moved(from: int, spots: PackedVector3Array, nexts: PackedInt32Array, stops: PackedFloat32Array,
		lines: Dictionary) -> void:
	if city and is_instance_valid(city):
		apply_traffic(from, spots, nexts, stops, lines)


func _on_paid(money: int) -> void:
	for peer: int in net.scene_peers:
		_paid.rpc_id(peer, money)


@rpc("authority", "call_remote", "reliable")
func _paid(money: int) -> void:
	if city and city.events:
		city.events.show_paid(money)


## Host: an event began; the guests make its empty copy before its people's copies come (NpcSync, also reliable).
func _on_started(event: CityEvent) -> void:
	for peer: int in net.scene_peers:
		_started.rpc_id(peer, String(event.name))
	event.tree_exiting.connect(_on_ended.bind(String(event.name)))


func _on_ended(event_name: String) -> void:
	if not is_inside_tree():
		return
	for peer: int in net.scene_peers:
		_ended.rpc_id(peer, event_name)


@rpc("authority", "call_remote", "reliable")
func _started(event_name: String) -> void:
	if not city or not city.events or city.events.has_node(event_name):
		return
	var copy := Node3D.new()
	copy.name = event_name
	city.events.add_child(copy)


@rpc("authority", "call_remote", "reliable")
func _ended(event_name: String) -> void:
	var copy := city.events.get_node_or_null(event_name) if city and city.events else null
	if copy:
		copy.queue_free()


## How far a copy at `body` has to slide to `to`: nothing when it jumps there instead.
static func pull(body: Node3D, to: Vector3) -> Vector3:
	if body.position.distance_to(to) > SNAP:
		body.position = to
		return Vector3.ZERO
	return to - body.position


## Slides `body` part of `left` this frame; returns what's still left.
static func slide(body: Node3D, left: Vector3, delta: float) -> Vector3:
	if left == Vector3.ZERO:
		return left
	var take := left * minf(PULL_RATE * delta, 1.0)
	body.position += take
	return left - take
