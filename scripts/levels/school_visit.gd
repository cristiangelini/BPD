class_name SchoolVisitLevel
extends Node3D

## The Los Girasoles primary school (politico-escuela.md, step 2, decision 210), where Deputy Lustre comes to visit: a
## one-floor building on block (3, 3), the front to +Z, and the playground behind it. Through the front door, the hall
## with the founder's bust and the coat pegs; to the west, the classroom with 20 small desks in 4 rows facing the
## blackboard on the back wall, the teacher's desk with the candy box and Señorita Rosa (SchoolAdult); to the east,
## a corridor with the backpacks and the door out to the playground: the slide, the sandbox and the janitor's shed with
## his cleaning cart. Each desk has its pupil (SchoolPupil), their looks drawn by the seed, and Don Tito the janitor
## sweeps the hall. The cops start in the station and drive here; --place=school_visit opens it from Play. Step 3:
## Deputy Lustre waits on the sidewalk and his visit (SchoolTour) is the case's clock: the talk, recess in the
## playground, the questions and the group photo out front. Every number here is (propuesta).

## The building (CityLayout "school_visit"): 28 x 12 m under one roof, with the playground (28 x 12 m more) behind it.
const HALF_X := 14.0
const FRONT_Z := 12.0
## The back wall of the building, with the playground's door; the playground ends at the fence.
const BACK_Z := 0.0
const FENCE_Z := -12.0
const FENCE_HEIGHT := 2.2
const FLOOR_TOP := 0.06
## The hall's back wall (the classroom's front) and the classroom's east wall.
const HALL_Z := 9.0
const CLASS_EAST := 4.0
## Door gaps: the front door, the classroom's and the playground's.
const FRONT_DOOR_X := 0.0
const CLASS_DOOR_X := -5.0
const YARD_DOOR_X := 9.0
## The 20 desks: 5 across (x) in 4 rows (z, from the front of the classroom), the pupil behind each.
const DESK_X: Array[float] = [-11.0, -8.0, -5.0, -2.0, 1.0]
const DESK_ROWS: Array[float] = [3.6, 5.0, 6.4, 7.8]
const DESK := Vector3(0.8, 0.55, 0.5)
## How far in front of the pupil the desk is (the pupils face -Z, the blackboard).
const DESK_AHEAD := 0.5
const PUPILS := 20
## The blackboard on the back wall and where the deputy stands to talk, in front of it.
const BOARD := Vector3(-5.0, 1.5, BACK_Z + 0.1)
const BOARD_SIZE := Vector2(4.0, 1.2)
const STAGE := Vector3(-5.0, 0, 1.6)
## The teacher's desk, with the candy box on it, and where she stands.
const TEACHER_DESK := Vector3(-10.0, 0, 1.4)
const TEACHER_AT := Vector3(-11.2, 0, 2.0)
## The janitor sweeps the hall at the start.
const JANITOR_AT := Vector3(7.0, 0, 10.6)
## The playground: the slide, the sandbox and the janitor's shed in the north-east corner, its door to the west.
const SLIDE := Vector3(-8.0, 0, -6.0)
const SANDBOX := Rect2(-3.5, -9.5, 3.0, 3.0)
const SHED := Rect2(8.0, -12.0, 6.0, 4.5)
const SHED_DOOR_Z := -9.75
const CART_AT := Vector3(11.5, 0, -10.0)
## The corners everyone walks through (step 3): inside the classroom's door, the hall by it and by the corridor, the
## corridor by the playground's door and just out of it, and inside and outside the front door.
const CLASS_DOOR_IN := Vector3(-5.0, 0, 8.4)
const HALL_WEST := Vector3(-5.0, 0, 10.5)
const HALL_EAST := Vector3(9.0, 0, 10.5)
const CORRIDOR := Vector3(9.0, 0, 1.0)
const YARD_IN := Vector3(9.0, 0, -1.0)
const FRONT_IN := Vector3(0.0, 0, 10.5)
const FRONT_OUT := Vector3(0.0, 0, 13.6)
## Where the deputy waits for his guard, on the sidewalk by the front door.
const WAITING_AT := Vector3(2.0, 0, 14.0)
## Where the pupils play at recess: anywhere in this part of the playground, clear of the shed.
const RECESS_AREA := Rect2(-12.0, -10.5, 18.0, 8.5)
## The group photo on the sidewalk: the deputy against the wall, the pupils in two rows of 10 in front of him.
const PHOTO_DEPUTY := Vector3(0.0, 0, 12.8)
const PHOTO_ROWS: Array[float] = [13.7, 14.4]

