class_name CakeLab
extends Node3D

## The cake lab "Dulce Ciencia" (docs/diseno/laboratorio.md, step 1): one floor on its lot in the city, with the front
## to +Z and the rest of the building closed above it. The tasting room at the front, the big kitchen in the middle,
## the flour storeroom and the locker room in the west, the flavor lab behind glass at the back and the cold room in
## the back east corner. The tasting room is open; the flavor lab and the cold room are locked. The showcase cakes
## break (a fine each) and the flour sacks burst into white footprints. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const CAKE_SCENE := preload("res://scenes/props/bakery_cake.tscn")
const SACK_SCENE := preload("res://scenes/props/lab_flour_sack.tscn")
const CAKE_MODEL := preload("res://assets/models/bakery_cake.glb")
const OVEN_MODEL := preload("res://assets/models/lab_oven.glb")
const MIXER_MODEL := preload("res://assets/models/giant_mixer.glb")
const MICROSCOPE_MODEL := preload("res://assets/models/microscope.glb")
const TUBES_MODEL := preload("res://assets/models/test_tubes.glb")
const HALF_X := 12.0
const HALF_Z := 11.0
## The lab's ceiling, and the closed floors of the building over it up to the lot's height.
const WALL_TOP := 3.5
const BUILDING_TOP := 8.0
const FLOOR_TOP := 0.06
const ENTRANCE_WIDTH := 2.4
const OPENING_WIDTH := 1.8
## The wall between the tasting room and the kitchen, with its two openings.
const TASTING_Z := 6.0
const TASTING_OPENINGS: Array[float] = [-6.0, 6.0]
## The west band: the flour storeroom in front of the locker room.
const WEST_X := -7.0
const STOREROOM_DOOR_Z := 1.0
const BACK_Z := -4.0
const LOCKER_DOOR_X := -9.5
## The flavor lab behind glass at the back, and its locked door.
const LAB_EAST_X := 3.0
const LAB_DOOR_X := -2.0
## The cold room in the back east corner, and its locked door.
const COLD_X := 6.0
const COLD_DOOR_X := 9.0

const SHOWCASE_AT := Vector3(0.0, FLOOR_TOP, 7.4)
const SHOWCASE_SIZE := Vector3(4.0, 0.9, 0.8)
const CAKES := 8
const CAKE_HALF_HEIGHT := 0.09
const TILL_AT := Vector3(-8.5, FLOOR_TOP, 7.5)
const TILL_SIZE := Vector3(2.0, 1.0, 0.7)
const TRAY_AT := Vector3(4.0, FLOOR_TOP, 7.5)
const TRAY_SIZE := Vector3(1.6, 0.9, 0.6)
const TABLES: Array[Vector3] = [
	Vector3(-6.5, FLOOR_TOP, 9.4), Vector3(-3.5, FLOOR_TOP, 9.4), Vector3(3.5, FLOOR_TOP, 9.4), Vector3(6.5, FLOOR_TOP, 9.4),
]
const TABLE_SIZE := Vector3(0.9, 0.75, 0.9)
## The three long steel counters across the kitchen.
const COUNTER_X := -1.0
const COUNTER_ROWS: Array[float] = [3.5, 0.5, -2.2]
const COUNTER_SIZE := Vector3(6.0, 0.9, 0.9)
const MIXERS: Array[Vector3] = [Vector3(7.0, FLOOR_TOP, 3.2), Vector3(7.0, FLOOR_TOP, 0.2)]
## The wall of ovens on the east side, facing the kitchen; the one at HIDING_OVEN is hollow.
const OVEN_X := 11.4
const OVENS: Array[float] = [4.2, 2.6, 1.0, -0.6, -2.2]
const OVEN_SIZE := Vector3(0.9, 1.6, 1.2)
const HIDING_OVEN := 3
## The flour sacks: two rows along the storeroom's west wall, with a gap in the middle.
const SACK_ROWS: Array[float] = [-11.35, -10.75]
const SACK_ALONG: Array[float] = [5.0, 4.0, 3.0, 1.0, 0.0]
const SACK_SIZE := Vector3(0.58, 0.36, 0.88)
const SACK_GAP_Z := 2.0
const LOCKERS := 5
const LOCKER_SIZE := Vector3(0.5, 1.9, 0.6)
const OPEN_LOCKER := 2
const LAB_TABLE_AT := Vector3(-2.0, FLOOR_TOP, -7.5)
const LAB_TABLE_SIZE := Vector3(3.0, 0.9, 1.0)
const RECIPE_CABINET_AT := Vector3(-6.4, FLOOR_TOP, -9.5)
const RECIPE_CABINET_SIZE := Vector3(0.8, 1.6, 1.0)
const COLD_SHELF_X := 11.6
const COLD_BOARDS: Array[float] = [0.5, 1.0, 1.5]
const BIN_AT := Vector3(4.5, FLOOR_TOP, -9.6)
const BIN_SIZE := Vector3(0.5, 0.6, 0.5)

