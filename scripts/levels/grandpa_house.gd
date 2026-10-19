class_name GrandpaHouse
extends Node3D

## Case 1.1 "La casa del abuelo" (docs/diseno/allanamiento.md): a two floor house of 12 x 10 m with 8 rooms.
## Downstairs: entrada (the hall), living, cocina, comedor and baño. Upstairs: two dormitorios and the altillo.
## It is built from the data below when the scene loads, and the evidence goes to hiding spots drawn with the case seed.

const WALL := 0.15
const SLAB := 0.2
const HALF_X := 6.0
const HALF_Z := 5.0
## The stairs climb north along the east side of the hall, from z = 0 to z = -3.75.
const STAIR_X := 1.0
const STAIR_RUN := 3.75
## The upstairs hole over the stairs is wider than them, so a cop's head doesn't hit its edge.
const HOLE_WEST := 0.2

const FLOOR_WOOD := Color(0.66, 0.44, 0.28)
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## Seconds between solving or failing the case and the end of shift screen.
const SHIFT_DELAY := 2.5
const GRASS := Color(0.45, 0.72, 0.3)
const ROAD := Color(0.32, 0.33, 0.36)
const OUTSIDE := Color(1.0, 0.84, 0.55)
const INSIDE_DOWN := Color(0.62, 0.92, 0.84)
const INSIDE_UP := Color(1.0, 0.74, 0.8)
const ROOF := Color(0.86, 0.32, 0.26)
const FURNITURE := Color(0.55, 0.36, 0.62)
const WHITE := Color(0.92, 0.92, 0.88)

