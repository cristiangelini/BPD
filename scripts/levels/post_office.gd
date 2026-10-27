class_name PostOffice
extends CrimeScenePlace

## The Correo Central (escena-correo.md, step 1, decision 470), on its lot with the front to +Z: the giant mailbox on
## the sidewalk and a clock over the door. Inside, the counter hall in front with its three windows, the parcel scale,
## the queue ribbons and the empty frame of La Vaquita Azul; the wall of 24 post boxes to the east (six with a route's
## color); at the back, the sorting room with the big sorting machine and the sacks of undelivered mail, and in the
## east corner the depot of "Frágil" parcels and the boss's office with the open safe, the postmark book and the red
## button. The six carriers stand about the counter, the boxes and the sorting machine (step 2), Doña Sellito in the
## hall and Cartita on its perch at window 2. The case reaches the carriers (step 3, set_up_case). La Vaquita Azul is
## hidden in one of nine spots (step 4) and the postmark book tells which post box. Every two minutes the sorting
## machine runs on its own (step 5, SortingMachine), and the red button in the office stops it. Every number here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(32, 28)
const HALF_X := 15.0
const BACK_Z := -13.0
## The front wall; the sidewalk runs from it to the lot's edge.
const FRONT_Z := 7.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT + 1.0
## In front of ROOMS_Z: the counter hall, and the post boxes east of EAST_X. Behind it: the sorting room, and east of
## EAST_X the depot, with the office behind OFFICE_Z.
const ROOMS_Z := 0.0
const EAST_X := 7.0
const OFFICE_Z := -5.0
const DOOR_FRONT_X := 0.0
const DOOR_BOXES_Z := 4.5
const DOOR_SORTING_X := -3.0
const DOOR_DEPOT_Z := -2.5
const DOOR_OFFICE_Z := -9.0
const DOOR_AT := Vector3(DOOR_FRONT_X, 0, FRONT_Z)
const SIDEWALK_AT := Vector3(0, 0, FRONT_Z + 3.5)
const MAILBOX_AT := Vector3(4.5, 0, FRONT_Z + 2.5)
## The counter hall: the counter with its three windows (staff behind it, to -Z), the empty frame on the wall behind
## them, the parcel scale, the returns sack and the queue ribbons.
const COUNTER_Z := 2.0
const COUNTER_FROM := -13.0
const COUNTER_TO := -4.0
const WINDOWS: Array[float] = [-11.0, -8.0, -5.0]
const FRAME_AT := Vector3(-8.0, 1.7, ROOMS_Z + 0.1)
const SCALE_AT := Vector3(-1.5, 0, 2.0)
const RETURNS_AT := Vector3(-14.0, 0, 6.2)
const QUEUE_AT := Vector3(3.0, 0, 4.5)
## The mail van waits at the curb east of the door, and drives straight out into the street (step 7).
const GETAWAY_AT := Vector3(9.0, 0, SIZE.y / 2 + 1.0)
## The stool with the roll of evidence bags, by the door.
const BAGS_AT := Vector3(-2.5, 0, 6.0)
## Where the people are: two carriers behind the counter facing the hall, one at the post boxes facing them and three
## at the sorting machine facing it; Doña Sellito in the hall by the sorting room's door; Cartita on its perch on the
## counter at window 2.
const CARRIERS_AT: Array[Vector3] = [Vector3(-11.0, 0, 1.0), Vector3(-5.0, 0, 1.0), Vector3(11.0, 0, 3.0),
	Vector3(-7.0, 0, -4.2), Vector3(-1.0, 0, -4.2), Vector3(-4.0, 0, -9.0)]
