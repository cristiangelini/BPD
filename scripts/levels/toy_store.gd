class_name ToyStore
extends Node3D

## The "Juguetería El Trompo Loco" as a place to raid (docs/diseno/allanamiento-jugueteria.md, step 1): a one-floor
## neighborhood toy store on its lot in the city, the front to +Z, with the giant spinning top on the roof and the
## giant teddy bear by the door. The salon has five toy shelves in aisles, the counter with the till, the train table
## with its control box, the collectors' glass case, the block castle and the ball pit; behind it, the storeroom
## (locked with the till's key), don Cucho's workshop and the bathroom. The workshop's back door opens to the fenced
## yard with the delivery van. Something thrown hard at the glass case cracks it (a fine), and at the castle knocks it
## down in pieces (another fine). Every number here is (propuesta).

signal case_cracked
signal castle_fallen

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const SHELF_MODEL := preload("res://assets/models/toy_shelf.glb")
const COUNTER_MODEL := preload("res://assets/models/toy_counter.glb")
const TRAIN_MODEL := preload("res://assets/models/train_table.glb")
const CASTLE_MODEL := preload("res://assets/models/block_castle.glb")
const TEDDY_MODEL := preload("res://assets/models/giant_teddy.glb")
const CASE_MODEL := preload("res://assets/models/collector_case.glb")
const PIT_MODEL := preload("res://assets/models/ball_pit.glb")
const TOP_MODEL := preload("res://assets/models/giant_top.glb")
const VAN_MODEL := preload("res://assets/models/toy_van.glb")
## The lot; the building goes from BACK_WALL_Z to FRONT_WALL_Z, the yard behind it and the sidewalk strip in front.
const HALF_X := 11.0
const HALF_Z := 10.0
const FRONT_WALL_Z := 8.5
const BACK_WALL_Z := -5.0
const FLOOR_TOP := 0.06
const WALL_TOP := GameScale.FLOOR_HEIGHT - PlaceBuilder.SLAB
const ROOF_TOP := GameScale.FLOOR_HEIGHT
const ENTRANCE_X := 0.0
## The wall between the salon (z > SALON_Z) and the rooms behind it, with the storeroom's, the workshop's and the
## bathroom's doors; the walls between those rooms, and the workshop's back door to the yard.
const SALON_Z := 0.0
const STORE_DOOR_X := -7.5
const WORKSHOP_DOOR_X := 2.5
const BATH_DOOR_X := 8.5
const STORE_X1 := -4.0
const BATH_X0 := 6.0
const BACK_DOOR_X := 0.0
## The five shelves in aisles, long side along X, toys on both faces.
const SHELVES: Array[Vector3] = [Vector3(-4.5, FLOOR_TOP, 2.2), Vector3(-1.0, FLOOR_TOP, 2.2),
	Vector3(-4.5, FLOOR_TOP, 4.8), Vector3(-1.0, FLOOR_TOP, 4.8), Vector3(2.5, FLOOR_TOP, 4.8)]
