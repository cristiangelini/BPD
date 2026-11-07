class_name ZooAnimal
extends Node3D

## An animal of the zoo (escena-zoo.md, "La hora de comer"): the monkey, the ostrich or the elephant. In its enclosure
## ("in") it stands still. At feeding time its gate opens and it comes out ("loose") to wander the grounds. A cop
## holding a bucket of its food (FoodBucket: bananas, peanuts or hay) close by lures it ("following"), and walked to
## its gate it goes back in; then a cop shuts the gate (ZooGate). Not back by the next feeding time, it goes back by
## itself (Zoo.start_feeding). While loose, each gets up to its own mischief: the monkey takes something lying around
## and keeps it until it's lured with bananas; the ostrich runs after the nearest cop and knocks them down; the
## elephant sprays water with its trunk now and then (Zoo.spray). Every number here is (propuesta).

const FOODS := {"monkey": "bananas", "ostrich": "peanuts", "elephant": "hay"}
const MODELS := {
	"monkey": preload("res://assets/models/animal_monkey.glb"),
	"ostrich": preload("res://assets/models/animal_avestruz.glb"),
	"elephant": preload("res://assets/models/animal_elefante.glb"),
}
## How fast it wanders and follows (m/s), how close a bucket lures it, how far from it it keeps, and how close to its
## gate's mouth it goes back in.
const WANDER_SPEED := 1.6
const FOLLOW_SPEED := 3.5
const LURE_REACH := 6.0
const KEEP := 1.2
const HOME_REACH := 1.8
## Where it wanders while loose: the grounds round the penguins, in the zoo's space.
const ROAM := Rect2(-11, -13, 22, 26)
## The monkey: how far it spots something to take, and how close it takes it.
const STEAL_REACH := 10.0
const TAKE_REACH := 0.8
## The ostrich: how far it sees a cop, how fast it runs, how close it knocks them down, for how long, and how long it
## rests after.
const CHASE_REACH := 10.0
const CHASE_SPEED := 4.5
const HIT_REACH := 0.9
const DOWN_SECONDS := 2.0
const KNOCK_PUSH := 5.0
const REST := 3.0
## The elephant: how often it sprays, how far ahead and how wide.
const SPRAY_EVERY := 5.0
const SPRAY_AHEAD := 2.5
const SPRAY_RADIUS := 3.0

## "monkey", "ostrich" or "elephant".
var kind := "monkey"
var zoo: Zoo
## "in", "loose" or "following".
var state := "in"
## What the monkey took (frozen in its hands), or null.
var carried: Grabbable
var _rest := 0.0
var _spray_clock := 0.0
var _to := Vector3.ZERO
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	var model: Node3D = MODELS[kind].instantiate()
	model.name = "Model"
	add_child(model)
	_rng.seed = hash(["zoo animal", kind])
	position = Zoo.pen_middle(kind)


## Its gate opened: out it comes, just outside it.
func release() -> void:
	state = "loose"
	position = Zoo.gate_mouth(kind)
	_to = position


## Back in its enclosure, in the middle (the monkey lets go of what it took).
func go_in() -> void:
	drop()
	state = "in"
	position = Zoo.pen_middle(kind)


## The bucket of its food a cop holds within LURE_REACH, or null.
func lure() -> FoodBucket:
	for bucket: FoodBucket in get_tree().get_nodes_in_group("food_buckets"):
		if bucket.holders.is_empty() or bucket.food != FOODS[kind]:
			continue
		if _flat(bucket.global_position - global_position).length() <= LURE_REACH:
			return bucket
	return null


func _process(delta: float) -> void:
	if state == "in":
		return
	var bucket := lure()
	state = "following" if bucket else "loose"
	if carried:
		carried.global_position = global_position + Vector3.UP * 0.9
	if bucket:
		drop()
		if _flat(Zoo.gate_mouth(kind) - position).length() <= HOME_REACH:
			go_in()
			if zoo:
				zoo.animal_back(self)
			return
		var held := get_parent_node_3d().to_local(bucket.global_position)
		var off := _flat(held - position)
		if off.length() > KEEP:
			_walk(position + off.normalized() * (off.length() - KEEP), FOLLOW_SPEED, delta)
		return
	_rest = maxf(_rest - delta, 0.0)
	match kind:
		"monkey":
			if _steal(delta):
				return
		"ostrich":
			if _chase(delta):
				return
		"elephant":
			_spray_clock += delta
			if _spray_clock >= SPRAY_EVERY:
				_spray_clock = 0.0
				if zoo:
					zoo.spray(global_position + global_transform.basis.z * SPRAY_AHEAD, SPRAY_RADIUS)
	if _flat(_to - position).length() < 0.3:
		_to = Vector3(_rng.randf_range(ROAM.position.x, ROAM.end.x), 0, _rng.randf_range(ROAM.position.y, ROAM.end.y))
	_walk(_to, WANDER_SPEED, delta)


## The monkey lets go of what it took.
func drop() -> void:
	if carried and is_instance_valid(carried):
		carried.freeze = false
	carried = null


## The monkey goes for the nearest thing lying around (not held, not Copito home, not a food bucket) and takes it.
## True while it's on its way.
func _steal(delta: float) -> bool:
	if carried:
		return false
	var best: Grabbable
	var best_away := STEAL_REACH
	for body: Node in get_tree().get_nodes_in_group("grabbables"):
		var item := body as Grabbable
		if not item or not item.holders.is_empty() or item.freeze or item is FoodBucket:
			continue
		var away := _flat(item.global_position - global_position).length()
		if away < best_away:
			best = item
			best_away = away
	if not best:
		return false
	if best_away <= TAKE_REACH:
		carried = best
		best.freeze = true
		# A clue not bagged yet is lost: the hair's cap goes up the tree, the cookie gets eaten.
		if best is CrimeClueItem and not (best as CrimeClueItem).bagged:
			(best as CrimeClueItem).wash()
		return false
	_walk(get_parent_node_3d().to_local(best.global_position), FOLLOW_SPEED, delta)
	return true


## The ostrich runs at the nearest cop and knocks them down (they drop what they hold). True while it runs.
func _chase(delta: float) -> bool:
	if _rest > 0.0:
		return false
	var best: Cop
	var best_away := CHASE_REACH
	for body: Node in get_tree().get_nodes_in_group("cops"):
		var cop := body as Cop
		var away := _flat(cop.global_position - global_position).length()
		if away < best_away and not cop.is_staggered():
			best = cop
			best_away = away
	if not best:
		return false
	if best_away <= HIT_REACH:
		knock_down(best)
		return false
	_walk(get_parent_node_3d().to_local(best.global_position), CHASE_SPEED, delta)
	return true


## Down for DOWN_SECONDS, shoved away, hands empty; then the ostrich rests a while.
func knock_down(cop: Cop) -> void:
	var away := _flat(cop.global_position - global_position).normalized()
	cop.get_node("Grabber").release()
	cop.knock_back(away * KNOCK_PUSH, DOWN_SECONDS)
	cop.show_hint("HINT_ZOO_OSTRICH")
	_rest = REST


## Walks toward `to`, in the zoo's space, facing where it goes.
func _walk(to: Vector3, speed: float, delta: float) -> void:
	var off := _flat(to - position)
	if off.length() < 0.01:
		return
	position += off.normalized() * minf(speed * delta, off.length())
	rotation.y = atan2(off.x, off.z)


static func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)
