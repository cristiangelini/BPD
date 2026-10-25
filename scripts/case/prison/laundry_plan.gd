class_name LaundryPlan
extends Node

## The prison's laundry (carcel-lavanderia.md, step 2): the kitchen east of the canteen turned into the laundry, its
## door taken off so the carts get through. Washers and dryers along the east wall, the folding table and a clothesline
## with clothes hung out, WORKERS inmates at their stations and CARTS laundry carts in two rows by the west wall. The
## seed draws which carts carry an inmate under the sheets (HIDDEN_MIN to HIDDEN_MAX of them) and on which of the
## truck's TRIPS each cart goes (PER_TRIP each). Nobody moves until the first cop walks through the gate. Every number
## here is (propuesta).

signal started

const CARTS := 12
const TRIPS := 4
const PER_TRIP := 3
const HIDDEN_MIN := 4
const HIDDEN_MAX := 6
const WORKERS := 6
## The carts' places (level space x, z): two rows by the west wall, back from the kitchen's front.
const CART_XS: Array[float] = [7.0, 8.4]
const CART_ZS: Array[float] = [6.6, 5.4, 4.2, 3.0, 1.8, 0.6]
## The machines against the east wall (level space z), their size, and how far from the wall they stand.
const WASHER_ZS: Array[float] = [6.8, 6.0, 5.2, 4.4]
const DRYER_ZS: Array[float] = [3.2, 2.4]
const MACHINE := Vector3(0.7, 0.85, 0.7)
const MACHINE_X := PrisonLevel.BUILDING_X - 0.5
## The folding table (level space x, z; long along Z) and the clothesline across the room (z), with its clothes.
const TABLE_AT := Vector2(9.5, -1.5)
const TABLE_SIZE := Vector3(1.0, 0.85, 2.4)
const LINE_Z := -4.0
const LINE_HEIGHT := 2.0
const CLOTHES := 6
## Each worker's station (level space x, z) and what they face there: the washers, the dryers, the table, the line.
const STATIONS: Array[Vector2] = [Vector2(10.4, 6.4), Vector2(10.4, 4.8), Vector2(10.4, 2.8), Vector2(8.6, -1.0),
	Vector2(10.4, -2.0), Vector2(9.0, -3.5)]
const FACES: Array[Vector2] = [Vector2(12.0, 6.4), Vector2(12.0, 4.8), Vector2(12.0, 2.8), Vector2(9.5, -1.0),
	Vector2(9.5, -2.0), Vector2(9.0, LINE_Z)]
const WHITE := Color(0.92, 0.93, 0.95)
const GLASS := Color(0.35, 0.45, 0.55)
const CLOTH: Array[Color] = [Color(0.85, 0.45, 0.2), Color(0.95, 0.95, 0.92), Color(0.6, 0.75, 0.9),
	Color(0.85, 0.85, 0.5)]

var prison: PrisonLevel
var carts: Array[LaundryCart] = []
var workers: Array[LaundryWorker] = []
var running := false
var follower := false
var room: Node3D
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["laundry", case_seed])
	# The kitchen's door comes off, so the carts get through to the canteen.
	if prison.kitchen_door:
		prison.kitchen_door.queue_free()
		prison.kitchen_door = null
	room = Node3D.new()
	room.name = "Laundry"
	prison.add_child(room)
	_build_room()
	var order := range(CARTS)
	_shuffle(order)
	var hidden := range(CARTS)
	_shuffle(hidden)
	hidden = hidden.slice(0, _rng.randi_range(HIDDEN_MIN, HIDDEN_MAX))
	for i in CARTS:
		var cart := LaundryCart.new()
		cart.name = "Cart%d" % i
		cart.trip = order.find(i) / PER_TRIP
		cart.hidden = hidden.has(i)
		cart.linen_seed = _rng.randi()
		var spot := cart_spot(i)
		cart.position = Vector3(spot.x, PrisonLevel.FLOOR_TOP, spot.y)
		room.add_child(cart)
		carts.append(cart)
	for i in WORKERS:
		var worker := LaundryWorker.new()
		worker.name = "Worker%d" % i
		worker.prison = level
		worker.station = STATIONS[i]
		worker.face = FACES[i]
		add_child(worker)
		worker.place()
		workers.append(worker)