const SHELF_SIZE := Vector3(3.0, 1.8, 0.6)
## The counter (customers on its +Z side) with the till, and the train's control box next to it.
const COUNTER_AT := Vector3(6.5, FLOOR_TOP, 6.6)
const COUNTER_SIZE := Vector3(3.0, 1.0, 0.9)
const CONTROL_AT := Vector3(4.6, FLOOR_TOP, 6.6)
## The train table with its loop and the tunnel on its +X curve.
const TRAIN_AT := Vector3(6.0, FLOOR_TOP, 2.6)
const TRAIN_SIZE := Vector3(4.4, 0.9, 2.4)
## The collectors' glass case against the east wall, its glass to -X; the block castle on its table; the teddy.
const CASE_AT := Vector3(10.6, FLOOR_TOP, 4.6)
const CASE_SIZE := Vector3(2.4, 1.8, 0.6)
const CASTLE_AT := Vector3(9.6, FLOOR_TOP, 7.6)
const CASTLE_SIZE := Vector3(1.4, 0.8, 1.0)
const TEDDY_AT := Vector3(-2.2, FLOOR_TOP, 7.0)
## The ball pit in the salon's front corner: a padded rim around a floor of balls.
const PIT_AT := Vector3(-8.5, FLOOR_TOP, 6.0)
const PIT_SIZE := Vector3(4.0, 0.6, 4.0)
const PIT_FLOOR := 0.3
## The van in the yard, its front to +X.
const VAN_AT := Vector3(4.0, 0.0, -7.6)
## How fast a prop must hit to crack the glass case or knock the castle down, and their fines.
const CASE_SPEED := 3.0
const CASE_FINE := 30
const CASTLE_SPEED := 2.0
const CASTLE_FINE := 20
## How fast the giant top on the roof spins, in turns a second.
const TOP_SPIN := 0.25

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_toy_ball_pit", "at": Vector3(-8.5, FLOOR_TOP + PIT_FLOOR, 6.0), "heavy": true},
	{"id": "behind_toy_counter", "at": Vector3(7.0, FLOOR_TOP, 5.6), "heavy": true},
	{"id": "behind_toy_boxes", "at": Vector3(-8.0, FLOOR_TOP, -3.4), "heavy": true},
	{"id": "under_toy_bench", "at": Vector3(3.5, FLOOR_TOP, -4.3), "heavy": true},
	{"id": "in_toy_bathroom", "at": Vector3(8.6, FLOOR_TOP, -2.5), "heavy": true},
	{"id": "behind_toy_van", "at": Vector3(4.0, FLOOR_TOP, -9.3), "heavy": true},
	{"id": "in_train_tunnel", "at": Vector3(7.7, FLOOR_TOP + TRAIN_SIZE.y, 2.6), "heavy": false},
	{"id": "on_toy_counter", "at": Vector3(7.6, FLOOR_TOP + COUNTER_SIZE.y, 6.6), "heavy": false},
	{"id": "behind_giant_teddy", "at": Vector3(-2.2, FLOOR_TOP, 8.05), "heavy": false},
	{"id": "on_toy_shelf", "at": Vector3(-1.0, FLOOR_TOP + SHELF_SIZE.y, 2.2), "heavy": false},
	{"id": "on_collector_case", "at": Vector3(10.6, FLOOR_TOP + CASE_SIZE.y, 4.6), "heavy": false},
	{"id": "on_toy_bench", "at": Vector3(2.4, FLOOR_TOP + 0.9, -4.3), "heavy": false},
]

const OUTSIDE := Color(0.98, 0.86, 0.42)
const FLOOR := Color(0.9, 0.86, 0.78)
const RUG := Color(0.42, 0.62, 0.92)
const WALL_IN := Color(0.97, 0.94, 0.88)
const SKY := Color(0.62, 0.82, 0.96)
const CONCRETE := Color(0.62, 0.62, 0.6)
const WOOD := Color(0.6, 0.42, 0.28)
const CARDBOARD := Color(0.78, 0.62, 0.42)
const RED := Color(0.91, 0.29, 0.23)
const DARK := Color(0.16, 0.16, 0.2)
const TILE := Color(0.92, 0.92, 0.95)
const FENCE := Color(0.85, 0.82, 0.72)
const BLOCKS: Array[Color] = [Color(0.91, 0.29, 0.23), Color(0.95, 0.76, 0.19), Color(0.23, 0.54, 0.91),
	Color(0.3, 0.72, 0.4), Color(0.85, 0.4, 0.7)]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var store_door: FrontDoor
var till: Till
var case_broken := false
var castle_down := false
var broken_goods := 0
## Money taken off the case pay: the collectors' glass case and the block castle.
var fines := 0
## Same seed, same store (the stories and the hiding spots come from it, step 5).
@export var case_seed := 0
var _build: PlaceBuilder
var _top: Node3D
var _castle: Node3D
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_salon()
	_build_back()
	_build_yard()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("toy_store")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "toy_store", car)


func _process(delta: float) -> void:
	_top.rotation.y = wrapf(_top.rotation.y + TAU * TOP_SPIN * delta, 0.0, TAU)


## The floors, the outer walls with the entrance, the roof with the giant top, and the sign over the door.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, BACK_WALL_Z, FRONT_WALL_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, FRONT_WALL_Z, HALF_Z, FLOOR_TOP, CONCRETE)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, BACK_WALL_Z, FLOOR_TOP, CONCRETE)
	_build.slab(-HALF_X, HALF_X, BACK_WALL_Z, FRONT_WALL_Z, ROOF_TOP, OUTSIDE.darkened(0.25))
	# A blue rug down the middle aisle, only for the look.
	_build.mesh_box(Vector3(ENTRANCE_X + 0.75, FLOOR_TOP + 0.005, 5.5), Vector3(1.5, 0.01, 6.0), RUG)
	_build.wall_at("x", FRONT_WALL_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [ENTRANCE_X], OUTSIDE)
	_build.wall_at("x", BACK_WALL_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [BACK_DOOR_X], OUTSIDE)
	_build.wall_at("z", -HALF_X, BACK_WALL_Z, FRONT_WALL_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, BACK_WALL_Z, FRONT_WALL_Z, 0.0, WALL_TOP, [], OUTSIDE)
	# A red awning over the front.
	_build.mesh_box(Vector3(0, WALL_TOP - 0.2, FRONT_WALL_Z + 0.6), Vector3(HALF_X * 2, 0.08, 1.2), RED)
	for line: Array in [["PLACE_TOY_STORE", 64, 2.75], ["TOY_SLOGAN", 32, 3.2]]:
		var label := Label3D.new()
		label.text = line[0]
		label.font_size = line[1]
		label.pixel_size = 0.01
		label.outline_size = 12
		label.modulate = OUTSIDE.lightened(0.5)
		label.position = Vector3(-4.0, line[2], FRONT_WALL_Z + 0.1)
		$Built.add_child(label)
	_top = _model(TOP_MODEL, Vector3(4.0, ROOF_TOP + 0.05, 6.0))


