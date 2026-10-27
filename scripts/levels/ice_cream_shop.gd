class_name IceCreamShop
extends Node3D

## The "Heladería Pingüino Derretido" as a place to raid (docs/diseno/allanamiento-heladeria.md, step 1): a one-floor
## neighborhood ice cream shop on its lot in the city, the front to +Z, with the fiberglass penguin on the sidewalk by
## the door. The salon has the counter with the 12 flavors, the till, two freezers and the tables; behind it, the
## kitchen with the soft-serve machine, two more freezers and the cold room (locked with the till's key), the owner's
## office and the bathroom. The kitchen's back door opens to the fenced yard with the ice cream truck. Something thrown
## hard at the counter's glass case cracks it (a fine), and at the penguin knocks it over. Every number here is
## (propuesta).

signal case_cracked
signal penguin_knocked

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const FREEZER_MODEL := preload("res://assets/models/ice_freezer.glb")
const LID_MODEL := preload("res://assets/models/freezer_lid.glb")
const COUNTER_MODEL := preload("res://assets/models/ice_counter.glb")
const MACHINE_MODEL := preload("res://assets/models/soft_serve_machine.glb")
const SHELF_MODEL := preload("res://assets/models/cold_shelf.glb")
const PENGUIN_MODEL := preload("res://assets/models/penguin_statue.glb")
const TRUCK_MODEL := preload("res://assets/models/ice_cream_truck.glb")
const WHEEL_MODEL := preload("res://assets/models/car_wheel.glb")
## The lot; the building goes from BACK_WALL_Z to FRONT_WALL_Z, the yard behind it and the sidewalk strip in front.
const HALF_X := 10.0
const HALF_Z := 10.0
const FRONT_WALL_Z := 8.5
const BACK_WALL_Z := -5.0
const FLOOR_TOP := 0.06
const WALL_TOP := GameScale.FLOOR_HEIGHT - PlaceBuilder.SLAB
const ROOF_TOP := GameScale.FLOOR_HEIGHT
const ENTRANCE_X := 3.0
## The wall between the salon (z > SALON_Z) and the rooms behind it, with the kitchen's, the office's and the
## bathroom's doors; the walls between those rooms.
const SALON_Z := 2.0
const KITCHEN_DOOR_X := -4.0
const OFFICE_DOOR_X := 2.5
const BATH_DOOR_X := 8.5
const KITCHEN_X1 := 0.0
const BATH_X0 := 5.0
## The cold room in the kitchen's back corner, behind its locked door, and the kitchen's back door to the yard.
const COLD_X1 := -5.5
const COLD_Z1 := -1.0
const COLD_DOOR_X := -7.75
const BACK_DOOR_X := -1.5
## The counter (customers on its +Z side), the cashier's desk with the till next to it, and the soft-serve machine.
const COUNTER_AT := Vector3(-4.0, FLOOR_TOP, 4.6)
const COUNTER_SIZE := Vector3(5.0, 1.0, 0.94)
const CASHIER_AT := Vector3(-0.8, FLOOR_TOP, 4.6)
const CASHIER_SIZE := Vector3(1.2, 1.0, 0.9)
const MACHINE_AT := Vector3(-1.0, FLOOR_TOP, 1.5)
const MACHINE_SIZE := Vector3(0.7, 1.7, 0.7)
## The four freezers, each standing at `at` turned `turn` (their lids hinge on their back, -Z before the turn).
const FREEZERS := [
	{"at": Vector3(-8.5, FLOOR_TOP, 2.9), "turn": 0.0},
	{"at": Vector3(6.4, FLOOR_TOP, 2.9), "turn": 0.0},
	{"at": Vector3(-0.5, FLOOR_TOP, -0.6), "turn": -PI / 2},
	{"at": Vector3(-0.5, FLOOR_TOP, -2.6), "turn": -PI / 2},
]
const FREEZER_SIZE := Vector3(1.6, 0.85, 0.8)
const SHELVES: Array[Vector3] = [Vector3(-8.9, FLOOR_TOP, -4.6), Vector3(-6.9, FLOOR_TOP, -4.6)]
const SHELF_SIZE := Vector3(2.0, 2.2, 0.6)
## The penguin on the sidewalk strip, and the truck in the yard, its front to +X.
const PENGUIN_AT := Vector3(6.5, FLOOR_TOP, 9.3)
const TRUCK_AT := Vector3(3.5, 0.0, -7.6)
## How fast a prop must hit to crack the counter's glass case or knock the penguin over, and the case's fine.
const CASE_SPEED := 3.0
const CASE_FINE := 30
const PENGUIN_SPEED := 3.0

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "behind_ice_counter", "at": Vector3(-4.0, FLOOR_TOP, 3.4), "heavy": true},
	{"id": "in_ice_cold_room", "at": Vector3(-7.9, FLOOR_TOP, -3.4), "heavy": true},
	{"id": "behind_ice_desk", "at": Vector3(3.6, FLOOR_TOP, -4.3), "heavy": true},
	{"id": "in_ice_bathroom", "at": Vector3(8.6, FLOOR_TOP, -1.5), "heavy": true},
	{"id": "behind_ice_truck", "at": Vector3(3.5, FLOOR_TOP, -9.3), "heavy": true},
	{"id": "among_yard_buckets", "at": Vector3(-6.5, FLOOR_TOP, -8.0), "heavy": true},
	{"id": "on_ice_cold_shelf", "at": Vector3(-6.9, FLOOR_TOP + 2.2, -4.6), "heavy": false},
	{"id": "on_soft_machine", "at": Vector3(-1.0, FLOOR_TOP + 1.7, 1.5), "heavy": false},
	{"id": "under_ice_table", "at": Vector3(8.0, FLOOR_TOP, 7.0), "heavy": false},
	{"id": "on_kitchen_bench", "at": Vector3(-3.4, FLOOR_TOP + 0.9, -4.6), "heavy": false},
	{"id": "under_flavor_board", "at": Vector3(3.8, FLOOR_TOP, 2.4), "heavy": false},
	{"id": "on_ice_cashier", "at": Vector3(-0.5, FLOOR_TOP + 1.0, 4.6), "heavy": false},
]

