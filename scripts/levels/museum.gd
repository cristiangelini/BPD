class_name Museum
extends CrimeScenePlace

## The city's museum (escena-museo.md, step 1, decision 200), on its lot with the front to +Z: steps and columns at
## the front, the hall with the ticket desk, the guards' security room on its west side (the monitors and someone's
## sandwich) and their lockers on its east side. Behind the hall, the big gallery: paintings on the walls, busts on
## pedestals, the velvet rope and the empty frame where the stolen piece hung. On the gallery's west side, the storage
## room with paintings under sheets, and the bathroom: just one, tiny, with a toilet, a sink, a mirror, the paper roll
## and the hand dryer. The guards, the director and the living statue come in step 2, the case in step 4.
## Every number here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(30, 26)
const HALF_X := 15.0
const BACK_Z := -13.0
## The front wall, with the steps in front of it to the lot's edge.
const FRONT_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The wall between the hall's three rooms and the gallery.
const HALL_Z := 4.0
## The hall's side walls: the security room is west of it, the lockers east.
const HALL_X := 6.0
## The wall between the gallery and the storage room and bathroom.
const GALLERY_X := -8.0
## The bathroom, in the gallery's north-west corner: x from BATHROOM_X to GALLERY_X, z from BATHROOM_Z to HALL_Z.
const BATHROOM_X := -11.0
const BATHROOM_Z := 1.0
const DOOR_FRONT_X := 0.0
const DOOR_GALLERY_X := 0.0
const DOOR_SIDE_Z := 7.0
const DOOR_STORAGE_Z := -6.0
const DOOR_BATHROOM_Z := 2.5
## Where the stolen piece hung: on the gallery's back wall, behind the velvet rope.
const EMPTY_FRAME_AT := Vector3(3.5, 1.6, BACK_Z + 0.12)
const FRAME_SIZE := Vector2(2.0, 1.4)
const ROPE_Z := BACK_Z + 1.6
const ROPE_FROM := 1.5
const ROPE_TO := 5.5
## The other paintings: where each hangs (on a wall's inside face), its size and which way it faces.
const PAINTINGS := [
	{"at": Vector3(-4.5, 1.6, BACK_Z + 0.12), "size": Vector2(1.6, 1.2), "turn": 0.0},
	{"at": Vector3(10.5, 1.6, BACK_Z + 0.12), "size": Vector2(1.4, 1.8), "turn": 0.0},
	{"at": Vector3(HALF_X - 0.12, 1.6, -8.0), "size": Vector2(1.8, 1.2), "turn": -PI / 2},
	{"at": Vector3(HALF_X - 0.12, 1.6, -2.0), "size": Vector2(1.2, 1.2), "turn": -PI / 2},
	{"at": Vector3(9.0, 1.6, HALL_Z - 0.12), "size": Vector2(1.6, 1.0), "turn": PI},
	{"at": Vector3(-4.5, 1.6, HALL_Z - 0.12), "size": Vector2(1.2, 1.5), "turn": PI},
]
## The busts on their pedestals, in the gallery's middle (the alarm's lasers run between them in step 4).
const PEDESTALS: Array[Vector3] = [Vector3(-3, 0, -7), Vector3(1, 0, -3), Vector3(6, 0, -7), Vector3(10, 0, -3)]
const PEDESTAL_SIZE := Vector3(0.6, 1.1, 0.6)
const BENCH_AT := Vector3(3.5, 0, -0.5)
## The security room: the desk against the west wall with its three monitors, and the sandwich on a plate.
const DESK_AT := Vector3(-14.2, 0, 7.0)
const DESK_SIZE := Vector3(1.0, 0.8, 3.0)
const MONITORS := 3
const SANDWICH_AT := DESK_AT + Vector3(0.1, 0.84, -1.2)
## The guards' six lockers in a row against the east wall, numbered from 1.
const LOCKERS: Array[Vector3] = [
	Vector3(14.6, 0, 4.7), Vector3(14.6, 0, 5.6), Vector3(14.6, 0, 6.5), Vector3(14.6, 0, 7.4),
	Vector3(14.6, 0, 8.3), Vector3(14.6, 0, 9.2),
]
const LOCKER_SIZE := Vector3(0.6, 1.9, 0.85)
## The paintings under sheets in the storage room.
const STORED: Array[Vector3] = [Vector3(-14, 0, -11.5), Vector3(-12, 0, -11.5), Vector3(-14.2, 0, -8), Vector3(-10, 0, -9)]
const STORED_SIZE := Vector3(0.3, 1.5, 1.2)
## The bathroom's fittings.
const TOILET_AT := Vector3(-10.4, 0, BATHROOM_Z + 0.4)
const SINK_AT := Vector3(BATHROOM_X + 0.3, 0, 3.4)
const MIRROR_AT := Vector3(BATHROOM_X + 0.09, 1.55, 3.4)
const PAPER_AT := Vector3(BATHROOM_X + 0.1, 0.7, BATHROOM_Z + 0.5)
const DRYER_AT := Vector3(-9.0, 1.3, HALL_Z - 0.15)
const DESK_HALL_AT := Vector3(-3.5, 0, 7.5)
## Where the people stand (step 2): the director in the hall, the living statue on the steps.
const DIRECTOR_AT := Vector3(2.0, 0, 6.5)
const STATUE_AT := Vector3(4.5, 0, 11.6)
const COLUMNS_X: Array[float] = [-6.0, -2.4, 2.4, 6.0]
const STONE := Color(0.88, 0.86, 0.8)
const WAXED := Color(0.72, 0.52, 0.34)
const INSIDE := Color(0.93, 0.9, 0.84)
const GALLERY_WALL := Color(0.62, 0.15, 0.2)
const GOLD := Color(0.9, 0.72, 0.25)
const WOOD := Color(0.5, 0.33, 0.2)
const METAL := Color(0.55, 0.58, 0.62)
const TILE := Color(0.75, 0.88, 0.92)
const PORCELAIN := Color(0.97, 0.97, 0.97)
const SHEET := Color(0.92, 0.92, 0.88)
const ROPE_RED := Color(0.7, 0.08, 0.12)
const CANVAS_COLORS: Array[Color] = [
	Color(0.3, 0.45, 0.7), Color(0.85, 0.6, 0.3), Color(0.35, 0.6, 0.35), Color(0.75, 0.4, 0.55),
	Color(0.95, 0.85, 0.4), Color(0.45, 0.35, 0.6),
]

