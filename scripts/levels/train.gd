class_name Train
extends CrimeScenePlace

## The train El Lento (escena-tren.md, step 1, decision 202): its own level, out of the city. The train stands still
## along X with its front to +X and the scenery runs past (TrainScenery): from the back, the luggage car (the empty
## showcase and the broken window at the back), the dining car (four tables, the food cart's spot and the bathroom),
## first class (the six numbered seats, the luggage rack and the ticket machine) and the locomotive (don Silbato's
## cabin with the brake lever). The cars join by open doors over a gangway. TrainRide is the clock: five stations,
## a tunnel in each leg that switches off the lamps, and the sign over each door with the next station and how long
## to it. In first class, the six magicians alike in front of their seats (MagicianTraits, TrainMagician); don
## Silbato, Picadora and señor Mostaza with his cart (TrainStaff) at their posts (step 2). The case comes in step 4.
## Every number here is (propuesta).

## The cars' floor is this high above the rails' ground.
const FLOOR_Y := 1.0
const WIDTH := 3.0
## Each car's x range, from the back: luggage, dining, first class and the locomotive.
const CARS := {
	"luggage": Vector2(-30, -16),
	"dining": Vector2(-15, -1),
	"first": Vector2(0, 14),
	"engine": Vector2(15, 24),
}
const CAR_NAMES: Array[String] = ["luggage", "dining", "first", "engine"]
## The side windows: one every WINDOW_EVERY meters, WINDOW wide, from sill to lintel.
const WINDOW_EVERY := 2.0
const WINDOW := 1.3
const SILL := 0.9
const LINTEL := 2.0
## The six seats of first class, numbered from 1: three a side of the aisle, facing the front.
const SEATS: Array[Vector3] = [
	Vector3(3, 0, -1.05), Vector3(6.5, 0, -1.05), Vector3(10, 0, -1.05),
	Vector3(3, 0, 1.05), Vector3(6.5, 0, 1.05), Vector3(10, 0, 1.05),
]
const TICKET_MACHINE_AT := Vector3(13.3, 0, -1.15)
const TABLES: Array[Vector3] = [Vector3(-11, 0, 0.95), Vector3(-7.5, 0, 0.95), Vector3(-4, 0, 0.95)]
## The portable board hangs on the dining car's other side, over its windows, with the rubber stamp's desk by it
## (CrimeBoard, BoardStamp; TrainLevel puts them).
const BOARD_AT := Transform3D(Basis.IDENTITY, Vector3(-8, FLOOR_Y - 0.25, -1.42))
const STAMP_AT := Vector3(-4.2, FLOOR_Y, -1.0)
const CART_AT := Vector3(-1.8, 0, -0.95)
## The bathroom, in the dining car's back corner beside its door: x from the end wall to BATHROOM_X, z from
## BATHROOM_Z to the side. Its door opens to the aisle.
const BATHROOM_X := -12.5
const BATHROOM_Z := 0.65
const SHOWCASE_AT := Vector3(-21, 0, -1.0)
const BROKEN_WINDOW_AT := Vector3(-30, 1.45, 0)
const BRAKE_AT := Vector3(22.8, 0, 0.9)
## The emergency brake stops the ride this long, costs this much off the salary each time, and works this many times.
const BRAKE_SECONDS := 60.0
const BRAKE_FINE := 100
const BRAKE_PULLS := 2
## Where the people stand: each magician in front of his seat, facing the aisle; don Silbato at the brake, Picadora
## by the ticket machine and señor Mostaza behind his cart.
const IN_FRONT_OF_SEAT := Vector3(0.75, 0, 0)
const ENGINEER_AT := Vector3(22.0, 0, 0.2)
const INSPECTOR_AT := Vector3(12.4, 0, 0.95)
const VENDOR_AT := Vector3(-2.7, 0, -0.95)
const CART_MODEL := preload("res://assets/models/train_cart.glb")
## The roll of numbered stickers, on top of the ticket machine.
const STICKERS_AT := TICKET_MACHINE_AT + Vector3(0, 1.45, 0)
## What was stolen, drawn with the seed (escena-tren.md, pregunta 1), and where it can be hidden: in a spare top hat
## on first class's luggage rack, in the food cart or in the bathroom's water tank.
const LOOTS: Array[String] = ["rabbit", "wand", "watch"]
const LOOT_SPOTS: Array[String] = ["hat", "food_cart", "tank"]
const LOOT_MODELS := {
	"rabbit": preload("res://assets/models/golden_rabbit.glb"),
	"wand": preload("res://assets/models/magic_wand.glb"),
	"watch": preload("res://assets/models/pocket_watch.glb"),
}
const HAT_RACK_AT := Vector3(8.5, 2.3, -1.15)
## The roll of evidence bags, on a shelf in the dining car's back corner, across from the bathroom.
const BAGS_AT := Vector3(-14.4, 0, -1.15)
const TANK_AT := Vector3(-14.65, 0.75, 1.1)
## Where a cop gets on: first class's aisle, by the back door.
const SPAWN_AT := Vector3(1.5, FLOOR_Y + 0.1, 0)
const BODY := Color(0.18, 0.32, 0.25)
const INSIDE := Color(0.85, 0.78, 0.62)
const FLOOR := Color(0.42, 0.28, 0.18)
const VELVET := Color(0.55, 0.1, 0.15)
const GLASS := Color(0.7, 0.85, 0.95, 0.25)
const BRASS := Color(0.85, 0.68, 0.3)
const DARK := Color(0.15, 0.15, 0.17)
const TILE := Color(0.75, 0.88, 0.92)
const CLOTH := Color(0.95, 0.95, 0.9)
const LEATHER := Color(0.45, 0.28, 0.15)

