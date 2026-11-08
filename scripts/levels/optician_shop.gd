class_name OpticianShop
extends Node3D

## The optician's shop "El Lente Borroso" as a place to raid (docs/diseno/allanamiento-optica.md, step 1a): a shop on
## its lot in the city with the front to +Z, the glass door open because it's opening hours, a shop window on either
## side and the giant glasses over the door. The salon at the front, with three wall displays of glasses, the turning
## stand, the try-on mirror and the counter with the till between two glass display cases. At the back, from west to
## east: the exam room (the exam chair facing the eye chart, the eye machine and a high shelf), the open waiting room
## and the lens workshop, locked with the till's key. Something that hits a display case or the mirror fast breaks it,
## a fine each. Step 1b: E on a wall display tries a pair of glasses on (TriedGlasses), the turning stand throws
## glasses when pushed (GlassesCarousel) and the exam chair goes up with its pedal (ExamChair). Every number here is
## (propuesta).

signal good_broken(index: int)
signal glasses_tried(cop: Cop, look: String)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const DISPLAY_MODEL := preload("res://assets/models/glasses_display.glb")
const CASE_MODEL := preload("res://assets/models/display_case.glb")
const MIRROR_MODEL := preload("res://assets/models/try_mirror.glb")
const CHART_MODEL := preload("res://assets/models/eye_chart.glb")
const MACHINE_MODEL := preload("res://assets/models/phoropter.glb")
const WAITING_CHAIR_MODEL := preload("res://assets/models/waiting_chair.glb")
const MAGAZINE_TABLE_MODEL := preload("res://assets/models/magazine_table.glb")
const WORKBENCH_MODEL := preload("res://assets/models/lens_workbench.glb")
const CASE_BOX_MODEL := preload("res://assets/models/case_box.glb")
const SIGN_MODEL := preload("res://assets/models/giant_glasses_sign.glb")
const HALF_X := 11.0
const HALF_Z := 9.0
## The shop's ceiling, and the closed roof over it up to the lot's height.
const WALL_TOP := 4.2
const BUILDING_TOP := 7.0
const FLOOR_TOP := 0.06
## The open doorway in the middle of the front, and the shop windows on either side of it.
const DOOR_HALF := 1.5
const WINDOW_FROM := 0.6
const WINDOW_TO := 2.8

## The wall displays, each standing on the floor at `at` and turned `turn` around Y (its front to +Z before the turn).
const DISPLAYS := [
	{"at": Vector3(-10.75, FLOOR_TOP, 6.0), "turn": PI / 2},
	{"at": Vector3(-10.75, FLOOR_TOP, 2.0), "turn": PI / 2},
	{"at": Vector3(10.75, FLOOR_TOP, 6.0), "turn": -PI / 2},
]
const CAROUSEL_AT := Vector3(-3.0, FLOOR_TOP, 4.5)
## The fragile goods: the two glass display cases on either side of the counter and the try-on mirror.
const GOODS := [
	{"kind": "case", "at": Vector3(1.9, FLOOR_TOP, 3.0), "turn": 0.0},
	{"kind": "case", "at": Vector3(8.1, FLOOR_TOP, 3.0), "turn": 0.0},
	{"kind": "mirror", "at": Vector3(10.8, FLOOR_TOP, 2.0), "turn": -PI / 2},
]
const GOOD_SPEED := 3.0
const GOOD_FINE := 25
## The counter in the salon between the display cases, with the till; the optician's side is -Z.
const COUNTER_AT := Vector3(5.0, FLOOR_TOP, 3.0)
const COUNTER_SIZE := Vector3(3.0, 1.0, 0.8)
const TILL_ON := Vector3(5.8, FLOOR_TOP + 1.0, 3.0)
## The wall between the salon and the back rooms, and the two walls that close the waiting room's sides.
const BACK_Z := -1.0
const EXAM_X := -3.0
const WORKSHOP_X := 3.0
const EXAM_DOOR_X := -7.0
const WORKSHOP_DOOR_X := 7.0
## The exam room: the chair faces the eye chart on the west wall, the eye machine beside it, the high shelf behind it
## (out of reach from the floor; step 1b raises the chair to get there).
const EXAM_CHAIR_AT := Vector3(-8.5, FLOOR_TOP, -7.4)
const CHART_AT := Vector3(-10.9, FLOOR_TOP + 1.45, -7.4)
const MACHINE_AT := Vector3(-9.1, FLOOR_TOP, -6.8)
const SHELF_AT := Vector3(-8.5, FLOOR_TOP + 2.6, -8.65)
const SHELF_SIZE := Vector3(2.0, 0.05, 0.6)
## The waiting room: four chairs against the back wall and the magazine table.
const WAITING_XS: Array[float] = [-2.1, -0.7, 0.7, 2.1]
const WAITING_Z := -8.4
const MAGAZINE_TABLE_AT := Vector3(0.0, FLOOR_TOP, -6.5)
## The workshop: the long workbench and two boxes of empty glasses cases.
const WORKBENCH_AT := Vector3(7.5, FLOOR_TOP, -8.45)
const CASE_BOXES: Array[Vector3] = [Vector3(10.4, FLOOR_TOP, -2.0), Vector3(10.4, FLOOR_TOP, -4.4)]
const CASE_BOX_SIZE := Vector3(0.6, 0.4, 0.4)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_display_0", "at": Vector3(-10.75, FLOOR_TOP + 0.1, 6.0), "heavy": true},
	{"id": "in_display_1", "at": Vector3(-10.75, FLOOR_TOP + 0.1, 2.0), "heavy": true},
	{"id": "behind_optician_counter", "at": Vector3(4.2, FLOOR_TOP, 2.1), "heavy": true},
	{"id": "in_workshop_corner", "at": Vector3(4.0, FLOOR_TOP, -8.4), "heavy": true},
	{"id": "between_case_boxes", "at": Vector3(10.4, FLOOR_TOP, -3.2), "heavy": true},
	{"id": "in_display_2", "at": Vector3(10.75, FLOOR_TOP + 0.1, 6.0), "heavy": false},
	{"id": "in_optician_counter", "at": Vector3(5.0, FLOOR_TOP + 0.05, 3.0), "heavy": false},
	{"id": "under_eye_chart", "at": Vector3(-10.75, FLOOR_TOP, -7.4), "heavy": false},
	{"id": "on_eye_machine", "at": Vector3(-9.1, FLOOR_TOP + 1.3, -7.25), "heavy": false},
	{"id": "under_exam_chair", "at": Vector3(-8.5, FLOOR_TOP, -7.1), "heavy": false},
	{"id": "in_magazines", "at": Vector3(0.0, FLOOR_TOP + 0.5, -6.5), "heavy": false},
	{"id": "on_high_shelf", "at": SHELF_AT + Vector3(0, 0.03, 0), "heavy": false},
]

