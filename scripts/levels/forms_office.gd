class_name FormsOffice
extends CrimeScenePlace

## The city's office (escena-oficina.md, step 1, decision 280): Formularios Infinitos S.A., the company that makes the
## forms to ask for other forms, on its lot with the front to +Z. Downstairs: the reception with the Founder's Stapler
## in its glass case, the clock to punch in and the water cooler; the open space with eight desks alike (nobody has a
## desk of their own), the giant copier at the back, and the kitchen in the north-west corner with the company's coffee
## machine and the cookie tin. Upstairs, by the stairs: the manager's office, where the theft was, with his big desk and
## the safe; the archive with its shelves of forms; and the meeting room. The people come in step 2 and the case in
## step 4. Every number here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(24, 18)
const HALF_X := 12.0
const BACK_Z := -9.0
## The front wall; the strip in front of it, to the lot's edge, is the entrance.
const FRONT_Z := 7.0
const FLOOR_TOP := 0.06
## The top of the upstairs floor and of the roof, with a low parapet over it.
const UP := GameScale.FLOOR_HEIGHT + FLOOR_TOP
const ROOF := GameScale.FLOOR_HEIGHT * 2
const TALL := 6.0
const DOOR_FRONT_X := 0.0
## Downstairs: the kitchen in the north-west corner, its door in its east wall.
const KITCHEN_X := -6.0
const KITCHEN_Z := -3.0
const DOOR_KITCHEN_Z := -6.0
## The stairs climb north along -Z on the east side, from STAIR_FOOT_Z to STAIR_TOP_Z.
const STAIR_X := 10.5
const STAIR_RUN := 3.75
const STAIR_FOOT_Z := 5.5
const STAIR_TOP_Z := STAIR_FOOT_Z - STAIR_RUN
## The hole upstairs over the stairs: wider than them and long enough that a cop's head doesn't hit its edge.
const HOLE_HALF_X := 0.8
const HOLE_SOUTH_Z := 5.0
## Upstairs: the wall between the back rooms (the archive west, the manager's office east) and the front ones (the
## meeting room west, the hall with the stairs east), with a door from the hall into each back room.
const BACK_ROOMS_Z := -1.0
const ARCHIVE_X := -4.0
const DOOR_ARCHIVE_X := -5.0
const DOOR_MANAGER_X := 4.0
const MEETING_X := -6.0
const DOOR_MEETING_Z := 1.5
## The reception: its desk facing the door, the clock to punch in on the front wall, the Founder's Stapler's glass
## case, the water cooler and the plastic plant.
const RECEPTION_AT := Vector3(-3.5, 0, 4.2)
const RECEPTION_SIZE := Vector3(2.4, 1.05, 0.7)
const TIME_CLOCK_AT := Vector3(2.2, 1.3, FRONT_Z - 0.12)
const STAPLER_CASE_AT := Vector3(-8.5, 0, 5.0)
const COOLER_AT := Vector3(6.5, FLOOR_TOP, 6.3)
const PLANT_AT := Vector3(-11.2, 0, 6.2)
## The open space: two rows of four desks alike, each with its rolling chair in front (+Z).
const DESK_COLUMNS: Array[float] = [-3.5, -0.5, 2.5, 5.5]
const DESK_ROWS: Array[float] = [-5.5, -1.5]
const DESK_SIZE := Vector3(1.4, 0.75, 0.75)
const CHAIR_OFF := 0.75
## Where an employee stands at a desk: at its east end, and the aisle between the rows they walk along to change desks.
const STAND_OFF := Vector3(0.95, 0, 0.1)
const AISLE_Z := -3.3
## The six employees, and how often the desk-change bell rings: then each one walks to another desk (nobody has a
## desk of their own).
const EMPLOYEES := 6
const DESK_CHANGE_EVERY := 90.0
## The giant copier against the back wall.
const COPIER_AT := Vector3(8.5, 0, -8.2)
const COPIER_SIZE := Vector3(1.6, 1.3, 0.9)
## The kitchen: the coffee machine on the floor in the corner, the counter along the back wall with the cookie tin,
## and the fridge.
const COFFEE_AT := Vector3(-11.3, FLOOR_TOP, -8.5)
const COFFEE_SIZE := Vector3(0.7, 1.6, 0.6)
const COUNTER_AT := Vector3(-8.6, 0, -8.6)
const COUNTER_SIZE := Vector3(3.6, 0.9, 0.6)
const TIN_AT := COUNTER_AT + Vector3(0.8, COUNTER_SIZE.y, 0)
const FRIDGE_AT := Vector3(-11.4, 0, -4.0)
const FRIDGE_SIZE := Vector3(0.7, 1.7, 0.7)
## The manager's office: the big desk (the thief's cup waits on it in step 4), his armchair behind it, the safe
## against the east wall and a leather sofa.
const MANAGER_DESK_AT := Vector3(4.0, UP, -5.5)
const MANAGER_DESK_SIZE := Vector3(2.2, 0.78, 1.0)
const SAFE_AT := Vector3(HALF_X - 0.45, UP, -4.0)
const SAFE_SIZE := Vector3(0.6, 0.9, 0.7)
const SOFA_AT := Vector3(9.0, UP, -8.3)
## El señor Trámite beside his desk, Benja by the copier, and Pelusa's round on the first floor: round the manager's
## office and out to the hall.
const MANAGER_AT := Vector3(5.6, UP, -5.0)
const INTERN_AT := Vector3(7.0, FLOOR_TOP, -7.3)
const VACUUM_ROUTE: Array[Vector3] = [Vector3(1.0, UP, -3.0), Vector3(1.0, UP, -7.5), Vector3(7.5, UP, -7.5),
	Vector3(7.5, UP, -3.0), Vector3(4.0, UP, -3.0), Vector3(4.0, UP, 1.0), Vector3(4.0, UP, -3.0)]
