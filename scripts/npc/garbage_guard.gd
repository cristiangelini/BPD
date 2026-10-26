class_name GarbageGuard
extends NightGuard

## The night guard of the garbage truck jailbreak (docs/diseno/fuga-basura.md, step 1): awake at his desk with the
## cells' key on his belt and no donuts, and it's garbage night. Every ROUND_MIN to ROUND_MAX seconds he walks to a
## cell (one, then the other), unlocks and opens it, steps in, leaves a giant bag (GarbageBag) open on the floor,
## empties the bin into it for IN_CELL seconds, knots it, steps out dragging it, locks the cell and takes it out the
## front door to the dumpster on the sidewalk (Dumpster), and walks back. While he's away he still watches. Every
## number here is (propuesta).

signal bag_dropped(bag: GarbageBag, cell: int)
signal bag_thrown(bag: GarbageBag)

const ROUND_MIN := 60.0
const ROUND_MAX := 90.0
const WALK_SPEED := 1.3
const IN_CELL := 4.0
## How far behind him the bag he drags goes.
const DRAG_BEHIND := 0.8
## His way, in the station's lot space: in front of each cell's door, the middle of each cell, and out to the sidewalk
## through the guard room and the front door.
const DOOR_FRONT_Z := 5.3
const CELL_IN_Z := 3.2
const BAG_Z := 3.6
const DESK_SIDE: Array[Vector3] = [Vector3(8.8, 0, 8.4), Vector3(12.2, 0, 8.4)]
const TO_STREET: Array[Vector3] = [Vector3(6.6, 0, 6.4), Vector3(5.2, 0, 6.4), Vector3(0, 0, 7.5), Vector3(0, 0, 10.0)]
const GRUMBLE_LINES := 4

## The station's lot, the cell doors and the dumpster (the level sets them).
var station_lot: Transform3D
var cell_doors: Array[CellDoor] = []
var dumpster: Dumpster
## Seconds to the next round, the cell it's for, and where he is in it: "" (at his desk), "to_cell", "in_cell",
## "out_of_cell", "to_street" or "back".
var round_left := ROUND_MAX
var round_cell := 0
var stage := ""
var bag: GarbageBag
var _desk_spot: Transform3D
var _path: Array[Vector3] = []
var _stay_left := 0.0


## The guard for this jailbreak's seed: the key on his belt, the first round's cell and wait.
func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["garbage guard", case_seed])
	key_on_belt = true
	_desk_spot = global_transform
	round_cell = _rng.randi_range(0, 1)
	round_left = _rng.randf_range(ROUND_MIN, ROUND_MAX)


## No donuts tonight.
func eat() -> void:
	eat_left = EAT_EVERY


func is_away() -> bool:
	return stage != ""


func _physics_process(delta: float) -> void:
	if not is_away():
		super(delta)
		if is_asleep():
			return
		round_left -= delta
		if round_left <= 0.0:
			start_round()
		return
	_tick_bubble(delta)
	if _stay_left > 0.0:
		_stay_left -= delta
		if _stay_left <= 0.0:
			_leave_cell()
	else:
		_walk(delta)
	_drag()
	if is_away():
		_watch(delta)


## Gets up for the garbage of `round_cell`.
func start_round() -> void:
	stage = "to_cell"
	var door := _door_x(round_cell)
	_path = [_at(DESK_SIDE[round_cell]), _at(Vector3(door, 0, DOOR_FRONT_Z))]
	say("GARBAGE_GUARD_GRUMBLE_%d" % _rng.randi_range(0, GRUMBLE_LINES - 1))


## Where a cell's door opens, along x, and its middle.
func _door_x(cell: int) -> float:
	var door := StationRooms.CELL_DOORS[cell]
	return (door.x + door.y) / 2.0


func _cell_x(cell: int) -> float:
	return (StationRooms.FRONT_X + StationRooms.CELL_SPLIT_X) / 2.0 if cell == 0 \
		else (StationRooms.CELL_SPLIT_X + StationRooms.HALF_X) / 2.0


func _at(local: Vector3) -> Vector3:
	return station_lot * Vector3(local.x, (station_lot.affine_inverse() * _desk_spot.origin).y, local.z)


func _walk(delta: float) -> void:
	if _path.is_empty():
		_arrived()
		return
	var to := _path[0] - global_position
	to.y = 0.0
	var step := WALK_SPEED * delta
	if to.length() > 0.01:
		global_basis = Basis.looking_at(-to.normalized())
	look = 0.0
	_model.rotation.y = 0.0
	if to.length() > step:
		global_position += to.normalized() * step
		return
	global_position = Vector3(_path[0].x, global_position.y, _path[0].z)
	_path.pop_front()
	if _path.is_empty():
		_arrived()


## The end of a stretch of his round.
func _arrived() -> void:
	match stage:
		"to_cell":
			if not _at_cell_inside():
				var door := cell_doors[round_cell]
				door.unlock()
				door.set_open(true)
				_path = [_at(Vector3(_door_x(round_cell), 0, CELL_IN_Z))]
				return
			_drop_bag()
		"out_of_cell":
			var door := cell_doors[round_cell]
			door.set_open(false)
			door.lock()
			stage = "to_street"
			_path.assign(TO_STREET.map(_at))
			if dumpster:
				_path.append(dumpster.global_position + (dumpster.global_basis * Vector3(0, 0, 1.0)))
		"to_street":
			if is_instance_valid(bag) and dumpster:
				dumpster.throw_in(bag)
				bag_thrown.emit(bag)
			bag = null
			stage = "back"
			var back := TO_STREET.duplicate()
			back.reverse()
			_path.assign(back.map(_at))
			_path.append(_at(DESK_SIDE[round_cell]))
			_path.append(_desk_spot.origin)
		"back":
			_back_at_desk()


func _at_cell_inside() -> bool:
	return (station_lot.affine_inverse() * global_position).z < StationRooms.CELL_FRONT_Z


## In the cell: the bag open on the floor, and IN_CELL seconds emptying the bin into it.
func _drop_bag() -> void:
	stage = "in_cell"
	bag = GarbageBag.new()
	bag.name = "GarbageBag"
	get_parent().add_child(bag, true)
	bag.global_position = _at(Vector3(_cell_x(round_cell), 0, BAG_Z))
	_stay_left = IN_CELL
	say("GARBAGE_GUARD_EMPTY")
	bag_dropped.emit(bag, round_cell)


## Done in the cell: he knots the bag and drags it out; at the door he locks the cell (then the dumpster).
func _leave_cell() -> void:
	if is_instance_valid(bag):
		bag.knot()
	stage = "out_of_cell"
	_path = [_at(Vector3(_door_x(round_cell), 0, DOOR_FRONT_Z))]


## The bag he's dragging follows him on the floor.
func _drag() -> void:
	if not is_instance_valid(bag) or not stage in ["out_of_cell", "to_street"]:
		return
	bag.global_position = global_position - facing() * DRAG_BEHIND


func _back_at_desk() -> void:
	global_transform = _desk_spot
	_path.clear()
	_stay_left = 0.0
	stage = ""
	round_cell = 1 - round_cell
	round_left = _rng.randf_range(ROUND_MIN, ROUND_MAX)


## Caught them: whatever he was doing, he's back at his desk with the cells locked (the level puts everyone back).
func catch() -> void:
	if is_away():
		for door in cell_doors:
			door.lock()
		if is_instance_valid(bag):
			bag.queue_free()
		bag = null
		_back_at_desk()
	super()
