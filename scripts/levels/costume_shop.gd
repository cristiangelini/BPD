class_name CostumeShop
extends Node3D

## The costume shop "Disfraces El Bigote Postizo" as a place to raid (docs/diseno/allanamiento-disfraces.md, step 1):
## a shop on its lot in the city, open and with the front to +Z. The counter stands by the door on the east side, with
## the office's key in its till; five racks of costumes fill the middle, the three fitting rooms with their curtains
## and the giant mirror stand along the west wall and the mask display case against the east one. The stock room is
## the open back of the shop, with its shelves and boxes, and the owner's office is in the back east corner, locked,
## with the desk and the little safe. The giant mirror breaks if something hits it fast and the display case if
## something thrown hits it, a fine each. Every number here is (propuesta).

## A mannequin ended up on the floor, and a customer complained (Don Fantoche adds it to the complaint, step 3).
signal mannequin_fell(mannequin: CostumeMannequin)
signal customer_complained(customer: CostumeCustomer)
signal mirror_broken
signal mask_case_broken

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const COUNTER_MODEL := preload("res://assets/models/costume_counter.glb")
const RACK_MODELS: Array[PackedScene] = [preload("res://assets/models/rack_pirates.glb"),
	preload("res://assets/models/rack_animals.glb"), preload("res://assets/models/rack_monsters.glb"),
	preload("res://assets/models/rack_princesses.glb"), preload("res://assets/models/rack_trades.glb")]
const CURTAIN_MODEL := preload("res://assets/models/fitting_curtain.glb")
const MIRROR_MODEL := preload("res://assets/models/giant_mirror.glb")
const CASE_MODEL := preload("res://assets/models/mask_case.glb")
const SHELF_MODEL := preload("res://assets/models/stock_shelf.glb")
const PILE_MODEL := preload("res://assets/models/box_pile.glb")
const TRUNK_MODEL := preload("res://assets/models/wig_trunk.glb")
const BASKET_MODEL := preload("res://assets/models/sale_basket.glb")
const SAFE_MODEL := preload("res://assets/models/costume_safe.glb")
const MUSTACHE_MODEL := preload("res://assets/models/giant_mustache.glb")
const HALF_X := 12.0
const HALF_Z := 10.0
const WALL_TOP := 4.5
const BUILDING_TOP := 6.0
const FLOOR_TOP := 0.06
## The open doorway in the middle of the front wall.
const ENTRANCE_X := 0.0
const ENTRANCE_WIDTH := 3.5
const ENTRANCE_HEIGHT := 3.0

## The counter by the door (its till holds the office's key).
const COUNTER_AT := Vector3(7.0, FLOOR_TOP, 6.5)
const COUNTER_SIZE := Vector3(3.5, 1.0, 0.8)
const TILL_ON := Vector3(5.8, FLOOR_TOP + 1.02, 6.5)
## The racks of costumes (pirates, animals, monsters, princesses, trades), each 3 m long along X.
const RACKS: Array[Vector3] = [Vector3(-5.0, FLOOR_TOP, -2.0), Vector3(-1.0, FLOOR_TOP, -2.0),
	Vector3(3.0, FLOOR_TOP, -2.0), Vector3(-5.0, FLOOR_TOP, 2.5), Vector3(-1.0, FLOOR_TOP, 2.5)]