const WALL := Color(0.95, 0.85, 0.55)
const TRIM := Color(0.45, 0.4, 0.55)
const CEILING := Color(0.95, 0.93, 0.88)
const FLOOR := Color(0.78, 0.72, 0.62)
const YARD := Color(0.62, 0.6, 0.56)
const WOOD := Color(0.72, 0.52, 0.32)
const GREEN_BOARD := Color(0.16, 0.32, 0.22)
const SAND := Color(0.93, 0.83, 0.55)
const SLIDE_RED := Color(0.9, 0.25, 0.2)
const METAL := Color(0.7, 0.72, 0.75)
const BUST := Color(0.8, 0.78, 0.74)
const CANDY := Color(0.95, 0.4, 0.65)
const CART := Color(0.95, 0.75, 0.15)
const BAGS: Array[Color] = [Color(0.85, 0.2, 0.2), Color(0.95, 0.75, 0.2), Color(0.25, 0.6, 0.3), Color(0.55, 0.3, 0.8)]

## The case's seed: which pupil looks how (step 2), which cards are traps (later steps).
var case_seed := 0
var pupils: Array[SchoolPupil] = []
var teacher: SchoolAdult
var janitor: SchoolAdult
## Deputy Lustre and his visit, the clock of the case (step 3).
var politician: Politician
var tour: SchoolTour
var _build: PlaceBuilder

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_classroom()
	_build_hall()
	_build_yard()
	_place_people()
	politician = Politician.new()
	politician.name = "Politician"
	add_child(politician)
	politician.position = WAITING_AT + Vector3.UP * FLOOR_TOP
	# Facing the street, waiting for his guard.
	politician.rotation.y = PI
	tour = SchoolTour.new()
	tour.name = "Tour"
	tour.setup(self, politician, case_seed)
	add_child(tour)
	city.transform = CityLayout.anchor("school_visit")
	car.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)


## Which look each of the 20 pupils has, desk by desk: the four looks dealt by the seed, five each.
static func looks_for(seed_value: int) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["school pupils", seed_value])
	var looks: Array[int] = []
	for i in PUPILS:
		looks.append(i % SchoolPupil.MODELS.size())
	for i in range(looks.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := looks[i]
		looks[i] = looks[j]
		looks[j] = swap
	return looks


## Where pupil `desk` sits (0 to 19, row by row from the front), in the school's space.
static func seat(desk: int) -> Vector3:
	return Vector3(DESK_X[desk % DESK_X.size()], 0, DESK_ROWS[desk / DESK_X.size()])


## The aisle beside desk `desk`, east of it: where its pupil steps out to before walking along the rows.
static func aisle_of(desk: int) -> float:
	return seat(desk).x + 1.5


## The way from desk `desk` to the classroom's door, in the school's space (the door last).
static func desk_to_door(desk: int) -> Array[Vector3]:
	var at := seat(desk)
	return [Vector3(aisle_of(desk), 0, at.z), Vector3(aisle_of(desk), 0, CLASS_DOOR_IN.z), CLASS_DOOR_IN]


## From desk `desk` out to the playground, ending at `spot` (all in world space).
func route_to_yard(desk: int, spot: Vector3) -> Array[Vector3]:
	var points: Array[Vector3] = desk_to_door(desk)
	points.append_array([HALL_WEST, HALL_EAST, CORRIDOR, YARD_IN])
	var out := _world(points)
	out.append(spot)
	return out


## From the playground back to desk `desk`.
func route_to_desk(desk: int) -> Array[Vector3]:
	var points: Array[Vector3] = [YARD_IN, CORRIDOR, HALL_EAST, HALL_WEST]
	var back := desk_to_door(desk)
	back.reverse()
	points.append_array(back)
	points.append(seat(desk))
	return _world(points)


## From desk `desk` out the front door, ending at `spot`.
func route_out_front(desk: int, spot: Vector3) -> Array[Vector3]:
	var points: Array[Vector3] = desk_to_door(desk)
	points.append_array([HALL_WEST, FRONT_IN, FRONT_OUT])
	var out := _world(points)
	out.append(spot)
	return out


## The deputy's ways: from the sidewalk to the blackboard, from there to the playground, back, and out for the photo.
func deputy_in() -> Array[Vector3]:
	return _world([FRONT_OUT, FRONT_IN, HALL_WEST, CLASS_DOOR_IN, STAGE])


func deputy_to_yard() -> Array[Vector3]:
	return _world([CLASS_DOOR_IN, HALL_WEST, HALL_EAST, CORRIDOR, YARD_IN])


func deputy_to_class() -> Array[Vector3]:
	return _world([YARD_IN, CORRIDOR, HALL_EAST, HALL_WEST, CLASS_DOOR_IN, STAGE])


func deputy_out() -> Array[Vector3]:
	return _world([CLASS_DOOR_IN, HALL_WEST, FRONT_IN, FRONT_OUT, PHOTO_DEPUTY])


## Where pupil `desk` plays at recess (world space), drawn by the seed.
func recess_spot(desk: int) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["school recess", case_seed, desk])
	return to_global(Vector3(rng.randf_range(RECESS_AREA.position.x, RECESS_AREA.end.x), 0,
		rng.randf_range(RECESS_AREA.position.y, RECESS_AREA.end.y)))


