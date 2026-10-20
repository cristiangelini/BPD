class_name Bakery
extends Node3D

## The bakery "El Pan Feliz" (docs/diseno/panaderia.md, step 1): the shop, the bakehouse, the storeroom and a
## bathroom downstairs, and Marta's flat upstairs, on its lot in the city with the front to +Z. The shop is open,
## with the shutter half up; the bakehouse door and the back door are locked. Marta serves the customers that come
## and go (step 2); the stories come next. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const BAKER_SCENE := preload("res://scenes/npc/baker.tscn")
const CUSTOMER_SCENE := preload("res://scenes/npc/bakery_customer.tscn")
## Customers: at most MAX_CUSTOMERS inside, a new one every CUSTOMER_EVERY seconds, none for SCARE_PAUSE after a scare.
const MAX_CUSTOMERS := 3
const CUSTOMER_EVERY := 8.0
const FIRST_CUSTOMER := 2.0
const SCARE_PAUSE := 20.0
## Where customers wait in front of the counter, and the lane they walk in along, inside the shop window.
const COUNTER_SLOTS := [2.2, 3.5, 4.8]
const COUNTER_FRONT := 4.45
const SHOP_LANE := 6.0
const SIDEWALK := 8.5
const HALF_X := 8.0
const HALF_Z := 7.0
## The shop floor sits a little over the city's paved block, which runs under it.
const FLOOR_TOP := 0.06
## The wall between the shop (front) and the back rooms, and the one between the storeroom (west) and the bakehouse.
const SHOP_BACK := 1.0
const STORE_EAST := 0.0
const STAIR_X := -7.2
const STAIR_FOOT := -0.2
const STAIR_RUN := 3.75
const BAKEHOUSE_DOOR_X := 3.0
const BACK_DOOR_X := 2.0
const ENTRANCE_X := -4.0
## The two windows of Marta's flat over the street, centered at these x.
const FLAT_WINDOWS := [-6.8, 6.2]

const OUTSIDE := Color(0.95, 0.75, 0.4)
const INSIDE := Color(1.0, 0.93, 0.8)
const BAKEHOUSE := Color(0.85, 0.85, 0.82)
const FLAT := Color(0.75, 0.85, 0.95)
const TILES := Color(0.8, 0.72, 0.62)
const FLOOR_WOOD := Color(0.66, 0.44, 0.28)
const WOOD := Color(0.55, 0.36, 0.25)
const WHITE := Color(0.92, 0.92, 0.88)
const STEEL := Color(0.6, 0.62, 0.66)
const GLASS := Color(0.55, 0.75, 0.85, 0.35)
const BREAD := Color(0.85, 0.58, 0.3)
const CAKE := Color(1.0, 0.7, 0.8)
const FLOUR := Color(0.95, 0.93, 0.88)
const SHUTTER := Color(0.55, 0.57, 0.6)
const AWNING := Color(0.75, 0.3, 0.25)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_oven", "at": Vector3(6.8, FLOOR_TOP + 0.05, -5.6), "heavy": true},
	{"id": "behind_flour", "at": Vector3(-2.0, FLOOR_TOP, -6.7), "heavy": true},
	{"id": "in_fridge", "at": Vector3(-0.9, 1.025, -0.2), "heavy": false},
	{"id": "under_counter", "at": Vector3(3.5, FLOOR_TOP + 0.05, 3.5), "heavy": true},
	{"id": "in_display", "at": Vector3(-1.5, FLOOR_TOP + 0.05, 4.5), "heavy": false},
	{"id": "on_mixer", "at": Vector3(0.9, 1.0, -6.0), "heavy": false},
	{"id": "on_wardrobe", "at": Vector3(7.5, GameScale.FLOOR_HEIGHT + 2.0, 3.0), "heavy": false},
	{"id": "in_chest", "at": Vector3(-1.2, GameScale.FLOOR_HEIGHT + 0.05, 6.3), "heavy": true},
	{"id": "bread_shelf", "at": Vector3(-7.55, 1.025, 4.0), "heavy": false},
	{"id": "under_kneading_table", "at": Vector3(4.0, FLOOR_TOP, -2.5), "heavy": true},
	{"id": "in_bathroom", "at": Vector3(-7.0, FLOOR_TOP, -6.3), "heavy": true},
	{"id": "under_bed", "at": Vector3(4.0, GameScale.FLOOR_HEIGHT, -3.5), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var bakehouse_door: FrontDoor
var back_door: FrontDoor
var city_map: CityMap
var baker: Baker
var customers: Array[BakeryCustomer] = []
var complaint_bar: ProgressBar
var _build: PlaceBuilder
var _customer_wait := FIRST_CUSTOMER
var _looks := 0
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_shop()
	_build_back_rooms()
	_build_flat()
	bakehouse_door = _door(Vector3(BAKEHOUSE_DOOR_X - GameScale.DOOR_WIDTH / 2, 0, SHOP_BACK), 0.0)
	back_door = _door(Vector3(BACK_DOOR_X + GameScale.DOOR_WIDTH / 2, 0, -HALF_Z), PI)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("bakery")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "bakery", car)
	_add_baker()


