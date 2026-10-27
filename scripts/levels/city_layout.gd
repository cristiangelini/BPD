class_name CityLayout
extends RefCounted

## The city plan (docs/diseno/ciudad.md): a grid of blocks with streets between and around them, the police
## station, the 10 raid places and filler buildings. Pure data, so tests can check it without a scene.
## Blocks are (column, row): column 0 is the west, row 0 the north (-Z). Every number here is (propuesta).
## The city grows a little at a time (Cristian, 19/10): new places (the jail, the politician's case...) add rows
## to the south, so ROWS goes up and nothing already placed moves.
## Twice the blocks (Cristian, 26/10): from 7 x 5 to 10 x 7, one column more on the west, two on the east and one row
## on each of north and south. The new blocks get the indices around the old ones (column -1, 7 and 8, row -1 and 5),
## so every place keeps its block; FIRST is the north-west block. Streets are numbered the same way: street k runs on
## the west (north) side of column (row) k, from FIRST to FIRST + COLUMNS (ROWS).

const COLUMNS := 10
const ROWS := 7
const FIRST := Vector2i(-1, -1)
## The edge streets' numbers.
const WEST := FIRST.x
const EAST := FIRST.x + COLUMNS
const NORTH := FIRST.y
const SOUTH := FIRST.y + ROWS
const BLOCK := 60.0
const STREET := 12.0
const PITCH := BLOCK + STREET
## Whole city, streets around the edge included.
const SIZE := Vector2(COLUMNS * BLOCK + (COLUMNS + 1) * STREET, ROWS * BLOCK + (ROWS + 1) * STREET)
const SIDEWALK := 3.0

