class_name Mansion
extends CrimeScenePlace

## The Candelabro mansion on its hill (escena-mansion.md, step 1, decision 270), with the front to +Z. One big floor:
## in front, the dining room (west), the hall with the boarded-up stairs, the grandfather clock and the armour, and the
## lounge with the piano and the fireplace (east); behind, the library, doña Clotilde's study with the open safe, the
## greenhouse and the butler's pantry with the bell board. Three walls are double: the secret passages run inside them
## (step 2). Out the back, the garden with the hedge maze (the getaway, step 6). The people come in step 3 and the case
## in step 5. Every number here is (propuesta).

## The house: x from -HALF_X to HALF_X, z from BACK_Z to FRONT_Z.
const HALF_X := 16.0
const BACK_Z := -11.0
const FRONT_Z := 11.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The wall between the front rooms and the back ones, and the front rooms' side walls.
const MIDDLE_Z := 1.0
const HALL_X := 4.0
## The back rooms' walls: library | study | greenhouse | pantry.
const LIBRARY_X := -7.0
const STUDY_X := -1.0
const PANTRY_X := 8.0
## The passages are 1.4 m wide, inside double walls (PASSAGES: where each runs, and the doorways in its two walls:
## its way in and its way out). Each one is a SecretPassage (step 2).
const PASSAGE_WIDTH := 1.4
const PASSAGES := {
	"bookcase": {"axis": "z", "fixed": LIBRARY_X, "from": BACK_Z, "to": MIDDLE_Z,
		"in": Vector3(LIBRARY_X - PASSAGE_WIDTH / 2, 0, -4.0), "out": Vector3(LIBRARY_X + PASSAGE_WIDTH / 2, 0, -8.0)},
	"clock": {"axis": "x", "fixed": MIDDLE_Z, "from": 0.0, "to": HALL_X,
		"in": Vector3(2.0, 0, MIDDLE_Z + PASSAGE_WIDTH / 2), "out": Vector3(0.8, 0, MIDDLE_Z - PASSAGE_WIDTH / 2)},
	"fireplace": {"axis": "x", "fixed": MIDDLE_Z, "from": 9.0, "to": 15.0,
		"in": Vector3(12.0, 0, MIDDLE_Z + PASSAGE_WIDTH / 2), "out": Vector3(14.0, 0, MIDDLE_Z - PASSAGE_WIDTH / 2)},
}
const DOOR_FRONT_X := 0.0
## The doors in the middle wall: dining room -> library, hall -> study, lounge -> greenhouse.
const DOORS_MIDDLE: Array[float] = [-12.0, -2.5, 6.0]
## The doors in the front rooms' side walls, and in the back rooms' walls.
const DOOR_SIDE_Z := 7.0
const DOOR_BACK_Z := -5.0
const DOOR_GARDEN_X := 3.5
## The rooms, in the house's space: [x0, x1, z0, z1].
const ROOMS := {
	"dining": [-HALF_X, -HALL_X, MIDDLE_Z, FRONT_Z],
	"hall": [-HALL_X, HALL_X, MIDDLE_Z, FRONT_Z],
	"lounge": [HALL_X, HALF_X, MIDDLE_Z, FRONT_Z],
	"library": [-HALF_X, LIBRARY_X, BACK_Z, MIDDLE_Z],
	"study": [LIBRARY_X, STUDY_X, BACK_Z, MIDDLE_Z],
	"greenhouse": [STUDY_X, PANTRY_X, BACK_Z, MIDDLE_Z],
	"pantry": [PANTRY_X, HALF_X, BACK_Z, MIDDLE_Z],
}
## What's in the rooms.
const TABLE_AT := Vector3(-10.0, 0, 6.0)
const TABLE_SIZE := Vector3(7.0, 0.78, 1.6)
const CLOCK_AT := Vector3(2.0, 0, MIDDLE_Z + 1.0)
const ARMOUR_AT := Vector3(-3.2, 0, 4.0)
const COAT_RACK_AT := Vector3(-3.3, 0, 9.8)
const STAIRS_AT := Vector3(-0.8, 0, 4.0)
const PIANO_AT := Vector3(9.0, 0, 9.4)
const FIREPLACE_AT := Vector3(12.0, 0, MIDDLE_Z + 1.0)
const CANDELABRA_AT := FIREPLACE_AT + Vector3(0.6, 1.55, 0)
const CAGE_AT := Vector3(15.0, 0, 9.5)
const SHELVES_X := -HALF_X + 0.35
const BOOKCASE_AT := Vector3(LIBRARY_X - 0.95, 0, -4.0)
const ARMCHAIR_AT := Vector3(-12.0, 0, -6.0)
const LIBRARY_FIRE_AT := Vector3(-11.5, 0, BACK_Z + 0.45)
const SAFE_AT := Vector3(-4.0, 0, BACK_Z + 0.45)
const DESK_AT := Vector3(-4.0, 0, -6.0)
const PORTRAIT_AT := Vector3(LIBRARY_X + PASSAGE_WIDTH / 2 + 0.09, 1.6, -8.0)
const PLANTS: Array[Vector3] = [
	Vector3(1.0, 0, -9.0), Vector3(5.5, 0, -9.0), Vector3(1.0, 0, -3.0), Vector3(6.0, 0, -2.5),
]
const BELL_BOARD_AT := Vector3(HALF_X - 0.12, 1.7, -5.0)
const BELL_ROOMS: Array[String] = ["dining", "hall", "lounge", "library", "study", "greenhouse"]
const PANTRY_SHELF_AT := Vector3(12.0, 0, BACK_Z + 0.4)
## Where the members wait, two spots per room (a third in the same room stands next to the first); the butler by his
## bell board.
const MEMBER_SPOTS := {
	"dining": [Vector3(-13.0, 0, 3.0), Vector3(-7.0, 0, 9.0)],
	"hall": [Vector3(-2.0, 0, 9.0), Vector3(3.0, 0, 4.0)],
	"lounge": [Vector3(6.5, 0, 9.5), Vector3(14.5, 0, 7.0)],
	"library": [Vector3(-12.0, 0, -3.0), Vector3(-9.5, 0, -8.5)],
	"study": [Vector3(-5.5, 0, -2.5), Vector3(-2.5, 0, -8.5)],
	"greenhouse": [Vector3(3.0, 0, -6.0), Vector3(3.5, 0, -1.0)],
	"pantry": [Vector3(10.5, 0, -6.0), Vector3(12.5, 0, -1.8)],
}
## Every this many seconds one member goes through a secret passage to the room at its other end (step 4).
const MOVE_EVERY := 60.0
## Doña Clotilde's box of chocolates, on the dining table.
const CHOCOLATES_AT := TABLE_AT + Vector3(0.6, TABLE_SIZE.y + 0.05, 0.2)
const CHOCOLATES_SCENE := preload("res://scenes/props/chocolate_box.tscn")
const BUTLER_AT := Vector3(14.5, 0, -3.5)
## The bell cord in each room with a bell (BellCord, step 5b), against a wall.
const BELL_CORDS := {
	"dining": Vector3(-HALF_X + 0.15, 0, 3.0), "hall": Vector3(HALL_X - 0.15, 0, 10.0),
	"lounge": Vector3(HALF_X - 0.15, 0, 3.5), "library": Vector3(-14.5, 0, BACK_Z + 0.15),
	"study": Vector3(-5.6, 0, BACK_Z + 0.15), "greenhouse": Vector3(PANTRY_X - 0.15, 0, -9.0),
}
## The culprit's way out of each room to the garden door (step 6), through the house's doors, in the house's space.
const WAY_OUT := {
	"greenhouse": [],
	"study": [Vector3(-2.0, 0, DOOR_BACK_Z), Vector3(0.0, 0, DOOR_BACK_Z)],
	"pantry": [Vector3(9.0, 0, DOOR_BACK_Z), Vector3(7.0, 0, DOOR_BACK_Z)],
	"lounge": [Vector3(6.0, 0, 2.0), Vector3(6.0, 0, 0.0)],
	"hall": [Vector3(-2.0, 0, 2.0), Vector3(-2.5, 0, 0.0), Vector3(-2.0, 0, DOOR_BACK_Z), Vector3(0.0, 0, DOOR_BACK_Z)],
	"dining": [Vector3(-4.5, 0, DOOR_SIDE_Z), Vector3(-3.5, 0, DOOR_SIDE_Z), Vector3(-2.0, 0, 2.0),
		Vector3(-2.5, 0, 0.0), Vector3(-2.0, 0, DOOR_BACK_Z), Vector3(0.0, 0, DOOR_BACK_Z)],
	"library": [Vector3(-12.0, 0, 0.0), Vector3(-12.0, 0, 2.0), Vector3(-4.5, 0, DOOR_SIDE_Z),
		Vector3(-3.5, 0, DOOR_SIDE_Z), Vector3(-2.0, 0, 2.0), Vector3(-2.5, 0, 0.0), Vector3(-2.0, 0, DOOR_BACK_Z),
		Vector3(0.0, 0, DOOR_BACK_Z)],
}
## The cork board (CrimeBoard) on the library's west wall, its stamp beside it (step 5).
const BOARD_AT := Transform3D(Basis(Vector3.UP, PI / 2), Vector3(-HALF_X + 0.2, 0, -3.5))
const STAMP_AT := Vector3(-14.5, 0, 0.0)
## What was stolen, drawn with the case seed: doña Clotilde's will, the Snoring Diamond or the Flan Recipe.
const LOOTS: Array[String] = ["will", "diamond", "recipe"]
const LOOT_MODELS := {
	"will": preload("res://assets/models/mansion_will.glb"),
	"diamond": preload("res://assets/models/snoring_diamond.glb"),
	"recipe": preload("res://assets/models/flan_recipe.glb"),
}
## Where it's hidden, drawn with the seed (step 5c): among the capes on the hall's coat rack, under the piano's lid or
## in the dusty trunk at the dead end of the bookcase's passage (TRUNK_AT).
const LOOT_SPOTS: Array[String] = ["coat_rack", "piano", "dusty_trunk"]
const TRUNK_AT := Vector3(LIBRARY_X, 0, MIDDLE_Z - 1.5)
const TRUNK := preload("res://assets/models/dusty_trunk.glb")
## Out front, the gravel drive where the patrol car stops; out the back, the hedge maze (MAZE_CELLS cells of
## MAZE_CELL m, one of them its way in by the back door and one its gate at the far end).
const DRIVE_Z := 17.0
const PATROL_CAR_AT := Vector3(-4.0, 0, DRIVE_Z)
const COP_AT := Vector3(0, 0.1, FRONT_Z + 2.5)
const MAZE_CELLS := Vector2i(7, 5)
const MAZE_CELL := 3.0
const MAZE_Z := BACK_Z - 3.0
const HEDGE_HEIGHT := 1.9
## Same maze every match: it's the mansion's.
const MAZE_SEED := 270
const GROUND_SIZE := 140.0
## The lamps hang one every this many meters across a room; the lit windows, front and back.
const LAMP_EVERY := 6.0
const WINDOWS_X: Array[float] = [-13.0, -8.0, 8.0, 13.0]
const STONE := Color(0.55, 0.52, 0.5)
const WALLPAPER := Color(0.42, 0.18, 0.22)
const PANEL := Color(0.36, 0.24, 0.16)
const PARQUET := Color(0.45, 0.3, 0.18)
const GLASS := Color(0.75, 0.9, 0.85, 0.35)
const HEDGE := Color(0.16, 0.34, 0.16)
const GRASS := Color(0.2, 0.3, 0.17)
const GRAVEL := Color(0.6, 0.58, 0.54)
const BRASS := Color(0.8, 0.65, 0.3)
const BLACK := Color(0.1, 0.09, 0.09)
const IVORY := Color(0.94, 0.92, 0.86)
const WINDOW_LIGHT := Color(1.0, 0.8, 0.4)
const BOOK_COLORS: Array[Color] = [Color(0.55, 0.12, 0.12), Color(0.15, 0.3, 0.2), Color(0.2, 0.22, 0.45),
	Color(0.6, 0.45, 0.2)]

