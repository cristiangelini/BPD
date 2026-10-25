class_name HardwareStore
extends Node3D

## The hardware store "El Tornillo Flojo" (docs/diseno/ferreteria.md, step 1): the shop at the front, the storeroom
## and the workshop behind it, and the materials yard at the back, on its lot in the city with the front to +Z.
## The shop is open; the storeroom ("Solo personal") and the workshop's back door to the yard are locked. The paint
## cans of the display and the screw jars on the counter break, each one a fine. Tobías serves behind the counter,
## watches what breaks and looks for a screw with his back turned when a cop rings the counter bell (step 2). The
## tools on the gondolas are for sale: what he sees in a cop's hand goes on the bill, and comes off it when it's put
## back (step 3).
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const PAINT_SCENE := preload("res://scenes/props/paint_can.tscn")
const JAR_SCENE := preload("res://scenes/props/screw_jar.tscn")
const TOBIAS_SCENE := preload("res://scenes/npc/hardware_man.tscn")
## The tools for sale, laid along the gondolas' two upper boards, both sides.
const TOOL_SCENES: Array[PackedScene] = [
	preload("res://scenes/props/tool_hammer.tscn"), preload("res://scenes/props/tool_wrench.tscn"),
	preload("res://scenes/props/tool_saw.tscn"), preload("res://scenes/props/tool_screwdriver.tscn"),
]
const TOOL_ALONG: Array[float] = [-0.7, 0.0, 0.7]
## How far from a gondola's middle the tools lie on each side of its back panel.
const TOOL_SIDE := 0.17
const TOOL_HALF_HEIGHT := 0.02
## The paint colors of the display, one model each (tools/modelgen/models/hardware.js).
const PAINT_MODELS: Array[PackedScene] = [
	preload("res://assets/models/paint_can_0.glb"), preload("res://assets/models/paint_can_1.glb"),
	preload("res://assets/models/paint_can_2.glb"), preload("res://assets/models/paint_can_3.glb"),
	preload("res://assets/models/paint_can_4.glb"), preload("res://assets/models/paint_can_5.glb"),
]
const PAINT_SHARDS: Array[Color] = [
	Color(0.91, 0.28, 0.24), Color(0.24, 0.48, 0.91), Color(0.95, 0.76, 0.19), Color(0.3, 0.72, 0.38),
	Color(0.96, 0.95, 0.92), Color(0.54, 0.3, 0.78),
]
const HALF_X := 8.0
## The lot runs from -HALF_Z to HALF_Z; the building covers its front from BACK_Z on, the yard the rest.
const HALF_Z := 7.0
const BACK_Z := -2.0
## The shop floor sits a little over the city's paved block, which runs under it; the yard's ground a little lower.
const FLOOR_TOP := 0.06
const GRASS_TOP := 0.04
## The wall between the shop and the back rooms, and the one between the storeroom (west) and the workshop.
const SPLIT_Z := 1.5
const WORKSHOP_WEST := 1.0
const ENTRANCE_X := 3.0
const STORE_DOOR_X := -5.0
const WORKSHOP_DOOR_Z := -0.25
const BACK_DOOR_X := 5.0
const FENCE_HEIGHT := 0.9
## The gap in the yard's west fence: the yard can be walked into from the side street.
const GATE_Z := -4.5
const GATE_WIDTH := 1.6
const COUNTER_AT := Vector3(-4.0, FLOOR_TOP, 3.2)
const COUNTER_SIZE := Vector3(3.0, 1.0, 0.7)
## Where Tobías stands behind his counter, facing the street (step 2).
const TOBIAS_POST := Vector3(-4.0, FLOOR_TOP, 2.4)
## The counter bell, on the customers' side of the counter top.
const BELL_AT := Vector3(-4.0, FLOOR_TOP + 1.0, 3.45)
const KEY_MACHINE_AT := Vector3(-5.1, FLOOR_TOP + COUNTER_SIZE.y, 3.2)
## The screw wall along the west wall: 60 little drawers in a cabinet, its top a hiding spot.
const SCREW_WALL_AT := Vector3(-7.7, FLOOR_TOP, 4.8)
const SCREW_WALL_SIZE := Vector3(0.45, 1.8, 3.4)
const SCREW_ROWS := 6
const SCREW_COLUMNS := 10
## The tool gondolas in the middle of the shop: center on the floor, and the heights of their boards.
const GONDOLAS: Array[Vector3] = [Vector3(0.5, FLOOR_TOP, 4.4), Vector3(5.3, FLOOR_TOP, 4.4)]
const GONDOLA_SIZE := Vector3(0.6, 1.3, 2.2)
const GONDOLA_BOARDS: Array[float] = [0.15, 0.55, 0.95]
## The paint display along the east wall: its boards (center), how long they run along z and the cans on each.
const PAINT_BOARDS: Array[Vector3] = [
	Vector3(7.65, FLOOR_TOP + 0.4, 4.6), Vector3(7.65, FLOOR_TOP + 0.85, 4.6), Vector3(7.65, FLOOR_TOP + 1.3, 4.6),
]
const PAINT_BOARD_LENGTH := 2.8
const PAINT_DEPTH := 0.5
const CANS_PER_BOARD := 6
const CAN_HALF_HEIGHT := 0.095
const JARS := 6
const JAR_HALF_HEIGHT := 0.075
const WORKBENCH_AT := Vector3(4.5, FLOOR_TOP, 0.6)
const WORKBENCH_SIZE := Vector3(2.4, 0.9, 0.7)
const CABINET_AT := Vector3(7.45, FLOOR_TOP, -1.2)
const CABINET_SIZE := Vector3(0.8, 1.8, 0.7)
const HOSE_AT := Vector3(-2.5, FLOOR_TOP, -1.35)
const NAILS_AT := Vector3(-0.3, FLOOR_TOP, -1.45)
const WHEELBARROW_AT := Vector3(-4.5, GRASS_TOP, -5.2)
const SAND_AT := Vector3(-0.8, GRASS_TOP, -5.4)
const SAND_SIZE := Vector3(1.6, 0.3, 1.6)
const BRICKS_AT := Vector3(4.0, GRASS_TOP, -5.2)

