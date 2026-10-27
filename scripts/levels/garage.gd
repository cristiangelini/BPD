class_name Garage
extends Node3D

## The garage "El Pistón Feliz" as a place to raid (docs/diseno/allanamiento-taller.md, step 1): a shed on its lot in
## the city, with the front to +Z and the big shutter rolled up because it's opening hours. Three clients' cars (one
## up on the lift, one over the pit), the tool wall over the workbench, a stack of tires, the oil drums, the counter
## with its bell and the till, a shelf of parts and the office at the back, locked with the till's key. A windshield
## that something hits fast cracks, a fine each. Every number here is (propuesta).

signal windshield_broken(index: int)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const LIFT_MODEL := preload("res://assets/models/garage_lift.glb")
const DRUM_MODEL := preload("res://assets/models/oil_drum.glb")
const BELL_MODEL := preload("res://assets/models/service_bell.glb")
const BOARD_MODEL := preload("res://assets/models/tool_board.glb")
const TIRE_MODEL := preload("res://assets/models/garage_tire.glb")
const WHEEL_MODEL := preload("res://assets/models/car_wheel.glb")
const HALF_X := 13.0
const HALF_Z := 11.0
## The shed's ceiling, and the closed roof over it up to the lot's height.
const WALL_TOP := 5.0
const BUILDING_TOP := 8.0
const FLOOR_TOP := 0.06
## The shutter's opening in the front wall.
const SHUTTER_WIDTH := 6.0
const SHUTTER_HEIGHT := 4.0

## The clients' cars: where each stands (its middle on the ground, facing +Z) and its look. The one on the lift is up.
const CARS := [
	{"at": Vector3(-6.5, FLOOR_TOP, 0.5), "look": 0},
	{"at": Vector3(0.0, FLOOR_TOP, 0.0), "look": 1, "lifted": true},
	{"at": Vector3(7.0, FLOOR_TOP, 0.0), "look": 2},
]
## The car's body up to the hood, and the cabin on top of it from CABIN_FROM_Z to its windshield at CABIN_TO_Z (the
## traffic sedan's shape).
const CAR_SIZE := Vector3(2.1, 0.75, 4.6)
const CAR_CLEARANCE := 0.2
const CABIN_SIZE := Vector3(1.94, 0.6, 2.1)
const CABIN_FROM_Z := -1.2
const CABIN_TO_Z := 0.9
## How high the lift holds its car.
const LIFT_HEIGHT := 1.65
const LIFT_POST_X := 1.6
const LIFT_POST_SIZE := Vector3(0.22, 3.4, 0.28)
## The windshield: the box just in front of the cabin, in the car's space, that a fast prop cracks.
const WINDSHIELD_AT := Vector3(0, 1.25, 1.1)
const WINDSHIELD_SIZE := Vector3(1.9, 0.5, 0.4)
const WINDSHIELD_SPEED := 3.0
const WINDSHIELD_FINE := 30
## The pit under the third car: 1 m wide and 1.2 m deep, with steps down at its back end.
const PIT_X := 7.0
const PIT_WIDTH := 1.0
const PIT_FROM_Z := -3.6
const PIT_TO_Z := 2.0
const PIT_DEPTH := 1.2
const PIT_STEPS := 7
const PIT_STEP_DEPTH := 0.22
## The counter at the front left, with its bell and the till; the mechanic's side is -Z.
const COUNTER_AT := Vector3(-9.0, FLOOR_TOP, 8.0)
const COUNTER_SIZE := Vector3(3.0, 1.0, 0.8)
const BELL_AT := Vector3(-8.2, FLOOR_TOP + 1.0, 8.0)
const TILL_ON := Vector3(-9.8, FLOOR_TOP + 1.0, 8.0)
## The workbench on the west wall, under the tool board.
const BENCH_AT := Vector3(-12.3, FLOOR_TOP, 0.0)
const BENCH_SIZE := Vector3(1.0, 0.9, 3.2)
## Two stacks of four tires in the back west corner.
const TIRE_STACKS: Array[Vector3] = [Vector3(-11.6, FLOOR_TOP, -8.0), Vector3(-10.6, FLOOR_TOP, -8.0)]
const TIRES_PER_STACK := 4
const TIRE_THICK := 0.24
const TIRE_SIZE := Vector3(0.8, TIRE_THICK * TIRES_PER_STACK, 0.8)
## The oil drums along the back wall, a gap in the middle; the one at OPEN_DRUM has no lid.
const DRUMS: Array[float] = [-7.0, -6.3, -4.1, -3.4]
const DRUM_Z := -10.4
const DRUM_SIZE := Vector3(0.6, 0.9, 0.6)
const OPEN_DRUM := 2
## The parts shelf on the east wall.
const SHELF_AT := Vector3(12.6, FLOOR_TOP, 5.0)
const SHELF_BOARDS: Array[float] = [0.6, 1.3]
## The office in the back east corner, and its locked door.
const OFFICE_X := 5.0
const OFFICE_Z := -5.0
const OFFICE_DOOR_X := 7.0
const DESK_AT := Vector3(10.0, FLOOR_TOP, -8.5)
const DESK_SIZE := Vector3(1.8, 0.8, 0.9)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_pit", "at": Vector3(PIT_X, FLOOR_TOP - PIT_DEPTH, -1.6), "heavy": true},
	{"id": "under_lift", "at": Vector3(0.0, FLOOR_TOP, -1.2), "heavy": true},
	{"id": "behind_garage_counter", "at": Vector3(-9.0, FLOOR_TOP, 7.0), "heavy": true},
	{"id": "between_oil_drums", "at": Vector3(-5.2, FLOOR_TOP, DRUM_Z), "heavy": true},
	{"id": "behind_tires", "at": Vector3(-11.1, FLOOR_TOP, -9.6), "heavy": true},
	{"id": "in_garage_office_corner", "at": Vector3(12.0, FLOOR_TOP, -10.0), "heavy": true},
	{"id": "in_oil_drum", "at": Vector3(-4.1, FLOOR_TOP + 0.05, DRUM_Z), "heavy": false},
	{"id": "on_tire_stack", "at": Vector3(-10.6, FLOOR_TOP + TIRE_THICK * TIRES_PER_STACK, -8.0), "heavy": false},
	{"id": "on_workbench", "at": Vector3(-12.3, FLOOR_TOP + 0.9, -0.9), "heavy": false},
	{"id": "in_garage_counter", "at": Vector3(-9.0, FLOOR_TOP + 0.05, 8.0), "heavy": false},
	{"id": "on_parts_shelf", "at": Vector3(12.6, FLOOR_TOP + 1.32, 4.2), "heavy": false},
	{"id": "on_garage_desk", "at": Vector3(10.5, FLOOR_TOP + 0.8, -8.5), "heavy": false},
]