## The maze's open walls, by cell: [x, z] -> the sides ("e", "s") with no hedge.
var maze_open := {}
## The secret passages, by id (SecretPassage).
var passages := {}
## The people (step 3): the six members of the club in the case's order, doña Clotilde, the butler and the parrot.
var members: Array[MysteryMember] = []
var clotilde: MansionOwner
var butler: MansionButler
var parrot: MansionParrot
var chocolates: ChocolateBox
var armour: MansionArmour
## The case (step 5), and what was stolen (LOOTS).
var case: CrimeSceneCase
var loot := ""
var loot_found := false
var clues: MansionClues
var loot_spot := ""
## Each hiding spot's LootSpot, by name.
var loot_spots := {}
var _move_left := MOVE_EVERY
var _move_rng := RandomNumberGenerator.new()
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("mansion")
	variant = "mansion"
	_builder = PlaceBuilder.new(self)
	_ground()
	_shell()
	_walls()
	_hall()
	_dining()
	_lounge()
	_library()
	_study()
	_greenhouse()
	_pantry()
	_passages()
	_maze()
	_people()
	_loot_spots()


## Which room a point in the world is in ("" if none).
func room_at(world: Vector3) -> String:
	if passage_at(world) != "":
		return ""
	var local := to_local(world)
	for room: String in ROOMS:
		var r: Array = ROOMS[room]
		if local.x > r[0] and local.x < r[1] and local.z > r[2] and local.z < r[3]:
			return room
	return ""


