class_name Airport
extends Node3D

## The city's airport (politico-aeropuerto.md, step 1, decision 231): it fills block (6, 4), its front to +Z on the
## street. The terminal, 40 x 24 m, faces the street with its doors in the middle: on the east of the hall the check-in
## counter with its scale, behind it the belt that takes the suitcases west to east through the X-ray machine, with
## the big screen over it where the press watches what goes through; at the back, the duty-free shop on the west and
## the gate on the east, with the glass wall between them that looks out at the apron and the little plane. The cops
## start in the station and drive here; --place=airport opens it from Play. Every number here is (propuesta).

const COUNTER_MODEL := preload("res://assets/models/checkin_counter.glb")
const XRAY_MODEL := preload("res://assets/models/xray_machine.glb")
const PLANE_MODEL := preload("res://assets/models/airplane.glb")
const SHELF_MODEL := preload("res://assets/models/duty_free_shelf.glb")
const SEATS_MODEL := preload("res://assets/models/gate_seats.glb")

## The block, half its side; the terminal's walls (x from -HALF_X to HALF_X, z from BACK_Z to FRONT_Z) and roof.
const HALF := 27.0
const HALF_X := 20.0
const BACK_Z := -2.0
const FRONT_Z := 22.0
const ROOF := 6.0
const FLOOR_TOP := 0.06
## The front doors in the middle, and the gate's door through the glass wall to the apron.
const DOORWAY := 4.0
const DOORWAY_HEIGHT := 3.0
const GATE_DOOR_X := 15.0
const GATE_DOORWAY := 2.2
## The glass wall at the back, between the shop and the gate, from this high.
const GLASS_X := 8.0
const GLASS_FROM := 0.9
## The check-in counter (its desk side to -Z), the belt along BELT_Z from BELT_X.x to BELT_X.y at BELT_TOP, and the
## X-ray machine on it with its screen above, facing the hall.
const COUNTER_AT := Vector3(-10, 0, 15)
const BELT_Z := 12.5
const BELT_X := Vector2(-14.0, 9.0)
const BELT_TOP := 0.75
const BELT_WIDTH := 1.0
const XRAY_AT := Vector3(5, 0, BELT_Z)
const SCREEN_AT := Vector3(5, 3.6, 11.6)
const SCREEN := Vector2(3.2, 1.8)
const FEED_SIZE := Vector2i(512, 288)
## Where the press stands, in front of the screen.
const PRESS_AT: Array[Vector3] = [Vector3(3.5, 0, 16.5), Vector3(5, 0, 17), Vector3(6.5, 0, 16.5)]
## The duty-free shop (west) and the gate (east), at the back of the hall, and what's in them.
const SHOP := Rect2(-HALF_X, BACK_Z, 11.0, 9.0)
const GATE := Rect2(HALF_X - 11.0, BACK_Z, 11.0, 9.0)
const SHELVES: Array[Vector3] = [Vector3(-18, 0, -1.4), Vector3(-15, 0, -1.4), Vector3(-12, 0, -1.4),
	Vector3(-16.5, 0, 3.5), Vector3(-13.5, 0, 3.5)]
const SEATS: Array[Vector3] = [Vector3(11.5, 0, 2.5), Vector3(14.5, 0, 2.5), Vector3(17.5, 0, 2.5),
	Vector3(11.5, 0, 5.0), Vector3(14.5, 0, 5.0), Vector3(17.5, 0, 5.0)]
## The plane on the apron, along +X with its stairs to the terminal.
const PLANE_AT := Vector3(0, 0, -15)

const WALL := Color(0.86, 0.88, 0.9)
const BAND := Color(0.16, 0.35, 0.66)
const FLOOR := Color(0.78, 0.8, 0.82)
const SHOP_FLOOR := Color(0.62, 0.42, 0.5)
const GATE_FLOOR := Color(0.55, 0.62, 0.75)
const ASPHALT := Color(0.24, 0.25, 0.27)
const PAINT := Color(0.95, 0.85, 0.2)
const CONCRETE := Color(0.7, 0.69, 0.66)
const GLASS := Color(0.62, 0.8, 0.92, 0.35)
const BELT := Color(0.12, 0.12, 0.14)
const RAIL := Color(0.72, 0.75, 0.8)
const XRAY_TINT := Color(0.55, 0.8, 1.0)

