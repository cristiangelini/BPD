class_name DentistRaid
extends Node3D

## The dental office "Sonrisa Total" as a place to raid (docs/diseno/allanamiento-dentista.md, step 2): one floor on
## its lot in the city, with the front to +Z. The waiting room at the front, with the reception desk (the candy jar and
## the next-patient bell on it), the fish tank and the chairs; a corridor across; and at the back the two consulting
## rooms with their chairs and gas tanks, the lab with the cabinet of denture molds and the X-ray light box, and Dr.
## Molina's office with the storeroom behind it, locked. The fish tank breaks when something hits it hard: a fine,
## and the floor around it stays wet (a cop running there slips, like on the jail's wet floor). Each mold that breaks
## counts. SPOTS are the 12 hiding spots the stories draw from (step 5). Dr. Molina walks the corridor (step 3): he
## fills the complaint ("¡Eso no es estéril!") with every mold he sees break and every cop he sees up on one of his
## chairs, and the next-patient bell on the reception sends him to consulting room 1 with his back to the door.
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const CHAIR_MODEL := preload("res://assets/models/dentist_chair.glb")
const TANK_MODEL := preload("res://assets/models/fish_tank.glb")
const GAS_MODEL := preload("res://assets/models/gas_tank.glb")
const CABINET_MODEL := preload("res://assets/models/mold_cabinet.glb")
const MOLD_MODEL := preload("res://assets/models/denture_mold.glb")
const XRAY_MODEL := preload("res://assets/models/xray_lightbox.glb")
const JAR_MODEL := preload("res://assets/models/candy_jar.glb")
const MOLINA_SCENE := preload("res://scenes/npc/dentist_molina.tscn")
const HALF_X := 11.0
const HALF_Z := 8.0
const WALL_TOP := 3.2
const BUILDING_TOP := 4.0
const FLOOR_TOP := 0.06
const ENTRANCE_WIDTH := 2.0
const OPENING_WIDTH := 1.4
## The waiting room's back wall, and the corridor behind it up to the rooms' wall.
const WAITING_Z := 3.0
const ROOMS_Z := 1.0
## The rooms across the back, west to east: consulting room 1, consulting room 2, the lab and the office (with the
## storeroom behind it, from STOREROOM_Z back).
const ROOM_WALLS: Array[float] = [-5.5, 0.0, 5.5]
const ROOM_DOORS: Array[float] = [-8.25, -2.75, 2.75, 8.25]
const STOREROOM_Z := -3.5
const STOREROOM_DOOR_X := 8.25
const CHAIRS: Array[Vector3] = [Vector3(-8.25, FLOOR_TOP, -3.5), Vector3(-2.75, FLOOR_TOP, -3.5)]
const GAS_TANKS: Array[Vector3] = [Vector3(-10.4, FLOOR_TOP, -6.0), Vector3(-0.6, FLOOR_TOP, -6.0)]
const ROOM_CUPBOARDS: Array[Vector3] = [Vector3(-6.3, FLOOR_TOP, -7.4), Vector3(-1.0, FLOOR_TOP, -7.4)]
const CUPBOARD_SIZE := Vector3(1.4, 0.9, 0.6)
const CABINET_AT := Vector3(4.0, FLOOR_TOP, -7.7)
const LAB_TABLE_AT := Vector3(2.75, FLOOR_TOP, -3.0)
const LAB_TABLE_SIZE := Vector3(2.4, 0.9, 1.0)
const KILN_AT := Vector3(5.0, FLOOR_TOP, -3.0)
const KILN_SIZE := Vector3(0.7, 1.0, 0.7)
const XRAY_AT := Vector3(0.2, FLOOR_TOP + 1.3, -5.0)
const DESK_AT := Vector3(8.25, FLOOR_TOP, -1.3)
const DESK_SIZE := Vector3(2.2, 0.75, 0.9)
const SHELF_X := 10.6
const RECEPTION_AT := Vector3(-7.0, FLOOR_TOP, 5.0)
const RECEPTION_SIZE := Vector3(3.0, 1.0, 0.8)
const TANK_AT := Vector3(9.4, FLOOR_TOP, 5.5)
const SEATS: Array[Vector3] = [Vector3(-1.5, FLOOR_TOP, 7.3), Vector3(0.0, FLOOR_TOP, 7.3), Vector3(1.5, FLOOR_TOP, 7.3),
	Vector3(4.0, FLOOR_TOP, 4.0), Vector3(5.5, FLOOR_TOP, 4.0)]
