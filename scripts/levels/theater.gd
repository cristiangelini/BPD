class_name Theater
extends CrimeScenePlace

## The Teatro Municipal (escena-teatro.md, step 1, decision 510), on its lot with the front to +Z: columns and the
## marquee of "Seis Fantasmas" on the sidewalk. Inside, the foyer in front with the ticket booth and the empty case of
## the Golden Mask; the hall with the red seats, a box up on each side and the orchestra pit; the raised stage with the
## turntable, four trapdoors over the basement, the prompter's shell and the backdrop; behind it, the six dressing
## rooms (one per sheet embroidery) and the props workshop. The people and the case come in later steps. Every number
## here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(36, 32)
const HALF_X := 17.0
const BACK_Z := -15.0
## The front wall; the sidewalk runs from it to the lot's edge.
const FRONT_Z := 9.0
const FLOOR_TOP := 0.06
const ROOF := 8.0
## The wall between the foyer (in front) and the hall, with its two doors.
const FOYER_Z := 4.0
const DOORS_HALL_X: Array[float] = [-5.0, 5.0]
const DOOR_FRONT_X := 0.0
const DOOR_AT := Vector3(DOOR_FRONT_X, 0, FRONT_Z)
const SIDEWALK_AT := Vector3(0, 0, FRONT_Z + 3.5)
## The stage: from its front edge (STAGE_Z) back to the backdrop (BACKDROP_Z), its floor at STAGE_TOP, the basement
## under it (BASEMENT_TOP, one floor down) between the wings (BASEMENT_X).
const STAGE_Z := -5.5
const BACKDROP_Z := -11.0
const STAGE_TOP := 1.08
const BASEMENT_TOP := STAGE_TOP - GameScale.FLOOR_HEIGHT
const BASEMENT_X := 15.0
## The turntable in the middle of the stage and the four trapdoors around it.
const TURNTABLE_AT := Vector3(0, STAGE_TOP, -8.25)
const TURNTABLE_RADIUS := 2.6
const TRAPDOOR_SIZE := 1.4
const TRAPDOORS: Array[Vector3] = [Vector3(-6.5, STAGE_TOP, -7.0), Vector3(6.5, STAGE_TOP, -7.0),
	Vector3(-6.5, STAGE_TOP, -9.8), Vector3(6.5, STAGE_TOP, -9.8)]
## The stairs from the basement up to the west wing (along -Z) and the hole they come out of.
const BASEMENT_STAIRS_AT := Vector3(-14.4, BASEMENT_TOP, -6.0)
const BASEMENT_STAIRS_RUN := 4.5
const PROMPTER_AT := Vector3(0, STAGE_TOP, STAGE_Z - 0.4)
const LEVER_AT := Vector3(12.5, STAGE_TOP, BACKDROP_Z + 0.4)
## The ramps up to the stage from the hall, at each side of the pit.
const STAGE_RAMPS_X: Array[float] = [-11.5, 11.5]
const RAMP_FROM_Z := -2.6
## The hall: rows of seats from the back to the front row, the pit with its rail and the tuba, and a box up on each
## side (BOX_TOP), reached by stairs along the side walls.
const ROWS_Z: Array[float] = [2.4, 1.5, 0.6, -0.3, -1.2, -2.1]
const SEATS_FROM := 1.2
const SEATS_TO := 10.0
const FRONT_ROW_AT := Vector3(-3.0, 0, -2.1)
const PIT_RAIL_Z := -3.0
const PIT_HALF := 8.0
const TUBA_AT := Vector3(4.0, 0, -4.4)
const BOX_TOP := GameScale.FLOOR_HEIGHT
const BOX_INNER_X := 14.2
const BOX_FROM_Z := -4.5
const BOX_TO_Z := -0.5
const BOX_SEAT_AT := Vector3(15.6, BOX_TOP, -3.2)
## The foyer: the ticket booth, the red carpet and the glass case the Golden Mask was taken from.
const MASK_CASE_AT := Vector3(0, 0, 6.2)
const BOOTH_AT := Vector3(-13.5, 0, 6.5)
## Behind the backdrop: the dressing rooms along the back wall, one per embroidery, and the props workshop.
const DRESSING_FROM := -12.0
const DRESSING_WIDTH := 2.6
const DRESSING_FRONT_Z := -12.6
const EMBROIDERIES: Array[String] = ["star", "moon", "sun", "bolt", "heart", "clover"]
const WORKSHOP_X := 5.0
const DOOR_WORKSHOP_Z := -13.0
const PROPS_DESK_AT := Vector3(11.0, STAGE_TOP, -13.8)
const PAINT := Color(0.72, 0.16, 0.18)
const INSIDE := Color(0.92, 0.86, 0.74)
const MARBLE := Color(0.85, 0.83, 0.8)
const BOARDS := Color(0.45, 0.3, 0.18)
const WOOD := Color(0.5, 0.34, 0.2)
const VELVET := Color(0.62, 0.08, 0.12)
const GOLD := Color(0.85, 0.68, 0.25)
const CONCRETE := Color(0.45, 0.45, 0.47)
const BLACK := Color(0.08, 0.08, 0.1)
const WHITE := Color(0.97, 0.97, 0.97)
const BACKDROP := Color(0.35, 0.45, 0.7)