const BOSS_AT := Vector3(1.5, 0, 1.2)
const PARROT_AT := Vector3(-8.0, 1.1, COUNTER_Z)
## Cartita's cookies, on a plate on the counter by her perch.
const COOKIES_AT := Vector3(-7.2, 1.11, COUNTER_Z + 0.2)
const COOKIES := 3
## The post boxes on the east wall: ROWS x COLUMNS, numbered from the top row, front to back.
const BOX_ROWS := 4
const BOX_COLUMNS := 6
const BOX_SIZE := 0.7
## The boxes with a route's color on their label, by the route (their number).
const ROUTE_BOXES := {"red": 2, "green": 5, "yellow": 9, "blue": 14, "orange": 18, "purple": 21}
## The sorting room: the machine in the middle and the sacks of undelivered mail around it.
const MACHINE_AT := Vector3(-4.0, 0, -6.5)
const MACHINE_SIZE := Vector3(8.0, 1.6, 2.6)
const SACKS_AT: Array[Vector3] = [Vector3(-12.5, 0, -2.5), Vector3(-12.5, 0, -10.5), Vector3(3.5, 0, -11.0),
	Vector3(3.5, 0, -2.0)]
## The office: the open safe, the desk with the postmark book and the red button that stops the machine.
const SAFE_AT := Vector3(13.8, 0, -11.8)
const DESK_AT := Vector3(11.0, 0, -8.0)
const BUTTON_AT := Vector3(9.0, 1.3, BACK_Z + 0.14)
## The depot: the shelves of parcels against the office's wall.
const SHELVES_AT := Vector3(11.0, 0, OFFICE_Z + 0.5)
## Where La Vaquita Azul can be hidden (PostOfficeSpot): the six post boxes with a route, the big sack of undelivered
## mail (the first of SACKS_AT), the parcel scale and the giant mailbox.
const STAMP_SPOTS: Array[String] = ["box_red", "box_green", "box_yellow", "box_blue", "box_orange", "box_purple",
	"sack", "scale", "mailbox"]
## Seconds a search of a spot takes, and reading the postmark book (propuesta).
const SEARCH_SECONDS := 5.0
const BOOK_SECONDS := 10.0
const PAINT := Color(0.95, 0.78, 0.22)
const INSIDE := Color(0.93, 0.9, 0.8)
const TILES := Color(0.62, 0.6, 0.56)
const CONCRETE := Color(0.5, 0.5, 0.52)
const WOOD := Color(0.5, 0.34, 0.2)
const METAL := Color(0.6, 0.62, 0.66)
const BRASS := Color(0.8, 0.65, 0.3)
const POST_BLUE := Color(0.15, 0.3, 0.65)
const BLACK := Color(0.08, 0.08, 0.1)
const WHITE := Color(0.97, 0.97, 0.97)
const SACK := Color(0.7, 0.6, 0.42)
const CARDBOARD := Color(0.72, 0.55, 0.35)
const RIBBON := Color(0.75, 0.15, 0.15)
const ROUTE_COLORS := {
	"red": Color(0.85, 0.18, 0.15), "green": Color(0.25, 0.7, 0.3), "yellow": Color(0.95, 0.85, 0.2),
	"blue": Color(0.2, 0.45, 0.9), "orange": Color(0.95, 0.55, 0.15), "purple": Color(0.55, 0.3, 0.75),
}

var case: CrimeSceneCase
## What was stolen (CrimeSceneCase's loot texts), where the culprit hid it, whether a search turned it up and whether
## it's back in its frame.
var loot := "stamp"
var loot_spot := "sack"
var stamp_uncovered := false
var loot_found := false
var loot_spots := {}
var stamp: BlueStamp
var book: PostmarkBook
## The sorting machine (step 5), and its red button in the office.
var sorting: SortingMachine
var button: RedButton
## The case's clues (step 6) and the returns sack on the counter.
var clues: PostOfficeClues
var returns: ReturnsSack
## What each cop is busy with ("" for nothing), by cop: a search or the book takes a while.
var _busy := {}
var carriers: Array[PostCarrier] = []
var boss: PostBoss
var parrot: PostParrot
var cookies: Array[ParrotCookie] = []
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("post_office")
	variant = "post_office"
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_rooms()
	_counter()
	_boxes()
	_sorting()
	_office()
	_depot()
	_people()


