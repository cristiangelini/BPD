class_name NurseryDentuda
extends Node

## The Dentuda, the greenhouse's giant carnivorous plant (docs/diseno/allanamiento-vivero.md, "El riego y la Dentuda",
## step 3): once every BITE_EVERY seconds she bites what comes within REACH of her mouth. A thing (thrown, carried or
## moving; what lies still in her pot she leaves alone) she swallows and spits far after HOLD_SECONDS. A cop holding
## something loses it to her the same way; a cop with empty hands is pushed back. Something to eat (the "dentuda_food"
## group: the fertilizer bags) she eats for good and calms down for CALM_SECONDS. Every number here is (propuesta).

## She bit a cop or a thing (Doña Hortensia sees it, step 4).
signal bitten(target: Node3D)
## She ate something and calmed down.
signal fed

const REACH := 1.5
const BITE_EVERY := 3.0
const HOLD_SECONDS := 5.0
const CALM_SECONDS := 10.0
## Things moving slower than STILL_SPEED and held by no one are lying still: she doesn't bite those.
const STILL_SPEED := 0.3
## She spits at SPIT_SPEED, toward where she faces, a little up; a cop with empty hands gets PUSH for PUSH_SECONDS.
const SPIT_SPEED := 7.0
const PUSH := 4.0
const PUSH_SECONDS := 0.5
const FOOD_GROUP := "dentuda_food"
## What she just spat she doesn't bite again for SPAT_SECONDS (else she'd catch it on its way out).
const SPAT_SECONDS := 2.0

var nursery: Nursery
## Her mouth (global) and where she faces, flat.
var mouth := Vector3.ZERO
var facing := Vector3.LEFT
## The plant's look, which snaps when she bites.
var plant: Node3D
var bite_left := 0.0
var calm_left := 0.0
var bites := 0
## What she has in her mouth: [body, seconds left, its collision layer].
var swallowed: Array = []
## What she spat lately (instance id -> seconds left).
var _spat := {}
## Online, on a guest: what the host's Dentuda has in her mouth, hidden here.
var _hidden_here: Array[NodePath] = []


func is_calm() -> bool:
	return calm_left > 0.0


## Online she's the host's: she bites there, and the guests' Dentuda follows (apply_net_state).
func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		tick(delta)


## Online, what the guests' Dentuda takes from the host's: her bites (she snaps there too), how calm she is and what
## she has in her mouth (hidden there too), by its path in the nursery.
func net_state() -> Array:
	var inside: Array[NodePath] = []
	for entry: Array in swallowed:
		if is_instance_valid(entry[0]):
			inside.append(nursery.get_path_to(entry[0]))
	return [bites, calm_left, inside]


func apply_net_state(state: Array) -> void:
	if state[0] > bites:
		_snap()
	bites = state[0]
	calm_left = state[1]
	for path: NodePath in _hidden_here:
		var body := nursery.get_node_or_null(path) as Node3D
		if body and not state[2].has(path):
			body.show()
	_hidden_here.clear()
	for path: NodePath in state[2]:
		var body := nursery.get_node_or_null(path) as Node3D
		if body:
			body.hide()
			_hidden_here.append(path)


## Moves her on by `delta` seconds: spits what's due and, if she isn't calm or still chewing, bites what's close.
func tick(delta: float) -> void:
	bite_left = maxf(bite_left - delta, 0.0)
	calm_left = maxf(calm_left - delta, 0.0)
	for id: int in _spat.keys():
		_spat[id] -= delta
		if _spat[id] <= 0.0:
			_spat.erase(id)
	for entry: Array in swallowed.duplicate():
		entry[1] -= delta
		if entry[1] <= 0.0:
			swallowed.erase(entry)
			_spit(entry[0], entry[2])
	if bite_left > 0.0 or is_calm():
		return
	var target := closest_target()
	if target:
		bite(target)


## Whether `at` (global) is within her reach: REACH around her mouth, flat, and not far above it.
func in_reach(at: Vector3) -> bool:
	var off := at - mouth
	if off.y > 0.6:
		return false
	off.y = 0.0
	return off.length() <= REACH


## The closest cop or loose thing in her reach that she would bite, or null.
func closest_target() -> Node3D:
	var best: Node3D = null
	var best_far := INF
	var candidates: Array[Node3D] = []
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop and nursery.is_ancestor_of(cop) and not cop.is_staggered():
			candidates.append(cop)
	for node in nursery.find_children("*", "RigidBody3D", true, false):
		var body := node as RigidBody3D
		if body.freeze or body.is_queued_for_deletion() or _spat.has(body.get_instance_id()):
			continue
		if not _in_mouth(body) and _moving(body):
			candidates.append(body)
	for candidate in candidates:
		if not in_reach(candidate.global_position):
			continue
		var far := candidate.global_position.distance_to(mouth)
		if far < best_far:
			best = candidate
			best_far = far
	return best


## She bites `target`: food she eats, a thing she swallows, a cop loses what it holds or gets pushed back.
func bite(target: Node3D) -> void:
	bite_left = BITE_EVERY
	bites += 1
	_snap()
	bitten.emit(target)
	var cop := target as Cop
	if cop:
		var held := (cop.get_node("Grabber") as Grabber).held
		if held:
			Nursery.empty_hands(cop)
			cop.show_hint("HINT_NURSERY_DENTUDA_TOOK")
			_take(held)
		else:
			var away := cop.global_position - mouth
			away.y = 0.0
			Nursery.shove(cop, (away.normalized() if away.length() > 0.01 else -facing) * PUSH, PUSH_SECONDS)
			cop.show_hint("HINT_NURSERY_DENTUDA_PUSH")
		return
	var body := target as RigidBody3D
	if body is Grabbable:
		for holder_id: int in (body as Grabbable).holders.keys():
			var grabber := instance_from_id(holder_id) as Grabber
			if grabber and grabber.get_parent() is Cop:
				Nursery.empty_hands(grabber.get_parent() as Cop)
			elif grabber:
				grabber.release()
	if body:
		_take(body)


## Swallows `body` (or eats it for good if it's food).
func _take(body: RigidBody3D) -> void:
	if body.is_in_group(FOOD_GROUP):
		calm_left = CALM_SECONDS
		body.remove_from_group(FOOD_GROUP)
		body.queue_free()
		fed.emit()
		return
	swallowed.append([body, HOLD_SECONDS, body.collision_layer])
	body.freeze = true
	body.collision_layer = 0
	body.hide()
	body.global_position = mouth


func _spit(body: RigidBody3D, layer: int) -> void:
	if not is_instance_valid(body):
		return
	body.global_position = mouth + facing * 0.6
	body.collision_layer = layer
	body.show()
	body.freeze = false
	body.linear_velocity = (facing + Vector3.UP * 0.6).normalized() * SPIT_SPEED
	_spat[body.get_instance_id()] = SPAT_SECONDS
	_snap()


func _in_mouth(body: RigidBody3D) -> bool:
	for entry: Array in swallowed:
		if entry[0] == body:
			return true
	return false


func _moving(body: RigidBody3D) -> bool:
	if body is Grabbable and (body as Grabbable).is_held():
		return true
	return body.linear_velocity.length() > STILL_SPEED


## The plant lunges and snaps its jaws.
func _snap() -> void:
	if not plant or not plant.is_inside_tree():
		return
	var snap := plant.create_tween()
	snap.tween_property(plant, "scale", Vector3(1.15, 0.85, 1.15), 0.08)
	snap.tween_property(plant, "scale", Vector3.ONE, 0.25)