const OUTSIDE := Color(0.9, 0.45, 0.3)
const INSIDE := Color(0.93, 0.9, 0.82)
const BACK := Color(0.78, 0.78, 0.74)
const TILES := Color(0.72, 0.72, 0.7)
const YARD := Color(0.62, 0.55, 0.45)
const WOOD := Color(0.6, 0.42, 0.28)
const STEEL := Color(0.55, 0.58, 0.62)
const GLASS := Color(0.55, 0.75, 0.85, 0.35)
const RED := Color(0.82, 0.24, 0.2)
const CEMENT := Color(0.8, 0.78, 0.72)
const HOSE := Color(0.25, 0.6, 0.3)
const CARDBOARD := Color(0.7, 0.55, 0.36)
const SAND := Color(0.9, 0.8, 0.55)
const BRICK := Color(0.7, 0.33, 0.24)
const WHITE := Color(0.93, 0.93, 0.9)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "under_hw_counter", "at": COUNTER_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "on_screw_wall", "at": SCREW_WALL_AT + Vector3(0, SCREW_WALL_SIZE.y, 0), "heavy": false},
	{"id": "under_gondola", "at": GONDOLAS[0] + Vector3(0.18, GONDOLA_BOARDS[0] + 0.02, 0), "heavy": false},
	{"id": "behind_cement", "at": Vector3(-5.0, FLOOR_TOP, -1.5), "heavy": true},
	{"id": "in_hose", "at": HOSE_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "in_nail_box", "at": NAILS_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "in_metal_cabinet", "at": CABINET_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "under_workbench", "at": WORKBENCH_AT + Vector3(-0.5, 0, 0), "heavy": true},
	{"id": "on_workbench", "at": WORKBENCH_AT + Vector3(0.6, WORKBENCH_SIZE.y + 0.06, 0), "heavy": false},
	{"id": "in_wheelbarrow", "at": WHEELBARROW_AT + Vector3(0, 0.3, 0), "heavy": true},
	{"id": "in_sand", "at": SAND_AT + Vector3(0, SAND_SIZE.y, 0), "heavy": false},
	{"id": "behind_bricks", "at": BRICKS_AT + Vector3(0, 0, -1.0), "heavy": true},
]
## The spots out in the yard (the rest are inside the building).
const YARD_SPOTS: Array[String] = ["in_wheelbarrow", "in_sand", "behind_bricks"]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var store_door: FrontDoor
var back_door: FrontDoor
var city_map: CityMap
var paint_cans: Array[Ornament] = []
var jars: Array[Ornament] = []
var broken_goods := 0
## Money taken off the case pay for broken things (each one is an Ornament.FINE).
var fines := 0
var tobias: HardwareMan
## The tools for sale, and how many of them are on the bill now.
var merchandise: Array[Merchandise] = []
var bill := 0
var bell: CounterBell
var complaint_bar: ProgressBar
## Tobías called his lawyer: the case is lost.
var case_failed := false
var _build: PlaceBuilder
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_yard()
	_build_shop()
	_build_storeroom()
	_build_workshop()
	_place_fragile()
	_place_merchandise()
	store_door = _door(Vector3(STORE_DOOR_X - GameScale.DOOR_WIDTH / 2, 0, SPLIT_Z), 0.0)
	back_door = _door(Vector3(BACK_DOOR_X + GameScale.DOOR_WIDTH / 2, 0, BACK_Z), PI)
	_place_tobias()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("hardware")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "hardware", car)