var case_seed := 0
var feed: SubViewport
var feed_camera: Camera3D
var screen: MeshInstance3D
var press: Array[RallyFan] = []
var _build: PlaceBuilder

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_grounds()
	_build_terminal()
	_build_hall()
	_build_shop_and_gate()
	_build_apron()
	city.transform = CityLayout.anchor("airport")
	car.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)


func in_terminal(at: Vector3) -> bool:
	var local := to_local(at)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z and local.y < ROOF


func in_shop(at: Vector3) -> bool:
	var local := to_local(at)
	return SHOP.has_point(Vector2(local.x, local.z)) and local.y < ROOF


func at_gate(at: Vector3) -> bool:
	var local := to_local(at)
	return GATE.has_point(Vector2(local.x, local.z)) and local.y < ROOF


func _process(_delta: float) -> void:
	# The screen shows the inside of the X-ray machine, from its roof down onto the belt.
	feed_camera.global_transform = Transform3D(Basis.looking_at(Vector3.DOWN, Vector3.FORWARD),
		to_global(XRAY_AT + Vector3.UP * 1.6))


## The front plaza, the grass around and the apron behind the terminal (the city's grass is at 0.035).
func _build_grounds() -> void:
	_build.mesh_box(Vector3(0, 0.045, (FRONT_Z + HALF) / 2), Vector3(HALF * 2, 0.02, HALF - FRONT_Z), CONCRETE)
	_build.mesh_box(Vector3(0, 0.045, (BACK_Z - HALF) / 2), Vector3(HALF * 2, 0.02, HALF + BACK_Z), ASPHALT)
	# The plane's taxi line and the stop marks.
	_build.mesh_box(Vector3(0, 0.06, PLANE_AT.z), Vector3(HALF * 2 - 2, 0.01, 0.25), PAINT)
	for x: float in [-6.0, 6.0]:
		_build.mesh_box(Vector3(x, 0.06, PLANE_AT.z), Vector3(0.25, 0.01, 3.0), PAINT)
	# A low fence around the apron.
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * (HALF - 0.5), 0.6, (BACK_Z - HALF) / 2), Vector3(0.1, 1.2, HALF + BACK_Z), RAIL)
	_build.box(Vector3(0, 0.6, -HALF + 0.5), Vector3(HALF * 2 - 1, 1.2, 0.1), RAIL)