## The case reaches the carriers (their traits are its suspects, same seed), and one of them, drawn with the seed,
## won't take off the cap until they get something to eat.
func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot_spot = STAMP_SPOTS[absi(hash(["post office stamp spot", case.case_seed])) % STAMP_SPOTS.size()]
	var stubborn := absi(hash("stubborn carrier %d" % case.case_seed)) % carriers.size()
	for carrier in carriers:
		carrier.case = case
		carrier.stubborn = carrier.index == stubborn
	parrot.case = case
	parrot.knows = case.plan.clues.has("witness")
	sorting = SortingMachine.new()
	sorting.name = "SortingMachine"
	sorting.post_office = self
	sorting.case = case
	add_child(sorting)
	clues = PostOfficeClues.new()
	clues.name = "Clues"
	clues.post_office = self
	clues.case = case
	add_child(clues)


## E on a spot: the cop searches it for SEARCH_SECONDS, and then La Vaquita Azul turns up if it's there, or the cop
## says what's there instead.
func search(spot: String, cop: Cop) -> void:
	if _busy.get(cop, "") != "":
		return
	_busy[cop] = spot
	if cop:
		cop.show_hint("HINT_POST_SEARCHING")
	get_tree().create_timer(SEARCH_SECONDS).timeout.connect(searched.bind(spot, cop))


## The search of a spot is over.
func searched(spot: String, cop: Cop) -> void:
	_busy.erase(cop)
	if clues:
		clues.searched(spot)
	if spot != loot_spot or stamp_uncovered or not case:
		if cop:
			cop.show_hint("HINT_POST_NOTHING_" + spot)
		return
	uncover_stamp()
	if cop:
		cop.show_hint("HINT_STAMP_UNCOVERED")


## E on the postmark book: BOOK_SECONDS reading the night's page, and then what it says.
func read_book(cop: Cop) -> void:
	if _busy.get(cop, "") != "":
		return
	_busy[cop] = "book"
	if cop:
		cop.show_hint("HINT_BOOK_READING")
	get_tree().create_timer(BOOK_SECONDS).timeout.connect(book_read.bind(cop))


func book_read(cop: Cop) -> void:
	_busy.erase(cop)
	if cop:
		cop.show_hint(book_says())


## What the book's night page tells: the color of the post box the envelope went to, if the stamp is in one, or no
## stamps that night.
func book_says() -> String:
	if case and loot_spot.begins_with("box_"):
		return tr("HINT_BOOK_STAMPED") % tr("ROUTE_COLOR_" + loot_spot.trim_prefix("box_"))
	return tr("HINT_BOOK_EMPTY")


## La Vaquita Azul comes out of its hiding spot, flat on the floor in front of it, for a cop to take back to its frame.
func uncover_stamp() -> void:
	if stamp_uncovered:
		return
	stamp_uncovered = true
	stamp = BlueStamp.new()
	stamp.name = "BlueStamp"
	stamp.post_office = self
	add_child(stamp)
	var spot := loot_spots[loot_spot] as Node3D
	var out: Vector3 = spot.get_meta("out")
	stamp.lie(Vector3(spot.position.x, FLOOR_TOP, spot.position.z) + out)


## La Vaquita Azul back in its frame: the case notes it (+LOOT_BONUS on the salary).
func reveal_loot() -> void:
	if loot_found:
		return
	uncover_stamp()
	loot_found = true
	stamp.position = FRAME_AT + Vector3(0, 0, 0.03)
	stamp.rotation = Vector3.ZERO
	stamp.collision_layer = 0
	if case:
		case.found_loot()


## The carrier by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return carriers[index] if index >= 0 and index < carriers.size() else null


