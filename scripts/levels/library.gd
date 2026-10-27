class_name Library
extends CrimeScenePlace

## The Municipal Library (escena-biblioteca.md, step 1, decision 360), on its lot with the front to +Z: the stone
## steps up to the door between four columns, and the clock over it. Inside, the reading room in the middle (the long
## tables with their green lamps, the Golden Book's display case, the reading armchair, the librarian's desk and the
## card catalog by the door); east of it the stacks, eight tall shelves with their letters A to H and the rolling
## ladder; west of it the children's corner (the rug, the cushions and the big cushion) in front and the storeroom
## (the returns cart and the boxes of old books) behind. At the long tables, the six readers in pajamas (step 2); behind
## the desk, Doña Sigilo; asleep on the rug, Tomasito. The case comes in later steps. Every number here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(30, 26)
const HALF_X := 15.0
const BACK_Z := -13.0
## The front wall; the steps and the square run from it to the lot's edge.
const FRONT_Z := 6.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT + 1.5
## The reading room is between WEST_X and EAST_X; the stacks east of EAST_X are open to it.
const WEST_X := -6.0
const EAST_X := 6.0
## The wall between the children's corner (front) and the storeroom (back).
const CHILDREN_Z := -3.0
const DOOR_FRONT_X := 0.0
const DOOR_CHILDREN_Z := 2.0
const DOOR_STORE_Z := -8.0
## The front: the steps, the columns and the clock over the door.
const STEPS_AT := Vector3(0, 0, FRONT_Z + 1.5)
const COLUMNS_X: Array[float] = [-4.5, -1.8, 1.8, 4.5]
const COLUMN_Z := FRONT_Z + 0.8
const CLOCK_AT := Vector3(0, ROOF + 1.1, COLUMN_Z + 0.63)
## The reading room: the Golden Book's display case in the middle, the long tables, the reading armchair, the
## librarian's desk and the card catalog by the door.
const CASE_AT := Vector3(0, 0, -1.0)
const CASE_SIZE := Vector3(1.0, 1.1, 0.7)
const TABLES_AT: Array[Vector3] = [Vector3(0, 0, 3.0), Vector3(0, 0, -5.5), Vector3(0, 0, -9.5)]
const TABLE_SIZE := Vector3(6.0, 0.78, 1.2)
const ARMCHAIR_AT := Vector3(-4.6, 0, -1.0)
const DESK_AT := Vector3(4.0, 0, 4.4)
const CATALOG_AT := Vector3(-4.4, 0, 5.3)
const CATALOG_SIZE := Vector3(1.6, 1.3, 0.6)
## The stool with the roll of evidence bags, by the desk.
const BAGS_AT := Vector3(2.2, 0, 5.0)
## Where the Golden Book can be hidden (LibrarySpot): the eight sections, the returns cart and the big cushion.
const BOOK_SPOTS: Array[String] = ["section_A", "section_B", "section_C", "section_D", "section_E", "section_F",
	"section_G", "section_H", "cart", "cushion"]
## Seconds a search of a spot takes, and reading the whole card catalog (propuesta).
const SEARCH_SECONDS := 5.0
const CATALOG_SECONDS := 10.0

