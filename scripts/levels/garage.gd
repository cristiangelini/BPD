class_name Garage
extends Node3D

## The garage "El Pistón Feliz" as a place to raid (docs/diseno/allanamiento-taller.md, step 1): a shed on its lot in
## the city, with the front to +Z and the big shutter rolled up because it's opening hours. Three clients' cars (one
## up on the lift, one over the pit), the tool wall over the workbench, a stack of tires, the oil drums, the counter
## with its bell and the till, a shelf of parts and the office at the back, locked with the till's key. A windshield
## that something hits fast cracks, a fine each. Don Tuerca walks among the cars filling the complaint; the bell calls
## him to the counter, his back to the garage, and the lift's button brings its car down (or up), squashing softly
## whoever is under it (step 2). Every number here is (propuesta).

signal windshield_broken(index: int)
## The lift's car came down on a cop.
signal squashed(cop: Cop)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const LIFT_MODEL := preload("res://assets/models/garage_lift.glb")
const ARMS_MODEL := preload("res://assets/models/garage_lift_arms.glb")
const TUERCA_SCENE := preload("res://scenes/npc/don_tuerca.tscn")
const DRUM_MODEL := preload("res://assets/models/oil_drum.glb")
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
## The arms under the car's sills, in the car's space, and the button on the left post's control box.
const LIFT_ARMS_Y := 0.15
const LIFT_BUTTON_AT := Vector3(-1.6, 1.2, 0.3)
## How fast the lift's car goes down or up, and how long it waits on whatever it lands on.
const LIFT_SPEED := 0.3
const SQUASH_PAUSE := 1.0
const SQUASH_FINE := 20
const SQUASH_SECONDS := 3.0
const SQUASH_PUSH := 4.0
## How tall a cop under the car counts as.
const COP_HEIGHT := 1.7
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

## Don Tuerca's round among the cars, back and forth: in front of them, down the east side of the lift, behind them and
## to the tires. At the counter he stands on the mechanic's side, his back to the garage.
const TUERCA_ROUTE: Array[Vector3] = [
	Vector3(-3.5, FLOOR_TOP, 4.0), Vector3(3.5, FLOOR_TOP, 4.0), Vector3(3.8, FLOOR_TOP, -3.8),
	Vector3(-3.0, FLOOR_TOP, -3.8), Vector3(-9.5, FLOOR_TOP, -4.5),
]
const COUNTER_SPOT := Vector3(-7.9, FLOOR_TOP, 6.8)
## Seeing a windshield crack, and ringing the bell once he knows the trick.
const SAW_WINDSHIELD := 10.0
const NOTICED := 10.0

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
var bell: GarageBell
var tuerca: FloorBoss
var complaint_bar: ProgressBar
## The lift's button, and how high its car is now and is going to.
var lift_button: PushButton
var lift_height := LIFT_HEIGHT
var lift_target := LIFT_HEIGHT
## The clients' cars, in the order of CARS.
var cars: Array[StaticBody3D] = []
var broken_windshields: Array[int] = []
var broken_goods := 0
## Money taken off the case pay: the windshields.
var fines := 0
## Same seed, same garage (the stories and the hiding spots come from it, step 4).
@export var case_seed := 0
var _build: PlaceBuilder
var _under_lift: Area3D
var _squash_wait := 0.0
## Whether this trip down already cost its fine.
var _trip_fined := false
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
	_place_tuerca()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("garage")
	_cut_pit(city as City)
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


## The city's ground is a box with its top at the street: the pit's hole is cut out of it (with its walls), or the
## grass would fill it up to the street.
func _cut_pit(city: City) -> void:
	var to_city := city.transform.affine_inverse()
	var hole := Rect2()
	for i in 4:
		var x := PIT_X + (PIT_WIDTH / 2 + 0.2) * (1 if i % 2 else -1)
		var z := (PIT_TO_Z + 0.2) if i >= 2 else (PIT_FROM_Z - 0.2)
		var at := to_city * Vector3(x, 0, z)
		hole = Rect2(Vector2(at.x, at.z), Vector2.ZERO) if i == 0 else hole.expand(Vector2(at.x, at.z))
	city.cut_ground(hole)


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
	bell = GarageBell.new()
	bell.position = BELL_AT
	add_child(bell)
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
		var lifted: bool = spec.get("lifted", false)
		var body: StaticBody3D = AnimatableBody3D.new() if lifted else StaticBody3D.new()
		body.name = "ClientCar%d" % i
		body.position = spec.at + Vector3(0, LIFT_HEIGHT if lifted else 0.0, 0)
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
		if lifted:
			_build_lift(body)


