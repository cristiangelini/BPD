class_name Train
extends CrimeScenePlace

## The train El Lento (escena-tren.md, step 1, decision 202): its own level, out of the city. The train stands still
## along X with its front to +X and the scenery runs past (step 1c): from the back, the luggage car (the empty
## showcase and the broken window at the back), the dining car (four tables, the food cart's spot and the bathroom),
## first class (the six numbered seats, the luggage rack and the ticket machine) and the locomotive (don Silbato's
## cabin with the brake lever). The cars join by open doors over a gangway. TrainRide is the clock, and the sign over
## each door says the next station and how long to it. The people come in step 2 and the case in step 4. Every number here is (propuesta).

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
	Vector3(3, 0, -0.95), Vector3(6.5, 0, -0.95), Vector3(10, 0, -0.95),
	Vector3(3, 0, 0.95), Vector3(6.5, 0, 0.95), Vector3(10, 0, 0.95),
]
const TICKET_MACHINE_AT := Vector3(13.3, 0, -1.15)
const TABLES: Array[Vector3] = [Vector3(-11, 0, -0.95), Vector3(-6, 0, -0.95), Vector3(-11, 0, 0.95), Vector3(-6, 0, 0.95)]
const CART_AT := Vector3(-2.5, 0, 0)
## The bathroom, in the dining car's back corner beside its door: x from the end wall to BATHROOM_X, z from
## BATHROOM_Z to the side. Its door opens to the aisle.
const BATHROOM_X := -12.5
const BATHROOM_Z := 0.65
const SHOWCASE_AT := Vector3(-21, 0, -1.0)
const BROKEN_WINDOW_AT := Vector3(-30, 1.45, 0)
const BRAKE_AT := Vector3(22.8, 0, 0.9)
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
## The ceiling lamps.
var lamps: Array[OmniLight3D] = []
## The sign over each door: the next station and how long to it.
var signs: Array[Label3D] = []
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
	_update_signs()


func _physics_process(delta: float) -> void:
	ride.advance(delta)
	_update_signs()


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
		_build.box(at + Vector3(0, 0.25, 0), Vector3(0.7, 0.5, 0.9), VELVET)
		_build.box(at + Vector3(-0.32, 0.75, 0), Vector3(0.12, 0.9, 0.9), VELVET)
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
	_build.box(TICKET_MACHINE_AT + Vector3(0, 0.7, 0), Vector3(0.5, 1.4, 0.4), Color(0.8, 0.2, 0.2))
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
	_build.mesh_box(CART_AT + Vector3(0, 0.02, 0), Vector3(0.9, 0.04, 0.6), Color(0.8, 0.8, 0.82))


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
	_build.box(BRAKE_AT + Vector3(0, 0.55, 0), Vector3(0.06, 1.1, 0.06), Color(0.85, 0.15, 0.1))
	_build.box(Vector3(span.x + 4, 0.75, 0), Vector3(5, 1.5, 1.2), Color(0.1, 0.1, 0.1))
	_build.mesh_box(Vector3(span.y + 0.7, -0.2, 0), Vector3(1.4, 1.4, WIDTH), Color(0.8, 0.15, 0.1))
