class_name PrisonLevel
extends Node3D

## The city's prison (carcel-motin.md, step 1, decision 104): a walled lot on block (5, 2), the front to +Z, where the
## ten prison cases happen. The gate in the perimeter wall stands open on the yard (a basketball hoop, the watchtower
## in the corner); across the yard, the building: the canteen first, with its six long tables, the serving counter with
## the pots of mash and the trays of jelly, the kitchen behind its door (where the guards hid from the riot) and the
## punishment cell in the west corner. Behind the canteen, through a locked barred gate, the cell block, shut until a
## case needs it. The cops start in the station and drive here; --place=prison opens it from Play. Step 2: the riot
## (PrisonRiot), with the inmates at the tables, starts when the first cop walks through the gate. Step 3: the tables
## knock over to hide behind (CanteenTable) and the trays by the counter are shields (PrisonTray).
## Every number here is (propuesta).

const POT_MODEL := preload("res://assets/models/prison_food_pot.glb")
const JELLY_MODEL := preload("res://assets/models/prison_jelly_tray.glb")
## The lot (CityLayout "prison") and its perimeter wall, with the gate's gap in the front wall.
const HALF_X := 14.0
const HALF_Z := 20.0
const FENCE_HEIGHT := 4.5
const FENCE_THICK := 0.4
const GATE_HALF := 2.5
const FLOOR_TOP := 0.06
## The building: two floors tall inside, its front on the yard with two doors.
const BUILDING_X := 12.0
const BUILDING_FRONT := 8.0
const BUILDING_BACK := -19.0
const ROOF := GameScale.FLOOR_HEIGHT * 2
const ENTRANCES: Array[float] = [-2.0, 2.0]
## The canteen and the kitchen east of it, split by KITCHEN_X with the kitchen's door; the cell block behind CELLS_Z.
const KITCHEN_X := 6.0
const KITCHEN_DOOR_Z := -5.5
const CELLS_Z := -7.0
## The serving counter along the kitchen's wall, with room to walk behind it.
const COUNTER_X := 4.4
const COUNTER_FROM := -5.0
const COUNTER_TO := 5.0
const COUNTER_SIZE := Vector2(0.8, 1.0)
## The stack of trays on a little table past the counter's north end (step 3).
const TRAY_RACK := Vector3(COUNTER_X, FLOOR_TOP, 6.6)
const TRAYS := 8
## The six tables: two columns of three, long along X.
const TABLE_XS: Array[float] = [-8.0, -2.0]
const TABLE_ZS: Array[float] = [4.5, 0.5, -3.5]
## The punishment cell in the canteen's west corner, its barred door on its north side (hinge at its west end).
const PUNISHMENT := Rect2(-BUILDING_X, CELLS_Z, 2.0, 3.0)
const PUNISHMENT_DOOR_X := -11.6
## The cell block's gate (hinge at its west end) and its corridor, with CELLS cells on each side.
const BLOCK_GATE_X := -1.6
const CORRIDOR := Vector2(-2.5, 0.5)
const CELL_DEPTH := 3.5
const CELLS := 4
## The watchtower in the yard's west corner and the basketball hoop.
const TOWER_AT := Vector3(-12.0, 0, 18.0)
const TOWER_HEIGHT := 6.0
const HOOP_AT := Vector3(-11.0, 0, 13.0)

const WALL := Color(0.62, 0.6, 0.55)
const INSIDE := Color(0.8, 0.82, 0.74)
const TILE := Color(0.78, 0.72, 0.6)
const YARD := Color(0.45, 0.46, 0.45)
const LINE := Color(0.9, 0.85, 0.3)
const STEEL := Color(0.55, 0.58, 0.62)
const BARS := Color(0.25, 0.27, 0.3)
const ORANGE := Color(0.85, 0.45, 0.2)
const WOOD := Color(0.45, 0.3, 0.18)

## The case's seed: who the inmates are and where they sit (step 2 on).
var case_seed := 0
var kitchen_door: FrontDoor
var punishment_door: CellDoor
var block_gate: CellDoor
var tables: Array[CanteenTable] = []
var trays: Array[PrisonTray] = []
var riot: PrisonRiot
## The case on top of the riot (step 5): the comisario's briefing, the planilla and the end of the shift.
var case: PrisonCase
var _build: PlaceBuilder

## Which prison case this is: "riot" (the canteen, carcel-motin.md) or "transfer" (the bus from the station,
## traslado-presos.md; --place=transfer).
@export var variant := "riot"
## The transfer's bus (traslado-presos.md, step 1), parked by the station's door, and its inmates (step 2).
var bus: PrisonBus
var transfer: TransferPlan