var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("museum")
	variant = "museum"
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_rooms()
	_gallery()
	_security()
	_lockers()
	_storage()
	_bathroom()
	_hall()


## Whether a point in the world (ignoring height) is on the museum's lot, steps included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the building (not on the steps).
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## Whether a point in the world is in the bathroom.
func in_bathroom(world: Vector3) -> bool:
	var local := to_local(world)
	return local.x > BATHROOM_X and local.x < GALLERY_X and local.z > BATHROOM_Z and local.z < HALL_Z


## Whether a point in the world is in the gallery.
func in_gallery(world: Vector3) -> bool:
	var local := to_local(world)
	return local.x > GALLERY_X and local.x < HALF_X and local.z > BACK_Z and local.z < HALL_Z


## The floor, the roof with its lights and the outer walls, with the front door.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, STONE)
	_builder.slab(-HALF_X - 0.2, HALF_X + 0.2, BACK_Z - 0.2, FRONT_Z + 0.2, ROOF, STONE.darkened(0.35))
	_builder.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [], GALLERY_WALL)
	_builder.wall("x", FRONT_Z, -HALF_X, HALF_X, 0, [DOOR_FRONT_X], STONE)
	_builder.wall("z", -HALF_X, BACK_Z, FRONT_Z, 0, [], INSIDE)
	_builder.wall("z", HALF_X, BACK_Z, FRONT_Z, 0, [], GALLERY_WALL)
	for x: float in [-11.5, -3.0, 4.0, 11.0]:
		for z: float in [-9.0, -2.0, 7.0]:
			_builder.light(Vector3(x, ROOF - 0.5, z))


## The steps up to the door (flat enough to walk, only for the look), four columns, the pediment and the sign.
func _front() -> void:
	var depth := SIZE.y / 2 - FRONT_Z
	for i in 3:
		var z := FRONT_Z + depth * (i + 0.5) / 3
		_builder.mesh_box(Vector3(0, 0.03 * (3 - i), z), Vector3(16.0 - i * 1.5, 0.06 * (3 - i), depth / 3), STONE)
	for x in COLUMNS_X:
		_builder.box(Vector3(x, ROOF / 2, FRONT_Z + 0.8), Vector3(0.5, ROOF, 0.5), STONE)
	_builder.box(Vector3(0, ROOF + 0.1, FRONT_Z + 0.8), Vector3(13.5, 0.2, 1.2), STONE)
	var pediment := PrismMesh.new()
	pediment.size = Vector3(13.5, 1.4, 1.0)
	_builder.mesh(pediment, Vector3(0, ROOF + 0.9, FRONT_Z + 0.8), STONE)
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = "SIGN_MUSEUM"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = GOLD
	sign_label.position = Vector3(0, ROOF + 0.55, FRONT_Z + 1.35)
	add_child(sign_label)


