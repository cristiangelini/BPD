class_name WindUpRig
extends Node

## The toy store's shelves full of wind-up toys (allanamiento-jugueteria.md, "Lo que se dispara"): a cop who bumps a
## shelf moving faster than BUMP_SPEED sets off PER_BUMP of its toys, which walk off chirping (WindUpToy). Each shelf
## holds PER_SHELF. Every release is heard all over the salon: don Cucho listens for it (step 3). Every number here is
## (propuesta).

## A shelf let toys loose at `at`: the noise the owner hears.
signal released(shelf: int, at: Vector3)

const PER_SHELF := 6
const PER_BUMP := 3
const BUMP_SPEED := 2.0
## How close to a shelf's side a cop's center must be to bump it (a bit over the cop's 0.5 m radius: once it touches
## the shelf it stops), and how long a shelf waits before it can go off again.
const BUMP_RANGE := 0.75
const COOLDOWN := 2.0
const COLORS: Array[Color] = [Color(0.91, 0.29, 0.23), Color(0.95, 0.76, 0.19), Color(0.23, 0.54, 0.91),
	Color(0.3, 0.72, 0.4), Color(0.85, 0.4, 0.7)]

var store: ToyStore
## Toys still on each shelf, and every toy let loose so far.
var left: Array[int] = []
var toys: Array[WindUpToy] = []
var _wait: Array[float] = []
var _rng := RandomNumberGenerator.new()


func setup(the_store: ToyStore) -> void:
	store = the_store
	_rng.seed = store.case_seed
	for i in ToyStore.SHELVES.size():
		left.append(PER_SHELF)
		_wait.append(0.0)


func _physics_process(delta: float) -> void:
	for i in _wait.size():
		_wait[i] = maxf(_wait[i] - delta, 0.0)
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop.vehicle:
			continue
		var shelf := bumped_shelf(cop.global_position, cop.velocity)
		if shelf >= 0:
			release(shelf)


## The shelf a cop at `at` moving at `velocity` bumps, or -1.
func bumped_shelf(at: Vector3, velocity: Vector3) -> int:
	if Vector2(velocity.x, velocity.z).length() <= BUMP_SPEED:
		return -1
	for i in ToyStore.SHELVES.size():
		var shelf: Vector3 = ToyStore.SHELVES[i]
		var reach := ToyStore.SHELF_SIZE / 2 + Vector3.ONE * BUMP_RANGE
		if absf(at.x - shelf.x) < reach.x and absf(at.z - shelf.z) < reach.z and at.y < shelf.y + reach.y * 2:
			return i
	return -1


## Lets PER_BUMP toys of shelf `i` loose (fewer if it's running out), once every COOLDOWN.
func release(i: int) -> void:
	if left[i] <= 0 or _wait[i] > 0.0:
		return
	_wait[i] = COOLDOWN
	var count := mini(PER_BUMP, left[i])
	left[i] -= count
	var shelf: Vector3 = ToyStore.SHELVES[i]
	for k in count:
		var side := 1.0 if _rng.randf() < 0.5 else -1.0
		var toy := WindUpToy.new()
		toy.color = COLORS[_rng.randi() % COLORS.size()]
		toy.position = shelf + Vector3(_rng.randf_range(-1.2, 1.2), 0.0, side * (ToyStore.SHELF_SIZE.z / 2 + 0.2))
		store.add_child(toy)
		toy.start(Vector3(_rng.randf_range(-0.6, 0.6), 0, side))
		toys.append(toy)
	store.say(shelf + Vector3(0, ToyStore.SHELF_SIZE.y + 0.5, 0), "TOY_RELEASED")
	released.emit(i, shelf)


## Toys walking right now.
func walking() -> int:
	return toys.filter(func(toy: WindUpToy) -> bool: return toy.is_walking()).size()
