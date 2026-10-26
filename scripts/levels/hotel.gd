class_name Hotel
extends CrimeScenePlace

## The city's hotel (escena-hotel.md, step 1, decision 201), the Hotel Gran Siesta on its lot with the front to +Z.
## Downstairs: the lobby with its armchairs, the Golden Pillow's case and the reception desk (the bell, the guest book
## and the key board behind it), the broken lift and the stairs; west of it, the dining room with the piano. Upstairs:
## the long corridor with the guests' six rooms (11, 12, 14, 15, 16 and 17: the hotel skips the 13), the suite at its
## west end, where the theft was, and behind an old wardrobe in the corridor, the room with no number: the 13. The
## six guests alike wait in the lobby, don Bostezo behind the desk, señora Perlita by the armchairs, Tito the bellboy
## by the door and doña Escoba upstairs with her cart (step 2). The case comes in step 4. Every number here is
## (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(26, 18)
const HALF_X := 13.0
const BACK_Z := -9.0
## The front wall; the awning over the door reaches the lot's edge.
const FRONT_Z := 7.0
const FLOOR_TOP := 0.06
## The top of the upstairs floor and of the roof over it; above it the upper storeys are shut.
const UP := GameScale.FLOOR_HEIGHT + FLOOR_TOP
const ROOF := GameScale.FLOOR_HEIGHT * 2
const TALL := 18.0
## Downstairs: the wall between the dining room (west) and the lobby.
const DINING_X := -5.0
const DOOR_FRONT_X := 0.0
const DOOR_DINING_Z := 2.0
## The stairs climb north along -Z on the lobby's east side, from STAIR_FOOT_Z to STAIR_TOP_Z.
const STAIR_X := 10.0
const STAIR_RUN := 3.75
const STAIR_FOOT_Z := 5.5
const STAIR_TOP_Z := STAIR_FOOT_Z - STAIR_RUN
## The hole upstairs over the stairs: wider than them and long enough that a cop's head doesn't hit its edge.
const HOLE_HALF_X := 0.8
const HOLE_SOUTH_Z := 5.0
## Upstairs: the corridor between z = -CORRIDOR and CORRIDOR, from the suite's wall to the east wall.
const CORRIDOR := 1.0
const SUITE_X := -7.0
const DOOR_SUITE_Z := 0.0
## The suite's own bathroom, in its north-west corner.
const SUITE_BATH_X := -10.0
const SUITE_BATH_Z := -5.0
const DOOR_SUITE_BATH_Z := -6.5
## The rooms off the corridor: from x0 to x1, on its north ("n") or south ("s") side, with the door at `door`.
## The 13 is the one without a number on its door, behind the wardrobe.
const ROOMS := {
	11: {"x0": -7.0, "x1": -2.5, "side": "n", "door": -4.75},
	12: {"x0": -2.5, "x1": 2.0, "side": "n", "door": -0.25},
	13: {"x0": 2.0, "x1": 5.0, "side": "n", "door": 3.5},
	14: {"x0": 5.0, "x1": 9.0, "side": "n", "door": 7.0},
	15: {"x0": 9.0, "x1": 13.0, "side": "n", "door": 11.0},
	16: {"x0": -7.0, "x1": -1.5, "side": "s", "door": -4.25},
	17: {"x0": -1.5, "x1": 4.0, "side": "s", "door": 1.25},
}
## The guests' rooms, in order: one per guest (step 3 draws who sleeps in each).
const GUEST_ROOMS: Array[int] = [11, 12, 14, 15, 16, 17]
const HIDDEN_ROOM := 13
## The wardrobe stands against the corridor's north wall over the 13's door; a cop drags it away (Grabbable).
const WARDROBE_AT := Vector3(3.5, UP, -CORRIDOR + 0.35)
const WARDROBE_SIZE := Vector3(1.6, 2.0, 0.6)
const WARDROBE_KG := 28.0
## The lobby: the reception desk against the back wall with the key board behind it, the bell and the guest book on
## it; the Golden Pillow's glass case, two armchairs, the plastic plant and the lift's doors.
const DESK_AT := Vector3(0.0, 0, -6.5)
const DESK_SIZE := Vector3(3.0, 1.05, 0.7)
const KEY_BOARD_AT := Vector3(0.0, 1.7, BACK_Z + 0.1)
const BELL_AT := DESK_AT + Vector3(0.9, DESK_SIZE.y, 0.1)
const BOOK_AT := DESK_AT + Vector3(-0.6, DESK_SIZE.y, 0.1)
const CASE_AT := Vector3(-2.5, 0, -6.0)
const ARMCHAIRS: Array[Vector3] = [Vector3(-2.5, 0, 4.0), Vector3(2.5, 0, 4.0)]
const PLANT_AT := Vector3(-4.2, 0, 6.2)
const LIFT_AT := Vector3(8.0, 0, BACK_Z + 0.1)
## The dining room: the piano and the tables.
const PIANO_AT := Vector3(-11.0, 0, -6.5)
const TABLES: Array[Vector3] = [Vector3(-10.0, 0, 0.0), Vector3(-8.0, 0, 4.0), Vector3(-11.5, 0, 4.5)]
## The suite: the big bed, the safe in the wall (where the theft was) and the bathtub in its bathroom.
const SUITE_BED_AT := Vector3(-10.0, UP, 4.5)
const SAFE_AT := Vector3(-HALF_X + 0.2, UP + 1.0, 0.5)
const TUB_AT := Vector3(-11.6, UP, -7.5)
## Where the people stand: the six guests in a row in the lobby facing the front door, the concierge behind the desk,
## señora Perlita by the armchairs, Tito by the front door and the maid in the corridor upstairs, pushing her cart west.
const GUESTS_AT: Array[Vector3] = [
	Vector3(-3.5, 0, -1.5), Vector3(-2.2, 0, -1.5), Vector3(-0.9, 0, -1.5), Vector3(0.4, 0, -1.5), Vector3(1.7, 0, -1.5),
	Vector3(3.0, 0, -1.5),
]
const CONCIERGE_AT := Vector3(0.0, 0, -7.6)
const PERLITA_AT := Vector3(4.5, 0, 2.5)
const BELLBOY_AT := Vector3(1.8, 0, 5.8)
const MAID_AT := Vector3(7.5, UP, 0.0)
## The awning over the front door.
const AWNING_DEPTH := 2.0
const BRICK := Color(0.85, 0.5, 0.45)
const INSIDE := Color(0.93, 0.86, 0.72)
const CARPET := Color(0.62, 0.12, 0.14)
const WOOD := Color(0.5, 0.33, 0.2)
const SHEETS := Color(0.95, 0.95, 0.92)
const BRASS := Color(0.85, 0.68, 0.3)
const METAL := Color(0.55, 0.58, 0.62)
const TILE := Color(0.75, 0.88, 0.92)
const GLASS := Color(0.75, 0.9, 1.0, 0.35)
const PLANT := Color(0.25, 0.6, 0.3)
const WINDOW := Color(0.35, 0.45, 0.6)
const FLOORBOARDS := Color(0.55, 0.38, 0.25)