## Each place: its block, the side its front faces (n, s, e, w), how far along that side its middle sits,
## its size (width along the street, height, depth), color and sign. Interiors come one per PR.
const PLACES := [
	{"id": "station", "block": Vector2i(2, 2), "side": "s", "along": 0.0, "size": Vector3(30, 9, 18), "color": Color(0.3, 0.45, 0.8), "sign": "PLACE_STATION"},
	{"id": "hotel", "block": Vector2i(2, 3), "side": "n", "along": 0.0, "size": Vector3(26, 18, 18), "color": Color(0.85, 0.5, 0.45), "sign": "PLACE_HOTEL"},
	{"id": "insurance", "block": Vector2i(3, 3), "side": "n", "along": 0.0, "size": Vector3(22, 12, 16), "color": Color(0.6, 0.65, 0.7), "sign": "PLACE_INSURANCE"},
	{"id": "grandpa", "block": Vector2i(1, 2), "side": "e", "along": 0.0, "size": Vector3(24, 7, 20), "color": Color(1.0, 0.84, 0.55), "sign": "PLACE_GRANDPA"},
	{"id": "apartments", "block": Vector2i(1, 3), "side": "e", "along": 0.0, "size": Vector3(22, 99.2, 16), "color": Color(0.75, 0.6, 0.85), "sign": "PLACE_APARTMENTS"},
	{"id": "bakery", "block": Vector2i(2, 1), "side": "s", "along": -12.0, "size": Vector3(16, 7, 14), "color": Color(0.95, 0.75, 0.4), "sign": "PLACE_BAKERY"},
	{"id": "pet_salon", "block": Vector2i(2, 1), "side": "s", "along": 12.0, "size": Vector3(16, 6, 14), "color": Color(0.55, 0.85, 0.8), "sign": "PLACE_PET_SALON"},
	{"id": "hardware", "block": Vector2i(3, 1), "side": "s", "along": -12.0, "size": Vector3(16, 7, 14), "color": Color(0.9, 0.45, 0.3), "sign": "PLACE_HARDWARE"},
	{"id": "gym", "block": Vector2i(3, 1), "side": "s", "along": 12.0, "size": Vector3(18, 8, 16), "color": Color(0.4, 0.75, 0.4), "sign": "PLACE_GYM"},
	{"id": "doll_factory", "block": Vector2i(4, 2), "side": "w", "along": 0.0, "size": Vector3(28, 10, 26), "color": Color(0.95, 0.6, 0.75), "sign": "PLACE_DOLL_FACTORY"},
	{"id": "grandpa_club", "block": Vector2i(4, 1), "side": "s", "along": 0.0, "size": Vector3(28, 5, 22), "color": Color(0.82, 0.55, 0.75), "sign": "PLACE_GRANDPA_CLUB"},
	{"id": "chapel", "block": Vector2i(1, 1), "side": "s", "along": 0.0, "size": Vector3(24, 5, 22), "color": Color(0.92, 0.88, 0.78), "sign": "PLACE_CHAPEL"},
	{"id": "mime_theater", "block": Vector2i(5, 1), "side": "s", "along": 0.0, "size": Vector3(24, 5, 20), "color": Color(0.2, 0.2, 0.24), "sign": "PLACE_MIME_THEATER"},
	{"id": "party_hall", "block": Vector2i(5, 0), "side": "s", "along": 0.0, "size": Vector3(24, 6, 20), "color": Color(0.55, 0.2, 0.45), "sign": "PLACE_PARTY_HALL"},
	{"id": "bank", "block": Vector2i(3, 0), "side": "s", "along": 0.0, "size": Vector3(24, 7, 20), "color": Color(0.86, 0.84, 0.78), "sign": "PLACE_BANK"},
	{"id": "prison", "block": Vector2i(5, 2), "side": "w", "along": 0.0, "size": Vector3(28, 5, 40), "color": Color(0.62, 0.6, 0.55), "sign": "PLACE_PRISON"},
	{"id": "circus", "block": Vector2i(5, 3), "side": "n", "along": 0.0, "size": Vector3(40, 8, 30), "color": Color(0.86, 0.18, 0.2), "sign": "PLACE_CIRCUS"},
	{"id": "gas_station", "block": Vector2i(4, 2), "side": "s", "along": 0.0, "size": Vector3(14, 5, 10), "color": Color(0.95, 0.9, 0.82), "sign": "PLACE_GAS_STATION"},
	{"id": "market", "block": Vector2i(2, 0), "side": "s", "along": 0.0, "size": Vector3(30, 6, 22), "color": Color(0.88, 0.8, 0.62), "sign": "PLACE_MARKET"},
	{"id": "auction", "block": Vector2i(6, 2), "side": "s", "along": 0.0, "size": Vector3(24, 6, 20), "color": Color(0.86, 0.82, 0.74), "sign": "PLACE_AUCTION"},
	{"id": "biker", "block": Vector2i(6, 0), "side": "s", "along": 0.0, "size": Vector3(24, 6, 20), "color": Color(0.22, 0.2, 0.2), "sign": "PLACE_BIKER"},
	{"id": "chess", "block": Vector2i(6, 1), "side": "s", "along": 0.0, "size": Vector3(24, 6, 20), "color": Color(0.3, 0.32, 0.36), "sign": "PLACE_CHESS"},
	{"id": "restaurant", "block": Vector2i(1, 0), "side": "s", "along": 0.0, "size": Vector3(24, 6, 20), "color": Color(0.62, 0.22, 0.2), "sign": "PLACE_RESTAURANT"},
	{"id": "school", "block": Vector2i(4, 0), "side": "s", "along": 0.0, "size": Vector3(24, 6, 20), "color": Color(0.45, 0.4, 0.55), "sign": "PLACE_SCHOOL"},
	{"id": "school_visit", "block": Vector2i(3, 3), "side": "s", "along": 0.0, "size": Vector3(28, 4, 24), "color": Color(0.95, 0.85, 0.55), "sign": "PLACE_SCHOOL_VISIT"},
	{"id": "museum", "block": Vector2i(0, 0), "side": "s", "along": 0.0, "size": Vector3(30, 7, 26), "color": Color(0.88, 0.86, 0.8), "sign": "PLACE_MUSEUM"},
	{"id": "cake_lab", "block": Vector2i(4, 3), "side": "w", "along": 0.0, "size": Vector3(24, 8, 22), "color": Color(0.95, 0.95, 0.85), "sign": "PLACE_CAKE_LAB"},
	# A park, not a building: it fills its block and its case scene builds the canal and the bridge on the grass.
	{"id": "bridge_park", "block": Vector2i(3, 4), "side": "n", "along": 0.0, "size": Vector3(54, 1, 54), "color": Color(0.45, 0.72, 0.3), "sign": "PLACE_BRIDGE_PARK", "park": true},
	{"id": "football_pitch", "block": Vector2i(4, 4), "side": "n", "along": 0.0, "size": Vector3(54, 1, 54), "color": Color(0.32, 0.62, 0.28), "sign": "PLACE_FOOTBALL_PITCH", "park": true},
	{"id": "tv_studio", "block": Vector2i(1, 4), "side": "n", "along": 0.0, "size": Vector3(34, 7, 22), "color": Color(0.62, 0.7, 0.82), "sign": "PLACE_TV_STUDIO"},
	# The wrong house's twin houses (casa-equivocada.md); provisional block until the city grows west, then (-1, 1) s.
	{"id": "wrong_house", "block": Vector2i(0, 2), "side": "s", "along": 0.0, "size": Vector3(36, 7, 20), "color": Color(0.95, 0.86, 0.6), "sign": "PLACE_WRONG_HOUSE"},
	# The airport fills its block too: the terminal and the apron are its case scene's (politico-aeropuerto.md).
	{"id": "airport", "block": Vector2i(6, 4), "side": "n", "along": 0.0, "size": Vector3(54, 1, 54), "color": Color(0.86, 0.88, 0.9), "sign": "PLACE_AIRPORT", "park": true},
	# The supermarket "Súper El Changuito" (allanamiento-super.md), on the east edge.
	{"id": "supermarket", "block": Vector2i(7, 1), "side": "s", "along": 0.0, "size": Vector3(30, 7, 24), "color": Color(0.95, 0.86, 0.4), "sign": "PLACE_SUPERMARKET"},
]