## The inner walls: the hall's back wall with the gallery's door, its two side walls with the doors to the security
## room and the lockers, the wall to the storage room and the bathroom, and the bathroom's own two walls.
func _rooms() -> void:
	_builder.wall("x", HALL_Z, -HALF_X, HALF_X, 0, [DOOR_GALLERY_X], INSIDE)
	_builder.wall("z", -HALL_X, HALL_Z, FRONT_Z, 0, [DOOR_SIDE_Z], INSIDE)
	_builder.wall("z", HALL_X, HALL_Z, FRONT_Z, 0, [DOOR_SIDE_Z], INSIDE)
	_builder.wall("z", GALLERY_X, BACK_Z, HALL_Z, 0, [DOOR_STORAGE_Z, DOOR_BATHROOM_Z], INSIDE)
	_builder.wall("x", BATHROOM_Z, BATHROOM_X, GALLERY_X, 0, [], TILE)
	_builder.wall("z", BATHROOM_X, BATHROOM_Z, HALL_Z, 0, [], TILE)


## The waxed floor, the paintings and the empty frame, the busts on their pedestals, the velvet rope and a bench.
func _gallery() -> void:
	var width := HALF_X - GALLERY_X
	var waxed := Vector3((GALLERY_X + HALF_X) / 2, FLOOR_TOP + 0.005, (BACK_Z + HALL_Z) / 2)
	_builder.mesh_box(waxed, Vector3(width - 0.2, 0.01, HALL_Z - BACK_Z - 0.2), WAXED)
	for i in PAINTINGS.size():
		var painting: Dictionary = PAINTINGS[i]
		_frame(painting.at, painting.size, painting.turn, CANVAS_COLORS[i % CANVAS_COLORS.size()])
	_frame(EMPTY_FRAME_AT, FRAME_SIZE, 0.0, GALLERY_WALL.darkened(0.25))
	for at in PEDESTALS:
		_builder.box(at + Vector3(0, PEDESTAL_SIZE.y / 2, 0), PEDESTAL_SIZE, STONE)
		var head := SphereMesh.new()
		head.radius = 0.2
		head.height = 0.45
		_builder.mesh(head, at + Vector3(0, PEDESTAL_SIZE.y + 0.3, 0), PORCELAIN)
		_builder.mesh_box(at + Vector3(0, PEDESTAL_SIZE.y + 0.06, 0), Vector3(0.35, 0.12, 0.25), PORCELAIN)
	var posts := 3
	for i in posts:
		var x := lerpf(ROPE_FROM, ROPE_TO, float(i) / (posts - 1))
		_builder.box(Vector3(x, 0.5, ROPE_Z), Vector3(0.1, 1.0, 0.1), GOLD)
	_builder.mesh_box(Vector3((ROPE_FROM + ROPE_TO) / 2, 0.85, ROPE_Z), Vector3(ROPE_TO - ROPE_FROM, 0.06, 0.06),
		ROPE_RED)
	_builder.box(BENCH_AT + Vector3(0, 0.22, 0), Vector3(2.4, 0.44, 0.6), WOOD)


## A gilt frame with a canvas in it, hanging on a wall's face at `at`, turned to face the room.
func _frame(at: Vector3, size: Vector2, turn: float, canvas: Color) -> void:
	var facing := Basis(Vector3.UP, turn)
	var bars := [
		[Vector3(0, size.y / 2, 0), Vector3(size.x + 0.16, 0.08, 0.06)],
		[Vector3(0, -size.y / 2, 0), Vector3(size.x + 0.16, 0.08, 0.06)],
		[Vector3(size.x / 2, 0, 0), Vector3(0.08, size.y, 0.06)],
		[Vector3(-size.x / 2, 0, 0), Vector3(0.08, size.y, 0.06)],
	]
	for bar: Array in bars:
		var box_mesh := BoxMesh.new()
		box_mesh.size = bar[1]
		_builder.mesh(box_mesh, at + facing * bar[0], GOLD, Vector3(0, turn, 0))
	var canvas_mesh := BoxMesh.new()
	canvas_mesh.size = Vector3(size.x, size.y, 0.02)
	_builder.mesh(canvas_mesh, at, canvas, Vector3(0, turn, 0))


