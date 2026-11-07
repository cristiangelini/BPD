class_name Nursery
extends Node3D

## The plant nursery "La Maceta Feliz" as a place to raid (docs/diseno/allanamiento-vivero.md, step 1): an open lot in
## the city behind a low wall, the front to +Z with the gate open in the middle under the sign and its smiling pot. The
## yard in the west half has rows of potted plants and four sprinklers (still off); in the east half stands the
## greenhouse, a glass house with its tables, the tap and the Dentuda in her huge pot in the middle. By the front, the
## counter with the till, the seed basket and the shelf of glazed ceramic pots on the west side, and the row of garden
## gnomes and the tool hut on the east. At the back, the shed (the soil bags, the compost and the wheelbarrow), the
## water tank, the trucks' gate and the owner's office, locked with the till's key. Something thrown hard at a
## greenhouse pane or at a ceramic pot breaks it, a fine each. Every number here is (propuesta).

signal pane_broken(index: int)
signal pot_broken(index: int)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const SPRINKLER_MODEL := preload("res://assets/models/nursery_sprinkler.glb")
const DENTUDA_POT_MODEL := preload("res://assets/models/dentuda_pot.glb")
const DENTUDA_MODEL := preload("res://assets/models/dentuda.glb")
const PLANT_MODELS: Array[PackedScene] = [preload("res://assets/models/potted_plant_0.glb"),
	preload("res://assets/models/potted_plant_1.glb"), preload("res://assets/models/potted_plant_2.glb")]
const CERAMIC_MODEL := preload("res://assets/models/ceramic_pot.glb")
const SOIL_BAG_MODEL := preload("res://assets/models/soil_bag.glb")
const WATER_TANK_MODEL := preload("res://assets/models/water_tank.glb")
const TAP_MODEL := preload("res://assets/models/nursery_tap.glb")
const SMILING_POT_MODEL := preload("res://assets/models/smiling_pot.glb")
const WHEELBARROW_MODEL := preload("res://assets/models/wheelbarrow.glb")
const GNOME_MODELS: Array[PackedScene] = [preload("res://assets/models/garden_gnome_0.glb"),
	preload("res://assets/models/garden_gnome_1.glb"), preload("res://assets/models/garden_gnome_2.glb")]
const HALF_X := 20.0
const HALF_Z := 11.0
const FLOOR_TOP := 0.06
## The low wall around the lot, and the gate in the front from -GATE_HALF to GATE_HALF under the sign.
const WALL_LOW := 1.2
const GATE_HALF := 2.5
const SIGN_TOP := 3.4
## The rooms with a roof (the shed and the office) have walls this tall.
const ROOM_TOP := 3.0
## The yard's four sprinklers, and the rows of potted plants between them.
const SPRINKLERS: Array[Vector3] = [Vector3(-15, FLOOR_TOP, -1), Vector3(-6, FLOOR_TOP, -1), Vector3(-15, FLOOR_TOP, 5),
	Vector3(-6, FLOOR_TOP, 5)]