## The trapdoors' bodies, by index (TRAPDOORS), closed over their holes.
var trapdoors: Array[StaticBody3D] = []
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("theater")
	variant = "theater"
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_foyer()
	_hall()
	_stage()
	_basement()
	_backstage()


## Whether a point in the world (ignoring height) is on the theater's lot, sidewalk included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the building (the basement too).
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## Which room a point in the world is in: "foyer", "hall", "stage", "basement", "dressing", "workshop", "backstage"
## or "" outside.
func room(world: Vector3) -> String:
	if not inside(world):
		return ""
	var local := to_local(world)
	if local.z > FOYER_Z:
		return "foyer"
	if local.z > STAGE_Z:
		return "hall"
	if local.z > BACKDROP_Z:
		return "basement" if local.y < STAGE_TOP - 0.5 else "stage"
	if local.x > WORKSHOP_X:
		return "workshop"
	if local.z < DRESSING_FRONT_Z and local.x > DRESSING_FROM and local.x < DRESSING_FROM + DRESSING_WIDTH * 6:
		return "dressing"
	return "backstage"


## The middle of dressing room `index` (0 to 5, one per EMBROIDERIES), on its floor.
static func dressing_at(index: int) -> Vector3:
	return Vector3(DRESSING_FROM + (index + 0.5) * DRESSING_WIDTH, STAGE_TOP, (BACK_Z + DRESSING_FRONT_Z) / 2)


## The floors, the roof with its lights and the outer walls.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, FOYER_Z, FRONT_Z, FLOOR_TOP, MARBLE)
	_builder.slab(-HALF_X, HALF_X, STAGE_Z, FOYER_Z, FLOOR_TOP, VELVET.darkened(0.3))
	_builder.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, ROOF, INSIDE)
	_builder.wall_at("x", BACK_Z, -HALF_X, HALF_X, 0, ROOF, [], PAINT)
	_builder.wall_at("x", FRONT_Z, -HALF_X, HALF_X, 0, ROOF, [DOOR_FRONT_X], PAINT)
	_builder.wall_at("z", -HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], PAINT)
	_builder.wall_at("z", HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], PAINT)
	for at: Vector3 in [Vector3(-8, 0, 6.5), Vector3(8, 0, 6.5), Vector3(-6, 0, 0), Vector3(6, 0, 0),
			Vector3(-7, STAGE_TOP, -8), Vector3(7, STAGE_TOP, -8), Vector3(-5, STAGE_TOP, -13),
			Vector3(11, STAGE_TOP, -13)]:
		_builder.light(at + Vector3(0, minf(ROOF - 0.5, at.y + 4.0), 0))