const OUTSIDE := Color(0.82, 0.9, 0.95)
const TILES := Color(0.9, 0.9, 0.88)
const EXAM_FLOOR := Color(0.72, 0.82, 0.86)
const WORKSHOP_FLOOR := Color(0.6, 0.58, 0.55)
const RED := Color(0.78, 0.2, 0.2)
const DARK := Color(0.1, 0.1, 0.12)
const GLASS := Color(0.75, 0.88, 0.95, 0.25)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var workshop_door: FrontDoor
var till: Till
## The pieces: the wall displays in the order of DISPLAYS, the exam chair, and the fragile goods in the order of GOODS.
var displays: Array[StaticBody3D] = []
var carousel: GlassesCarousel
var exam_chair: ExamChair
var goods: Array[StaticBody3D] = []
var broken: Array[int] = []
var broken_goods := 0
## Money taken off the case pay: the display cases and the mirror.
var fines := 0
## Same seed, same shop (the stories and the hiding spots come from it, step 4).
@export var case_seed := 0
var _build: PlaceBuilder
## Which pair a cop gets at a wall display: same seed, same pairs in the same order.
var _glasses_rng := RandomNumberGenerator.new()
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_glasses_rng.seed = case_seed
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_salon()
	_build_counter()
	_build_back_walls()
	_build_exam_room()
	_build_waiting_room()
	_build_workshop()
	_place_goods()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("optician")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "optician", car)


## The tiles, the walls with the doorway and the two shop windows, the roof, the name and the giant glasses.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, TILES)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, OUTSIDE.darkened(0.1))
	for side: float in [-1.0, 1.0]:
		var a := side * DOOR_HALF
		var b := side * HALF_X
		_build.wall_at("x", HALF_Z, minf(a, b), maxf(a, b), 0.0, WINDOW_FROM, [], OUTSIDE)
		_build.wall_at("x", HALF_Z, minf(a, b), maxf(a, b), WINDOW_TO, WALL_TOP - WINDOW_TO, [], OUTSIDE)
		_glass(Vector3(side * (DOOR_HALF + HALF_X) / 2, (WINDOW_FROM + WINDOW_TO) / 2, HALF_Z),
			Vector3(HALF_X - DOOR_HALF, WINDOW_TO - WINDOW_FROM, 0.06))
	_build.wall_at("x", HALF_Z, -DOOR_HALF, DOOR_HALF, WINDOW_TO, WALL_TOP - WINDOW_TO, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_model(SIGN_MODEL, Vector3(0, 3.55, HALF_Z + 0.3))
	_label("PLACE_OPTICIAN", Vector3(0, WALL_TOP + 1.0, HALF_Z + 0.08), 110)
	_label("OPTICIAN_WINDOW_SIGN", Vector3(-6.25, WINDOW_TO - 0.4, HALF_Z + 0.06), 64)
	_label("OPTICIAN_WINDOW_SIGN", Vector3(6.25, WINDOW_TO - 0.4, HALF_Z + 0.06), 64)
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-5.0, 2.0, 6.5]:
			_build.light(Vector3(x, WALL_TOP - 0.4, z))