const PLANT_ROWS: Array[float] = [1.3, 2.7]
## The greenhouse: a glass house from GREEN_X0 to GREEN_X1 and ±GREEN_HALF_Z, GREEN_TOP tall, its door in the west
## wall from -GREEN_DOOR to GREEN_DOOR. Its panes, 2 m or so each, break when something hits them fast.
const GREEN_X0 := 2.0
const GREEN_X1 := 14.0
const GREEN_HALF_Z := 4.0
const GREEN_TOP := 3.2
const GREEN_DOOR := 1.0
const PANE_SPEED := 3.0
const PANE_FINE := 30
## The tables inside, along X on both sides of the Dentuda, and the tap at the east end.
const TABLE_XS: Array[Vector2] = [Vector2(3.0, 6.5), Vector2(9.5, 13.0)]
const TABLE_Z := 2.6
const TABLE_DEPTH := 0.9
const TABLE_TOP := 0.8
const TAP_AT := Vector3(13.6, FLOOR_TOP, 0.0)
## The Dentuda's pot in the middle of the greenhouse: its radius and the height of its rim.
const DENTUDA_AT := Vector3(8.0, FLOOR_TOP, 0.0)
const DENTUDA_POT_RADIUS := 1.1
const DENTUDA_POT_TOP := 0.84
## By the front: the counter with the till, the seed basket, the shelf of ceramic pots (each one a fine), the row of
## gnomes and the tool hut.
const COUNTER_AT := Vector3(-15.0, FLOOR_TOP, 8.5)
const COUNTER_SIZE := Vector3(2.0, 1.0, 0.7)
const BASKET_AT := Vector3(-12.5, FLOOR_TOP, 8.5)
const BASKET_SIZE := Vector3(0.7, 0.5, 0.5)
const SHELF_AT := Vector3(-8.0, FLOOR_TOP, 9.9)
const SHELF_SIZE := Vector3(3.2, 1.4, 0.45)
const SHELF_BOARD := 0.7
const CERAMIC_POTS := 8
const POT_FINE := 10
const GNOMES := 8
const GNOME_X0 := 4.0
const GNOME_STEP := 1.25
const GNOME_Z := 9.6
const HUT_AT := Vector3(17.5, FLOOR_TOP, 8.0)
const HUT_SIZE := Vector3(2.0, 2.2, 2.0)
## At the back: the shed (west), the water tank, the trucks' gate and the office (east, locked).
const SHED_EAST := -9.0
const SHED_FRONT := -4.0
## The shed's front is open wide, from SHED_DOOR_X - SHED_DOOR_HALF to SHED_DOOR_X + SHED_DOOR_HALF.
const SHED_DOOR_X := -14.5
const SHED_DOOR_HALF := 2.0
const SHED_LINTEL := 2.4
const SOIL_PILE_AT := Vector3(-17.0, FLOOR_TOP, -9.0)
const SOIL_PILE_SIZE := Vector3(1.6, 0.6, 1.2)
const COMPOST_AT := Vector3(-12.0, FLOOR_TOP, -9.5)
const COMPOST_SIZE := Vector3(1.6, 0.8, 1.2)
const WHEELBARROW_AT := Vector3(-11.0, FLOOR_TOP, -6.0)
const TANK_AT := Vector3(-5.0, FLOOR_TOP, -9.5)
const TRUCK_GATE: Vector2 = Vector2(4.0, 10.0)
const OFFICE_WEST := 14.0
const OFFICE_FRONT := -5.0
const OFFICE_DOOR_X := 17.0

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_dentuda_pot", "at": Vector3(8.0, DENTUDA_POT_TOP, 0.65), "heavy": true},
	{"id": "under_greenhouse_table", "at": Vector3(4.75, FLOOR_TOP, 2.6), "heavy": true},
	{"id": "among_soil_bags", "at": Vector3(-15.4, FLOOR_TOP, -9.0), "heavy": true},
	{"id": "in_compost", "at": Vector3(-12.0, FLOOR_TOP + 0.05, -9.5), "heavy": true},
	{"id": "in_shed_wheelbarrow", "at": Vector3(-11.0, FLOOR_TOP + 0.5, -6.0), "heavy": true},
	{"id": "in_nursery_office", "at": Vector3(18.5, FLOOR_TOP, -9.0), "heavy": true},
	{"id": "in_nursery_counter", "at": Vector3(-15.0, FLOOR_TOP + 0.05, 8.5), "heavy": false},
	{"id": "behind_pot_shelf", "at": Vector3(-8.0, FLOOR_TOP, 10.5), "heavy": false},
	{"id": "in_seed_basket", "at": Vector3(-12.5, FLOOR_TOP + 0.05, 8.5), "heavy": false},
	{"id": "among_gnomes", "at": Vector3(8.4, FLOOR_TOP, 9.6), "heavy": false},
	{"id": "in_tool_hut", "at": Vector3(17.6, FLOOR_TOP + 0.05, 8.0), "heavy": false},
	{"id": "under_water_tank", "at": Vector3(-5.0, FLOOR_TOP, -9.5), "heavy": false},
]

