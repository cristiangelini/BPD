class_name WrongHouse
extends Node3D

## The wrong house (docs/diseno/casa-equivocada.md, step 1, decision 223): two twin two-storey houses joined by the
## party wall, on one lot with the fronts to +Z. Same color, same roof, same green door, and each lost a digit of its
## number ("1_" and "_4"): the warrant says 14 and either could be it. Which one is the guilty neighbor's, the west or
## the east, comes from the seed (or --guilty=left|right); the other is doña Chola's, who knows nothing. Each house
## has its front door locked with the key in one of its pots, its ornaments (fines), its mailbox, and an old station
## wagon parked in the side passage, nose to the street. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const POT_SCENE := preload("res://scenes/props/key_pot.tscn")
## Each house is HALF_U * 2 wide; the west one's middle at -HALF_U and the east one's at +HALF_U, the party wall at x = 0.
const HALF_U := 7.0
const FRONT_Z := 7.0
const BACK_Z := -4.0
## The lot's edges: the front garden runs to LOT_Z, the back yard to -LOT_Z, the side passages to LOT_X.
const LOT_X := 18.0
const LOT_Z := 10.0
const FLOOR_TOP := 0.06
## The wall between the front rooms and the back ones, and the walls of the stair hall (in a house's own x, u).
const SPLIT_Z := 1.5
const HALL_WEST := -2.5
const HALL_EAST := 1.5
const ENTRANCE_U := -3.5
const BACK_DOOR_U := 4.5
const SIDE_DOOR_Z := -1.0
const STAIR_U := -0.5
const STAIR_FOOT_Z := 1.0
const STAIR_RUN := 3.75
const FENCE_HEIGHT := 0.9
## Where each house's three pots stand in its front garden, and its mailbox by the sidewalk (house space).
const POTS: Array[Vector3] = [Vector3(-5.0, 0.0, 7.8), Vector3(-2.0, 0.0, 7.8), Vector3(1.0, 0.0, 8.4)]
const MAILBOX_AT := Vector3(-5.5, 0.0, 9.6)
## The station wagon in the side passage beside each house (outside it, so -/+ by the house's side).
const WAGON_X := 16.0
const WAGON_Z := 3.0
const WAGON_SIZE := Vector3(1.9, 1.5, 4.6)
const NUMBERS: Array[String] = ["1_", "_4"]
const LEFT := 0
const RIGHT := 1
## Ornament shelves in house space (OrnamentLayout units) and the kitchen counter's row of plates.
const SHELVES := [
	{"at": Vector3(-6.75, 0, 4.3), "along": "z", "width": 2.0},  # living
	{"at": Vector3(-6.75, GameScale.FLOOR_HEIGHT, 4.3), "along": "z", "width": 2.0},  # west bedroom
	{"at": Vector3(6.75, GameScale.FLOOR_HEIGHT, 4.3), "along": "z", "width": 2.0},  # east bedroom
]
const COUNTER_AT := Vector3(4.5, FLOOR_TOP, 2.0)
const COUNTER_PLATES := 6

const WALLS := Color(0.95, 0.86, 0.6)
const INSIDE := Color(0.96, 0.93, 0.86)
const DOOR_GREEN := Color(0.2, 0.55, 0.3)
const ROOF := Color(0.62, 0.3, 0.24)
const TILES := Color(0.78, 0.7, 0.6)
const WOOD := Color(0.55, 0.38, 0.25)
const WHITE := Color(0.93, 0.93, 0.9)
const FENCE := Color(0.9, 0.9, 0.85)
const WAGON := Color(0.55, 0.62, 0.48)
const WAGON_ROOF := Color(0.45, 0.34, 0.24)