## The salon: the three wall displays with their glasses and the turning stand in the middle.
func _build_salon() -> void:
	for spec: Dictionary in DISPLAYS:
		var display := GlassesDisplay.new()
		display.tried.connect(try_on)
		displays.append(_piece(DISPLAY_MODEL, spec.at, spec.turn, [
			[Vector3(0, 1.0, -0.155), Vector3(1.2, 2.0, 0.04)],
			[Vector3(-0.58, 1.0, 0), Vector3(0.04, 2.0, 0.35)],
			[Vector3(0.58, 1.0, 0), Vector3(0.04, 2.0, 0.35)],
			[Vector3(0, 0.05, 0), Vector3(1.2, 0.1, 0.35)],
			[Vector3(0, 1.96, 0), Vector3(1.2, 0.08, 0.35)],
		], display))
	carousel = GlassesCarousel.new()
	carousel.name = "Carousel"
	carousel.position = CAROUSEL_AT
	add_child(carousel)


## A cop tried a pair on at a wall display: a pair drawn with the seed, on its face for TriedGlasses.SECONDS, and on
## its own PC the screen looks that way.
func try_on(cop: Cop) -> void:
	var look: String = TriedGlasses.LOOKS[_glasses_rng.randi_range(0, TriedGlasses.LOOKS.size() - 1)]
	TriedGlasses.put_on(cop, look, cop.input_enabled)
	glasses_tried.emit(cop, look)


## The counter with the till, open on the optician's side.
func _build_counter() -> void:
	_build.mesh_box(Vector3(5.0, FLOOR_TOP + 0.005, 4.4), Vector3(9.0, 0.01, 1.6), RED.lightened(0.35))
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", RED)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_OPTICIAN"
	add_child(till)