const RACK_SIZE := Vector3(3.0, 1.7, 0.6)
## The three fitting rooms along the west wall, each from the wall (x = -HALF_X) to its curtain (FITTING_X), their
## middles along Z.
const FITTING_X := -9.5
const FITTING_Z: Array[float] = [-3.5, -0.5, 2.5]
const FITTING_DEPTH := 3.0
const FITTING_TOP := 2.6
## The giant mirror on the west wall, past the fitting rooms, and what breaks it.
const MIRROR_AT := Vector3(-HALF_X + PlaceBuilder.WALL / 2 + 0.04, 1.5, 6.5)
const MIRROR_SIZE := Vector3(0.4, 2.4, 3.0)
const MIRROR_SPEED := 3.0
const MIRROR_FINE := 30
## The mask display case against the east wall, its glass to -X, and what breaks it.
const CASE_AT := Vector3(HALF_X - 0.5, FLOOR_TOP, 1.0)
const CASE_SIZE := Vector3(0.8, 1.8, 2.4)
const CASE_SPEED := 3.0
const CASE_FINE := 15
## The stock room: the open back of the shop, with its shelves on the back wall and a pile of boxes.
const STOCK_Z := -6.5
const SHELVES_X: Array[float] = [-6.0, -3.0, 2.5]
const SHELF_Z := -9.6
const SHELF_SIZE := Vector3(2.0, 2.2, 0.6)
const PILE_AT := Vector3(-0.3, FLOOR_TOP, -8.6)
## The wig trunk by the mirror and the sale basket by the door.
const TRUNK_AT := Vector3(-7.5, FLOOR_TOP, 6.8)
const BASKET_AT := Vector3(-2.5, FLOOR_TOP, 7.5)
## The office in the back east corner, its door in its front wall (OFFICE_Z), with the desk and the little safe.
## The 8 mannequins in costume: a row between the racks, 1.5 m apart so one falling knocks the next, and two by the
## front racks.
const MANNEQUINS: Array[Vector3] = [Vector3(-6.5, FLOOR_TOP, 0.75), Vector3(-5.0, FLOOR_TOP, 0.75),
	Vector3(-3.5, FLOOR_TOP, 0.75), Vector3(-2.0, FLOOR_TOP, 0.75), Vector3(-0.5, FLOOR_TOP, 0.75),
	Vector3(1.0, FLOOR_TOP, 0.75), Vector3(2.5, FLOOR_TOP, 2.6), Vector3(4.0, FLOOR_TOP, 2.6)]
const MANNEQUIN_LOOKS := ["pirate", "chicken", "astronaut", "vampire"]
## The 4 customers look at the front racks and walk to the fitting rooms along the front aisle and the west aisle;
## the next one goes this long after the last is back.
const CUSTOMER_HOMES: Array[Vector3] = [Vector3(-5.8, FLOOR_TOP, 3.7), Vector3(-4.0, FLOOR_TOP, 3.7),
	Vector3(-1.8, FLOOR_TOP, 3.7), Vector3(-0.2, FLOOR_TOP, 3.7)]
const CUSTOMER_LOOKS := ["cliente", "clienta", "vecina", "invitado"]
const AISLE_Z := 5.6
const AISLE_X := -8.5
const TURN_GAP := 4.0
const FIRST_TURN := 3.0

const OFFICE_X := 8.0
const OFFICE_Z := -4.5
const OFFICE_DOOR_X := 10.0
const DESK_AT := Vector3(9.6, FLOOR_TOP, -9.0)
const DESK_SIZE := Vector3(1.8, 0.8, 0.9)
const SAFE_AT := Vector3(11.3, FLOOR_TOP, -9.3)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_stock_boxes", "at": Vector3(-1.6, FLOOR_TOP, -8.8), "heavy": true},
	{"id": "by_stock_shelf", "at": Vector3(2.5, FLOOR_TOP, -8.6), "heavy": true},
	{"id": "in_dinosaur_costume", "at": Vector3(3.0, FLOOR_TOP, -2.9), "heavy": true},
	{"id": "behind_costume_counter", "at": Vector3(8.0, FLOOR_TOP, 5.6), "heavy": true},
	{"id": "in_costume_office_corner", "at": Vector3(11.2, FLOOR_TOP, -5.4), "heavy": true},
	{"id": "by_wig_trunk", "at": Vector3(-6.4, FLOOR_TOP, 6.8), "heavy": true},
	{"id": "in_fitting_room_1", "at": Vector3(-11.0, FLOOR_TOP, -3.5), "heavy": false},
	{"id": "behind_pirate_rack", "at": Vector3(-5.0, FLOOR_TOP, -2.9), "heavy": false},
	{"id": "in_sale_basket", "at": Vector3(-2.5, FLOOR_TOP + 0.4, 7.5), "heavy": false},
	{"id": "under_costume_desk", "at": Vector3(9.6, FLOOR_TOP, -9.0), "heavy": false},
	{"id": "behind_costume_safe", "at": Vector3(10.4, FLOOR_TOP, -9.5), "heavy": false},
	{"id": "on_mask_case", "at": Vector3(HALF_X - 0.5, FLOOR_TOP + CASE_SIZE.y, 1.0), "heavy": false},
]