## Whether a point in the world is inside the house (not in a passage or outdoors).
func inside(world: Vector3) -> bool:
	return room_at(world) != ""


## Whether a point in the world is inside a secret passage, and which.
func passage_at(world: Vector3) -> String:
	var local := to_local(world)
	for id: String in PASSAGES:
		var p: Dictionary = PASSAGES[id]
		var across: float = local.x if p.axis == "z" else local.z
		var along: float = local.z if p.axis == "z" else local.x
		if absf(across - p.fixed) < PASSAGE_WIDTH / 2 and along > p.from and along < p.to:
			return id
	return ""


## The house, the garden and the drive are the scene.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	var maze_end := MAZE_Z - MAZE_CELLS.y * MAZE_CELL - 2.0
	return absf(local.x) < HALF_X + 4.0 and local.z > maze_end and local.z < DRIVE_Z + 4.0


## The maze cell a point in the house's space is in, or (-1, -1) out of it.
static func maze_cell(local: Vector3) -> Vector2i:
	var x := floori((local.x + MAZE_CELLS.x * MAZE_CELL / 2) / MAZE_CELL)
	var z := floori((MAZE_Z - local.z) / MAZE_CELL)
	if x < 0 or z < 0 or x >= MAZE_CELLS.x or z >= MAZE_CELLS.y:
		return Vector2i(-1, -1)
	return Vector2i(x, z)


## The middle of a maze cell, in the house's space.
static func maze_center(cell: Vector2i) -> Vector3:
	return Vector3((cell.x + 0.5) * MAZE_CELL - MAZE_CELLS.x * MAZE_CELL / 2, 0, MAZE_Z - (cell.y + 0.5) * MAZE_CELL)


## The maze's way in (by the back door) and its gate (at the far end).
static func maze_entry() -> Vector2i:
	return Vector2i(MAZE_CELLS.x / 2, 0)


static func maze_gate() -> Vector2i:
	return Vector2i(MAZE_CELLS.x - 1, MAZE_CELLS.y - 1)


## Whether the maze lets you walk from one cell to its neighbour.
func maze_joined(a: Vector2i, b: Vector2i) -> bool:
	var first := a if a.x + a.y < b.x + b.y else b
	var second := b if first == a else a
	var side := "e" if second.x > first.x else "s"
	return (maze_open.get(first, []) as Array).has(side) and (second - first).length_squared() == 1


## The grass all around, the gravel drive and the path to the door.
func _ground() -> void:
	_builder.slab(-GROUND_SIZE / 2, GROUND_SIZE / 2, -GROUND_SIZE / 2, GROUND_SIZE / 2, 0.0, GRASS)
	_builder.mesh_box(Vector3(0, 0.01, DRIVE_Z), Vector3(16.0, 0.02, 6.0), GRAVEL)
	_builder.mesh_box(Vector3(0, 0.01, (FRONT_Z + DRIVE_Z) / 2), Vector3(2.4, 0.02, DRIVE_Z - FRONT_Z), GRAVEL)


