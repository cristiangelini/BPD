class_name InsuranceOffice
extends Node3D

## The insurance office "Seguros Todo Tranquilo" (docs/diseno/seguros.md, step 1): one floor on its lot in the city,
## with the front to +Z and the rest of the building's floors closed above it. The reception at the front, the twelve
## cubicles in the middle and west, the meeting room and the kitchen nook in the east, the floor boss's office at the
## back east, the archive at the back west and the giant printer between them. The reception is open; the boss's
## office and the archive are locked. The rolling chairs roll, the paper piles fly, and the glass trophies and the
## monitors of the middle row break, each one a fine. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const CHAIR_SCENE := preload("res://scenes/props/office_chair.tscn")
const MONITOR_SCENE := preload("res://scenes/props/office_monitor.tscn")
const MONITOR_MODEL := preload("res://assets/models/office_monitor.glb")
const TROPHY_SCENE := preload("res://scenes/props/glass_trophy.tscn")
const COFFEE_MODEL := preload("res://assets/models/coffee_machine.glb")
const COOLER_MODEL := preload("res://assets/models/water_cooler.glb")
const HALF_X := 11.0
const HALF_Z := 8.0
## The office floor's ceiling, and the closed floors of the building over it up to the lot's height.
const WALL_TOP := 3.2
const BUILDING_TOP := 12.0
const FLOOR_TOP := 0.06
const ENTRANCE_WIDTH := 2.4
## The wall between the reception and the rest, with its two openings.
const RECEPTION_Z := 5.0
const RECEPTION_OPENINGS: Array[float] = [-8.0, 2.0]
const OPENING_WIDTH := 1.8
## The east band: the meeting room at the front, the kitchen nook in the middle and the boss's office at the back.
const EAST_X := 4.0
const MEETING_BACK_Z := 1.0
const MEETING_DOOR_Z := 3.0
const OFFICE_FRONT_Z := -2.5
const OFFICE_DOOR_X := 6.0
## The archive at the back west, and its door.
const ARCHIVE_X := -5.0
const ARCHIVE_FRONT_Z := -4.5
const ARCHIVE_DOOR_X := -8.0
## The cubicles: four across, three rows, each open to +Z, with its desk against the low back partition.
const CUBICLE_COLUMNS: Array[float] = [-9.4, -6.6, -3.8, -1.0]
const CUBICLE_ROWS: Array[float] = [3.3, 0.7, -1.9]
const CUBICLE_SIZE := Vector2(2.4, 1.6)
const PARTITION_HEIGHT := 1.2
const CUBICLE_DESK_SIZE := Vector3(1.6, 0.78, 0.6)
## The row whose monitors are real (fragile); the rest are only for the look.
const MONITOR_ROW := 1
const DESK_AT := Vector3(-6.0, FLOOR_TOP, 6.6)
const DESK_SIZE := Vector3(2.4, 1.0, 0.7)
const COOLER_AT := Vector3(9.8, FLOOR_TOP, 7.3)
const PRINTER_AT := Vector3(0.0, FLOOR_TOP, -6.8)
const PRINTER_SIZE := Vector3(1.4, 1.3, 0.9)
const MEETING_TABLE_AT := Vector3(7.6, FLOOR_TOP, 3.0)
const MEETING_TABLE_SIZE := Vector3(4.0, 0.75, 1.4)
const MEETING_CABINET_AT := Vector3(10.4, FLOOR_TOP, 4.2)
const MEETING_CABINET_SIZE := Vector3(0.8, 1.0, 0.9)
const COUNTER_AT := Vector3(7.5, FLOOR_TOP, 0.6)
const COUNTER_SIZE := Vector3(3.0, 0.9, 0.6)
const COFFEE_AT := Vector3(10.5, FLOOR_TOP, -0.6)
const COFFEE_SIZE := Vector3(0.7, 1.6, 0.6)
const FRIDGE_AT := Vector3(10.55, FLOOR_TOP, -1.8)
const FRIDGE_SIZE := Vector3(0.7, 1.7, 0.7)
const BIN_AT := Vector3(4.6, FLOOR_TOP, 0.5)
const BIN_SIZE := Vector3(0.4, 0.5, 0.4)
const BOSS_DESK_AT := Vector3(8.5, FLOOR_TOP, -6.0)
const BOSS_DESK_SIZE := Vector3(1.6, 0.75, 0.8)
const FILING_AT := Vector3(10.5, FLOOR_TOP, -7.5)
const SAFE_AT := Vector3(5.0, FLOOR_TOP, -7.4)
const SAFE_SIZE := Vector3(0.6, 0.6, 0.6)
## The shelf of glass trophies on the boss's east wall.
const TROPHY_SHELF_AT := Vector3(10.7, FLOOR_TOP + 1.2, -4.5)
const TROPHIES := 6
const TROPHY_HALF_HEIGHT := 0.125
const ARCHIVE_BOX_AT := Vector3(-9.5, FLOOR_TOP, -5.6)
const ARCHIVE_BOX_SIZE := Vector3(1.0, 0.6, 0.8)
const ARCHIVE_SHELF_Z := -7.55
const ARCHIVE_BOARDS: Array[float] = [0.5, 1.2, 1.9]
const ARCHIVE_GAP_X := -6.0
const SHREDDER_AT := Vector3(-5.6, FLOOR_TOP, -5.2)