## The wardrobe that hides the 13.
var wardrobe: Grabbable
var guests: Array[HotelGuest] = []
var concierge: HotelStaff
var perlita: HotelStaff
var bellboy: HotelStaff
var maid: HotelStaff
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("hotel")
	variant = "hotel"
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_downstairs()
	_lobby()
	_dining()
	_stairs()
	_upstairs()
	_rooms()
	_suite()
	_wardrobe()
	_people()


## The guest by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return guests[index] if index >= 0 and index < guests.size() else null


## Whether a point in the world (ignoring height) is on the hotel's lot, under the awning included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the building.
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## Which floor a point in the world is on: 0 downstairs, 1 upstairs.
func floor_of(world: Vector3) -> int:
	return 1 if to_local(world).y > UP - 0.5 else 0


## The room a point in the world is in, by number (the suite is 0 and anywhere else -1). Only upstairs.
func room_of(world: Vector3) -> int:
	var local := to_local(world)
	if floor_of(world) != 1 or not inside(world):
		return -1
	if local.x < SUITE_X:
		return 0
	for number: int in ROOMS:
		var room: Dictionary = ROOMS[number]
		var z0 := BACK_Z if room.side == "n" else CORRIDOR
		var z1 := -CORRIDOR if room.side == "n" else FRONT_Z
		if local.x > room.x0 and local.x < room.x1 and local.z > z0 and local.z < z1:
			return number
	return -1


