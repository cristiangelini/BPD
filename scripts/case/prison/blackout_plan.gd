class_name BlackoutPlan
extends Node

## The inmates loose in the blackout (carcel-corte-de-luz.md, step 3): INMATES in the block's cells, one or two to a
## cell, and each one's role by the seed: GATES_MIN to GATES_MIN + 2 head out to the yard's gate (each after a delay
## of GATE_FIRST seconds and then one every GATE_EVERY, give or take GATE_JITTER), half the rest hide (crouched in a corner of the canteen, behind the counter, in the
## punishment cell or in a cell that isn't theirs) and the others wander round the canteen. Nothing moves until the
## first cop walks through the prison's gate. Every LIGHT_CHECK seconds each inmate is lit or not by the cops'
## flashlights (Flashlight.reaches): lit, they freeze. One reaching the gate is gone and counts as escaped. Every
## point here is in the prison's space (x, z) and every number is (propuesta).

signal started
signal inmate_escaped(inmate: BlackoutInmate)

const INMATES := 12
const GATES_MIN := 3
const GATE_FIRST := 10.0
const GATE_EVERY := 25.0
const GATE_JITTER := 5.0
const LIGHT_CHECK := 0.1
## Past this (level z, the gate's line in the front wall) the one walking out is gone.
const ESCAPE_Z := PrisonLevel.HALF_Z - 0.6
## The corridor's middle, through the block's gate, the canteen's two aisles and the front door to the yard.
const CORRIDOR_X := -1.0
const BLOCK_OUT := Vector2(-1.0, -5.1)
const EAST_AISLE := 2.0
const WEST_AISLE := -5.0
const BACK_ROW := -5.1
const FRONT_ROW := 6.5
const DOOR_OUT := Vector2(2.0, 9.0)
const YARD := Vector2(1.0, 15.0)
const GATE := Vector2(0.0, PrisonLevel.HALF_Z + 0.5)
## The hiding spots out in the canteen, each with the way there from BLOCK_OUT.
const CANTEEN_HIDES: Array = [
	[Vector2(EAST_AISLE, BACK_ROW), Vector2(5.3, BACK_ROW), Vector2(5.3, -3.0)],
	[Vector2(EAST_AISLE, BACK_ROW), Vector2(5.3, BACK_ROW), Vector2(5.3, 2.5)],
	[Vector2(WEST_AISLE, BACK_ROW), Vector2(WEST_AISLE, FRONT_ROW + 0.7), Vector2(-11.2, FRONT_ROW + 0.7)],
	[Vector2(WEST_AISLE, BACK_ROW), Vector2(WEST_AISLE, -1.5), Vector2(-11.2, -1.5)],
	[Vector2(WEST_AISLE, BACK_ROW), Vector2(WEST_AISLE, -1.5), Vector2(-11.0, -1.5), Vector2(-11.0, -3.4),
		Vector2(-11.0, -5.2)],
	[Vector2(EAST_AISLE, BACK_ROW), Vector2(EAST_AISLE, FRONT_ROW), Vector2(-3.5, FRONT_ROW + 0.8)],
]
## How many points of a route lead out of the cell (wander_route).
const WAY_OUT := 3
## Round the canteen, between the tables.
const WANDER: Array[Vector2] = [Vector2(WEST_AISLE, BACK_ROW), Vector2(WEST_AISLE, FRONT_ROW),
	Vector2(EAST_AISLE, FRONT_ROW), Vector2(EAST_AISLE, BACK_ROW)]

var prison: PrisonLevel
var inmates: Array[BlackoutInmate] = []
var running := false
var escaped := 0
var _check_left := 0.0
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["blackout inmates", case_seed])
	var gates := GATES_MIN + _rng.randi_range(0, 2)
	var hides := (INMATES - gates) / 2
	var roles: Array = []
	for i in INMATES:
		roles.append(BlackoutInmate.Role.GATE if i < gates else (BlackoutInmate.Role.HIDE if i < gates + hides
			else BlackoutInmate.Role.WANDER))
	_shuffle(roles)
	var spots := range(CANTEEN_HIDES.size() + PrisonLevel.CELLS * 2)
	_shuffle(spots)
	var hide_at := 0
	var gate_at := 0
	for i in INMATES:
		var cell := i % (PrisonLevel.CELLS * 2)
		var inmate := BlackoutInmate.new()
		inmate.name = "BlackoutInmate%d" % i
		inmate.prison = level
		inmate.role = roles[i]
		# Two to a cell, at the back where the door doesn't swing; out by its middle.
		var deeper := -0.7 if cell < PrisonLevel.CELLS else 0.7
		var start := cell_middle(cell) + Vector2(deeper, -0.5 if i < PrisonLevel.CELLS * 2 else 0.5)
		var out := [cell_middle(cell), Vector2(CORRIDOR_X, cell_middle(cell).y), BLOCK_OUT]
		match inmate.role:
			BlackoutInmate.Role.GATE:
				inmate.route = _path(out + [Vector2(EAST_AISLE, BACK_ROW), Vector2(EAST_AISLE, FRONT_ROW), DOOR_OUT, YARD,
					GATE])
				inmate.delay = maxf(GATE_FIRST + gate_at * GATE_EVERY + _rng.randf_range(-GATE_JITTER, GATE_JITTER), 0.0)
				gate_at += 1
			BlackoutInmate.Role.HIDE:
				var spot: int = spots[hide_at]
				hide_at += 1
				# Skip their own cell: hiding there is just staying put.
				if spot >= CANTEEN_HIDES.size() and spot - CANTEEN_HIDES.size() == cell:
					spot = spots[hide_at]
					hide_at += 1
				inmate.route = _hide_route(cell, spot)
			BlackoutInmate.Role.WANDER:
				inmate.route = wander_route(cell, _rng.randi_range(0, WANDER.size() - 1))
				inmate.loop_from = WAY_OUT
				inmate.loop = true
		add_child(inmate)
		inmate.global_position = level.global_transform * Vector3(start.x, PrisonLevel.FLOOR_TOP, start.y)
		inmate.escaped.connect(_on_escaped)
		inmates.append(inmate)
		BlackoutEscort.to_block(inmate, level)