@export var case_seed := 0
## The guilty neighbor's house: LEFT (west) or RIGHT (east).
var guilty := LEFT
## By house (LEFT, RIGHT): its front door, its pots, which pot has the key, its ornaments and its station wagon.
var doors: Array[FrontDoor] = []
var pots: Array = [[], []]
var key_pot: Array[int] = [0, 0]
var ornaments: Array = [[], []]
var broken: Array[int] = [0, 0]
var wagons: Array[StaticBody3D] = []
var station_parking: Transform3D
var _build: PlaceBuilder
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	guilty = pick_guilty(case_seed, OS.get_cmdline_user_args())
	_build = PlaceBuilder.new($Built)
	_build_lot()
	for house in 2:
		_build_house(house)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("wrong_house")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = city.transform * CityLayout.parking("wrong_house")
	car.global_position += Vector3.UP * 0.05
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))


## The guilty house from --guilty=left|right among the user args, or drawn from the seed.
static func pick_guilty(seed_value: int, args: PackedStringArray) -> int:
	for arg: String in args:
		if arg == "--guilty=left":
			return LEFT
		if arg == "--guilty=right":
			return RIGHT
	return hash(["wrong house", seed_value]) % 2


## A house's middle on the lot.
static func house_x(house: int) -> float:
	return -HALF_U if house == LEFT else HALF_U


## Where `local` (in a house's own space, u along x) sits on the lot.
static func at(house: int, local: Vector3) -> Vector3:
	return local + Vector3(house_x(house), 0, 0)


## Which house a point of the lot is in, by its side of the party wall.
static func house_of(point: Vector3) -> int:
	return LEFT if point.x < 0.0 else RIGHT


## The low fences round the back yards (one between them, over the party wall) and down the side passages.
func _build_lot() -> void:
	var y := FENCE_HEIGHT / 2
	_build.box(Vector3(0, y, -LOT_Z), Vector3(LOT_X * 2, FENCE_HEIGHT, 0.06), FENCE)
	_build.box(Vector3(0, y, (BACK_Z - LOT_Z) / 2), Vector3(0.06, FENCE_HEIGHT, LOT_Z + BACK_Z), FENCE)
	for x: float in [-LOT_X, LOT_X]:
		_build.box(Vector3(x, y, 0), Vector3(0.06, FENCE_HEIGHT, LOT_Z * 2), FENCE)


func _build_house(house: int) -> void:
	var x := house_x(house)
	var up := GameScale.FLOOR_HEIGHT
	_build.slab(x - HALF_U, x + HALF_U, BACK_Z, FRONT_Z, FLOOR_TOP, TILES)
	# Upstairs floor with the hole over the stairs (a little wider to the west, for the head), and the ceiling.
	var hole_w := x + STAIR_U - GameScale.STAIR_WIDTH / 2 - 0.3
	var hole_e := x + STAIR_U + GameScale.STAIR_WIDTH / 2
	var hole_n := STAIR_FOOT_Z - STAIR_RUN
	_build.slab(x - HALF_U, hole_w, BACK_Z, FRONT_Z, up, TILES)
	_build.slab(hole_e, x + HALF_U, BACK_Z, FRONT_Z, up, TILES)
	_build.slab(hole_w, hole_e, BACK_Z, hole_n, up, TILES)
	_build.slab(hole_w, hole_e, STAIR_FOOT_Z, FRONT_Z, up, TILES)
	_build.slab(x - HALF_U - 0.2, x + HALF_U + 0.2, BACK_Z - 0.2, FRONT_Z + 0.2, up * 2, ROOF)
	var roof := PrismMesh.new()
	roof.size = Vector3(HALF_U * 2 + 0.4, 2.0, FRONT_Z - BACK_Z + 0.6)
	_build.mesh(roof, Vector3(x, up * 2 + 1.0, (FRONT_Z + BACK_Z) / 2), ROOF)
	_build.box(Vector3(x + hole_w - x - 0.04, up + 0.5, (hole_n + STAIR_FOOT_Z) / 2), Vector3(0.08, 1.0, STAIR_RUN), WHITE)
	for level in 2:
		_build.wall("x", FRONT_Z, x - HALF_U, x + HALF_U, level, [x + ENTRANCE_U] if level == 0 else [], WALLS)
		_build.wall("x", BACK_Z, x - HALF_U, x + HALF_U, level, [x + BACK_DOOR_U] if level == 0 else [], WALLS)
		# The outer side walls; the party wall at x = 0 is built once, by the west house.
		var outer := x - HALF_U if house == LEFT else x + HALF_U
		_build.wall("z", outer, BACK_Z, FRONT_Z, level, [], WALLS)
		if house == LEFT:
			_build.wall("z", 0.0, BACK_Z, FRONT_Z, level, [], WALLS)
		# Front rooms (living and kitchen downstairs, two bedrooms up) off the stair hall behind them; bathroom and
		# laundry (storeroom up) on each side of the hall.
		_build.wall("x", SPLIT_Z, x - HALF_U, x + HALF_U, level, [x + STAIR_U - 1.0] if level == 0 else [x - 4.0, x + 3.5], INSIDE)
		_build.wall("z", x, SPLIT_Z, FRONT_Z, level, [4.0] if level == 0 else [], INSIDE)
		_build.wall("z", x + HALL_WEST, BACK_Z, SPLIT_Z, level, [SIDE_DOOR_Z], INSIDE)
		_build.wall("z", x + HALL_EAST, BACK_Z, SPLIT_Z, level, [SIDE_DOOR_Z], INSIDE)
		for u: float in [-3.5, 3.5]:
			_build.light(Vector3(x + u, level * up + 2.2, 4.3))
		_build.light(Vector3(x - 0.5, level * up + 2.2, -1.5))
	_build.stairs(Vector3(x + STAIR_U, FLOOR_TOP, STAIR_FOOT_Z), STAIR_RUN, WOOD)
	_furniture(house)
	_front(house)
	_fragile(house)