## The archive's shelves, against its walls, and the meeting room's long table.
## Two along the back wall (their boxes face +Z) and one along the west wall (facing +X).
const BACK_SHELVES: Array[Vector3] = [Vector3(-10.0, UP, -8.65), Vector3(-6.6, UP, -8.65)]
const WEST_SHELF_AT := Vector3(-HALF_X + 0.35, UP, -4.5)
const SHELF_SIZE := Vector3(2.2, 2.3, 0.5)
const MEETING_TABLE_AT := Vector3(-9.0, UP, 3.0)
const MEETING_TABLE_SIZE := Vector3(4.0, 0.76, 1.4)
const CHAIR_SCENE := preload("res://scenes/props/office_chair.tscn")
const MONITOR_MODEL := preload("res://assets/models/office_monitor.glb")
const PHONE_MODEL := preload("res://assets/models/desk_phone.glb")
const COFFEE_MODEL := preload("res://assets/models/coffee_machine.glb")
const COOLER_MODEL := preload("res://assets/models/water_cooler.glb")
const TIN_MODEL := preload("res://assets/models/cookie_tin.glb")
const CONCRETE := Color(0.62, 0.66, 0.7)
const MIRROR := Color(0.45, 0.6, 0.72)
const INSIDE := Color(0.9, 0.9, 0.86)
const CARPET := Color(0.42, 0.45, 0.5)
const MANAGER_CARPET := Color(0.45, 0.2, 0.2)
const DESK := Color(0.82, 0.78, 0.7)
const DARK := Color(0.2, 0.2, 0.22)
const WOOD := Color(0.5, 0.33, 0.2)
const LEATHER := Color(0.35, 0.2, 0.12)
const WHITE := Color(0.95, 0.95, 0.93)
const METAL := Color(0.55, 0.58, 0.62)
const GLASS := Color(0.75, 0.9, 1.0, 0.35)
const BRONZE := Color(0.75, 0.5, 0.25)
const PLANT := Color(0.25, 0.6, 0.3)
const FILES := Color(0.85, 0.75, 0.5)

## The eight rolling chairs of the open space, in the order of the desks.
var chairs: Array[Grabbable] = []
var coffee_machine: StaticBody3D
## The six employees, in order, the desk each one is at (an index of desks()) and the seconds to the next bell.
var employees: Array[OfficePerson] = []
var desk_of: Array[int] = []
var bell_in := DESK_CHANGE_EVERY
var manager: OfficePerson
var intern: OfficePerson
var vacuum: RobotVacuum
var _rng := RandomNumberGenerator.new()
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("forms_office")
	variant = "office"
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_reception()
	_open_space()
	_kitchen()
	_stairs()
	_upstairs()
	_manager()
	_archive()
	_meeting()
	_people()


