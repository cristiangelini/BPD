class_name Hotel
extends CrimeScenePlace

## The city's hotel (escena-hotel.md, step 1, decision 201), the Hotel Gran Siesta on its lot with the front to +Z.
## Downstairs: the lobby with its armchairs, the Golden Pillow's case and the reception desk (the bell, the guest book
## and the key board behind it), the broken lift and the stairs; west of it, the dining room with the piano. Upstairs:
## the long corridor with the guests' six rooms (11, 12, 14, 15, 16 and 17: the hotel skips the 13), the suite at its
## west end, where the theft was, and behind an old wardrobe in the corridor, the room with no number: the 13. The
## six guests alike wait in the lobby, don Bostezo behind the desk, señora Perlita by the armchairs, Tito the bellboy
## by the door and doña Escoba upstairs with her cart (step 2). In every guest room, its sleeper's shoes, hairbrush,
## nightstand and suitcase (step 3). The case (step 4): what was stolen hides in the 13, in the maid's cart or in the
## culprit's suitcase, and the evidence bags wait on a stool by the desk; the clues in the suite and the maid's round
## are HotelClues'; Tito the witness (HotelBellboy), the guest book with the 3 a.m. signature (GuestBook) and the
## bell that wakes the concierge (HotelSceneBell) are at the reception. Every number here is (propuesta).

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
## What was stolen, drawn with the seed (escena-hotel.md, pregunta 1), and where it can be hidden: under the bed in the
## 13, in the maid's laundry cart or in the culprit's suitcase.
const LOOTS: Array[String] = ["necklace", "toupee", "pillow"]
const LOOT_SPOTS: Array[String] = ["room13", "cart", "suitcase"]
const LOOT_MODELS := {
	"necklace": preload("res://assets/models/pearl_necklace.glb"),
	"toupee": preload("res://assets/models/gold_toupee.glb"),
	"pillow": preload("res://assets/models/golden_pillow.glb"),
}
## How far in front of its hiding spot (toward the door) what was stolen falls: past the bed, the cart, the suitcase.
const LOOT_OUT := {"room13": 1.4, "cart": 0.8, "suitcase": 0.6}
## The roll of evidence bags, on a stool by the reception desk.
const BAGS_AT := Vector3(2.4, 0, -5.6)
## The shuttle waits at the curb east of the door, its back to the building, and drives straight out (step 5).
const GETAWAY_AT := Vector3(9.5, 0, SIZE.y / 2 + 1.0)
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
## With false, the hotel is just the building: no guests, no staff (the raid builds its own on top).
@export var crime_scene := true
var wardrobe: Grabbable
var guests: Array[HotelGuest] = []
## The things in the guest rooms (RoomThing), by room: shoe, hair, glasses and suitcase.
var things := {}
var case: CrimeSceneCase
## What was stolen and where it is (drawn with the case seed in set_up_case), and whether the cops found it.
var loot := "necklace"
var loot_spot := "room13"
var loot_found := false
## The searchable places, by spot (the suitcase is the culprit's RoomThing).
var loot_spots := {}
var concierge: HotelStaff
var perlita: HotelStaff
var bellboy: HotelBellboy
var bell: HotelSceneBell
var book: GuestBook
var maid: HotelStaff
## The case's clues in the suite and the maid's round (HotelClues), once the case comes.
var clues: HotelClues
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
	if crime_scene:
		_people()
		_things()
		_bags()
		_loot_spots()


## Draws what was stolen and where it is, and tells the guests, the concierge and the rooms' things about the case.
func set_up_case(new_case: CrimeSceneCase) -> void:
	if not crime_scene:
		return
	case = new_case
	loot = LOOTS[hash(["hotel loot", case.case_seed]) % LOOTS.size()]
	loot_spot = LOOT_SPOTS[hash(["hotel loot spot", case.case_seed]) % LOOT_SPOTS.size()]
	loot_spots.suitcase = things[case.cooks[case.plan.culprit].room].suitcase
	for guest in guests:
		guest.case = case
	concierge.case = case
	bellboy.case = case
	bellboy.knows = case.plan.clues.has("witness")
	bellboy.asked_room = GUEST_ROOMS[hash(["hotel bellboy room", case.case_seed]) % GUEST_ROOMS.size()]
	book = GuestBook.new()
	book.name = "GuestBook"
	book.case = case
	book.has_signature = case.plan.clues.has("signature")
	book.position = BOOK_AT
	add_child(book)
	for room: int in things:
		for thing: RoomThing in things[room].values():
			thing.case = case
	clues = HotelClues.new()
	clues.name = "Clues"
	clues.hotel = self
	clues.case = case
	add_child(clues)