## The floor, the roof with its lamps and the outer walls, with the front door and the garden door.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, PARQUET)
	_builder.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, ROOF, BLACK)
	_builder.wall("x", FRONT_Z, -HALF_X, HALF_X, 0, [DOOR_FRONT_X], STONE)
	_builder.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [DOOR_GARDEN_X], STONE)
	_builder.wall("z", -HALF_X, BACK_Z, FRONT_Z, 0, [], STONE)
	_builder.wall("z", HALF_X, BACK_Z, FRONT_Z, 0, [], STONE)
	var roof := PrismMesh.new()
	roof.size = Vector3(FRONT_Z - BACK_Z + 1.0, 3.0, HALF_X * 2 + 1.0)
	_builder.mesh(roof, Vector3(0, ROOF + 1.5, (FRONT_Z + BACK_Z) / 2), BLACK.lightened(0.15), Vector3(0, PI / 2, 0))
	for x: float in WINDOWS_X:
		_builder.mesh_box(Vector3(x, 1.5, FRONT_Z + 0.09), Vector3(1.0, 1.4, 0.02), WINDOW_LIGHT)
		_builder.mesh_box(Vector3(x, 1.5, BACK_Z - 0.09), Vector3(1.0, 1.4, 0.02), WINDOW_LIGHT)
	var glow := _builder.material(WINDOW_LIGHT)
	glow.emission_enabled = true
	glow.emission = WINDOW_LIGHT
	for room: String in ROOMS:
		var r: Array = ROOMS[room]
		var across := ceili((r[1] - r[0]) / LAMP_EVERY)
		for i in across:
			var x: float = lerpf(r[0], r[1], (i + 0.5) / across)
			var lamp := _builder.light(Vector3(x, ROOF - 0.5, (r[2] + r[3]) / 2))
			lamp.light_energy = 1.4
			lamp.omni_range = 9.0


## The inner walls. The middle one is double where the clock's and the fireplace's passages run, and so is the one
## between the library and the study (the bookcase's); each double wall is closed at its ends.
func _walls() -> void:
	var half := PASSAGE_WIDTH / 2
	var clock: Dictionary = PASSAGES.clock
	var fire: Dictionary = PASSAGES.fireplace
	_builder.wall("x", MIDDLE_Z, -HALF_X, clock.from, 0, DOORS_MIDDLE.slice(0, 2), WALLPAPER)
	_builder.wall("x", MIDDLE_Z, clock.to, fire.from, 0, [DOORS_MIDDLE[2]], WALLPAPER)
	_builder.wall("x", MIDDLE_Z, fire.to, HALF_X, 0, [], WALLPAPER)
	for p: Dictionary in [clock, fire]:
		_builder.wall("x", MIDDLE_Z - half, p.from, p.to, 0, [p.out.x], PANEL)
		_builder.wall("x", MIDDLE_Z + half, p.from, p.to, 0, [p["in"].x], PANEL)
		_builder.wall("z", p.from, MIDDLE_Z - half, MIDDLE_Z + half, 0, [], PANEL)
		_builder.wall("z", p.to, MIDDLE_Z - half, MIDDLE_Z + half, 0, [], PANEL)
	var shelf: Dictionary = PASSAGES.bookcase
	_builder.wall("z", LIBRARY_X - half, BACK_Z, MIDDLE_Z - 0.1, 0, [shelf["in"].z], PANEL)
	_builder.wall("z", LIBRARY_X + half, BACK_Z, MIDDLE_Z - 0.1, 0, [shelf.out.z], PANEL)
	_builder.wall("z", -HALL_X, MIDDLE_Z, FRONT_Z, 0, [DOOR_SIDE_Z], WALLPAPER)
	_builder.wall("z", HALL_X, MIDDLE_Z, FRONT_Z, 0, [DOOR_SIDE_Z], WALLPAPER)
	_builder.wall("z", STUDY_X, BACK_Z, MIDDLE_Z, 0, [DOOR_BACK_Z], WALLPAPER)
	_builder.wall("z", PANTRY_X, BACK_Z, MIDDLE_Z, 0, [DOOR_BACK_Z], WALLPAPER)


## The hall: the stairs nobody goes up (boarded up), the suit of armour (MansionArmour) and the coat rack by the door.
## The grandfather clock against the back wall is its passage's door (_passages).
func _hall() -> void:
	for i in 6:
		var top := (i + 1) * GameScale.STEP_HEIGHT
		_builder.box(STAIRS_AT + Vector3(0, top / 2, -i * 0.3), Vector3(2.0, top, 0.3), PANEL)
	for y: float in [0.9, 1.3]:
		_builder.box(STAIRS_AT + Vector3(0, y, 0.3), Vector3(2.2, 0.15, 0.05), PARQUET)
	_builder.box(ARMOUR_AT + Vector3(0, 0.05, 0), Vector3(0.6, 0.1, 0.6), STONE)
	armour = MansionArmour.new()
	armour.name = "Armour"
	armour.position = ARMOUR_AT + Vector3(0, 0.1, 0)
	add_child(armour)
	_builder.box(COAT_RACK_AT + Vector3(0, 0.9, 0), Vector3(0.1, 1.8, 0.1), PANEL)


## The long table still laid for the club's dinner, with its chairs and two candelabras.
func _dining() -> void:
	_builder.box(TABLE_AT + Vector3(0, TABLE_SIZE.y - 0.03, 0), Vector3(TABLE_SIZE.x, 0.06, TABLE_SIZE.z), PARQUET)
	_builder.legs(TABLE_AT, Vector2(TABLE_SIZE.x, TABLE_SIZE.z), TABLE_SIZE.y - 0.06, PARQUET)
	_builder.mesh_box(TABLE_AT + Vector3(0, TABLE_SIZE.y + 0.005, 0), Vector3(TABLE_SIZE.x - 0.3, 0.01, 1.0), IVORY)
	for i in 6:
		var x := TABLE_AT.x + (i % 3 - 1) * 2.2
		var side := 1.0 if i < 3 else -1.0
		_builder.box(TABLE_AT + Vector3(x - TABLE_AT.x, 0.25, side * 1.2), Vector3(0.5, 0.5, 0.5), PANEL)
	for dx: float in [-1.8, 1.8]:
		_builder.mesh_box(TABLE_AT + Vector3(dx, TABLE_SIZE.y + 0.25, 0), Vector3(0.08, 0.5, 0.08), BRASS)