## The same furniture in both: sofa and TV, kitchen counter and fridge, bathtub, washing machine, two beds and boxes.
func _furniture(house: int) -> void:
	var up := GameScale.FLOOR_HEIGHT
	_build.legs(at(house, Vector3(-3.5, FLOOR_TOP, 2.5)), Vector2(2.2, 0.8), 0.3, WOOD)
	_build.box(at(house, Vector3(-3.5, 0.45, 2.5)), Vector3(2.2, 0.3, 0.8), DOOR_GREEN.lightened(0.3))
	_build.box(at(house, Vector3(-3.5, 0.5, 6.5)), Vector3(1.4, 0.9, 0.5), Color(0.2, 0.2, 0.22))
	_build.box(COUNTER_AT + Vector3(house_x(house), 0.45, 0), Vector3(3.0, 0.9, 0.6), WHITE)
	_build.open_box(at(house, Vector3(6.4, FLOOR_TOP, 6.4)), Vector3(0.8, 1.8, 0.7), "-x", WHITE)
	_build.open_box(at(house, Vector3(-5.6, FLOOR_TOP, -3.2)), Vector3(1.7, 0.6, 0.8), "top", WHITE)
	_build.open_box(at(house, Vector3(6.4, FLOOR_TOP, -3.3)), Vector3(0.9, 0.9, 0.9), "-x", WHITE)
	for u: float in [-3.5, 3.5]:
		_build.legs(at(house, Vector3(u, up, 5.5)), Vector2(1.5, 2.1), 0.34, WOOD)
		_build.box(at(house, Vector3(u, up + 0.45, 5.5)), Vector3(1.4, 0.2, 2.0), WHITE)
	_build.box(at(house, Vector3(5.5, up + 0.3, -2.8)), Vector3(0.8, 0.6, 0.8), Color(0.7, 0.55, 0.35))