## The floor, the walls with the front doors, the glass wall and the gate's door at the back, the roof and the sign.
func _build_terminal() -> void:
	_build.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, ROOF + 0.2, WALL.darkened(0.35))
	var y := ROOF / 2
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * HALF_X, y, (BACK_Z + FRONT_Z) / 2), Vector3(PlaceBuilder.WALL, ROOF, FRONT_Z - BACK_Z),
			WALL)
		# The front on each side of the doors.
		var from := DOORWAY / 2
		_build.box(Vector3(side * (from + HALF_X) / 2, y, FRONT_Z), Vector3(HALF_X - from, ROOF, PlaceBuilder.WALL), WALL)
	var lintel := ROOF - DOORWAY_HEIGHT
	_build.box(Vector3(0, DOORWAY_HEIGHT + lintel / 2, FRONT_Z), Vector3(DOORWAY, lintel, PlaceBuilder.WALL), WALL)
	# The back: solid by the shop, glass from GLASS_FROM up in the middle, and the gate's side with its door.
	_build.box(Vector3((-HALF_X - GLASS_X) / 2, y, BACK_Z), Vector3(HALF_X - GLASS_X, ROOF, PlaceBuilder.WALL), WALL)
	_build.box(Vector3(0, GLASS_FROM / 2, BACK_Z), Vector3(GLASS_X * 2, GLASS_FROM, PlaceBuilder.WALL), WALL)
	_glass(Vector3(0, (GLASS_FROM + ROOF) / 2, BACK_Z), Vector3(GLASS_X * 2, ROOF - GLASS_FROM, 0.05))
	var edges: Array[float] = [GLASS_X, GATE_DOOR_X - GATE_DOORWAY / 2, GATE_DOOR_X + GATE_DOORWAY / 2, HALF_X]
	for i in range(0, edges.size(), 2):
		_build.box(Vector3((edges[i] + edges[i + 1]) / 2, y, BACK_Z), Vector3(edges[i + 1] - edges[i], ROOF,
			PlaceBuilder.WALL), WALL)
	_build.box(Vector3(GATE_DOOR_X, DOORWAY_HEIGHT + lintel / 2, BACK_Z), Vector3(GATE_DOORWAY, lintel,
		PlaceBuilder.WALL), WALL)
	_build.mesh_box(Vector3(0, ROOF - 1.2, FRONT_Z + 0.1), Vector3(HALF_X * 2, 1.2, 0.05), BAND)
	_label("PLACE_AIRPORT", Vector3(0, ROOF - 1.2, FRONT_Z + 0.14), 0.0, 110)
	for x: float in [-14.0, 0.0, 14.0]:
		_build.light(Vector3(x, ROOF - 0.4, 6))
		_build.light(Vector3(x, ROOF - 0.4, 16))


## The check-in counter, the belt through the X-ray machine and the screen over it, and the press.
func _build_hall() -> void:
	var counter: Node3D = COUNTER_MODEL.instantiate()
	counter.name = "Counter"
	counter.position = COUNTER_AT + Vector3.UP * FLOOR_TOP
	$Built.add_child(counter)
	_build.shape(_build.body(counter.position + Vector3.UP * 0.55), Vector3(3.0, 1.1, 0.8))
	_label("AIRPORT_CHECKIN", COUNTER_AT + Vector3(0, 2.6, 0), 0.0, 48)
	var length := BELT_X.y - BELT_X.x
	var middle := Vector3((BELT_X.x + BELT_X.y) / 2, 0, BELT_Z)
	_build.box(middle + Vector3(0, BELT_TOP / 2, 0), Vector3(length, BELT_TOP, BELT_WIDTH), RAIL)
	_build.mesh_box(middle + Vector3(0, BELT_TOP + 0.01, 0), Vector3(length, 0.02, BELT_WIDTH - 0.1), BELT)
	for side: float in [-1.0, 1.0]:
		_build.box(middle + Vector3(0, BELT_TOP + 0.1, side * (BELT_WIDTH / 2 + 0.03)), Vector3(length, 0.2, 0.06), RAIL)
	var xray: Node3D = XRAY_MODEL.instantiate()
	xray.name = "Xray"
	xray.position = XRAY_AT + Vector3.UP * FLOOR_TOP
	$Built.add_child(xray)
	for side: float in [-1.0, 1.0]:
		_build.shape(_build.body(XRAY_AT + Vector3(0, 0.95, side * 0.55)), Vector3(2.4, 1.9, 0.1))
	_build.shape(_build.body(XRAY_AT + Vector3(0, 1.55, 0)), Vector3(2.4, 0.5, 1.2))
	_label("AIRPORT_XRAY", XRAY_AT + Vector3(0, 2.3, 0.65), 0.0, 40)
	_build_screen()
	for i in PRESS_AT.size():
		var reporter := RallyFan.new()
		reporter.name = "Press%d" % i
		reporter.look = "periodista"
		add_child(reporter)
		reporter.position = PRESS_AT[i] + Vector3.UP * (FLOOR_TOP + 0.05)
		# NPCs face -Z: toward the screen.
		reporter.rotation.y = PI
		press.append(reporter)