## The plaza fills its block.
const PLAZA := Vector2i(3, 2)
## Shops are places whose front gets a shutter and an awning.
const SHOPS: Array[String] = ["bakery", "pet_salon", "hardware", "gym"]

## Filler buildings on the north and south sides that have no place: 3 per side.
const FILLER_ALONG: Array[float] = [-16.0, 0.0, 16.0]
const FILLER_SIZE := {
	"house": Vector3(11, 6, 10), "warehouse": Vector3(13, 8, 12), "building": Vector3(12, 10, 11),
}
const FILLER_COLORS: Array[Color] = [
	Color(0.95, 0.7, 0.6), Color(0.7, 0.85, 0.95), Color(0.85, 0.9, 0.6), Color(0.95, 0.88, 0.7),
	Color(0.8, 0.75, 0.9),
]

## Street names: rows of the grid run west to east (between block rows), columns north to south.
## STREETS_EW[0] is street NORTH + 1, STREETS_NS[0] street WEST + 1 (the edge streets have no sign).
const STREETS_EW: Array[String] = ["STREET_FERN", "STREET_KITE", "STREET_CLOCK", "STREET_LINDEN", "STREET_PUDDLE",
	"STREET_PILLOW"]
const STREETS_NS: Array[String] = [
	"STREET_MITTEN", "STREET_SOCK", "STREET_TEAPOT", "STREET_CENTRAL", "STREET_BUTTON", "STREET_SPOON", "STREET_WHISTLE",
	"STREET_LADLE", "STREET_HAMMOCK",
]


## Center of a block on the ground.
static func block_center(block: Vector2i) -> Vector3:
	var first := -SIZE / 2 + Vector2.ONE * (STREET + BLOCK / 2)
	return Vector3(first.x + (block.x - FIRST.x) * PITCH, 0, first.y + (block.y - FIRST.y) * PITCH)


## Center x of north-south street `k` (WEST to EAST).
static func street_x(k: int) -> float:
	return -SIZE.x / 2 + STREET / 2 + (k - WEST) * PITCH


## Center z of west-east street `k` (NORTH to SOUTH).
static func street_z(k: int) -> float:
	return -SIZE.y / 2 + STREET / 2 + (k - NORTH) * PITCH


## Every block, row by row from the north-west.
static func blocks() -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	for row in range(FIRST.y, FIRST.y + ROWS):
		for col in range(FIRST.x, FIRST.x + COLUMNS):
			list.append(Vector2i(col, row))
	return list


## Every crossing (i, j) of north-south street i and west-east street j; `inner` leaves out the edge streets.
static func crossings(inner := false) -> Array[Vector2i]:
	var cut := 1 if inner else 0
	var list: Array[Vector2i] = []
	for i in range(WEST + cut, EAST + 1 - cut):
		for j in range(NORTH + cut, SOUTH + 1 - cut):
			list.append(Vector2i(i, j))
	return list


## Whether crossing (i, j) is on the street grid.
static func on_grid(crossing: Vector2i) -> bool:
	return crossing.x >= WEST and crossing.x <= EAST and crossing.y >= NORTH and crossing.y <= SOUTH