## Whether a point in the world (ignoring height) is on the office's lot, the entrance included.
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


## The room a point in the world is in: downstairs "kitchen" or "open_space" (the reception included), upstairs
## "manager", "archive", "meeting" or "hall"; "" outside the building.
func room_of(world: Vector3) -> String:
	if not inside(world):
		return ""
	var local := to_local(world)
	if floor_of(world) == 0:
		return "kitchen" if local.x < KITCHEN_X and local.z < KITCHEN_Z else "open_space"
	if local.z < BACK_ROOMS_Z:
		return "archive" if local.x < ARCHIVE_X else "manager"
	return "meeting" if local.x < MEETING_X else "hall"


## The eight desks of the open space, in order (row by row), by the middle of their top's floor.
static func desks() -> Array[Vector3]:
	var all: Array[Vector3] = []
	for z: float in DESK_ROWS:
		for x: float in DESK_COLUMNS:
			all.append(Vector3(x, FLOOR_TOP, z))
	return all


## Where an employee stands at a desk.
static func stand_at(desk: int) -> Vector3:
	return desks()[desk] + STAND_OFF


## The desk-change bell: every employee walks to another desk, free and not his own, drawn with the seed. They go out
## to the aisle, along it and in to the new desk.
func ring_desk_bell() -> void:
	bell_in = DESK_CHANGE_EVERY
	var free: Array[int] = []
	for desk in desks().size():
		free.append(desk)
	var next: Array[int] = []
	for i in employees.size():
		var options := free.filter(func(desk: int) -> bool: return desk != desk_of[i] and not next.has(desk))
		if options.is_empty():
			options = free.filter(func(desk: int) -> bool: return not next.has(desk))
		next.append(options[_rng.randi_range(0, options.size() - 1)])
	for i in employees.size():
		var from := stand_at(desk_of[i])
		var to := stand_at(next[i])
		employees[i].walk([Vector3(from.x, from.y, AISLE_Z), Vector3(to.x, to.y, AISLE_Z), to])
		desk_of[i] = next[i]


func _physics_process(delta: float) -> void:
	if employees.is_empty():
		return
	bell_in -= delta
	if bell_in <= 0.0:
		ring_desk_bell()


## The floor, the outer walls on both floors with the front door, the roof with its parapet and the mirrored windows.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, CARPET)
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, ROOF, INSIDE.darkened(0.4))
	_ceiling(-HALF_X, HALF_X, BACK_Z, FRONT_Z, ROOF)
	for side: float in [-1.0, 1.0]:
		_builder.box(Vector3(side * (HALF_X - 0.1), (ROOF + TALL) / 2, (BACK_Z + FRONT_Z) / 2),
			Vector3(0.2, TALL - ROOF, FRONT_Z - BACK_Z), CONCRETE)
	for z: float in [BACK_Z + 0.1, FRONT_Z - 0.1]:
		_builder.box(Vector3(0, (ROOF + TALL) / 2, z), Vector3(SIZE.x, TALL - ROOF, 0.2), CONCRETE)
	for level in 2:
		_builder.wall("x", BACK_Z, -HALF_X, HALF_X, level, [], INSIDE)
		_builder.wall("x", FRONT_Z, -HALF_X, HALF_X, level, [DOOR_FRONT_X] if level == 0 else [], INSIDE)
		_builder.wall("z", -HALF_X, BACK_Z, FRONT_Z, level, [], INSIDE)
		_builder.wall("z", HALF_X, BACK_Z, FRONT_Z, level, [], INSIDE)
	# Grey concrete on the outside, with a band of mirrored windows on each floor.
	var skin := 0.02
	var out := PlaceBuilder.WALL / 2 + skin / 2
	var door_left := DOOR_FRONT_X - GameScale.DOOR_WIDTH / 2
	var door_right := DOOR_FRONT_X + GameScale.DOOR_WIDTH / 2
	_builder.mesh_box(Vector3((-HALF_X + door_left) / 2, ROOF / 2, FRONT_Z + out),
		Vector3(door_left + HALF_X, ROOF, skin), CONCRETE)
	_builder.mesh_box(Vector3((HALF_X + door_right) / 2, ROOF / 2, FRONT_Z + out),
		Vector3(HALF_X - door_right, ROOF, skin), CONCRETE)
	_builder.mesh_box(Vector3(DOOR_FRONT_X, (ROOF + GameScale.DOOR_HEIGHT) / 2, FRONT_Z + out),
		Vector3(GameScale.DOOR_WIDTH, ROOF - GameScale.DOOR_HEIGHT, skin), CONCRETE)
	_builder.mesh_box(Vector3(0, ROOF / 2, BACK_Z - out), Vector3(SIZE.x, ROOF, skin), CONCRETE)
	for side: float in [-1.0, 1.0]:
		_builder.mesh_box(Vector3(side * (HALF_X + out), ROOF / 2, (BACK_Z + FRONT_Z) / 2),
			Vector3(skin, ROOF, FRONT_Z - BACK_Z), CONCRETE)
	for level in 2:
		var y := level * GameScale.FLOOR_HEIGHT + 1.5
		for side: float in [-1.0, 1.0]:
			_builder.mesh_box(Vector3(side * (HALF_X + 1.0) / 2 + side * 0.5, y, FRONT_Z + out + 0.02),
				Vector3(HALF_X - 2.0, 1.1, 0.02), MIRROR)
			_builder.mesh_box(Vector3(side * (HALF_X + out + 0.02), y, (BACK_Z + FRONT_Z) / 2),
				Vector3(0.02, 1.1, FRONT_Z - BACK_Z - 2.0), MIRROR)