## Where pupil `desk` stands for the group photo (world space): two rows of 10 in front of the deputy.
func photo_spot(desk: int) -> Vector3:
	var row := desk / 10
	return to_global(Vector3(-4.5 + (desk % 10), 0, PHOTO_ROWS[row]))


func _world(points: Array[Vector3]) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for point in points:
		out.append(to_global(point))
	return out


## Whether a world position is in the classroom.
func in_classroom(at: Vector3) -> bool:
	var local := to_local(at)
	return local.x > -HALF_X and local.x < CLASS_EAST and local.z > BACK_Z and local.z < HALL_Z


## Whether a world position is in the playground.
func in_yard(at: Vector3) -> bool:
	var local := to_local(at)
	return absf(local.x) < HALF_X and local.z < BACK_Z and local.z > FENCE_Z


## The floor, the outer walls with the front and playground doors, the roof and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP + 0.02, FLOOR)
	# The roof rests on the walls (they stop a slab short of the floor height).
	_build.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, GameScale.FLOOR_HEIGHT, CEILING)
	_build.wall("x", FRONT_Z, -HALF_X, HALF_X, 0, [FRONT_DOOR_X], WALL)
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [YARD_DOOR_X], WALL)
	_build.wall("z", -HALF_X, BACK_Z, FRONT_Z, 0, [], WALL)
	_build.wall("z", HALF_X, BACK_Z, FRONT_Z, 0, [], WALL)
	_label("PLACE_SCHOOL_VISIT", Vector3(0, GameScale.FLOOR_HEIGHT + 0.7, FRONT_Z + 0.12), 0.0, 80)
	for x: float in [-9.0, -2.0, 9.0]:
		for z: float in [3.0, 7.5]:
			_build.light(Vector3(x, GameScale.FLOOR_HEIGHT - 0.4, z))
	_build.light(Vector3(0, GameScale.FLOOR_HEIGHT - 0.4, 10.5))


## The classroom: its walls, the blackboard, the teacher's desk with the candy box and the 20 desks.
func _build_classroom() -> void:
	_build.wall("x", HALL_Z, -HALF_X, CLASS_EAST, 0, [CLASS_DOOR_X], WALL)
	_build.wall("z", CLASS_EAST, BACK_Z, HALL_Z, 0, [], WALL)
	_build.mesh_box(BOARD, Vector3(BOARD_SIZE.x, BOARD_SIZE.y, 0.05), GREEN_BOARD)
	_build.mesh_box(BOARD + Vector3(0, -BOARD_SIZE.y / 2 - 0.05, 0.06), Vector3(BOARD_SIZE.x, 0.05, 0.12), WOOD)
	_label("SCHOOL_BOARD", BOARD + Vector3(0, 0.2, 0.04), 0.0, 40)
	_build.box(TEACHER_DESK + Vector3(0, 0.38, 0), Vector3(1.4, 0.76, 0.7), WOOD)
	_build.mesh_box(TEACHER_DESK + Vector3(0.4, 0.84, 0), Vector3(0.3, 0.16, 0.2), CANDY)
	for desk in PUPILS:
		var at := seat(desk) + Vector3(0, FLOOR_TOP, -DESK_AHEAD)
		_build.box(at + Vector3(0, DESK.y / 2, 0), DESK, WOOD)
		_build.mesh_box(at + Vector3(0, 0.22, DESK_AHEAD + 0.05), Vector3(0.5, 0.06, 0.4), TRIM)


## The hall: the founder's bust by the front door and the coat pegs with backpacks in the corridor.
func _build_hall() -> void:
	_build.box(Vector3(-3.0, 0.55, 10.8), Vector3(0.5, 1.1, 0.5), BUST.darkened(0.2))
	_build.mesh(_ball(0.28), Vector3(-3.0, 1.45, 10.8), BUST)
	_label("SCHOOL_FOUNDER", Vector3(-3.0, 0.7, 11.07), 0.0, 24)
	for i in 8:
		var z := 1.0 + i * 1.0
		_build.mesh_box(Vector3(HALF_X - 0.15, 1.3, z), Vector3(0.1, 0.06, 0.06), METAL)
		_build.mesh_box(Vector3(HALF_X - 0.3, 1.05, z), Vector3(0.18, 0.4, 0.32), BAGS[i % BAGS.size()])