## Whether a point in the world (ignoring height) is on the post office's lot, sidewalk included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the building.
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## The mail van waits at the curb, east of the door, and drives straight out into the street.
func getaway(_index: int, _city: Node3D) -> Dictionary:
	var out := to_global(GETAWAY_AT)
	return {"at": Transform3D(global_basis, out), "via": [to_global(Vector3(GETAWAY_AT.x, 0, SIZE.y / 2 + 5.0))]}


## A cop shouted (VoiceChat): Cartita may get scared.
func shouted_by(cop: Cop) -> void:
	if parrot:
		parrot.shouted_by(cop)


## Which room a point in the world is in: "counter", "boxes", "sorting", "depot", "office", or "" outside.
func room(world: Vector3) -> String:
	if not inside(world):
		return ""
	var local := to_local(world)
	if local.z > ROOMS_Z:
		return "boxes" if local.x > EAST_X else "counter"
	if local.x < EAST_X:
		return "sorting"
	return "depot" if local.z > OFFICE_Z else "office"


## Where post box `index` (0 to 23) is: its door's middle on the east wall, facing west (-X).
static func box_at(index: int) -> Vector3:
	var row := index / BOX_COLUMNS
	var column := index % BOX_COLUMNS
	return Vector3(HALF_X - 0.37, 2.4 - row * BOX_SIZE, 1.2 + column * (BOX_SIZE + 0.15))


## The six carriers alike (CarrierTraits.draw with the case seed), each facing what they look after: the counter's
## two the hall, the boxes' one the boxes and the sorting room's three the machine. Doña Sellito facing the hall and
## Cartita on the counter.
func _people() -> void:
	var traits := CarrierTraits.draw(case_seed)
	for i in traits.size():
		var carrier := PostCarrier.new()
		carrier.name = "Carrier%d" % i
		carrier.traits = traits[i]
		carrier.index = i
		var at: Vector3 = CARRIERS_AT[i]
		carrier.position = at + Vector3(0, FLOOR_TOP, 0)
		carrier.rotation.y = facing(at)
		add_child(carrier)
		carriers.append(carrier)
	boss = PostBoss.new()
	boss.name = "Boss"
	boss.position = BOSS_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(boss)
	parrot = PostParrot.new()
	parrot.name = "Parrot"
	parrot.position = PARROT_AT
	add_child(parrot)
	# The plate of parrot cookies on the counter, by window 2.
	_builder.mesh_box(COOKIES_AT + Vector3(0, -0.01, 0), Vector3(0.4, 0.02, 0.3), WHITE)
	for i in COOKIES:
		var cookie := ParrotCookie.new()
		cookie.name = "ParrotCookie%d" % i
		cookie.position = COOKIES_AT + Vector3(-0.12 + i * 0.12, 0, 0)
		add_child(cookie)
		cookies.append(cookie)


## Which way a carrier standing at `at` faces (a Y rotation; the models face +Z): the hall behind the counter, the
## boxes in their room, the machine in the sorting room.
static func facing(at: Vector3) -> float:
	if at.z > ROOMS_Z:
		return PI / 2 if at.x > EAST_X else 0.0
	var to := MACHINE_AT - at
	return atan2(to.x, to.z)


## The floors, the roof with its lights and the outer walls.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, ROOMS_Z, FRONT_Z, FLOOR_TOP, TILES)
	_builder.slab(-HALF_X, HALF_X, BACK_Z, ROOMS_Z, FLOOR_TOP, CONCRETE)
	_builder.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, ROOF, INSIDE)
	_builder.wall_at("x", BACK_Z, -HALF_X, HALF_X, 0, ROOF, [], PAINT)
	_builder.wall_at("x", FRONT_Z, -HALF_X, HALF_X, 0, ROOF, [DOOR_FRONT_X], PAINT)
	_builder.wall_at("z", -HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], PAINT)
	_builder.wall_at("z", HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], PAINT)
	for at: Vector3 in [Vector3(-8, 0, 3.5), Vector3(2, 0, 3.5), Vector3(11, 0, 3.5), Vector3(-9, 0, -6.5),
			Vector3(1, 0, -6.5), Vector3(11, 0, -2.5), Vector3(11, 0, -9.0)]:
		_builder.light(at + Vector3(0, ROOF - 0.5, 0))