const OUTSIDE := Color(0.6, 0.65, 0.7)
const GLASS := Color(0.55, 0.75, 0.85, 0.35)
const INSIDE := Color(0.9, 0.9, 0.86)
const CARPET := Color(0.52, 0.54, 0.56)
const PARTITION := Color(0.55, 0.62, 0.72)
const DESK := Color(0.82, 0.76, 0.62)
const WOOD := Color(0.5, 0.36, 0.24)
const STEEL := Color(0.62, 0.65, 0.7)
const CARDBOARD := Color(0.72, 0.56, 0.36)
const WHITE := Color(0.95, 0.95, 0.93)
const DARK := Color(0.2, 0.2, 0.23)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "under_reception_desk", "at": DESK_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "under_cubicle_desk", "at": Vector3(-9.4, FLOOR_TOP, -2.35), "heavy": true},
	{"id": "on_cubicle_desk", "at": Vector3(-0.95, FLOOR_TOP + 0.78, 2.85), "heavy": false},
	{"id": "under_meeting_table", "at": MEETING_TABLE_AT + Vector3(-0.8, 0, 0), "heavy": true},
	{"id": "in_meeting_cabinet", "at": MEETING_CABINET_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "in_fridge", "at": FRIDGE_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "in_kitchen_bin", "at": BIN_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "in_boss_safe", "at": SAFE_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "in_filing_cabinet", "at": FILING_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "behind_printer", "at": Vector3(PRINTER_AT.x, FLOOR_TOP, -7.6), "heavy": true},
	{"id": "in_archive_box", "at": ARCHIVE_BOX_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "on_archive_shelf", "at": Vector3(ARCHIVE_GAP_X, FLOOR_TOP + ARCHIVE_BOARDS[1] + 0.02, ARCHIVE_SHELF_Z), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var boss_door: FrontDoor
var archive_door: FrontDoor
var city_map: CityMap
var chairs: Array[Grabbable] = []
var piles: Array[PaperPile] = []
var monitors: Array[Ornament] = []
var trophies: Array[Ornament] = []
var broken_goods := 0
## Money taken off the case pay for broken things (each one is an Ornament.FINE).
var fines := 0
var _build: PlaceBuilder
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_reception()
	_build_cubicles()
	_build_meeting_room()
	_build_kitchen()
	_build_boss_office()
	_build_archive()
	_place_fragile()
	boss_door = _door(Vector3(OFFICE_DOOR_X, FLOOR_TOP, OFFICE_FRONT_Z))
	archive_door = _door(Vector3(ARCHIVE_DOOR_X, FLOOR_TOP, ARCHIVE_FRONT_Z))
	var city: Node3D = $City
	city.transform = CityLayout.anchor("insurance")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "insurance", car)


## A locked door in a wall along x, its middle at `at`.
func _door(at: Vector3) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(at.x - GameScale.DOOR_WIDTH / 2, at.y - FLOOR_TOP, at.z)
	add_child(door)
	return door


## A wall from the floor up to WALL_TOP, along "x" (at z = fixed) or "z" (at x = fixed), with openings given as
## Vector3(middle, width, height).
func _wall(axis: String, fixed: float, from: float, to: float, openings: Array, color: Color) -> void:
	var start := from
	for opening: Vector3 in openings:
		var a := opening.x - opening.y / 2
		var b := opening.x + opening.y / 2
		_wall_box(axis, fixed, start, a, 0.0, WALL_TOP, color)
		_wall_box(axis, fixed, a, b, opening.z, WALL_TOP, color)
		start = b
	_wall_box(axis, fixed, start, to, 0.0, WALL_TOP, color)