## Where the people are: the six readers two by two at the long tables, facing each other across them, Doña Sigilo
## behind her desk facing the room, and Tomasito asleep on the rug.
const READERS_AT: Array[Vector3] = [
	Vector3(-1.5, 0, 1.7), Vector3(1.5, 0, 4.3), Vector3(-1.5, 0, -6.8), Vector3(1.5, 0, -4.2), Vector3(-1.5, 0, -10.8),
	Vector3(1.5, 0, -8.2),
]
const LIBRARIAN_AT := Vector3(4.0, 0, 5.2)
## The stacks: eight shelves along z, four rows of two, each with its letter; books on both faces.
const SECTIONS := {
	"A": Vector3(7.5, 0, -8.5), "B": Vector3(7.5, 0, -1.5), "C": Vector3(9.5, 0, -8.5), "D": Vector3(9.5, 0, -1.5),
	"E": Vector3(11.5, 0, -8.5), "F": Vector3(11.5, 0, -1.5), "G": Vector3(13.5, 0, -8.5), "H": Vector3(13.5, 0, -1.5),
}
const SHELF_SIZE := Vector3(0.6, 2.8, 5.0)
const SHELF_ROWS := 5
const LADDER_AT := Vector3(9.0, 0, 3.0)
## The children's corner: the rug, the small cushions and the big cushion, and where the boy sleeps (step 2).
const RUG_AT := Vector3(-10.5, 0, 2.0)
const CUSHION_AT := Vector3(-12.5, 0, 4.0)
const KID_AT := Vector3(-9.5, 0, 3.5)
## The storeroom: the returns cart and the boxes of old books.
const CART_AT := Vector3(-8.5, 0, -6.0)
const BOXES_AT := Vector3(-13.0, 0, -11.0)
const STONE := Color(0.84, 0.82, 0.76)
const ROOF_COLOR := Color(0.36, 0.42, 0.5)
const INSIDE := Color(0.93, 0.89, 0.78)
const PARQUET := Color(0.55, 0.38, 0.22)
const CARPET := Color(0.55, 0.16, 0.18)
const WOOD := Color(0.42, 0.26, 0.14)
const LAMP_GREEN := Color(0.15, 0.5, 0.3)
const GLASS := Color(0.75, 0.9, 0.95, 0.35)
const GOLD := Color(0.92, 0.75, 0.25)
const WHITE := Color(0.97, 0.97, 0.97)
const BLACK := Color(0.08, 0.08, 0.1)
const METAL := Color(0.6, 0.62, 0.66)
const BOOK_COLORS: Array[Color] = [
	Color(0.7, 0.2, 0.2), Color(0.2, 0.35, 0.65), Color(0.25, 0.5, 0.3), Color(0.8, 0.6, 0.2), Color(0.45, 0.25, 0.5),
	Color(0.85, 0.82, 0.7), Color(0.3, 0.3, 0.32),
]
const CUSHION_COLORS: Array[Color] = [Color(0.95, 0.6, 0.2), Color(0.3, 0.7, 0.85), Color(0.9, 0.45, 0.6),
	Color(0.55, 0.8, 0.35)]

var case: CrimeSceneCase
## What was stolen (CrimeSceneCase's loot texts), where the culprit hid it, whether a search turned it up and whether
## it's back in its display case.
var loot := "golden_book"
var loot_spot := "section_A"
var book_uncovered := false
var loot_found := false
var loot_spots := {}
var book: GoldenBook
var catalog: CardCatalog
var clues: LibraryClues
## What each cop is busy searching ("" for nothing), by cop: a search or the catalog takes a while.
var _busy := {}
var readers: Array[LibraryReader] = []
var librarian: Librarian
var kid: LibraryKid
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("library")
	variant = "library"
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_rooms()
	_reading_room()
	_stacks()
	_children_corner()
	_storeroom()
	_people()


## The case reaches the readers (their traits are its suspects, same seed), and one of them, drawn with the seed,
## won't take off the nightcap until they get something to eat.
func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot_spot = BOOK_SPOTS[absi(hash(["library book spot", case.case_seed])) % BOOK_SPOTS.size()]
	var stubborn := absi(hash("stubborn reader %d" % case.case_seed)) % readers.size()
	for reader in readers:
		reader.case = case
		reader.stubborn = reader.index == stubborn
	kid.case = case
	kid.knows = case.plan.clues.has("witness")
	kid.saw = case.culprit().genre
	clues = LibraryClues.new()
	clues.name = "Clues"
	clues.library = self
	clues.case = case
	add_child(clues)


## E on a spot: the cop searches it for SEARCH_SECONDS, and then the Golden Book turns up if it's there, or the cop
## says what's there instead.
func search(spot: String, cop: Cop) -> void:
	if _busy.get(cop, "") != "":
		return
	_busy[cop] = spot
	if cop:
		cop.show_hint("HINT_LIBRARY_SEARCHING")
	get_tree().create_timer(SEARCH_SECONDS).timeout.connect(searched.bind(spot, cop))


## The search of a spot is over.
func searched(spot: String, cop: Cop) -> void:
	_busy.erase(cop)
	if spot != loot_spot or book_uncovered or not case:
		if cop:
			cop.show_hint("HINT_LIBRARY_NOTHING_" + spot)
		return
	uncover_book()
	if cop:
		cop.show_hint("HINT_LIBRARY_BOOK_UNCOVERED")