## The middle of a room's floor, in the hotel's space.
static func room_middle(number: int) -> Vector3:
	var room: Dictionary = ROOMS[number]
	var z := (BACK_Z - CORRIDOR) / 2 if room.side == "n" else (CORRIDOR + FRONT_Z) / 2
	return Vector3((room.x0 + room.x1) / 2, UP, z)


## The six guests alike in the lobby and the staff: the concierge, señora Perlita, Tito and the maid with her cart.
func _people() -> void:
	for i in GUESTS_AT.size():
		var guest := HotelGuest.new()
		guest.name = "Guest%d" % i
		guest.index = i
		guest.position = GUESTS_AT[i] + Vector3(0, FLOOR_TOP, 0)
		add_child(guest)
		guests.append(guest)
	concierge = _staff("concierge", CONCIERGE_AT + Vector3(0, FLOOR_TOP, 0), 0.0)
	perlita = _staff("perlita", PERLITA_AT + Vector3(0, FLOOR_TOP, 0), -0.4)
	bellboy = _staff("bellboy", BELLBOY_AT + Vector3(0, FLOOR_TOP, 0), PI)
	maid = _staff("maid", MAID_AT, -PI / 2.0)


func _staff(who: String, at: Vector3, turn: float) -> HotelStaff:
	var person := HotelStaff.new()
	person.who = who
	person.name = who.capitalize()
	person.position = at
	person.rotation.y = turn
	add_child(person)
	return person


## The floor, the upper storeys shut over the roof, the outer walls on both floors with the front door, and windows.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, CARPET.darkened(0.2))
	_builder.box(Vector3(0, (ROOF + TALL) / 2, (BACK_Z + FRONT_Z) / 2), Vector3(SIZE.x, TALL - ROOF, FRONT_Z - BACK_Z),
		BRICK)
	for level in 2:
		_builder.wall("x", BACK_Z, -HALF_X, HALF_X, level, [], INSIDE)
		_builder.wall("x", FRONT_Z, -HALF_X, HALF_X, level, [DOOR_FRONT_X] if level == 0 else [], INSIDE)
		_builder.wall("z", -HALF_X, BACK_Z, FRONT_Z, level, [], INSIDE)
		_builder.wall("z", HALF_X, BACK_Z, FRONT_Z, level, [], INSIDE)
	# Brick on the outside of the two floors, around the front door.
	var skin := 0.02
	var out := PlaceBuilder.WALL / 2 + skin / 2
	var door_left := DOOR_FRONT_X - GameScale.DOOR_WIDTH / 2
	var door_right := DOOR_FRONT_X + GameScale.DOOR_WIDTH / 2
	_builder.mesh_box(Vector3((-HALF_X + door_left) / 2, ROOF / 2, FRONT_Z + out),
		Vector3(door_left + HALF_X, ROOF, skin), BRICK)
	_builder.mesh_box(Vector3((HALF_X + door_right) / 2, ROOF / 2, FRONT_Z + out),
		Vector3(HALF_X - door_right, ROOF, skin), BRICK)
	_builder.mesh_box(Vector3(DOOR_FRONT_X, (ROOF + GameScale.DOOR_HEIGHT) / 2, FRONT_Z + out),
		Vector3(GameScale.DOOR_WIDTH, ROOF - GameScale.DOOR_HEIGHT, skin), BRICK)
	_builder.mesh_box(Vector3(0, ROOF / 2, BACK_Z - out), Vector3(SIZE.x, ROOF, skin), BRICK)
	for side: float in [-1.0, 1.0]:
		_builder.mesh_box(Vector3(side * (HALF_X + out), ROOF / 2, (BACK_Z + FRONT_Z) / 2),
			Vector3(skin, ROOF, FRONT_Z - BACK_Z), BRICK)
	# The upper storeys' windows, only for the look.
	for row in range(1, 6):
		for x: float in [-10.0, -6.0, -2.0, 2.0, 6.0, 10.0]:
			_builder.mesh_box(Vector3(x, row * GameScale.FLOOR_HEIGHT + 1.4, FRONT_Z + 0.09), Vector3(1.2, 1.2, 0.04),
				WINDOW)