static func _path(points: Array) -> Array[Vector2]:
	var path: Array[Vector2] = []
	for point: Vector2 in points:
		path.append(point)
	return path


## The way out of `cell` (WAY_OUT points: its middle, the corridor, the block's gate) and then round the canteen from
## WANDER's point `first`.
static func wander_route(cell: int, first: int) -> Array[Vector2]:
	var route := _path([cell_middle(cell), Vector2(CORRIDOR_X, cell_middle(cell).y), BLOCK_OUT])
	for k in WANDER.size():
		route.append(WANDER[(first + k) % WANDER.size()])
	return route


## The middle of a cell of the block (0 to 3 west, 4 to 7 east), in level space.
static func cell_middle(cell: int) -> Vector2:
	var row := cell % PrisonLevel.CELLS
	var z := PrisonLevel.CELLS_Z - (row + 0.5) * PrisonLevel.CELL_LENGTH
	var depth := PrisonLevel.CELL_DEPTH / 2
	return Vector2(PrisonLevel.CORRIDOR.x - depth if cell < PrisonLevel.CELLS else PrisonLevel.CORRIDOR.y + depth, z)


## The way from `cell` to hiding spot `spot`: one of CANTEEN_HIDES, or another cell along the corridor.
func _hide_route(cell: int, spot: int) -> Array[Vector2]:
	var route: Array[Vector2] = [cell_middle(cell), Vector2(CORRIDOR_X, cell_middle(cell).y)]
	if spot < CANTEEN_HIDES.size():
		route.append(BLOCK_OUT)
		for point: Vector2 in CANTEEN_HIDES[spot]:
			route.append(point)
		return route
	var other := spot - CANTEEN_HIDES.size()
	var inside := cell_middle(other)
	route.append(Vector2(CORRIDOR_X, inside.y))
	# In, and into its back corner on the side away from the open door (PrisonLevel._cell_fronts).
	var west := other < PrisonLevel.CELLS
	route.append(inside)
	route.append(Vector2(inside.x + (-0.4 if west else 0.4), inside.y + (0.8 if west else -0.8)))
	return route


## The blackout is on: everyone walks.
func start() -> void:
	if running:
		return
	running = true
	for inmate in inmates:
		inmate.active = true
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_BLACKOUT_STARTED")
	started.emit()


## Whether any cop's flashlight lights `inmate` now.
func lit(inmate: BlackoutInmate) -> bool:
	var chest := inmate.global_position + Vector3.UP * 1.1
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var belt: ToolBelt = cop.get("belt")
		if belt and belt.flashlight and belt.flashlight.reaches(chest, inmate):
			return true
	return false


func loose() -> Array[BlackoutInmate]:
	return inmates.filter(func(inmate: BlackoutInmate) -> bool:
		return not inmate.is_escaped and not locked_in(inmate))


## Whether `inmate` is in a cell with its door shut (BlackoutEscort).
func locked_in(inmate: BlackoutInmate) -> bool:
	var escort := OwnerEscort.of(inmate) as BlackoutEscort
	return escort != null and escort.locked_in()


func count_locked_in() -> int:
	return inmates.filter(locked_in).size()


func _on_escaped(inmate: BlackoutInmate) -> void:
	escaped += 1
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_INMATE_ESCAPED")
	inmate_escaped.emit(inmate)


func _shuffle(items: Array) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = items[i]
		items[i] = items[j]
		items[j] = swap


func _physics_process(delta: float) -> void:
	if not running:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if prison.inside_walls(cop.global_position):
				start()
				return
		return
	_check_left -= delta
	if _check_left > 0.0:
		return
	_check_left = LIGHT_CHECK
	for inmate in inmates:
		if not inmate.is_escaped:
			inmate.set_lit(lit(inmate))