## The glass door's frame, the doormat and the company's sign over the entrance.
func _front() -> void:
	var depth := SIZE.y / 2 - FRONT_Z
	_builder.mesh_box(Vector3(DOOR_FRONT_X, 0.01, FRONT_Z + depth / 2), Vector3(1.6, 0.01, depth), DARK)
	for side: float in [-1.0, 1.0]:
		_builder.mesh_box(Vector3(DOOR_FRONT_X + side * (GameScale.DOOR_WIDTH / 2 + 0.05), GameScale.DOOR_HEIGHT / 2,
			FRONT_Z + 0.1), Vector3(0.1, GameScale.DOOR_HEIGHT, 0.05), METAL)
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = "PLACE_OFFICE"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = WHITE
	sign_label.position = Vector3(0, GameScale.DOOR_HEIGHT + 0.4, FRONT_Z + 0.14)
	add_child(sign_label)


## The reception desk, the clock to punch in, the Founder's Stapler's glass case, the water cooler and the plant.
func _reception() -> void:
	_builder.box(RECEPTION_AT + Vector3(0, RECEPTION_SIZE.y / 2, 0), RECEPTION_SIZE, DESK.darkened(0.2))
	_model(PHONE_MODEL, RECEPTION_AT + Vector3(0.7, RECEPTION_SIZE.y, 0))
	_builder.mesh_box(TIME_CLOCK_AT, Vector3(0.5, 0.6, 0.18), METAL)
	_builder.mesh_box(TIME_CLOCK_AT + Vector3(0, 0.12, -0.1), Vector3(0.3, 0.2, 0.02), WHITE)
	var clock_sign := Label3D.new()
	clock_sign.name = "TimeClockSign"
	clock_sign.text = "SIGN_OFFICE_CLOCK"
	clock_sign.font_size = 24
	clock_sign.pixel_size = 0.01
	clock_sign.modulate = DARK
	clock_sign.position = TIME_CLOCK_AT + Vector3(0, 0.5, -0.1)
	clock_sign.rotation.y = PI
	add_child(clock_sign)
	_builder.box(STAPLER_CASE_AT + Vector3(0, 0.45, 0), Vector3(0.7, 0.9, 0.7), WOOD)
	_builder.mesh_box(STAPLER_CASE_AT + Vector3(0, 1.2, 0), Vector3(0.7, 0.6, 0.7), GLASS)
	_builder.mesh_box(STAPLER_CASE_AT + Vector3(0, 0.96, 0), Vector3(0.3, 0.1, 0.1), BRONZE)
	_builder.shape(_builder.body(COOLER_AT + Vector3(0, 0.7, 0)), Vector3(0.4, 1.4, 0.4))
	_model(COOLER_MODEL, COOLER_AT, PI)
	_builder.box(PLANT_AT + Vector3(0, 0.25, 0), Vector3(0.4, 0.5, 0.4), WOOD)
	var leaves := SphereMesh.new()
	leaves.radius = 0.45
	leaves.height = 0.9
	_builder.mesh(leaves, PLANT_AT + Vector3(0, 0.9, 0), PLANT)
	for at: Vector3 in [Vector3(-6, 0, 4), Vector3(4, 0, 4)]:
		_builder.light(at + Vector3(0, GameScale.FLOOR_HEIGHT - 0.5, 0))


