class_name PrintingPress
extends Node3D

## The print shop's rotativa (docs/diseno/allanamiento-imprenta.md, step 2). Every EVERY seconds, or when someone pulls
## its red lever, it runs RUN_TIME seconds: the belt of its infeed table carries whatever lies on it toward the rollers
## at SPEED (cops too, but the railing across the belt stops them at chest height before the rollers). Anything up to
## PRINT_MASS kg goes through the rollers and comes out on the output tray "printed": an ink stain of the run's color
## and the shop's stamp. Anything heavier jams the press JAM_TIME seconds and is spat back onto the belt, and that run
## is over. While it runs it throws SHEETS_PER_SECOND sheets of paper into the air, which glide down over the shop
## (they weigh nothing and push nothing). Every number here is (propuesta).

signal started(cop: Cop)
signal finished
signal printed(body: RigidBody3D, ink: int)
signal jammed(body: RigidBody3D)

const EVERY := 45.0
const RUN_TIME := 12.0
const SPEED := 1.5
const PRINT_MASS := 10.0
const JAM_TIME := 5.0
const SHEETS_PER_SECOND := 2.0
const SHEET_LIFE := 6.0
const MAX_SHEETS := 30
## The inks, in the order of the barrels: blue, red, yellow and black. Each run prints with the next one.
const INKS: Array[Color] = [Color(0.18, 0.37, 0.85), Color(0.85, 0.23, 0.23), Color(0.95, 0.78, 0.23),
	Color(0.12, 0.12, 0.14)]
## The railing across the belt: a bar this high over the belt's top, low enough for a cop and high enough for things.
const RAIL_LOW := 0.45
const RAIL_HIGH := 0.7

var running := false
var run_left := 0.0
var wait_left := EVERY
var jam_left := 0.0
## How many runs it has made (the ink is the next one each time).
var runs := 0
## Everything it has printed, and the sheets in the air: {"node": MeshInstance3D, "velocity": Vector3, "age": float}.
var printed_things: Array[RigidBody3D] = []
var sheets: Array[Dictionary] = []
## What the sheets look like (a story can make them bills).
var sheet_color := Color(0.97, 0.96, 0.92)
var sheet_size := Vector3(0.21, 0.004, 0.3)
var belt: StaticBody3D
var lever: PushButton
var _belt_x := Vector2.ZERO
var _belt_top := 0.0
var _half_z := 0.0
var _tray_x := Vector2.ZERO
var _tray_top := 0.0
var _rollers: Area3D
var _riders: Area3D
var _sheet_left := 0.0
var _rng := RandomNumberGenerator.new()


## Builds the moving belt from belt_x.x to belt_x.y (its top at belt_top), the railing, the rollers' mouth and the
## lever on the housing's +Z side at `lever_at`; what comes out lands on the tray from tray_x.x to tray_x.y.
func build(belt_x: Vector2, belt_top: float, half_z: float, tray_x: Vector2, tray_top: float, lever_at: Vector3,
		case_seed: int) -> void:
	_belt_x = belt_x
	_belt_top = belt_top
	_half_z = half_z
	_tray_x = tray_x
	_tray_top = tray_top
	_rng.seed = case_seed
	var build := PlaceBuilder.new(self)
	belt = build.body(Vector3((belt_x.x + belt_x.y) / 2, belt_top - 0.05, 0))
	belt.name = "Belt"
	build.shape(belt, Vector3(belt_x.y - belt_x.x, 0.1, half_z * 2))
	var rail_x := belt_x.y - 0.4
	build.box(Vector3(rail_x, belt_top + (RAIL_LOW + RAIL_HIGH) / 2, 0), Vector3(0.06, RAIL_HIGH - RAIL_LOW,
		half_z * 2), Color(0.95, 0.8, 0.2))
	for z: float in [-half_z, half_z]:
		build.box(Vector3(rail_x, belt_top + RAIL_HIGH / 2, z), Vector3(0.06, RAIL_HIGH, 0.06), Color(0.95, 0.8, 0.2))
	_rollers = _area("Rollers", Vector3(belt_x.y - 0.15, belt_top + 0.35, 0), Vector3(0.3, 0.7, half_z * 2))
	_riders = _area("Riders", Vector3((belt_x.x + belt_x.y) / 2, belt_top + 0.3, 0),
		Vector3(belt_x.y - belt_x.x, 0.6, half_z * 2))
	lever = PushButton.new()
	lever.name = "Lever"
	lever.prompt = "PROMPT_PRESS_LEVER"
	lever.position = lever_at
	add_child(lever)
	lever.pressed.connect(func(cop: Cop) -> void: start(cop))
	_apply()


func is_moving() -> bool:
	return running and jam_left <= 0.0


## Starts a run now (the lever, or the clock). Not while it runs or is jammed.
func start(cop: Cop = null) -> void:
	if running or jam_left > 0.0:
		return
	running = true
	run_left = RUN_TIME
	runs += 1
	_sheet_left = 0.0
	_apply()
	started.emit(cop)


## Ends the run; the clock starts counting for the next one.
func stop() -> void:
	if not running:
		return
	running = false
	wait_left = EVERY
	_apply()
	finished.emit()


## The run's ink color, by index in INKS.
func ink() -> int:
	return (runs - 1) % INKS.size() if runs > 0 else 0


