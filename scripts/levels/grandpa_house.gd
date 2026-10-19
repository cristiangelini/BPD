class_name GrandpaHouse
extends Node3D

## Case 1.1 "La casa del abuelo" (docs/diseno/allanamiento.md): a two floor house of 24 x 20 m with 14 rooms.
## A hall runs south to north through the middle of both floors, with three rooms on each side of it.
## Downstairs: living, estudio and baño to the west; comedor, cocina and lavadero to the east.
## Upstairs: dormitorio chico, cuarto de costura and baño de arriba to the west; dormitorio grande,
## cuarto de juegos and altillo to the east.
## It is built from the data below when the scene loads, and the evidence goes to hiding spots drawn with the case seed.

const WALL := 0.15
const SLAB := 0.2
const HALF_X := 12.0
const HALF_Z := 10.0
## The hall is 3 m wide; the rooms on each side are split at these z values.
const HALL := 1.5
const SPLITS := [3.0, -3.0]
## The stairs climb north along the east side of the hall, from z = 0 to z = -3.75.
const STAIR_X := 1.0
const STAIR_RUN := 3.75
## The upstairs hole over the stairs is wider than them, so a cop's head doesn't hit its edge.
const HOLE_WEST := 0.2

const FLOOR_WOOD := Color(0.66, 0.44, 0.28)
const GRASS := Color(0.45, 0.72, 0.3)
const ROAD := Color(0.32, 0.33, 0.36)
const OUTSIDE := Color(1.0, 0.84, 0.55)
const INSIDE_DOWN := Color(0.62, 0.92, 0.84)
const INSIDE_UP := Color(1.0, 0.74, 0.8)
const ROOF := Color(0.86, 0.32, 0.26)
const FURNITURE := Color(0.55, 0.36, 0.62)
const WHITE := Color(0.92, 0.92, 0.88)