const OUTSIDE := Color(0.98, 0.84, 0.9)
const TILE := Color(0.92, 0.9, 0.86)
const CHECKER := Color(0.3, 0.6, 0.75)
const WALL_IN := Color(0.96, 0.94, 0.88)
const MINT := Color(0.6, 0.88, 0.78)
const CONCRETE := Color(0.62, 0.62, 0.6)
const WOOD := Color(0.6, 0.42, 0.28)
const STEEL := Color(0.72, 0.74, 0.78)
const PINK := Color(0.95, 0.45, 0.62)
const COLD := Color(0.78, 0.9, 0.98)
const DARK := Color(0.16, 0.16, 0.2)
const FENCE := Color(0.85, 0.82, 0.72)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var cold_door: FrontDoor
var till: Till
var case_broken := false
var penguin_down := false
var broken_goods := 0
## Money taken off the case pay: the counter's glass case (and the melted freezers, step 2).
var fines := 0
## Same seed, same shop (the stories and the hiding spots come from it, step 5).
@export var case_seed := 0
var _build: PlaceBuilder
var _penguin: Node3D
var _penguin_body: StaticBody3D
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_salon()
	_build_kitchen()
	_build_back()
	_build_yard()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("ice_cream")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "ice_cream", car)


## The floors, the outer walls with the entrance, the roof, the sign over the door and the penguin on the sidewalk.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, BACK_WALL_Z, FRONT_WALL_Z, FLOOR_TOP, TILE)
	_build.slab(-HALF_X, HALF_X, FRONT_WALL_Z, HALF_Z, FLOOR_TOP, CONCRETE)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, BACK_WALL_Z, FLOOR_TOP, CONCRETE)
	_build.slab(-HALF_X, HALF_X, BACK_WALL_Z, FRONT_WALL_Z, ROOF_TOP, OUTSIDE.darkened(0.25))
	# The salon's checkered floor, only for the look.
	for i in 20:
		for j in 6:
			if (i + j) % 2 == 0:
				_build.mesh_box(Vector3(-9.5 + i, FLOOR_TOP + 0.005, 2.5 + j), Vector3(1.0, 0.01, 1.0), CHECKER)
	_build.wall_at("x", FRONT_WALL_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [ENTRANCE_X], OUTSIDE)
	_build.wall_at("x", BACK_WALL_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [BACK_DOOR_X], OUTSIDE)
	_build.wall_at("z", -HALF_X, BACK_WALL_Z, FRONT_WALL_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, BACK_WALL_Z, FRONT_WALL_Z, 0.0, WALL_TOP, [], OUTSIDE)
	# A pink awning over the front.
	_build.mesh_box(Vector3(0, WALL_TOP - 0.2, FRONT_WALL_Z + 0.6), Vector3(HALF_X * 2, 0.08, 1.2), PINK)
	for line: Array in [["PLACE_ICE_CREAM", 64, 2.75], ["ICE_SINCE", 32, 3.2]]:
		var label := Label3D.new()
		label.text = line[0]
		label.font_size = line[1]
		label.pixel_size = 0.01
		label.outline_size = 12
		label.modulate = PINK.lightened(0.4)
		label.position = Vector3(-3.0, line[2], FRONT_WALL_Z + 0.1)
		$Built.add_child(label)
	_penguin = _model(PENGUIN_MODEL, PENGUIN_AT)
	_penguin_body = _build.body(PENGUIN_AT + Vector3(0, 1.0, 0))
	_build.shape(_penguin_body, Vector3(0.9, 2.0, 0.8))
	var hit := _area(PENGUIN_AT + Vector3(0, 1.0, 0), Vector3(1.6, 2.0, 1.6))
	hit.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > PENGUIN_SPEED:
			knock_penguin())