## The `index`-th cart's place (level space x, z).
static func cart_spot(index: int) -> Vector2:
	return Vector2(CART_XS[index % CART_XS.size()], CART_ZS[index / CART_XS.size()])


## The carts going out on the truck's `trip`, from 0.
func carts_on_trip(trip: int) -> Array[LaundryCart]:
	return carts.filter(func(cart: LaundryCart) -> bool: return cart.trip == trip)


func hidden_count() -> int:
	return carts.filter(func(cart: LaundryCart) -> bool: return cart.hidden).size()


## The washers and dryers, the folding table and the clothesline with its clothes.
func _build_room() -> void:
	var build := PlaceBuilder.new(room)
	for z in WASHER_ZS:
		_machine(build, z, false)
	for z in DRYER_ZS:
		_machine(build, z, true)
	var table := Vector3(TABLE_AT.x, PrisonLevel.FLOOR_TOP, TABLE_AT.y)
	build.legs(table, Vector2(TABLE_SIZE.x, TABLE_SIZE.z), TABLE_SIZE.y, PrisonLevel.STEEL)
	build.box(table + Vector3(0, TABLE_SIZE.y, 0), Vector3(TABLE_SIZE.x, 0.05, TABLE_SIZE.z), PrisonLevel.STEEL)
	for i in 3:
		build.mesh_box(table + Vector3(0, TABLE_SIZE.y + 0.05 + i * 0.06, -0.6 + i * 0.5), Vector3(0.5, 0.06, 0.4),
			CLOTH[i % CLOTH.size()])
	var from := PrisonLevel.KITCHEN_X + 0.2
	var to := PrisonLevel.BUILDING_X - 0.2
	build.mesh_box(Vector3((from + to) / 2, LINE_HEIGHT, LINE_Z), Vector3(to - from, 0.02, 0.02), PrisonLevel.BARS)
	for i in CLOTHES:
		var x := from + 0.5 + i * (to - from - 1.0) / (CLOTHES - 1)
		var long := 0.5 + 0.2 * (i % 2)
		build.mesh_box(Vector3(x, LINE_HEIGHT - long / 2, LINE_Z), Vector3(0.5, long, 0.02), CLOTH[i % CLOTH.size()])


## A washer (or a dryer) against the east wall, its round glass door toward the room.
func _machine(build: PlaceBuilder, z: float, dryer: bool) -> void:
	var at := Vector3(MACHINE_X, PrisonLevel.FLOOR_TOP, z)
	build.box(at + Vector3(0, MACHINE.y / 2, 0), MACHINE, WHITE if not dryer else WHITE.darkened(0.15))
	var door := CylinderMesh.new()
	door.top_radius = 0.22
	door.bottom_radius = 0.22
	door.height = 0.04
	build.mesh(door, at + Vector3(-MACHINE.x / 2 - 0.01, MACHINE.y * 0.5, 0), GLASS, Vector3(0, 0, PI / 2))
	build.mesh_box(at + Vector3(-MACHINE.x / 2 + 0.05, MACHINE.y - 0.06, 0), Vector3(0.12, 0.06, MACHINE.z - 0.1),
		PrisonLevel.BARS)


## The laundry day is on: everyone gets to work.
func start() -> void:
	if running:
		return
	running = true
	for i in workers.size():
		workers[i].work(i * 0.27)
	started.emit()


func _physics_process(_delta: float) -> void:
	if follower or running:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if prison.inside_walls(cop.global_position):
			start()
			return


func _shuffle(items: Array) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = items[i]
		items[i] = items[j]
		items[j] = swap