func _wall_box(axis: String, fixed: float, a: float, b: float, y0: float, y1: float, color: Color) -> void:
	if b - a < 0.01 or y1 - y0 < 0.01:
		return
	var size := Vector3(b - a, y1 - y0, PlaceBuilder.WALL) if axis == "x" else Vector3(PlaceBuilder.WALL, y1 - y0, b - a)
	var mid := (a + b) / 2
	var center := Vector3(mid, (y0 + y1) / 2, fixed) if axis == "x" else Vector3(fixed, (y0 + y1) / 2, mid)
	_build.box(center, size, color)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look


## Carpet, outer walls with the glass front, the ceiling, the closed floors above and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, CARPET)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, INSIDE.darkened(0.1))
	# The front is glass from waist height, with the entrance in the middle.
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.0, 0.9, OUTSIDE)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.0, 0.9, OUTSIDE)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.9, 2.6, GLASS)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.9, 2.6, GLASS)
	_wall_box("x", HALF_Z, -HALF_X, HALF_X, 2.6, WALL_TOP, OUTSIDE)
	_wall("x", -HALF_Z, -HALF_X, HALF_X, [], OUTSIDE)
	_wall("z", -HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	_wall("z", HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	# The building's other floors, closed, with rows of windows.
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	for floor_i in 3:
		for i in 8:
			var y := WALL_TOP + 1.6 + floor_i * 2.8
			_build.mesh_box(Vector3(-HALF_X + 1.5 + i * 2.7, y, HALF_Z + 0.02), Vector3(1.6, 1.2, 0.04), GLASS.darkened(0.3))
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_INSURANCE"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.position = Vector3(0, WALL_TOP + 0.7, HALF_Z + 0.08)
	$Built.add_child(sign_label)
	_build.mesh_box(Vector3(0, 2.75, HALF_Z + 0.8), Vector3(4.0, 0.08, 1.6), OUTSIDE.darkened(0.3))


## The reception: Coca's desk, the waiting chairs, the water cooler and the "Employee of the month" photos.
func _build_reception() -> void:
	var openings: Array = RECEPTION_OPENINGS.map(func(x: float) -> Vector3: return Vector3(x, OPENING_WIDTH, 2.4))
	_wall("x", RECEPTION_Z, -HALF_X, HALF_X, openings, INSIDE)
	_build.open_box(DESK_AT, DESK_SIZE, "-z", WOOD)
	for i in 6:
		var at := Vector3(3.0 + i * 0.9, FLOOR_TOP, 7.3)
		_build.box(at + Vector3(0, 0.22, 0), Vector3(0.5, 0.44, 0.5), PARTITION)
		_build.mesh_box(at + Vector3(0, 0.7, 0.22), Vector3(0.5, 0.5, 0.06), PARTITION)
	var cooler := _build.body(COOLER_AT + Vector3(0, 0.7, 0))
	_build.shape(cooler, Vector3(0.34, 1.4, 0.34))
	_model(COOLER_MODEL, COOLER_AT, PI)
	# The "Employee of the month" photos, on the reception's side of its wall.
	for i in 4:
		var at := Vector3(6.5 + i * 1.1, 1.7, RECEPTION_Z + 0.09)
		_build.mesh_box(at, Vector3(0.6, 0.8, 0.03), WOOD)
		_build.mesh_box(at + Vector3(0, 0.05, 0.02), Vector3(0.45, 0.55, 0.01), Color(0.95, 0.85, 0.7))
	_build.light(Vector3(-5.0, 2.8, 6.5))
	_build.light(Vector3(5.0, 2.8, 6.5))


## The twelve cubicles: low partitions open to +Z, a desk with a monitor and a pile of papers, and a rolling chair.
func _build_cubicles() -> void:
	var half := CUBICLE_SIZE / 2
	for row in CUBICLE_ROWS.size():
		var z := CUBICLE_ROWS[row]
		for x: float in CUBICLE_COLUMNS:
			var y := FLOOR_TOP + PARTITION_HEIGHT / 2
			_build.box(Vector3(x, y, z - half.y), Vector3(CUBICLE_SIZE.x, PARTITION_HEIGHT, 0.06), PARTITION)
			for side: float in [-1.0, 1.0]:
				_build.box(Vector3(x + side * half.x, y, z), Vector3(0.06, PARTITION_HEIGHT, CUBICLE_SIZE.y), PARTITION)
			var desk := Vector3(x, FLOOR_TOP, z - half.y + 0.35)
			_build.legs(desk, Vector2(CUBICLE_DESK_SIZE.x, CUBICLE_DESK_SIZE.z), CUBICLE_DESK_SIZE.y - 0.03, DESK.darkened(0.3))
			_build.box(desk + Vector3(0, CUBICLE_DESK_SIZE.y - 0.015, 0), Vector3(CUBICLE_DESK_SIZE.x, 0.03, CUBICLE_DESK_SIZE.z), DESK)
			var top := desk + Vector3(0, CUBICLE_DESK_SIZE.y, 0)
			if row != MONITOR_ROW:
				_model(MONITOR_MODEL, top + Vector3(-0.45, 0.15, -0.05))
			var pile := PaperPile.new()
			pile.position = top + Vector3(0.5, 0, 0)
			add_child(pile)
			piles.append(pile)
			var chair: Grabbable = CHAIR_SCENE.instantiate()
			chair.position = Vector3(x, FLOOR_TOP + 0.01, z + 0.25)
			chair.rotation.y = PI
			add_child(chair)
			chairs.append(chair)
	for at: Vector3 in [Vector3(-8.0, 2.8, 2.0), Vector3(-2.4, 2.8, 2.0), Vector3(-8.0, 2.8, -1.8), Vector3(-2.4, 2.8, -1.8)]:
		_build.light(at)
	# The giant printer in the back corner, between the archive and the boss's office (it prints in step 2).
	_build.box(PRINTER_AT + Vector3(0, PRINTER_SIZE.y / 2, 0), PRINTER_SIZE, WHITE.darkened(0.1))
	_build.mesh_box(PRINTER_AT + Vector3(0, PRINTER_SIZE.y - 0.15, PRINTER_SIZE.z / 2 + 0.1), Vector3(0.9, 0.04, 0.3), WHITE)
	_build.mesh_box(PRINTER_AT + Vector3(0.5, PRINTER_SIZE.y + 0.02, 0.2), Vector3(0.3, 0.04, 0.2), DARK)
	_build.light(Vector3(0.0, 2.8, -6.0))


## The meeting room at the east front: its walls, the long table with chairs, the cabinet and the company's paintings.
func _build_meeting_room() -> void:
	_wall("z", EAST_X, MEETING_BACK_Z, RECEPTION_Z, [Vector3(MEETING_DOOR_Z, OPENING_WIDTH, 2.4)], INSIDE)
	_wall("x", MEETING_BACK_Z, EAST_X, HALF_X, [], INSIDE)
	_build.legs(MEETING_TABLE_AT, Vector2(MEETING_TABLE_SIZE.x, MEETING_TABLE_SIZE.z), MEETING_TABLE_SIZE.y - 0.04, WOOD)
	_build.box(MEETING_TABLE_AT + Vector3(0, MEETING_TABLE_SIZE.y - 0.02, 0), Vector3(MEETING_TABLE_SIZE.x, 0.04, MEETING_TABLE_SIZE.z), WOOD.lightened(0.15))
	for i in 4:
		for side: float in [-1.0, 1.0]:
			_build.mesh_box(MEETING_TABLE_AT + Vector3(-1.5 + i, 0.25, side * 1.0), Vector3(0.45, 0.5, 0.45), DARK)
	_build.open_box(MEETING_CABINET_AT, MEETING_CABINET_SIZE, "-x", WOOD)
	_build.mesh_box(Vector3(EAST_X + 0.1, 1.6, 2.0), Vector3(0.03, 1.0, 1.6), WHITE)
	for i in 3:
		var at := Vector3(5.6 + i * 2.0, 1.8, MEETING_BACK_Z + 0.09)
		_build.mesh_box(at, Vector3(0.9, 0.7, 0.04), WOOD.darkened(0.2))
		_build.mesh_box(at + Vector3(0, 0, 0.025), Vector3(0.75, 0.55, 0.01), Color(0.4 + i * 0.2, 0.6, 0.8 - i * 0.2))
	_build.light(Vector3(7.5, 2.8, 3.0))


## The kitchen nook between the meeting room and the boss's office, open to the cubicles: the counter, the huge
## coffee machine, the fridge and the bin.
func _build_kitchen() -> void:
	_build.box(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0), COUNTER_SIZE, WHITE.darkened(0.15))
	var coffee := _build.body(COFFEE_AT + Vector3(0, COFFEE_SIZE.y / 2, 0))
	_build.shape(coffee, Vector3(COFFEE_SIZE.z, COFFEE_SIZE.y, COFFEE_SIZE.x))
	_model(COFFEE_MODEL, COFFEE_AT, -PI / 2)
	_build.open_box(FRIDGE_AT, FRIDGE_SIZE, "-x", WHITE)
	_build.box(FRIDGE_AT + Vector3(0, 0.9, 0), Vector3(0.6, 0.03, 0.6), WHITE.darkened(0.1))
	_build.open_box(BIN_AT, BIN_SIZE, "top", DARK)
	_build.light(Vector3(7.5, 2.8, -0.8))


## The floor boss's office at the back east: the wall with the locked door and a window to the cubicles, the desk,
## the filing cabinet, the small safe and the shelf of glass trophies.
func _build_boss_office() -> void:
	_wall("x", OFFICE_FRONT_Z, EAST_X, HALF_X, [Vector3(OFFICE_DOOR_X, GameScale.DOOR_WIDTH, GameScale.DOOR_HEIGHT)], INSIDE)
	_wall_box("z", EAST_X, -HALF_Z, OFFICE_FRONT_Z, 0.0, 1.0, INSIDE)
	_wall_box("z", EAST_X, -HALF_Z, OFFICE_FRONT_Z, 1.0, 2.2, GLASS)
	_wall_box("z", EAST_X, -HALF_Z, OFFICE_FRONT_Z, 2.2, WALL_TOP, INSIDE)
	_build.legs(BOSS_DESK_AT, Vector2(BOSS_DESK_SIZE.x, BOSS_DESK_SIZE.z), BOSS_DESK_SIZE.y - 0.03, WOOD)
	_build.box(BOSS_DESK_AT + Vector3(0, BOSS_DESK_SIZE.y - 0.015, 0), Vector3(BOSS_DESK_SIZE.x, 0.03, BOSS_DESK_SIZE.z), WOOD.lightened(0.1))
	_build.open_box(FILING_AT, Vector3(0.6, 1.3, 0.6), "-x", STEEL)
	_build.open_box(SAFE_AT, SAFE_SIZE, "+z", DARK)
	_build.box(TROPHY_SHELF_AT, Vector3(0.3, 0.03, 2.4), WOOD)
	_build.light(Vector3(8.0, 2.8, -5.0))


## The archive at the back west: its locked door, tall shelves of folders, a box on the floor and the shredder.
func _build_archive() -> void:
	_wall("x", ARCHIVE_FRONT_Z, -HALF_X, ARCHIVE_X, [Vector3(ARCHIVE_DOOR_X, GameScale.DOOR_WIDTH, GameScale.DOOR_HEIGHT)], INSIDE)
	_wall("z", ARCHIVE_X, -HALF_Z, ARCHIVE_FRONT_Z, [], INSIDE)
	var length := ARCHIVE_X - 0.4 - (-HALF_X + 0.4)
	var middle := (ARCHIVE_X + -HALF_X) / 2
	for y: float in ARCHIVE_BOARDS:
		_build.box(Vector3(middle, FLOOR_TOP + y, ARCHIVE_SHELF_Z), Vector3(length, 0.04, 0.6), STEEL)
		for i in 9:
			var x := -HALF_X + 0.9 + i * 0.6
			# The middle board keeps a gap free for the hiding spot.
			if y == ARCHIVE_BOARDS[1] and absf(x - ARCHIVE_GAP_X) < 0.4:
				continue
			_build.mesh_box(Vector3(x, FLOOR_TOP + y + 0.17, ARCHIVE_SHELF_Z), Vector3(0.45, 0.3, 0.4), CARDBOARD)
	_build.open_box(ARCHIVE_BOX_AT, ARCHIVE_BOX_SIZE, "top", CARDBOARD)
	_build.box(SHREDDER_AT + Vector3(0, 0.4, 0), Vector3(0.5, 0.8, 0.4), DARK)
	_build.light(Vector3(-8.0, 2.8, -6.2))


## The monitors of the middle row of cubicles and the glass trophies on their shelf: each one that breaks is a fine.
func _place_fragile() -> void:
	for x: float in CUBICLE_COLUMNS:
		var monitor: Ornament = MONITOR_SCENE.instantiate()
		var z := CUBICLE_ROWS[MONITOR_ROW] - CUBICLE_SIZE.y / 2 + 0.3
		monitor.position = Vector3(x - 0.45, FLOOR_TOP + CUBICLE_DESK_SIZE.y + 0.155, z)
		add_child(monitor)
		monitor.broken.connect(_on_fragile_broken)
		monitors.append(monitor)
	for i in TROPHIES:
		var trophy: Ornament = TROPHY_SCENE.instantiate()
		trophy.position = TROPHY_SHELF_AT + Vector3(0, 0.015 + TROPHY_HALF_HEIGHT + 0.005, -1.0 + i * 0.4)
		trophy.rotation.y = -PI / 2
		add_child(trophy)
		trophy.broken.connect(_on_fragile_broken)
		trophies.append(trophy)


func _on_fragile_broken(_at: Vector3) -> void:
	broken_goods += 1
	fines += Ornament.FINE