## The piano, the fireplace against the middle wall (low: a cop crouches to go in; its back is the passage's door and
## the candelabra on the mantel opens it, _passages). Lorenzo's cage by the window is _people's.
func _lounge() -> void:
	_builder.box(PIANO_AT + Vector3(0, 0.5, 0), Vector3(1.6, 1.0, 1.2), BLACK)
	_builder.mesh_box(PIANO_AT + Vector3(0, 0.75, 0.62), Vector3(1.4, 0.05, 0.05), IVORY)
	_builder.box(FIREPLACE_AT + Vector3(-0.85, 0.6, 0), Vector3(0.3, 1.2, 0.5), STONE)
	_builder.box(FIREPLACE_AT + Vector3(0.85, 0.6, 0), Vector3(0.3, 1.2, 0.5), STONE)
	_builder.box(FIREPLACE_AT + Vector3(0, 1.3, 0), Vector3(2.0, 0.2, 0.6), STONE)


## Shelves of books along the west wall up to the board (BOARD_AT), the leather armchair and a small fireplace on the
## back wall. The
## bookcase against the passage's wall is its door (_passages).
func _library() -> void:
	for z in range(int(BACK_Z) + 1, int(BOARD_AT.origin.z - CrimeBoard.SIZE.x / 2) - 1):
		_shelf(Vector3(SHELVES_X, 0, z + 0.5), PI / 2)
	_builder.box(ARMCHAIR_AT + Vector3(0, 0.4, 0), Vector3(1.0, 0.8, 0.9), Color(0.4, 0.2, 0.12))
	_builder.box(LIBRARY_FIRE_AT + Vector3(0, 0.6, 0), Vector3(1.6, 1.2, 0.5), STONE)


## One bookcase, 1 m wide, its books facing `turn` (built by `builder`: the house's, or a door's).
func _shelf(at: Vector3, turn: float, builder := _builder) -> void:
	var facing := Basis(Vector3.UP, turn)
	var sideways := absf(sin(turn)) > 0.5
	builder.box(at + Vector3(0, 1.1, 0), Vector3(0.35, 2.2, 1.0) if sideways else Vector3(1.0, 2.2, 0.35), PANEL)
	for row in 4:
		var color := BOOK_COLORS[posmod(row + int(at.z), BOOK_COLORS.size())]
		var size := Vector3(0.05, 0.3, 0.85) if sideways else Vector3(0.85, 0.3, 0.05)
		builder.mesh_box(at + facing * Vector3(0, 0, 0.19) + Vector3(0, 0.35 + row * 0.5, 0), size, color)


## Doña Clotilde's study: the desk and the safe (open and empty). Her portrait is the passage's way out (_passages).
func _study() -> void:
	_builder.box(DESK_AT + Vector3(0, 0.4, 0), Vector3(1.8, 0.8, 0.9), PANEL)
	_builder.box(SAFE_AT + Vector3(0, 0.5, 0), Vector3(0.8, 1.0, 0.7), Color(0.3, 0.32, 0.35))
	_builder.mesh_box(SAFE_AT + Vector3(0.55, 0.5, 0.45), Vector3(0.05, 0.9, 0.7), Color(0.3, 0.32, 0.35))