## E on the card catalog: CATALOG_SECONDS reading the cards, and then what the swapped card says.
func read_catalog(cop: Cop) -> void:
	if _busy.get(cop, "") != "":
		return
	_busy[cop] = "catalog"
	if cop:
		cop.show_hint("HINT_CATALOG_READING")
	get_tree().create_timer(CATALOG_SECONDS).timeout.connect(catalog_read.bind(cop))


func catalog_read(cop: Cop) -> void:
	_busy.erase(cop)
	if cop:
		cop.show_hint(catalog_says())


## What the card catalog tells: the letter of the section the swapped card hides, or that everything's in order.
func catalog_says() -> String:
	if case and loot_spot.begins_with("section_"):
		return tr("HINT_CATALOG_SWAPPED") % loot_spot.trim_prefix("section_")
	return tr("HINT_CATALOG_IN_ORDER")


## The Golden Book comes out of its hiding spot, on the floor in front of it, for a cop to take back to its case.
func uncover_book() -> void:
	if book_uncovered:
		return
	book_uncovered = true
	book = GoldenBook.new()
	book.name = "GoldenBook"
	book.library = self
	add_child(book)
	var spot := loot_spots[loot_spot] as Node3D
	var out: Vector3 = spot.get_meta("out")
	book.position = Vector3(spot.position.x, FLOOR_TOP, spot.position.z) + out


## The Golden Book back in its display case: the case notes it (+LOOT_BONUS on the salary).
func reveal_loot() -> void:
	if loot_found:
		return
	uncover_book()
	loot_found = true
	# Back in the case unopened, Doña Sigilo locks it: the bookmark stays inside.
	if case and not book.opened:
		case.ruin("bookmark")
	book.position = CASE_AT + Vector3(0, 0.98, 0)
	book.collision_layer = 0
	if case:
		case.found_loot()


## The reader by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return readers[index] if index >= 0 and index < readers.size() else null


## Whether a point in the world (ignoring height) is on the library's lot, steps included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the building.
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## Which room a point in the world is in: "reading", "stacks", "children", "storage", or "" outside the building.
func room(world: Vector3) -> String:
	if not inside(world):
		return ""
	var local := to_local(world)
	if local.x > EAST_X:
		return "stacks"
	if local.x < WEST_X:
		return "children" if local.z > CHILDREN_Z else "storage"
	return "reading"


## The section a point in the world is in front of ("A" to "H"), or "" away from the shelves.
func section(world: Vector3) -> String:
	var local := to_local(world)
	var nearest := ""
	var best := 1.0
	for letter: String in SECTIONS:
		var at: Vector3 = SECTIONS[letter]
		if absf(local.x - at.x) < best and absf(local.z - at.z) < SHELF_SIZE.z / 2:
			best = absf(local.x - at.x)
			nearest = letter
	return nearest


func _spot(spot: String, at: Vector3, size: Vector3) -> void:
	var body := LibrarySpot.new(size)
	body.name = "Search_" + spot
	body.spot = spot
	body.place = self
	body.position = at
	# Where the book lands when it turns up: in the aisle west of a shelf, in front of the cart or the cushion.
	body.set_meta("out", Vector3(-0.8, 0, 0) if spot.begins_with("section_") else Vector3(0, 0, 0.9))
	add_child(body)
	loot_spots[spot] = body


## The six readers alike (ReaderTraits.draw with the case seed) at the tables, Doña Sigilo at her desk and Tomasito
## asleep on the rug.
func _people() -> void:
	var traits := ReaderTraits.draw(case_seed)
	for i in traits.size():
		var reader := LibraryReader.new()
		reader.name = "Reader%d" % i
		reader.traits = traits[i]
		reader.index = i
		reader.position = READERS_AT[i] + Vector3(0, FLOOR_TOP, 0)
		reader.rotation.y = 0.0 if i % 2 == 0 else PI
		add_child(reader)
		readers.append(reader)
	librarian = Librarian.new()
	librarian.name = "Librarian"
	librarian.position = LIBRARIAN_AT + Vector3(0, FLOOR_TOP, 0)
	librarian.rotation.y = PI
	add_child(librarian)
	kid = LibraryKid.new()
	kid.name = "Kid"
	kid.position = KID_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(kid)