## The salon: the five shelves, the counter with the till, the train table and its control box, the glass case, the
## castle, the teddy by the door, the ball pit, and the wall to the rooms behind.
func _build_salon() -> void:
	for at: Vector3 in SHELVES:
		_model(SHELF_MODEL, at)
		_build.shape(_build.body(at + Vector3(0, SHELF_SIZE.y / 2, 0)), SHELF_SIZE)
	_model(COUNTER_MODEL, COUNTER_AT)
	_build.shape(_build.body(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0)), COUNTER_SIZE)
	till = Till.new()
	till.position = COUNTER_AT + Vector3(-0.9, COUNTER_SIZE.y + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_TOY"
	add_child(till)
	# The train's control box with its lever (it works in step 3).
	_build.box(CONTROL_AT + Vector3(0, 0.5, 0), Vector3(0.4, 1.0, 0.4), DARK)
	_build.mesh_box(CONTROL_AT + Vector3(0, 1.15, 0.1), Vector3(0.05, 0.3, 0.05), RED)
	_model(TRAIN_MODEL, TRAIN_AT)
	_build.shape(_build.body(TRAIN_AT + Vector3(0, TRAIN_SIZE.y / 2, 0)), TRAIN_SIZE)
	_model(CASE_MODEL, CASE_AT, -PI / 2)
	var solid := _build.body(CASE_AT + Vector3(0, CASE_SIZE.y / 2, 0))
	solid.rotation.y = -PI / 2
	_build.shape(solid, CASE_SIZE)
	var glass := _area(CASE_AT + Vector3(-0.6, 1.0, 0), Vector3(0.6, 1.4, CASE_SIZE.x))
	glass.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > CASE_SPEED:
			crack_case())
	_castle = _model(CASTLE_MODEL, CASTLE_AT)
	_build.shape(_build.body(CASTLE_AT + Vector3(0, CASTLE_SIZE.y / 2, 0)), CASTLE_SIZE)
	var blocks := _area(CASTLE_AT + Vector3(0, 1.2, 0), Vector3(1.8, 0.9, 1.4))
	blocks.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > CASTLE_SPEED:
			knock_castle())
	_model(TEDDY_MODEL, TEDDY_AT)
	_build.shape(_build.body(TEDDY_AT + Vector3(0, 1.0, 0)), Vector3(1.3, 2.0, 1.1))
	_model(PIT_MODEL, PIT_AT)
	var pit_floor := Vector3(PIT_SIZE.x - 0.4, PIT_FLOOR, PIT_SIZE.z - 0.4)
	_build.shape(_build.body(PIT_AT + Vector3(0, PIT_FLOOR / 2, 0)), pit_floor)
	for side: float in [-1.0, 1.0]:
		_build.shape(_build.body(PIT_AT + Vector3(0, PIT_SIZE.y / 2, side * 1.9)), Vector3(PIT_SIZE.x, PIT_SIZE.y, 0.2))
		_build.shape(_build.body(PIT_AT + Vector3(side * 1.9, PIT_SIZE.y / 2, 0)), Vector3(0.2, PIT_SIZE.y, 3.6))
	_build.wall_at("x", SALON_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [STORE_DOOR_X, WORKSHOP_DOOR_X, BATH_DOOR_X], SKY)
	for at: Vector3 in [Vector3(-6.0, 2.2, 4.0), Vector3(0.0, 2.2, 4.0), Vector3(6.0, 2.2, 4.0)]:
		_build.light(at)


