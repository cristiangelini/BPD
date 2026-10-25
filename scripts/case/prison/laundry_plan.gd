class_name LaundryPlan
extends Node

## The prison's laundry (carcel-lavanderia.md, step 2): the kitchen east of the canteen turned into the laundry, its
## door taken off so the carts get through. Washers and dryers along the east wall, the folding table and a clothesline
## with clothes hung out, WORKERS inmates at their stations and CARTS laundry carts in two rows by the west wall. The
## seed draws which carts carry an inmate under the sheets (HIDDEN_MIN to HIDDEN_MAX of them) and on which of the
## truck's TRIPS each cart goes (PER_TRIP each). Nobody moves until the first cop walks through the gate. Step 3: the
## truck (LaundryTruck) comes FIRST_TRIP seconds after that and every TRIP_EVERY seconds, and PER_TRIP workers push
## that trip's carts to it, PUSH_STAGGER seconds apart. A cart checked or knocked over with an inmate under the sheets
## lets them out (`found`): they run for the gate (a BlackoutInmate going for it, in daylight), and cuffed they're
## walked to the punishment cell (BlackoutEscort; `caught`). The ones who reach the gate, and the carts that go up the
## ramp with someone still in them, are `escaped`. The truck leaves once its carts are up; after the last trip the
## laundry day is over (`ended`). Every number here is (propuesta).

signal started
signal trip_started(trip: int)
signal found_one(count: int)
signal caught_one(count: int)
signal escaped_one(count: int)
signal ended

const CARTS := 12
const TRIPS := 4
const PER_TRIP := 3
const HIDDEN_MIN := 4
const HIDDEN_MAX := 6
const WORKERS := 6
## Step 4: one in FOOT_ONE_IN of the hidden ones has a shoe sticking out, and one in CAT_ONE_IN of the empty carts has a
## cat asleep in the towels.
const FOOT_ONE_IN := 2
const CAT_ONE_IN := 3
## Step 5: after MACHINE_TRIPS of the trips (drawn among the first TRIPS - 1), halfway to the next one, an inmate squeezes
## into a washer or a dryer; when the next trip comes, still in there, they slip into one of its carts that has nobody.
## Let out, they're dizzy DIZZY_TIME seconds before they run.
const MACHINE_TRIPS := 2
const DIZZY_TIME := 5.0
## The carts' places (level space x, z): two rows by the west wall, back from the kitchen's front.
const CART_XS: Array[float] = [7.0, 9.0]
const CART_ZS: Array[float] = [6.6, 5.4, 4.2, 3.0, 1.8, 0.6]
## The machines against the east wall (level space z; LaundryMachine), and how far from the wall they stand.
const WASHER_ZS: Array[float] = [6.8, 6.0, 5.2, 4.4]
const DRYER_ZS: Array[float] = [3.2, 2.4]
const MACHINE_X := PrisonLevel.BUILDING_X - 0.5
## The folding table (level space x, z; long along Z) and the clothesline across the room (z), with its clothes.
const TABLE_AT := Vector2(9.5, -1.5)
const TABLE_SIZE := Vector3(1.0, 0.85, 2.4)
const LINE_Z := -4.0
const LINE_HEIGHT := 2.0
const CLOTHES := 6
## Each worker's station (level space x, z) and what they face there: the washers, the dryers, the table, the line.
const STATIONS: Array[Vector2] = [Vector2(10.4, 6.4), Vector2(10.4, 4.8), Vector2(10.4, 2.8), Vector2(10.4, -0.9),
	Vector2(10.4, -2.1), Vector2(9.0, -3.5)]
const FACES: Array[Vector2] = [Vector2(12.0, 6.4), Vector2(12.0, 4.8), Vector2(12.0, 2.8), Vector2(9.5, -0.9),
	Vector2(9.5, -2.1), Vector2(9.0, LINE_Z)]
## The truck's trips: the first this long after the start, then one every TRIP_EVERY seconds; a trip's pushers set off
## this far apart.
const FIRST_TRIP := 20.0
const TRIP_EVERY := 120.0
const PUSH_STAGGER := 6.0
## The ways through the laundry (level space): the east lane by the machines, the aisle between the rows of carts and
## where they cross south of the folding table; through the kitchen's doorway and up the canteen's lane by the counter,
## out the east front door and across the yard to the gate.
const LANE_X := 10.4
const AISLE_X := 8.0
const CROSS_Z := -3.0
const CANTEEN_X := 3.2
const GATE := Vector2(0.0, PrisonLevel.HALF_Z + 0.5)
const CLOTH: Array[Color] = [Color(0.85, 0.45, 0.2), Color(0.95, 0.95, 0.92), Color(0.6, 0.75, 0.9),
	Color(0.85, 0.85, 0.5)]