var ride := TrainRide.new()
## The ceiling lamps, which go off in the tunnels.
var lamps: Array[OmniLight3D] = []
## The sign over each door: the next station and how long to it.
var signs: Array[Label3D] = []
var scenery: TrainScenery
var magicians: Array[TrainMagician] = []
var engineer: TrainStaff
var inspector: TrainStaff
var vendor: TrainStaff
var cart: StaticBody3D
var case: CrimeSceneCase
## Which seat (index in SEATS) each magician is in now; they swap in every tunnel.
var seat_of: Array[int] = [0, 1, 2, 3, 4, 5]
## Who wears which sticker: number -> magician index, and the last magician each number was on.
var stickers := {}
var last_wearer := {}
## The culprit peels his sticker off in the first tunnel he goes through with one, only once.
var culprit_peeled := false
var _was_tunnel := false
## What was stolen and where it is (drawn with the case seed in set_up_case), and whether the cops found it.
var loot := "rabbit"
var loot_spot := "hat"
var loot_found := false
## The searchable places, by spot.
var loot_spots := {}
## The case's clues where they go (TrainClues, step 4b), once the case comes.
var clues: TrainClues
## Who has a ticket from the machine, by cop name (Picadora talks only to them), and the brake.
var tickets := {}
var ticket_machine: TrainTicketMachine
var brake: TrainBrake
var brake_pulls := 0
var brake_left := 0.0
var _cars: Node3D
var _build: PlaceBuilder


func _init() -> void:
	variant = "train"


func _ready() -> void:
	_cars = Node3D.new()
	_cars.name = "Cars"
	_cars.position.y = FLOOR_Y
	add_child(_cars)
	_build = PlaceBuilder.new(_cars)
	for car: String in CAR_NAMES:
		_car(CARS[car], car)
	_first_class()
	_dining()
	_luggage()
	_engine()
	_people()
	scenery = TrainScenery.new()
	scenery.name = "Scenery"
	scenery.ride = ride
	add_child(scenery)
	_update_signs()


func _physics_process(delta: float) -> void:
	# Braked, the train stands in the field and the stations' clock waits.
	if brake_left > 0.0:
		brake_left = maxf(brake_left - delta, 0.0)
	else:
		ride.advance(delta)
	var dark := ride.in_tunnel()
	for lamp in lamps:
		lamp.visible = not dark
	if dark and not _was_tunnel:
		_into_tunnel()
	elif _was_tunnel and not dark:
		for magician in magicians:
			magician.say("MAGICIAN_TA_DA", 2.0)
	_was_tunnel = dark
	_update_signs()
	if case and ride.arrived():
		case.end_of_line()


