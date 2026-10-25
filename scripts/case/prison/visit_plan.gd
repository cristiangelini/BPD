class_name VisitPlan
extends Node

## The prison's visiting day (carcel-visitas.md, step 2): VISITORS visitors in line in the yard, from the search table
## by the canteen's west door back toward the gate, each with a different thing in their hands. The seed draws who
## comes, what each one brings and who hides something (HIDDEN_MIN to HIDDEN_MAX of them, in what they bring or in a
## pocket). The head of the line walks to the table; once they go in, everyone moves up a place. Nobody moves until
## the first cop walks through the gate. Every number here is (propuesta).

signal started
signal all_in
## Something hidden was found (step 3), or an innocent thing was opened for nothing.
signal confiscated_one(count: int)
signal broke_one(count: int)

const VISITORS := 8
const HIDDEN_MIN := 4
const HIDDEN_MAX := 6
## One in POCKET_ONE_IN of the hidden ones has it in a pocket instead of in what they bring.
const POCKET_ONE_IN := 3
## One in NERVOUS_ONE_IN of the innocent ones is nervous anyway, and frets now and then (step 4).
const NERVOUS_ONE_IN := 3
## The search table in the yard, by the canteen's west door, long along Z (level space x, z), and its size.
const TABLE_AT := Vector2(-3.4, 10.4)
const TABLE_SIZE := Vector3(0.8, 0.8, 2.0)
## Where the visitor stands at the table (its east side; the cop searches from the west), and where they leave what
## they bring.
const TABLE_SPOT := Vector2(-2.4, 10.4)
const ITEM_ON_TABLE := Vector3(-3.4, 0.86, 10.4)
## The line: its head, and a place every QUEUE_STEP meters back toward the gate.
const QUEUE_HEAD := Vector2(-2.4, 11.8)
const QUEUE_STEP := 1.0
## In through the west door, along the front of the canteen and down the aisle between the two columns of tables.
const DOOR_OUT := Vector2(-2.0, 9.0)
const DOOR_IN := Vector2(-2.0, 6.8)
const AISLE_X := -5.0
## A visitor's seat: past the bench on a table's +Z side, at one of these places along it.
const SEAT_XS: Array[float] = [-0.9, 0.9]
const SEAT_Z := 1.25

var prison: PrisonLevel
## In line order: the first is the head of the line.
var visitors: Array[PrisonVisitor] = []
## Still in line or at the table, in order.
var line: Array[PrisonVisitor] = []
var running := false
var follower := false
var table: StaticBody3D
## Hidden things found at the search table, and innocent things opened for nothing (step 3).
var confiscated := 0
var broken := 0
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["visiting day", case_seed])
	_build_table()
	var looks := range(PrisonVisitor.LOOKS.size())
	_shuffle(looks)
	var kinds := range(VisitItem.Kind.size())
	_shuffle(kinds)
	var hiders := range(VISITORS)
	_shuffle(hiders)
	hiders = hiders.slice(0, _rng.randi_range(HIDDEN_MIN, HIDDEN_MAX))
	var seats := seat_spots()
	_shuffle(seats)
	for i in VISITORS:
		var visitor := PrisonVisitor.new()
		visitor.name = "Visitor%d" % i
		visitor.prison = level
		visitor.look = looks[i % looks.size()]
		visitor.item_kind = kinds[i] as VisitItem.Kind
		if hiders.has(i):
			if _rng.randi_range(1, POCKET_ONE_IN) == 1:
				visitor.pocket_hidden = true
				visitor.pocket_kind = _rng.randi_range(0, Contraband.IN_POCKET.size() - 1)
			else:
				visitor.item_hidden = true
		visitor.seat = seats[i]
		visitor.tell_seed = _rng.randi()
		if not hiders.has(i) and _rng.randi_range(1, NERVOUS_ONE_IN) == 1:
			visitor.nervous = true
		add_child(visitor)
		var spot := queue_spot(i)
		visitor.global_position = level.global_transform * Vector3(spot.x, PrisonLevel.FLOOR_TOP, spot.y)
		visitor.look_at(visitor.global_position + level.global_basis * Vector3(0, 0, -1), Vector3.UP)
		visitor.went_in.connect(_on_went_in)
		visitor.found.connect(_on_found)
		visitor.cried.connect(_on_cried)
		visitors.append(visitor)
		line.append(visitor)


## The search table: a plain steel-topped table standing in the yard.
func _build_table() -> void:
	table = StaticBody3D.new()
	table.name = "SearchTable"
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = TABLE_SIZE
	shape.shape = box
	shape.position.y = TABLE_SIZE.y / 2
	table.add_child(shape)
	table.add_child(CopTool.piece(CopTool.box(Vector3(TABLE_SIZE.x, 0.05, TABLE_SIZE.z)), PrisonLevel.STEEL,
		Vector3(0, TABLE_SIZE.y - 0.025, 0)))
	for x: float in [-0.35, 0.35]:
		for z: float in [-0.95, 0.95]:
			table.add_child(CopTool.piece(CopTool.box(Vector3(0.05, TABLE_SIZE.y, 0.05)), PrisonLevel.BARS,
				Vector3(x, TABLE_SIZE.y / 2, z)))
	table.position = Vector3(TABLE_AT.x, PrisonLevel.FLOOR_TOP, TABLE_AT.y)
	prison.add_child(table)


## The `place`-th place in line (level space x, z).
static func queue_spot(place: int) -> Vector2:
	return QUEUE_HEAD + Vector2(0, QUEUE_STEP * place)


## Every visitor's seat (level space x, z): the canteen's tables, on their +Z side, in table order.
static func seat_spots() -> Array:
	var seats := []
	for z: float in PrisonLevel.TABLE_ZS:
		for x: float in PrisonLevel.TABLE_XS:
			for along: float in SEAT_XS:
				seats.append(Vector2(x + along, z + SEAT_Z))
	return seats


## From the search table to `seat`: in through the west door, along the front and down the aisle between the tables.
static func way_in(seat: Vector2) -> Array[Vector2]:
	return [DOOR_OUT, DOOR_IN, Vector2(AISLE_X, DOOR_IN.y), Vector2(AISLE_X, seat.y), seat]


## The visiting day is on: the head of the line walks to the table.
func start() -> void:
	if running:
		return
	running = true
	_move_up()
	started.emit()


## Everyone in line walks to their place: the head to the table, the rest a place further up.
func _move_up() -> void:
	for place in line.size():
		var visitor := line[place]
		if visitor.state != PrisonVisitor.State.QUEUE:
			continue
		var to: Array[Vector2] = [TABLE_SPOT if place == 0 else queue_spot(place - 1)]
		visitor.walk(to)


func _on_went_in(visitor: PrisonVisitor) -> void:
	line.erase(visitor)
	if line.is_empty():
		all_in.emit()
		return
	_move_up()


func _on_found(_visitor: PrisonVisitor, _contraband: Contraband) -> void:
	confiscated += 1
	confiscated_one.emit(confiscated)


func _on_cried(_visitor: PrisonVisitor) -> void:
	broken += 1
	broke_one.emit(broken)


## The ones who still carry something hidden (step 5 tries to pass it under the table).
func carrying_contraband() -> Array[PrisonVisitor]:
	return visitors.filter(func(visitor: PrisonVisitor) -> bool:
		return visitor.has_contraband())


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