## Eight desks alike with a monitor, a phone and a pile of papers, each with its rolling chair, and the giant copier.
func _open_space() -> void:
	for z: float in DESK_ROWS:
		for x: float in DESK_COLUMNS:
			var desk := Vector3(x, FLOOR_TOP, z)
			_builder.legs(desk, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.03, DARK)
			_builder.box(desk + Vector3(0, DESK_SIZE.y - 0.015, 0), Vector3(DESK_SIZE.x, 0.03, DESK_SIZE.z), DESK)
			var top := desk + Vector3(0, DESK_SIZE.y, 0)
			_model(MONITOR_MODEL, top + Vector3(-0.3, 0.15, -0.15))
			_model(PHONE_MODEL, top + Vector3(0.4, 0, -0.1))
			_builder.mesh_box(top + Vector3(0.45, 0.06, 0.15), Vector3(0.3, 0.12, 0.22), WHITE)
			var chair: Grabbable = CHAIR_SCENE.instantiate()
			chair.position = Vector3(x, FLOOR_TOP + 0.01, z + CHAIR_OFF)
			chair.rotation.y = PI
			add_child(chair)
			chairs.append(chair)
	_builder.box(COPIER_AT + Vector3(0, COPIER_SIZE.y / 2, 0), COPIER_SIZE, WHITE.darkened(0.1))
	_builder.mesh_box(COPIER_AT + Vector3(0.3, COPIER_SIZE.y + 0.02, 0.1), Vector3(0.5, 0.04, 0.3), DARK)
	_builder.mesh_box(COPIER_AT + Vector3(-0.5, COPIER_SIZE.y + 0.05, 0.2), Vector3(0.12, 0.05, 0.12),
		Color(0.2, 0.75, 0.3))
	for at: Vector3 in [Vector3(-2, 0, -5.5), Vector3(4, 0, -5.5), Vector3(-2, 0, -1.5), Vector3(4, 0, -1.5),
			Vector3(8.5, 0, -6.5)]:
		_builder.light(at + Vector3(0, GameScale.FLOOR_HEIGHT - 0.5, 0))


## The kitchen's walls, the coffee machine (the one the employees make their coffee at, step 3), the counter with the
## cookie tin and the fridge.
func _kitchen() -> void:
	_builder.wall("z", KITCHEN_X, BACK_Z, KITCHEN_Z, 0, [DOOR_KITCHEN_Z], INSIDE)
	_builder.wall("x", KITCHEN_Z, -HALF_X, KITCHEN_X, 0, [], INSIDE)
	_builder.mesh_box(Vector3((-HALF_X + KITCHEN_X) / 2, FLOOR_TOP + 0.005, (BACK_Z + KITCHEN_Z) / 2),
		Vector3(KITCHEN_X + HALF_X - 0.2, 0.01, KITCHEN_Z - BACK_Z - 0.2), WHITE.darkened(0.15))
	coffee_machine = StaticBody3D.new()
	coffee_machine.name = "CoffeeMachine"
	coffee_machine.position = COFFEE_AT
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = COFFEE_SIZE
	shape.shape = box
	shape.position.y = COFFEE_SIZE.y / 2
	coffee_machine.add_child(shape)
	coffee_machine.add_child(COFFEE_MODEL.instantiate())
	add_child(coffee_machine)
	_builder.box(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0), COUNTER_SIZE, WHITE.darkened(0.1))
	_model(TIN_MODEL, TIN_AT)
	_builder.open_box(FRIDGE_AT, FRIDGE_SIZE, "+x", WHITE)
	_builder.light(Vector3(-9.0, GameScale.FLOOR_HEIGHT - 0.5, -6.0))