func _add_baker() -> void:
	baker = BAKER_SCENE.instantiate()
	baker.till_post = Vector3(5.0, FLOOR_TOP, 2.4)
	baker.door_post = Vector3(BAKEHOUSE_DOOR_X, FLOOR_TOP, SHOP_BACK + 0.7)
	baker.position = baker.door_post
	add_child(baker)
	for door: FrontDoor in [bakehouse_door, back_door]:
		door.broken.connect(func() -> void:
			baker.door_broken()
			scare_customers())
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
	baker.hurt.connect(scare_customers)
	baker.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


func _physics_process(delta: float) -> void:
	_customer_wait -= delta
	if _customer_wait <= 0.0 and customers.size() < MAX_CUSTOMERS:
		_customer_wait = CUSTOMER_EVERY
		add_customer()


## A customer walks in from the sidewalk to a free place at the counter and joins Marta's queue on arrival.
func add_customer() -> BakeryCustomer:
	var taken := customers.map(func(c: BakeryCustomer) -> float: return c.route[c.route.size() - 1].x)
	var slot: float = COUNTER_SLOTS.filter(func(x: float) -> bool: return not taken.has(x))[0]
	var customer: BakeryCustomer = CUSTOMER_SCENE.instantiate()
	var side := -1.0 if _looks % 2 == 0 else 1.0
	customer.route = [Vector3(ENTRANCE_X + side * 5.0, 0, SIDEWALK), Vector3(ENTRANCE_X, 0, SIDEWALK),
		Vector3(ENTRANCE_X, FLOOR_TOP, SHOP_LANE), Vector3(slot, FLOOR_TOP, SHOP_LANE),
		Vector3(slot, FLOOR_TOP, COUNTER_FRONT)]
	customer.position = customer.route[0]
	add_child(customer)
	customer.set_look(_looks)
	_looks += 1
	customers.append(customer)
	customer.arrived.connect(func() -> void: baker.queue.append(customer))
	customer.fled.connect(func() -> void:
		baker.queue.erase(customer)
		baker.customer_fled())
	customer.bumped.connect(scare_customers)
	customer.gone.connect(func() -> void: customers.erase(customer))
	return customer


## Everyone in the shop runs out without paying, and no one comes in for a while.
func scare_customers() -> void:
	_customer_wait = SCARE_PAUSE
	for customer in customers.duplicate():
		customer.scare()