## The three secret passages (step 2), each with a panel in each of its doorways, flush with the wall and sliding into
## it. The bookcase's way in hides behind the bookcase, which slides along the wall; the clock's behind the grandfather
## clock, which slides aside; the fireplace's is the fireplace's back, and the candelabra on the mantel opens it. The
## way out is the panel itself: doña Clotilde's portrait in the study, plain panels in the greenhouse and the pantry.
func _passages() -> void:
	for id: String in PASSAGES:
		var p: Dictionary = PASSAGES[id]
		var passage := SecretPassage.new()
		passage.name = "Passage" + id.capitalize()
		passage.id = id
		add_child(passage)
		passages[id] = passage
		var along := Vector3(0, 0, 1) if p.axis == "z" else Vector3(1, 0, 0)
		var size := Vector3(0.1, GameScale.DOOR_HEIGHT, GameScale.DOOR_WIDTH) if p.axis == "z" \
			else Vector3(GameScale.DOOR_WIDTH, GameScale.DOOR_HEIGHT, 0.1)
		var up := Vector3(0, GameScale.DOOR_HEIGHT / 2, 0)
		var color := BLACK if id == "fireplace" else PANEL
		for end: String in ["in", "out"]:
			var panel := passage.add_door("Panel" + end.capitalize(), p[end] + up, size,
				along * (GameScale.DOOR_WIDTH + 0.05), "PROMPT_PASSAGE_PORTRAIT" if id == "bookcase" and end == "out"
				else "PROMPT_PASSAGE_PANEL")
			PlaceBuilder.new(panel).mesh_box(Vector3.ZERO, size, color)
	var shelf := (passages.bookcase as SecretPassage).add_door("Bookcase", BOOKCASE_AT + Vector3(0, 1.1, 0),
		Vector3(0.35, 2.2, 1.3), Vector3(0, 0, 1.4), "PROMPT_PASSAGE_BOOK")
	var shelf_look := PlaceBuilder.new(shelf)
	shelf_look.mesh_box(Vector3.ZERO, Vector3(0.35, 2.2, 1.3), PANEL)
	for row in 4:
		shelf_look.mesh_box(Vector3(-0.19, row * 0.5 - 0.75, 0), Vector3(0.05, 0.3, 1.15), BOOK_COLORS[row])
	shelf_look.mesh_box(Vector3(-0.22, 0.25, 0.3), Vector3(0.06, 0.32, 0.08), Color(0.85, 0.1, 0.1))
	var portrait := (passages.bookcase as SecretPassage).doors[1]
	var frame := PlaceBuilder.new(portrait)
	frame.mesh_box(Vector3(0.06, PORTRAIT_AT.y - GameScale.DOOR_HEIGHT / 2, 0), Vector3(0.04, 1.3, 1.0), BRASS)
	frame.mesh_box(Vector3(0.08, PORTRAIT_AT.y - GameScale.DOOR_HEIGHT / 2, 0), Vector3(0.02, 1.15, 0.85),
		Color(0.55, 0.3, 0.45))
	var clock := (passages.clock as SecretPassage).add_door("Clock", CLOCK_AT + Vector3(0, 1.1, 0),
		Vector3(0.7, 2.2, 0.5), Vector3(1.0, 0, 0), "PROMPT_PASSAGE_CLOCK")
	var clock_look := PlaceBuilder.new(clock)
	clock_look.mesh_box(Vector3.ZERO, Vector3(0.7, 2.2, 0.5), PANEL)
	var dial := CylinderMesh.new()
	dial.top_radius = 0.24
	dial.bottom_radius = 0.24
	dial.height = 0.02
	clock_look.mesh(dial, Vector3(0, 0.7, 0.26), IVORY, Vector3(PI / 2, 0, 0))
	clock_look.mesh_box(Vector3(0, -0.2, 0.26), Vector3(0.05, 0.6, 0.02), BRASS)
	var candle := (passages.fireplace as SecretPassage).add_door("Candelabra", CANDELABRA_AT, Vector3(0.2, 0.3, 0.2),
		Vector3.ZERO, "PROMPT_PASSAGE_CANDLE")
	PlaceBuilder.new(candle).mesh_box(Vector3.ZERO, Vector3(0.08, 0.3, 0.08), BRASS)


## The greenhouse: glass roof panes and huge plants in pots.
func _greenhouse() -> void:
	var r: Array = ROOMS.greenhouse
	var center := Vector3((r[0] + r[1]) / 2, ROOF - 0.12, (r[2] + r[3]) / 2)
	_builder.mesh_box(center, Vector3(r[1] - r[0], 0.02, r[3] - r[2]), GLASS)
	for at in PLANTS:
		_builder.box(at + Vector3(0, 0.3, 0), Vector3(0.7, 0.6, 0.7), Color(0.6, 0.35, 0.22))
		var leaves := SphereMesh.new()
		leaves.radius = 0.8
		leaves.height = 1.4
		_builder.mesh(leaves, at + Vector3(0, 1.3, 0), HEDGE.lightened(0.15))


## The six members (MemberTraits.draw with the case seed), each in the room of their alibi (one of them stubborn about
## the cap); doña Clotilde on her round, Ceferino by the bell board, Lorenzo in his cage in the lounge and the box of
## chocolates on the dining table.
func _people() -> void:
	var traits := MemberTraits.draw(case_seed)
	var stubborn := hash("stubborn member %d" % case_seed) % traits.size()
	for i in traits.size():
		var member := MysteryMember.new()
		member.name = "Member%d" % i
		member.traits = traits[i]
		member.index = i
		member.stubborn = i == stubborn
		member.room = traits[i].room
		member.position = free_spot(member.room)
		member.rotation.y = _facing(member.position, member.room)
		add_child(member)
		members.append(member)
	_move_rng.seed = hash("mansion moves %d" % case_seed)
	clotilde = MansionOwner.new()
	clotilde.name = "Clotilde"
	clotilde.position = MansionOwner.ROUTE[0] + Vector3(0, FLOOR_TOP, 0)
	add_child(clotilde)
	butler = MansionButler.new()
	butler.name = "Butler"
	butler.position = BUTLER_AT + Vector3(0, FLOOR_TOP, 0)
	butler.rotation.y = -PI / 2
	add_child(butler)
	parrot = MansionParrot.new()
	parrot.name = "Parrot"
	parrot.position = CAGE_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(parrot)
	chocolates = CHOCOLATES_SCENE.instantiate()
	chocolates.name = "Chocolates"
	chocolates.position = CHOCOLATES_AT
	add_child(chocolates)


## Draws what was stolen and where it's hidden, and tells the members about the case (each part of a file they give
## goes to it); then the clues go where they go (MansionClues).
func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot = LOOTS[hash(["mansion loot", case.case_seed]) % LOOTS.size()]
	loot_spot = LOOT_SPOTS[hash(["mansion loot spot", case.case_seed]) % LOOT_SPOTS.size()]
	for member in members:
		member.part_given.connect(case.guard_part)
	clues = MansionClues.new()
	clues.name = "Clues"
	clues.mansion = self
	clues.case = case
	add_child(clues)


## Searching a spot: the stolen thing turns up in the right one; a sign of nothing in the others.
func search(spot: String, cop: Cop) -> void:
	if spot != loot_spot or loot_found or not case:
		if cop:
			cop.show_hint("HINT_SEARCH_NOTHING_" + spot)
		return
	reveal_loot()