## The storeroom with boxes piled to the ceiling behind its locked door, don Cucho's workshop with the bench and the
## magnifier, and the bathroom.
func _build_back() -> void:
	_build.wall_at("z", STORE_X1, BACK_WALL_Z, SALON_Z, 0.0, WALL_TOP, [], WALL_IN)
	_build.wall_at("z", BATH_X0, BACK_WALL_Z, SALON_Z, 0.0, WALL_TOP, [], WALL_IN)
	for i in 12:
		var size := Vector3(0.8, 0.6, 0.7)
		var at := Vector3(-10.4 + (i % 4) * 0.85, FLOOR_TOP + 0.3 + (i / 4) * 0.62, -4.5)
		_build.box(at, size, CARDBOARD.darkened(0.08 * (i % 3)))
	_build.box(Vector3(-5.0, FLOOR_TOP + 0.3, -1.0), Vector3(0.8, 0.6, 0.7), CARDBOARD)
	store_door = DOOR_SCENE.instantiate()
	store_door.position = Vector3(STORE_DOOR_X - GameScale.DOOR_WIDTH / 2, 0.0, SALON_Z)
	add_child(store_door)
	# The workshop's bench on legs, with the magnifier and a robot opened up on it.
	var bench := Vector3(3.0, FLOOR_TOP, -4.3)
	_build.box(bench + Vector3(0, 0.875, 0), Vector3(2.2, 0.05, 0.8), WOOD)
	_build.legs(bench, Vector2(2.2, 0.8), 0.85, WOOD.darkened(0.3))
	_build.mesh_box(bench + Vector3(0.6, 0.98, 0), Vector3(0.3, 0.16, 0.2), BLOCKS[2])
	_build.mesh_box(bench + Vector3(0.95, 1.1, -0.2), Vector3(0.04, 0.4, 0.04), DARK)
	_build.mesh_box(bench + Vector3(0.95, 1.3, -0.05), Vector3(0.18, 0.18, 0.02), SKY)
	_build.box(Vector3(-2.8, FLOOR_TOP + 0.5, -4.5), Vector3(1.2, 1.0, 0.5), WOOD)
	# The bathroom.
	_build.box(Vector3(10.4, FLOOR_TOP + 0.25, -4.2), Vector3(0.5, 0.5, 0.6), TILE)
	_build.box(Vector3(6.6, FLOOR_TOP + 0.45, -1.0), Vector3(0.5, 0.9, 0.6), TILE)
	for at: Vector3 in [Vector3(-7.5, 2.2, -2.5), Vector3(1.0, 2.2, -2.5), Vector3(8.5, 2.2, -2.5)]:
		_build.light(at).light_energy = 0.5


## The fenced yard behind the workshop with the delivery van and a pile of empty boxes.
func _build_yard() -> void:
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, 1.2, [], FENCE)
	for x: float in [-HALF_X, HALF_X]:
		_build.wall_at("z", x, -HALF_Z, BACK_WALL_Z, 0.0, 1.2, [], FENCE)
	_model(VAN_MODEL, VAN_AT, PI / 2)
	_build.shape(_build.body(VAN_AT + Vector3(0, 1.1, 0)), Vector3(4.6, 2.2, 2.0))
	for i in 5:
		_build.box(Vector3(-7.6 + (i % 3) * 0.7, FLOOR_TOP + 0.25 + (i / 3) * 0.5, -8.4), Vector3(0.6, 0.5, 0.6),
			CARDBOARD.lightened(0.05 * i))


## Cracks the collectors' glass case, once: a fine and a crack across it.
func crack_case() -> void:
	if case_broken:
		return
	case_broken = true
	broken_goods += 1
	fines += CASE_FINE
	_build.mesh_box(CASE_AT + Vector3(-0.32, 1.2, 0.2), Vector3(0.01, 0.03, 1.6), DARK)
	_build.mesh_box(CASE_AT + Vector3(-0.32, 1.0, -0.4), Vector3(0.01, 0.4, 0.03), DARK)
	_say(CASE_AT + Vector3(-0.6, 2.2, 0), "TOY_CASE_BROKEN")
	case_cracked.emit()


## Knocks the block castle down, once: its blocks lie all over the floor around the bare table, and a fine.
func knock_castle() -> void:
	if castle_down:
		return
	castle_down = true
	broken_goods += 1
	fines += CASTLE_FINE
	_castle.visible = false
	_build.mesh_box(CASTLE_AT + Vector3(0, CASTLE_SIZE.y / 2, 0), CASTLE_SIZE, Color(0.96, 0.94, 0.89))
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed
	for i in 12:
		var spot := Vector3(rng.randf_range(-1.4, 1.2), 0.12, rng.randf_range(-1.4, 0.7))
		_build.mesh_box(CASTLE_AT + spot, Vector3(0.28, 0.24, 0.28), BLOCKS[i % BLOCKS.size()])
	_say(CASTLE_AT + Vector3(0, 2.0, 0), "TOY_CASTLE_DOWN")
	castle_fallen.emit()


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
