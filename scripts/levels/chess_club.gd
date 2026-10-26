class_name ChessClub
extends InfiltrationPlace

## The chess club "El Peón Dormido" (docs/diseno/infiltracion-ajedrez.md, steps 2 to 4, decision 175): one floor on its own
## city lot, the front to +Z. The doorkeeper stands inside the entrance and only lets members through; the hall with
## its eight chess tables on a checkered floor and the trophy cabinet, and the cafeteria east of it (with the locked
## door of the Gran Maestro's office); behind, the tournament room with the stage where the Gran Maestro plays and his
## audience, and the storeroom of boards east of it. Each table has its board with a game halfway through
## (ChessBoard), its clock (ChessClock) and a stool behind each seat (step 3). The gang's members stand at the tables'
## seats, drawn with the seed; the seats left are for the cops (to play is to stand at a seat, hands free for the
## pieces). Every so often a member challenges a cop to a game on the clock (ChessGames, step 4). The whole club is for members only. The cops start in the
## station, where the disguises are, and drive here. --place=chess opens it from Play. Every number here is
## (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway in the middle of the front wall, into the hall.
const ENTRANCE_X := 0.0
## The wall between the hall (west) and the cafeteria (east) at CAFE_X, with its doorway at CAFE_DOOR_Z.
const CAFE_X := 4.0
const CAFE_DOOR_Z := 5.0
## The back wall at BACK_Z: the tournament room's doorway at TOURNEY_DOOR_X and the office's locked door, from the
## cafeteria, at OFFICE_DOOR_X. Behind, east of CAFE_X, the office (north of STORE_Z) and the storeroom (south of it,
## its doorway from the tournament room at STORE_DOOR_Z).
const BACK_Z := 0.0
const TOURNEY_DOOR_X := -4.0
const OFFICE_DOOR_X := 8.0
const STORE_Z := -5.0
const STORE_DOOR_Z := -7.5
## The hall's chess tables, a seat on each side of each (north facing +Z, south facing -Z).
const TABLES: Array[Vector3] = [Vector3(-10.0, 0, 2.6), Vector3(-7.0, 0, 2.6), Vector3(-4.0, 0, 2.6),
	Vector3(-1.0, 0, 2.6), Vector3(-10.0, 0, 6.0), Vector3(-7.0, 0, 6.0), Vector3(-4.0, 0, 6.0), Vector3(-1.0, 0, 6.0)]
const TABLE_SIZE := Vector3(1.3, 0.75, 1.0)
const SEAT_OFF := 0.8
## On each table, west of the middle, the board, and east of it the clock.
const BOARD_X := -0.15
const CLOCK_X := 0.45
## A seat's stool, this far further from the table than where the player stands.
const STOOL_BEHIND := 0.4
## How many members of the gang stand at the tables (the seed picks their seats).
const PLAYERS := 6
## The stage in the tournament room with the Gran Maestro's table on it; he sits north of it facing the door (+Z), his
## rival south of it.
const STAGE_AT := Vector3(-4.0, 0, -6.5)
const STAGE_SIZE := Vector3(5.0, 0.35, 3.5)
const ALFIL_AT := Vector3(-4.0, 0, -7.3)
const RIVAL_AT := Vector3(-4.0, 0, -5.7)
## Where the tournament's audience stands, looking at the stage (the seed picks AUDIENCE of them).
const AUDIENCE_SPOTS: Array[Vector3] = [Vector3(-7.5, 0, -2.6), Vector3(-1.5, 0, -2.4), Vector3(0.5, 0, -3.6)]
const AUDIENCE := 2
## The trophy cabinet on the hall's west wall, the cafeteria's counter and the doorkeeper inside the entrance.
const CABINET_AT := Vector3(-HALF_X + 0.35, 0, 8.4)
const COUNTER_AT := Vector3(9.5, 0, 8.4)
const DOORKEEPER_AT := Vector3(ENTRANCE_X + 1.2, 0, HALF_Z - 1.2)
const SQUARE := 2.0

const OUTSIDE := Color(0.3, 0.32, 0.36)
const INSIDE := Color(0.88, 0.84, 0.74)
const FLOOR := Color(0.45, 0.32, 0.22)
const DARK_SQUARE := Color(0.2, 0.2, 0.22)
const LIGHT_SQUARE := Color(0.92, 0.9, 0.84)
const WOOD := Color(0.48, 0.3, 0.18)