const OUTSIDE := Color(0.72, 0.74, 0.7)
const CONCRETE := Color(0.66, 0.6, 0.52)
const GREASE := Color(0.3, 0.3, 0.32)
const BLUE := Color(0.25, 0.42, 0.75)
const RED := Color(0.85, 0.25, 0.2)
const WOOD := Color(0.6, 0.44, 0.3)
const STEEL := Color(0.62, 0.65, 0.68)
const DARK := Color(0.1, 0.1, 0.12)
const YELLOW := Color(0.95, 0.78, 0.2)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
## The clients' cars, in the order of CARS.
var cars: Array[StaticBody3D] = []
var broken_windshields: Array[int] = []
var broken_goods := 0
## Money taken off the case pay: the windshields.
var fines := 0
## Same seed, same garage (the stories and the hiding spots come from it, step 4).
@export var case_seed := 0
var _build: PlaceBuilder
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_pit()
	_build_front()
	_build_walls_inside()
	_build_office()
	_place_cars()
	office_door = _door(OFFICE_DOOR_X)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("garage")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "garage", car)


## The concrete floor around the pit, the walls with the shutter's opening, the roof and the sign.
func _build_shell() -> void:
	var pit_x0 := PIT_X - PIT_WIDTH / 2
	var pit_x1 := PIT_X + PIT_WIDTH / 2
	_build.slab(-HALF_X, pit_x0, -HALF_Z, HALF_Z, FLOOR_TOP, CONCRETE)
	_build.slab(pit_x1, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, CONCRETE)
	_build.slab(pit_x0, pit_x1, -HALF_Z, PIT_FROM_Z, FLOOR_TOP, CONCRETE)
	_build.slab(pit_x0, pit_x1, PIT_TO_Z, HALF_Z, FLOOR_TOP, CONCRETE)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, OUTSIDE.darkened(0.1))
	var half := SHUTTER_WIDTH / 2
	_build.wall_at("x", HALF_Z, -HALF_X, -half, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, half, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, -half, half, SHUTTER_HEIGHT, WALL_TOP - SHUTTER_HEIGHT, [], OUTSIDE)
	# The shutter, rolled up in its box over the opening.
	_build.mesh_box(Vector3(0, SHUTTER_HEIGHT + 0.25, HALF_Z - 0.3), Vector3(SHUTTER_WIDTH, 0.5, 0.5), STEEL.darkened(0.2))
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_GARAGE"
	sign_label.font_size = 110
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.position = Vector3(0, WALL_TOP + 0.9, HALF_Z + 0.08)
	$Built.add_child(sign_label)
	# Yellow and black stripes painted around the opening, and oil stains on the floor.
	for i in 6:
		_build.mesh_box(Vector3(-half - 0.15, 0.4 + i * 0.6, HALF_Z + 0.08), Vector3(0.3, 0.3, 0.02), YELLOW if i % 2 == 0 else DARK)
		_build.mesh_box(Vector3(half + 0.15, 0.4 + i * 0.6, HALF_Z + 0.08), Vector3(0.3, 0.3, 0.02), YELLOW if i % 2 == 0 else DARK)
	for at: Vector3 in [Vector3(-6.0, 0, 4.0), Vector3(2.0, 0, 3.5), Vector3(-2.0, 0, -6.0), Vector3(9.5, 0, 5.0)]:
		_build.mesh_box(at + Vector3(0, FLOOR_TOP + 0.005, 0), Vector3(1.2, 0.01, 0.8), GREASE)
	for at: Vector3 in [Vector3(-7.0, 4.6, 4.0), Vector3(0.0, 4.6, 4.0), Vector3(7.0, 4.6, 4.0), Vector3(-7.0, 4.6, -5.0),
			Vector3(0.0, 4.6, -5.0), Vector3(9.0, 3.4, -8.0)]:
		_build.light(at)