const OUTSIDE := Color(0.95, 0.55, 0.2)
const FLOOR := Color(0.62, 0.46, 0.34)
const CEILING := Color(0.92, 0.9, 0.86)
const WALLS := Color(0.98, 0.86, 0.6)
const FITTING := Color(0.75, 0.3, 0.45)
const OFFICE := Color(0.85, 0.78, 0.62)
const WOOD := Color(0.5, 0.36, 0.26)
const DARK := Color(0.1, 0.1, 0.12)
const GLASS := Color(0.75, 0.88, 0.95)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
var mannequins: Array[CostumeMannequin] = []
var customers: Array[CostumeCustomer] = []
## The customer whose turn it is (null between turns), the next one in line and how long until they go.
var on_turn: CostumeCustomer
var _next_customer := 0
var _turn_left := FIRST_TURN
var mirror_cracked := false
var case_broken := false
## Money taken off the case pay: the mirror and the display case.
var fines := 0
## Same seed, same shop (the stories and the hiding spots come from it, step 5).
@export var case_seed := 0
var _build: PlaceBuilder
var _case_glass: Node3D
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_counter()
	_build_racks()
	_build_fitting_rooms()
	_build_fragile()
	_build_stock()
	_build_office()
	office_door = _door(OFFICE_DOOR_X)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("costume_shop")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "costume_shop", car)
	# The loose mannequins once the cop is out at the station, not standing in them.
	_build_mannequins()
	_build_customers()


## The wooden floor, the walls with the doorway, the ceiling with its lights, the roof, the sign and its mustache.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, CEILING)
	var x0 := ENTRANCE_X - ENTRANCE_WIDTH / 2
	var x1 := ENTRANCE_X + ENTRANCE_WIDTH / 2
	_build.wall_at("x", HALF_Z, -HALF_X, x0, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x1, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x0, x1, ENTRANCE_HEIGHT, WALL_TOP - ENTRANCE_HEIGHT, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], WALLS)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], WALLS)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], WALLS)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_label("PLACE_COSTUME_SHOP", Vector3(-5.0, WALL_TOP + 0.6, HALF_Z + 0.08), 96)
	_label("COSTUME_MOTTO", Vector3(-5.0, ENTRANCE_HEIGHT + 0.6, HALF_Z + 0.08), 60)
	_model(MUSTACHE_MODEL, Vector3(6.0, BUILDING_TOP + 0.6, HALF_Z - 0.6))
	for x: float in [-8.0, -3.0, 2.0, 7.0]:
		for z: float in [-7.0, -2.0, 3.0, 7.5]:
			_build.light(Vector3(x, 4.1, z)).light_energy = 1.2


## The counter by the door with its till.
func _build_counter() -> void:
	_solid(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0), COUNTER_SIZE)
	_model(COUNTER_MODEL, COUNTER_AT)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_COSTUME"
	add_child(till)


## The five racks of costumes, the wig trunk and the sale basket.
func _build_racks() -> void:
	for i in RACKS.size():
		_solid(RACKS[i] + Vector3(0, RACK_SIZE.y / 2, 0), RACK_SIZE)
		_model(RACK_MODELS[i], RACKS[i])
		_label("COSTUME_RACK_%d" % (i + 1), RACKS[i] + Vector3(0, RACK_SIZE.y + 0.35, 0), 36, 0.0, 0.008)
	_solid(TRUNK_AT + Vector3(0, 0.25, 0), Vector3(1.0, 0.5, 0.6))
	_model(TRUNK_MODEL, TRUNK_AT)
	_solid(BASKET_AT + Vector3(0, 0.2, 0), Vector3(0.8, 0.4, 0.6))
	_model(BASKET_MODEL, BASKET_AT)