## The desk against the west wall with three monitors and a chair, and the plate where the sandwich goes.
func _security() -> void:
	_builder.box(DESK_AT + Vector3(0, DESK_SIZE.y / 2, 0), DESK_SIZE, WOOD)
	for i in MONITORS:
		var z := DESK_AT.z + (i - (MONITORS - 1) / 2.0) * 0.9
		_builder.mesh_box(Vector3(DESK_AT.x - 0.2, DESK_SIZE.y + 0.3, z), Vector3(0.1, 0.45, 0.7), METAL.darkened(0.5))
		_builder.mesh_box(Vector3(DESK_AT.x - 0.14, DESK_SIZE.y + 0.3, z), Vector3(0.02, 0.38, 0.62),
			Color(0.3, 0.55, 0.45))
	_builder.box(DESK_AT + Vector3(1.0, 0.25, 0), Vector3(0.5, 0.5, 0.5), METAL)
	var plate := CylinderMesh.new()
	plate.top_radius = 0.16
	plate.bottom_radius = 0.14
	plate.height = 0.02
	_builder.mesh(plate, SANDWICH_AT, PORCELAIN)


## The six numbered lockers against the east wall, doors to the room.
func _lockers() -> void:
	for i in LOCKERS.size():
		var at := LOCKERS[i]
		_builder.box(at + Vector3(0, LOCKER_SIZE.y / 2, 0), LOCKER_SIZE, METAL)
		var number := Label3D.new()
		number.name = "Locker%d" % (i + 1)
		number.text = str(i + 1)
		number.font_size = 48
		number.pixel_size = 0.01
		number.position = at + Vector3(-LOCKER_SIZE.x / 2 - 0.01, 1.6, 0)
		number.rotation.y = -PI / 2
		add_child(number)


## Paintings standing under white sheets in the storage room.
func _storage() -> void:
	for at in STORED:
		_builder.box(at + Vector3(0, STORED_SIZE.y / 2, 0), STORED_SIZE, SHEET)


## The tiny bathroom: tiled floor, toilet, sink with the mirror over it, the paper roll and the hand dryer.
func _bathroom() -> void:
	var middle := Vector3((BATHROOM_X + GALLERY_X) / 2, FLOOR_TOP + 0.005, (BATHROOM_Z + HALL_Z) / 2)
	_builder.mesh_box(middle, Vector3(GALLERY_X - BATHROOM_X - 0.2, 0.01, HALL_Z - BATHROOM_Z - 0.2), TILE)
	_builder.box(TOILET_AT + Vector3(0, 0.2, 0), Vector3(0.4, 0.4, 0.55), PORCELAIN)
	_builder.mesh_box(TOILET_AT + Vector3(0, 0.6, -0.22), Vector3(0.4, 0.4, 0.15), PORCELAIN)
	_builder.box(SINK_AT + Vector3(0, 0.8, 0), Vector3(0.45, 0.15, 0.55), PORCELAIN)
	_builder.mesh_box(SINK_AT + Vector3(0, 0.4, 0), Vector3(0.12, 0.7, 0.12), PORCELAIN)
	_builder.mesh_box(MIRROR_AT, Vector3(0.02, 0.6, 0.5), Color(0.8, 0.9, 0.95))
	var roll := CylinderMesh.new()
	roll.top_radius = 0.06
	roll.bottom_radius = 0.06
	roll.height = 0.12
	_builder.mesh(roll, PAPER_AT, PORCELAIN, Vector3(PI / 2, 0, 0))
	_builder.mesh_box(DRYER_AT, Vector3(0.3, 0.35, 0.18), METAL)
	_builder.light(Vector3((BATHROOM_X + GALLERY_X) / 2, ROOF - 0.5, (BATHROOM_Z + HALL_Z) / 2))


## The ticket desk in the hall and a sign pointing to the gallery.
func _hall() -> void:
	_builder.box(DESK_HALL_AT + Vector3(0, 0.5, 0), Vector3(2.4, 1.0, 0.7), WOOD)
	var to_gallery := Label3D.new()
	to_gallery.name = "ToGallery"
	to_gallery.text = "SIGN_MUSEUM_GALLERY"
	to_gallery.font_size = 28
	to_gallery.pixel_size = 0.01
	to_gallery.position = Vector3(DOOR_GALLERY_X, GameScale.DOOR_HEIGHT + 0.16, HALL_Z + 0.1)
	add_child(to_gallery)