## [axis, fixed, from, to, level, door centers, color]. Axis "x" runs along x at z = fixed; "z" along z at x = fixed.
const WALLS := [
	["x", HALF_Z, -HALF_X, HALF_X, 0, [0.0], OUTSIDE],
	["x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE],
	["z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE],
	["z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE],
	["z", -1.5, -HALF_Z, HALF_Z, 0, [2.5, -3.0], INSIDE_DOWN],
	["z", 1.5, -HALF_Z, HALF_Z, 0, [3.0], INSIDE_DOWN],
	["x", -1.0, -HALF_X, -1.5, 0, [], INSIDE_DOWN],
	["x", 1.0, 1.5, HALF_X, 0, [4.0], INSIDE_DOWN],
	["x", HALF_Z, -HALF_X, HALF_X, 1, [], OUTSIDE],
	["x", -HALF_Z, -HALF_X, HALF_X, 1, [], OUTSIDE],
	["z", -HALF_X, -HALF_Z, HALF_Z, 1, [], OUTSIDE],
	["z", HALF_X, -HALF_Z, HALF_Z, 1, [], OUTSIDE],
	["z", -1.5, -HALF_Z, HALF_Z, 1, [2.5, -2.0], INSIDE_UP],
	["z", 1.5, -HALF_Z, HALF_Z, 1, [2.5], INSIDE_UP],
	["x", 0.0, -HALF_X, -1.5, 1, [], INSIDE_UP],
]

## Ten hiding spots: where the evidence rests, and whether a heavy item (the 40 kg safe) fits there.
const SPOTS := [
	{"id": "under_sofa", "at": Vector3(-4.5, 0.0, 4.3), "heavy": false},
	{"id": "behind_picture", "at": Vector3(-5.72, 1.025, 1.5), "heavy": false},
	{"id": "in_oven", "at": Vector3(5.5, 0.05, -4.0), "heavy": false},
	{"id": "in_cupboard", "at": Vector3(3.0, 1.025, -4.6), "heavy": false},
	{"id": "under_table", "at": Vector3(3.8, 0.0, 3.0), "heavy": true},
	{"id": "in_bathtub", "at": Vector3(-4.8, 0.05, -4.2), "heavy": true},
	{"id": "under_stairs", "at": Vector3(1.0, 0.0, -3.3), "heavy": true},
	{"id": "under_bed", "at": Vector3(-4.5, 2.7, 3.6), "heavy": false},
	{"id": "in_attic", "at": Vector3(-4.6, 2.7, -3.6), "heavy": true},
	{"id": "in_wardrobe", "at": Vector3(5.6, 2.75, -2.0), "heavy": true},
]

## The door key hides in one of these pots by the front door.
const POTS := [Vector3(-2.5, 0.0, 5.8), Vector3(2.5, 0.0, 5.8), Vector3(4.5, 0.0, 6.6)]

const POT_SCENE := preload("res://scenes/props/key_pot.tscn")

## Evidence placed this week: the main one (cookie tin) and the small safe. Album and figurine come later.
const EVIDENCE := [
	{"scene": preload("res://scenes/props/cookie_tin.tscn"), "heavy": false, "half_height": 0.085},
	{"scene": preload("res://scenes/props/heavy_safe.tscn"), "heavy": true, "half_height": 0.3},
]

## 0 draws a new seed. Online, the host will send it to everyone.
@export var case_seed := 0

## Spot index of each placed evidence, in EVIDENCE order.
var evidence_spots: Array = []
var evidence: Array[Node3D] = []
var key_pot := 0
var pots: Array[KeyPot] = []
var ornaments_total := 0
var broken_ornaments := 0
## Money taken off the case pay for broken ornaments.
var fines := 0

## The grandpa called his lawyer or the main evidence broke: the case is lost.
var case_failed := false
## The main evidence is in the trunk and every cop got in the car (allanamiento.md, "Entrega").
var case_solved := false
## The end of shift screen is up.
var shift_over := false

var _materials := {}
@onready var _built: Node3D = $Built
@onready var grandpa: Grandpa = $Grandpa
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	_build()
	_bake_navigation()
	grandpa.complaint_changed.connect(func(value: float) -> void: %ComplaintBar.value = value)
	grandpa.lawyer_called.connect(_on_lawyer_called)
	$FrontDoor.broken.connect(func() -> void: grandpa.door_broken($FrontDoor.global_position))
	if case_seed == 0:
		case_seed = randi() | 1
	var spot_heavy := SPOTS.map(func(s: Dictionary) -> bool: return s.heavy)
	var item_heavy := EVIDENCE.map(func(e: Dictionary) -> bool: return e.heavy)
	var result := HidingDraw.draw(case_seed, spot_heavy, item_heavy, POTS.size())
	evidence_spots = result.spots
	key_pot = result.key_pot
	pots[key_pot].has_key = true
	for i in EVIDENCE.size():
		var item: Node3D = EVIDENCE[i].scene.instantiate()
		item.position = SPOTS[evidence_spots[i]].at + Vector3.UP * (EVIDENCE[i].half_height + 0.02)
		$Evidence.add_child(item)
		evidence.append(item)
	for place: Dictionary in OrnamentLayout.places(case_seed):
		var ornament: Ornament = OrnamentLayout.KINDS[place.kind].instantiate()
		ornament.position = place.at
		ornament.rotation.y = place.turn
		ornament.broken.connect(_on_ornament_broken)
		$Ornaments.add_child(ornament)
	ornaments_total = $Ornaments.get_child_count()
	(evidence[0] as Evidence).broken.connect(_fail.bind("CASE_FAILED_BROKEN"))
	car.evidence_delivered.connect(_on_evidence_delivered)
	car.evidence_delivered.connect(_check_solved.unbind(1))
	car.seats_changed.connect(_check_solved)
	$ShiftScreen.play_again.connect(func() -> void: get_tree().reload_current_scene())
	$ShiftScreen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


## Shows the end of shift screen with the pay and the awards, and stops everyone's controls.
func finish_shift() -> void:
	if shift_over:
		return
	shift_over = true
	var values := car.delivered.map(func(item: Evidence) -> float: return item.value)
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	%CaseSolved.hide()
	%CaseFailed.hide()
	$ShiftScreen.show_report(case_solved, ShiftReport.pay(case_solved, values, fines), broken_ornaments,
		ShiftReport.awards(stats))


func _finish_soon() -> void:
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The cookie tin, the evidence the case is about.
func main_evidence() -> Evidence:
	return evidence[0]


func _check_solved() -> void:
	if case_solved or case_failed or not car.is_delivered(main_evidence()):
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).vehicle != car:
			return
	case_solved = true
	%CaseSolved.show()
	_finish_soon()


func _on_evidence_delivered(item: Evidence) -> void:
	_float_label("+%d" % roundi(item.value), item.global_position, Color(0.4, 1, 0.45))


func _on_lawyer_called() -> void:
	_fail("CASE_FAILED_LAWYER")


func _fail(reason: String) -> void:
	if case_failed or case_solved:
		return
	case_failed = true
	%CaseFailed.text = reason
	%CaseFailed.show()
	_finish_soon()


## The grandpa walks on a navigation mesh baked from the built house when the scene loads.
func _bake_navigation() -> void:
	var nav: NavigationRegion3D = $Navigation
	NavigationServer3D.map_set_cell_size(get_world_3d().navigation_map, nav.navigation_mesh.cell_size)
	NavigationServer3D.map_set_cell_height(get_world_3d().navigation_map, nav.navigation_mesh.cell_height)
	_built.add_to_group("navigation_source")
	nav.bake_navigation_mesh(false)


func _on_ornament_broken(at: Vector3) -> void:
	grandpa.saw_break(at)
	broken_ornaments += 1
	fines += Ornament.FINE
	_float_label("-%d" % Ornament.FINE, at, Color(1, 0.3, 0.25))


## Placeholder feedback until the HUD exists: money floats up where it happened.
func _float_label(text: String, at: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	label.outline_size = 8
	label.pixel_size = 0.005
	add_child(label)
	label.global_position = at + Vector3.UP * 0.2
	var tween := label.create_tween()
	tween.tween_property(label, "global_position:y", at.y + 0.8, 1.2)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(label.queue_free)


func _build() -> void:
	var up := GameScale.FLOOR_HEIGHT
	_box(Vector3(0, -0.1, 0), Vector3(40, 0.2, 40), GRASS)
	# The street in front of the house, where the patrol car waits (visual only, flat on the grass).
	_mesh_box(Vector3(0, 0.005, 12.5), Vector3(40, 0.01, 6), ROAD)
	_box(Vector3(0, 0.01, 0), Vector3(HALF_X * 2, 0.02, HALF_Z * 2), FLOOR_WOOD)
	# Upstairs floor, with the hole over the stairs.
	var hole_east := STAIR_X + GameScale.STAIR_WIDTH / 2
	var hole_north := -STAIR_RUN
	_slab(-HALF_X, HOLE_WEST, -HALF_Z, HALF_Z, up)
	_slab(HOLE_WEST, HALF_X, 0.0, HALF_Z, up)
	_slab(HOLE_WEST, HALF_X, -HALF_Z, hole_north, up)
	_slab(hole_east, HALF_X, hole_north, 0.0, up)
	_slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, up * 2)
	# Gable roof, just for the look from outside.
	var roof := PrismMesh.new()
	roof.size = Vector3(HALF_X * 2 + 0.6, 2.2, HALF_Z * 2 + 0.6)
	_mesh(roof, Vector3(0, up * 2 + 1.1, 0), ROOF)
	for w: Array in WALLS:
		_wall(w[0], w[1], w[2], w[3], w[4], w[5], w[6])
	# Railing around the stair hole upstairs.
	_box(Vector3(HOLE_WEST, up + 0.5, hole_north / 2), Vector3(0.08, 1.0, STAIR_RUN), WHITE)
	_box(Vector3((HOLE_WEST + hole_east) / 2, up + 0.5, 0.0), Vector3(hole_east - HOLE_WEST, 1.0, 0.08), WHITE)
	_stairs()
	_furniture()
	for unit: Dictionary in OrnamentLayout.SHELVES:
		for box: Array in OrnamentLayout.shelf_boxes(unit):
			_box(box[0], box[1], FURNITURE)
	for p: Vector3 in POTS:
		var pot: KeyPot = POT_SCENE.instantiate()
		pot.position = p
		_built.add_child(pot)
		pots.append(pot)
	_lights()


## A ramp to walk on (a capsule can't climb 18 cm steps) under treads that are only for the look.
func _stairs() -> void:
	var rise := GameScale.FLOOR_HEIGHT
	var steps := roundi(rise / GameScale.STEP_HEIGHT)
	var depth := STAIR_RUN / steps
	for i in steps:
		var top := (i + 1) * GameScale.STEP_HEIGHT
		_mesh_box(Vector3(STAIR_X, top - 0.03, -(i + 0.5) * depth), Vector3(GameScale.STAIR_WIDTH, 0.06, depth), WHITE)
	var ramp := _body(Vector3(STAIR_X, rise / 2, -STAIR_RUN / 2))
	ramp.rotation.x = atan2(rise, STAIR_RUN)
	_shape(ramp, Vector3(GameScale.STAIR_WIDTH, 0.05, Vector2(STAIR_RUN, rise).length()))


func _furniture() -> void:
	var up := GameScale.FLOOR_HEIGHT
	# Living: sofa on legs and a picture with a shelf behind it.
	_legs(Vector3(-4.5, 0, 4.3), Vector2(2.2, 0.8), 0.3, FURNITURE)
	_box(Vector3(-4.5, 0.45, 4.3), Vector3(2.2, 0.3, 0.8), FURNITURE)
	_box(Vector3(-4.5, 0.85, 4.65), Vector3(2.2, 0.5, 0.15), FURNITURE)
	_box(Vector3(-5.72, 1.0, 1.5), Vector3(0.4, 0.05, 0.6), FURNITURE)
	_box(Vector3(-5.45, 1.35, 1.5), Vector3(0.05, 0.8, 0.9), Color(0.95, 0.75, 0.2))
	# Cocina: oven open to the west, cupboard with a shelf and a counter.
	_open_box(Vector3(5.5, 0, -4.0), Vector3(0.8, 0.9, 0.7), "-x", WHITE)
	_open_box(Vector3(3.0, 0, -4.6), Vector3(1.2, 2.0, 0.6), "+z", FURNITURE)
	_box(Vector3(3.0, 1.0, -4.6), Vector3(1.1, 0.05, 0.55), FURNITURE)
	_box(Vector3(4.4, 0.45, -4.6), Vector3(1.2, 0.9, 0.6), WHITE)
	# Comedor: table on legs.
	_legs(Vector3(3.8, 0, 3.0), Vector2(2.0, 1.1), 0.72, FURNITURE)
	_box(Vector3(3.8, 0.75, 3.0), Vector3(2.0, 0.06, 1.1), FURNITURE)
	# Baño: bathtub and toilet.
	_open_box(Vector3(-4.8, 0, -4.2), Vector3(1.7, 0.6, 0.8), "top", WHITE)
	_box(Vector3(-2.3, 0.2, -4.5), Vector3(0.45, 0.4, 0.6), WHITE)
	# Dormitorios: a bed in each, wardrobe in the east one.
	_bed(Vector3(-4.5, up, 3.6))
	_bed(Vector3(3.8, up, 3.4))
	_open_box(Vector3(5.6, up, -2.0), Vector3(0.6, 2.0, 1.2), "-x", FURNITURE)
	# Altillo: junk boxes.
	_box(Vector3(-5.4, up + 0.3, -1.0), Vector3(0.8, 0.6, 0.8), Color(0.7, 0.55, 0.35))
	_box(Vector3(-3.0, up + 0.4, -4.4), Vector3(1.0, 0.8, 0.8), Color(0.7, 0.55, 0.35))


func _bed(foot_center: Vector3) -> void:
	_legs(foot_center, Vector2(1.5, 2.1), 0.34, FURNITURE)
	_box(foot_center + Vector3(0, 0.37, 0), Vector3(1.5, 0.06, 2.1), FURNITURE)
	_box(foot_center + Vector3(0, 0.5, 0), Vector3(1.4, 0.2, 2.0), WHITE)
	_box(foot_center + Vector3(0, 0.6, 1.05), Vector3(1.5, 1.2, 0.08), FURNITURE)


func _lights() -> void:
	var up := GameScale.FLOOR_HEIGHT
	for at: Vector3 in [Vector3(0, 2.2, 2), Vector3(-3.7, 2.2, 2), Vector3(3.7, 2.2, -2), Vector3(3.7, 2.2, 3),
			Vector3(-3.7, 2.2, -3), Vector3(-3.7, up + 2.2, 2.5), Vector3(-3.7, up + 2.2, -2.5), Vector3(3.7, up + 2.2, 0)]:
		var light := OmniLight3D.new()
		light.position = at
		light.light_color = Color(1.0, 0.82, 0.6)
		light.light_energy = 0.6
		light.omni_range = 6.0
		_built.add_child(light)


func _wall(axis: String, fixed: float, from: float, to: float, level: int, doors: Array, color: Color) -> void:
	var y0 := level * GameScale.FLOOR_HEIGHT
	var height := GameScale.FLOOR_HEIGHT - SLAB
	var start := from
	for d: float in doors:
		var a := d - GameScale.DOOR_WIDTH / 2
		var b := d + GameScale.DOOR_WIDTH / 2
		_wall_piece(axis, fixed, start, a, y0, height, color)
		_wall_piece(axis, fixed, a, b, y0 + GameScale.DOOR_HEIGHT, height - GameScale.DOOR_HEIGHT, color)
		start = b
	_wall_piece(axis, fixed, start, to, y0, height, color)


func _wall_piece(axis: String, fixed: float, a: float, b: float, y0: float, height: float, color: Color) -> void:
	if b - a < 0.01 or height < 0.01:
		return
	var mid := (a + b) / 2
	if axis == "x":
		_box(Vector3(mid, y0 + height / 2, fixed), Vector3(b - a, height, WALL), color)
	else:
		_box(Vector3(fixed, y0 + height / 2, mid), Vector3(WALL, height, b - a), color)


## A floor slab whose top is at y = top.
func _slab(x0: float, x1: float, z0: float, z1: float, top: float) -> void:
	_box(Vector3((x0 + x1) / 2, top - SLAB / 2, (z0 + z1) / 2), Vector3(x1 - x0, SLAB, z1 - z0), FLOOR_WOOD)


## Four thin legs under a footprint, from the floor up to height.
func _legs(center: Vector3, footprint: Vector2, height: float, color: Color) -> void:
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var at := center + Vector3(sx * (footprint.x / 2 - 0.06), height / 2, sz * (footprint.y / 2 - 0.06))
			_box(at, Vector3(0.08, height, 0.08), color)


## A box open on one face ("top", "-x", "+x", "-z" or "+z"), standing on bottom_center.
func _open_box(bottom_center: Vector3, size: Vector3, open: String, color: Color) -> void:
	var t := 0.05
	var center := bottom_center + Vector3(0, size.y / 2, 0)
	var faces := {
		"bottom": [Vector3(0, -size.y / 2 + t / 2, 0), Vector3(size.x, t, size.z)],
		"top": [Vector3(0, size.y / 2 - t / 2, 0), Vector3(size.x, t, size.z)],
		"-x": [Vector3(-size.x / 2 + t / 2, 0, 0), Vector3(t, size.y, size.z)],
		"+x": [Vector3(size.x / 2 - t / 2, 0, 0), Vector3(t, size.y, size.z)],
		"-z": [Vector3(0, 0, -size.z / 2 + t / 2), Vector3(size.x, size.y, t)],
		"+z": [Vector3(0, 0, size.z / 2 - t / 2), Vector3(size.x, size.y, t)],
	}
	for face: String in faces:
		if face != open:
			_box(center + faces[face][0], faces[face][1], color)


func _box(center: Vector3, size: Vector3, color: Color) -> void:
	_shape(_body(center), size)
	_mesh_box(center, size, color)


func _body(at: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	_built.add_child(body)
	return body


func _shape(body: StaticBody3D, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)


func _mesh_box(center: Vector3, size: Vector3, color: Color) -> void:
	var box := BoxMesh.new()
	box.size = size
	_mesh(box, center, color)


func _mesh(mesh: Mesh, at: Vector3, color: Color) -> void:
	if not _materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.9
		_materials[color] = material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _materials[color]
	instance.position = at
	_built.add_child(instance)
