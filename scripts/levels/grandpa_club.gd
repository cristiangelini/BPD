class_name GrandpaClub
extends Node3D

## The grandparents' club "Club de Jubilados Los Años Dorados" (docs/diseno/infiltracion.md, step 2a): one floor on its
## lot in the city, the front to +Z. The hall has 12 bingo tables, the bingo stand by the stage and the dance floor;
## behind it, the kitchen, Doña Chela's office (locked) and the storeroom. The cops start in the station, where the
## disguises are, and drive here. --place=club opens it from Play. The grandparents, the doorman and the case come in
## the next steps. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const BINGO_CAGE_SCENE := preload("res://scenes/props/bingo_cage.tscn")
const HALF_X := 14.0
const HALF_Z := 11.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway between the tables and the dance floor.
const ENTRANCE_X := 3.5
## The back rooms run along the north: the wall between them and the hall, and the walls between them.
const BACK_Z := -4.0
const KITCHEN_EAST := -5.0
const STORE_WEST := 5.0
## The doorways from the hall: kitchen, office (with a door) and storeroom.
const KITCHEN_DOOR_X := -9.5
const OFFICE_DOOR_X := 0.0
const STORE_DOOR_X := 9.5
## The bingo tables: 4 columns by 3 rows, each with 4 chairs.
const TABLE_XS: Array[float] = [-9.0, -5.5, -2.0, 1.5]
const TABLE_ZS: Array[float] = [-1.0, 3.0, 7.0]
const TABLE_SIZE := Vector2(1.6, 1.0)
const TABLE_HEIGHT := 0.75
## The stage on the west wall, low enough to step onto, and the bingo stand in front of it.
const STAGE := Rect2(-14.0, -3.0, 2.6, 7.0)
const STAGE_HEIGHT := 0.3
const BINGO_STAND := Vector3(-10.6, 0, 0.5)
## The dance floor, a checkerboard on the east side of the hall.
const DANCE_FLOOR := Rect2(5.5, -2.5, 7.5, 9.0)
const DANCE_TILE := 1.5
## How many grandparents play bingo, of the 48 seats; the rest are for the cops.
const MEMBERS := 16
## Doña Chela calls the numbers from the stage, behind the bingo stand.
const CHELA_AT := Vector3(-11.9, 0, 0.5)
## One bingo card per cop, on free seats of the tables (drawn with the seed).
const CARDS := 4
## The doorman stands outside, by the entrance.
const DOORMAN_AT := Vector3(ENTRANCE_X + 1.4, 0, HALF_Z + 0.7)

const OUTSIDE := Color(0.82, 0.55, 0.75)
const INSIDE := Color(0.98, 0.9, 0.78)
const WOOD := Color(0.6, 0.4, 0.26)
const TILES := Color(0.78, 0.7, 0.6)
const TABLECLOTH := Color(0.35, 0.6, 0.4)
const CHAIR := Color(0.5, 0.32, 0.2)
const STAGE_COLOR := Color(0.55, 0.15, 0.2)
const DANCE_LIGHT := Color(0.95, 0.92, 0.85)
const DANCE_DARK := Color(0.2, 0.18, 0.2)

## Same seed, same club (the grandparents and the evidence, in the next steps). 0 draws one.
@export var case_seed := 0
var office_door: FrontDoor
var bingo_cage: Node3D
## The tables' middles on the floor, in the club's space.
var tables: Array[Vector3] = []
var members: Array[ClubMember] = []
var chela: ClubMember
var doorman: ClubDoorman
var bingo: ClubBingo
var suspicion: ClubSuspicion
var dance: ClubDance
## The seats nobody took, as seats() gives them.
var free_seats: Array = []
var station_parking: Transform3D
var _build: PlaceBuilder

@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_hall()
	_build_back_rooms()
	_add_people()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("grandpa_club")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)


## Floor, outer walls with the entrance, the roof and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, TILES)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.35))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	_build.mesh_box(Vector3(ENTRANCE_X, GameScale.DOOR_HEIGHT + 0.25, HALF_Z + 0.8), Vector3(4.0, 0.1, 1.5), STAGE_COLOR)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_GRANDPA_CLUB"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(-4.0, ROOF + 0.5, HALF_Z)
	$Built.add_child(sign_label)
	for x: float in [-10.0, 0.0, 10.0]:
		for z: float in [-7.5, 0.0, 6.0]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The bingo tables with their chairs, the stage, the bingo stand and the dance floor.
func _build_hall() -> void:
	for z: float in TABLE_ZS:
		for x: float in TABLE_XS:
			var at := Vector3(x, FLOOR_TOP, z)
			tables.append(at)
			_build.legs(at, TABLE_SIZE, TABLE_HEIGHT - 0.04, WOOD)
			_build.box(at + Vector3(0, TABLE_HEIGHT - 0.02, 0), Vector3(TABLE_SIZE.x, 0.04, TABLE_SIZE.y), TABLECLOTH)
			for side: float in [-1.0, 1.0]:
				for along: float in [-0.4, 0.4]:
					_build.box(at + Vector3(along, 0.22, side * (TABLE_SIZE.y / 2 + 0.35)), Vector3(0.42, 0.44, 0.42), CHAIR)
	var stage_center := STAGE.get_center()
	_build.box(Vector3(stage_center.x, FLOOR_TOP + STAGE_HEIGHT / 2, stage_center.y),
		Vector3(STAGE.size.x, STAGE_HEIGHT, STAGE.size.y), STAGE_COLOR)
	_build.box(BINGO_STAND + Vector3(0, FLOOR_TOP + 0.5, 0), Vector3(0.8, 1.0, 0.6), WOOD)
	bingo_cage = BINGO_CAGE_SCENE.instantiate()
	bingo_cage.name = "BingoCage"
	add_child(bingo_cage)
	bingo_cage.position = BINGO_STAND + Vector3(0, FLOOR_TOP + 1.25, 0)
	var columns := roundi(DANCE_FLOOR.size.x / DANCE_TILE)
	var rows := roundi(DANCE_FLOOR.size.y / DANCE_TILE)
	for i in columns:
		for j in rows:
			var tile_at := DANCE_FLOOR.position + Vector2(i + 0.5, j + 0.5) * DANCE_TILE
			_build.mesh_box(Vector3(tile_at.x, FLOOR_TOP + 0.006, tile_at.y), Vector3(DANCE_TILE, 0.01, DANCE_TILE),
				DANCE_LIGHT if (i + j) % 2 == 0 else DANCE_DARK)