const RACK_AT := Vector3(3.0, FLOOR_TOP, 7.4)
## The molds on the lab's table that break (the cabinet's are only for the look).
const MOLDS := 6
## Something hitting the fish tank faster than this breaks it: a fine, and the wet floor around it.
const TANK_SPEED := 4.0
const TANK_FINE := 20
const WET := Rect2(6.0, 3.2, 4.8, 4.6)
## Running faster than walking on the wet floor slips: down for WET_SLIP seconds, and not again for WET_AGAIN.
const WET_SLIP := 2.0
const WET_PUSH := 3.0
const WET_AGAIN := 3.0

## Dr. Molina's round, back and forth along the corridor, looking into every room through its door.
const MOLINA_ROUTE: Array[Vector3] = [Vector3(-8.25, FLOOR_TOP, 2.0), Vector3(-2.75, FLOOR_TOP, 2.0),
	Vector3(2.75, FLOOR_TOP, 2.0), Vector3(8.25, FLOOR_TOP, 2.0)]
## Where he "sees" the next patient: beside chair 1, facing it, his back to the room's door.
const PATIENT_SPOT := Vector3(-7.7, FLOOR_TOP, -2.3)
## Seeing a mold break, and a cop up on one of his chairs.
const SAW_MOLD := 2.0
const SAW_IN_CHAIR := 10.0
## Up on a chair: over its seat (from its middle, across and back to front) and higher than this.
const SEAT := Vector2(0.5, 1.0)
const SEAT_HEIGHT := 0.5

const OUTSIDE := Color(0.92, 0.95, 0.97)
const MINT := Color(0.55, 0.82, 0.74)
const TILE := Color(0.9, 0.92, 0.93)
const FLOOR := Color(0.78, 0.86, 0.88)
const WOOD := Color(0.62, 0.48, 0.34)
const STEEL := Color(0.74, 0.77, 0.8)
const GLASS := Color(0.6, 0.8, 0.9, 0.35)
const WATER := Color(0.45, 0.65, 0.85, 0.5)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "dentist_under_chair_1", "at": CHAIRS[0] + Vector3(0.0, 0.0, 0.75), "heavy": true},
	{"id": "dentist_under_chair_2", "at": CHAIRS[1] + Vector3(0.0, 0.0, 0.75), "heavy": true},
	{"id": "dentist_behind_fish_tank", "at": TANK_AT + Vector3(-0.2, 0.0, -0.75), "heavy": true},
	{"id": "dentist_under_reception", "at": RECEPTION_AT + Vector3(0.0, 0.0, -0.9), "heavy": true},
	{"id": "dentist_in_storeroom", "at": Vector3(9.0, FLOOR_TOP, -6.5), "heavy": true},
	{"id": "dentist_under_lab_table", "at": LAB_TABLE_AT, "heavy": true},
	{"id": "dentist_in_cupboard_1", "at": ROOM_CUPBOARDS[0] + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "dentist_in_cupboard_2", "at": ROOM_CUPBOARDS[1] + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "dentist_in_kiln", "at": KILN_AT + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "dentist_in_magazine_rack", "at": RACK_AT + Vector3(0.0, 0.3, 0.0), "heavy": false},
	{"id": "dentist_on_office_desk", "at": DESK_AT + Vector3(0.6, DESK_SIZE.y, 0.0), "heavy": false},
	{"id": "dentist_on_office_shelf", "at": Vector3(SHELF_X, FLOOR_TOP + 1.2, -1.2), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var storeroom_door: FrontDoor
var molds: Array[Ornament] = []
var fish_tank: Node3D
var tank_broken := false
var broken_goods := 0
var fines := 0
var molina: FloorBoss
var bell: NextPatientBell
var complaint_bar: ProgressBar
## Cops Dr. Molina already saw up on a chair (until they get down).
var _seen_in_chair := {}
var _build: PlaceBuilder
## Cop -> seconds until it can slip on the wet floor again.
var _slipped := {}
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_waiting_room()
	_build_rooms()
	_build_lab()
	_build_office()
	_place_molds()
	storeroom_door = _door(Vector3(STOREROOM_DOOR_X, FLOOR_TOP, STOREROOM_Z))
	_place_molina()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("dentist")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "dentist", car)