func _door(at: Vector3, turn: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = at
	door.rotation.y = turn
	add_child(door)
	return door


## Floor, outer walls, the roof and the front: the entrance, two shop windows and the sign.
func _build_shell() -> void:
	var up := GameScale.FLOOR_HEIGHT
	var height := up - PlaceBuilder.SLAB
	_build.slab(-HALF_X, HALF_X, BACK_Z, HALF_Z, FLOOR_TOP, TILES)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, BACK_Z - 0.2, HALF_Z + 0.2, up, OUTSIDE.darkened(0.35))
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [BACK_DOOR_X], OUTSIDE)
	_build.wall("z", -HALF_X, BACK_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, BACK_Z, HALF_Z, 0, [], OUTSIDE)
	# Front: a shop window on each side of the entrance, over a low wall.
	_build.wall("x", HALF_Z, ENTRANCE_X - 1.0, ENTRANCE_X + 1.0, 0, [ENTRANCE_X], OUTSIDE)
	for span: Vector2 in [Vector2(-HALF_X, ENTRANCE_X - 1.0), Vector2(ENTRANCE_X + 1.0, HALF_X)]:
		var mid := (span.x + span.y) / 2
		var width := span.y - span.x
		_build.box(Vector3(mid, 0.45, HALF_Z), Vector3(width, 0.9, PlaceBuilder.WALL), OUTSIDE)
		_build.box(Vector3(mid, 2.4, HALF_Z), Vector3(width, height - 2.3, PlaceBuilder.WALL), OUTSIDE)
		_build.box(Vector3(mid, 1.6, HALF_Z), Vector3(width, 1.4, 0.04), GLASS)
	_build.mesh_box(Vector3(0, 2.4, HALF_Z + 0.8), Vector3(HALF_X * 2 - 1, 0.1, 1.5), RED)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_HARDWARE"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, up + 0.6, HALF_Z + 0.12)
	$Built.add_child(sign_label)
	_build.box(Vector3(0, up + 0.6, HALF_Z), Vector3(HALF_X * 2, 1.2, PlaceBuilder.WALL), OUTSIDE)


## The materials yard: packed earth, a low fence with a gate to the side street, the wheelbarrow, sand and bricks.
func _build_yard() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, BACK_Z, GRASS_TOP, YARD)
	var fence_y := GRASS_TOP + FENCE_HEIGHT / 2
	_build.box(Vector3(0, fence_y, -HALF_Z), Vector3(HALF_X * 2, FENCE_HEIGHT, 0.06), WHITE)
	_build.box(Vector3(HALF_X, fence_y, (BACK_Z - HALF_Z) / 2), Vector3(0.06, FENCE_HEIGHT, HALF_Z + BACK_Z), WHITE)
	# The west fence, with the gate gap.
	var gate_a := GATE_Z - GATE_WIDTH / 2
	var gate_b := GATE_Z + GATE_WIDTH / 2
	_build.box(Vector3(-HALF_X, fence_y, (-HALF_Z + gate_a) / 2), Vector3(0.06, FENCE_HEIGHT, gate_a + HALF_Z), WHITE)
	_build.box(Vector3(-HALF_X, fence_y, (gate_b + BACK_Z) / 2), Vector3(0.06, FENCE_HEIGHT, BACK_Z - gate_b), WHITE)
	_build.open_box(WHEELBARROW_AT + Vector3(0, 0.25, 0), Vector3(0.7, 0.4, 1.1), "top", RED)
	_build.box(WHEELBARROW_AT + Vector3(0, 0.12, 0.65), Vector3(0.1, 0.24, 0.24), STEEL)
	_build.box(SAND_AT + Vector3(0, SAND_SIZE.y / 2, 0), SAND_SIZE, SAND)
	for level in 3:
		_build.box(BRICKS_AT + Vector3(0, 0.15 + level * 0.3, 0), Vector3(1.6, 0.3, 0.9), BRICK)
	for i in 3:
		_build.box(Vector3(6.2, GRASS_TOP + 0.08 + i * 0.16, -5.6), Vector3(0.16, 0.16, 2.4), STEEL)
	_build.light(Vector3(0, 2.6, -4.5))