const EARTH := Color(0.55, 0.45, 0.32)
const GRASS := Color(0.42, 0.62, 0.3)
const BRICK := Color(0.78, 0.52, 0.38)
const WALL_IN := Color(0.93, 0.9, 0.8)
const WOOD := Color(0.55, 0.36, 0.22)
const FRAME := Color(0.92, 0.94, 0.95)
const STEEL := Color(0.5, 0.52, 0.56)
const COMPOST := Color(0.25, 0.18, 0.1)
const SIGN_GREEN := Color(0.3, 0.6, 0.3)
const GLASS := Color(0.75, 0.92, 0.85, 0.3)
const CRACKED := Color(0.45, 0.5, 0.5, 0.75)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
## The greenhouse's panes (each a body with its glass), the broken ones by index, and the ceramic pots.
var panes: Array[StaticBody3D] = []
var cracked: Array[int] = []
var pots: Array[Node3D] = []
var broken_pots: Array[int] = []
var broken_goods := 0
## Money taken off the case pay: the panes and the pots.
var fines := 0
## Same seed, same nursery (the stories and the hiding spots come from it, step 6).
@export var case_seed := 0
var _build: PlaceBuilder


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_lot()
	_build_yard()
	_build_greenhouse()
	_build_front()
	_build_back()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("nursery")
	station_parking = city.transform * CityLayout.parking("station")
	_park_car()
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "nursery", $PatrolCar)


func _park_car() -> void:
	var car: PatrolCar = $PatrolCar
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))


## Whether `at` lies inside the greenhouse.
static func in_greenhouse(at: Vector3) -> bool:
	return at.x > GREEN_X0 and at.x < GREEN_X1 and absf(at.z) < GREEN_HALF_Z


## The ground (earth, with grass in the yard), the low wall with the open gate, the tall walls of the shed and the
## office at the back, and the sign over the gate with its smiling pot.
func _build_lot() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, EARTH)
	_build.mesh_box(Vector3(-10.5, FLOOR_TOP + 0.005, 2.0), Vector3(17.0, 0.01, 10.0), GRASS)
	_build.wall_at("x", HALF_Z, -HALF_X, -GATE_HALF, 0.0, WALL_LOW, [], BRICK)
	_build.wall_at("x", HALF_Z, GATE_HALF, HALF_X, 0.0, WALL_LOW, [], BRICK)
	_build.wall_at("x", -HALF_Z, -HALF_X, SHED_EAST, 0.0, ROOM_TOP, [], BRICK)
	_build.wall_at("x", -HALF_Z, SHED_EAST, TRUCK_GATE.x, 0.0, WALL_LOW, [], BRICK)
	_build.wall_at("x", -HALF_Z, TRUCK_GATE.y, OFFICE_WEST, 0.0, WALL_LOW, [], BRICK)
	_build.wall_at("x", -HALF_Z, OFFICE_WEST, HALF_X, 0.0, ROOM_TOP, [], BRICK)
	_build.wall_at("z", -HALF_X, -HALF_Z, SHED_FRONT, 0.0, ROOM_TOP, [], BRICK)
	_build.wall_at("z", -HALF_X, SHED_FRONT, HALF_Z, 0.0, WALL_LOW, [], BRICK)
	_build.wall_at("z", HALF_X, -HALF_Z, OFFICE_FRONT, 0.0, ROOM_TOP, [], BRICK)
	_build.wall_at("z", HALF_X, OFFICE_FRONT, HALF_Z, 0.0, WALL_LOW, [], BRICK)
	for x: float in [-GATE_HALF - 0.2, GATE_HALF + 0.2]:
		_build.box(Vector3(x, SIGN_TOP / 2, HALF_Z), Vector3(0.25, SIGN_TOP, 0.25), WOOD)
	_build.mesh_box(Vector3(0, SIGN_TOP - 0.45, HALF_Z), Vector3(GATE_HALF * 2 + 0.6, 0.8, 0.1), SIGN_GREEN)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_NURSERY"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, SIGN_TOP - 0.45, HALF_Z + 0.07)
	$Built.add_child(sign_label)
	_model(SMILING_POT_MODEL, Vector3(0, SIGN_TOP, HALF_Z))