## The red awning over the front door on two brass poles, and the sign over it.
func _front() -> void:
	var depth := SIZE.y / 2 - FRONT_Z
	_builder.mesh_box(Vector3(DOOR_FRONT_X, GameScale.DOOR_HEIGHT + 0.4, FRONT_Z + depth / 2),
		Vector3(3.0, 0.08, AWNING_DEPTH), CARPET)
	for side: float in [-1.0, 1.0]:
		_builder.box(Vector3(DOOR_FRONT_X + side * 1.4, (GameScale.DOOR_HEIGHT + 0.4) / 2, FRONT_Z + AWNING_DEPTH - 0.1),
			Vector3(0.06, GameScale.DOOR_HEIGHT + 0.4, 0.06), BRASS)
	_builder.mesh_box(Vector3(DOOR_FRONT_X, 0.01, FRONT_Z + depth / 2), Vector3(1.6, 0.01, depth), CARPET)
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = "PLACE_HOTEL"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = BRASS
	sign_label.position = Vector3(0, ROOF + 0.8, FRONT_Z + 0.12)
	add_child(sign_label)


## The wall between the dining room and the lobby, the worn red carpet and the lights downstairs.
func _downstairs() -> void:
	_builder.wall("z", DINING_X, BACK_Z, FRONT_Z, 0, [DOOR_DINING_Z], INSIDE)
	_builder.mesh_box(Vector3(DOOR_FRONT_X, FLOOR_TOP + 0.005, (FRONT_Z + DESK_AT.z) / 2),
		Vector3(1.6, 0.01, FRONT_Z - DESK_AT.z - 0.8), CARPET)
	for at: Vector3 in [Vector3(-9, 0, -4), Vector3(-9, 0, 3), Vector3(0, 0, -4), Vector3(0, 0, 3), Vector3(8, 0, 0)]:
		_builder.light(at + Vector3(0, GameScale.FLOOR_HEIGHT - 0.5, 0))


## The reception desk, the bell and the guest book on it, the key board, the Golden Pillow's glass case, the
## armchairs, the plastic plant and the lift that has been out of order since 1987.
func _lobby() -> void:
	_builder.box(DESK_AT + Vector3(0, DESK_SIZE.y / 2, 0), DESK_SIZE, WOOD)
	var bell := SphereMesh.new()
	bell.radius = 0.07
	bell.height = 0.07
	_builder.mesh(bell, BELL_AT + Vector3(0, 0.035, 0), BRASS)
	_builder.mesh_box(BOOK_AT + Vector3(0, 0.02, 0), Vector3(0.45, 0.04, 0.32), CARPET.darkened(0.3))
	_builder.mesh_box(KEY_BOARD_AT, Vector3(2.0, 0.9, 0.04), WOOD.lightened(0.2))
	for i in GUEST_ROOMS.size():
		var hook := Vector3(KEY_BOARD_AT.x - 0.75 + i * 0.3, KEY_BOARD_AT.y, KEY_BOARD_AT.z + 0.04)
		_builder.mesh_box(hook, Vector3(0.04, 0.04, 0.04), BRASS)
	_builder.box(CASE_AT + Vector3(0, 0.45, 0), Vector3(0.7, 0.9, 0.7), WOOD)
	_builder.mesh_box(CASE_AT + Vector3(0, 1.2, 0), Vector3(0.7, 0.6, 0.7), GLASS)
	for at in ARMCHAIRS:
		_builder.box(at + Vector3(0, 0.25, 0), Vector3(0.9, 0.5, 0.9), CARPET)
		_builder.box(at + Vector3(0, 0.7, -0.38), Vector3(0.9, 0.5, 0.15), CARPET)
	_builder.box(PLANT_AT + Vector3(0, 0.25, 0), Vector3(0.4, 0.5, 0.4), WOOD)
	var leaves := SphereMesh.new()
	leaves.radius = 0.45
	leaves.height = 0.9
	_builder.mesh(leaves, PLANT_AT + Vector3(0, 0.9, 0), PLANT)
	for side: float in [-1.0, 1.0]:
		_builder.mesh_box(LIFT_AT + Vector3(side * 0.42, 1.05, 0.02), Vector3(0.8, 2.1, 0.04), METAL)
	var lift_sign := Label3D.new()
	lift_sign.name = "LiftSign"
	lift_sign.text = "SIGN_HOTEL_LIFT"
	lift_sign.font_size = 28
	lift_sign.pixel_size = 0.01
	lift_sign.position = LIFT_AT + Vector3(0, 1.2, 0.06)
	add_child(lift_sign)