## The sign and the clock over the door, and the giant mailbox on the sidewalk.
func _front() -> void:
	var face := FRONT_Z + 0.12
	_label("Sign", "SIGN_POST_OFFICE", Vector3(-4.5, ROOF - 0.9, face + 0.06), 0.0, 0.012, 64)
	var dial := CylinderMesh.new()
	dial.top_radius = 0.6
	dial.bottom_radius = 0.6
	dial.height = 0.1
	_builder.mesh(dial, Vector3(4.0, ROOF - 0.8, face + 0.06), WHITE, Vector3(PI / 2, 0, 0))
	_builder.mesh_box(Vector3(4.0, ROOF - 0.6, face + 0.13), Vector3(0.05, 0.4, 0.02), BLACK)
	_builder.mesh_box(Vector3(4.15, ROOF - 0.8, face + 0.13), Vector3(0.3, 0.05, 0.02), BLACK)
	_spot("mailbox", MAILBOX_AT + Vector3(0, 0.9, 0), Vector3(1.2, 1.8, 1.0), Vector3(0, 0, 1.0))
	var tube := CylinderMesh.new()
	tube.top_radius = 0.6
	tube.bottom_radius = 0.6
	tube.height = 1.4
	_builder.mesh(tube, MAILBOX_AT + Vector3(0, 0.7, 0), POST_BLUE)
	var top := SphereMesh.new()
	top.radius = 0.6
	top.height = 0.6
	top.is_hemisphere = true
	_builder.mesh(top, MAILBOX_AT + Vector3(0, 1.4, 0), POST_BLUE)
	_builder.mesh_box(MAILBOX_AT + Vector3(0, 1.15, 0.58), Vector3(0.6, 0.08, 0.06), BLACK)
	_label("MailboxSign", "SIGN_MAILBOX", MAILBOX_AT + Vector3(0, 0.8, 0.62), 0.0, 0.004, 32)


## The walls between the rooms, with their doors and a sign over each.
func _rooms() -> void:
	_builder.wall_at("x", ROOMS_Z, -HALF_X, HALF_X, 0, ROOF, [DOOR_SORTING_X], INSIDE)
	_builder.wall_at("z", EAST_X, ROOMS_Z, FRONT_Z, 0, ROOF, [DOOR_BOXES_Z], INSIDE)
	_builder.wall_at("z", EAST_X, BACK_Z, ROOMS_Z, 0, ROOF, [DOOR_DEPOT_Z, DOOR_OFFICE_Z], PAINT)
	_builder.wall_at("x", OFFICE_Z, EAST_X, HALF_X, 0, ROOF, [], PAINT)
	_label("", "SIGN_POST_BOXES", Vector3(EAST_X - 0.12, 2.6, DOOR_BOXES_Z), -PI / 2)
	_label("", "SIGN_SORTING", Vector3(DOOR_SORTING_X, 2.6, ROOMS_Z + 0.12), 0.0)
	_label("", "SIGN_DEPOT", Vector3(EAST_X - 0.12, 2.6, DOOR_DEPOT_Z), -PI / 2)
	_label("", "SIGN_POST_BOSS", Vector3(EAST_X - 0.12, 2.6, DOOR_OFFICE_Z), -PI / 2)


