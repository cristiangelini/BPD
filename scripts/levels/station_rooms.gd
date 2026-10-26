class_name StationRooms
extends RefCounted

## The police station inside (docs/diseno/comisaria.md, "Cómo es por dentro"): one floor in the 30 x 18 m building of
## the city, front to +Z. The front row has the armory (west, behind a barred counter), the guard room where the cops
## appear (middle) and the cells (east); the back row has the board room (closed for now), the comisario's office and
## the break room, and a door in the office's back wall leads to the interrogation wing (InterrogationWing). Local coordinates of the building, with its middle on the ground. Pure data, so tests can check it
## without a scene. Every number here is (propuesta).

const HALF_X := 15.0
const HALF_Z := 9.0
const CEILING := 3.0
const WALL := 0.2
## The wall between the front and the back row.
const SPLIT_Z := 1.0
## Front row: armory | guard room | cells. Back row: board room | office | break room.
const FRONT_X := 6.0
const BACK_X := 5.0
## The front door, and the door from the guard room to each room around it: [from, to] along the wall.
const FRONT_DOOR := Vector2(-1.2, 1.2)
const OFFICE_DOOR := Vector2(-0.8, 0.8)
const BOARD_DOOR := Vector2(-10.8, -9.6)
const BREAK_DOOR := Vector2(9.6, 10.8)
## The door between the office and the board room, along the office's west wall: only open while a crime scene case
## uses the board (escena-del-crimen.md), since the board room's own door opens onto the armory.
const BOARD_SIDE_DOOR := Vector2(-3.2, -2.0)
const CELLS_DOOR := Vector2(5.6, 7.2)
## The armory counter: a window in the wall between the guard room and the armory, with bars above it.
const COUNTER := Vector2(3.0, 7.0)
const COUNTER_HEIGHT := 1.1
const BARS_TOP := 2.3
const BAR_EVERY := 0.25
## Two cells against the cells room's back wall, barred toward the room.
const CELL_FRONT_Z := 4.5
const CELL_SPLIT_X := 10.5
## The barred door of each cell, [from, to] along its front (CellDoor), hinged at `from`.
const CELL_DOORS: Array[Vector2] = [Vector2(9.0, 10.2), Vector2(10.8, 12.0)]
## Where the four cops wake up in the jailbreak (fuga.md): two in each cell, facing the bars (+Z).
const CELL_SPAWNS: Array[Vector3] = [Vector3(7.3, 0, 3.2), Vector3(11.7, 0, 3.2), Vector3(9.3, 0, 3.2),
	Vector3(13.7, 0, 3.2)]

## Where the four cops appear in the guard room, facing the office (-Z).
const SPAWNS: Array[Vector3] = [Vector3(-1.5, 0, 6.0), Vector3(1.5, 0, 6.0), Vector3(-1.5, 0, 7.5), Vector3(1.5, 0, 7.5)]
## Where the comisario stands, behind his desk, facing the office door (+Z).
const COMISARIO_AT := Vector3(0, 0, -6.5)
## Where the armero stands behind the counter, facing the guard room (+X).
const ARMERO_AT := Vector3(-6.9, 0, 5.0)

## The disguises in front of the lockers (infiltracion.md): a wig, glasses and a mustache for each of the four cops,
## in two rows from DISGUISES_AT.
const DISGUISES: Array[String] = ["wig", "glasses", "mustache", "wig", "glasses", "mustache",
	"wig", "glasses", "mustache", "wig", "glasses", "mustache"]
const DISGUISES_AT := Vector3(-5.15, 0, 1.95)
## The choir's (infiltracion-coro.md, step 2): a folded robe and a songbook for each cop, in a third row.
const CHOIR_DISGUISES: Array[String] = ["robe", "songbook", "robe", "songbook", "robe", "songbook", "robe", "songbook"]
const CHOIR_DISGUISES_AT := Vector3(-5.15, 0, 2.75)
const CHOIR_GAP := 0.34
const SONGBOOK_SCENE := "res://scenes/props/songbook.tscn"
## The mime troupe's (infiltracion-mimos.md, step 1): a beret, a white face and a striped shirt for each cop, in a
## fourth row.
const MIME_DISGUISES: Array[String] = ["mime_beret", "mime_face", "mime_shirt", "mime_beret", "mime_face", "mime_shirt",
	"mime_beret", "mime_face", "mime_shirt", "mime_beret", "mime_face", "mime_shirt"]
const MIME_DISGUISES_AT := Vector3(-5.15, 0, 3.15)
const MIME_GAP := 0.3
## The costume party's (infiltracion-fiesta.md, step 1): a party-store cop cap, a fake mustache and a plastic badge for
## each cop, in a fifth row.
const PARTY_DISGUISES: Array[String] = ["party_cap", "party_mustache", "party_badge", "party_cap", "party_mustache",
	"party_badge", "party_cap", "party_mustache", "party_badge", "party_cap", "party_mustache", "party_badge"]