## The piano and the dining tables.
func _dining() -> void:
	_builder.box(PIANO_AT + Vector3(0, 0.55, 0), Vector3(1.6, 1.1, 0.7), Color(0.1, 0.1, 0.1))
	for at in TABLES:
		_builder.box(at + Vector3(0, 0.74, 0), Vector3(1.0, 0.06, 1.0), SHEETS)
		_builder.legs(at, Vector2(1.0, 1.0), 0.72, WOOD)


## The stairs up from the lobby, and the railing around their hole upstairs (open where they arrive).
func _stairs() -> void:
	_builder.stairs(Vector3(STAIR_X, FLOOR_TOP, STAIR_FOOT_Z), STAIR_RUN, WOOD)
	var west := STAIR_X - HOLE_HALF_X
	var east := STAIR_X + HOLE_HALF_X
	var length := HOLE_SOUTH_Z - STAIR_TOP_Z
	for x: float in [west, east]:
		_builder.box(Vector3(x, UP + 0.5, (STAIR_TOP_Z + HOLE_SOUTH_Z) / 2), Vector3(0.06, 1.0, length), WOOD)
	_builder.box(Vector3(STAIR_X, UP + 0.5, HOLE_SOUTH_Z), Vector3(HOLE_HALF_X * 2, 1.0, 0.06), WOOD)


## The upstairs floor around the stairs' hole, its roof and lights, and the corridor's walls with the rooms' doors.
func _upstairs() -> void:
	var west := STAIR_X - HOLE_HALF_X
	var east := STAIR_X + HOLE_HALF_X
	_builder.slab(-HALF_X, west, BACK_Z, FRONT_Z, UP, INSIDE.darkened(0.3))
	_builder.slab(east, HALF_X, BACK_Z, FRONT_Z, UP, INSIDE.darkened(0.3))
	_builder.slab(west, east, BACK_Z, STAIR_TOP_Z, UP, INSIDE.darkened(0.3))
	_builder.slab(west, east, HOLE_SOUTH_Z, FRONT_Z, UP, INSIDE.darkened(0.3))
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, ROOF, INSIDE.darkened(0.4))
	_builder.mesh_box(Vector3((SUITE_X + HALF_X) / 2, UP + 0.005, 0), Vector3(HALF_X - SUITE_X, 0.01, CORRIDOR * 2),
		CARPET)
	var north_doors: Array[float] = []
	var south_doors: Array[float] = []
	for number: int in ROOMS:
		var room: Dictionary = ROOMS[number]
		(north_doors if room.side == "n" else south_doors).append(room.door)
	_builder.wall("x", -CORRIDOR, SUITE_X, HALF_X, 1, north_doors, INSIDE)
	_builder.wall("x", CORRIDOR, SUITE_X, (ROOMS[17] as Dictionary).x1, 1, south_doors, INSIDE)
	_builder.wall("z", SUITE_X, BACK_Z, FRONT_Z, 1, [DOOR_SUITE_Z], INSIDE)
	for x: float in [-4.0, 1.0, 6.0, 11.0]:
		_builder.light(Vector3(x, ROOF - 0.5, 0))