## The yard: the four sprinklers (still off, step 2) and two rows of potted plants across it.
func _build_yard() -> void:
	for at in SPRINKLERS:
		_model(SPRINKLER_MODEL, at)
	for z in PLANT_ROWS:
		for i in 12:
			var at := Vector3(-18.0 + i * 1.4, FLOOR_TOP, z)
			_model(PLANT_MODELS[(i + roundi(z)) % PLANT_MODELS.size()], at, i * 0.7)


## The greenhouse: a white frame with its glass panes (the door in the west wall), the glass roof, the tables with
## their plants, the tap and the Dentuda in her pot in the middle. She doesn't bite yet (step 3).
func _build_greenhouse() -> void:
	var walls := [
		["x", -GREEN_HALF_Z, GREEN_X0, GREEN_X1],
		["x", GREEN_HALF_Z, GREEN_X0, GREEN_X1],
		["z", GREEN_X1, -GREEN_HALF_Z, GREEN_HALF_Z],
		["z", GREEN_X0, -GREEN_HALF_Z, -GREEN_DOOR],
		["z", GREEN_X0, GREEN_DOOR, GREEN_HALF_Z],
	]
	for wall: Array in walls:
		var from: float = wall[2]
		var to: float = wall[3]
		var count := maxi(1, roundi((to - from) / 2.0))
		var width := (to - from) / count
		for i in count:
			_pane(wall[0], wall[1], from + width * i, from + width * (i + 1))
	for x: float in [GREEN_X0, GREEN_X1]:
		for z: float in [-GREEN_HALF_Z, GREEN_HALF_Z]:
			_build.box(Vector3(x, GREEN_TOP / 2, z), Vector3(0.12, GREEN_TOP, 0.12), FRAME)
	for z: float in [-GREEN_DOOR, GREEN_DOOR]:
		_build.box(Vector3(GREEN_X0, GREEN_TOP / 2, z), Vector3(0.12, GREEN_TOP, 0.12), FRAME)
	_build.box(Vector3(GREEN_X0, (GameScale.DOOR_HEIGHT + GREEN_TOP) / 2 + 0.1, 0),
		Vector3(0.12, GREEN_TOP - GameScale.DOOR_HEIGHT - 0.2, GREEN_DOOR * 2), FRAME)
	var length := GREEN_X1 - GREEN_X0
	var mid_x := (GREEN_X0 + GREEN_X1) / 2
	_build.box(Vector3(mid_x, GREEN_TOP + 0.03, 0), Vector3(length, 0.06, GREEN_HALF_Z * 2), GLASS)
	_build.mesh_box(Vector3(mid_x, GREEN_TOP + 0.1, 0), Vector3(length, 0.1, 0.12), FRAME)
	for side: float in [-1.0, 1.0]:
		for span in TABLE_XS:
			var center := Vector3((span.x + span.y) / 2, FLOOR_TOP, side * TABLE_Z)
			var footprint := Vector2(span.y - span.x, TABLE_DEPTH)
			_build.legs(center, footprint, TABLE_TOP, WOOD)
			_build.box(center + Vector3(0, TABLE_TOP + 0.03, 0), Vector3(footprint.x, 0.06, footprint.y), WOOD)
			for i in 4:
				var at := center + Vector3(-footprint.x / 2 + 0.45 + i * (footprint.x - 0.9) / 3, TABLE_TOP + 0.06, 0)
				_model(PLANT_MODELS[i % PLANT_MODELS.size()], at, i * 1.3)
	_model(TAP_MODEL, TAP_AT, -PI / 2)
	_build.shape(_build.body(TAP_AT + Vector3(0, 0.45, 0)), Vector3(0.15, 0.9, 0.15))
	_model(DENTUDA_POT_MODEL, DENTUDA_AT)
	_cylinder(DENTUDA_AT + Vector3(0, DENTUDA_POT_TOP / 2, 0), DENTUDA_POT_RADIUS, DENTUDA_POT_TOP)
	_model(DENTUDA_MODEL, DENTUDA_AT + Vector3(0, 0.8, 0), -PI / 2)
	_cylinder(DENTUDA_AT + Vector3(0, 0.8 + 0.8, 0), 0.2, 1.6)
	var lamp := _build.light(Vector3(mid_x, GREEN_TOP - 0.4, 0))
	lamp.light_color = Color(0.9, 1.0, 0.85)