## The screen over the X-ray machine: what's inside it, live, in X-ray blue.
func _build_screen() -> void:
	feed = SubViewport.new()
	feed.name = "Feed"
	feed.size = FEED_SIZE
	feed.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(feed)
	feed_camera = Camera3D.new()
	feed_camera.name = "FeedCamera"
	feed_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	feed_camera.size = 1.2
	feed.add_child(feed_camera)
	screen = MeshInstance3D.new()
	screen.name = "Screen"
	var quad := QuadMesh.new()
	quad.size = SCREEN
	screen.mesh = quad
	var live := StandardMaterial3D.new()
	live.albedo_color = XRAY_TINT
	live.albedo_texture = feed.get_texture()
	live.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = live
	screen.position = SCREEN_AT
	$Built.add_child(screen)
	_build.mesh_box(SCREEN_AT + Vector3(0, 0, -0.06), Vector3(SCREEN.x + 0.2, SCREEN.y + 0.2, 0.1), BELT)
	_build.mesh_box(SCREEN_AT + Vector3(0, SCREEN.y / 2 + (ROOF - SCREEN_AT.y - SCREEN.y / 2) / 2, -0.06),
		Vector3(0.1, ROOF - SCREEN_AT.y - SCREEN.y / 2, 0.1), RAIL)
	_process(0.0)


## The duty-free shop's floor, shelves and sign; the gate's floor, seats, desk and sign.
func _build_shop_and_gate() -> void:
	_build.mesh_box(Vector3(SHOP.get_center().x, FLOOR_TOP + 0.01, SHOP.get_center().y), Vector3(SHOP.size.x, 0.02,
		SHOP.size.y), SHOP_FLOOR)
	for i in SHELVES.size():
		var shelf: Node3D = SHELF_MODEL.instantiate()
		shelf.name = "Shelf%d" % i
		shelf.position = SHELVES[i] + Vector3.UP * FLOOR_TOP
		$Built.add_child(shelf)
		_build.shape(_build.body(shelf.position + Vector3.UP * 0.9), Vector3(2.0, 1.8, 0.45))
	_label("AIRPORT_DUTY_FREE", Vector3(SHOP.get_center().x, 3.4, SHOP.end.y), 0.0, 44)
	_build.mesh_box(Vector3(GATE.get_center().x, FLOOR_TOP + 0.01, GATE.get_center().y), Vector3(GATE.size.x, 0.02,
		GATE.size.y), GATE_FLOOR)
	for i in SEATS.size():
		var seats: Node3D = SEATS_MODEL.instantiate()
		seats.name = "Seats%d" % i
		seats.position = SEATS[i] + Vector3.UP * FLOOR_TOP
		$Built.add_child(seats)
		_build.shape(_build.body(seats.position + Vector3.UP * 0.4), Vector3(2.4, 0.8, 0.5))
	_build.box(Vector3(GATE_DOOR_X + 2.5, FLOOR_TOP + 0.55, BACK_Z + 1.2), Vector3(1.6, 1.1, 0.7), BAND)
	_label("AIRPORT_GATE", Vector3(GATE_DOOR_X, DOORWAY_HEIGHT + 0.5, BACK_Z + 0.12), 0.0, 44)


## The plane on the apron, solid enough to bump into.
func _build_apron() -> void:
	var plane: Node3D = PLANE_MODEL.instantiate()
	plane.name = "Plane"
	plane.position = PLANE_AT
	$Built.add_child(plane)
	_build.shape(_build.body(PLANE_AT + Vector3(0, 2.2, 0)), Vector3(15.0, 2.4, 2.4))
	_build.shape(_build.body(PLANE_AT + Vector3(0.5, 1.8, 0)), Vector3(2.2, 0.2, 14.0))


func _glass(center: Vector3, size: Vector3) -> void:
	var body := _build.body(center)
	_build.shape(body, size)
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


func _label(key: String, at: Vector3, turn: float, size: int) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = 0.01
	label.outline_size = 12
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)