## The wall between the salon and the back rooms, with the exam room's doorway, the workshop's locked door and the
## waiting room open in the middle, and the two walls that close the waiting room's sides.
func _build_back_walls() -> void:
	_build.wall_at("x", BACK_Z, -HALF_X, EXAM_X, 0.0, WALL_TOP, [EXAM_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("x", BACK_Z, WORKSHOP_X, HALF_X, 0.0, WALL_TOP, [WORKSHOP_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("z", EXAM_X, -HALF_Z, BACK_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	_build.wall_at("z", WORKSHOP_X, -HALF_Z, BACK_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	workshop_door = DOOR_SCENE.instantiate()
	workshop_door.position = Vector3(WORKSHOP_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(workshop_door)


## The exam room: the chair facing the eye chart, the eye machine and the high shelf behind the chair.
func _build_exam_room() -> void:
	_build.mesh_box(Vector3((-HALF_X + EXAM_X) / 2, FLOOR_TOP + 0.005, (-HALF_Z + BACK_Z) / 2),
		Vector3(EXAM_X + HALF_X, 0.01, BACK_Z + HALF_Z), EXAM_FLOOR)
	exam_chair = ExamChair.new()
	exam_chair.name = "ExamChair"
	exam_chair.position = EXAM_CHAIR_AT
	exam_chair.rotation.y = -PI / 2
	add_child(exam_chair)
	var chart := _model(CHART_MODEL, CHART_AT, PI / 2)
	chart.name = "EyeChart"
	_piece(MACHINE_MODEL, MACHINE_AT, PI, [
		[Vector3(0, 0.03, 0), Vector3(0.45, 0.06, 0.45)],
		[Vector3(0, 0.65, 0), Vector3(0.08, 1.3, 0.08)],
		[Vector3(0, 1.18, 0.45), Vector3(0.5, 0.24, 0.12)],
	])
	_build.box(SHELF_AT - Vector3(0, SHELF_SIZE.y / 2, 0), SHELF_SIZE, OUTSIDE.darkened(0.25))


## The waiting room: four chairs against the back wall, facing the salon, and the table with the old magazines.
func _build_waiting_room() -> void:
	for x: float in WAITING_XS:
		_piece(WAITING_CHAIR_MODEL, Vector3(x, FLOOR_TOP, WAITING_Z), 0.0, [
			[Vector3(0, 0.235, 0), Vector3(0.48, 0.47, 0.46)],
			[Vector3(0, 0.68, -0.22), Vector3(0.48, 0.4, 0.05)],
		])
	_piece(MAGAZINE_TABLE_MODEL, MAGAZINE_TABLE_AT, 0.0, [[Vector3(0, 0.225, 0), Vector3(0.8, 0.45, 0.5)]])


## The workshop: a concrete floor, the lens workbench and the boxes of empty glasses cases.
func _build_workshop() -> void:
	_build.mesh_box(Vector3((WORKSHOP_X + HALF_X) / 2, FLOOR_TOP + 0.005, (-HALF_Z + BACK_Z) / 2),
		Vector3(HALF_X - WORKSHOP_X, 0.01, BACK_Z + HALF_Z), WORKSHOP_FLOOR)
	_piece(WORKBENCH_MODEL, WORKBENCH_AT, 0.0, [[Vector3(0, 0.45, 0), Vector3(3.0, 0.9, 0.8)]])
	for at: Vector3 in CASE_BOXES:
		_piece(CASE_BOX_MODEL, at, 0.0, [[Vector3(0, CASE_BOX_SIZE.y / 2, 0), CASE_BOX_SIZE]])


## The display cases and the mirror: a body each, and an area around it that breaks it when something flies in fast.
func _place_goods() -> void:
	for i in GOODS.size():
		var spec: Dictionary = GOODS[i]
		var display_case: bool = spec.kind == "case"
		var size := Vector3(1.4, 1.0, 0.6) if display_case else Vector3(0.6, 1.9, 0.12)
		var body := _piece(CASE_MODEL if display_case else MIRROR_MODEL, spec.at, spec.turn,
			[[Vector3(0, size.y / 2, 0), size]])
		body.name = "Good%d" % i
		goods.append(body)
		var area := Area3D.new()
		area.position = Vector3(0, size.y / 2, 0)
		area.collision_layer = 0
		area.collision_mask = 4
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size + Vector3(0.3, 0.1, 0.3)
		shape.shape = box
		area.add_child(shape)
		body.add_child(area)
		area.body_entered.connect(func(hit: Node3D) -> void:
			if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > GOOD_SPEED:
				break_good(i))


## Breaks good `index`, once: a fine, and cracks across the display case's glass or the mirror.
func break_good(index: int) -> void:
	if broken.has(index):
		return
	broken.append(index)
	broken_goods += 1
	fines += GOOD_FINE
	var body := goods[index]
	var display_case: bool = GOODS[index].kind == "case"
	var middle := Vector3(0, 0.85, 0.31) if display_case else Vector3(0, 1.15, 0.04)
	var reach := Vector2(0.5, 0.12) if display_case else Vector2(0.2, 0.5)
	for i in 6:
		var turn := i * TAU / 6.0 + 0.4
		var crack := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.25 + (i % 3) * 0.1, 0.015, 0.015)
		crack.mesh = mesh
		crack.material_override = _build.material(DARK)
		crack.position = middle + Vector3(cos(turn) * reach.x * 0.6, sin(turn) * reach.y * 0.6, 0)
		crack.rotation.z = turn
		crack.name = "Crack%d" % i
		body.add_child(crack)
	_say(body.position + Vector3(0, 2.2, 0), "OPTICIAN_GOOD_BROKEN")
	good_broken.emit(index)


## A piece of furniture: a body at `at` turned `turn`, with its model and one box shape per [center, size]. `body`:
## one that does something (a wall display), else a plain one.
func _piece(scene: PackedScene, at: Vector3, turn: float, shapes: Array, body: StaticBody3D = null) -> StaticBody3D:
	if not body:
		body = StaticBody3D.new()
	body.position = at
	body.rotation.y = turn
	for spec: Array in shapes:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = spec[1]
		shape.shape = box
		shape.position = spec[0]
		body.add_child(shape)
	body.add_child(scene.instantiate())
	add_child(body)
	return body


## The shop window's pane: see-through, but solid.
func _glass(center: Vector3, size: Vector3) -> void:
	_build.shape(_build.body(center), size)
	var pane := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	pane.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = GLASS
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pane.material_override = material
	pane.position = center
	$Built.add_child(pane)


func _label(key: String, at: Vector3, size: int) -> void:
	var sign_label := Label3D.new()
	sign_label.text = key
	sign_label.font_size = size
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.position = at
	$Built.add_child(sign_label)


## A floating line over `at` for a few seconds.
func _say(at: Vector3, key: String) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(3.0).timeout.connect(label.queue_free)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