## The salon: the counter with its glass case, the cashier's desk with the till and the cones, the two freezers, the
## tables and the "flavor of the month" board, and the wall to the rooms behind.
func _build_salon() -> void:
	_model(COUNTER_MODEL, COUNTER_AT)
	_build.shape(_build.body(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0)), COUNTER_SIZE)
	var glass := _area(COUNTER_AT + Vector3(0, 1.1, 0.6), Vector3(COUNTER_SIZE.x, 0.6, 0.6))
	glass.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > CASE_SPEED:
			crack_case())
	_build.open_box(CASHIER_AT, CASHIER_SIZE, "-z", PINK)
	till = Till.new()
	till.position = CASHIER_AT + Vector3(-0.3, CASHIER_SIZE.y + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_ICE"
	add_child(till)
	# The scale and the cones' dispenser, only for the look.
	_build.mesh_box(CASHIER_AT + Vector3(0.3, CASHIER_SIZE.y + 0.05, 0.1), Vector3(0.3, 0.1, 0.3), STEEL)
	_build.mesh_box(CASHIER_AT + Vector3(0.45, CASHIER_SIZE.y + 0.25, -0.25), Vector3(0.12, 0.5, 0.12), WOOD)
	for i in 2:
		_freezer(i)
	for at: Vector3 in [Vector3(5.5, FLOOR_TOP, 7.0), Vector3(8.0, FLOOR_TOP, 7.0), Vector3(8.0, FLOOR_TOP, 5.0)]:
		_build.box(at + Vector3(0, 0.75, 0), Vector3(0.8, 0.05, 0.8), MINT)
		_build.box(at + Vector3(0, 0.37, 0), Vector3(0.1, 0.74, 0.1), STEEL)
		for side: float in [-1.0, 1.0]:
			_build.box(at + Vector3(side * 0.75, 0.22, 0), Vector3(0.4, 0.44, 0.4), PINK)
	_build.mesh_box(Vector3(3.8, 1.7, SALON_Z + 0.09), Vector3(1.4, 0.9, 0.03), DARK)
	var board := Label3D.new()
	board.text = "ICE_FLAVOR_OF_THE_MONTH"
	board.font_size = 26
	board.pixel_size = 0.005
	board.position = Vector3(3.8, 1.95, SALON_Z + 0.12)
	$Built.add_child(board)
	_build.wall_at("x", SALON_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [KITCHEN_DOOR_X, OFFICE_DOOR_X, BATH_DOOR_X], MINT)
	for at: Vector3 in [Vector3(-4.0, 2.2, 6.0), Vector3(4.0, 2.2, 6.0)]:
		_build.light(at)


## The kitchen: the soft-serve machine, the bench with the mixer and the sink, two freezers, and the cold room behind
## its locked door with shelves of tubs and blocks of ice.
func _build_kitchen() -> void:
	_build.wall_at("z", KITCHEN_X1, BACK_WALL_Z, SALON_Z, 0.0, WALL_TOP, [], WALL_IN)
	_model(MACHINE_MODEL, MACHINE_AT, PI)
	_build.shape(_build.body(MACHINE_AT + Vector3(0, MACHINE_SIZE.y / 2, 0)), MACHINE_SIZE)
	_build.box(Vector3(-3.4, FLOOR_TOP + 0.45, -4.6), Vector3(2.4, 0.9, 0.6), STEEL)
	_build.mesh_box(Vector3(-2.7, FLOOR_TOP + 1.1, -4.6), Vector3(0.35, 0.4, 0.35), PINK)
	_build.mesh_box(Vector3(-4.2, FLOOR_TOP + 0.92, -4.6), Vector3(0.6, 0.04, 0.4), DARK)
	for i in range(2, 4):
		_freezer(i)
	_build.wall_at("x", COLD_Z1, -HALF_X, COLD_X1, 0.0, WALL_TOP, [COLD_DOOR_X], COLD)
	_build.wall_at("z", COLD_X1, BACK_WALL_Z, COLD_Z1, 0.0, WALL_TOP, [], COLD)
	_build.mesh_box(Vector3((-HALF_X + COLD_X1) / 2, FLOOR_TOP + 0.05, (BACK_WALL_Z + COLD_Z1) / 2),
		Vector3(COLD_X1 + HALF_X - 0.3, 0.1, COLD_Z1 - BACK_WALL_Z - 0.3), Color(0.95, 0.97, 1.0))
	for at: Vector3 in SHELVES:
		_model(SHELF_MODEL, at)
		_build.shape(_build.body(at + Vector3(0, SHELF_SIZE.y / 2, 0)), SHELF_SIZE)
	cold_door = DOOR_SCENE.instantiate()
	cold_door.position = Vector3(COLD_DOOR_X - GameScale.DOOR_WIDTH / 2, 0.0, COLD_Z1)
	add_child(cold_door)
	var frost := _build.light(Vector3(-7.75, 2.2, -3.0))
	frost.light_color = COLD
	frost.light_energy = 0.6
	_build.light(Vector3(-3.0, 2.2, -1.5)).light_energy = 0.6


## The owner's office with the desk and the toy safe, and the bathroom.
func _build_back() -> void:
	_build.wall_at("z", BATH_X0, BACK_WALL_Z, SALON_Z, 0.0, WALL_TOP, [], WALL_IN)
	_build.box(Vector3(2.5, FLOOR_TOP + 0.4, -3.0), Vector3(1.8, 0.8, 0.8), WOOD)
	_build.box(Vector3(2.5, FLOOR_TOP + 0.25, -3.9), Vector3(0.5, 0.5, 0.5), PINK)
	_build.box(Vector3(4.4, FLOOR_TOP + 0.3, -4.5), Vector3(0.5, 0.6, 0.5), DARK)
	_build.box(Vector3(9.4, FLOOR_TOP + 0.25, -4.2), Vector3(0.5, 0.5, 0.6), TILE)
	_build.box(Vector3(5.6, FLOOR_TOP + 0.45, -1.0), Vector3(0.5, 0.9, 0.6), TILE)
	for at: Vector3 in [Vector3(2.5, 2.2, -1.5), Vector3(7.5, 2.2, -1.5)]:
		_build.light(at).light_energy = 0.4


## The fenced yard behind the kitchen with the ice cream truck and a pile of empty buckets.
func _build_yard() -> void:
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, 1.2, [], FENCE)
	for x: float in [-HALF_X, HALF_X]:
		_build.wall_at("z", x, -HALF_Z, BACK_WALL_Z, 0.0, 1.2, [], FENCE)
	var truck := _model(TRUCK_MODEL, TRUCK_AT, PI / 2)
	for at: Vector3 in [Vector3(-1.1, 0.38, 1.7), Vector3(1.1, 0.38, 1.7), Vector3(-1.1, 0.38, -1.7),
			Vector3(1.1, 0.38, -1.7)]:
		var wheel: Node3D = WHEEL_MODEL.instantiate()
		wheel.position = at
		truck.add_child(wheel)
	_build.shape(_build.body(TRUCK_AT + Vector3(0, 1.3, 0)), Vector3(5.2, 2.6, 2.2))
	for i in 4:
		_build.box(Vector3(-7.4 + (i % 2) * 0.6, FLOOR_TOP + 0.25 + (i / 2) * 0.5, -8.6), Vector3(0.45, 0.5, 0.45),
			[MINT, PINK, COLD, FENCE][i])