func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot = LOOTS[hash(["train loot", case.case_seed]) % LOOTS.size()]
	loot_spot = LOOT_SPOTS[hash(["train loot spot", case.case_seed]) % LOOT_SPOTS.size()]
	for magician in magicians:
		magician.case = case
	inspector.knows = case.plan.clues.has("witness")
	clues = TrainClues.new()
	clues.name = "Clues"
	clues.train = self
	clues.case = case
	add_child(clues)


## The emergency brake: the train stops BRAKE_SECONDS, don Silbato shouts, it comes off the salary and Picadora,
## who was punching tickets, falls over and won't talk anymore.
func pull_brake() -> void:
	brake_pulls += 1
	brake_left = BRAKE_SECONDS
	engineer.say("TRAIN_ENGINEER_BRAKE")
	if case:
		case.spend(BRAKE_FINE)
	inspector.offend()


func has_ticket(cop: Cop) -> bool:
	return tickets.has(str(cop.name))


func witness_offended() -> bool:
	return inspector.offended


func offend_witness() -> void:
	inspector.offend()


## The node the cars are built in (FLOOR_Y up): the clues go in it too.
func cars() -> Node3D:
	return _cars


## Searching a spot: the stolen thing turns up in the right one; a sign of nothing in the others.
func search(spot: String, cop: Cop) -> void:
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
	_cars.add_child(item)
	var spot := loot_spots[loot_spot] as Node3D
	var out: Vector3 = spot.get_meta("out")
	item.position = Vector3(spot.position.x, 0.0, spot.position.z) + out * 0.6
	if case:
		case.found_loot()


## In the dark the six swap seats (the order drawn with the seed and the leg), and the culprit peels his sticker
## off the first time he can. A guest's train follows the host's (step 6).
func _into_tunnel() -> void:
	if case and case.follower:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["train tunnel", case_seed, ride.leg()])
	var order: Array[int] = seat_of.duplicate()
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := order[i]
		order[i] = order[j]
		order[j] = swap
	for i in magicians.size():
		seat(i, order[i])
	var culprit := CrimePlan.culprit_of(MagicianTraits.COUNT, case_seed)
	if not culprit_peeled and sticker_of(culprit) >= 0:
		culprit_peeled = true
		drop_sticker(magicians[culprit])


## Puts a magician in front of a seat, facing the aisle.
func seat(index: int, seat_index: int) -> void:
	seat_of[index] = seat_index
	var magician := magicians[index]
	magician.position = SEATS[seat_index] + IN_FRONT_OF_SEAT
	magician.rotation.y = 0.0 if SEATS[seat_index].z < 0 else PI


## Sticks sticker `number` on a magician's cape; the one he had falls at his feet. What he shows already (his hair,
## with the hat off) goes to that file right away.
func stick_sticker(number: int, magician: TrainMagician) -> void:
	var had := sticker_of(magician.index)
	if had == number:
		return
	if had >= 0:
		drop_sticker(magician)
	stickers[number] = magician.index
	last_wearer[number] = magician.index
	magician.show_sticker(number)
	magician.say(tr("MAGICIAN_STUCK") % (number + 1))
	if case and not magician.hat_on:
		case.magician_part(magician.index, "hair")


## A magician's sticker falls at his feet, a sticker to pick up again.
func drop_sticker(magician: TrainMagician) -> void:
	var number := sticker_of(magician.index)
	if number < 0:
		return
	stickers.erase(number)
	magician.show_sticker(-1)
	_sticker(number, magician.global_position + magician.global_basis.z * 0.6 + Vector3.UP * 0.1)


## The number of the sticker on a magician's cape, or -1.
func sticker_of(magician_index: int) -> int:
	for number: int in stickers:
		if stickers[number] == magician_index:
			return number
	return -1