var prison: PrisonLevel
var carts: Array[LaundryCart] = []
var workers: Array[LaundryWorker] = []
var running := false
var follower := false
var room: Node3D
var truck: LaundryTruck
## The trip on now (-1 before the first) and the seconds to the next.
var trip_now := -1
var next_trip_in := FIRST_TRIP
## Inmates found under the sheets, cuffed into the punishment cell, and gone (through the gate or up the ramp).
var found := 0
var caught := 0
var escaped := 0
var is_over := false
var runners: Array[BlackoutInmate] = []
## Step 5: the washers and dryers; after which trips someone squeezes into one, and which.
var machines: Array[LaundryMachine] = []
var machine_trips: Array[int] = []
var machine_picks: Array[int] = []
var _machine_in := -1.0
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
		cart.index = i
		cart.trip = order.find(i) / PER_TRIP
		cart.hidden = hidden.has(i)
		cart.linen_seed = _rng.randi()
		cart.tell_seed = _rng.randi()
		if cart.hidden:
			cart.foot_out = _rng.randi_range(1, FOOT_ONE_IN) == 1
		else:
			cart.has_cat = _rng.randi_range(1, CAT_ONE_IN) == 1
		var spot := cart_spot(i)
		cart.position = Vector3(spot.x, PrisonLevel.FLOOR_TOP, spot.y)
		room.add_child(cart)
		cart.revealed.connect(_on_revealed)
		cart.loaded_up.connect(_on_loaded)
		carts.append(cart)
	var trips := range(TRIPS - 1)
	_shuffle(trips)
	for trip: int in trips.slice(0, MACHINE_TRIPS):
		machine_trips.append(trip)
		machine_picks.append(_rng.randi_range(0, machines.size() - 1))
	for i in WORKERS:
		var worker := LaundryWorker.new()
		worker.name = "Worker%d" % i
		worker.prison = level
		worker.station = STATIONS[i]
		worker.face = FACES[i]
		add_child(worker)
		worker.place()
		workers.append(worker)
		for cart in carts:
			worker.add_collision_exception_with(cart)
	truck = LaundryTruck.new()
	truck.name = "LaundryTruck"
	prison.add_child(truck)


## The `index`-th cart's place (level space x, z).
static func cart_spot(index: int) -> Vector2:
	return Vector2(CART_XS[index % CART_XS.size()], CART_ZS[index / CART_XS.size()])


## The carts going out on the truck's `trip`, from 0.
func carts_on_trip(trip: int) -> Array[LaundryCart]:
	return carts.filter(func(cart: LaundryCart) -> bool: return cart.trip == trip)


## The pushers' way from a cart pulled out into the aisle to the truck: down the aisle, through the kitchen's doorway,
## up the canteen's lane, out the front door and across the yard to the gate (the cart goes up the ramp past it).
static func push_route() -> Array[Vector2]:
	return [Vector2(AISLE_X, PrisonLevel.KITCHEN_DOOR_Z), Vector2(5.0, PrisonLevel.KITCHEN_DOOR_Z),
		Vector2(CANTEEN_X, PrisonLevel.KITCHEN_DOOR_Z), Vector2(CANTEEN_X, 6.0), Vector2(PrisonLevel.ENTRANCES[1], 7.2),
		Vector2(PrisonLevel.ENTRANCES[1], 10.0), Vector2(1.0, 14.0), Vector2(0.0, PrisonLevel.HALF_Z)]


## A runner's way from `at` (level space) to the gate: the pushers' way from the nearest part of it.
static func escape_route(at: Vector2) -> Array[Vector2]:
	var way := push_route()
	way[way.size() - 1] = GATE
	if at.y >= PrisonLevel.BUILDING_FRONT:
		return way.slice(5) if at.y < 10.0 else way.slice(6)
	if at.x < PrisonLevel.KITCHEN_X:
		var lane := way.slice(3)
		if at.y < PrisonLevel.KITCHEN_DOOR_Z + 1.0 and at.x > CANTEEN_X:
			lane.push_front(way[2])
		else:
			lane.push_front(Vector2(CANTEEN_X, at.y))
		return lane
	way.push_front(Vector2(AISLE_X, at.y))
	return way


func hidden_count() -> int:
	return carts.filter(func(cart: LaundryCart) -> bool: return cart.hidden).size()


## The washers and dryers, the folding table and the clothesline with its clothes.
func _build_room() -> void:
	var build := PlaceBuilder.new(room)
	for z: float in WASHER_ZS + DRYER_ZS:
		var machine := LaundryMachine.new()
		machine.name = "Machine%d" % machines.size()
		machine.dryer = DRYER_ZS.has(z)
		machine.position = Vector3(MACHINE_X, PrisonLevel.FLOOR_TOP, z)
		room.add_child(machine)
		machine.opened.connect(_on_machine_opened)
		machines.append(machine)
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


