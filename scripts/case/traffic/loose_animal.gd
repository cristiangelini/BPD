class_name LooseAnimal
extends Node3D

## A circus animal out of its open cage (control-circo.md, step 3): it hops down behind its truck and wanders round
## it. A cop holding a bucket of its food (FoodBucket) close by lures it: it follows the bucket, and once it's by its
## cage's door (CircusTruck.cage_mouth) it hops back in and the door shuts. Not back within
## CircusTruck.LOOSE_SECONDS, it runs off for good (`gone`). Every number here is (propuesta).

signal home
signal gone

## How fast it wanders, follows and runs off (m/s), how far from its truck it wanders and how close a bucket lures it.
const WANDER_SPEED := 2.0
const FOLLOW_SPEED := 3.5
const RUN_SPEED := 8.0
const ROAM := 7.0
const LURE_REACH := 6.0
## It keeps this far from the bucket it follows, and hops in this close to its cage's door.
const KEEP := 1.0
const HOME_REACH := 1.5
const RUN_FAR := 60.0

## Its truck (a QueueCar) and what it is (CircusTruck.ANIMALS).
var car: Node3D
var animal := "lion"
## "loose", "following", "home" or "gone".
var state := "loose"
## Online, a guest's copy only walks to where the host's is (`target`).
var follower := false
var target := Vector3.INF
var left := CircusTruck.LOOSE_SECONDS
var _to := Vector3.ZERO
var _run_dir := Vector3.ZERO
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("loose_animals")
	var model: Node3D = CircusTruck.ANIMAL_MODELS[maxi(CircusTruck.ANIMALS.find(animal), 0)].instantiate()
	model.name = "Model"
	add_child(model)
	_rng.seed = hash(["loose", name])
	_to = global_position


## The bucket of its food a cop holds within LURE_REACH, or null.
func lure() -> FoodBucket:
	for bucket: FoodBucket in get_tree().get_nodes_in_group("food_buckets"):
		if bucket.holders.is_empty() or bucket.food != CircusTruck.food_of(animal):
			continue
		if _flat(bucket.global_position - global_position).length() <= LURE_REACH:
			return bucket
	return null


func _process(delta: float) -> void:
	if state == "home":
		return
	if follower:
		if target != Vector3.INF:
			_walk(target, RUN_SPEED * 2.0, delta)
		return
	if state == "gone":
		_walk(global_position + _run_dir, RUN_SPEED, delta)
		if is_instance_valid(car) and _flat(global_position - car.global_position).length() > RUN_FAR:
			queue_free()
		return
	left -= delta
	if left <= 0.0:
		run_off()
		return
	if is_instance_valid(car) and _flat(CircusTruck.cage_mouth(car) - global_position).length() <= HOME_REACH \
			and state == "following":
		go_home()
		return
	var bucket := lure()
	state = "following" if bucket else "loose"
	if bucket:
		var off := _flat(bucket.global_position - global_position)
		if off.length() > KEEP:
			_walk(global_position + off.normalized() * (off.length() - KEEP), FOLLOW_SPEED, delta)
		return
	if _flat(_to - global_position).length() < 0.3 and is_instance_valid(car):
		var around := car.global_transform * Vector3(0, 0, -CircusTruck.CAGE_SIZE.z)
		_to = around + Vector3(_rng.randf_range(-ROAM, ROAM), 0, _rng.randf_range(-ROAM, ROAM))
		_to.y = car.global_position.y
	_walk(_to, WANDER_SPEED, delta)


## Back in its cage: the truck takes it in and shuts the door.
func go_home() -> void:
	state = "home"
	home.emit()
	queue_free()


## Off for good, away from its truck.
func run_off() -> void:
	state = "gone"
	_run_dir = _flat(global_position - car.global_position).normalized() if is_instance_valid(car) else Vector3.FORWARD
	if _run_dir == Vector3.ZERO:
		_run_dir = Vector3.FORWARD
	gone.emit()


func _walk(to: Vector3, speed: float, delta: float) -> void:
	var off := _flat(to - global_position)
	if off.length() < 0.01:
		return
	global_position += off.normalized() * minf(speed * delta, off.length())
	look_at(global_position + off, Vector3.UP, true)


static func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)