## The floors, the high roof with its lights, and the outer walls with the front door.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, PARQUET)
	_builder.mesh_box(Vector3((WEST_X - HALF_X) / 2, FLOOR_TOP + 0.005, (CHILDREN_Z + FRONT_Z) / 2),
		Vector3(HALF_X + WEST_X - 0.2, 0.01, FRONT_Z - CHILDREN_Z - 0.2), Color(0.6, 0.8, 0.55))
	_builder.mesh_box(Vector3(0, FLOOR_TOP + 0.005, -1.0), Vector3(2.4, 0.01, 18.0), CARPET)
	_builder.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, ROOF, INSIDE)
	_builder.mesh_box(Vector3(0, ROOF + 0.4, (BACK_Z + FRONT_Z) / 2), Vector3(SIZE.x + 0.8, 0.5, FRONT_Z - BACK_Z + 0.8),
		ROOF_COLOR)
	_builder.wall_at("x", BACK_Z, -HALF_X, HALF_X, 0, ROOF, [], STONE)
	_builder.wall_at("x", FRONT_Z, -HALF_X, HALF_X, 0, ROOF, [DOOR_FRONT_X], STONE)
	_builder.wall_at("z", -HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], STONE)
	_builder.wall_at("z", HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], STONE)
	for x: float in [-10.5, 0.0, 10.5]:
		for z: float in [-9.0, -1.0, 4.0]:
			_builder.light(Vector3(x, ROOF - 0.5, z))


## The low stone steps up to the door, the four columns with the pediment over them, the clock and the sign.
func _front() -> void:
	for i in 3:
		var depth := 3.0 - i
		var height := 0.05 * (i + 1)
		_builder.box(Vector3(0, height / 2, FRONT_Z + depth / 2), Vector3(11.0 - i, height, depth), STONE)
	for x in COLUMNS_X:
		var column := CylinderMesh.new()
		column.top_radius = 0.3
		column.bottom_radius = 0.35
		column.height = ROOF
		_builder.mesh(column, Vector3(x, ROOF / 2, COLUMN_Z), WHITE)
		_builder.shape(_builder.body(Vector3(x, ROOF / 2, COLUMN_Z)), Vector3(0.6, ROOF, 0.6))
	_builder.mesh_box(Vector3(0, ROOF + 0.3, COLUMN_Z), Vector3(11.0, 0.6, 1.4), WHITE)
	var pediment := PrismMesh.new()
	pediment.size = Vector3(11.0, 1.4, 1.2)
	_builder.mesh(pediment, Vector3(0, ROOF + 1.3, COLUMN_Z), WHITE)
	var clock := CylinderMesh.new()
	clock.top_radius = 0.45
	clock.bottom_radius = 0.45
	clock.height = 0.06
	_builder.mesh(clock, CLOCK_AT, GOLD, Vector3(PI / 2, 0, 0))
	_builder.mesh_box(CLOCK_AT + Vector3(0, 0.15, 0.05), Vector3(0.04, 0.3, 0.02), BLACK)
	_builder.mesh_box(CLOCK_AT + Vector3(0.1, 0, 0.05), Vector3(0.22, 0.04, 0.02), BLACK)
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = "SIGN_LIBRARY"
	sign_label.font_size = 48
	sign_label.pixel_size = 0.008
	sign_label.outline_size = 12
	sign_label.modulate = GOLD
	sign_label.position = Vector3(0, ROOF + 0.3, COLUMN_Z + 0.72)
	add_child(sign_label)


## The walls of the children's corner and the storeroom, with their doors to the reading room.
func _rooms() -> void:
	_builder.wall_at("z", WEST_X, BACK_Z, FRONT_Z, 0, ROOF, [DOOR_CHILDREN_Z, DOOR_STORE_Z], INSIDE)
	_builder.wall_at("x", CHILDREN_Z, -HALF_X, WEST_X, 0, ROOF, [], INSIDE)
	var kids := Label3D.new()
	kids.text = "SIGN_LIBRARY_CHILDREN"
	kids.pixel_size = 0.006
	kids.outline_size = 8
	kids.position = Vector3(WEST_X + 0.12, 2.6, DOOR_CHILDREN_Z)
	kids.rotation.y = PI / 2
	add_child(kids)