## The counter with its three windows, the empty frame of La Vaquita Azul behind them, the parcel scale, the returns
## sack and the queue ribbons.
func _counter() -> void:
	var middle := (COUNTER_FROM + COUNTER_TO) / 2
	_builder.box(Vector3(middle, 0.55, COUNTER_Z), Vector3(COUNTER_TO - COUNTER_FROM, 1.1, 0.8), WOOD)
	for i in WINDOWS.size():
		var x := WINDOWS[i]
		_builder.mesh_box(Vector3(x - 1.2, 1.75, COUNTER_Z), Vector3(0.06, 1.3, 0.8), WOOD)
		_builder.mesh_box(Vector3(x, 2.45, COUNTER_Z), Vector3(2.4, 0.1, 0.8), WOOD)
		_label("Window%d" % (i + 1), "SIGN_WINDOW_%d" % (i + 1), Vector3(x, 2.65, COUNTER_Z + 0.42), 0.0)
	_builder.mesh_box(Vector3(COUNTER_TO + 0.03, 1.75, COUNTER_Z), Vector3(0.06, 1.3, 0.8), WOOD)
	var frame := Node3D.new()
	frame.name = "StampFrame"
	frame.position = FRAME_AT
	add_child(frame)
	for part: Array in [[Vector3(0, 0.4, 0), Vector3(0.9, 0.08, 0.06)], [Vector3(0, -0.4, 0), Vector3(0.9, 0.08, 0.06)],
			[Vector3(-0.41, 0, 0), Vector3(0.08, 0.88, 0.06)], [Vector3(0.41, 0, 0), Vector3(0.08, 0.88, 0.06)],
			[Vector3(0, 0, -0.01), Vector3(0.76, 0.76, 0.02)]]:
		var box := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = part[1]
		box.mesh = mesh
		box.material_override = _builder.material(BRASS if part[1].z > 0.03 else Color(0.25, 0.1, 0.12))
		box.position = part[0]
		frame.add_child(box)
	_label("Plaque", "SIGN_STAMP", FRAME_AT + Vector3(0, -0.6, 0.02), 0.0, 0.003, 32)
	_builder.mesh_box(SCALE_AT + Vector3(0, 0.4, 0), Vector3(1.0, 0.8, 1.0), METAL)
	_spot("scale", SCALE_AT + Vector3(0, 0.4, 0), Vector3(1.0, 0.8, 1.0), Vector3(0, 0, 1.0))
	_builder.mesh_box(SCALE_AT + Vector3(0, 0.82, 0), Vector3(0.9, 0.04, 0.9), METAL.lightened(0.2))
	_builder.box(SCALE_AT + Vector3(0, 1.2, -0.45), Vector3(0.6, 0.7, 0.1), WHITE)
	returns = ReturnsSack.new(Vector3(0.9, 0.9, 0.9))
	returns.name = "ReturnsSack"
	returns.position = RETURNS_AT + Vector3(0, 0.45, 0)
	add_child(returns)
	_sack(RETURNS_AT, "")
	_builder.box(BAGS_AT + Vector3(0, 0.25, 0), Vector3(0.5, 0.5, 0.4), WOOD)
	bags = EvidenceBags.new()
	bags.name = "EvidenceBags"
	bags.position = BAGS_AT + Vector3(0, 0.5, 0)
	add_child(bags)
	_label("ReturnsSign", "SIGN_RETURNS", RETURNS_AT + Vector3(0, 1.3, 0), PI / 2)
	for i in 6:
		var at := QUEUE_AT + Vector3((i % 3) * 1.5 - 1.5, 0, (i / 3) * 1.8 - 0.9)
		_builder.mesh_box(at + Vector3(0, 0.5, 0), Vector3(0.08, 1.0, 0.08), BRASS)
		if i % 3 < 2:
			_builder.mesh_box(at + Vector3(0.75, 0.9, 0), Vector3(1.5, 0.06, 0.02), RIBBON)