## The magician wearing a sticker now, or the last one who did (-1 if nobody ever did).
func wearer(number: int) -> int:
	return stickers.get(number, last_wearer.get(number, -1))


func _sticker(number: int, world: Vector3) -> TrainSticker:
	var sticker := TrainSticker.new()
	sticker.name = "Sticker%d" % number
	sticker.number = number
	add_child(sticker)
	sticker.global_position = world
	return sticker


func suspect(index: int) -> CollisionObject3D:
	return magicians[index] if index < magicians.size() else null


## The car (by index in CAR_NAMES) a point in the world is in, or -1.
func car_of(world: Vector3) -> int:
	var at := to_local(world)
	if absf(at.z) > WIDTH / 2 or at.y < FLOOR_Y - 0.5 or at.y > FLOOR_Y + GameScale.FLOOR_HEIGHT + 0.5:
		return -1
	for i in CAR_NAMES.size():
		var span: Vector2 = CARS[CAR_NAMES[i]]
		if at.x >= span.x and at.x <= span.y:
			return i
	return -1


func at_scene(world: Vector3) -> bool:
	var at := to_local(world)
	return absf(at.z) <= WIDTH / 2 and at.x >= CARS["luggage"].x and at.x <= CARS["engine"].y


func _update_signs() -> void:
	var text := tr("TRAIN_LAST_STOP") if ride.arrived() else (
		tr("TRAIN_AT_STATION") % tr(TrainRide.NAMES[ride.next_station()]) if ride.stopped() else
		tr("TRAIN_NEXT_STATION") % [tr(TrainRide.NAMES[ride.next_station()]), ceili(ride.time_to_station())])
	for label in signs:
		label.text = text


## A car's shell: floor, roof, the end walls with their door and the two sides with windows; its lamp, its signs and
## the gangway to the car in front.
func _car(span: Vector2, car: String) -> void:
	var half := WIDTH / 2
	var top := GameScale.FLOOR_HEIGHT
	_build.slab(span.x, span.y, -half, half, 0.0, FLOOR)
	_build.box(Vector3((span.x + span.y) / 2, top + 0.05, 0), Vector3(span.y - span.x, 0.1, WIDTH + 0.1), BODY)
	var back_doors := [] if car == "luggage" else [0.0]
	var front_doors := [] if car == "engine" else [0.0]
	_build.wall("z", span.x, -half, half, 0, back_doors, BODY)
	_build.wall("z", span.y, -half, half, 0, front_doors, BODY)
	for side: float in [-half, half]:
		_side(span, side)
	var lamp := _build.light(Vector3((span.x + span.y) / 2, top - 0.4, 0))
	lamp.omni_range = 10.0
	lamps.append(lamp)
	for end: float in [span.x + 0.1, span.y - 0.1]:
		var label := Label3D.new()
		label.name = "Sign"
		label.font_size = 40
		label.pixel_size = 0.005
		label.modulate = Color(1.0, 0.75, 0.2)
		label.outline_size = 8
		label.position = Vector3(end, GameScale.DOOR_HEIGHT + 0.25, 0)
		label.rotation.y = PI / 2 if end < (span.x + span.y) / 2 else -PI / 2
		_cars.add_child(label)
		signs.append(label)
	if car != "engine":
		_build.slab(span.y, span.y + 1.0, -GameScale.DOOR_WIDTH / 2, GameScale.DOOR_WIDTH / 2, 0.0, DARK)
		for z: float in [-GameScale.DOOR_WIDTH / 2, GameScale.DOOR_WIDTH / 2]:
			_build.box(Vector3(span.y + 0.5, 1.1, z), Vector3(1.0, 2.2, 0.05), DARK)