## Every chair by the tables, as [where on the floor, the table's middle], in the club's space.
func seats() -> Array:
	var all := []
	for at: Vector3 in tables:
		for side: float in [-1.0, 1.0]:
			for along: float in [-0.4, 0.4]:
				all.append([at + Vector3(along, 0, side * (TABLE_SIZE.y / 2 + 0.35)), at])
	return all


## The grandparents at their seats (drawn with the seed), Doña Chela on the stage and the doorman at the entrance.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["club members", case_seed])
	var free := seats()
	for i in MEMBERS:
		var seat: Array = free.pop_at(rng.randi_range(0, free.size() - 1))
		var member := ClubMember.new()
		member.name = "Member%d" % i
		member.look = "abuela" if rng.randf() < 0.5 else "abuelo"
		member.next_line = rng.randi_range(0, ClubMember.GOSSIP_LINES - 1)
		add_child(member)
		member.position = seat[0]
		var to_table: Vector3 = seat[1] - seat[0]
		member.rotation.y = atan2(-to_table.x, -to_table.z)
		members.append(member)
	chela = ClubMember.new()
	chela.name = "Chela"
	chela.look = "chela"
	add_child(chela)
	chela.position = CHELA_AT + Vector3(0, FLOOR_TOP + STAGE_HEIGHT, 0)
	# Facing the hall (+X).
	chela.rotation.y = -PI / 2
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	add_child(doorman)
	doorman.position = DOORMAN_AT
	doorman.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	free_seats = free
	_add_bingo(rng)
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.chela = chela
	suspicion.inside = func(at: Vector3) -> bool:
		var local := global_transform.affine_inverse() * at
		return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF
	suspicion.in_back_room = func(at: Vector3) -> bool:
		var local := global_transform.affine_inverse() * at
		return absf(local.x) < HALF_X and local.z > -HALF_Z and local.z < BACK_Z and local.y < ROOF
	add_child(suspicion)
	suspicion.watch_bingo(bingo)
	dance = ClubDance.new()
	dance.name = "Dance"
	dance.chela = chela
	dance.inside = suspicion.inside
	dance.on_floor = func(at: Vector3) -> bool:
		var local := global_transform.affine_inverse() * at
		return DANCE_FLOOR.has_point(Vector2(local.x, local.z)) and local.y < ROOF
	add_child(dance)
	var floor_middle := DANCE_FLOOR.get_center()
	dance.position = Vector3(floor_middle.x, 1.5, floor_middle.y)
	suspicion.watch_dance(dance)


## Doña Chela's bingo at the stand, and the cops' cards in front of free seats, lying on the table.
func _add_bingo(rng: RandomNumberGenerator) -> void:
	bingo = ClubBingo.new()
	bingo.name = "Bingo"
	bingo.case_seed = case_seed
	bingo.members = members
	add_child(bingo)
	bingo.position = BINGO_STAND
	for i in CARDS:
		var seat: Array = free_seats.pop_at(rng.randi_range(0, free_seats.size() - 1))
		var card := ClubBingoCard.new()
		card.name = "BingoCard%d" % i
		bingo.add_card(card, i)
		add_child(card)
		var table: Vector3 = seat[1]
		var toward: Vector3 = seat[0] - table
		card.position = table + toward * 0.25 + Vector3(0, TABLE_HEIGHT + 0.01, 0)
		# The card's top row (B I N G O) away from the seat.
		card.rotation.y = atan2(toward.x, toward.z)


## The kitchen, the office and the storeroom behind the hall, with their counters and shelves.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [KITCHEN_DOOR_X, OFFICE_DOOR_X, STORE_DOOR_X], INSIDE)
	_build.wall("z", KITCHEN_EAST, -HALF_Z, BACK_Z, 0, [], INSIDE)
	_build.wall("z", STORE_WEST, -HALF_Z, BACK_Z, 0, [], INSIDE)
	# Kitchen: a counter along the back wall.
	_build.box(Vector3(-9.5, FLOOR_TOP + 0.45, -10.4), Vector3(8.0, 0.9, 0.8), INSIDE.darkened(0.15))
	# Office: a desk and a filing cabinet.
	_build.legs(Vector3(0, FLOOR_TOP, -8.5), Vector2(1.8, 0.9), 0.72, WOOD)
	_build.box(Vector3(0, FLOOR_TOP + 0.74, -8.5), Vector3(1.8, 0.04, 0.9), WOOD)
	_build.box(Vector3(3.8, FLOOR_TOP + 0.7, -10.3), Vector3(0.9, 1.4, 0.6), Color(0.5, 0.52, 0.55))
	# Storeroom: shelves along the back and east walls.
	_build.open_box(Vector3(9.5, FLOOR_TOP, -10.5), Vector3(6.0, 2.0, 0.6), "+z", WOOD)
	_build.open_box(Vector3(13.4, FLOOR_TOP, -7.0), Vector3(0.6, 2.0, 4.0), "-x", WOOD)