## The three fitting rooms along the west wall: their walls, a curtain each and the number over the doorway.
func _build_fitting_rooms() -> void:
	var z0 := FITTING_Z[0] - FITTING_DEPTH / 2
	var z1 := FITTING_Z[FITTING_Z.size() - 1] + FITTING_DEPTH / 2
	_build.wall_at("z", FITTING_X, z0, z1, 0.0, FITTING_TOP, Array(FITTING_Z), FITTING)
	for z: float in [z0, z1] + FITTING_Z.slice(0, FITTING_Z.size() - 1).map(func(mid: float) -> float:
			return mid + FITTING_DEPTH / 2):
		_build.wall_at("x", z, -HALF_X, FITTING_X, 0.0, FITTING_TOP, [], FITTING)
	for i in FITTING_Z.size():
		_model(CURTAIN_MODEL, Vector3(FITTING_X + 0.1, FLOOR_TOP, FITTING_Z[i]))
		_label("COSTUME_FITTING_%d" % (i + 1), Vector3(FITTING_X + 0.08, GameScale.DOOR_HEIGHT + 0.25, FITTING_Z[i]), 28,
			PI / 2)


## The giant mirror and the mask display case, each with what breaks it.
func _build_fragile() -> void:
	_model(MIRROR_MODEL, MIRROR_AT)
	var mirror_hit := _area(MIRROR_AT + Vector3(MIRROR_SIZE.x / 2, 0, 0), MIRROR_SIZE)
	mirror_hit.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > MIRROR_SPEED:
			break_mirror())
	_solid(CASE_AT + Vector3(0, CASE_SIZE.y / 2, 0), CASE_SIZE)
	_case_glass = _model(CASE_MODEL, CASE_AT)
	var case_hit := _area(CASE_AT + Vector3(-CASE_SIZE.x / 2 - 0.2, CASE_SIZE.y / 2, 0), Vector3(0.4, CASE_SIZE.y,
		CASE_SIZE.z))
	case_hit.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > CASE_SPEED:
			break_mask_case())


## The stock room at the back: its shelves, the pile of boxes and its sign.
func _build_stock() -> void:
	for x: float in SHELVES_X:
		var at := Vector3(x, FLOOR_TOP, SHELF_Z)
		_solid(at + Vector3(0, SHELF_SIZE.y / 2, 0), SHELF_SIZE)
		_model(SHELF_MODEL, at)
	_solid(PILE_AT + Vector3(0, 0.65, 0), Vector3(1.2, 1.3, 0.6))
	_model(PILE_MODEL, PILE_AT)
	_label("COSTUME_STOCK_SIGN", Vector3(-1.5, 3.2, -HALF_Z + 0.1), 48)
	# A strip on the floor marks where the stock room starts.
	_build.mesh_box(Vector3(-2.0, FLOOR_TOP + 0.005, STOCK_Z), Vector3(19.0, 0.01, 0.1), Color(0.95, 0.8, 0.2))


## The owner's office: its walls, the locked door, the desk and the little safe.
func _build_office() -> void:
	_build.wall_at("x", OFFICE_Z, OFFICE_X, HALF_X, 0.0, WALL_TOP, [OFFICE_DOOR_X], OFFICE)
	_build.wall_at("z", OFFICE_X, -HALF_Z, OFFICE_Z, 0.0, WALL_TOP, [], OFFICE)
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.04, DARK)
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.02, 0), Vector3(DESK_SIZE.x, 0.04, DESK_SIZE.z), WOOD)
	_solid(SAFE_AT + Vector3(0, 0.3, 0), Vector3(0.6, 0.6, 0.6))
	_model(SAFE_MODEL, SAFE_AT)


## Something hit the giant mirror hard, once: a fine and the cracks all over it.
func break_mirror() -> void:
	if mirror_cracked:
		return
	mirror_cracked = true
	fines += MIRROR_FINE
	for i in 6:
		_build.mesh_box(MIRROR_AT + Vector3(0.07, -0.8 + (i % 3) * 0.7, -1.0 + i * 0.4), Vector3(0.01, 0.03, 1.2),
			Color(0.35, 0.38, 0.42))
	_say(MIRROR_AT + Vector3(0.8, 1.6, 0), "COSTUME_MIRROR_BROKEN")
	mirror_broken.emit()