const PARTY_DISGUISES_AT := Vector3(-5.15, 0, 3.55)
const PARTY_GAP := 0.3
## The gym's (infiltracion-gimnasio.md, step 1): a headband, a pair of wristbands and a tank top for each cop, in a
## sixth row.
const GYM_DISGUISES: Array[String] = ["gym_headband", "gym_wristbands", "gym_tank", "gym_headband", "gym_wristbands",
	"gym_tank", "gym_headband", "gym_wristbands", "gym_tank", "gym_headband", "gym_wristbands", "gym_tank"]
const GYM_DISGUISES_AT := Vector3(-5.15, 0, 3.95)
const GYM_GAP := 0.36
## The thieves' school's (infiltracion-escuela.md, step 1): an eye mask, a beanie and a striped shirt for each cop, in a
## seventh row.
const THIEF_DISGUISES: Array[String] = ["thief_mask", "thief_beanie", "thief_shirt", "thief_mask", "thief_beanie",
	"thief_shirt", "thief_mask", "thief_beanie", "thief_shirt", "thief_mask", "thief_beanie", "thief_shirt"]
const THIEF_DISGUISES_AT := Vector3(-5.15, 0, 4.4)
const THIEF_GAP := 0.42
## The restaurant's (infiltracion-restaurante.md, step 1): a chef's hat, a curly mustache and an apron for each cop, in
## an eighth row.
const CHEF_DISGUISES: Array[String] = ["chef_hat", "chef_mustache", "chef_apron", "chef_hat", "chef_mustache",
	"chef_apron", "chef_hat", "chef_mustache", "chef_apron", "chef_hat", "chef_mustache", "chef_apron"]
const CHEF_DISGUISES_AT := Vector3(-5.15, 0, 4.85)
const CHEF_GAP := 0.42
## The chess club's (infiltracion-ajedrez.md, step 1): thick glasses, an argyle vest and a beret for each cop, in a
## ninth row.
const CHESS_DISGUISES: Array[String] = ["chess_glasses", "chess_vest", "chess_beret", "chess_glasses", "chess_vest",
	"chess_beret", "chess_glasses", "chess_vest", "chess_beret", "chess_glasses", "chess_vest", "chess_beret"]
const CHESS_DISGUISES_AT := Vector3(-5.15, 0, 5.3)
const CHESS_GAP := 0.42
## The biker gang's (infiltracion-motos.md, step 1): a bandana, a long fake beard and a leather jacket for each cop, in
## a row on the other side of the guard room, by the coffee: the rows by the lockers reach where the cops appear.
const BIKER_DISGUISES: Array[String] = ["biker_bandana", "biker_beard", "biker_jacket", "biker_bandana", "biker_beard",
	"biker_jacket", "biker_bandana", "biker_beard", "biker_jacket", "biker_bandana", "biker_beard", "biker_jacket"]
const BIKER_DISGUISES_AT := Vector3(0.6, 0, 2.4)
const BIKER_GAP := 0.42

## Furniture: [model, position, turn]. The models come from tools/modelgen/models/station.js.
const FURNITURE := [
	["station_desk", Vector3(0, 0, -5.2), 0.0],
	["station_lockers", Vector3(-4.2, 0, 1.4), 0.0],
	["station_coffee", Vector3(4.5, 0, 1.5), 0.0],
	["station_bench", Vector3(-3.6, 0, 8.4), 0.0],
	["station_bench", Vector3(3.6, 0, 8.4), 0.0],
	["station_rack", Vector3(-10.5, 0, 1.5), 0.0],
	["station_rack", Vector3(-14.5, 0, 5.0), PI / 2],
	["station_bunk", Vector3(8.3, 0, 1.6), 0.0],
	["station_bunk", Vector3(12.7, 0, 1.6), 0.0],
	["station_coffee", Vector3(13.8, 0, -8.4), 0.0],
	["station_bench", Vector3(10.0, 0, -4.0), 0.0],
]
## Footprints of the furniture you bump into: [center, size].
const SOLID := {
	"station_desk": Vector3(2, 0.8, 0.9), "station_lockers": Vector3(2.4, 1.9, 0.5), "station_coffee": Vector3(0.7, 1.5, 0.6),
	"station_bench": Vector3(2, 0.45, 0.45), "station_rack": Vector3(2.4, 1.8, 0.5), "station_bunk": Vector3(2, 0.5, 0.8),
}