## One glass pane of the greenhouse, along `axis` at `fixed`, from `a` to `b`: a body with its glass and a frame post
## between it and the next, and an area around it that breaks it when something hits it fast.
func _pane(axis: String, fixed: float, a: float, b: float) -> void:
	var mid := (a + b) / 2
	var center := Vector3(mid, GREEN_TOP / 2, fixed) if axis == "x" else Vector3(fixed, GREEN_TOP / 2, mid)
	var size := Vector3(b - a, GREEN_TOP, 0.06) if axis == "x" else Vector3(0.06, GREEN_TOP, b - a)
	var body := _build.body(center)
	body.name = "Pane%d" % panes.size()
	_build.shape(body, size)
	var glass := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	glass.mesh = box
	glass.material_override = _glass(GLASS)
	body.add_child(glass)
	var post := Vector3(b, GREEN_TOP / 2, fixed) if axis == "x" else Vector3(fixed, GREEN_TOP / 2, b)
	_build.mesh_box(post, Vector3(0.08, GREEN_TOP, 0.08), FRAME)
	var index := panes.size()
	panes.append(body)
	var area := _area(center, size + (Vector3(0, 0, 0.8) if axis == "x" else Vector3(0.8, 0, 0)))
	area.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > PANE_SPEED:
			break_pane(index))