## Whether `at` (this scene's space) is on the wet floor of the broken fish tank.
func on_wet_floor(at: Vector3) -> bool:
	return tank_broken and WET.has_point(Vector2(at.x, at.z)) and at.y < FLOOR_TOP + 0.5


func _physics_process(delta: float) -> void:
	for cop: Variant in _slipped.keys():
		_slipped[cop] -= delta
		if _slipped[cop] <= 0.0 or not is_instance_valid(cop):
			_slipped.erase(cop)
	# Online the host's doctor minds his chairs; the guests' one only follows.
	if molina and multiplayer.is_server():
		_watch_chairs()
	if not tank_broken:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.sync and not cop.sync.is_multiplayer_authority():
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if _slipped.has(cop) or not cop.is_running or flat.length() <= GameScale.WALK_SPEED \
				or not on_wet_floor(to_local(cop.global_position)):
			continue
		_slipped[cop] = WET_AGAIN
		cop.get_node("Grabber").release()
		cop.knock_back(flat.normalized() * WET_PUSH, WET_SLIP)
		cop.show_hint("HINT_WET_FLOOR")


## Shatters the fish tank, once: a fine, the glass and the water gone, and a wet floor around it.
func break_fish_tank() -> void:
	if tank_broken:
		return
	tank_broken = true
	broken_goods += 1
	fines += TANK_FINE
	if molina:
		molina.saw(fish_tank.global_position + Vector3.UP * 0.6, FloorBoss.SAW_BREAK, "MOLINA_TANK")
	fish_tank.queue_free()
	_build.mesh_box(Vector3(WET.get_center().x, FLOOR_TOP + 0.006, WET.get_center().y), Vector3(WET.size.x, 0.004,
		WET.size.y), WATER)


## Light walls, the shop window with the entrance, the ceiling, the roof and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, TILE)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.0, 1.0, MINT)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.0, 1.0, MINT)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 1.0, 2.6, GLASS)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 1.0, 2.6, GLASS)
	_wall_box("x", HALF_Z, -HALF_X, HALF_X, 2.6, WALL_TOP, OUTSIDE)
	_wall("x", -HALF_Z, -HALF_X, HALF_X, [], OUTSIDE)
	_wall("z", -HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	_wall("z", HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	var roof := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + roof / 2, 0), Vector3(HALF_X * 2, roof, HALF_Z * 2), OUTSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_DENTIST"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.modulate = MINT.darkened(0.3)
	sign_label.position = Vector3(0, WALL_TOP + 0.4, HALF_Z + 0.08)
	$Built.add_child(sign_label)


## The waiting room: the reception desk with the candy jar and the bell, the fish tank, the seats and the magazines.
func _build_waiting_room() -> void:
	var doors: Array = [-6.0, 0.0, 6.0].map(func(x: float) -> Vector3: return Vector3(x, OPENING_WIDTH * 1.5, 2.4))
	_wall("x", WAITING_Z, -HALF_X, HALF_X, doors, TILE)
	_build.open_box(RECEPTION_AT, RECEPTION_SIZE, "-z", WOOD)
	_model(JAR_MODEL, RECEPTION_AT + Vector3(-0.8, RECEPTION_SIZE.y, 0.1))
	bell = NextPatientBell.new()
	bell.position = RECEPTION_AT + Vector3(0.9, RECEPTION_SIZE.y, 0.15)
	add_child(bell)
	fish_tank = _model(TANK_MODEL, TANK_AT, -PI / 2)
	var tank_body := StaticBody3D.new()
	tank_body.position = Vector3(0, 0.65, 0)
	fish_tank.add_child(tank_body)
	_build.shape(tank_body, Vector3(1.0, 1.3, 0.45))
	var area := Area3D.new()
	area.position = Vector3(0, 0.65, 0)
	area.collision_layer = 0
	area.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.3, 1.5, 0.75)
	shape.shape = box
	area.add_child(shape)
	fish_tank.add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if multiplayer.is_server() and body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > TANK_SPEED:
			break_fish_tank())
	for at: Vector3 in SEATS:
		_build.box(at + Vector3(0, 0.23, 0), Vector3(0.5, 0.46, 0.5), MINT.darkened(0.15))
		_build.mesh_box(at + Vector3(0, 0.7, -0.22 if at.z > 6.0 else 0.22), Vector3(0.5, 0.5, 0.06), MINT.darkened(0.15))
	_build.open_box(RACK_AT, Vector3(0.8, 0.6, 0.35), "y", WOOD)
	_build.light(Vector3(-5.0, 2.9, 5.5))
	_build.light(Vector3(5.0, 2.9, 5.5))