## The shop: the counter with the till and the key copying machine, the screw wall, two tool gondolas, the paint
## display and the board of blank keys behind the counter.
func _build_shop() -> void:
	_build.wall("x", SPLIT_Z, -HALF_X, HALF_X, 0, [STORE_DOOR_X], INSIDE)
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", WOOD)
	_build.box(COUNTER_AT + Vector3(1.0, COUNTER_SIZE.y + 0.15, 0), Vector3(0.5, 0.3, 0.4), STEEL)
	_build.box(KEY_MACHINE_AT + Vector3(0, 0.15, 0), Vector3(0.5, 0.3, 0.35), RED)
	_build.mesh_box(KEY_MACHINE_AT + Vector3(0, 0.34, 0), Vector3(0.12, 0.08, 0.12), STEEL)
	# The board of blank keys on the wall behind the counter.
	_build.mesh_box(Vector3(-2.0, 1.6, SPLIT_Z + 0.09), Vector3(1.6, 0.8, 0.03), WOOD)
	for row in 4:
		for column in 10:
			_build.mesh_box(Vector3(-2.7 + column * 0.155, 1.33 + row * 0.18, SPLIT_Z + 0.12), Vector3(0.03, 0.08, 0.01),
				Color(0.85, 0.72, 0.3))
	# The screw wall: one cabinet, with its little drawer fronts only for the look.
	_build.box(SCREW_WALL_AT + Vector3(0, SCREW_WALL_SIZE.y / 2, 0), SCREW_WALL_SIZE, WOOD)
	var step := Vector2(SCREW_WALL_SIZE.z / SCREW_COLUMNS, SCREW_WALL_SIZE.y / SCREW_ROWS)
	for row in SCREW_ROWS:
		for column in SCREW_COLUMNS:
			var front := Vector3(SCREW_WALL_AT.x + SCREW_WALL_SIZE.x / 2 + 0.01, FLOOR_TOP + (row + 0.5) * step.y,
				SCREW_WALL_AT.z - SCREW_WALL_SIZE.z / 2 + (column + 0.5) * step.x)
			_build.mesh_box(front, Vector3(0.02, step.y - 0.05, step.x - 0.05), CARDBOARD.lightened(0.2))
	for at: Vector3 in GONDOLAS:
		_build.box(at + Vector3(0, GONDOLA_SIZE.y / 2, 0), Vector3(0.06, GONDOLA_SIZE.y, GONDOLA_SIZE.z), STEEL)
		for y: float in GONDOLA_BOARDS:
			_build.box(at + Vector3(0, y, 0), Vector3(GONDOLA_SIZE.x, 0.04, GONDOLA_SIZE.z), STEEL.lightened(0.2))
	for board: Vector3 in PAINT_BOARDS:
		_build.box(board, Vector3(PAINT_DEPTH, 0.04, PAINT_BOARD_LENGTH), WOOD)
	_build.light(Vector3(-3.0, 2.2, 4.5))
	_build.light(Vector3(4.0, 2.2, 4.5))


## The storeroom: cement sacks, hose rolls, nail boxes and a ladder against the wall.
func _build_storeroom() -> void:
	_build.wall("z", WORKSHOP_WEST, BACK_Z, SPLIT_Z, 0, [WORKSHOP_DOOR_Z], BACK)
	for x: float in [-6.9, -6.25]:
		for level in 3:
			_build.box(Vector3(x, FLOOR_TOP + 0.12 + level * 0.24, -1.4), Vector3(0.6, 0.24, 0.9), CEMENT)
	_build.open_box(HOSE_AT, Vector3(0.7, 0.5, 0.7), "top", HOSE)
	_build.open_box(NAILS_AT, Vector3(0.6, 0.4, 0.5), "top", CARDBOARD)
	for y: float in [0.2, 0.6]:
		_build.box(Vector3(-3.8, FLOOR_TOP + y, -1.6), Vector3(0.6, 0.4, 0.5), CARDBOARD)
	_build.mesh_box(Vector3(-7.85, 1.2, 0.3), Vector3(0.05, 2.2, 0.5), WOOD.lightened(0.3))
	_build.light(Vector3(-3.5, 2.2, -0.2))


