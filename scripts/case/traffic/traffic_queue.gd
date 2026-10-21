class_name TrafficQueue
extends Node3D

## The cars that come to the traffic control and their patience (control-transito.md, "Cómo es el caso", steps 3 and
## 6). Once the checkpoint is set up, a car comes down the lane every SPAWN_EVERY seconds and joins the queue. Each car
## waiting adds to the patience meter; at FULL the first one sneaks by along the sidewalk and the meter drops a bit.
## E on the barrier lets the first one through. There's no time limit (decision 98): only the meter.
## "rush_hour" (Hora pico) sends twice the cars and wears the patience out faster. Every number here is (propuesta).

signal patience_changed(value: float)
## A car went by: let through, or sneaking.
signal passed(car: QueueCar, sneaked: bool)

const SPAWN_EVERY := 6.0
## Cars start this far up the lane from the checkpoint.
const SPAWN_FROM := 70.0
## No new car while the queue's last one is this close to where they start.
const SPAWN_ROOM := 8.0
const FULL := 100.0
## Per waiting car, per second.
const PATIENCE_PER_CAR := 0.5
## Per second with nobody waiting.
const CALM_DOWN := 2.0
## After a car sneaks by, the meter drops back to this.
const AFTER_SNEAK := 70.0
const VARIANTS := {
	"rush_hour": {"spawn": 0.5, "patience": 1.5},
}

var checkpoint: TrafficCheckpoint
var variant := "rush_hour"
var case_seed := 1
var patience := 0.0
## In the order they came, the first one first.
var cars: Array[QueueCar] = []
var spawned := 0
var _until_spawn := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = hash(["traffic queue", case_seed])
	for barrier: RoadBarrier in get_tree().get_nodes_in_group("road_barriers"):
		barrier.lifted.connect(func(_cop: Cop) -> void: release_front())


func spawn_every() -> float:
	return SPAWN_EVERY * float(VARIANTS[variant].spawn)


func waiting_count() -> int:
	return cars.filter(func(car: QueueCar) -> bool: return car.waiting()).size()


func front() -> QueueCar:
	return cars[0] if not cars.is_empty() else null


func release_front() -> void:
	var car := front()
	if car:
		car.let_through()
		_leave(car, false)


func _physics_process(delta: float) -> void:
	if not checkpoint or not checkpoint.ready_now:
		return
	_until_spawn -= delta
	if _until_spawn <= 0.0 and _room_to_spawn():
		_until_spawn = spawn_every()
		spawn()
	# A car that went by on its own (the barrier was off the lane) leaves the queue too.
	for car in cars.duplicate():
		if not is_instance_valid(car) or car.at.z < -TrafficCheckpoint.ZONE.y:
			_leave(car, false)
	var waiting := waiting_count()
	if waiting > 0:
		_set_patience(patience + waiting * PATIENCE_PER_CAR * float(VARIANTS[variant].patience) * delta)
	else:
		_set_patience(patience - CALM_DOWN * delta)
	if patience >= FULL and front():
		var car := front()
		car.sneak()
		_leave(car, true)
		_set_patience(AFTER_SNEAK)


func _room_to_spawn() -> bool:
	return cars.is_empty() or cars.back().at.z < SPAWN_FROM - SPAWN_ROOM


func spawn() -> QueueCar:
	var car := QueueCar.new()
	car.name = "QueueCar%d" % spawned
	car.checkpoint = checkpoint
	car.look = _rng.randi()
	car.driver = DriverTraits.draw(_rng)
	car.at = Vector3(0, 0, SPAWN_FROM)
	car.speed = QueueCar.SPEED
	car.ahead = cars.back() if not cars.is_empty() else null
	spawned += 1
	cars.append(car)
	add_child(car)
	return car


func _leave(car: QueueCar, sneaked: bool) -> void:
	var i := cars.find(car)
	if i < 0:
		return
	cars.remove_at(i)
	if i < cars.size():
		cars[i].ahead = cars[i - 1] if i > 0 else null
	if is_instance_valid(car):
		passed.emit(car, sneaked)


func _set_patience(value: float) -> void:
	value = clampf(value, 0.0, FULL)
	if value != patience:
		patience = value
		patience_changed.emit(patience)