## Something thrown broke the mask display case, once: a fine, no glass and its masks on the floor in front of it.
func break_mask_case() -> void:
	if case_broken:
		return
	case_broken = true
	fines += CASE_FINE
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed
	for i in 8:
		var at := Vector3(CASE_AT.x - 1.0 + rng.randf_range(-0.4, 0.4), FLOOR_TOP + 0.01, CASE_AT.z + rng.randf_range(-1.1, 1.1))
		_build.mesh_box(at, Vector3(0.18, 0.02, 0.22), [Color(0.96, 0.94, 0.88), Color(0.85, 0.22, 0.2),
			Color(0.25, 0.65, 0.4)][i % 3])
	_build.mesh_box(CASE_AT + Vector3(-CASE_SIZE.x / 2 - 0.02, 1.1, 0), Vector3(0.02, 1.2, 2.3), DARK)
	_say(CASE_AT + Vector3(-1.0, 2.2, 0), "COSTUME_CASE_BROKEN")
	mask_case_broken.emit()


## The 8 mannequins, each one a loose body, facing the door.
func _build_mannequins() -> void:
	for i in MANNEQUINS.size():
		var mannequin := CostumeMannequin.new()
		mannequin.name = "Mannequin%d" % (i + 1)
		mannequin.look = MANNEQUIN_LOOKS[i % MANNEQUIN_LOOKS.size()]
		mannequin.position = MANNEQUINS[i]
		add_child(mannequin)
		mannequin.fell.connect(_on_mannequin_fell)
		mannequins.append(mannequin)


## The 4 customers, each in front of a rack.
func _build_customers() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["costume customers", case_seed])
	for i in CUSTOMER_HOMES.size():
		var customer := CostumeCustomer.new()
		customer.name = "Customer%d" % (i + 1)
		customer.look = CUSTOMER_LOOKS[i % CUSTOMER_LOOKS.size()]
		customer.shop = self
		customer.home = CUSTOMER_HOMES[i]
		customer.position = customer.home
		customer.rng.seed = rng.randi()
		add_child(customer)
		customer.complained.connect(customer_complained.emit)
		customer.turn_over.connect(func(_done: CostumeCustomer) -> void:
			on_turn = null
			_turn_left = TURN_GAP)
		customers.append(customer)


func _on_mannequin_fell(mannequin: CostumeMannequin) -> void:
	for customer in customers:
		customer.near_fall(mannequin.middle())
	mannequin_fell.emit(mannequin)


## The way from `from` to the front of fitting room `index` (shop space): out to the front aisle, along it to the west
## aisle, up it to the fitting room and in front of its curtain.
func aisle_path(from: Vector3, index: int) -> Array:
	var z := FITTING_Z[index]
	return [Vector3(from.x, FLOOR_TOP, AISLE_Z), Vector3(AISLE_X, FLOOR_TOP, AISLE_Z), Vector3(AISLE_X, FLOOR_TOP, z),
		Vector3(FITTING_X + 0.8, FLOOR_TOP, z)]


## Where a customer stands inside fitting room `index` (shop space).
func fitting_inside(index: int) -> Vector3:
	return Vector3((FITTING_X - HALF_X) / 2, FLOOR_TOP, FITTING_Z[index])


## Whether a cop is inside fitting room `index`.
func cop_in_fitting(index: int) -> bool:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var at := to_local(cop.global_position)
		if at.x < FITTING_X and absf(at.z - FITTING_Z[index]) < FITTING_DEPTH / 2:
			return true
	return false


## Between turns the next customer in line goes to the next fitting room.
func _physics_process(delta: float) -> void:
	if on_turn:
		return
	_turn_left -= delta
	if _turn_left > 0.0:
		return
	on_turn = customers[_next_customer % customers.size()]
	on_turn.start_turn(_next_customer % FITTING_Z.size())
	_next_customer += 1


## A locked door in the office's front wall, its middle at x.
func _door(x: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(x - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_Z)
	add_child(door)
	return door


## A box only to bump into, under a model that gives the look.
func _solid(center: Vector3, size: Vector3) -> StaticBody3D:
	var body := _build.body(center)
	_build.shape(body, size)
	return body


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
func _say(at: Vector3, key: String, seconds := 3.0) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(seconds).timeout.connect(label.queue_free)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