@onready var car: PatrolCar = get_node_or_null("PatrolCar")
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_fence()
	_build_yard()
	_build_shell()
	_build_canteen()
	_build_cells()
	if variant == "transfer":
		_start_transfer()
		return
	riot = PrisonRiot.new()
	riot.name = "Riot"
	add_child(riot)
	riot.setup(self, case_seed)
	city.transform = CityLayout.anchor("prison")
	car.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	case = PrisonCase.new()
	case.name = "Case"
	case.prison = self
	case.shift_screen = $ShiftScreen
	add_child(case)
	case.start(city.get("comisario"))


## The transfer starts at the station: the bus waits on the street by its door, turned so its doors face the
## sidewalk, and the cops in the guard room.
func _start_transfer() -> void:
	city.transform = CityLayout.anchor("prison")
	bus = $Bus
	bus.global_transform = (city.transform * CityLayout.parking("station")).rotated_local(Vector3.UP, PI) \
		.translated_local(Vector3.UP * 0.05)
	transfer = TransferPlan.new()
	transfer.name = "Transfer"
	add_child(transfer)
	transfer.setup(bus, case_seed)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)


## Whether a world position is inside the perimeter wall.
func inside_walls(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z


## Whether a world position is inside the canteen (step 2 on: where the riot is).
func in_canteen(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > -BUILDING_X and local.x < KITCHEN_X and local.z > CELLS_Z and local.z < BUILDING_FRONT


## The perimeter wall all around the lot with barbed wire on top, the gate's two barred leaves swung open against it
## on the yard's side, and the sign over the gap.
func _build_fence() -> void:
	var y := FENCE_HEIGHT / 2
	_build.box(Vector3(0, y, -HALF_Z), Vector3(HALF_X * 2, FENCE_HEIGHT, FENCE_THICK), WALL)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * HALF_X, y, 0), Vector3(FENCE_THICK, FENCE_HEIGHT, HALF_Z * 2), WALL)
		var piece := HALF_X - GATE_HALF
		_build.box(Vector3(side * (GATE_HALF + piece / 2), y, HALF_Z), Vector3(piece, FENCE_HEIGHT, FENCE_THICK), WALL)
		_bars("z", side * (GATE_HALF - 0.1), HALF_Z - 0.3 - GATE_HALF, HALF_Z - 0.3, 3.2)
	for z: float in [-HALF_Z, HALF_Z]:
		_build.mesh_box(Vector3(0, FENCE_HEIGHT + 0.15, z), Vector3(HALF_X * 2, 0.08, 0.08), BARS)
	for x: float in [-HALF_X, HALF_X]:
		_build.mesh_box(Vector3(x, FENCE_HEIGHT + 0.15, 0), Vector3(0.08, 0.08, HALF_Z * 2), BARS)
	_build.mesh_box(Vector3(0, FENCE_HEIGHT - 0.2, HALF_Z), Vector3(GATE_HALF * 2, 0.4, FENCE_THICK), WALL.darkened(0.2))
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_PRISON"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, FENCE_HEIGHT + 0.5, HALF_Z + 0.25)
	$Built.add_child(sign_label)


## The yard's floor with its painted lines, the hoop and the watchtower on four legs with its hut and floodlight.
func _build_yard() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, YARD)
	for x: float in [-5.0, 5.0]:
		_build.mesh_box(Vector3(x, FLOOR_TOP + 0.005, (BUILDING_FRONT + HALF_Z) / 2), Vector3(0.12, 0.01, 10.0), LINE)
	_build.box(HOOP_AT + Vector3(0, 1.6, 0), Vector3(0.12, 3.2, 0.12), STEEL)
	_build.mesh_box(HOOP_AT + Vector3(0.25, 3.0, 0), Vector3(0.05, 0.9, 1.2), INSIDE)
	var ring := TorusMesh.new()
	ring.inner_radius = 0.2
	ring.outer_radius = 0.23
	_build.mesh(ring, HOOP_AT + Vector3(0.55, 2.75, 0), ORANGE)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			_build.box(TOWER_AT + Vector3(sx, TOWER_HEIGHT / 2, sz), Vector3(0.15, TOWER_HEIGHT, 0.15), WOOD)
	_build.mesh_box(TOWER_AT + Vector3(0, TOWER_HEIGHT, 0), Vector3(2.6, 0.15, 2.6), WOOD)
	_build.mesh_box(TOWER_AT + Vector3(0, TOWER_HEIGHT + 0.6, 0), Vector3(2.2, 1.0, 2.2), INSIDE)
	_build.mesh_box(TOWER_AT + Vector3(0, TOWER_HEIGHT + 1.3, 0), Vector3(2.8, 0.15, 2.8), WOOD.darkened(0.3))
	_build.mesh_box(TOWER_AT + Vector3(0.9, TOWER_HEIGHT + 1.6, 0.9), Vector3(0.4, 0.3, 0.4), LINE)