## Freezer `i` of FREEZERS: its body, and its lid shut on top (the lids open in step 2).
func _freezer(i: int) -> void:
	var at: Vector3 = FREEZERS[i].at
	var turn: float = FREEZERS[i].turn
	_model(FREEZER_MODEL, at, turn)
	var solid := _build.body(at + Vector3(0, FREEZER_SIZE.y / 2, 0))
	solid.rotation.y = turn
	_build.shape(solid, FREEZER_SIZE)
	var hinge := at + Vector3(0, FREEZER_SIZE.y, -FREEZER_SIZE.z / 2).rotated(Vector3.UP, turn)
	_model(LID_MODEL, hinge, turn)


## Cracks the counter's glass case, once: a fine and a crack across it.
func crack_case() -> void:
	if case_broken:
		return
	case_broken = true
	broken_goods += 1
	fines += CASE_FINE
	_build.mesh_box(COUNTER_AT + Vector3(0.4, 1.2, 0.36), Vector3(2.0, 0.03, 0.01), DARK)
	_build.mesh_box(COUNTER_AT + Vector3(-0.5, 1.15, 0.36), Vector3(0.03, 0.3, 0.01), DARK)
	_say(COUNTER_AT + Vector3(0, 2.2, 0.6), "ICE_CASE_BROKEN")
	case_cracked.emit()


## Knocks the penguin over, once: it lies on the sidewalk (no fine; the owner minds, step 3).
func knock_penguin() -> void:
	if penguin_down:
		return
	penguin_down = true
	_penguin.rotation.x = PI / 2
	_penguin.position = PENGUIN_AT + Vector3(0, 0.45, 0)
	_penguin_body.position = PENGUIN_AT + Vector3(0, 0.45, 1.0)
	_penguin_body.rotation.x = PI / 2
	_say(PENGUIN_AT + Vector3(0, 2.0, 0), "ICE_PENGUIN_DOWN")
	penguin_knocked.emit()


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