## The pit: its walls, its floor and the steps down at the back end.
func _build_pit() -> void:
	var bottom := FLOOR_TOP - PIT_DEPTH
	_build.slab(PIT_X - PIT_WIDTH / 2, PIT_X + PIT_WIDTH / 2, PIT_FROM_Z, PIT_TO_Z, bottom, GREASE)
	var length := PIT_TO_Z - PIT_FROM_Z
	var mid_z := (PIT_FROM_Z + PIT_TO_Z) / 2
	# The walls stop under the floor's slab, so the two don't flicker on top.
	var wall := PIT_DEPTH - PlaceBuilder.SLAB
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(PIT_X + side * (PIT_WIDTH / 2 + 0.1), bottom + wall / 2, mid_z),
			Vector3(0.2, wall, length), CONCRETE.darkened(0.25))
	for z: float in [PIT_FROM_Z - 0.1, PIT_TO_Z + 0.1]:
		_build.box(Vector3(PIT_X, bottom + wall / 2, z), Vector3(PIT_WIDTH + 0.4, wall, 0.2), CONCRETE.darkened(0.25))
	var rise := PIT_DEPTH / PIT_STEPS
	for i in PIT_STEPS:
		var height := PIT_DEPTH - i * rise
		_build.box(Vector3(PIT_X, bottom + height / 2, PIT_FROM_Z + (i + 0.5) * PIT_STEP_DEPTH),
			Vector3(PIT_WIDTH, height, PIT_STEP_DEPTH), YELLOW.darkened(0.3))
	_build.light(Vector3(PIT_X, bottom + 0.9, PIT_TO_Z - 0.4))


## The counter with its bell and the till, by the shutter.
func _build_front() -> void:
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", BLUE)
	_model(BELL_MODEL, BELL_AT)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_GARAGE"
	add_child(till)


## The workbench and the tool board, the tire stacks, the oil drums and the parts shelf.
func _build_walls_inside() -> void:
	_build.legs(BENCH_AT, Vector2(BENCH_SIZE.x, BENCH_SIZE.z), BENCH_SIZE.y - 0.06, DARK)
	_build.box(BENCH_AT + Vector3(0, BENCH_SIZE.y - 0.03, 0), Vector3(BENCH_SIZE.x, 0.06, BENCH_SIZE.z), WOOD)
	_model(BOARD_MODEL, Vector3(-HALF_X + 0.08, 1.15, 0.0), PI / 2)
	for at: Vector3 in TIRE_STACKS:
		_solid(at + Vector3(0, TIRE_SIZE.y / 2, 0), TIRE_SIZE * Vector3(0.9, 1, 0.9))
		for i in TIRES_PER_STACK:
			_model(TIRE_MODEL, at + Vector3(0, TIRE_THICK * i, 0), i * 0.4)
	for i in DRUMS.size():
		var at := Vector3(DRUMS[i], FLOOR_TOP, DRUM_Z)
		if i == OPEN_DRUM:
			_build.open_box(at, DRUM_SIZE, "top", BLUE.darkened(0.2))
		else:
			_solid(at + Vector3(0, DRUM_SIZE.y / 2, 0), DRUM_SIZE * Vector3(0.95, 1, 0.95))
			_model(DRUM_MODEL, at, i * 0.7)
	_build.legs(SHELF_AT, Vector2(0.6, 2.4), SHELF_BOARDS[-1], DARK)
	for y: float in SHELF_BOARDS:
		_build.box(SHELF_AT + Vector3(0, y, 0), Vector3(0.6, 0.04, 2.4), STEEL)
		for i in 3:
			if y == SHELF_BOARDS[-1] and i == 0:
				continue
			_build.mesh_box(SHELF_AT + Vector3(0, y + 0.15, -0.8 + i * 0.8), Vector3(0.45, 0.26, 0.5),
				Color.from_hsv(0.08 + i * 0.3, 0.6, 0.85))