func _door(at: Vector3, turn: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = at
	door.rotation.y = turn
	add_child(door)
	return door


## Floors, outer walls, the roof and the front: the entrance, the shop window with the shutter half up, the sign.
func _build_shell() -> void:
	var up := GameScale.FLOOR_HEIGHT
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, TILES)
	# Upstairs floor with the hole over the stairs, and the roof.
	# The hole is wider than the stairs, so a cop's head doesn't hit its edge, with a railing on its open side.
	var hole := Rect2(-HALF_X, STAIR_FOOT - STAIR_RUN, STAIR_X + GameScale.STAIR_WIDTH / 2 + 0.6 + HALF_X, STAIR_RUN)
	_build.slab(-HALF_X, hole.position.x, -HALF_Z, HALF_Z, up, FLOOR_WOOD)
	_build.slab(hole.end.x, HALF_X, -HALF_Z, HALF_Z, up, FLOOR_WOOD)
	_build.slab(hole.position.x, hole.end.x, -HALF_Z, hole.position.y, up, FLOOR_WOOD)
	_build.slab(hole.position.x, hole.end.x, hole.end.y, HALF_Z, up, FLOOR_WOOD)
	_build.box(Vector3(hole.end.x, up + 0.5, hole.get_center().y), Vector3(0.08, 1.0, STAIR_RUN), WHITE)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, up * 2, OUTSIDE.darkened(0.35))
	for level in 2:
		_build.wall("x", -HALF_Z, -HALF_X, HALF_X, level, [BACK_DOOR_X] if level == 0 else [], OUTSIDE)
		_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, level, [], OUTSIDE)
		_build.wall("z", HALF_X, -HALF_Z, HALF_Z, level, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 1, [], OUTSIDE)
	# Downstairs front: wall with the entrance, then the shop window from x = -1 to 7.
	var height := up - PlaceBuilder.SLAB
	_build.wall("x", HALF_Z, -HALF_X, -1.0, 0, [ENTRANCE_X], OUTSIDE)
	_build.box(Vector3(3.0, 0.45, HALF_Z), Vector3(8.0, 0.9, PlaceBuilder.WALL), OUTSIDE)
	_build.box(Vector3(3.0, 2.4, HALF_Z), Vector3(8.0, height - 2.3, PlaceBuilder.WALL), OUTSIDE)
	_build.box(Vector3(3.0, 1.6, HALF_Z), Vector3(8.0, 1.4, 0.04), GLASS)
	_build.box(Vector3(7.5, height / 2, HALF_Z), Vector3(1.0, height, PlaceBuilder.WALL), OUTSIDE)
	# The shutter, half up over the window and the entrance; an awning; the sign.
	_build.mesh_box(Vector3(3.0, 2.0, HALF_Z + 0.1), Vector3(8.0, 0.6, 0.05), SHUTTER)
	_build.mesh_box(Vector3(ENTRANCE_X, 2.0, HALF_Z + 0.1), Vector3(GameScale.DOOR_WIDTH, 0.2, 0.05), SHUTTER)
	_build.mesh_box(Vector3(0, 2.6, HALF_Z + 0.8), Vector3(HALF_X * 2 - 1, 0.1, 1.5), AWNING)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_BAKERY"
	sign_label.font_size = 72
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(-0.3, up + 1.5, HALF_Z + 0.12)
	$Built.add_child(sign_label)
	# Marta's windows upstairs, only for the look.
	for x: float in FLAT_WINDOWS:
		_build.mesh_box(Vector3(x, up + 1.4, HALF_Z + 0.09), Vector3(1.4, 1.2, 0.04), Color(GLASS, 1.0))
		_build.mesh_box(Vector3(x, up + 0.75, HALF_Z + 0.15), Vector3(1.6, 0.08, 0.16), WHITE)


## The shop: counter (open on Marta's side) with the till, the cake display, the bread shelves on the west wall.
func _build_shop() -> void:
	_build.wall("x", SHOP_BACK, -HALF_X, HALF_X, 0, [BAKEHOUSE_DOOR_X], INSIDE)
	_build.open_box(Vector3(3.5, FLOOR_TOP, 3.5), Vector3(5.0, 1.0, 0.7), "-z", WOOD)
	_build.box(Vector3(5.2, 1.15, 3.5), Vector3(0.5, 0.3, 0.4), STEEL)
	_build.open_box(Vector3(-1.5, FLOOR_TOP, 4.5), Vector3(2.0, 1.1, 0.8), "top", GLASS)
	for x: float in [-2.1, -1.5, -0.9]:
		var cake := CylinderMesh.new()
		cake.top_radius = 0.22
		cake.bottom_radius = 0.22
		cake.height = 0.25
		_build.mesh(cake, Vector3(x, FLOOR_TOP + 0.18, 4.5), CAKE)
	for y: float in [0.4, 1.0, 1.6]:
		_build.box(Vector3(-7.55, y, 4.0), Vector3(0.6, 0.05, 4.0), WOOD)
		for z: float in [2.6, 3.4, 4.2, 5.0]:
			_build.mesh(_loaf(), Vector3(-7.55, y + 0.12, z), BREAD, Vector3(0, 0, PI / 2))
	_build.light(Vector3(0, 2.2, 4.0))
	_build.light(Vector3(-5, 2.2, 4.0))