## Searching a spot: the stolen thing turns up in the right one; a sign of nothing in the others. Any suitcase can be
## searched, but only the culprit's can hide it.
func search(spot: String, cop: Cop, room := 0) -> void:
	if spot == "suitcase" and loot_spots.get("suitcase") != things.get(room, {}).get("suitcase"):
		return
	if spot != loot_spot or loot_found or not case:
		if cop:
			cop.show_hint("HINT_SEARCH_NOTHING_" + spot)
		return
	reveal_loot()


## What was stolen comes out of its hiding spot, on the floor in front of it, and the case notes it.
func reveal_loot() -> void:
	if loot_found:
		return
	loot_found = true
	var item: Node3D = LOOT_MODELS[loot].instantiate()
	item.name = "Loot"
	add_child(item)
	var spot := loot_spots[loot_spot] as Node3D
	var at := to_local(spot.global_position)
	var floor_y := UP if floor_of(spot.global_position + Vector3.UP * 0.1) == 1 else FLOOR_TOP
	var out := Vector3(0, 0, 1 if at.z < 0 else -1)
	item.position = Vector3(at.x, floor_y, at.z) + out * LOOT_OUT[loot_spot]
	if case:
		case.found_loot()


## The hotel's shuttle waits at the curb, east of the door, and drives straight out into the street.
func getaway(_index: int, _city: Node3D) -> Dictionary:
	var out := to_global(GETAWAY_AT)
	return {"at": Transform3D(global_basis, out), "via": [to_global(Vector3(GETAWAY_AT.x, 0, SIZE.y / 2 + 5.0))]}


## Online, what the guests' hotel takes from the host's: who signed the notebook, the concierge's anger, Tito, the
## safe, the card on the suite's door, the maid's round, the guest book, and the clues ruined on the host.
func net_state() -> Dictionary:
	var state := {"signed": guests.map(func(guest: HotelGuest) -> bool: return guest.signed)}
	if not case:
		return state
	state.angry = concierge.angry_left
	state.tito = [bellboy.delivered, bellboy.offended]
	state.book = book.signed_over
	state.suite = [clues.safe.touched, clues.hanger.hung, clues.suite_cleaned, clues.maid_walking]
	state.maid = [maid.position, maid.rotation.y]
	return state


func apply_net_state(state: Dictionary) -> void:
	for guest in guests:
		guest.signed = state.signed[guest.index]
	if not case or not state.has("tito"):
		return
	concierge.angry_left = state.angry
	bellboy.delivered = state.tito[0]
	bellboy.offended = state.tito[1]
	book.signed_over = state.book
	clues.safe.touched = state.suite[0]
	if clues.hanger.hung != state.suite[1]:
		clues.hanger.hung = state.suite[1]
		clues.hanger._show()
	clues.suite_cleaned = state.suite[2]
	clues.maid_walking = state.suite[3]
	maid.position = state.maid[0]
	maid.rotation.y = state.maid[1]
	for kind: String in ["hair", "bite"]:
		if case.ruined.has(kind) and case.items.has(kind):
			var item: CrimeClueItem = case.items[kind]
			item.spoiled = true
			item._eaten_part.visible = false
	if case.ruined.has("footprint") and case.flour_print and not case.flour_print.wiped:
		case.flour_print.wipe()


func witness_offended() -> bool:
	return bellboy != null and bellboy.offended