func _car_shape(body: StaticBody3D, size: Vector3, at: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	body.add_child(shape)


## The lift under `lift_car`: its two posts, solid, the arms riding with the car, the button and the space under it.
func _build_lift(lift_car: StaticBody3D) -> void:
	var at: Vector3 = CARS[1].at
	_model(LIFT_MODEL, at)
	for side: float in [-1.0, 1.0]:
		_solid(at + Vector3(side * LIFT_POST_X, LIFT_POST_SIZE.y / 2, 0), LIFT_POST_SIZE)
	var arms: Node3D = ARMS_MODEL.instantiate()
	arms.position.y = LIFT_ARMS_Y
	lift_car.add_child(arms)
	lift_button = PushButton.new()
	lift_button.prompt = "PROMPT_LIFT"
	lift_button.position = at + LIFT_BUTTON_AT
	add_child(lift_button)
	lift_button.pressed.connect(func(_cop: Cop) -> void: toggle_lift())
	_under_lift = _area(at + Vector3(0, LIFT_HEIGHT / 2, 0), Vector3(CAR_SIZE.x, LIFT_HEIGHT, CAR_SIZE.z))
	_under_lift.collision_mask = 6


## The lift's button: its car heads down if it's up (or on its way up), and up otherwise.
func toggle_lift() -> void:
	lift_target = 0.0 if lift_target > 0.0 else LIFT_HEIGHT
	_trip_fined = false


## The lift's car moves toward its target; on the way down it lands softly on whatever is under it.
func _move_lift(delta: float) -> void:
	if is_equal_approx(lift_height, lift_target):
		return
	if _squash_wait > 0.0:
		_squash_wait -= delta
		return
	if lift_target < lift_height and _squash_under():
		_squash_wait = SQUASH_PAUSE
		return
	lift_height = move_toward(lift_height, lift_target, LIFT_SPEED * delta)
	cars[1].position.y = CARS[1].at.y + lift_height


## Whatever is under the lift's car and as tall as its bottom: a cop is squashed (a fine once a trip and a while on
## the floor) and shoved out, a prop just shoved out. Whether there was anything.
func _squash_under() -> bool:
	var bottom := CARS[1].at.y + lift_height + CAR_CLEARANCE
	var any := false
	for body in _under_lift.get_overlapping_bodies():
		var local := to_local((body as Node3D).global_position)
		var out := Vector3(signf(local.x - CARS[1].at.x) if absf(local.x - CARS[1].at.x) > 0.05 else 1.0, 0, 0)
		if body is Cop and local.y + COP_HEIGHT > bottom:
			var cop := body as Cop
			cop.knock_back(global_basis * out * SQUASH_PUSH, SQUASH_SECONDS)
			if not _trip_fined:
				_trip_fined = true
				broken_goods += 1
				fines += SQUASH_FINE
				_say(to_local(cop.global_position) + Vector3.UP * 1.2, "GARAGE_SQUASHED")
				squashed.emit(cop)
			any = true
		elif body is RigidBody3D and local.y + 0.4 > bottom:
			(body as RigidBody3D).linear_velocity = global_basis * out * SQUASH_PUSH
			any = true
	return any


func _physics_process(delta: float) -> void:
	if cars.size() > 1:
		_move_lift(delta)


## Don Tuerca on his round, the bell's visits to the counter, what he notices and the complaint bar.
func _place_tuerca() -> void:
	tuerca = TUERCA_SCENE.instantiate()
	tuerca.route = TUERCA_ROUTE
	tuerca.printer_spot = COUNTER_SPOT
	tuerca.printer = bell
	add_child(tuerca)
	tuerca.fix_facing = to_global(COUNTER_SPOT + Vector3(0, 0, 10))
	tuerca.start_at(0)
	office_door.broken.connect(tuerca.door_broken)
	till.opened.connect(func(at: Vector3) -> void: tuerca.saw(at, FloorBoss.SAW_TILL))
	windshield_broken.connect(func(index: int) -> void:
		tuerca.saw(to_global(cars[index].position + WINDSHIELD_AT), SAW_WINDSHIELD, "TUERCA_WINDSHIELD"))
	bell.noticed.connect(func() -> void: tuerca.scold(NOTICED, "TUERCA_NOTICED"))
	var hud := CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	hud.add_child(box)
	var title := Label.new()
	title.text = "HUD_COMPLAINT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	complaint_bar = ProgressBar.new()
	complaint_bar.custom_minimum_size = Vector2(320, 18)
	complaint_bar.show_percentage = false
	complaint_bar.modulate = Color(1, 0.45, 0.35)
	box.add_child(complaint_bar)
	add_child(hud)
	tuerca.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


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