## By the front: the counter with the till (open at the back, something fits inside), the seed basket, the shelf of
## ceramic pots, the gnomes and the tool hut.
func _build_front() -> void:
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", WOOD)
	till = Till.new()
	till.position = COUNTER_AT + Vector3(0.4, COUNTER_SIZE.y + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_NURSERY"
	add_child(till)
	_build.open_box(BASKET_AT, BASKET_SIZE, "top", WOOD.lightened(0.35))
	for i in 3:
		_build.mesh_box(BASKET_AT + Vector3(-0.2 + i * 0.2, BASKET_SIZE.y - 0.1, 0), Vector3(0.12, 0.02, 0.18),
			[Color(0.9, 0.3, 0.3), Color(0.95, 0.85, 0.3), Color(0.4, 0.7, 0.95)][i])
	_build.open_box(SHELF_AT, SHELF_SIZE, "-z", WOOD)
	_build.box(SHELF_AT + Vector3(0, SHELF_BOARD, 0), Vector3(SHELF_SIZE.x - 0.1, 0.05, SHELF_SIZE.z - 0.1), WOOD)
	for i in CERAMIC_POTS:
		var per_row := CERAMIC_POTS / 2.0
		var row := floorf(i / per_row)
		var at := SHELF_AT + Vector3(-1.2 + (i - row * per_row) * 0.8, SHELF_BOARD + 0.03 + row * (SHELF_SIZE.y
			- SHELF_BOARD), 0)
		var pot := _model(CERAMIC_MODEL, at)
		pots.append(pot)
		var area := _area(at + Vector3(0, 0.2, -0.1), Vector3(0.45, 0.45, 0.6))
		area.body_entered.connect(func(hit: Node3D) -> void:
			if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > PANE_SPEED:
				break_pot(i))
	for i in GNOMES:
		var at := Vector3(GNOME_X0 + i * GNOME_STEP, FLOOR_TOP, GNOME_Z)
		_model(GNOME_MODELS[i % GNOME_MODELS.size()], at)
		_build.shape(_build.body(at + Vector3(0, 0.3, 0)), Vector3(0.4, 0.6, 0.4))
	_build.open_box(HUT_AT, HUT_SIZE, "-x", WOOD.darkened(0.15))
	_build.mesh_box(HUT_AT + Vector3(0, HUT_SIZE.y + 0.15, 0), Vector3(HUT_SIZE.x + 0.3, 0.3, HUT_SIZE.z + 0.3),
		Color(0.7, 0.25, 0.2))
	for i in 3:
		_build.mesh_box(HUT_AT + Vector3(0.85, 0.8, -0.6 + i * 0.6), Vector3(0.04, 1.5, 0.04), WOOD.lightened(0.3))


## At the back: the shed with the soil bags, the compost and the wheelbarrow; the water tank; the trucks' gate,
## closed; and the office, locked, with its desk.
func _build_back() -> void:
	_build.wall_at("x", SHED_FRONT, -HALF_X, SHED_DOOR_X - SHED_DOOR_HALF, 0.0, ROOM_TOP, [], WALL_IN)
	_build.wall_at("x", SHED_FRONT, SHED_DOOR_X + SHED_DOOR_HALF, SHED_EAST, 0.0, ROOM_TOP, [], WALL_IN)
	_build.box(Vector3(SHED_DOOR_X, (SHED_LINTEL + ROOM_TOP) / 2, SHED_FRONT),
		Vector3(SHED_DOOR_HALF * 2, ROOM_TOP - SHED_LINTEL, PlaceBuilder.WALL), WALL_IN)
	_build.wall_at("z", SHED_EAST, -HALF_Z, SHED_FRONT, 0.0, ROOM_TOP, [], WALL_IN)
	_build.box(Vector3((-HALF_X + SHED_EAST) / 2, ROOM_TOP + 0.1, (-HALF_Z + SHED_FRONT) / 2),
		Vector3(SHED_EAST + HALF_X, 0.2, SHED_FRONT + HALF_Z), WOOD.darkened(0.3))
	for i in 8:
		var across := fmod(floorf(i / 2.0), 2.0) * 0.6 - 0.3
		var at := SOIL_PILE_AT + Vector3((i % 2) * 0.7 - 0.35, floorf(i / 4.0) * 0.15, across)
		_model(SOIL_BAG_MODEL, at, (i % 3) * 0.2)
	_build.shape(_build.body(SOIL_PILE_AT + Vector3(0, SOIL_PILE_SIZE.y / 2, 0)), SOIL_PILE_SIZE)
	_build.open_box(COMPOST_AT, COMPOST_SIZE, "top", WOOD)
	_build.mesh_box(COMPOST_AT + Vector3(0, 0.3, 0), COMPOST_SIZE - Vector3(0.12, 0.6, 0.12), COMPOST)
	_model(WHEELBARROW_MODEL, WHEELBARROW_AT)
	_build.open_box(WHEELBARROW_AT + Vector3(0, 0.42, 0), Vector3(0.66, 0.32, 0.86), "top", Color(0.25, 0.56, 0.29))
	_build.box(WHEELBARROW_AT + Vector3(0, 0.2, 0), Vector3(0.3, 0.4, 0.3), STEEL)
	_build.light(Vector3(-14.5, ROOM_TOP - 0.4, -7.5))
	_model(WATER_TANK_MODEL, TANK_AT)
	for sx: float in [-0.55, 0.55]:
		for sz: float in [-0.55, 0.55]:
			_build.shape(_build.body(TANK_AT + Vector3(sx, 0.6, sz)), Vector3(0.08, 1.2, 0.08))
	_cylinder(TANK_AT + Vector3(0, 1.88, 0), 0.65, 1.3)
	var gate_mid := (TRUCK_GATE.x + TRUCK_GATE.y) / 2
	for x: float in [TRUCK_GATE.x, TRUCK_GATE.y]:
		_build.box(Vector3(x, 1.2, -HALF_Z), Vector3(0.25, 2.4, 0.25), STEEL)
	_build.box(Vector3(gate_mid, 1.05, -HALF_Z), Vector3(TRUCK_GATE.y - TRUCK_GATE.x - 0.25, 1.9, 0.08), STEEL)
	for i in 9:
		_build.mesh_box(Vector3(TRUCK_GATE.x + 0.6 + i * 0.6, 1.05, -HALF_Z + 0.06), Vector3(0.05, 1.8, 0.02),
			STEEL.darkened(0.3))
	_build.wall_at("x", OFFICE_FRONT, OFFICE_WEST, HALF_X, 0.0, ROOM_TOP, [OFFICE_DOOR_X], WALL_IN)
	_build.wall_at("z", OFFICE_WEST, -HALF_Z, OFFICE_FRONT, 0.0, ROOM_TOP, [], WALL_IN)
	_build.box(Vector3((OFFICE_WEST + HALF_X) / 2, ROOM_TOP + 0.1, (-HALF_Z + OFFICE_FRONT) / 2),
		Vector3(HALF_X - OFFICE_WEST, 0.2, OFFICE_FRONT + HALF_Z), WOOD.darkened(0.3))
	_build.legs(Vector3(16.5, FLOOR_TOP, -10.0), Vector2(2.0, 1.0), 0.75, WOOD)
	_build.box(Vector3(16.5, FLOOR_TOP + 0.78, -10.0), Vector3(2.0, 0.06, 1.0), WOOD)
	_build.light(Vector3(17.0, ROOM_TOP - 0.4, -8.0))
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_FRONT)
	add_child(office_door)