## The long tables with their green lamps, the display case with the empty stand, the reading armchair, the
## librarian's desk and the card catalog with its drawers.
func _reading_room() -> void:
	for at in TABLES_AT:
		_builder.box(at + Vector3(0, TABLE_SIZE.y - 0.04, 0), Vector3(TABLE_SIZE.x, 0.08, TABLE_SIZE.z), WOOD)
		_builder.legs(at, Vector2(TABLE_SIZE.x - 0.3, TABLE_SIZE.z - 0.2), TABLE_SIZE.y - 0.08, WOOD.darkened(0.2))
		for x: float in [-2.0, 0.0, 2.0]:
			_builder.mesh_box(at + Vector3(x, TABLE_SIZE.y + 0.2, 0), Vector3(0.05, 0.4, 0.05), METAL)
			_builder.mesh_box(at + Vector3(x, TABLE_SIZE.y + 0.42, 0), Vector3(0.4, 0.12, 0.22), LAMP_GREEN)
	# The display case: a wooden stand, a glass box on it, and the gold stand inside with no book.
	_builder.box(CASE_AT + Vector3(0, 0.45, 0), Vector3(CASE_SIZE.x, 0.9, CASE_SIZE.z), WOOD)
	_builder.box(CASE_AT + Vector3(0, 0.9 + 0.25, 0), Vector3(CASE_SIZE.x, 0.5, CASE_SIZE.z), GLASS)
	_builder.mesh_box(CASE_AT + Vector3(0, 0.95, 0), Vector3(0.4, 0.06, 0.3), GOLD)
	# The reading armchair, red velvet with a footstool.
	_builder.box(ARMCHAIR_AT + Vector3(0, 0.25, 0), Vector3(0.9, 0.5, 0.9), CARPET)
	_builder.box(ARMCHAIR_AT + Vector3(-0.38, 0.7, 0), Vector3(0.15, 0.6, 0.9), CARPET)
	_builder.box(ARMCHAIR_AT + Vector3(0.6, 0.15, 0), Vector3(0.4, 0.3, 0.4), CARPET.darkened(0.2))
	# The librarian's desk with the bell and the stamp.
	_builder.box(DESK_AT + Vector3(0, 0.5, 0), Vector3(2.2, 1.0, 0.7), WOOD)
	_builder.mesh_box(DESK_AT + Vector3(-0.6, 1.05, 0), Vector3(0.12, 0.08, 0.12), GOLD)
	_builder.mesh_box(DESK_AT + Vector3(0.5, 1.05, 0), Vector3(0.1, 0.1, 0.08), BLACK)
	# The card catalog: a cabinet of little drawers, each with its brass handle.
	_builder.mesh_box(CATALOG_AT + Vector3(0, CATALOG_SIZE.y / 2, 0), CATALOG_SIZE, WOOD.lightened(0.15))
	_builder.box(BAGS_AT + Vector3(0, FLOOR_TOP + 0.25, 0), Vector3(0.5, 0.5, 0.4), WOOD)
	bags = EvidenceBags.new()
	bags.name = "EvidenceBags"
	bags.position = BAGS_AT + Vector3(0, FLOOR_TOP + 0.5, 0)
	add_child(bags)
	catalog = CardCatalog.new(CATALOG_SIZE)
	catalog.name = "CardCatalog"
	catalog.library = self
	catalog.position = CATALOG_AT + Vector3(0, CATALOG_SIZE.y / 2, 0)
	add_child(catalog)
	for row in 4:
		for column in 6:
			_builder.mesh_box(CATALOG_AT + Vector3(-0.65 + column * 0.26, 0.25 + row * 0.28, -CATALOG_SIZE.z / 2 - 0.01),
				Vector3(0.06, 0.03, 0.02), GOLD)