## What was stolen comes out of its hiding spot, on the floor in front of it, and the case notes it.
func reveal_loot() -> void:
	if loot_found:
		return
	loot_found = true
	var item: Node3D = LOOT_MODELS[loot].instantiate()
	item.name = "Loot"
	add_child(item)
	var spot := loot_spots[loot_spot] as Node3D
	var out: Vector3 = spot.get_meta("out")
	item.position = Vector3(spot.position.x, FLOOR_TOP, spot.position.z) + out * 0.7
	item.rotation.y = atan2(out.x, out.z)
	if case:
		case.found_loot()


## The three hiding spots: the coat rack (with the club's spare capes on it), the piano and the dusty trunk.
func _loot_spots() -> void:
	var cape := BoxMesh.new()
	cape.size = Vector3(0.3, 0.8, 0.05)
	for i in 3:
		var turn := i * TAU / 3
		var at := COAT_RACK_AT + Vector3(sin(turn) * 0.12, 1.25, cos(turn) * 0.12)
		_builder.mesh(cape, at, Color(0.6, 0.45, 0.25).darkened(i * 0.12), Vector3(0, turn, 0))
	_loot_spot("coat_rack", COAT_RACK_AT + Vector3(0.15, 1.2, 0), Vector3(0.3, 1.2, 0.6), Vector3.RIGHT)
	_loot_spot("piano", PIANO_AT + Vector3(0, 1.05, 0), Vector3(1.6, 0.1, 1.2), Vector3.FORWARD)
	var trunk := TRUNK.instantiate()
	trunk.name = "Trunk"
	trunk.position = TRUNK_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(trunk)
	_loot_spot("dusty_trunk", TRUNK_AT + Vector3(0, 0.4, 0), Vector3(0.62, 0.7, 0.9), Vector3.FORWARD)


func _loot_spot(spot: String, at: Vector3, size: Vector3, out: Vector3) -> void:
	var body := LootSpot.new(size)
	body.name = "Search_" + spot
	body.spot = spot
	body.place = self
	body.position = at
	body.set_meta("out", out)
	add_child(body)
	loot_spots[spot] = body


## The member by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return members[index] if index >= 0 and index < members.size() else null


## The accused culprit runs off through the maze (MazeGetaway, step 6) instead of giving up.
func foot_getaway(index: int) -> MazeGetaway:
	var getaway := MazeGetaway.new()
	getaway.name = "MazeGetaway"
	getaway.mansion = self
	add_child(getaway)
	getaway.start(members[index])
	return getaway


## The culprit's way from a room to the maze's gate, in the house's space: out by the garden door, into the maze and
## through it like someone lost (every turn tried, drawn with the case seed, until the gate), and out the gate.
func getaway_route(room: String) -> Array[Vector3]:
	var way: Array[Vector3] = []
	for at: Vector3 in WAY_OUT.get(room, []):
		way.append(at + Vector3(0, FLOOR_TOP, 0))
	way.append(Vector3(DOOR_GARDEN_X, FLOOR_TOP, BACK_Z + 1.0))
	way.append(Vector3(DOOR_GARDEN_X, 0, BACK_Z - 1.0))
	var entry := maze_center(maze_entry())
	way.append(entry + Vector3(0, 0, MAZE_CELL / 2 + 0.5))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("mansion maze run %d" % case_seed)
	var seen := {maze_entry(): true}
	var stack: Array[Vector2i] = [maze_entry()]
	way.append(entry)
	while stack.back() != maze_gate():
		var cell: Vector2i = stack.back()
		var next: Array[Vector2i] = []
		for step: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
			if not seen.has(cell + step) and maze_joined(cell, cell + step):
				next.append(cell + step)
		if next.is_empty():
			stack.pop_back()
		else:
			var other := next[rng.randi_range(0, next.size() - 1)]
			seen[other] = true
			stack.append(other)
		way.append(maze_center(stack.back()))
	way.append(maze_center(maze_gate()) + Vector3(0, 0, -MAZE_CELL / 2 - 2.0))
	return way


## Lorenzo is the witness: shouted at, he's offended for good.
func witness_offended() -> bool:
	return parrot.offended


func offend_witness() -> void:
	parrot.offend()


func shouted_by(cop: Cop) -> void:
	if cop.global_position.distance_to(parrot.global_position) <= MansionParrot.SHOUT_REACH:
		parrot.offend()


## A spot in a room no member is standing on (MEMBER_SPOTS; past two, next to the first ones), in the house's space.
func free_spot(room: String) -> Vector3:
	for i in MemberTraits.COUNT:
		var spot: Vector3 = MEMBER_SPOTS[room][i % 2] + Vector3(0.9 * floori(i / 2.0), FLOOR_TOP, 0)
		var taken := false
		for member in members:
			taken = taken or (member.room == room and member.position.distance_to(spot) < 0.5)
		if not taken:
			return spot
	return MEMBER_SPOTS[room][0] + Vector3(0, FLOOR_TOP, 0)


## The rotation that turns someone at a spot to the middle of the room.
func _facing(spot: Vector3, room: String) -> float:
	var r: Array = ROOMS[room]
	var to := Vector3((r[0] + r[1]) / 2.0, 0, (r[2] + r[3]) / 2.0) - spot
	return atan2(to.x, to.z)


## The secret passage with a way in or out in a room, and whether that's its way in ("" if the room has none).
func passage_from(room: String) -> Array:
	for id: String in PASSAGES:
		for end: String in ["in", "out"]:
			if room_at(to_global(passage_door(id, end, 1.0))) == room:
				return [id, end == "in"]
	return ["", false]


## The point in front of a passage's doorway ("in" or "out"), this many meters out into its room; 0 is the doorway
## and a negative number is inside the passage, on its middle line.
func passage_door(id: String, end: String, out := 1.0) -> Vector3:
	var p: Dictionary = PASSAGES[id]
	var door: Vector3 = p[end]
	var middle := Vector3(p.fixed, 0, door.z) if p.axis == "z" else Vector3(door.x, 0, p.fixed)
	if out < 0.0:
		return middle
	return door + (door - middle).normalized() * out


