class_name BlackoutPlan
extends Node

## The inmates loose in the blackout (carcel-corte-de-luz.md, step 3): INMATES in the block's cells, one or two to a
## cell, and each one's role by the seed: GATES_MIN to GATES_MIN + 2 head out to the yard's gate (each after a delay
## of GATE_FIRST seconds and then one every GATE_EVERY, give or take GATE_JITTER), half the rest hide (crouched in a corner of the canteen, behind the counter, in the
## punishment cell or in a cell that isn't theirs) and the others wander round the canteen. Nothing moves until the
## first cop walks through the prison's gate. Every LIGHT_CHECK seconds each inmate is lit or not by the cops'
## flashlights (Flashlight.reaches): lit, they freeze. One reaching the gate is gone and counts as escaped. Every
## point here is in the prison's space (x, z) and every number is (propuesta). Step 5: the fuse board (FuseBoard) and
## its three fuses: one in the kitchen, one somewhere in the canteen or the block, and El Chispa's, one of the
## inmates who aren't going for the gate. He waits by the board and, PULL_DELAY seconds after a fuse goes in while
## he's free, walks back to it, pulls the last one out and tosses it somewhere dark. With the three in, the light
## comes back (lights_back): the cells with someone in them lock, and everyone still loose gives up.

signal started
signal inmate_escaped(inmate: BlackoutInmate)
signal lights_came_back

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
## Where El Chispa waits, in the corridor in front of the board, how close he pulls a fuse from and how long after one
## goes in.
const BOARD_SPOT := Vector2(-1.0, PrisonLevel.BUILDING_BACK + 1.2)
const PULL_REACH := 1.6
const PULL_DELAY := 10.0
## Where the fuses can be, in level space (x, height, z): the kitchen's, and the loose one's (also where El Chispa
## tosses the one he pulls): on the canteen's tables, on the floor of the corridor and the corners, on the bunks.
const KITCHEN_SPOTS: Array[Vector3] = [Vector3(9.0, 0.1, -3.0), Vector3(10.5, 0.1, 4.0), Vector3(7.5, 0.1, 6.5)]
const LOOSE_SPOTS: Array[Vector3] = [Vector3(-8.0, 0.85, 4.5), Vector3(-2.0, 0.85, 0.5), Vector3(-8.0, 0.85, -3.5),
	Vector3(-1.0, 0.1, -12.0), Vector3(-5.55, 0.55, -15.5), Vector3(-11.55, 0.55, -6.0), Vector3(5.3, 0.1, 6.0),
	Vector3(2.3, 0.55, -9.5)]
## The way out of the punishment cell, into the west aisle.
const PUNISHMENT_OUT: Array[Vector2] = [Vector2(-11.0, -3.4), Vector2(-11.0, -1.5), Vector2(WEST_AISLE, -1.5)]
## Round the canteen, between the tables.
const WANDER: Array[Vector2] = [Vector2(WEST_AISLE, BACK_ROW), Vector2(WEST_AISLE, FRONT_ROW),
	Vector2(EAST_AISLE, FRONT_ROW), Vector2(EAST_AISLE, BACK_ROW)]

var prison: PrisonLevel
var inmates: Array[BlackoutInmate] = []
var running := false
var escaped := 0
var chispa: BlackoutInmate
var board: FuseBoard
var lights_on := false
## El Chispa's countdown to pull a fuse back out (0: nothing to pull), and whether he's on his way to the board.
var _pull_left := 0.0
var _pulling := false
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
	# El Chispa is the first who isn't going for the gate.
	var chispa_at := roles.find(BlackoutInmate.Role.WANDER)
	if chispa_at == -1:
		chispa_at = roles.find(BlackoutInmate.Role.HIDE)
	roles[chispa_at] = BlackoutInmate.Role.CHISPA
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
			BlackoutInmate.Role.CHISPA:
				inmate.route = board_route(cell)
				inmate.has_fuse = true
				chispa = inmate
		add_child(inmate)
		inmate.global_position = level.global_transform * Vector3(start.x, PrisonLevel.FLOOR_TOP, start.y)
		inmate.escaped.connect(_on_escaped)
		inmates.append(inmate)
		BlackoutEscort.to_block(inmate, level)
	chispa.dropped_fuse.connect(_on_dropped_fuse)
	board = level.fuse_board
	if board:
		board.changed.connect(_on_board_changed)
		board.complete.connect(lights_back)
	spawn_fuse(level.global_transform * KITCHEN_SPOTS[_rng.randi_range(0, KITCHEN_SPOTS.size() - 1)])
	spawn_fuse(level.global_transform * LOOSE_SPOTS[_rng.randi_range(0, LOOSE_SPOTS.size() - 1)])


static func _path(points: Array) -> Array[Vector2]:
	var path: Array[Vector2] = []
	for point: Vector2 in points:
		path.append(point)
	return path