func offend_witness() -> void:
	if bellboy:
		bellboy.offend()


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
	var traits := GuestTraits.draw(case_seed)
	for i in GUESTS_AT.size():
		var guest := HotelGuest.new()
		guest.name = "Guest%d" % i
		guest.index = i
		guest.traits = traits[i]
		guest.position = GUESTS_AT[i] + Vector3(0, FLOOR_TOP, 0)
		add_child(guest)
		guests.append(guest)
	concierge = _staff("concierge", CONCIERGE_AT + Vector3(0, FLOOR_TOP, 0), 0.0)
	perlita = _staff("perlita", PERLITA_AT + Vector3(0, FLOOR_TOP, 0), -0.4)
	bellboy = HotelBellboy.new()
	bellboy.name = "Bellboy"
	bellboy.hotel = self
	bellboy.position = BELLBOY_AT + Vector3(0, FLOOR_TOP, 0)
	bellboy.rotation.y = PI
	add_child(bellboy)
	bell = HotelSceneBell.new()
	bell.name = "Bell"
	bell.concierge = concierge
	bell.position = BELL_AT
	add_child(bell)
	maid = _staff("maid", MAID_AT, -PI / 2.0)


## In each guest room, the things of whoever really sleeps there: the shoes at the foot of the bed, the hairbrush and
## the glasses (or not) on the nightstand and the suitcase beside the bed.
func _things() -> void:
	var traits := GuestTraits.draw(case_seed)
	for guest in traits:
		var room: Dictionary = ROOMS[guest.room]
		var toward := 1.0 if room.side == "n" else -1.0
		var bed := Vector3(room_middle(guest.room).x, UP, (BACK_Z + 1.1) if room.side == "n" else (FRONT_Z - 1.1))
		var stand := bed + Vector3(1.1, 0.6, -0.6 * toward)
		var at := {"shoe": bed + Vector3(-0.3, 0, 1.4 * toward), "hair": stand + Vector3(0, 0, -0.1),
			"glasses": stand + Vector3(0, 0, 0.12), "suitcase": bed + Vector3(-1.2, 0, 0.3 * toward)}
		things[guest.room] = {}
		for what: String in at:
			var thing := RoomThing.new()
			thing.what = what
			thing.room = guest.room
			thing.sleeper = guest
			thing.position = at[what]
			add_child(thing)
			things[guest.room][what] = thing


## A stool with the roll of evidence bags for the clues the cops carry.
func _bags() -> void:
	_builder.box(BAGS_AT + Vector3(0, 0.25, 0), Vector3(0.5, 0.5, 0.4), WOOD)
	bags = EvidenceBags.new()
	bags.name = "EvidenceBags"
	bags.position = BAGS_AT + Vector3(0, 0.5, 0)
	add_child(bags)


## Two places to search besides the suitcases: under the bed of the 13 and the maid's cart (it goes with her).
func _loot_spots() -> void:
	var bed := Vector3(room_middle(HIDDEN_ROOM).x, UP + 0.3, BACK_Z + 1.1)
	var under_bed := LootSpot.new(Vector3(1.5, 0.6, 2.1))
	under_bed.name = "Search_room13"
	under_bed.spot = "room13"
	under_bed.place = self
	under_bed.position = bed
	add_child(under_bed)
	loot_spots.room13 = under_bed
	var in_cart := LootSpot.new(HotelStaff.CART_SIZE + Vector3(0.05, 0.05, 0.05))
	in_cart.name = "Search_cart"
	in_cart.spot = "cart"
	in_cart.place = self
	in_cart.position.y = HotelStaff.CART_SIZE.y / 2
	maid.cart.add_child(in_cart)
	loot_spots.cart = in_cart


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
	_builder.box(SUITE_BED_AT + Vector3(0, 0.66, 0.75), Vector3(1.6, 0.12, 0.4), SHEETS.lightened(0.5))
	_builder.mesh_box(SAFE_AT, Vector3(0.1, 0.5, 0.5), METAL.darkened(0.3))
	# Its door, left open.
	_builder.mesh_box(SAFE_AT + Vector3(0.3, 0, 0.27), Vector3(0.5, 0.46, 0.04), METAL)
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