## The front: the green door (locked), its lost digit over it, the pots, the mailbox and the wagon in the passage.
func _front(house: int) -> void:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = at(house, Vector3(ENTRANCE_U - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, FRONT_Z))
	add_child(door)
	(door.get_node("Panel/Mesh") as MeshInstance3D).material_override = _build.material(DOOR_GREEN)
	doors.append(door)
	var number := Label3D.new()
	number.text = NUMBERS[house]
	number.font_size = 96
	number.pixel_size = 0.006
	number.outline_size = 12
	number.position = at(house, Vector3(ENTRANCE_U, GameScale.DOOR_HEIGHT + 0.35, FRONT_Z + 0.1))
	$Built.add_child(number)
	key_pot[house] = hash(["wrong house key", case_seed, house]) % POTS.size()
	for i in POTS.size():
		var pot: KeyPot = POT_SCENE.instantiate()
		pot.position = at(house, POTS[i])
		pot.has_key = i == key_pot[house]
		$Built.add_child(pot)
		pots[house].append(pot)
	_build.box(at(house, MAILBOX_AT + Vector3(0, 0.5, 0)), Vector3(0.06, 1.0, 0.06), WOOD)
	_build.box(at(house, MAILBOX_AT + Vector3(0, 1.1, 0)), Vector3(0.3, 0.25, 0.45), Color(0.2, 0.35, 0.7))
	var side := -1.0 if house == LEFT else 1.0
	var wagon := _build.body(Vector3(side * WAGON_X, 0, WAGON_Z))
	_build.shape(wagon, WAGON_SIZE)
	wagon.get_child(0).position.y = WAGON_SIZE.y / 2 + 0.25
	var parts := [[Vector3(0, 0.75, 0), Vector3(WAGON_SIZE.x, 0.7, WAGON_SIZE.z), WAGON],
		[Vector3(0, 1.35, -0.4), Vector3(WAGON_SIZE.x - 0.1, 0.55, 3.2), WAGON_ROOF]]
	for part: Array in parts:
		var mesh := BoxMesh.new()
		mesh.size = part[1]
		var piece := MeshInstance3D.new()
		piece.mesh = mesh
		piece.material_override = _build.material(part[2])
		piece.position = part[0]
		wagon.add_child(piece)
	for wheel_at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.position = wheel_at
		wagon.add_child(wheel)
	wagons.append(wagon)


## The ornaments on the shelves and the plates on the kitchen counter; each one that breaks is a fine.
func _fragile(house: int) -> void:
	for unit: Dictionary in SHELVES:
		var placed := unit.duplicate()
		placed.at = at(house, unit.at)
		for piece: Array in OrnamentLayout.shelf_boxes(placed):
			_build.box(piece[0], piece[1], WOOD)
	for spot: Dictionary in ornament_places(case_seed, house):
		var ornament: Ornament = OrnamentLayout.KINDS[spot.kind].instantiate()
		ornament.position = spot.at
		ornament.rotation.y = spot.turn
		add_child(ornament)
		ornament.broken.connect(_on_ornament_broken.bind(house))
		ornaments[house].append(ornament)


## Every ornament of a house: [{"kind", "at", "turn"}], the same for the same seed.
static func ornament_places(seed_value: int, house: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["wrong house ornaments", seed_value, house])
	var result := []
	for unit: Dictionary in SHELVES:
		var along := Vector3.RIGHT if unit.along == "x" else Vector3.BACK
		var count := floori(unit.width / OrnamentLayout.SPACING)
		for level: float in OrnamentLayout.SHELF_LEVELS:
			for i in count:
				var offset: float = (i - (count - 1) / 2.0) * OrnamentLayout.SPACING
				_add(result, rng, rng.randi_range(0, OrnamentLayout.KINDS.size() - 1),
					at(house, unit.at + along * offset + Vector3.UP * level))
	for i in COUNTER_PLATES:
		var offset := (i - (COUNTER_PLATES - 1) / 2.0) * 0.4
		_add(result, rng, OrnamentLayout.PLATE, at(house, COUNTER_AT + Vector3(offset, 0.9, 0)))
	return result


static func _add(result: Array, rng: RandomNumberGenerator, kind: int, surface: Vector3) -> void:
	result.append({"kind": kind, "at": surface + Vector3.UP * (OrnamentLayout.HALF_HEIGHTS[kind] + 0.005),
		"turn": rng.randf() * TAU})


func _on_ornament_broken(_at: Vector3, house: int) -> void:
	broken[house] += 1
