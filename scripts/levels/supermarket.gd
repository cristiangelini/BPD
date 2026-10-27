class_name Supermarket
extends Node3D

## The supermarket "Súper El Changuito" as a place to raid (docs/diseno/allanamiento-super.md, step 1): a store on its
## lot in the city, open and with the front to +Z. Four gondolas make aisles 1 to 4, the dairy fridge runs along the
## back wall with the chest freezer in front of it, the produce stand with its scale is in the west corner, three
## checkouts face the door, the manager's office is in the front east corner (locked, its key in checkout 1's till) and
## the storeroom in the back east corner. By the door the offer table holds a pyramid of 21 cans: it falls with nothing,
## and the fridge's glass cracks if something hits it fast, a fine each. Every number here is (propuesta).

signal pyramid_fell
signal fridge_broken

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const GONDOLA_MODEL := preload("res://assets/models/gondola.glb")
const FRIDGE_MODEL := preload("res://assets/models/dairy_fridge.glb")
const CHECKOUT_MODEL := preload("res://assets/models/checkout.glb")
const PRODUCE_MODEL := preload("res://assets/models/produce_stand.glb")
const FREEZER_MODEL := preload("res://assets/models/chest_freezer.glb")
const CAN_MODEL := preload("res://assets/models/food_can.glb")
const HALF_X := 15.0
const HALF_Z := 12.0
const WALL_TOP := 5.0
const BUILDING_TOP := 7.0
const FLOOR_TOP := 0.06
## The open doorway in the front wall, east of the checkouts.
const ENTRANCE_X := 3.0
const ENTRANCE_WIDTH := 4.0
const ENTRANCE_HEIGHT := 3.0

## The gondolas: each aisle's west side, three 3 m modules from GONDOLA_FROM_Z, and the aisle signs between them.
const GONDOLA_X: Array[float] = [-10.0, -5.0, 0.0, 5.0]
const GONDOLA_FROM_Z := -6.0
const GONDOLA_MODULE := 3.0
const GONDOLA_SIZE := Vector3(1.2, 1.8, 9.0)
## The dairy fridge along the back wall (three of 4 m), and the fragile glass in front of them.
const FRIDGE_X: Array[float] = [-11.0, -7.0, -3.0]
const FRIDGE_Z := -11.4
const FRIDGE_SIZE := Vector3(4.0, 2.2, 0.9)
const FRIDGE_SPEED := 3.0
const FRIDGE_FINE := 30
const FREEZER_AT := Vector3(-3.0, FLOOR_TOP, -8.6)
const FREEZER_SIZE := Vector3(2.0, 0.9, 0.9)
const PRODUCE_AT := Vector3(-13.6, FLOOR_TOP, 2.0)
const PRODUCE_SIZE := Vector3(1.0, 0.9, 2.95)
## The checkouts, their middles; the till sits on checkout 1's stand.
const CHECKOUT_X: Array[float] = [-10.0, -6.0, -2.0]
const CHECKOUT_Z := 7.6
const CHECKOUT_SIZE := Vector3(0.8, 0.9, 2.4)
const TILL_ON := Vector3(-10.0, FLOOR_TOP + 0.92, 8.45)
## The offer table by the door with its pyramid: six rows of cans, from 6 at the bottom to 1 at the top.
const OFFER_AT := Vector3(3.0, FLOOR_TOP, 4.0)
const OFFER_SIZE := Vector3(1.4, 0.8, 0.7)
const CAN_SIZE := Vector3(0.1, 0.12, 0.1)
const PYRAMID_ROWS := 6
## How far a can has to move from its place for the pyramid to count as fallen, and the fine.
const PYRAMID_MOVED := 0.15
const PYRAMID_FINE := 20
## The office in the front east corner, its door in its north wall; and the storeroom in the back east corner, its
## swing door an open gap.
const OFFICE_X := 8.0
const OFFICE_Z := 5.0
const OFFICE_DOOR_X := 10.0
const DESK_AT := Vector3(12.5, FLOOR_TOP, 9.5)
const DESK_SIZE := Vector3(1.8, 0.8, 0.9)
const STORE_X := 8.0
const STORE_Z := -5.0
const STORE_DOOR_X := 11.5
const BOX_STACKS: Array[Vector3] = [Vector3(10.0, FLOOR_TOP, -9.5), Vector3(13.5, FLOOR_TOP, -8.0),
	Vector3(13.5, FLOOR_TOP, -10.8)]