## The way out of `cell` into the canteen: its middle, the corridor and the block's gate (WAY_OUT points), or out of
## the punishment cell into the west aisle.
static func way_out(cell: int) -> Array[Vector2]:
	if cell == PrisonLevel.PUNISHMENT_CELL:
		return PUNISHMENT_OUT.duplicate()
	return _path([cell_middle(cell), Vector2(CORRIDOR_X, cell_middle(cell).y), BLOCK_OUT])


## The way out of `cell` and then round the canteen from WANDER's point `first`.
static func wander_route(cell: int, first: int) -> Array[Vector2]:
	var route := way_out(cell)
	for k in WANDER.size():
		route.append(WANDER[(first + k) % WANDER.size()])
	return route


## From `cell` to El Chispa's spot by the fuse board: along the corridor, or round from the punishment cell.
static func board_route(cell: int) -> Array[Vector2]:
	if cell == PrisonLevel.PUNISHMENT_CELL:
		return _path(PUNISHMENT_OUT + [Vector2(WEST_AISLE, BACK_ROW), BLOCK_OUT, Vector2(CORRIDOR_X, -7.5), BOARD_SPOT])
	return _path([cell_middle(cell), Vector2(CORRIDOR_X, cell_middle(cell).y), BOARD_SPOT])


## From wherever El Chispa is (world space) back to the board.
func route_to_board(at: Vector3) -> Array[Vector2]:
	var local := prison.global_transform.affine_inverse() * at
	if prison.in_punishment(at):
		return board_route(PrisonLevel.PUNISHMENT_CELL)
	if prison.in_block(at):
		var cell := prison.cell_at(at)
		return board_route(cell) if cell != -1 else _path([Vector2(CORRIDOR_X, local.z), BOARD_SPOT])
	var aisle := WEST_AISLE if local.x < (WEST_AISLE + EAST_AISLE) / 2 else EAST_AISLE
	return _path([Vector2(aisle, local.z), Vector2(aisle, BACK_ROW), BLOCK_OUT, Vector2(CORRIDOR_X, -7.5), BOARD_SPOT])


## A fuse lying at `at` (world space).
func spawn_fuse(at: Vector3) -> Fuse:
	var fuse := Fuse.new()
	fuse.name = "Fuse"
	prison.add_child(fuse, true)
	fuse.global_position = at
	return fuse


## The three fuses are in: the lamps come on, the cells with someone in them lock and the loose ones give up.
func lights_back() -> void:
	if lights_on:
		return
	lights_on = true
	_pull_left = 0.0
	prison.set_lights(true)
	for inmate in inmates:
		var escort := OwnerEscort.of(inmate) as BlackoutEscort
		if escort and escort.in_car:
			prison.cell_door(escort.cell).lock()
		if not inmate.is_escaped:
			inmate.surrender()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_LIGHTS_BACK")
	lights_came_back.emit()


## Whether El Chispa ended up in the punishment cell, shut in (the extra, step 6).
func chispa_punished() -> bool:
	var escort := OwnerEscort.of(chispa) as BlackoutEscort
	return escort != null and escort.in_car and escort.cell == PrisonLevel.PUNISHMENT_CELL \
		and not prison.punishment_door.is_open


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


func _on_board_changed(filled: int) -> void:
	if filled > 0 and not board.is_complete() and not _pulling:
		_pull_left = PULL_DELAY


func _on_dropped_fuse(_inmate: BlackoutInmate, at: Vector3) -> void:
	_pulling = false
	_pull_left = 0.0
	spawn_fuse(at)


## El Chispa's turn: once the countdown runs out while he's free he heads for the board, and there he pulls the last
## fuse out and tosses it to one of LOOSE_SPOTS.
func _chispa(delta: float) -> void:
	if lights_on or not chispa or not chispa.has_fuse or not board or board.filled == 0:
		_pulling = false
		return
	if not chispa.is_free():
		return
	if not _pulling:
		_pull_left -= delta
		if _pull_left > 0.0:
			return
		_pulling = true
		chispa.head_for(route_to_board(chispa.global_position))
		chispa.say("CHISPA_GOES")
	if chispa.global_position.distance_to(board.global_position * Vector3(1, 0, 1)
			+ Vector3.UP * chispa.global_position.y) > PULL_REACH:
		return
	_pulling = false
	if board.pull():
		chispa.say("CHISPA_PULLS")
		spawn_fuse(prison.global_transform * LOOSE_SPOTS[_rng.randi_range(0, LOOSE_SPOTS.size() - 1)])
	if board.filled > 0:
		_pull_left = PULL_DELAY


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
	_chispa(delta)
	_check_left -= delta
	if _check_left > 0.0:
		return
	_check_left = LIGHT_CHECK
	for inmate in inmates:
		if not inmate.is_escaped:
			inmate.set_lit(lit(inmate))