## The eight shelves full of books, with their letters over them, and the rolling ladder.
func _stacks() -> void:
	for letter: String in SECTIONS:
		var at: Vector3 = SECTIONS[letter]
		_builder.mesh_box(at + Vector3(0, SHELF_SIZE.y / 2, 0), SHELF_SIZE, WOOD)
		_spot("section_" + letter, at + Vector3(0, SHELF_SIZE.y / 2, 0), SHELF_SIZE)
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(["library shelf", letter])
		for row in SHELF_ROWS:
			var y := 0.3 + row * (SHELF_SIZE.y - 0.4) / SHELF_ROWS
			for face: float in [-1.0, 1.0]:
				var z := at.z - SHELF_SIZE.z / 2 + 0.1
				while z < at.z + SHELF_SIZE.z / 2 - 0.3:
					var length := rng.randf_range(0.5, 1.2)
					length = minf(length, at.z + SHELF_SIZE.z / 2 - 0.1 - z)
					var height := rng.randf_range(0.28, 0.4)
					_builder.mesh_box(Vector3(at.x + face * (SHELF_SIZE.x / 2 + 0.06), y + height / 2, z + length / 2),
						Vector3(0.12, height, length - 0.03), BOOK_COLORS[rng.randi() % BOOK_COLORS.size()])
					z += length
		var label := Label3D.new()
		label.name = "Section" + letter
		label.text = letter
		label.font_size = 96
		label.pixel_size = 0.01
		label.outline_size = 16
		label.modulate = GOLD
		label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		label.position = at + Vector3(0, SHELF_SIZE.y + 0.35, 0)
		add_child(label)
	# The rolling ladder, leaning on its rail.
	for side: float in [-0.25, 0.25]:
		_builder.mesh_box(LADDER_AT + Vector3(side, 1.4, 0), Vector3(0.05, 2.8, 0.05), WOOD.lightened(0.2))
	for step in 7:
		_builder.mesh_box(LADDER_AT + Vector3(0, 0.3 + step * 0.38, 0), Vector3(0.5, 0.04, 0.06), WOOD.lightened(0.2))


## The rug, the small cushions in a ring and the big cushion in the corner, and the little bookcase of picture books.
func _children_corner() -> void:
	var rug := CylinderMesh.new()
	rug.top_radius = 2.2
	rug.bottom_radius = 2.2
	rug.height = 0.02
	_builder.mesh(rug, RUG_AT + Vector3(0, FLOOR_TOP + 0.02, 0), Color(0.95, 0.85, 0.35))
	for i in CUSHION_COLORS.size():
		var turn := TAU * i / CUSHION_COLORS.size()
		_builder.box(RUG_AT + Vector3(cos(turn) * 1.6, 0.12, sin(turn) * 1.6), Vector3(0.6, 0.24, 0.6), CUSHION_COLORS[i])
	_builder.mesh_box(CUSHION_AT + Vector3(0, 0.3, 0), Vector3(1.6, 0.6, 1.4), Color(0.6, 0.4, 0.8))
	_spot("cushion", CUSHION_AT + Vector3(0, 0.3, 0), Vector3(1.6, 0.6, 1.4))
	_builder.box(Vector3(-14.5, 0.6, -0.5), Vector3(0.5, 1.2, 3.0), WOOD.lightened(0.25))
	for i in 6:
		_builder.mesh_box(Vector3(-14.2, 0.95, -1.7 + i * 0.45), Vector3(0.06, 0.35, 0.3), CUSHION_COLORS[i % 4])


## The returns cart, the boxes of old books and the shelves along the back wall.
func _storeroom() -> void:
	_builder.mesh_box(CART_AT + Vector3(0, 0.55, 0), Vector3(1.2, 0.06, 0.6), METAL)
	_builder.mesh_box(CART_AT + Vector3(0, 0.2, 0), Vector3(1.2, 0.06, 0.6), METAL)
	_spot("cart", CART_AT + Vector3(0, 0.45, 0), Vector3(1.2, 0.9, 0.6))
	for x: float in [-0.55, 0.55]:
		_builder.mesh_box(CART_AT + Vector3(x, 0.45, 0), Vector3(0.04, 0.9, 0.04), METAL)
	for i in 5:
		_builder.mesh_box(CART_AT + Vector3(-0.45 + i * 0.22, 0.72, 0), Vector3(0.18, 0.3, 0.45), BOOK_COLORS[i])
	for i in 4:
		_builder.box(BOXES_AT + Vector3((i % 2) * 0.7, 0.25 + (i / 2) * 0.5, 0), Vector3(0.6, 0.5, 0.5),
			Color(0.7, 0.55, 0.35))
	_builder.box(Vector3(-10.5, 1.2, BACK_Z + 0.3), Vector3(7.0, 2.4, 0.5), WOOD)