const OUTSIDE := Color(0.9, 0.86, 0.72)
const GLASS := Color(0.6, 0.8, 0.9, 0.35)
const TILE := Color(0.86, 0.87, 0.83)
const FLOOR := Color(0.74, 0.6, 0.5)
const PINK := Color(0.96, 0.7, 0.78)
const MINT := Color(0.62, 0.85, 0.75)
const STEEL := Color(0.72, 0.75, 0.78)
const WOOD := Color(0.6, 0.44, 0.3)
const DARK := Color(0.22, 0.22, 0.25)
const ICE := Color(0.78, 0.9, 0.98)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_oven", "at": Vector3(OVEN_X, FLOOR_TOP + 0.05, OVENS[HIDING_OVEN]), "heavy": true},
	{"id": "under_steel_counter", "at": Vector3(COUNTER_X - 1.5, FLOOR_TOP, COUNTER_ROWS[1]), "heavy": true},
	{"id": "between_flour_sacks", "at": Vector3(-11.05, FLOOR_TOP, SACK_GAP_Z), "heavy": true},
	{"id": "in_cold_room", "at": Vector3(8.0, FLOOR_TOP, -9.0), "heavy": true},
	{"id": "under_tasting_table", "at": TABLES[1], "heavy": true},
	{"id": "behind_showcase", "at": Vector3(1.0, FLOOR_TOP, 6.6), "heavy": true},
	{"id": "in_locker", "at": Vector3(-11.6, FLOOR_TOP + 0.05, -9.8 + OPEN_LOCKER * 0.7), "heavy": false},
	{"id": "in_recipe_cabinet", "at": RECIPE_CABINET_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "on_cold_shelf", "at": Vector3(COLD_SHELF_X - 0.05, FLOOR_TOP + COLD_BOARDS[1] + 0.02, -6.0), "heavy": false},
	{"id": "in_mixer_bowl", "at": MIXERS[0] + Vector3(0, 0.35, 0.05), "heavy": false},
	{"id": "in_kitchen_bin", "at": BIN_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "on_lab_table", "at": LAB_TABLE_AT + Vector3(0.8, LAB_TABLE_SIZE.y, 0), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var lab_door: FrontDoor
var cold_door: FrontDoor
var city_map: CityMap
var cakes: Array[Ornament] = []
var sacks: Array[FlourSack] = []
var flour: FlourPrints
var broken_goods := 0
var burst_sacks := 0
## Money taken off the case pay for broken things (each one is an Ornament.FINE).
var fines := 0
var _build: PlaceBuilder
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	_build = PlaceBuilder.new($Built)
	flour = FlourPrints.new()
	add_child(flour)
	_build_shell()
	_build_tasting_room()
	_build_kitchen()
	_build_storeroom()
	_build_locker_room()
	_build_flavor_lab()
	_build_cold_room()
	_place_cakes()
	_place_sacks()
	lab_door = _door(Vector3(LAB_DOOR_X, FLOOR_TOP, BACK_Z))
	cold_door = _door(Vector3(COLD_DOOR_X, FLOOR_TOP, BACK_Z))
	var city: Node3D = $City
	city.transform = CityLayout.anchor("cake_lab")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "cake_lab", car)


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


## A table: four legs and a top, `size` high.
func _table(at: Vector3, size: Vector3, color: Color, top_color: Color) -> void:
	_build.legs(at, Vector2(size.x, size.z), size.y - 0.04, color)
	_build.box(at + Vector3(0, size.y - 0.02, 0), Vector3(size.x, 0.04, size.z), top_color)