const BOX_STACK_SIZE := Vector3(1.2, 1.6, 1.2)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_super_freezer", "at": Vector3(-3.0, FLOOR_TOP + 0.1, -8.6), "heavy": true},
	{"id": "behind_produce", "at": Vector3(-14.4, FLOOR_TOP, -0.6), "heavy": true},
	{"id": "between_storeroom_boxes", "at": Vector3(11.8, FLOOR_TOP, -9.0), "heavy": true},
	{"id": "by_loading_door", "at": Vector3(10.0, FLOOR_TOP, -11.3), "heavy": true},
	{"id": "in_cardboard_bin", "at": Vector3(-13.8, FLOOR_TOP, -6.5), "heavy": true},
	{"id": "in_super_office_corner", "at": Vector3(14.0, FLOOR_TOP, 11.0), "heavy": true},
	{"id": "on_top_shelf", "at": Vector3(-5.0, FLOOR_TOP + 1.8, -3.0), "heavy": false},
	{"id": "in_aisle_4", "at": Vector3(7.0, FLOOR_TOP, -2.0), "heavy": false},
	{"id": "under_checkout_belt", "at": Vector3(-6.0, FLOOR_TOP, 6.2), "heavy": false},
	{"id": "behind_offer_table", "at": Vector3(3.0, FLOOR_TOP, 3.3), "heavy": false},
	{"id": "by_produce_scale", "at": Vector3(-13.6, FLOOR_TOP + 0.9, 3.3), "heavy": false},
	{"id": "on_super_desk", "at": Vector3(13.0, FLOOR_TOP + 0.8, 9.5), "heavy": false},
]

const OUTSIDE := Color(0.95, 0.86, 0.4)
const TILE := Color(0.93, 0.9, 0.82)
const CEILING := Color(0.94, 0.94, 0.92)
const RED := Color(0.85, 0.25, 0.2)
const WOOD := Color(0.6, 0.44, 0.3)
const DARK := Color(0.1, 0.1, 0.12)
const CARDBOARD := Color(0.72, 0.56, 0.36)
const GLASS := Color(0.6, 0.82, 0.95)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
## The pyramid's cans, bottom row first, and where each one started.
var cans: Array[RigidBody3D] = []
var can_homes: Array[Vector3] = []
var pyramid_fallen := false
var fridge_cracked := false
var broken_goods := 0
## Money taken off the case pay: the pyramid and the fridge's glass.
var fines := 0
## Same seed, same supermarket (the stories and the hiding spots come from it, step 5).
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
	_build_aisles()
	_build_back()
	_build_front()
	_build_rooms()
	_build_pyramid()
	office_door = _door(OFFICE_DOOR_X)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("supermarket")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "supermarket", car)


## The tiled floor, the walls with the doorway and the shop windows, the roof and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, TILE)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, CEILING)
	var x0 := ENTRANCE_X - ENTRANCE_WIDTH / 2
	var x1 := ENTRANCE_X + ENTRANCE_WIDTH / 2
	_build.wall_at("x", HALF_Z, -HALF_X, x0, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x1, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x0, x1, ENTRANCE_HEIGHT, WALL_TOP - ENTRANCE_HEIGHT, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	# The shop windows on the front, with the week's offers painted on them.
	for x: float in [-11.0, -6.0, -1.5]:
		_build.mesh_box(Vector3(x, 1.7, HALF_Z + 0.08), Vector3(3.6, 2.0, 0.02), GLASS)
		_build.mesh_box(Vector3(x, 2.3, HALF_Z + 0.1), Vector3(2.0, 0.4, 0.02), RED)
	_label("PLACE_SUPERMARKET", Vector3(0, WALL_TOP + 0.9, HALF_Z + 0.08), 110)
	for x: float in [-10.0, -5.0, 0.0, 5.0, 10.0]:
		for z: float in [-7.0, 0.0, 7.0]:
			_build.light(Vector3(x, 4.6, z))


## The four gondolas, each of three modules, and the aisle signs hanging over the aisles on their east side.
func _build_aisles() -> void:
	for i in GONDOLA_X.size():
		var x := GONDOLA_X[i]
		_solid(Vector3(x, FLOOR_TOP + GONDOLA_SIZE.y / 2, GONDOLA_FROM_Z + GONDOLA_SIZE.z / 2), GONDOLA_SIZE)
		for m in 3:
			_model(GONDOLA_MODEL, Vector3(x, FLOOR_TOP, GONDOLA_FROM_Z + GONDOLA_MODULE * (m + 0.5)))
		var sign_at := Vector3(x + 2.5, 3.6, GONDOLA_FROM_Z + GONDOLA_SIZE.z / 2)
		_build.mesh_box(sign_at, Vector3(1.6, 0.6, 0.04), RED)
		# Read from both ends of the aisle.
		_label("SUPER_AISLE_%d" % (i + 1), sign_at + Vector3(0, 0, 0.04), 40)
		_label("SUPER_AISLE_%d" % (i + 1), sign_at - Vector3(0, 0, 0.04), 40, PI)


## The dairy fridge along the back wall, its glass that cracks, and the chest freezer in front of it.
func _build_back() -> void:
	for x: float in FRIDGE_X:
		_solid(Vector3(x, FLOOR_TOP + FRIDGE_SIZE.y / 2, FRIDGE_Z), FRIDGE_SIZE)
		_model(FRIDGE_MODEL, Vector3(x, FLOOR_TOP, FRIDGE_Z))
	var width := FRIDGE_SIZE.x * FRIDGE_X.size()
	var glass := _area(Vector3(-7.0, FLOOR_TOP + 1.0, FRIDGE_Z + FRIDGE_SIZE.z / 2 + 0.2), Vector3(width, 1.6, 0.4))
	glass.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > FRIDGE_SPEED:
			break_fridge())
	_build.open_box(FREEZER_AT, FREEZER_SIZE, "top", Color(0.93, 0.94, 0.95))
	_model(FREEZER_MODEL, FREEZER_AT)
	# The cardboard bin in the back west corner, open on top.
	_build.open_box(Vector3(-13.8, FLOOR_TOP, -6.5), Vector3(1.4, 1.0, 1.2), "top", CARDBOARD.darkened(0.2))


