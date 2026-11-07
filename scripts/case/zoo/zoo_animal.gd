class_name ZooAnimal
extends Node3D

## An animal of the zoo (escena-zoo.md, "La hora de comer"): the monkey, the ostrich or the elephant. In its enclosure
## ("in") it stands still. At feeding time its gate opens and it comes out ("loose") to wander the grounds. A cop
## holding a bucket of its food (FoodBucket: bananas, peanuts or hay) close by lures it ("following"), and walked to
## its gate it goes back in; then a cop shuts the gate (ZooGate). Not back by the next feeding time, it goes back by
## itself (Zoo.start_feeding). What each one gets up to while loose comes next. Every number here is (propuesta).

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

## "monkey", "ostrich" or "elephant".
var kind := "monkey"
var zoo: Zoo
## "in", "loose" or "following".
var state := "in"
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


## Back in its enclosure, in the middle.
func go_in() -> void:
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
	if bucket:
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
	if _flat(_to - position).length() < 0.3:
		_to = Vector3(_rng.randf_range(ROAM.position.x, ROAM.end.x), 0, _rng.randf_range(ROAM.position.y, ROAM.end.y))
	_walk(_to, WANDER_SPEED, delta)


## Walks toward `to`, in the zoo's space, facing where it goes.
func _walk(to: Vector3, speed: float, delta: float) -> void:
	var off := _flat(to - position)
	if off.length() < 0.01:
		return
	position += off.normalized() * minf(speed * delta, off.length())
	rotation.y = atan2(off.x, off.z)


static func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)