## The laundry day is on: everyone gets to work.
func start() -> void:
	if running:
		return
	running = true
	for i in workers.size():
		workers[i].work(i * 0.27)
	started.emit()


## The truck's next trip: it comes, and PER_TRIP workers go for that trip's carts.
func start_trip() -> void:
	if trip_now >= TRIPS - 1:
		return
	trip_now += 1
	next_trip_in = TRIP_EVERY
	truck.arrive()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_LAUNDRY_TRUCK")
	var trip_carts := carts_on_trip(trip_now)
	_out_of_machines(trip_carts)
	_machine_in = TRIP_EVERY / 2 if machine_trips.has(trip_now) else -1.0
	for k in trip_carts.size():
		var worker := workers[(trip_now * PER_TRIP + k) % WORKERS]
		worker.fetch(trip_carts[k], k * PUSH_STAGGER)
	trip_started.emit(trip_now)


## Halfway to the next trip: someone squeezes into the machine drawn for this one.
func fill_machine() -> void:
	_machine_in = -1.0
	var pick := machine_picks[machine_trips.find(trip_now)] if machine_trips.has(trip_now) else 0
	machines[pick].set_occupied(true)


## The trip is here: whoever is still in a machine slips into one of its carts that has nobody (and isn't checked).
func _out_of_machines(trip_carts: Array[LaundryCart]) -> void:
	for machine in machines:
		if not machine.occupied:
			continue
		for cart in trip_carts:
			if not cart.hidden and not cart.checked and not cart.loaded:
				machine.set_occupied(false)
				cart.hidden = true
				cart.has_cat = false
				break


func _on_machine_opened(machine: LaundryMachine, had_someone: bool) -> void:
	if not had_someone:
		return
	var runner := _runner(machine.global_position + machine.global_basis * Vector3(-0.8, 0, 0))
	runner.delay = DIZZY_TIME
	runner.say("MACHINE_DIZZY", DIZZY_TIME)


func _on_revealed(cart: LaundryCart) -> void:
	# Out over its front (knocked over, the cart turns about its length, so its front stays level).
	var front := -cart.global_basis.z
	front.y = 0.0
	var runner := _runner(cart.global_position + front.normalized() * (LaundryCart.SIZE.z / 2 + 0.4))
	runner.say("LAUNDRY_SURPRISE")


## An inmate found (in a cart or a machine) at `at`: off for the gate, unless cuffed and walked to the punishment cell.
func _runner(at: Vector3) -> BlackoutInmate:
	found += 1
	var runner := BlackoutInmate.new()
	runner.name = "Runner%d" % runners.size()
	runner.role = BlackoutInmate.Role.GATE
	runner.glow_eyes = false
	runner.prison = prison
	var local := prison.global_transform.affine_inverse() * at
	runner.route = escape_route(Vector2(local.x, local.z))
	add_child(runner)
	runner.global_position = at
	for other in carts:
		runner.add_collision_exception_with(other)
	runner.active = true
	runner.escaped.connect(_on_runner_escaped)
	BlackoutEscort.to_block(runner, prison).boarded.connect(_on_caught.bind(runner))
	runners.append(runner)
	found_one.emit(found)
	return runner


## Walked into the punishment cell: counted once, even if they walk out and get walked back in.
func _on_caught(runner: BlackoutInmate) -> void:
	if runner.has_meta("caught"):
		return
	runner.set_meta("caught", true)
	caught += 1
	caught_one.emit(caught)


func _on_runner_escaped(_runner: BlackoutInmate) -> void:
	_escape()


func _on_loaded(cart: LaundryCart) -> void:
	if cart.hidden:
		_escape()
	var trip_carts := carts_on_trip(cart.trip)
	if not trip_carts.all(func(other: LaundryCart) -> bool: return other.loaded):
		return
	truck.leave()
	if cart.trip == TRIPS - 1:
		is_over = true
		ended.emit()


func _escape() -> void:
	escaped += 1
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_LAUNDRY_ESCAPED")
	escaped_one.emit(escaped)


func _physics_process(delta: float) -> void:
	if follower:
		return
	if not running:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if prison.inside_walls(cop.global_position):
				start()
				return
		return
	if _machine_in > 0.0:
		_machine_in -= delta
		if _machine_in <= 0.0:
			fill_machine()
	if is_over or trip_now >= TRIPS - 1:
		return
	next_trip_in -= delta
	if next_trip_in <= 0.0:
		start_trip()


func _shuffle(items: Array) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = items[i]
		items[i] = items[j]
		items[j] = swap