var office_door: FrontDoor
## The seats no member took, for the cops: [position, turn].
var free_seats: Array[Array] = []
var alfil: ClubMember
var rival: ClubMember
var doorman: ClubDoorman
## Each hall table's board and clock (by TABLES' order), and the Gran Maestro's on the stage.
var boards: Array[ChessBoard] = []
var clocks: Array[ChessClock] = []
var stage_board: ChessBoard
var stage_clock: ChessClock
var games: ChessGames
var _build: PlaceBuilder


func _ready() -> void:
	variant = "chess"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_hall()
	_build_back_rooms()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)
	_add_people()
	games = ChessGames.new()
	games.name = "Games"
	games.club = self
	games.case_seed = case_seed
	add_child(games)
	place_in_city("chess")


## The Gran Maestro rides off from the street, out of the entrance (step 6).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


## Every seat at the tables: [position, turn] (turn 0 faces -Z).
static func seats() -> Array[Array]:
	var all: Array[Array] = []
	for at in TABLES:
		all.append([at + Vector3(0, 0, -SEAT_OFF), PI])
		all.append([at + Vector3(0, 0, SEAT_OFF), 0.0])
	return all


func _local(at: Vector3) -> Vector3:
	return global_transform.affine_inverse() * at


## Whether a world position is inside the club.
func is_inside(at: Vector3) -> bool:
	var local := _local(at)
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is in the hall with the tables.
func in_hall(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z > BACK_Z and local.x < CAFE_X


## Whether a world position is in the cafeteria.
func in_cafe(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z > BACK_Z and local.x > CAFE_X


## Whether a world position is in the tournament room.
func in_tournament(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.x < CAFE_X


## Whether a world position is in the storeroom.
func in_storeroom(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < STORE_Z and local.x > CAFE_X


## Whether a world position is in the Gran Maestro's office.
func in_back_room(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.z > STORE_Z and local.x > CAFE_X


## The members at their seats, drawn with the seed; the Gran Maestro and his rival on the stage and the audience
## watching them; the doorkeeper by the entrance and their suspicion.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["chess members", case_seed])
	free_seats = seats()
	for i in PLAYERS:
		var seat: Array = free_seats.pop_at(rng.randi_range(0, free_seats.size() - 1))
		_add_member("ajedrecista" if rng.randf() < 0.5 else "ajedrecista_b", seat[0], seat[1], rng)
	var spots := AUDIENCE_SPOTS.duplicate()
	for i in AUDIENCE:
		var spot: Vector3 = spots.pop_at(rng.randi_range(0, spots.size() - 1))
		var facing := STAGE_AT - spot
		_add_member("ajedrecista" if rng.randf() < 0.5 else "ajedrecista_b", spot, atan2(-facing.x, -facing.z), rng)
	_add_member("ajedrecista", RIVAL_AT + Vector3(0, STAGE_SIZE.y, 0), 0.0, rng)
	rival = members.back()
	alfil = ClubMember.new()
	alfil.name = "Alfil"
	alfil.look = "alfil"
	add_child(alfil)
	alfil.position = ALFIL_AT + Vector3(0, FLOOR_TOP + STAGE_SIZE.y, 0)
	alfil.rotation.y = PI
	boss = alfil
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	doorman.look = "conserje"
	doorman.disguise_look = "chess"
	add_child(doorman)
	doorman.position = DOORKEEPER_AT + Vector3(0, FLOOR_TOP, 0)
	doorman.rotation.y = PI / 2
	doorman.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = alfil
	suspicion.boss_found_out = "ALFIL_FOUND_OUT"
	suspicion.disguise_look = "chess"
	suspicion.prefix = "CHESS_"
	suspicion.inside = is_inside
	suspicion.in_back_room = in_back_room
	add_child(suspicion)


func _add_member(look: String, spot: Vector3, turn: float, rng: RandomNumberGenerator) -> void:
	var member := ClubMember.new()
	member.name = "Member%d" % members.size()
	member.look = look
	member.next_line = rng.randi_range(0, ClubMember.TALK[look][1] - 1)
	add_child(member)
	member.position = spot + Vector3(0, FLOOR_TOP, 0)
	member.rotation.y = turn
	members.append(member)


## Floor, outer walls with the entrance, the roof, the sign, the hall's and cafeteria's walls and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	_build.wall("z", CAFE_X, BACK_Z, HALF_Z, 0, [CAFE_DOOR_Z], INSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_CHESS"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-6.0, 2.5, 7.0]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The hall's checkered floor, the tables with their boards and chairs, the trophy cabinet and the cafeteria's counter.
func _build_hall() -> void:
	var cols := int((CAFE_X + HALF_X) / SQUARE)
	var rows := int((HALF_Z - BACK_Z) / SQUARE)
	for col in cols:
		for row in rows:
			var center := Vector3(-HALF_X + (col + 0.5) * SQUARE, FLOOR_TOP + 0.003, BACK_Z + (row + 0.5) * SQUARE)
			_build.mesh_box(center, Vector3(SQUARE, 0.006, SQUARE), DARK_SQUARE if (col + row) % 2 == 0 else LIGHT_SQUARE)
	for at in TABLES:
		_table(at)
	_build.box(CABINET_AT + Vector3(0, FLOOR_TOP + 1.0, 0), Vector3(0.6, 2.0, 2.4), WOOD.darkened(0.25))
	_build.mesh_box(CABINET_AT + Vector3(0.31, FLOOR_TOP + 1.1, 0), Vector3(0.02, 1.6, 2.2), Color(0.75, 0.88, 0.95))
	for i in 3:
		var cup := CylinderMesh.new()
		cup.top_radius = 0.12
		cup.bottom_radius = 0.05
		cup.height = 0.3
		_build.mesh(cup, CABINET_AT + Vector3(0.1, FLOOR_TOP + 1.25, -0.7 + i * 0.7), Color(0.95, 0.8, 0.3))
	_build.box(COUNTER_AT + Vector3(0, FLOOR_TOP + 0.55, 0), Vector3(3.0, 1.1, 0.7), WOOD)
	_build.mesh_box(COUNTER_AT + Vector3(0.8, FLOOR_TOP + 1.3, 0), Vector3(0.4, 0.4, 0.35), Color(0.2, 0.2, 0.22))
	for at: Vector3 in [Vector3(7.0, 0, 3.0), Vector3(10.0, 0, 3.0)]:
		_build.box(at + Vector3(0, FLOOR_TOP + 0.38, 0), Vector3(1.0, 0.76, 1.0), WOOD.lightened(0.1))


## A chess table with its board and its clock on top and a stool behind each seat.
func _table(at: Vector3, raised := 0.0) -> void:
	var base := at + Vector3(0, FLOOR_TOP + raised, 0)
	_build.box(base + Vector3(0, TABLE_SIZE.y / 2, 0), TABLE_SIZE, WOOD)
	var board := ChessBoard.new()
	board.name = "Board%d" % boards.size() if raised == 0.0 else "StageBoard"
	add_child(board)
	board.position = base + Vector3(BOARD_X, TABLE_SIZE.y + 0.021, 0)
	var clock := ChessClock.new()
	clock.name = "Clock%d" % clocks.size() if raised == 0.0 else "StageClock"
	add_child(clock)
	clock.position = base + Vector3(CLOCK_X, TABLE_SIZE.y, 0)
	if raised == 0.0:
		boards.append(board)
		clocks.append(clock)
	else:
		stage_board = board
		stage_clock = clock
	for side: float in [-1.0, 1.0]:
		var stool := base + Vector3(0, 0.23, side * (SEAT_OFF + STOOL_BEHIND))
		_build.box(stool, Vector3(0.4, 0.46, 0.4), WOOD.darkened(0.3))


## The tournament room's stage with the Gran Maestro's table and the audience's benches, the office with its desk and
## the storeroom with its shelves of boards.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [TOURNEY_DOOR_X, OFFICE_DOOR_X], INSIDE)
	_build.wall("z", CAFE_X, -HALF_Z, BACK_Z, 0, [STORE_DOOR_Z], INSIDE)
	_build.wall("x", STORE_Z, CAFE_X, HALF_X, 0, [], INSIDE)
	_build.box(STAGE_AT + Vector3(0, FLOOR_TOP + STAGE_SIZE.y / 2, 0), STAGE_SIZE, Color(0.55, 0.12, 0.14))
	_table(STAGE_AT, STAGE_SIZE.y)
	for x: float in [-9.0, 1.0]:
		_build.box(Vector3(x, FLOOR_TOP + 0.22, -1.2), Vector3(2.4, 0.44, 0.5), WOOD.darkened(0.2))
	_build.box(Vector3(8.5, FLOOR_TOP + 0.4, -3.0), Vector3(2.4, 0.8, 1.0), WOOD.darkened(0.2))
	for x: float in [6.0, 10.0]:
		_build.box(Vector3(x, FLOOR_TOP + 0.9, -HALF_Z + 0.35), Vector3(2.4, 1.8, 0.5), WOOD)
		for shelf in 3:
			_build.mesh_box(Vector3(x, FLOOR_TOP + 0.4 + shelf * 0.55, -HALF_Z + 0.62), Vector3(2.0, 0.08, 0.04),
				LIGHT_SQUARE if shelf % 2 == 0 else DARK_SQUARE)