## The office in the back east corner: its walls with the door, a desk with papers and a calendar of cars.
func _build_office() -> void:
	_build.wall_at("x", OFFICE_Z, OFFICE_X, HALF_X, 0.0, WALL_TOP, [OFFICE_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("z", OFFICE_X, -HALF_Z, OFFICE_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.04, DARK)
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.02, 0), Vector3(DESK_SIZE.x, 0.04, DESK_SIZE.z), WOOD)
	_build.mesh_box(DESK_AT + Vector3(-0.4, DESK_SIZE.y + 0.03, 0), Vector3(0.5, 0.05, 0.35), Color(0.95, 0.94, 0.88))
	_build.mesh_box(Vector3(10.0, 2.0, -HALF_Z + 0.1), Vector3(0.8, 1.0, 0.02), RED)


## A locked door in the office's front wall, its middle at x.
func _door(x: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(x - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_Z)
	add_child(door)
	return door


## The clients' cars: a body each with the traffic's look, the lift under the second one, and a windshield that
## cracks when something flies into it fast.
func _place_cars() -> void:
	for i in CARS.size():
		var spec: Dictionary = CARS[i]
		var body := StaticBody3D.new()
		body.name = "ClientCar%d" % i
		body.position = spec.at + Vector3(0, LIFT_HEIGHT if spec.get("lifted", false) else 0.0, 0)
		var top := CAR_CLEARANCE + CAR_SIZE.y
		_car_shape(body, CAR_SIZE, Vector3(0, CAR_CLEARANCE + CAR_SIZE.y / 2, 0))
		_car_shape(body, CABIN_SIZE, Vector3(0, top + CABIN_SIZE.y / 2, (CABIN_FROM_Z + CABIN_TO_Z) / 2))
		body.add_child(TrafficCar.MODELS[spec.look].instantiate())
		for at in SuspectCar.SEDAN_WHEELS:
			var wheel: Node3D = WHEEL_MODEL.instantiate()
			wheel.position = at
			body.add_child(wheel)
		add_child(body)
		cars.append(body)
		var area := _area(body.position + WINDSHIELD_AT, WINDSHIELD_SIZE)
		area.body_entered.connect(func(hit: Node3D) -> void:
			if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > WINDSHIELD_SPEED:
				break_windshield(i))
		if spec.get("lifted", false):
			_build_lift(spec.at)


func _car_shape(body: StaticBody3D, size: Vector3, at: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	body.add_child(shape)


## The lift's two posts on either side of its car, solid, under the model.
func _build_lift(at: Vector3) -> void:
	_model(LIFT_MODEL, at)
	for side: float in [-1.0, 1.0]:
		_solid(at + Vector3(side * LIFT_POST_X, LIFT_POST_SIZE.y / 2, 0), LIFT_POST_SIZE)


## Cracks the windshield of car `index`, once: a fine and the cracks over the glass.
func break_windshield(index: int) -> void:
	if broken_windshields.has(index):
		return
	broken_windshields.append(index)
	broken_goods += 1
	fines += WINDSHIELD_FINE
	var cracks := Node3D.new()
	cracks.name = "Cracks%d" % index
	cars[index].add_child(cracks)
	var material := StandardMaterial3D.new()
	material.albedo_color = DARK
	for i in 7:
		var turn := i * TAU / 7.0 + 0.3
		var crack := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.5 + (i % 3) * 0.2, 0.02, 0.02)
		mesh.material = material
		crack.mesh = mesh
		crack.position = Vector3(cos(turn) * 0.25, 1.25 + sin(turn) * 0.12, CABIN_TO_Z + 0.02)
		crack.rotation.z = turn
		cracks.add_child(crack)
	_say(cars[index].position + Vector3(0, 2.4, 0), "GARAGE_WINDSHIELD_BROKEN")
	windshield_broken.emit(index)


## A box only to bump into, under a model that gives the look.
func _solid(center: Vector3, size: Vector3) -> void:
	_build.shape(_build.body(center), size)


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