## One side of a car at z = side: under the sills, over the lintels, the posts between windows and the glass.
func _side(span: Vector2, side: float) -> void:
	var length := span.y - span.x
	var mid := (span.x + span.y) / 2
	var top := GameScale.FLOOR_HEIGHT
	_build.box(Vector3(mid, SILL / 2, side), Vector3(length, SILL, 0.12), BODY)
	_build.box(Vector3(mid, (LINTEL + top) / 2, side), Vector3(length, top - LINTEL, 0.12), BODY)
	var windows := int(length / WINDOW_EVERY)
	var first := mid - (windows - 1) * WINDOW_EVERY / 2
	var edge := span.x
	for i in windows:
		var x := first + i * WINDOW_EVERY
		_post(edge, x - WINDOW / 2, side)
		_build.box(Vector3(x, (SILL + LINTEL) / 2, side), Vector3(WINDOW, LINTEL - SILL, 0.03), GLASS)
		edge = x + WINDOW / 2
	_post(edge, span.y, side)


func _post(from: float, to: float, side: float) -> void:
	if to - from > 0.01:
		_build.box(Vector3((from + to) / 2, (SILL + LINTEL) / 2, side), Vector3(to - from, LINTEL - SILL, 0.12), BODY)


func _first_class() -> void:
	for i in SEATS.size():
		var at: Vector3 = SEATS[i]
		_build.box(at + Vector3(0, 0.25, 0), Vector3(0.7, 0.5, 0.7), VELVET)
		_build.box(at + Vector3(-0.32, 0.75, 0), Vector3(0.12, 0.9, 0.7), VELVET)
		var number := Label3D.new()
		number.name = "Seat%d" % (i + 1)
		number.text = str(i + 1)
		number.font_size = 48
		number.pixel_size = 0.006
		number.modulate = BRASS
		number.position = at + Vector3(-0.39, 1.1, 0)
		number.rotation.y = -PI / 2
		_cars.add_child(number)
	for side: float in [-1.0, 1.0]:
		_build.mesh_box(Vector3(7, 2.15, side * 1.15), Vector3(13, 0.05, 0.6), BRASS)
	_build.mesh_box(TICKET_MACHINE_AT + Vector3(0, 0.7, 0), Vector3(0.5, 1.4, 0.4), Color(0.8, 0.2, 0.2))
	ticket_machine = TrainTicketMachine.new()
	ticket_machine.name = "TicketMachine"
	ticket_machine.train = self
	ticket_machine.position = TICKET_MACHINE_AT
	_cars.add_child(ticket_machine)
	_build.mesh_box(TICKET_MACHINE_AT + Vector3(-0.26, 1.1, 0), Vector3(0.02, 0.25, 0.3), DARK)


func _dining() -> void:
	for at: Vector3 in TABLES:
		_build.box(at + Vector3(0, 0.75, 0), Vector3(1.0, 0.06, 0.8), CLOTH)
		_build.box(at + Vector3(0, 0.37, 0), Vector3(0.1, 0.74, 0.1), DARK)
		for dx: float in [-0.9, 0.9]:
			_build.box(at + Vector3(dx, 0.23, 0), Vector3(0.45, 0.46, 0.8), VELVET)
	var back: float = CARS["dining"].x
	_build.wall("x", BATHROOM_Z, back, BATHROOM_X, 0, [(back + BATHROOM_X) / 2], INSIDE)
	_build.wall("z", BATHROOM_X, BATHROOM_Z, WIDTH / 2, 0, [], INSIDE)
	_build.box(Vector3(back + 0.35, 0.2, 1.1), Vector3(0.5, 0.4, 0.6), TILE)
	_build.box(Vector3(BATHROOM_X - 0.3, 0.8, 1.2), Vector3(0.4, 0.15, 0.4), CLOTH)


func _luggage() -> void:
	var span: Vector2 = CARS["luggage"]
	for i in 7:
		var at := Vector3(span.x + 2.5 + i * 1.6, 0, 1.0 if i % 2 == 0 else -1.0)
		_build.box(at + Vector3(0, 0.3, 0), Vector3(0.9, 0.6, 0.6), LEATHER if i % 3 else BRASS.darkened(0.4))
	for i in 3:
		_build.open_box(Vector3(-26.5 + i * 1.2, 0.6, -1.1), Vector3(0.6, 0.6, 0.5), "+z", BRASS)
	_build.box(SHOWCASE_AT + Vector3(0, 0.45, 0), Vector3(0.8, 0.9, 0.6), DARK)
	_build.box(SHOWCASE_AT + Vector3(0, 1.2, 0), Vector3(0.7, 0.6, 0.5), GLASS)
	# The back end has no door: a window, broken, with the night's wind.
	_build.mesh_box(BROKEN_WINDOW_AT + Vector3(0.02, 0, 0), Vector3(0.02, 0.7, 1.0), Color(0.05, 0.05, 0.08))