## Floor, outer walls two floors tall with the two front doors, the roof, the inner walls and the lights.
func _build_shell() -> void:
	_build.slab(-BUILDING_X, BUILDING_X, BUILDING_BACK, BUILDING_FRONT, FLOOR_TOP + 0.02, TILE)
	_build.slab(-BUILDING_X - 0.2, BUILDING_X + 0.2, BUILDING_BACK - 0.2, BUILDING_FRONT + 0.2, ROOF, WALL.darkened(0.4))
	_build.wall("x", BUILDING_FRONT, -BUILDING_X, BUILDING_X, 0, ENTRANCES, WALL)
	_build.wall("x", BUILDING_BACK, -BUILDING_X, BUILDING_X, 0, [], WALL)
	_build.wall("z", -BUILDING_X, BUILDING_BACK, BUILDING_FRONT, 0, [], WALL)
	_build.wall("z", BUILDING_X, BUILDING_BACK, BUILDING_FRONT, 0, [], WALL)
	_build.wall("z", KITCHEN_X, CELLS_Z, BUILDING_FRONT, 0, [KITCHEN_DOOR_Z], INSIDE)
	_build.wall("x", CELLS_Z, KITCHEN_X, BUILDING_X, 0, [], INSIDE)
	_upper("x", BUILDING_FRONT, -BUILDING_X, BUILDING_X, WALL)
	_upper("x", BUILDING_BACK, -BUILDING_X, BUILDING_X, WALL)
	_upper("z", -BUILDING_X, BUILDING_BACK, BUILDING_FRONT, WALL)
	_upper("z", BUILDING_X, BUILDING_BACK, BUILDING_FRONT, WALL)
	_upper("z", KITCHEN_X, CELLS_Z, BUILDING_FRONT, INSIDE)
	_upper("x", CELLS_Z, -BUILDING_X, BUILDING_X, INSIDE)
	for x: float in [-9.0, -3.0, 3.0, 9.0]:
		for z: float in [5.0, -1.5, -10.0, -16.0]:
			var lamp := OmniLight3D.new()
			lamp.position = Vector3(x, ROOF - 1.0, z)
			lamp.light_color = Color(1.0, 0.92, 0.78)
			lamp.light_energy = 1.4
			lamp.omni_range = 9.0
			$Built.add_child(lamp)
	kitchen_door = preload("res://scenes/props/front_door.tscn").instantiate()
	kitchen_door.name = "KitchenDoor"
	kitchen_door.position = Vector3(KITCHEN_X, FLOOR_TOP, KITCHEN_DOOR_Z + GameScale.DOOR_WIDTH / 2)
	kitchen_door.rotation.y = PI / 2
	add_child(kitchen_door)


## The six tables, the counter with the food on it, the stack of trays at its end and the punishment cell.
func _build_canteen() -> void:
	for x in TABLE_XS:
		for z in TABLE_ZS:
			_table(Vector3(x, FLOOR_TOP, z))
	var length := COUNTER_TO - COUNTER_FROM
	var middle := Vector3(COUNTER_X, FLOOR_TOP, (COUNTER_FROM + COUNTER_TO) / 2)
	_build.box(middle + Vector3(0, COUNTER_SIZE.y / 2, 0), Vector3(COUNTER_SIZE.x, COUNTER_SIZE.y, length), STEEL)
	var top := middle + Vector3(0, COUNTER_SIZE.y, 0)
	for i in 4:
		var z := COUNTER_FROM + 1.2 + i * (length - 2.4) / 3
		var food: Node3D = (POT_MODEL if i % 2 == 0 else JELLY_MODEL).instantiate()
		food.position = Vector3(top.x, top.y, z)
		$Built.add_child(food)
	_build.legs(TRAY_RACK, Vector2(0.8, 0.6), 0.8, STEEL)
	_build.box(TRAY_RACK + Vector3(0, 0.82, 0), Vector3(0.8, 0.04, 0.6), STEEL)
	for i in TRAYS:
		var tray := PrisonTray.new()
		tray.name = "Tray%d" % i
		tray.position = TRAY_RACK + Vector3(0, 0.86 + i * 0.035, 0)
		add_child(tray)
		trays.append(tray)
	var cell := PUNISHMENT
	_build.wall("z", cell.end.x, cell.position.y, cell.end.y, 0, [], INSIDE)
	_build.wall("x", cell.end.y, cell.position.x, PUNISHMENT_DOOR_X, 0, [], INSIDE)
	_build.wall("x", cell.end.y, PUNISHMENT_DOOR_X + CellDoor.WIDTH, cell.end.x, 0, [], INSIDE)
	_build.box(Vector3(cell.position.x + 0.45, FLOOR_TOP + 0.25, cell.position.y + 1.0), Vector3(0.8, 0.5, 1.8), ORANGE)
	punishment_door = CellDoor.new()
	punishment_door.name = "PunishmentDoor"
	punishment_door.position = Vector3(PUNISHMENT_DOOR_X, FLOOR_TOP, cell.end.y)
	add_child(punishment_door)