## The playground: the fence, the slide, the sandbox and the janitor's shed with his cart.
func _build_yard() -> void:
	_build.slab(-HALF_X, HALF_X, FENCE_Z, BACK_Z, FLOOR_TOP, YARD)
	_build.box(Vector3(0, FENCE_HEIGHT / 2, FENCE_Z), Vector3(HALF_X * 2, FENCE_HEIGHT, PlaceBuilder.WALL), WALL)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * HALF_X, FENCE_HEIGHT / 2, (BACK_Z + FENCE_Z) / 2),
			Vector3(PlaceBuilder.WALL, FENCE_HEIGHT, BACK_Z - FENCE_Z), WALL)
	# The slide: a ladder on the back, a platform and the red chute down to the front.
	_build.box(SLIDE + Vector3(0, 0.75, -1.2), Vector3(0.8, 1.5, 0.3), METAL)
	_build.box(SLIDE + Vector3(0, 1.45, -0.8), Vector3(0.8, 0.1, 0.8), METAL)
	var chute := _build.body(SLIDE + Vector3(0, 0.85, 0.5))
	chute.rotation.x = atan2(1.4, 2.2)
	_build.shape(chute, Vector3(0.7, 0.08, 2.6))
	var chute_mesh := BoxMesh.new()
	chute_mesh.size = Vector3(0.7, 0.08, 2.6)
	_build.mesh(chute_mesh, SLIDE + Vector3(0, 0.85, 0.5), SLIDE_RED, Vector3(atan2(1.4, 2.2), 0, 0))
	# The sandbox: a low wooden frame around the sand.
	var middle := Vector3(SANDBOX.get_center().x, 0, SANDBOX.get_center().y)
	_build.mesh_box(middle + Vector3(0, FLOOR_TOP + 0.08, 0), Vector3(SANDBOX.size.x, 0.1, SANDBOX.size.y), SAND)
	for side: float in [-1.0, 1.0]:
		_build.box(middle + Vector3(side * SANDBOX.size.x / 2, 0.15, 0), Vector3(0.12, 0.3, SANDBOX.size.y), WOOD)
		_build.box(middle + Vector3(0, 0.15, side * SANDBOX.size.y / 2), Vector3(SANDBOX.size.x, 0.3, 0.12), WOOD)
	# The janitor's shed in the corner, its door on the west wall, and his yellow cart inside.
	var top := GameScale.FLOOR_HEIGHT
	_build.wall("x", SHED.position.y + SHED.size.y, SHED.position.x, HALF_X, 0, [], WOOD)
	_build.wall("z", SHED.position.x, SHED.position.y, SHED.end.y, 0, [SHED_DOOR_Z], WOOD)
	_build.slab(SHED.position.x, HALF_X, SHED.position.y, SHED.end.y, top, WOOD.darkened(0.3))
	_label("SCHOOL_SHED", Vector3(SHED.position.x - 0.1, top - 0.3, SHED_DOOR_Z), -PI / 2, 28)
	_build.box(CART_AT + Vector3(0, 0.45, 0), Vector3(0.6, 0.9, 0.9), CART)
	_build.light(Vector3(11.0, top - 0.4, -10.0))


## The 20 pupils at their desks, the teacher by hers and the janitor in the hall.
func _place_people() -> void:
	var looks := looks_for(case_seed)
	for desk in PUPILS:
		var pupil := SchoolPupil.new()
		pupil.name = "Pupil%d" % desk
		pupil.look = looks[desk]
		pupil.desk = desk
		pupil.next_line = (desk * 3 + case_seed) % SchoolPupil.LINES
		pupil.position = seat(desk) + Vector3.UP * FLOOR_TOP
		add_child(pupil)
		pupils.append(pupil)
	teacher = SchoolAdult.new()
	teacher.name = "Teacher"
	teacher.look = "maestra"
	teacher.position = TEACHER_AT + Vector3.UP * FLOOR_TOP
	# Facing the class (+Z); NPCs face -Z.
	teacher.rotation.y = PI
	add_child(teacher)
	janitor = SchoolAdult.new()
	janitor.name = "Janitor"
	janitor.look = "conserje"
	janitor.position = JANITOR_AT + Vector3.UP * FLOOR_TOP
	janitor.rotation.y = PI / 2
	add_child(janitor)


func _label(key: String, at: Vector3, turn: float, size: int) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = 0.01
	label.outline_size = 12
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)


static func _ball(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.2
	mesh.radial_segments = 8
	mesh.rings = 5
	return mesh