## The columns on the sidewalk, the sign and the marquee with the show's name over the door.
func _front() -> void:
	var face := FRONT_Z + 0.12
	_label("Sign", "SIGN_THEATER", Vector3(0, ROOF - 1.0, face + 0.06), 0.0, 0.014, 64)
	_builder.mesh_box(Vector3(0, 3.4, FRONT_Z + 1.0), Vector3(8.0, 0.8, 2.0), BLACK)
	_label("Marquee", "SIGN_MARQUEE", Vector3(0, 3.4, FRONT_Z + 2.02), 0.0, 0.008, 48)
	for i in 8:
		var bulb := SphereMesh.new()
		bulb.radius = 0.08
		bulb.height = 0.16
		_builder.mesh(bulb, Vector3(-3.6 + i * 1.03, 3.85, FRONT_Z + 2.02), Color(1.0, 0.9, 0.5))
	var column := CylinderMesh.new()
	column.top_radius = 0.35
	column.bottom_radius = 0.4
	column.height = ROOF - 0.5
	for x: float in [-8.0, -3.5, 3.5, 8.0]:
		var at := Vector3(x, 0, FRONT_Z + 1.2)
		_builder.shape(_builder.body(at + Vector3(0, column.height / 2, 0)), Vector3(0.7, column.height, 0.7))
		_builder.mesh(column, at + Vector3(0, column.height / 2, 0), MARBLE)


## The foyer: the ticket booth, the red carpet from the door to the hall and the empty glass case of the Golden Mask.
func _foyer() -> void:
	_builder.box(BOOTH_AT + Vector3(0, 1.1, 0), Vector3(2.4, 2.2, 1.8), WOOD)
	_label("Booth", "SIGN_BOOTH", BOOTH_AT + Vector3(1.22, 1.8, 0), PI / 2)
	_builder.mesh_box(Vector3(0, FLOOR_TOP + 0.01, (FOYER_Z + FRONT_Z) / 2), Vector3(2.4, 0.02, FRONT_Z - FOYER_Z),
		VELVET)
	_builder.box(MASK_CASE_AT + Vector3(0, 0.5, 0), Vector3(0.8, 1.0, 0.8), MARBLE)
	var glass := MeshInstance3D.new()
	glass.name = "MaskCase"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.7, 0.7, 0.7)
	glass.mesh = mesh
	var see_through := StandardMaterial3D.new()
	see_through.albedo_color = Color(0.8, 0.95, 1.0, 0.25)
	see_through.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.material_override = see_through
	glass.position = MASK_CASE_AT + Vector3(0, 1.36, 0)
	add_child(glass)
	_builder.mesh_box(MASK_CASE_AT + Vector3(0, 1.03, 0), Vector3(0.3, 0.06, 0.2), VELVET)
	_label("Plaque", "SIGN_MASK", MASK_CASE_AT + Vector3(0, 0.75, 0.42), 0.0, 0.003, 32)
	for x: float in DOORS_HALL_X:
		_label("", "SIGN_HALL", Vector3(x, 2.5, FOYER_Z + 0.12), 0.0)