## The workshop: the workbench with its vise, the grinder and the metal cabinet.
func _build_workshop() -> void:
	_build.legs(WORKBENCH_AT, Vector2(WORKBENCH_SIZE.x, WORKBENCH_SIZE.z), WORKBENCH_SIZE.y, WOOD)
	_build.box(WORKBENCH_AT + Vector3(0, WORKBENCH_SIZE.y + 0.03, 0), Vector3(WORKBENCH_SIZE.x, 0.06, WORKBENCH_SIZE.z), WOOD)
	_build.mesh_box(WORKBENCH_AT + Vector3(-0.9, WORKBENCH_SIZE.y + 0.14, 0.2), Vector3(0.2, 0.16, 0.14), STEEL)
	_build.mesh_box(WORKBENCH_AT + Vector3(0.0, WORKBENCH_SIZE.y + 0.12, -0.2), Vector3(0.3, 0.14, 0.18), RED)
	_build.open_box(CABINET_AT, CABINET_SIZE, "-x", STEEL)
	_build.box(Vector3(CABINET_AT.x, CABINET_AT.y + 0.9, CABINET_AT.z), Vector3(CABINET_SIZE.x - 0.1, 0.04, CABINET_SIZE.z - 0.1), STEEL)
	_build.light(Vector3(4.5, 2.2, -0.2))


## The paint cans on the display and the screw jars on the counter: each one that breaks is a fine.
func _place_fragile() -> void:
	for b in PAINT_BOARDS.size():
		var board := PAINT_BOARDS[b]
		for i in CANS_PER_BOARD:
			var offset := (i - (CANS_PER_BOARD - 1) / 2.0) * (PAINT_BOARD_LENGTH - 0.3) / (CANS_PER_BOARD - 1)
			var color := (b * 2 + i) % PAINT_MODELS.size()
			var can: Ornament = PAINT_SCENE.instantiate()
			can.get_node("Model").free()
			var look: Node3D = PAINT_MODELS[color].instantiate()
			look.name = "Model"
			can.add_child(look)
			can.shard_color = PAINT_SHARDS[color]
			can.position = board + Vector3(0, 0.02 + CAN_HALF_HEIGHT + 0.005, offset)
			add_child(can)
			can.broken.connect(_on_fragile_broken)
			paint_cans.append(can)
	for i in JARS:
		var jar: Ornament = JAR_SCENE.instantiate()
		var along := -0.6 + i * 0.13 if i < 3 else 0.2 + (i - 3) * 0.13
		jar.position = COUNTER_AT + Vector3(along, COUNTER_SIZE.y + JAR_HALF_HEIGHT + 0.005, 0.15)
		add_child(jar)
		jar.broken.connect(_on_fragile_broken)
		jars.append(jar)


## Tobías behind his counter, the bell that sends him to the screw wall and his complaint meter. A rammed door
## reaches him anywhere.
func _place_tobias() -> void:
	tobias = TOBIAS_SCENE.instantiate()
	tobias.position = TOBIAS_POST
	tobias.screw_wall = SCREW_WALL_AT + Vector3(0, 1.0, 0)
	add_child(tobias)
	bell = CounterBell.new()
	bell.position = BELL_AT
	bell.hardware_man = tobias
	add_child(bell)
	for door: FrontDoor in [store_door, back_door]:
		door.broken.connect(tobias.door_broken)
	tobias.lawyer_called.connect(_on_lawyer_called)
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
	tobias.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## The tools on the gondolas' two upper boards, both sides of the back panel, turned to lie along the board.
func _place_merchandise() -> void:
	var kind := 0
	for gondola: Vector3 in GONDOLAS:
		for board: float in GONDOLA_BOARDS.slice(1):
			for side: float in [-TOOL_SIDE, TOOL_SIDE]:
				for along: float in TOOL_ALONG:
					var item: Merchandise = TOOL_SCENES[kind % TOOL_SCENES.size()].instantiate()
					kind += 1
					item.position = gondola + Vector3(side, board + 0.02 + TOOL_HALF_HEIGHT + 0.01, along)
					item.rotation.y = PI / 2
					add_child(item)
					item.home = item.position
					merchandise.append(item)


## The bill: a tool Tobías sees in a hand for long enough goes on it (as much off the pay as its price), and comes
## off when it lies near its place again.
func _physics_process(delta: float) -> void:
	if not tobias:
		return
	for item: Merchandise in merchandise:
		if not item.is_in_hand():
			item.seen = 0.0
			if item.charged and item.is_home():
				item.charged = false
				bill -= 1
				fines -= Merchandise.PRICE
				tobias.took_back()
			continue
		if item.charged or not tobias.can_see(item.global_position):
			continue
		item.seen += delta
		if item.seen >= Merchandise.SEEN_TO_CHARGE:
			item.charged = true
			bill += 1
			fines += Merchandise.PRICE
			tobias.charged()


func _on_lawyer_called() -> void:
	case_failed = true
	%CaseFailed.show()


func _on_fragile_broken(at: Vector3) -> void:
	broken_goods += 1
	fines += Ornament.FINE
	if tobias:
		tobias.saw(at, HardwareMan.SAW_BREAK)