## The two consulting rooms, each with its chair, its gas tank and its cupboard, opening to the corridor.
func _build_rooms() -> void:
	var doors: Array = ROOM_DOORS.map(func(x: float) -> Vector3: return Vector3(x, OPENING_WIDTH, 2.4))
	_wall("x", ROOMS_Z, -HALF_X, HALF_X, doors, TILE)
	for x: float in ROOM_WALLS:
		_wall("z", x, -HALF_Z, ROOMS_Z, [], TILE)
	for i in CHAIRS.size():
		_model(CHAIR_MODEL, CHAIRS[i])
		var chair := _build.body(CHAIRS[i] + Vector3(0, 0.45, -0.3))
		_build.shape(chair, Vector3(0.7, 0.9, 1.3))
		_model(GAS_MODEL, GAS_TANKS[i])
		_build.open_box(ROOM_CUPBOARDS[i], CUPBOARD_SIZE, "z", TILE.darkened(0.05))
		_build.light(CHAIRS[i] + Vector3(0, 2.8, 0))
	_build.light(Vector3(0, 2.9, 2.0))


## The lab: the cabinet of molds against the back wall, the work table, the kiln and the X-ray light box.
func _build_lab() -> void:
	_model(CABINET_MODEL, CABINET_AT)
	var cabinet := _build.body(CABINET_AT + Vector3(0, 0.8, 0))
	_build.shape(cabinet, Vector3(1.2, 1.6, 0.4))
	_table(LAB_TABLE_AT, LAB_TABLE_SIZE, STEEL.darkened(0.2), STEEL)
	_build.open_box(KILN_AT, KILN_SIZE, "z", STEEL.darkened(0.3))
	_model(XRAY_MODEL, XRAY_AT, PI / 2)
	_build.light(Vector3(2.75, 2.9, -4.0))


## Dr. Molina's office (desk and shelf) and the locked storeroom behind it.
func _build_office() -> void:
	_wall("x", STOREROOM_Z, ROOM_WALLS[2], HALF_X, [Vector3(STOREROOM_DOOR_X, GameScale.DOOR_WIDTH, 2.4)], TILE)
	_table(DESK_AT, DESK_SIZE, WOOD.darkened(0.2), WOOD)
	_build.open_box(Vector3(SHELF_X, FLOOR_TOP, -1.2), Vector3(0.6, 1.9, 1.6), "-x", WOOD)
	_build.light(Vector3(8.25, 2.9, -1.0))
	_build.light(Vector3(8.25, 2.9, -6.0))