func _engine() -> void:
	var span: Vector2 = CARS["engine"]
	_build.box(BRAKE_AT + Vector3(0, 0.5, -0.9), Vector3(0.8, 1.0, 1.2), DARK)
	brake = TrainBrake.new()
	brake.name = "Brake"
	brake.train = self
	brake.position = BRAKE_AT
	_cars.add_child(brake)
	_build.box(Vector3(span.x + 4, 0.75, -0.9), Vector3(5, 1.5, 1.0), Color(0.1, 0.1, 0.1))
	_build.mesh_box(Vector3(span.y + 0.7, -0.2, 0), Vector3(1.4, 1.4, WIDTH), Color(0.8, 0.15, 0.1))


## The six magicians in front of their seats (traits drawn with the case seed), the three of the staff and the cart.
func _people() -> void:
	var all_traits := MagicianTraits.draw(case_seed)
	for i in all_traits.size():
		var magician := TrainMagician.new()
		magician.name = "Magician%d" % (i + 1)
		magician.traits = all_traits[i]
		magician.index = i
		magician.train = self
		_cars.add_child(magician)
		magicians.append(magician)
		seat(i, i)
	for i in MagicianTraits.COUNT:
		var sticker := _sticker(i, to_global(STICKERS_AT + Vector3(0, FLOOR_Y + i * 0.012, 0)))
		sticker.rotation.x = -PI / 2
	engineer = _staff("engineer", ENGINEER_AT, PI / 2)
	inspector = _staff("inspector", INSPECTOR_AT, -PI / 2)
	vendor = _staff("vendor", VENDOR_AT, PI / 2)
	cart = StaticBody3D.new()
	cart.name = "Cart"
	cart.position = CART_AT
	_cars.add_child(cart)
	_build.shape(cart, Vector3(0.9, 0.9, 0.6))
	cart.get_child(0).position.y = 0.45
	cart.add_child(CART_MODEL.instantiate())
	_loot_spot("hat", HAT_RACK_AT, Vector3(1.2, 0.3, 0.5), Vector3(0, 0, 1))
	_loot_spot("food_cart", CART_AT + Vector3(0, 0.95, 0), Vector3(0.9, 0.15, 0.6), Vector3(0, 0, 1))
	_loot_spot("tank", TANK_AT, Vector3(0.3, 0.4, 0.5), Vector3(1, 0, 0))
	_build.mesh_box(TANK_AT, Vector3(0.22, 0.35, 0.45), TILE)
	_build.box(BAGS_AT + Vector3(0, 0.45, 0), Vector3(0.5, 0.9, 0.4), LEATHER)
	bags = EvidenceBags.new()
	bags.name = "EvidenceBags"
	bags.position = BAGS_AT + Vector3(0, 0.9, 0)
	_cars.add_child(bags)
	for i in 3:
		_build.mesh_box(HAT_RACK_AT + Vector3(-0.4 + i * 0.4, -0.02, 0), Vector3(0.28, 0.3, 0.28), DARK)


func _loot_spot(spot: String, at: Vector3, size: Vector3, out: Vector3) -> void:
	var body := LootSpot.new(size)
	body.name = "Search_" + spot
	body.spot = spot
	body.place = self
	body.position = at
	body.set_meta("out", out)
	_cars.add_child(body)
	loot_spots[spot] = body


func _staff(role: String, at: Vector3, turn: float) -> TrainStaff:
	var person := TrainStaff.new()
	person.name = role.capitalize()
	person.role = role
	person.train = self
	person.position = at
	person.rotation.y = turn
	_cars.add_child(person)
	return person