## The cell block behind the canteen: the barred wall with its locked gate, the corridor and the cells on each side,
## each behind bars with a bunk.
func _build_cells() -> void:
	_build.wall("x", CELLS_Z, -BUILDING_X, CORRIDOR.x, 0, [], INSIDE)
	_build.wall("x", CELLS_Z, CORRIDOR.y, KITCHEN_X, 0, [], INSIDE)
	_bars("x", CELLS_Z, CORRIDOR.x, BLOCK_GATE_X, GameScale.DOOR_HEIGHT)
	_bars("x", CELLS_Z, BLOCK_GATE_X + CellDoor.WIDTH, CORRIDOR.y, GameScale.DOOR_HEIGHT)
	block_gate = CellDoor.new()
	block_gate.name = "BlockGate"
	block_gate.locked = true
	block_gate.position = Vector3(BLOCK_GATE_X, FLOOR_TOP, CELLS_Z)
	add_child(block_gate)
	var cell_z := (BUILDING_BACK - CELLS_Z) / CELLS
	for side: float in [-1.0, 1.0]:
		var front := CORRIDOR.x if side < 0 else CORRIDOR.y
		var back := front + side * CELL_DEPTH
		_build.wall("z", back, BUILDING_BACK, CELLS_Z, 0, [], INSIDE)
		_bars("z", front, BUILDING_BACK, CELLS_Z, GameScale.DOOR_HEIGHT)
		for i in CELLS:
			var z0 := CELLS_Z + i * cell_z
			if i > 0:
				_build.wall("x", z0, minf(front, back), maxf(front, back), 0, [], INSIDE)
			_build.box(Vector3(back - side * 0.45, FLOOR_TOP + 0.25, z0 + cell_z / 2), Vector3(0.8, 0.5, 1.9), ORANGE)


## A wall above the first floor's (PlaceBuilder.wall), up to the roof: the building is two floors tall inside.
func _upper(axis: String, fixed: float, from: float, to: float, color: Color) -> void:
	var y0 := GameScale.FLOOR_HEIGHT - PlaceBuilder.SLAB
	var middle := (from + to) / 2
	var height := ROOF - y0
	if axis == "x":
		_build.box(Vector3(middle, y0 + height / 2, fixed), Vector3(to - from, height, PlaceBuilder.WALL), color)
	else:
		_build.box(Vector3(fixed, y0 + height / 2, middle), Vector3(PlaceBuilder.WALL, height, to - from), color)


## A canteen table with its benches, which knocks over (CanteenTable).
func _table(at: Vector3) -> void:
	var table := CanteenTable.new()
	table.name = "Table%d" % tables.size()
	table.position = at
	add_child(table)
	tables.append(table)


## A row of bars along "x" (at z = fixed) or "z" (at x = fixed), `height` tall, solid to walk into.
func _bars(axis: String, fixed: float, from: float, to: float, height: float) -> void:
	var length := to - from
	var middle := (from + to) / 2
	var center := Vector3(middle, FLOOR_TOP + height / 2, fixed) if axis == "x" else Vector3(fixed, FLOOR_TOP + height / 2, middle)
	_build.shape(_build.body(center), Vector3(length, height, 0.1) if axis == "x" else Vector3(0.1, height, length))
	var count := int(length / CellDoor.BAR_EVERY)
	for i in count + 1:
		var along := from + i * length / maxf(count, 1)
		var at := Vector3(along, FLOOR_TOP + height / 2, fixed) if axis == "x" else Vector3(fixed, FLOOR_TOP + height / 2, along)
		_build.mesh_box(at, Vector3(0.05, height, 0.05), BARS)
	for y: float in [0.1, height - 0.05]:
		var rail := Vector3(middle, FLOOR_TOP + y, fixed) if axis == "x" else Vector3(fixed, FLOOR_TOP + y, middle)
		_build.mesh_box(rail, Vector3(length, 0.06, 0.06) if axis == "x" else Vector3(0.06, 0.06, length), BARS)