## Every wall piece inside the shell: [center, size] in local coordinates, doorways and the counter left open.
## The outside walls (the facade) are built by the city with their full height. With `board_open`, the office's west
## wall has the door to the board room.
static func walls(board_open := false) -> Array:
	var pieces := []
	run(pieces, "x", SPLIT_Z, -HALF_X, HALF_X, [BOARD_DOOR, OFFICE_DOOR, BREAK_DOOR])
	run(pieces, "z", -FRONT_X, SPLIT_Z, HALF_Z, [COUNTER])
	run(pieces, "z", FRONT_X, SPLIT_Z, HALF_Z, [CELLS_DOOR])
	run(pieces, "z", -BACK_X, -HALF_Z, SPLIT_Z, [BOARD_SIDE_DOOR] if board_open else [])
	run(pieces, "z", BACK_X, -HALF_Z, SPLIT_Z, [])
	run(pieces, "z", CELL_SPLIT_X, SPLIT_Z, CELL_FRONT_Z, [])
	return pieces


## The front wall, split around the door, as [center, size] pieces of the given height.
static func front_wall(height: float) -> Array:
	var pieces := []
	run(pieces, "x", HALF_Z, -HALF_X, HALF_X, [FRONT_DOOR], height)
	return pieces


## The back wall, split around the door to the interrogation wing (InterrogationWing), as [center, size] pieces.
static func back_wall(height: float) -> Array:
	var pieces := []
	run(pieces, "x", -HALF_Z, -HALF_X, HALF_X, [InterrogationWing.OFFICE_DOOR], height)
	return pieces


## The bars: the armory counter's and the cells' fronts, as thin [center, size] posts.
static func bars() -> Array:
	var posts := []
	var y := (COUNTER_HEIGHT + BARS_TOP) / 2
	var z := COUNTER.x + BAR_EVERY / 2
	while z < COUNTER.y:
		posts.append([Vector3(-FRONT_X, y, z), Vector3(0.04, BARS_TOP - COUNTER_HEIGHT, 0.04)])
		z += BAR_EVERY
	var x := FRONT_X + BAR_EVERY / 2
	while x < HALF_X:
		if not CELL_DOORS.any(func(door: Vector2) -> bool: return x > door.x - 0.05 and x < door.y + 0.05):
			posts.append([Vector3(x, CEILING / 2, CELL_FRONT_Z), Vector3(0.05, CEILING, 0.05)])
		x += BAR_EVERY
	# Over each door, a beam up to the ceiling.
	for door in CELL_DOORS:
		var top := GameScale.DOOR_HEIGHT + 0.05
		posts.append([Vector3((door.x + door.y) / 2, (top + CEILING) / 2, CELL_FRONT_Z),
			Vector3(door.y - door.x, CEILING - top, 0.08)])
	return posts


## The counter under the bars, and the wall over them up to the ceiling.
static func counter() -> Array:
	var length := COUNTER.y - COUNTER.x
	var middle := (COUNTER.x + COUNTER.y) / 2
	return [
		[Vector3(-FRONT_X, COUNTER_HEIGHT / 2, middle), Vector3(0.6, COUNTER_HEIGHT, length)],
		[Vector3(-FRONT_X, (BARS_TOP + CEILING) / 2, middle), Vector3(WALL, CEILING - BARS_TOP, length)],
	]


## Doors that stay shut for now (the board room): [center, size].
static func closed_doors() -> Array:
	var width := BOARD_DOOR.y - BOARD_DOOR.x
	return [[Vector3((BOARD_DOOR.x + BOARD_DOOR.y) / 2, GameScale.DOOR_HEIGHT / 2, SPLIT_Z), Vector3(width, GameScale.DOOR_HEIGHT, 0.08)]]


## One light per room.
static func lights() -> Array[Vector3]:
	var y := CEILING - 0.4
	return [Vector3(-10.5, y, 5), Vector3(0, y, 5), Vector3(10.5, y, 5), Vector3(-10, y, -4), Vector3(0, y, -4), Vector3(10, y, -4)]


## Wall pieces along x (at z = fixed) or along z (at x = fixed) from `from` to `to`, leaving the gaps open
## (with a lintel over each doorway up to the ceiling).
static func run(pieces: Array, along: String, fixed: float, from: float, to: float, gaps: Array, height := CEILING) -> void:
	var start := from
	for gap: Vector2 in gaps:
		_piece(pieces, along, fixed, start, gap.x, 0.0, height)
		if gap != COUNTER:
			_piece(pieces, along, fixed, gap.x, gap.y, GameScale.DOOR_HEIGHT, height)
		start = gap.y
	_piece(pieces, along, fixed, start, to, 0.0, height)


static func _piece(pieces: Array, along: String, fixed: float, from: float, to: float, bottom: float, top: float) -> void:
	if to - from < 0.01 or top - bottom < 0.01:
		return
	var middle := (from + to) / 2
	var y := (bottom + top) / 2
	if along == "x":
		pieces.append([Vector3(middle, y, fixed), Vector3(to - from, top - bottom, WALL)])
	else:
		pieces.append([Vector3(fixed, y, middle), Vector3(WALL, top - bottom, to - from)])