## The bakehouse (east): oven, kneading table and mixer. The storeroom (west): flour sacks, fridge, the stairs up,
## and the bathroom in its corner.
func _build_back_rooms() -> void:
	_build.wall("z", STORE_EAST, -HALF_Z, SHOP_BACK, 0, [-3.0], BAKEHOUSE)
	_build.open_box(Vector3(6.8, FLOOR_TOP, -5.6), Vector3(2.4, 1.6, 1.6), "+z", STEEL)
	_build.legs(Vector3(4.0, 0, -2.5), Vector2(2.4, 0.9), 0.85, WOOD)
	_build.box(Vector3(4.0, 0.88, -2.5), Vector3(2.4, 0.06, 0.9), WOOD)
	_build.box(Vector3(0.9, 0.5, -6.0), Vector3(0.8, 1.0, 0.8), WHITE)
	for i in 4:
		_build.box(Vector3(-3.2 + i * 0.65, 0.18, -6.0), Vector3(0.6, 0.35, 0.9), FLOUR)
	_build.box(Vector3(-2.9, 0.53, -6.0), Vector3(0.6, 0.35, 0.9), FLOUR)
	_build.open_box(Vector3(-0.9, FLOOR_TOP, -0.2), Vector3(0.9, 2.0, 0.8), "-x", WHITE)
	_build.box(Vector3(-0.9, 1.0, -0.2), Vector3(0.8, 0.05, 0.7), WHITE)
	_build.stairs(Vector3(STAIR_X, 0, STAIR_FOOT), STAIR_RUN, WOOD)
	_build.wall("x", -4.5, -HALF_X, -5.5, 0, [], INSIDE)
	_build.wall("z", -5.5, -HALF_Z, -4.5, 0, [-5.75], INSIDE)
	_build.box(Vector3(-7.4, 0.2, -6.3), Vector3(0.45, 0.4, 0.6), WHITE)
	_build.light(Vector3(4.0, 2.2, -3.0))
	_build.light(Vector3(-3.0, 2.2, -3.0))
	_build.light(Vector3(-6.8, 2.2, -5.8))


## Marta's flat: living room (west) and bedroom (east), each with a window over the street.
func _build_flat() -> void:
	var up := GameScale.FLOOR_HEIGHT
	_build.wall("z", STORE_EAST, -HALF_Z, HALF_Z, 1, [3.0], FLAT)
	_build.legs(Vector3(4.0, up, -3.5), Vector2(1.5, 2.1), 0.34, WOOD)
	_build.box(Vector3(4.0, up + 0.37, -3.5), Vector3(1.5, 0.06, 2.1), WOOD)
	_build.box(Vector3(4.0, up + 0.5, -3.5), Vector3(1.4, 0.2, 2.0), WHITE)
	_build.open_box(Vector3(7.5, up, 3.0), Vector3(0.8, 2.0, 1.2), "-x", WOOD)
	_build.box(Vector3(-4.0, up + 0.25, 5.8), Vector3(2.2, 0.5, 0.8), Color(0.5, 0.35, 0.6))
	_build.open_box(Vector3(-1.2, up, 6.3), Vector3(1.0, 0.6, 0.6), "top", WOOD)
	_build.legs(Vector3(-4.0, up, 2.0), Vector2(1.2, 1.2), 0.72, WOOD)
	_build.box(Vector3(-4.0, up + 0.75, 2.0), Vector3(1.2, 0.06, 1.2), WOOD)
	_build.light(Vector3(-4.0, up + 2.2, 0.0))
	_build.light(Vector3(4.0, up + 2.2, 0.0))


func _loaf() -> Mesh:
	var loaf := CapsuleMesh.new()
	loaf.radius = 0.1
	loaf.height = 0.35
	return loaf