## The hall: the wall to the foyer, the rows of seats each side of the aisle, the pit with its rail, its chairs and the
## tuba, the two ramps up to the stage, and a box with its stairs on each side.
func _hall() -> void:
	_builder.wall_at("x", FOYER_Z, -HALF_X, HALF_X, 0, ROOF, DOORS_HALL_X, INSIDE)
	for z: float in ROWS_Z:
		for side: float in [-1.0, 1.0]:
			var middle := side * (SEATS_FROM + SEATS_TO) / 2
			_builder.box(Vector3(middle, 0.25, z), Vector3(SEATS_TO - SEATS_FROM, 0.5, 0.5), VELVET)
			_builder.mesh_box(Vector3(middle, 0.7, z + 0.22), Vector3(SEATS_TO - SEATS_FROM, 0.5, 0.08), VELVET)
	_builder.box(Vector3(0, 0.45, PIT_RAIL_Z), Vector3(PIT_HALF * 2, 0.9, 0.1), GOLD)
	for i in 6:
		_builder.mesh_box(Vector3(-6.0 + i * 2.0, 0.25, -4.6), Vector3(0.45, 0.5, 0.45), BLACK)
	var bell := CylinderMesh.new()
	bell.top_radius = 0.4
	bell.bottom_radius = 0.15
	bell.height = 0.5
	_builder.box(TUBA_AT + Vector3(0, 0.45, 0), Vector3(0.5, 0.9, 0.5), GOLD)
	_builder.mesh(bell, TUBA_AT + Vector3(0, 1.1, 0), GOLD)
	for x: float in STAGE_RAMPS_X:
		_ramp(Vector3(x, 0, RAMP_FROM_Z), STAGE_Z - RAMP_FROM_Z, STAGE_TOP)
	for side: float in [-1.0, 1.0]:
		var outer := side * HALF_X
		var inner := side * BOX_INNER_X
		_builder.slab(minf(inner, outer), maxf(inner, outer), BOX_FROM_Z, BOX_TO_Z, BOX_TOP, VELVET.darkened(0.2))
		_builder.box(Vector3(inner, BOX_TOP + 0.45, (BOX_FROM_Z + BOX_TO_Z) / 2), Vector3(0.15, 0.9, BOX_TO_Z - BOX_FROM_Z),
			GOLD)
		_builder.stairs(Vector3(side * 15.6, 0, FOYER_Z - 0.5), FOYER_Z - 0.5 - BOX_TO_Z, WOOD)
		_builder.mesh_box(Vector3(side * 15.6, BOX_TOP + 0.25, -3.2), Vector3(0.6, 0.5, 0.6), VELVET)