## Tiles, outer walls with the shop window, the ceiling, the closed floors above and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, TILE.darkened(0.08))
	# The front is a shop window from waist height, with the entrance in the middle.
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.0, 0.9, PINK)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.0, 0.9, PINK)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.9, 2.7, GLASS)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.9, 2.7, GLASS)
	_wall_box("x", HALF_Z, -HALF_X, HALF_X, 2.7, WALL_TOP, OUTSIDE)
	_wall("x", -HALF_Z, -HALF_X, HALF_X, [], OUTSIDE)
	_wall("z", -HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	_wall("z", HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	for i in 8:
		_build.mesh_box(Vector3(-HALF_X + 1.6 + i * 2.97, WALL_TOP + 2.4, HALF_Z + 0.02), Vector3(1.6, 1.2, 0.04), GLASS.darkened(0.3))
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_CAKE_LAB"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.position = Vector3(0, WALL_TOP + 0.6, HALF_Z + 0.08)
	$Built.add_child(sign_label)
	# A striped awning over the shop window.
	for i in 12:
		var color := PINK if i % 2 == 0 else TILE
		_build.mesh_box(Vector3(-HALF_X + 1.0 + i * 2.0, 2.9, HALF_Z + 0.7), Vector3(2.0, 0.06, 1.4), color)


## The tasting room: the showcase, the till with the cold room's key (step 2), Pocha's tray and four little tables.
func _build_tasting_room() -> void:
	var openings: Array = TASTING_OPENINGS.map(func(x: float) -> Vector3: return Vector3(x, OPENING_WIDTH, 2.4))
	_wall("x", TASTING_Z, -HALF_X, HALF_X, openings, TILE)
	_build.box(SHOWCASE_AT + Vector3(0, SHOWCASE_SIZE.y / 2, 0), SHOWCASE_SIZE, PINK)
	# The glass hood over the cakes, only for the look, so the cakes can be taken out.
	var hood := SHOWCASE_AT + Vector3(0, SHOWCASE_SIZE.y + 0.3, 0)
	_build.mesh_box(hood + Vector3(0, 0, SHOWCASE_SIZE.z / 2), Vector3(SHOWCASE_SIZE.x, 0.6, 0.02), GLASS)
	_build.mesh_box(hood + Vector3(0, 0.3, 0), Vector3(SHOWCASE_SIZE.x, 0.02, SHOWCASE_SIZE.z), GLASS)
	_build.open_box(TILL_AT, TILL_SIZE, "-z", WOOD)
	_build.mesh_box(TILL_AT + Vector3(0.5, TILL_SIZE.y + 0.12, 0), Vector3(0.4, 0.24, 0.3), DARK)
	_build.box(TRAY_AT + Vector3(0, TRAY_SIZE.y / 2, 0), TRAY_SIZE, MINT)
	_build.mesh_box(TRAY_AT + Vector3(0, TRAY_SIZE.y + 0.01, 0), Vector3(0.7, 0.02, 0.4), STEEL)
	for at: Vector3 in TABLES:
		_table(at, TABLE_SIZE, WOOD.darkened(0.2), TILE)
		for side: float in [-1.0, 1.0]:
			_build.mesh_box(at + Vector3(side * 0.7, 0.23, 0), Vector3(0.4, 0.46, 0.4), PINK.darkened(0.15))
	_build.light(Vector3(-6.0, 3.1, 8.5))
	_build.light(Vector3(6.0, 3.1, 8.5))


## The big kitchen: three long steel counters, the two giant mixers, the wall of ovens and the giant piping bag.
func _build_kitchen() -> void:
	for z: float in COUNTER_ROWS:
		_table(Vector3(COUNTER_X, FLOOR_TOP, z), COUNTER_SIZE, STEEL.darkened(0.2), STEEL)
		_build.mesh_box(Vector3(COUNTER_X, FLOOR_TOP + 0.25, z), Vector3(COUNTER_SIZE.x - 0.2, 0.03, COUNTER_SIZE.z - 0.2), STEEL.darkened(0.1))
	for at: Vector3 in MIXERS:
		_build.box(at + Vector3(0, 0.1, 0), Vector3(0.9, 0.2, 0.9), MINT)
		_build.box(at + Vector3(0, 0.8, -0.35), Vector3(0.3, 1.2, 0.3), MINT)
		var bowl := at + Vector3(0, 0.3, 0.05)
		_build.open_box(bowl, Vector3(0.5, 0.5, 0.5), "top", STEEL)
		_model(MIXER_MODEL, at)
	for i in OVENS.size():
		var at := Vector3(OVEN_X, FLOOR_TOP, OVENS[i])
		if i == HIDING_OVEN:
			_build.open_box(at, OVEN_SIZE, "-x", STEEL)
		else:
			_build.box(at + Vector3(0, OVEN_SIZE.y / 2, 0), OVEN_SIZE, STEEL)
		_model(OVEN_MODEL, at, -PI / 2)
	# The giant piping bag, 1 m long, hanging over the middle counter.
	var bag := CylinderMesh.new()
	bag.top_radius = 0.18
	bag.bottom_radius = 0.02
	bag.height = 1.0
	_build.mesh(bag, Vector3(COUNTER_X, 2.6, COUNTER_ROWS[1]), Color(0.97, 0.97, 0.95))
	for at: Vector3 in [Vector3(-3.5, 3.1, 2.0), Vector3(2.0, 3.1, 2.0), Vector3(-3.5, 3.1, -2.0), Vector3(2.0, 3.1, -2.0), Vector3(9.0, 3.1, 1.0)]:
		_build.light(at)


## The flour storeroom in the west, open to the kitchen: shelves of eggs and colourings over the sacks.
func _build_storeroom() -> void:
	_wall("z", WEST_X, BACK_Z, TASTING_Z, [Vector3(STOREROOM_DOOR_Z, OPENING_WIDTH, 2.4)], TILE)
	for y: float in [1.2, 1.8]:
		_build.box(Vector3(-9.5, FLOOR_TOP + y, TASTING_Z - 0.3), Vector3(4.0, 0.04, 0.5), WOOD)
		for i in 6:
			var at := Vector3(-11.0 + i * 0.6, FLOOR_TOP + y + 0.1, TASTING_Z - 0.3)
			var color := Color(0.9, 0.82, 0.6) if y < 1.5 else Color.from_hsv(i / 6.0, 0.6, 0.9)
			_build.mesh_box(at, Vector3(0.4, 0.16, 0.3), color)
	_build.light(Vector3(-9.5, 3.1, 1.0))


## The locker room behind the storeroom: five lockers (one ajar), a bench, the chef's hats and aprons.
func _build_locker_room() -> void:
	_wall("x", BACK_Z, -HALF_X, WEST_X, [Vector3(LOCKER_DOOR_X, OPENING_WIDTH, 2.4)], TILE)
	_wall("z", WEST_X, -HALF_Z, BACK_Z, [], TILE)
	for i in LOCKERS:
		var at := Vector3(-11.6, FLOOR_TOP, -9.8 + i * 0.7)
		if i == OPEN_LOCKER:
			_build.open_box(at, LOCKER_SIZE, "+x", MINT.darkened(0.2))
		else:
			_build.box(at + Vector3(0, LOCKER_SIZE.y / 2, 0), LOCKER_SIZE, MINT.darkened(0.2))
	_build.box(Vector3(-9.6, FLOOR_TOP + 0.22, -7.5), Vector3(0.4, 0.44, 2.4), WOOD)
	for i in 4:
		var at := Vector3(-7.2, 1.6, -9.5 + i * 0.8)
		_build.mesh_box(at, Vector3(0.04, 0.8, 0.5), TILE)
		_build.mesh(_hat_mesh(), at + Vector3(-0.12, 0.65, 0), TILE)
	_build.light(Vector3(-9.5, 3.1, -7.5))


func _hat_mesh() -> CylinderMesh:
	var hat := CylinderMesh.new()
	hat.top_radius = 0.14
	hat.bottom_radius = 0.1
	hat.height = 0.3
	return hat


## The flavor lab behind glass: the lab table with the microscope and the test tubes, the formula board and the
## recipe cabinet.
func _build_flavor_lab() -> void:
	var door_x := LAB_DOOR_X
	var half := GameScale.DOOR_WIDTH / 2
	for piece: Array in [[WEST_X, door_x - half], [door_x + half, LAB_EAST_X]]:
		_wall_box("x", BACK_Z, piece[0], piece[1], 0.0, 1.0, TILE)
		_wall_box("x", BACK_Z, piece[0], piece[1], 1.0, 2.4, GLASS)
		_wall_box("x", BACK_Z, piece[0], piece[1], 2.4, WALL_TOP, TILE)
	_wall_box("x", BACK_Z, door_x - half, door_x + half, GameScale.DOOR_HEIGHT, WALL_TOP, TILE)
	_wall("z", LAB_EAST_X, -HALF_Z, BACK_Z, [], TILE)
	_table(LAB_TABLE_AT, LAB_TABLE_SIZE, DARK, TILE)
	var top := LAB_TABLE_AT + Vector3(0, LAB_TABLE_SIZE.y, 0)
	_model(MICROSCOPE_MODEL, top + Vector3(-0.9, 0, 0))
	_model(TUBES_MODEL, top + Vector3(-0.2, 0, -0.2))
	_model(TUBES_MODEL, top + Vector3(-0.2, 0, 0.2))
	_build.open_box(RECIPE_CABINET_AT, RECIPE_CABINET_SIZE, "+x", WOOD)
	# The formula board on the back wall.
	_build.mesh_box(Vector3(-2.0, 1.8, -HALF_Z + 0.1), Vector3(3.0, 1.4, 0.03), DARK.lightened(0.1))
	for i in 5:
		_build.mesh_box(Vector3(-3.1 + i * 0.5, 1.9 - (i % 2) * 0.3, -HALF_Z + 0.12), Vector3(0.35, 0.05, 0.01), TILE)
	_build.light(Vector3(-2.0, 3.1, -7.5))


## The cold room in the back east corner: shelves of finished cakes and a cold blue light.
func _build_cold_room() -> void:
	_wall("x", BACK_Z, COLD_X, HALF_X, [Vector3(COLD_DOOR_X, GameScale.DOOR_WIDTH, GameScale.DOOR_HEIGHT)], ICE)
	_wall("z", COLD_X, -HALF_Z, BACK_Z, [], ICE)
	for y: float in COLD_BOARDS:
		_build.box(Vector3(COLD_SHELF_X, FLOOR_TOP + y, -7.5), Vector3(0.6, 0.04, 6.4), STEEL)
		for i in 6:
			var z := -10.2 + i * 1.0
			# The middle board keeps a place free for the hiding spot.
			if y == COLD_BOARDS[1] and absf(z + 6.0) < 0.6:
				continue
			_model(CAKE_MODEL, Vector3(COLD_SHELF_X, FLOOR_TOP + y + 0.02, z))
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(9.0, 3.0, -7.5)
	lamp.light_color = ICE
	lamp.light_energy = 0.8
	lamp.omni_range = 7.0
	$Built.add_child(lamp)
	# The back nook between the lab and the cold room: the sink and the bin.
	_build.box(Vector3(4.5, FLOOR_TOP + 0.45, -10.6), Vector3(2.0, 0.9, 0.6), STEEL)
	_build.open_box(BIN_AT, BIN_SIZE, "top", DARK)
	_build.light(Vector3(4.5, 3.1, -7.5))


## The cakes in the showcase, two rows of four: each one that breaks is a fine.
func _place_cakes() -> void:
	for i in CAKES:
		var cake: Ornament = CAKE_SCENE.instantiate()
		var x := SHOWCASE_AT.x - 1.35 + (i % 4) * 0.9
		var z := SHOWCASE_AT.z + (0.18 if i < 4 else -0.18)
		cake.position = Vector3(x, SHOWCASE_AT.y + SHOWCASE_SIZE.y + CAKE_HALF_HEIGHT + 0.005, z)
		add_child(cake)
		cake.broken.connect(_on_cake_broken)
		cakes.append(cake)


## The ten flour sacks in the storeroom, two rows with a gap in the middle.
func _place_sacks() -> void:
	for x: float in SACK_ROWS:
		for z: float in SACK_ALONG:
			var sack: FlourSack = SACK_SCENE.instantiate()
			sack.position = Vector3(x, FLOOR_TOP + SACK_SIZE.y / 2 + 0.005, z)
			add_child(sack)
			sack.burst.connect(_on_sack_burst)
			sacks.append(sack)


func _on_cake_broken(_at: Vector3) -> void:
	broken_goods += 1
	fines += Ornament.FINE


func _on_sack_burst(at: Vector3) -> void:
	burst_sacks += 1
	flour.spill(at)