## Breaks greenhouse pane `index`, once: a fine, the glass goes grey and cracked and you can walk through the hole.
func break_pane(index: int) -> void:
	if cracked.has(index):
		return
	cracked.append(index)
	broken_goods += 1
	fines += PANE_FINE
	var pane := panes[index]
	(pane.get_child(0) as CollisionShape3D).set_deferred("disabled", true)
	(pane.get_child(1) as MeshInstance3D).material_override = _glass(CRACKED)
	(pane.get_child(1) as MeshInstance3D).scale = Vector3(1, 0.25, 1)
	(pane.get_child(1) as MeshInstance3D).position.y = -GREEN_TOP * 0.375
	_say(pane.position + Vector3(0, 2.0, 0), "NURSERY_GLASS_BROKEN")
	pane_broken.emit(index)


## Breaks ceramic pot `index`, once: a fine, and it's gone.
func break_pot(index: int) -> void:
	if broken_pots.has(index):
		return
	broken_pots.append(index)
	broken_goods += 1
	fines += POT_FINE
	pots[index].visible = false
	_say(pots[index].position + Vector3(0, 1.2, -0.6), "NURSERY_POT_BROKEN")
	pot_broken.emit(index)


func _glass(color: Color) -> StandardMaterial3D:
	var glass := StandardMaterial3D.new()
	glass.albedo_color = color
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return glass


## A standing cylinder body for the collisions, `height` tall, centered at `center`.
func _cylinder(center: Vector3, radius: float, height: float) -> void:
	var body := _build.body(center)
	var collision := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = height
	collision.shape = cylinder
	body.add_child(collision)


func _area(center: Vector3, size: Vector3) -> Area3D:
	var area := Area3D.new()
	area.position = center
	area.collision_layer = 0
	area.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	return area


## A floating line over `at` for a few seconds.
func _say(at: Vector3, key: String) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(3.0).timeout.connect(label.queue_free)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