## The stairs up from the open space, and the railing around their hole upstairs (open where they arrive).
func _stairs() -> void:
	_builder.stairs(Vector3(STAIR_X, FLOOR_TOP, STAIR_FOOT_Z), STAIR_RUN, DARK)
	var west := STAIR_X - HOLE_HALF_X
	var length := HOLE_SOUTH_Z - STAIR_TOP_Z
	_builder.box(Vector3(west, UP + 0.5, (STAIR_TOP_Z + HOLE_SOUTH_Z) / 2), Vector3(0.06, 1.0, length), METAL)
	_builder.box(Vector3((west + HALF_X) / 2, UP + 0.5, HOLE_SOUTH_Z), Vector3(HALF_X - west, 1.0, 0.06), METAL)


## The upstairs floor around the stairs' hole and the walls between its four rooms, with their doors.
func _upstairs() -> void:
	var west := STAIR_X - HOLE_HALF_X
	var east := STAIR_X + HOLE_HALF_X
	_builder.slab(-HALF_X, west, BACK_Z, FRONT_Z, UP, CARPET)
	_builder.slab(east, HALF_X, BACK_Z, FRONT_Z, UP, CARPET)
	_builder.slab(west, east, BACK_Z, STAIR_TOP_Z, UP, CARPET)
	_builder.slab(west, east, HOLE_SOUTH_Z, FRONT_Z, UP, CARPET)
	_ceiling(-HALF_X, west, BACK_Z, FRONT_Z, UP)
	_ceiling(east, HALF_X, BACK_Z, FRONT_Z, UP)
	_ceiling(west, east, BACK_Z, STAIR_TOP_Z, UP)
	_ceiling(west, east, HOLE_SOUTH_Z, FRONT_Z, UP)
	_builder.wall("x", BACK_ROOMS_Z, -HALF_X, HALF_X, 1, [DOOR_ARCHIVE_X, DOOR_MANAGER_X], INSIDE)
	_builder.wall("z", ARCHIVE_X, BACK_Z, BACK_ROOMS_Z, 1, [], INSIDE)
	_builder.wall("z", MEETING_X, BACK_ROOMS_Z, FRONT_Z, 1, [DOOR_MEETING_Z], INSIDE)
	for at: Vector3 in [Vector3(3, 0, 2), Vector3(8, 0, 0.5)]:
		_builder.light(at + Vector3(0, UP + GameScale.FLOOR_HEIGHT - 0.6, 0))


## The manager's office: red carpet, his big desk with the armchair behind it, the safe, the sofa and the sign on
## the door.
func _manager() -> void:
	_builder.mesh_box(Vector3((ARCHIVE_X + HALF_X) / 2, UP + 0.005, (BACK_Z + BACK_ROOMS_Z) / 2),
		Vector3(HALF_X - ARCHIVE_X - 0.2, 0.01, BACK_ROOMS_Z - BACK_Z - 0.2), MANAGER_CARPET)
	_builder.box(MANAGER_DESK_AT + Vector3(0, MANAGER_DESK_SIZE.y / 2, 0), MANAGER_DESK_SIZE, WOOD)
	_model(PHONE_MODEL, MANAGER_DESK_AT + Vector3(-0.7, MANAGER_DESK_SIZE.y, -0.2))
	var armchair := MANAGER_DESK_AT + Vector3(0, 0, -1.1)
	_builder.box(armchair + Vector3(0, 0.25, 0), Vector3(0.8, 0.5, 0.7), LEATHER)
	_builder.box(armchair + Vector3(0, 0.85, -0.3), Vector3(0.8, 0.8, 0.12), LEATHER)
	_builder.box(SAFE_AT + Vector3(0, SAFE_SIZE.y / 2, 0), SAFE_SIZE, METAL.darkened(0.3))
	_builder.mesh_box(SAFE_AT + Vector3(-SAFE_SIZE.x / 2 - 0.01, 0.55, 0), Vector3(0.02, 0.16, 0.16), METAL)
	_builder.box(SOFA_AT + Vector3(0, 0.25, 0), Vector3(2.0, 0.5, 0.8), LEATHER)
	_builder.box(SOFA_AT + Vector3(0, 0.7, -0.3), Vector3(2.0, 0.5, 0.2), LEATHER)
	var door_sign := Label3D.new()
	door_sign.name = "ManagerSign"
	door_sign.text = "SIGN_OFFICE_MANAGER"
	door_sign.font_size = 28
	door_sign.pixel_size = 0.01
	door_sign.modulate = DARK
	door_sign.position = Vector3(DOOR_MANAGER_X, UP + GameScale.DOOR_HEIGHT + 0.2, BACK_ROOMS_Z + 0.09)
	add_child(door_sign)
	_builder.light(Vector3(4.0, ROOF - 0.5, -5.0))
	_builder.light(Vector3(9.5, ROOF - 0.5, -5.0))