## Online the host's clock starts and ends the runs and its rollers print or jam; the guests take that from it
## (net_state) and only move their belt and throw their sheets.
func _physics_process(delta: float) -> void:
	var host := multiplayer.is_server()
	if jam_left > 0.0:
		jam_left -= delta
		if jam_left <= 0.0:
			wait_left = EVERY
		return
	if not running:
		wait_left -= delta
		if wait_left <= 0.0 and host:
			start()
		return
	run_left -= delta
	for body: Node3D in _rollers.get_overlapping_bodies() if host else []:
		if body is RigidBody3D and not (body as RigidBody3D).freeze:
			_through(body)
			if not running:
				return
	_sheet_left -= delta
	if _sheet_left <= 0.0:
		_sheet_left += 1.0 / SHEETS_PER_SECOND
		_throw_sheet()
	if run_left <= 0.0 and host:
		stop()


## Online, what the guests' press takes from the host's: whether it runs or is jammed, its clocks, its runs (the ink)
## and what it printed, by path from here, with the ink of each.
func net_state() -> Array:
	var stamped: Array = []
	for body: RigidBody3D in printed_things:
		if is_instance_valid(body):
			stamped.append([get_path_to(body), body.get_meta("press_ink", 0)])
	return [running, run_left, jam_left, wait_left, runs, stamped]


func apply_net_state(state: Array) -> void:
	jam_left = state[2]
	if state[0] and not running:
		jam_left = 0.0
		runs = state[4] - 1
		start()
	elif not state[0] and running:
		running = false
		_apply()
		finished.emit()
	jam_left = state[2]
	runs = state[4]
	run_left = state[1]
	wait_left = state[3]
	for entry: Array in state[5]:
		var body := get_node_or_null(entry[0] as NodePath) as RigidBody3D
		if body and body.get_meta("press_ink", -1) != entry[1]:
			stamp(body, entry[1])


func _process(delta: float) -> void:
	for sheet: Dictionary in sheets.duplicate():
		sheet.age += delta
		var node: MeshInstance3D = sheet.node
		if sheet.age > SHEET_LIFE or not is_instance_valid(node):
			sheets.erase(sheet)
			if is_instance_valid(node):
				node.queue_free()
			continue
		var velocity: Vector3 = sheet.velocity
		velocity.y = maxf(velocity.y - 4.0 * delta, -0.6)
		velocity.x *= 1.0 - 0.5 * delta
		velocity.z *= 1.0 - 0.5 * delta
		sheet.velocity = velocity
		node.position += velocity * delta
		node.position.y = maxf(node.position.y, 0.08)
		node.rotation += Vector3(1.3, 0.7, 0.9) * delta * (0.0 if node.position.y <= 0.08 else 1.0)


## A thing reached the rollers: the light ones come out printed on the tray, the heavy ones jam the press.
func _through(body: RigidBody3D) -> void:
	if body.mass > PRINT_MASS:
		jam_left = JAM_TIME
		running = false
		_apply()
		body.global_position = to_global(Vector3(_belt_x.y - 1.2, _belt_top + 0.4, to_local(body.global_position).z))
		body.linear_velocity = Vector3(-1.0, 1.0, 0)
		jammed.emit(body)
		return
	var z := clampf(to_local(body.global_position).z, -_half_z + 0.3, _half_z - 0.3)
	body.global_position = to_global(Vector3(_tray_x.x + 0.4, _tray_top + 0.35, z))
	body.linear_velocity = Vector3(SPEED, 0, 0)
	stamp(body, ink())
	printed.emit(body, ink())


## Leaves the press's mark on a thing: an ink stain of INKS[`index`] and the "LA TINTA LOCA" stamp (the stamp once).
func stamp(body: RigidBody3D, index: int) -> void:
	var stain := StandardMaterial3D.new()
	stain.albedo_color = Color(INKS[index], 0.6)
	stain.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for mesh: Node in body.find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_overlay = stain
	body.set_meta("press_ink", index)
	if not printed_things.has(body):
		printed_things.append(body)
	if body.has_node("PressStamp"):
		return
	var label := Label3D.new()
	label.name = "PressStamp"
	label.text = "PRINT_SHOP_STAMP"
	label.font_size = 28
	label.pixel_size = 0.004
	label.outline_size = 6
	label.modulate = Color(0.85, 0.15, 0.2)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0.3, 0)
	body.add_child(label)


## A sheet of paper flies up from the output tray and glides down somewhere over the shop.
func _throw_sheet() -> void:
	if sheets.size() >= MAX_SHEETS:
		var oldest: Dictionary = sheets.pop_front()
		(oldest.node as Node).queue_free()
	var mesh := BoxMesh.new()
	mesh.size = sheet_size
	var node := MeshInstance3D.new()
	node.mesh = mesh
	var paper := StandardMaterial3D.new()
	paper.albedo_color = sheet_color.lerp(INKS[ink()], 0.15)
	node.material_override = paper
	node.position = Vector3(_tray_x.y - 0.2, _tray_top + 0.3, 0)
	add_child(node)
	var velocity := Vector3(_rng.randf_range(0.5, 3.0), _rng.randf_range(3.0, 5.0), _rng.randf_range(-2.5, 2.5))
	sheets.append({"node": node, "velocity": velocity, "age": 0.0})


func _area(area_name: String, center: Vector3, size: Vector3) -> Area3D:
	var area := Area3D.new()
	area.name = area_name
	area.collision_layer = 0
	area.collision_mask = 4
	area.position = center
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	return area


## Sets the belt moving or still, and wakes what lies on it (a still body falls asleep).
func _apply() -> void:
	belt.constant_linear_velocity = Vector3(SPEED, 0, 0) if is_moving() else Vector3.ZERO
	if is_moving():
		for body: Node3D in _riders.get_overlapping_bodies():
			if body is RigidBody3D:
				(body as RigidBody3D).sleeping = false