## The wall of post boxes: 24 small brass doors with their number, six of them with a route's color on the label.
func _boxes() -> void:
	_builder.box(Vector3(HALF_X - 0.2, 1.4, 3.3), Vector3(0.3, 2.8, 5.4), WOOD)
	var routes := {}
	for route: String in ROUTE_BOXES:
		routes[ROUTE_BOXES[route]] = route
	for i in BOX_ROWS * BOX_COLUMNS:
		var at := box_at(i)
		var door := Node3D.new()
		door.name = "Box%d" % i
		door.position = at
		add_child(door)
		var plate := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.04, BOX_SIZE - 0.08, BOX_SIZE)
		plate.mesh = mesh
		plate.material_override = _builder.material(BRASS)
		door.add_child(plate)
		var number := Label3D.new()
		number.text = str(i + 1)
		number.pixel_size = 0.003
		number.outline_size = 4
		number.position = Vector3(-0.03, 0.15, 0)
		number.rotation.y = -PI / 2
		door.add_child(number)
		if routes.has(i):
			_spot("box_" + routes[i], at, Vector3(0.12, BOX_SIZE - 0.08, BOX_SIZE), Vector3(-1.0, 0, 0))
			var tag := MeshInstance3D.new()
			tag.name = "Route"
			var tag_mesh := BoxMesh.new()
			tag_mesh.size = Vector3(0.02, 0.12, 0.3)
			tag.mesh = tag_mesh
			tag.material_override = _builder.material(ROUTE_COLORS[routes[i]])
			tag.position = Vector3(-0.03, -0.15, 0)
			door.add_child(tag)


## The sorting room: the big machine with its belts and rollers, the chute at its end and the sacks around it.
func _sorting() -> void:
	_builder.box(MACHINE_AT + Vector3(0, MACHINE_SIZE.y / 2, 0), MACHINE_SIZE, POST_BLUE)
	_builder.mesh_box(MACHINE_AT + Vector3(0, MACHINE_SIZE.y + 0.03, 0), Vector3(MACHINE_SIZE.x - 0.4, 0.06, 1.0), BLACK)
	var roller := CylinderMesh.new()
	roller.top_radius = 0.18
	roller.bottom_radius = 0.18
	roller.height = MACHINE_SIZE.z + 0.2
	for i in 5:
		_builder.mesh(roller, MACHINE_AT + Vector3(-3.2 + i * 1.6, MACHINE_SIZE.y + 0.25, 0), METAL,
			Vector3(PI / 2, 0, 0))
	_builder.box(MACHINE_AT + Vector3(-MACHINE_SIZE.x / 2 - 0.6, 1.6, 0), Vector3(1.2, 3.2, 1.6), POST_BLUE.darkened(0.3))
	_builder.mesh_box(MACHINE_AT + Vector3(MACHINE_SIZE.x / 2 + 0.4, 1.0, 0), Vector3(0.8, 0.1, 1.2), METAL)
	for i in SACKS_AT.size():
		_sack(SACKS_AT[i], "Sack%d" % i, "sack" if i == 0 else "")
	_builder.box(Vector3(-14.4, 0.9, -6.5), Vector3(1.0, 1.8, 6.0), WOOD)