## [axis, fixed, from, to, level, door centers, color]. Axis "x" runs along x at z = fixed; "z" along z at x = fixed.
## The east middle doors sit at z = 1.5 so they don't open onto the foot of the stairs.
const WALLS := [
	["x", HALF_Z, -HALF_X, HALF_X, 0, [0.0], OUTSIDE],
	["x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE],
	["z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE],
	["z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE],
	["z", -HALL, -HALF_Z, HALF_Z, 0, [6.5, 0.0, -6.5], INSIDE_DOWN],
	["z", HALL, -HALF_Z, HALF_Z, 0, [6.5, 1.5, -6.5], INSIDE_DOWN],
	["x", 3.0, -HALF_X, -HALL, 0, [-7.0], INSIDE_DOWN],
	["x", -3.0, -HALF_X, -HALL, 0, [], INSIDE_DOWN],
	["x", 3.0, HALL, HALF_X, 0, [7.0], INSIDE_DOWN],
	["x", -3.0, HALL, HALF_X, 0, [7.0], INSIDE_DOWN],
	["x", HALF_Z, -HALF_X, HALF_X, 1, [], OUTSIDE],
	["x", -HALF_Z, -HALF_X, HALF_X, 1, [], OUTSIDE],
	["z", -HALF_X, -HALF_Z, HALF_Z, 1, [], OUTSIDE],
	["z", HALF_X, -HALF_Z, HALF_Z, 1, [], OUTSIDE],
	["z", -HALL, -HALF_Z, HALF_Z, 1, [6.5, 0.0, -6.5], INSIDE_UP],
	["z", HALL, -HALF_Z, HALF_Z, 1, [6.5, 1.5, -6.5], INSIDE_UP],
	["x", 3.0, -HALF_X, -HALL, 1, [], INSIDE_UP],
	["x", -3.0, -HALF_X, -HALL, 1, [], INSIDE_UP],
	["x", 3.0, HALL, HALF_X, 1, [], INSIDE_UP],
	["x", -3.0, HALL, HALF_X, 1, [], INSIDE_UP],
]

## Twelve hiding spots: where the evidence rests, and whether a heavy item (the 40 kg safe) fits there.
const SPOTS := [
	{"id": "under_sofa", "at": Vector3(-8.0, 0.0, 9.3), "heavy": false},
	{"id": "behind_picture", "at": Vector3(-11.72, 1.025, 6.5), "heavy": false},
	{"id": "in_oven", "at": Vector3(11.5, 0.05, -1.5), "heavy": false},
	{"id": "in_cupboard", "at": Vector3(5.0, 1.025, -2.6), "heavy": false},
	{"id": "under_table", "at": Vector3(7.0, 0.0, 6.5), "heavy": true},
	{"id": "in_bathtub", "at": Vector3(-10.8, 0.05, -9.2), "heavy": true},
	{"id": "under_stairs", "at": Vector3(1.0, 0.0, -3.3), "heavy": true},
	{"id": "under_desk", "at": Vector3(-9.0, 0.0, -1.0), "heavy": true},
	{"id": "in_washer", "at": Vector3(11.4, 0.05, -9.4), "heavy": true},
	{"id": "under_bed", "at": Vector3(-8.0, 2.7, 7.5), "heavy": false},
	{"id": "in_attic", "at": Vector3(8.0, 2.7, -8.5), "heavy": true},
	{"id": "in_wardrobe", "at": Vector3(11.6, 2.75, 5.0), "heavy": true},
]

## The door key hides in one of these pots by the front door.
const POTS := [Vector3(-2.5, 0.0, 10.8), Vector3(2.5, 0.0, 10.8), Vector3(4.5, 0.0, 11.6)]

const POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const CLUTTER_SCENE := preload("res://scenes/props/clutter.tscn")

## Dressers (cómodas): floor point at the middle of the front and the way the front faces (rotation around y).
const DRESSERS := [
	{"at": Vector3(-11.42, 2.7, 5.0), "turn": PI / 2},  # dormitorio chico
	{"at": Vector3(11.42, 2.7, 8.5), "turn": -PI / 2},  # dormitorio grande
	{"at": Vector3(-5.0, 0.0, 2.42), "turn": PI},  # estudio
	{"at": Vector3(-11.42, 2.7, 0.0), "turn": PI / 2},  # cuarto de costura
	{"at": Vector3(4.0, 0.0, 9.42), "turn": PI},  # comedor
]
## Chance that a drawer also holds an ornament, which breaks if the drawer is yanked out (propuesta).
const DRAWER_ORNAMENT := 0.3

## What the comisario says before the raid, one tr() key per line.
const BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_1_1_B", "BRIEF_1_1_C", "BRIEF_1_1_D", "BRIEF_1_1_E"]
## The open checklist redraws this often, in seconds.
const CHECKLIST_REFRESH := 0.2

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
## Some cop already picked up the main evidence (checklist row "find it").
var main_found := false

var briefing: CaseBriefing
var checklist: CaseChecklist
var _refresh_left := 0.0

var _materials := {}
var _drawer_ornaments := 0
var dressers: Array[Dresser] = []
@onready var _built: Node3D = $Built
@onready var grandpa: Grandpa = $Grandpa
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = randi() | 1
	_build()
	_place_dressers()
	_bake_navigation()
	grandpa.complaint_changed.connect(func(value: float) -> void: %ComplaintBar.value = value)
	grandpa.lawyer_called.connect(_on_lawyer_called)
	$FrontDoor.broken.connect(func() -> void: grandpa.door_broken($FrontDoor.global_position))
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
	ornaments_total = $Ornaments.get_child_count() + _drawer_ornaments
	(evidence[0] as Evidence).broken.connect(_fail.bind("CASE_FAILED_BROKEN"))
	car.evidence_delivered.connect(_on_evidence_delivered)
	car.evidence_delivered.connect(_check_solved.unbind(1))
	car.seats_changed.connect(_check_solved)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing = CaseBriefing.new()
	add_child(briefing)
	briefing.finished.connect(checklist.set_open.bind(true))
	# Only a cop with a player at the keys hears the comisario; tests drive cops without input.
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(BRIEFING)
			break


func _process(delta: float) -> void:
	if not main_found and main_evidence().is_held():
		main_found = true
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = CHECKLIST_REFRESH
		checklist.show_rows(CaseObjectives.rows(objective_facts()))


## What the checklist needs to know about the case right now.
func objective_facts() -> Dictionary:
	var door: FrontDoor = $FrontDoor
	var all_in := true
	for cop in get_tree().get_nodes_in_group("cops"):
		all_in = all_in and (cop as Cop).vehicle == car
	return {
		"door_open": door.is_open or door.is_broken,
		"found": main_found,
		"delivered": car.is_delivered(main_evidence()),
		"all_in_car": all_in,
		"extra_delivered": car.is_delivered(evidence[1] as Evidence),
		"broken": broken_ornaments,
		"fines": fines,
		"complaint": grandpa.complaint,
	}


## Dressers whose drawers hold folded clothes and, sometimes, an ornament (contents come from the case seed).
func _place_dressers() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed + 17
	for place: Dictionary in DRESSERS:
		var dresser := Dresser.new()
		var fill := []
		for i in Dresser.DRAWERS:
			var items := [CLUTTER_SCENE]
			if rng.randf() < DRAWER_ORNAMENT:
				items.append(OrnamentLayout.KINDS[rng.randi_range(0, OrnamentLayout.KINDS.size() - 1)])
			else:
				items.append(CLUTTER_SCENE)
			fill.append(items)
		dresser.contents = fill
		dresser.position = place.at
		dresser.rotation.y = place.turn
		_built.add_child(dresser)
		dressers.append(dresser)
		for drawer in dresser.drawers:
			drawer.ripped.connect(grandpa.saw_break)
			for item in drawer.contents:
				if item is Ornament:
					(item as Ornament).broken.connect(_on_ornament_broken)
					_drawer_ornaments += 1


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
	_box(Vector3(0, -0.1, 4), Vector3(60, 0.2, 52), GRASS)
	# The street in front of the house, where the patrol car waits (visual only, flat on the grass).
	_mesh_box(Vector3(0, 0.005, 17.5), Vector3(60, 0.01, 6), ROAD)
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
	# Living: sofa on legs against the south wall and a picture with a shelf behind it on the west wall.
	_legs(Vector3(-8.0, 0, 9.3), Vector2(2.2, 0.8), 0.3, FURNITURE)
	_box(Vector3(-8.0, 0.45, 9.3), Vector3(2.2, 0.3, 0.8), FURNITURE)
	_box(Vector3(-8.0, 0.85, 9.65), Vector3(2.2, 0.5, 0.15), FURNITURE)
	_box(Vector3(-11.72, 1.0, 6.5), Vector3(0.4, 0.05, 0.6), FURNITURE)
	_box(Vector3(-11.45, 1.35, 6.5), Vector3(0.05, 0.8, 0.9), Color(0.95, 0.75, 0.2))
	# Estudio: desk on legs.
	_legs(Vector3(-9.0, 0, -1.0), Vector2(1.6, 0.9), 0.74, FURNITURE)
	_box(Vector3(-9.0, 0.77, -1.0), Vector3(1.6, 0.06, 0.9), FURNITURE)
	# Cocina: oven open to the west, cupboard with a shelf and a counter, against the north wall.
	_open_box(Vector3(11.5, 0, -1.5), Vector3(0.8, 0.9, 0.7), "-x", WHITE)
	_open_box(Vector3(5.0, 0, -2.6), Vector3(1.2, 2.0, 0.6), "+z", FURNITURE)
	_box(Vector3(5.0, 1.0, -2.6), Vector3(1.1, 0.05, 0.55), FURNITURE)
	_box(Vector3(6.4, 0.45, -2.6), Vector3(1.2, 0.9, 0.6), WHITE)
	# Comedor: table on legs.
	_legs(Vector3(7.0, 0, 6.5), Vector2(2.0, 1.1), 0.72, FURNITURE)
	_box(Vector3(7.0, 0.75, 6.5), Vector3(2.0, 0.06, 1.1), FURNITURE)
	# Lavadero: washing machine open to the west.
	_open_box(Vector3(11.4, 0, -9.4), Vector3(0.9, 0.9, 0.9), "-x", WHITE)
	# Baño: bathtub and toilet.
	_open_box(Vector3(-10.8, 0, -9.2), Vector3(1.7, 0.6, 0.8), "top", WHITE)
	_box(Vector3(-2.3, 0.2, -9.5), Vector3(0.45, 0.4, 0.6), WHITE)
	# Dormitorios: a bed in each, wardrobe in the big one.
	_bed(Vector3(-8.0, up, 7.5))
	_bed(Vector3(7.0, up, 7.0))
	_open_box(Vector3(11.6, up, 5.0), Vector3(0.6, 2.0, 1.2), "-x", FURNITURE)
	# Cuarto de costura: sewing table. Cuarto de juegos: card table. Baño de arriba: toilet.
	_legs(Vector3(-7.0, up, 0.0), Vector2(1.2, 0.7), 0.74, FURNITURE)
	_box(Vector3(-7.0, up + 0.77, 0.0), Vector3(1.2, 0.06, 0.7), FURNITURE)
	_legs(Vector3(7.0, up, 0.0), Vector2(1.4, 1.4), 0.72, FURNITURE)
	_box(Vector3(7.0, up + 0.75, 0.0), Vector3(1.4, 0.06, 1.4), Color(0.2, 0.55, 0.3))
	_box(Vector3(-2.3, up + 0.2, -9.5), Vector3(0.45, 0.4, 0.6), WHITE)
	# Altillo: junk boxes.
	_box(Vector3(10.5, up + 0.3, -5.0), Vector3(0.8, 0.6, 0.8), Color(0.7, 0.55, 0.35))
	_box(Vector3(5.5, up + 0.4, -9.4), Vector3(1.0, 0.8, 0.8), Color(0.7, 0.55, 0.35))


func _bed(foot_center: Vector3) -> void:
	_legs(foot_center, Vector2(1.5, 2.1), 0.34, FURNITURE)
	_box(foot_center + Vector3(0, 0.37, 0), Vector3(1.5, 0.06, 2.1), FURNITURE)
	_box(foot_center + Vector3(0, 0.5, 0), Vector3(1.4, 0.2, 2.0), WHITE)
	_box(foot_center + Vector3(0, 0.6, 1.05), Vector3(1.5, 1.2, 0.08), FURNITURE)


## One light in the middle of each room and two along each hall.
func _lights() -> void:
	var up := GameScale.FLOOR_HEIGHT
	for level in 2:
		var y := level * up + 2.2
		for x: float in [-6.75, 6.75]:
			for z: float in [6.5, 0.0, -6.5]:
				_light(Vector3(x, y, z))
		for z: float in [5.0, -5.0]:
			_light(Vector3(-0.5, y, z))


func _light(at: Vector3) -> void:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = Color(1.0, 0.82, 0.6)
	light.light_energy = 0.7
	light.omni_range = 8.0
	_built.add_child(light)


func _wall(axis: String, fixed: float, from: float, to: float, level: int, doors: Array, color: Color) -> void:
	var y0 := level * GameScale.FLOOR_HEIGHT
	var height := GameScale.FLOOR_HEIGHT - SLAB
	var start := from
	# Doors must go in order along the wall, or a later piece covers an earlier door.
	var sorted_doors := doors.duplicate()
	sorted_doors.sort()
	for d: float in sorted_doors:
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