## Each room's walls, its bed against the far wall, the nightstand beside it, a lamp and the number over its door
## (not the 13's).
func _rooms() -> void:
	for number: int in ROOMS:
		var room: Dictionary = ROOMS[number]
		var north: bool = room.side == "n"
		var z0 := BACK_Z if north else CORRIDOR
		var z1 := -CORRIDOR if north else FRONT_Z
		if room.x1 < HALF_X:
			_builder.wall("z", room.x1, z0, z1, 1, [], INSIDE)
		var middle := room_middle(number)
		_builder.mesh_box(Vector3(middle.x, UP + 0.005, (z0 + z1) / 2), Vector3(room.x1 - room.x0 - 0.2, 0.01, z1 - z0 - 0.2),
			FLOORBOARDS)
		var far := (BACK_Z + 1.1) if north else (FRONT_Z - 1.1)
		_builder.box(Vector3(middle.x, UP + 0.25, far), Vector3(1.4, 0.5, 2.0), SHEETS)
		_builder.box(Vector3(middle.x + 1.1, UP + 0.3, far + (-0.6 if north else 0.6)), Vector3(0.45, 0.6, 0.45), WOOD)
		_builder.light(middle + Vector3(0, GameScale.FLOOR_HEIGHT - 0.5, 0))
		if number == HIDDEN_ROOM:
			continue
		var label := Label3D.new()
		label.name = "Room%d" % number
		label.text = str(number)
		label.font_size = 40
		label.pixel_size = 0.01
		label.modulate = BRASS
		var face := -CORRIDOR + 0.09 if north else CORRIDOR - 0.09
		label.position = Vector3(room.door, UP + GameScale.DOOR_HEIGHT + 0.2, face)
		label.rotation.y = 0.0 if north else PI
		add_child(label)


## The suite: its big bed, the safe in the west wall and its own bathroom with the bathtub.
func _suite() -> void:
	_builder.wall("z", SUITE_BATH_X, BACK_Z, SUITE_BATH_Z, 1, [DOOR_SUITE_BATH_Z], TILE)
	_builder.wall("x", SUITE_BATH_Z, -HALF_X, SUITE_BATH_X, 1, [], TILE)
	_builder.mesh_box(Vector3((-HALF_X + SUITE_BATH_X) / 2, UP + 0.005, (BACK_Z + SUITE_BATH_Z) / 2),
		Vector3(SUITE_BATH_X + HALF_X - 0.2, 0.01, SUITE_BATH_Z - BACK_Z - 0.2), TILE)
	_builder.mesh_box(Vector3((-HALF_X + SUITE_X) / 2, UP + 0.005, (SUITE_BATH_Z + FRONT_Z) / 2),
		Vector3(SUITE_X + HALF_X - 0.2, 0.01, FRONT_Z - SUITE_BATH_Z - 0.2), CARPET)
	_builder.mesh_box(Vector3((SUITE_BATH_X + SUITE_X) / 2, UP + 0.005, (BACK_Z + SUITE_BATH_Z) / 2),
		Vector3(SUITE_X - SUITE_BATH_X - 0.2, 0.01, SUITE_BATH_Z - BACK_Z), CARPET)
	_builder.box(TUB_AT + Vector3(0, 0.3, 0), Vector3(1.6, 0.6, 0.8), SHEETS)
	_builder.box(SUITE_BED_AT + Vector3(0, 0.3, 0), Vector3(2.0, 0.6, 2.2), SHEETS)
	_builder.box(SUITE_BED_AT + Vector3(0, 0.8, 1.05), Vector3(2.0, 1.0, 0.1), WOOD)
	_builder.mesh_box(SAFE_AT, Vector3(0.1, 0.5, 0.5), METAL.darkened(0.3))
	var suite_sign := Label3D.new()
	suite_sign.name = "SuiteSign"
	suite_sign.text = "SIGN_HOTEL_SUITE"
	suite_sign.font_size = 32
	suite_sign.pixel_size = 0.01
	suite_sign.modulate = BRASS
	suite_sign.position = Vector3(SUITE_X + 0.09, UP + GameScale.DOOR_HEIGHT + 0.2, DOOR_SUITE_Z)
	suite_sign.rotation.y = PI / 2
	add_child(suite_sign)
	_builder.light(Vector3(-10.0, ROOF - 0.5, 1.0))
	_builder.light(Vector3(-11.5, ROOF - 0.5, -7.0))


## The old wardrobe over the 13's door: heavy, but one cop can drag it away.
func _wardrobe() -> void:
	wardrobe = Grabbable.new()
	wardrobe.name = "Wardrobe"
	wardrobe.mass = WARDROBE_KG
	wardrobe.position = WARDROBE_AT + Vector3(0, WARDROBE_SIZE.y / 2, 0)
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = WARDROBE_SIZE
	collision.shape = box_shape
	wardrobe.add_child(collision)
	var look := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = WARDROBE_SIZE
	look.mesh = box_mesh
	look.material_override = _builder.material(WOOD.darkened(0.2))
	wardrobe.add_child(look)
	add_child(wardrobe)