## The archive: shelves of boxes of forms up to the ceiling.
func _archive() -> void:
	for at in BACK_SHELVES:
		_builder.box(at + Vector3(0, SHELF_SIZE.y / 2, 0), SHELF_SIZE, WOOD.lightened(0.1))
		for row in 3:
			_builder.mesh_box(at + Vector3(0, 0.4 + row * 0.75, SHELF_SIZE.z / 2 + 0.01),
				Vector3(SHELF_SIZE.x - 0.2, 0.4, 0.02), FILES)
	var west := Vector3(SHELF_SIZE.z, SHELF_SIZE.y, SHELF_SIZE.x)
	_builder.box(WEST_SHELF_AT + Vector3(0, west.y / 2, 0), west, WOOD.lightened(0.1))
	for row in 3:
		_builder.mesh_box(WEST_SHELF_AT + Vector3(west.x / 2 + 0.01, 0.4 + row * 0.75, 0), Vector3(0.02, 0.4, west.z - 0.2),
			FILES)
	_builder.light(Vector3(-8.0, ROOF - 0.5, -5.0))


## The meeting room: the long table with its chairs and the whiteboard on the west wall.
func _meeting() -> void:
	_builder.legs(MEETING_TABLE_AT, Vector2(MEETING_TABLE_SIZE.x, MEETING_TABLE_SIZE.z), MEETING_TABLE_SIZE.y - 0.04,
		DARK)
	_builder.box(MEETING_TABLE_AT + Vector3(0, MEETING_TABLE_SIZE.y - 0.02, 0),
		Vector3(MEETING_TABLE_SIZE.x, 0.04, MEETING_TABLE_SIZE.z), WOOD.lightened(0.15))
	for i in 4:
		for side: float in [-1.0, 1.0]:
			_builder.mesh_box(MEETING_TABLE_AT + Vector3(-1.5 + i, 0.25, side * 1.0), Vector3(0.45, 0.5, 0.45), DARK)
	_builder.mesh_box(Vector3(-HALF_X + 0.1, UP + 1.5, 3.0), Vector3(0.03, 1.0, 2.0), WHITE)
	_builder.light(Vector3(-9.0, ROOF - 0.5, 3.0))


## The six employees at six of the eight desks (drawn with the seed), el señor Trámite in his office, Benja by the
## copier and Pelusa on its round.
func _people() -> void:
	_rng.seed = hash("office desks %d" % case_seed)
	var free: Array[int] = []
	for desk in desks().size():
		free.append(desk)
	for i in EMPLOYEES:
		var employee := OfficePerson.new()
		employee.name = "Employee%d" % i
		employee.index = i
		desk_of.append(free.pop_at(_rng.randi_range(0, free.size() - 1)))
		employee.position = stand_at(desk_of[i])
		employee.rotation.y = -PI / 2
		add_child(employee)
		employees.append(employee)
	manager = _person("manager", MANAGER_AT, -PI / 2)
	intern = _person("intern", INTERN_AT, PI / 2)
	vacuum = RobotVacuum.new()
	vacuum.name = "Pelusa"
	vacuum.route = VACUUM_ROUTE
	vacuum.position = VACUUM_ROUTE[0]
	add_child(vacuum)


func _person(who: String, at: Vector3, turn: float) -> OfficePerson:
	var person := OfficePerson.new()
	person.who = who
	person.name = who.capitalize()
	person.position = at
	person.rotation.y = turn
	add_child(person)
	return person


## White ceiling tiles under the slab whose top is at `top`, only for the look.
func _ceiling(x0: float, x1: float, z0: float, z1: float, top: float) -> void:
	_builder.mesh_box(Vector3((x0 + x1) / 2, top - PlaceBuilder.SLAB - 0.01, (z0 + z1) / 2),
		Vector3(x1 - x0, 0.01, z1 - z0), WHITE)


func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	add_child(look)
	return look