## The molds on the lab's table: each one that breaks counts (Dr. Molina minds it, step 3).
func _place_molds() -> void:
	for i in MOLDS:
		var mold := Ornament.new()
		mold.mass = 0.3
		mold.collision_layer = 4
		mold.collision_mask = 15
		mold.shard_color = Color(0.94, 0.9, 0.84)
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(0.14, 0.07, 0.1)
		shape.shape = box
		mold.add_child(shape)
		var look: Node3D = MOLD_MODEL.instantiate()
		look.position.y = -0.035
		mold.add_child(look)
		mold.position = LAB_TABLE_AT + Vector3(-0.9 + i * 0.36, LAB_TABLE_SIZE.y + 0.045, 0.2)
		add_child(mold)
		molds.append(mold)
		mold.broken.connect(func(at: Vector3) -> void:
			molds.erase(mold)
			broken_goods += 1
			if molina:
				molina.saw(at, SAW_MOLD, "MOLINA_MOLD"))


## Dr. Molina on his round, his patient at the bell, what he notices and the complaint bar.
func _place_molina() -> void:
	molina = MOLINA_SCENE.instantiate()
	molina.route = MOLINA_ROUTE
	molina.printer_spot = PATIENT_SPOT
	molina.printer = bell
	add_child(molina)
	molina.fix_facing = to_global(CHAIRS[0])
	molina.start_at(0)
	storeroom_door.broken.connect(molina.door_broken)
	molina.lawyer_called.connect(%CaseFailed.show)
	var hud := CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	hud.add_child(box)
	var title := Label.new()
	title.text = "HUD_COMPLAINT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	complaint_bar = ProgressBar.new()
	complaint_bar.custom_minimum_size = Vector2(320, 18)
	complaint_bar.show_percentage = false
	complaint_bar.modulate = Color(1, 0.45, 0.35)
	box.add_child(complaint_bar)
	add_child(hud)
	molina.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Which chair `at` (this scene's space) is up on, or -1.
func chair_under(at: Vector3) -> int:
	for i in CHAIRS.size():
		var from := at - CHAIRS[i]
		if absf(from.x) < SEAT.x and from.z > -SEAT.y and from.z < SEAT.y * 0.4 and from.y > SEAT_HEIGHT:
			return i
	return -1


## Every cop up on a chair that the doctor sees, once until they get down.
func _watch_chairs() -> void:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if chair_under(to_local(cop.global_position)) < 0:
			_seen_in_chair.erase(cop)
		elif not _seen_in_chair.has(cop) and molina.saw(cop.global_position + Vector3.UP * 0.8, SAW_IN_CHAIR,
				"MOLINA_CHAIR"):
			_seen_in_chair[cop] = true


## A locked door in a wall along x, its middle at `at`.
func _door(at: Vector3) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(at.x - GameScale.DOOR_WIDTH / 2, at.y - FLOOR_TOP, at.z)
	add_child(door)
	return door


## A wall from the floor up to WALL_TOP, along "x" (at z = fixed) or "z" (at x = fixed), with openings given as
## Vector3(middle, width, height).
func _wall(axis: String, fixed: float, from: float, to: float, openings: Array, color: Color) -> void:
	var start := from
	for opening: Vector3 in openings:
		var a := opening.x - opening.y / 2
		var b := opening.x + opening.y / 2
		_wall_box(axis, fixed, start, a, 0.0, WALL_TOP, color)
		_wall_box(axis, fixed, a, b, opening.z, WALL_TOP, color)
		start = b
	_wall_box(axis, fixed, start, to, 0.0, WALL_TOP, color)


func _wall_box(axis: String, fixed: float, a: float, b: float, y0: float, y1: float, color: Color) -> void:
	if b - a < 0.01 or y1 - y0 < 0.01:
		return
	var size := Vector3(b - a, y1 - y0, PlaceBuilder.WALL) if axis == "x" else Vector3(PlaceBuilder.WALL, y1 - y0, b - a)
	var mid := (a + b) / 2
	var center := Vector3(mid, (y0 + y1) / 2, fixed) if axis == "x" else Vector3(fixed, (y0 + y1) / 2, mid)
	_build.box(center, size, color)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look


## A table: four legs and a top, `size` high.
func _table(at: Vector3, size: Vector3, color: Color, top_color: Color) -> void:
	_build.legs(at, Vector2(size.x, size.z), size.y - 0.04, color)
	_build.box(at + Vector3(0, size.y - 0.02, 0), Vector3(size.x, 0.04, size.z), top_color)