## The direction a side faces, on the ground.
static func side_normal(side: String) -> Vector3:
	return {"n": Vector3.FORWARD, "s": Vector3.BACK, "e": Vector3.RIGHT, "w": Vector3.LEFT}[side]


## Turn around Y that points a building's +Z front toward `side`.
static func side_turn(side: String) -> float:
	return {"n": PI, "s": 0.0, "e": PI / 2, "w": -PI / 2}[side]


## Where a lot's footprint center sits: its front on the inner edge of the sidewalk.
static func lot_center(block: Vector2i, side: String, along: float, depth: float) -> Vector3:
	var normal := side_normal(side)
	var tangent := Vector3(-normal.z, 0, normal.x).abs()
	return block_center(block) + normal * (BLOCK / 2 - SIDEWALK - depth / 2) + tangent * along


## Footprint on the ground (x, z) of a lot, for overlap checks.
static func footprint(block: Vector2i, side: String, along: float, size: Vector3) -> Rect2:
	var center := lot_center(block, side, along, size.z)
	var across := Vector2(size.x, size.z) if side in ["n", "s"] else Vector2(size.z, size.x)
	return Rect2(Vector2(center.x, center.z) - across / 2, across)


static func barrio_kind(block: Vector2i) -> String:
	if block.x <= 1:
		return "house"
	if block.x >= 4:
		return "warehouse"
	return "building"


## Every filler lot as {block, side, along, size, color}: north and south sides without a place.
static func fillers() -> Array[Dictionary]:
	var lots: Array[Dictionary] = []
	for block in blocks():
		if block == PLAZA or is_park(block):
			continue
		for side: String in ["n", "s"]:
			if PLACES.any(func(p: Dictionary) -> bool: return p.block == block and p.side == side):
				continue
			var size: Vector3 = FILLER_SIZE[barrio_kind(block)]
			for i in FILLER_ALONG.size():
				lots.append({"block": block, "side": side, "along": FILLER_ALONG[i], "size": size,
					"color": FILLER_COLORS[posmod(block.x * 7 + block.y * 3 + i + (1 if side == "n" else 0), FILLER_COLORS.size())]})
	return lots


## Whether a park fills `block` (it has no buildings and its ground is grass).
static func is_park(block: Vector2i) -> bool:
	return PLACES.any(func(p: Dictionary) -> bool: return p.block == block and p.get("park", false))


static func place(id: String) -> Dictionary:
	for p: Dictionary in PLACES:
		if p.id == id:
			return p
	return {}


## Where a place's front door meets the sidewalk.
static func door_of(id: String) -> Vector3:
	var p := place(id)
	return lot_center(p.block, p.side, p.along, p.size.z) + side_normal(p.side) * (p.size.z / 2)


## Where the city goes so that place `id` sits at the origin with its front facing +Z, the way a case scene
## builds its place (the grandpa's house builds itself there and the city is laid around it).
static func anchor(id: String) -> Transform3D:
	var p := place(id)
	var lot := Transform3D(Basis(Vector3.UP, side_turn(p.side)), lot_center(p.block, p.side, p.along, p.size.z))
	return lot.affine_inverse()


## The street spot in front of a place's door where the patrol car parks, and the car's turn to run along it.
static func parking(id: String) -> Transform3D:
	var p := place(id)
	var spot := door_of(id) + side_normal(p.side) * (SIDEWALK + 3.0)
	return Transform3D(Basis(Vector3.UP, side_turn(p.side) + PI / 2), spot)


## A place's lot: its building's own space (its middle on the ground, front to +Z) in the city.
static func lot(id: String) -> Transform3D:
	var p := place(id)
	return Transform3D(Basis(Vector3.UP, side_turn(p.side)), lot_center(p.block, p.side, p.along, p.size.z))


## Where cop `index` (0 to 3) appears in the station's guard room, facing the comisario's office (StationRooms).
static func station_spawn(index: int) -> Transform3D:
	return lot("station") * Transform3D(Basis.IDENTITY, StationRooms.SPAWNS[index % StationRooms.SPAWNS.size()])


## Where cop `index` wakes up locked in a cell for the jailbreak (fuga.md), facing the bars.
static func jail_spawn(index: int) -> Transform3D:
	var at := StationRooms.CELL_SPAWNS[index % StationRooms.CELL_SPAWNS.size()]
	return lot("station") * Transform3D(Basis(Vector3.UP, PI), at)