## The boss's office: the open safe in the corner, the desk with the postmark book and its stamps, a chair, and the
## red button on the back wall.
func _office() -> void:
	_builder.box(SAFE_AT + Vector3(0, 0.7, 0), Vector3(1.2, 1.4, 1.0), BLACK)
	var door := MeshInstance3D.new()
	door.name = "SafeDoor"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.0, 1.2, 0.08)
	door.mesh = mesh
	door.material_override = _builder.material(BLACK.lightened(0.15))
	door.position = SAFE_AT + Vector3(-0.95, 0.7, 0.55)
	door.rotation.y = -PI / 2
	add_child(door)
	var dial := CylinderMesh.new()
	dial.top_radius = 0.12
	dial.bottom_radius = 0.12
	dial.height = 0.04
	_builder.mesh(dial, door.position + Vector3(-0.05, 0.1, 0), METAL, Vector3(0, 0, PI / 2))
	_builder.box(DESK_AT + Vector3(0, 0.45, 0), Vector3(2.0, 0.9, 1.0), WOOD)
	book = PostmarkBook.new(Vector3(0.6, 0.12, 0.45))
	book.name = "PostmarkBook"
	book.post_office = self
	book.position = DESK_AT + Vector3(-0.3, 0.96, 0)
	add_child(book)
	_builder.mesh_box(DESK_AT + Vector3(-0.3, 0.95, 0), Vector3(0.6, 0.1, 0.45), Color(0.45, 0.12, 0.12))
	_builder.mesh_box(DESK_AT + Vector3(0.5, 1.0, 0.1), Vector3(0.12, 0.2, 0.12), BLACK)
	_builder.box(DESK_AT + Vector3(0, 0.25, -1.0), Vector3(0.5, 0.5, 0.5), BLACK)
	_builder.mesh_box(BUTTON_AT + Vector3(0, 0, -0.02), Vector3(0.4, 0.4, 0.04), METAL)
	var knob := CylinderMesh.new()
	knob.top_radius = 0.12
	knob.bottom_radius = 0.12
	knob.height = 0.08
	_builder.mesh(knob, BUTTON_AT + Vector3(0, 0, 0.03), RIBBON, Vector3(PI / 2, 0, 0))
	button = RedButton.new()
	button.name = "RedButton"
	button.post_office = self
	button.position = BUTTON_AT
	add_child(button)


## The depot: two shelves of "Frágil" parcels against the office's wall and a stack on the floor.
func _depot() -> void:
	for x: float in [-2.0, 2.0]:
		var at := SHELVES_AT + Vector3(x, 0, 0)
		_builder.box(at + Vector3(0, 1.0, 0), Vector3(3.2, 2.0, 0.6), WOOD)
		for i in 3:
			_builder.mesh_box(at + Vector3(-1.0 + i * 1.0, 2.25, 0), Vector3(0.7, 0.5, 0.5), CARDBOARD)
	_builder.box(Vector3(13.5, 0.35, -1.0), Vector3(0.9, 0.7, 0.9), CARDBOARD)
	_label("FragileSign", "SIGN_FRAGILE", Vector3(13.5, 0.4, -0.53), 0.0, 0.004, 32)


## A sack of mail, standing, tied at the top. With a `spot`, it's that spot (E searches it); with no name, just the
## look (its body is made apart).
func _sack(at: Vector3, sack_name: String, spot := "") -> void:
	if spot == "" and sack_name != "":
		var body := _builder.body(at + Vector3(0, 0.45, 0))
		body.name = sack_name
		_builder.shape(body, Vector3(0.9, 0.9, 0.9))
	elif spot != "":
		_spot(spot, at + Vector3(0, 0.45, 0), Vector3(0.9, 0.9, 0.9), Vector3(1.0, 0, 0)).name = sack_name
	var bag := SphereMesh.new()
	bag.radius = 0.5
	bag.height = 1.1
	_builder.mesh(bag, at + Vector3(0, 0.5, 0), SACK)
	var knot := CylinderMesh.new()
	knot.top_radius = 0.12
	knot.bottom_radius = 0.08
	knot.height = 0.2
	_builder.mesh(knot, at + Vector3(0, 1.1, 0), SACK.darkened(0.2))


func _label(label_name: String, key: String, at: Vector3, turn: float, pixel := 0.006, font := 32) -> void:
	var label := Label3D.new()
	if label_name != "":
		label.name = label_name
	label.text = key
	label.pixel_size = pixel
	label.font_size = font
	label.outline_size = 8
	label.position = at
	label.rotation.y = turn
	add_child(label)


## A spot La Vaquita Azul can hide in, as a box the cops search with E; `out` is where the stamp lands when it turns up
## (on the floor).
func _spot(spot: String, at: Vector3, size: Vector3, out: Vector3) -> PostOfficeSpot:
	var body := PostOfficeSpot.new(size)
	body.name = "Search_" + spot
	body.spot = spot
	body.place = self
	body.position = at
	body.set_meta("out", out)
	add_child(body)
	loot_spots[spot] = body
	return body