## The stage: its floor with the holes for the stairs down and the trapdoors (closed), the turntable, the prompter's
## shell at its edge, the backdrop with walks round it, the curtain and the stage lever.
func _stage() -> void:
	var trap_xs := [TRAPDOORS[0].x, TRAPDOORS[1].x]
	var half := TRAPDOOR_SIZE / 2
	var stair_in := BASEMENT_STAIRS_AT.x + GameScale.STAIR_WIDTH / 2 + 0.1
	var stair_end := BASEMENT_STAIRS_AT.z - BASEMENT_STAIRS_RUN
	_builder.slab(-BASEMENT_X, stair_in, BACKDROP_Z, stair_end, STAGE_TOP, BOARDS)
	_builder.slab(stair_in, trap_xs[0] - half, BACKDROP_Z, STAGE_Z, STAGE_TOP, BOARDS)
	_builder.slab(trap_xs[0] + half, trap_xs[1] - half, BACKDROP_Z, STAGE_Z, STAGE_TOP, BOARDS)
	_builder.slab(trap_xs[1] + half, BASEMENT_X, BACKDROP_Z, STAGE_Z, STAGE_TOP, BOARDS)
	for x: float in trap_xs:
		var gaps: Array[float] = [STAGE_Z]
		for trap: Vector3 in TRAPDOORS:
			if trap.x == x:
				gaps.append(trap.z + half)
				gaps.append(trap.z - half)
		gaps.append(BACKDROP_Z)
		for i in range(0, gaps.size(), 2):
			_builder.slab(x - half, x + half, gaps[i + 1], gaps[i], STAGE_TOP, BOARDS)
	for i in TRAPDOORS.size():
		var door := _builder.body(TRAPDOORS[i] - Vector3(0, PlaceBuilder.SLAB / 2, 0))
		door.name = "Trapdoor%d" % i
		_builder.shape(door, Vector3(TRAPDOOR_SIZE, PlaceBuilder.SLAB, TRAPDOOR_SIZE))
		var lid := MeshInstance3D.new()
		var lid_mesh := BoxMesh.new()
		lid_mesh.size = Vector3(TRAPDOOR_SIZE - 0.04, PlaceBuilder.SLAB, TRAPDOOR_SIZE - 0.04)
		lid.mesh = lid_mesh
		lid.material_override = _builder.material(BOARDS.darkened(0.35))
		door.add_child(lid)
		trapdoors.append(door)
	var turntable := MeshInstance3D.new()
	turntable.name = "Turntable"
	var disc := CylinderMesh.new()
	disc.top_radius = TURNTABLE_RADIUS
	disc.bottom_radius = TURNTABLE_RADIUS
	disc.height = 0.04
	turntable.mesh = disc
	turntable.material_override = _builder.material(BOARDS.lightened(0.15))
	turntable.position = TURNTABLE_AT + Vector3(0, 0.02, 0)
	add_child(turntable)
	var shell := SphereMesh.new()
	shell.radius = 0.6
	shell.height = 0.6
	shell.is_hemisphere = true
	_builder.shape(_builder.body(PROMPTER_AT + Vector3(0, 0.3, 0)), Vector3(1.2, 0.6, 0.8))
	_builder.mesh(shell, PROMPTER_AT, GOLD)
	for side: float in [-1.0, 1.0]:
		_builder.box(Vector3(side * (BASEMENT_X + HALF_X) / 2, (BASEMENT_TOP + STAGE_TOP) / 2, (STAGE_Z + BACKDROP_Z) / 2),
			Vector3(HALF_X - BASEMENT_X, STAGE_TOP - BASEMENT_TOP, STAGE_Z - BACKDROP_Z), BOARDS.darkened(0.2))
		_builder.mesh_box(Vector3(side * 12.5, (ROOF + 2.6) / 2, STAGE_Z - 0.1), Vector3(5.0, ROOF - 2.6, 0.1), VELVET)
	_builder.box(Vector3(0, (BASEMENT_TOP + STAGE_TOP) / 2, STAGE_Z + 0.08), Vector3(BASEMENT_X * 2, STAGE_TOP - BASEMENT_TOP,
		0.16), BOARDS.darkened(0.2))
	_builder.mesh_box(Vector3(0, ROOF - 0.6, STAGE_Z - 0.1), Vector3(HALF_X * 2, 1.0, 0.1), VELVET)
	_builder.box(Vector3(0, STAGE_TOP + 2.8, BACKDROP_Z), Vector3(20.0, 5.6, 0.1), BACKDROP)
	_builder.mesh_box(LEVER_AT + Vector3(0, 0.5, 0), Vector3(0.3, 1.0, 0.3), BLACK)
	_builder.mesh_box(LEVER_AT + Vector3(0, 1.15, 0.1), Vector3(0.06, 0.5, 0.06), Color(0.85, 0.15, 0.15))


## The basement under the stage: its floor, the walls the stage's sides hold up and the stairs to the west wing, with
## old scenery leaning on the walls.
func _basement() -> void:
	_builder.slab(-BASEMENT_X, BASEMENT_X, BACKDROP_Z, STAGE_Z, BASEMENT_TOP, CONCRETE)
	_builder.stairs(BASEMENT_STAIRS_AT, BASEMENT_STAIRS_RUN, WOOD)
	_builder.light(Vector3(0, STAGE_TOP - 0.6, -8.25))
	_builder.light(Vector3(-9, STAGE_TOP - 0.6, -8.25))
	_builder.light(Vector3(9, STAGE_TOP - 0.6, -8.25))
	for at: Vector3 in [Vector3(8.0, BASEMENT_TOP, -10.6), Vector3(10.5, BASEMENT_TOP, -10.6)]:
		_builder.box(at + Vector3(0, 1.0, 0), Vector3(2.0, 2.0, 0.1), BACKDROP.darkened(0.2))