## Sends a member through the secret passage of the room they're in, to the room at its other end: the passage opens,
## they walk through it (MysteryMember.walk_along) to a free spot there and it closes behind them unless the cops had
## it open. Returns the room they're going to ("" if theirs has no passage or they're already walking).
func send_through(member: MysteryMember) -> String:
	var way := passage_from(member.room)
	if way[0] == "" or member.walk:
		return ""
	var id: String = way[0]
	var start := "in" if way[1] else "out"
	var end := "out" if way[1] else "in"
	var to_room := room_at(to_global(passage_door(id, end)))
	var passage: SecretPassage = passages[id]
	var was_open := passage.is_open
	passage.set_open(true)
	var spot := free_spot(to_room)
	var points: Array[Vector3] = [passage_door(id, start) + Vector3.UP * FLOOR_TOP,
		passage_door(id, start, -1.0) + Vector3.UP * FLOOR_TOP, passage_door(id, end, -1.0) + Vector3.UP * FLOOR_TOP,
		passage_door(id, end) + Vector3.UP * FLOOR_TOP, spot]
	member.walk_along(points, to_room, func() -> void:
		member.rotation.y = _facing(spot, to_room)
		if not was_open:
			passage.set_open(false))
	return to_room


## Every MOVE_EVERY seconds one member (drawn with the case seed) in a room with a passage goes through it.
func _physics_process(delta: float) -> void:
	_move_left -= delta
	if _move_left > 0.0:
		return
	_move_left = MOVE_EVERY
	var can_go: Array[MysteryMember] = []
	for member in members:
		if passage_from(member.room)[0] != "" and not member.walk:
			can_go.append(member)
	if not can_go.is_empty():
		send_through(can_go[_move_rng.randi_range(0, can_go.size() - 1)])


## The butler's pantry: the bell board on the east wall (one bell per room) and shelves of jars.
func _pantry() -> void:
	_builder.mesh_box(BELL_BOARD_AT, Vector3(0.04, 0.7, 1.8), PANEL)
	for i in BELL_ROOMS.size():
		var at := BELL_BOARD_AT + Vector3(-0.04, 0.12, -0.75 + i * 0.3)
		_builder.mesh_box(at, Vector3(0.05, 0.1, 0.1), BRASS)
	_builder.box(PANTRY_SHELF_AT + Vector3(0, 1.0, 0), Vector3(3.0, 2.0, 0.5), PANEL)


## The hedge maze behind the house: a grid of cells with hedges between them, carved with a fixed seed so every match
## has the same one; its way in faces the garden door and its gate is the far corner.
func _maze() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = MAZE_SEED
	var seen := {maze_entry(): true}
	var stack: Array[Vector2i] = [maze_entry()]
	while not stack.is_empty():
		var cell: Vector2i = stack.back()
		var next: Array[Vector2i] = []
		for step: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
			var other := cell + step
			var on_grid := other.x >= 0 and other.y >= 0 and other.x < MAZE_CELLS.x and other.y < MAZE_CELLS.y
			if on_grid and not seen.has(other):
				next.append(other)
		if next.is_empty():
			stack.pop_back()
			continue
		var other := next[rng.randi_range(0, next.size() - 1)]
		var first := cell if cell.x + cell.y < other.x + other.y else other
		var side := "e" if other.x != cell.x else "s"
		var sides: Array = maze_open.get(first, [])
		sides.append(side)
		maze_open[first] = sides
		seen[other] = true
		stack.append(other)
	var width := MAZE_CELLS.x * MAZE_CELL
	var left := -width / 2
	for z in MAZE_CELLS.y:
		for x in MAZE_CELLS.x:
			var cell := Vector2i(x, z)
			var center := maze_center(cell)
			var sides: Array = maze_open.get(cell, [])
			if x < MAZE_CELLS.x - 1 and not sides.has("e"):
				_hedge(center + Vector3(MAZE_CELL / 2, 0, 0), Vector3(0.6, HEDGE_HEIGHT, MAZE_CELL + 0.6))
			if z < MAZE_CELLS.y - 1 and not sides.has("s"):
				_hedge(center + Vector3(0, 0, -MAZE_CELL / 2), Vector3(MAZE_CELL + 0.6, HEDGE_HEIGHT, 0.6))
	var across := Vector3(MAZE_CELL + 0.6, HEDGE_HEIGHT, 0.6)
	for x in MAZE_CELLS.x:
		if x != maze_entry().x:
			_hedge(maze_center(Vector2i(x, 0)) + Vector3(0, 0, MAZE_CELL / 2), across)
		var far := maze_center(Vector2i(x, MAZE_CELLS.y - 1)) + Vector3(0, 0, -MAZE_CELL / 2)
		if x != maze_gate().x:
			_hedge(far, across)
		else:
			_builder.mesh_box(far + Vector3(0, 1.0, 0), Vector3(MAZE_CELL - 0.4, 2.0, 0.08), BLACK)
	var depth := MAZE_CELLS.y * MAZE_CELL
	_hedge(Vector3(left, 0, MAZE_Z - depth / 2), Vector3(0.6, HEDGE_HEIGHT, depth + 0.6))
	_hedge(Vector3(-left, 0, MAZE_Z - depth / 2), Vector3(0.6, HEDGE_HEIGHT, depth + 0.6))


func _hedge(at: Vector3, size: Vector3) -> void:
	_builder.box(at + Vector3(0, size.y / 2, 0), size, HEDGE)