## The produce stand, the three checkouts with checkout 1's till, and the offer table by the door.
func _build_front() -> void:
	_solid(PRODUCE_AT + Vector3(0, PRODUCE_SIZE.y / 2, 0), PRODUCE_SIZE)
	_model(PRODUCE_MODEL, PRODUCE_AT, PI)
	for x: float in CHECKOUT_X:
		_solid(Vector3(x, FLOOR_TOP + CHECKOUT_SIZE.y / 2, CHECKOUT_Z), CHECKOUT_SIZE)
		_model(CHECKOUT_MODEL, Vector3(x, FLOOR_TOP, CHECKOUT_Z))
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_SUPERMARKET"
	add_child(till)
	_solid(OFFER_AT + Vector3(0, OFFER_SIZE.y / 2, 0), OFFER_SIZE)
	_build.mesh_box(OFFER_AT + Vector3(0, OFFER_SIZE.y / 2, 0), OFFER_SIZE, RED)
	_label("SUPER_OFFER", OFFER_AT + Vector3(0, 1.9, 0), 48, 0.0, 0.004)


## The manager's office (walls, its locked door and a desk) and the storeroom with its stacks of boxes.
func _build_rooms() -> void:
	_build.wall_at("x", OFFICE_Z, OFFICE_X, HALF_X, 0.0, WALL_TOP, [OFFICE_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("z", OFFICE_X, OFFICE_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.04, DARK)
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.02, 0), Vector3(DESK_SIZE.x, 0.04, DESK_SIZE.z), WOOD)
	_build.wall_at("x", STORE_Z, STORE_X, HALF_X, 0.0, WALL_TOP, [STORE_DOOR_X], OUTSIDE.lightened(0.1))
	_build.wall_at("z", STORE_X, -HALF_Z, STORE_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.1))
	for at: Vector3 in BOX_STACKS:
		_build.box(at + Vector3(0, BOX_STACK_SIZE.y / 2, 0), BOX_STACK_SIZE, CARDBOARD)
	# The loading door in the back wall, closed.
	_build.mesh_box(Vector3(10.0, 1.6, -HALF_Z + 0.1), Vector3(3.0, 3.2, 0.04), DARK.lightened(0.3))


## The pyramid of cans on the offer table: each row half a can in from the one under it, asleep until bumped.
func _build_pyramid() -> void:
	var top := OFFER_AT.y + OFFER_SIZE.y
	for row in PYRAMID_ROWS:
		var count := PYRAMID_ROWS - row
		for i in count:
			var at := OFFER_AT + Vector3((i - (count - 1) / 2.0) * CAN_SIZE.x, 0, 0)
			at.y = top + CAN_SIZE.y * (row + 0.5)
			var can := ClubEvidence.make_item("Can", CAN_MODEL, CAN_SIZE, 0.4)
			(can.get_child(1) as Node3D).position.y = -CAN_SIZE.y / 2
			add_child(can)
			can.position = at
			can.sleeping = true
			cans.append(can)
			can_homes.append(at)


func _physics_process(_delta: float) -> void:
	if pyramid_fallen:
		return
	for i in cans.size():
		if cans[i].position.distance_to(can_homes[i]) > PYRAMID_MOVED:
			topple_pyramid()
			return


## The pyramid fell, once: a fine and the manager on the loudspeaker.
func topple_pyramid() -> void:
	if pyramid_fallen:
		return
	pyramid_fallen = true
	broken_goods += 1
	fines += PYRAMID_FINE
	for can in cans:
		can.sleeping = false
	_say(OFFER_AT + Vector3(0, 2.2, 0), "SUPER_PYRAMID_FELL")
	pyramid_fell.emit()


## The fridge's glass cracked, once: a fine and the cracks over it.
func break_fridge() -> void:
	if fridge_cracked:
		return
	fridge_cracked = true
	broken_goods += 1
	fines += FRIDGE_FINE
	for i in 9:
		_build.mesh_box(Vector3(-11.5 + i * 1.3, FLOOR_TOP + 0.8 + (i % 3) * 0.3, FRIDGE_Z + FRIDGE_SIZE.z / 2 + 0.03),
			Vector3(0.7, 0.02, 0.02), DARK)
	_say(Vector3(-7.0, 2.8, FRIDGE_Z + 1.0), "SUPER_FRIDGE_BROKEN")
	fridge_broken.emit()


## A locked door in the office's north wall, its middle at x.
func _door(x: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(x - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_Z)
	add_child(door)
	return door


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


func _label(key: String, at: Vector3, size: int, turn := 0.0, pixel := 0.01) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = pixel
	label.outline_size = 18
	label.double_sided = false
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)


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