## Behind the backdrop: the floor up at the stage's height, the six dressing rooms along the back wall with their
## embroidery over the door and a trunk inside, and the props workshop with its desk and shelves.
func _backstage() -> void:
	_builder.box(Vector3(0, (BASEMENT_TOP + STAGE_TOP) / 2, (BACK_Z + BACKDROP_Z) / 2), Vector3(HALF_X * 2,
		STAGE_TOP - BASEMENT_TOP, BACKDROP_Z - BACK_Z), BOARDS.darkened(0.2))
	var doors: Array[float] = []
	for i in EMBROIDERIES.size():
		doors.append(dressing_at(i).x)
	var dressing_to := DRESSING_FROM + DRESSING_WIDTH * EMBROIDERIES.size()
	var height := ROOF - STAGE_TOP
	_builder.wall_at("x", DRESSING_FRONT_Z, DRESSING_FROM, dressing_to, STAGE_TOP, height, doors, INSIDE)
	for i in EMBROIDERIES.size() + 1:
		var x := DRESSING_FROM + i * DRESSING_WIDTH
		_builder.wall_at("z", x, BACK_Z, DRESSING_FRONT_Z, STAGE_TOP, height, [], INSIDE)
	for i in EMBROIDERIES.size():
		var at := dressing_at(i)
		_label("Dressing%d" % i, "SIGN_DRESSING_%s" % EMBROIDERIES[i].to_upper(),
			Vector3(at.x, STAGE_TOP + 2.4, DRESSING_FRONT_Z + 0.1), 0.0, 0.004, 32)
		_builder.box(Vector3(at.x, STAGE_TOP + 0.3, BACK_Z + 0.5), Vector3(1.2, 0.6, 0.6), WOOD.darkened(0.2))
		_builder.mesh_box(Vector3(at.x + 0.9, STAGE_TOP + 1.3, BACK_Z + 0.1), Vector3(0.6, 0.8, 0.04), WHITE)
	_builder.wall_at("z", WORKSHOP_X, BACK_Z, BACKDROP_Z, STAGE_TOP, height, [DOOR_WORKSHOP_Z], INSIDE)
	_label("", "SIGN_WORKSHOP", Vector3(WORKSHOP_X - 0.12, STAGE_TOP + 2.6, DOOR_WORKSHOP_Z), -PI / 2)
	_builder.box(PROPS_DESK_AT + Vector3(0, 0.45, 0), Vector3(2.4, 0.9, 1.0), WOOD)
	_builder.mesh_box(PROPS_DESK_AT + Vector3(-0.4, 0.96, 0), Vector3(0.5, 0.12, 0.4), Color(0.25, 0.2, 0.45))
	_builder.box(Vector3(16.4, STAGE_TOP + 1.0, -13.0), Vector3(0.6, 2.0, 3.0), WOOD)


## A ramp up `rise` along -Z from `foot`, `run` long, with treads only for the look.
func _ramp(foot: Vector3, run: float, rise: float) -> void:
	var length := absf(run)
	var steps := roundi(rise / GameScale.STEP_HEIGHT)
	for i in steps:
		var top := foot.y + (i + 1) * GameScale.STEP_HEIGHT
		_builder.mesh_box(Vector3(foot.x, top - 0.03, foot.z - (i + 0.5) * length / steps),
			Vector3(1.6, 0.06, length / steps), WOOD)
	var ramp := _builder.body(foot + Vector3(0, rise / 2, -length / 2))
	ramp.rotation.x = atan2(rise, length)
	_builder.shape(ramp, Vector3(1.6, 0.05, Vector2(length, rise).length()))


func _label(label_name: String, key: String, at: Vector3, turn: float, pixel := 0.006, font := 32) -> void:
	var label := Label3D.new()
	if label_name != "":
		label.name = label_name
	label.text = key
	label.pixel_size = pixel
	label.font_size = font
	label.outline_size = 8
	label.position = at
	label.rotation.y = turn
	add_child(label)
