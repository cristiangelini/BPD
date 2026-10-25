class_name MimeTheater
extends InfiltrationPlace

## The mime troupe's "Teatro del Silencio" (docs/diseno/infiltracion-mimos.md, step 2, decision 170): one floor on its
## lot in the city, the front to +Z. The hall has two blocks of seats with an aisle down the middle, and at the back
## the stage with two rows of marks on its floor, red curtains at its sides and the trunk by its east side; Maestra
## Pausa's bench is on the floor in front of it. Behind the stage, her dressing room (locked) and the prop room. The
## cops start in the station, where the mime disguises are, and drive here. --place=mime opens it from Play.
## Mimes stand on the stage's marks (by the seed), Maestra Pausa by her bench facing them, and the mute doorman only lets
## in cops passing for mimes (step 2b); they all watch the cops (ClubSuspicion, "MIME_" texts) and hear them talk
## (MimeSilence, step 3); Pausa leads the rehearsals of mime and statue (MimeRehearsal, step 4).
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway at the end of the aisle.
const ENTRANCE_X := 0.0
## The seats: one block on each side of the aisle, rows from the entrance toward the stage.
const SEAT_XS: Array[float] = [-4.2, 4.2]
const SEAT_ZS: Array[float] = [7.0, 5.9, 4.8, 3.7, 2.6, 1.5, 0.4, -0.7]
const SEAT_SIZE := Vector3(5.0, 0.45, 0.5)
const SEAT_BACK := 0.85
## The stage against the back wall, low enough to step onto, and its two rows of marks.
const STAGE := Rect2(-8.0, -6.5, 16.0, 3.5)
const STAGE_HEIGHT := 0.35
const ROW_ZS: Array[float] = [-5.6, -4.0]
const MARKS_PER_ROW := 7
const MARK_GAP := 2.0
## Where Maestra Pausa stands, on the floor in front of the stage, facing it (-Z).
const BENCH_AT := Vector3(0, 0, -2.0)
## The trunk at the stage's east side, on the floor.
const TRUNK_AT := Vector3(9.6, 0, -4.6)
const TRUNK_SIZE := Vector3(1.2, 0.7, 0.7)
## The back rooms run along the north behind the stage: the dressing room (west, locked) and the prop room (east).
const BACK_Z := -6.5
const ROOMS_SPLIT_X := 0.0
const DRESSING_DOOR_X := -10.0
const PROPS_DOOR_X := 10.0
## How many mimes rehearse, of the 14 marks; the rest are for the cops.
const MEMBERS := 10
## The mute doorman stands outside, by the entrance.
const DOORMAN_AT := Vector3(ENTRANCE_X + 1.4, 0, HALF_Z + 0.7)

const OUTSIDE := Color(0.2, 0.2, 0.24)
const INSIDE := Color(0.9, 0.88, 0.86)
const FLOOR := Color(0.32, 0.22, 0.16)
const SEAT := Color(0.62, 0.12, 0.16)
const STAGE_COLOR := Color(0.18, 0.16, 0.16)
const CURTAIN := Color(0.7, 0.08, 0.12)
const MARK := Color(0.95, 0.95, 0.9)
const WOOD := Color(0.48, 0.3, 0.18)
const CARDBOARD := Color(0.72, 0.56, 0.36)

var dressing_door: FrontDoor
## The marks on the stage, on its floor, in the theater's space, and the ones no mime took, for the cops.
var marks: Array[Vector3] = []
var free_marks: Array[Vector3] = []
var pausa: ClubMember
var doorman: ClubDoorman
## No talking near the mimes (step 3).
var silence: MimeSilence
## Maestra Pausa's rehearsals of mime and statue (step 4).
var rehearsal: MimeRehearsal
var _build: PlaceBuilder


func _ready() -> void:
	variant = "mime"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_hall()
	_build_stage()
	_build_back_rooms()
	dressing_door = DOOR_SCENE.instantiate()
	dressing_door.position = Vector3(DRESSING_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(dressing_door)
	_add_people()
	place_in_city("mime_theater")


## Maestra Pausa runs off from the street, out of the entrance (step 6).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


## The mimes on marks drawn with the seed, facing the hall, Maestra Pausa by her bench facing them, the mute doorman
## and their suspicion.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["mime members", case_seed])
	free_marks = marks.duplicate()
	for i in MEMBERS:
		var member := ClubMember.new()
		member.name = "Member%d" % i
		member.look = "mimo" if rng.randf() < 0.5 else "mimo_b"
		member.next_line = rng.randi_range(0, ClubMember.TALK[member.look][1] - 1)
		add_child(member)
		member.position = free_marks.pop_at(rng.randi_range(0, free_marks.size() - 1))
		# Facing the hall (+Z).
		member.rotation.y = PI
		members.append(member)
	pausa = ClubMember.new()
	pausa.name = "Pausa"
	pausa.look = "pausa"
	add_child(pausa)
	pausa.position = BENCH_AT + Vector3(0, FLOOR_TOP, 0)
	boss = pausa
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	doorman.look = "mimo_portero"
	doorman.disguise_look = "mime"
	add_child(doorman)
	doorman.position = DOORMAN_AT
	doorman.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = pausa
	suspicion.boss_found_out = "PAUSA_FOUND_OUT"
	suspicion.disguise_look = "mime"
	suspicion.prefix = "MIME_"
	suspicion.inside = is_inside
	suspicion.in_back_room = in_back_room
	add_child(suspicion)
	silence = MimeSilence.new()
	silence.name = "Silence"
	silence.suspicion = suspicion
	silence.inside = is_inside
	add_child(silence)
	rehearsal = MimeRehearsal.new()
	rehearsal.name = "Rehearsal"
	rehearsal.case_seed = case_seed
	rehearsal.pausa = pausa
	rehearsal.members = members
	rehearsal.inside = is_inside
	rehearsal.on_stage = on_stage
	add_child(rehearsal)
	suspicion.watch_rehearsal(rehearsal)


## Whether a world position is inside the theater.
func is_inside(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is in the dressing room or the prop room.
func in_back_room(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and local.z > -HALF_Z and local.z < BACK_Z and local.y < ROOF


## Whether a world position is up on the stage.
func on_stage(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return STAGE.has_point(Vector2(local.x, local.z)) and local.y > FLOOR_TOP + STAGE_HEIGHT - 0.2 and local.y < ROOF


## Floor, outer walls with the entrance, the roof, the sign and the two masks over the door.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_MIME_THEATER"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	# Two white faces over the door, one smiling and one sad, so it reads as a theater from the street.
	for side: float in [-1.0, 1.0]:
		var face := SphereMesh.new()
		face.radius = 0.45
		face.height = 0.9
		_build.mesh(face, Vector3(side * 2.2, ROOF - 0.9, HALF_Z + 0.2), MARK, Vector3.ZERO)
		var mouth := TorusMesh.new()
		mouth.inner_radius = 0.12
		mouth.outer_radius = 0.17
		_build.mesh(mouth, Vector3(side * 2.2, ROOF - 1.05 + side * 0.06, HALF_Z + 0.62), STAGE_COLOR,
			Vector3(PI / 2, 0, 0))
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-8.0, -4.5, 1.0, 6.5]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The seats in two blocks along the aisle, each row with its backrest toward the entrance.
func _build_hall() -> void:
	for x: float in SEAT_XS:
		for z: float in SEAT_ZS:
			_build.box(Vector3(x, FLOOR_TOP + SEAT_SIZE.y / 2, z), SEAT_SIZE, SEAT)
			_build.box(Vector3(x, FLOOR_TOP + SEAT_BACK / 2, z + SEAT_SIZE.z / 2 + 0.04),
				Vector3(SEAT_SIZE.x, SEAT_BACK, 0.08), SEAT.darkened(0.25))
	# Maestra Pausa's little bench, facing the stage.
	_build.box(BENCH_AT + Vector3(0, FLOOR_TOP + 0.1, 0.6), Vector3(0.9, 0.2, 0.4), WOOD)


## The stage with its marks, its curtains at both sides and the trunk by its east side.
func _build_stage() -> void:
	var middle := STAGE.get_center()
	_build.box(Vector3(middle.x, FLOOR_TOP + STAGE_HEIGHT / 2, middle.y),
		Vector3(STAGE.size.x, STAGE_HEIGHT, STAGE.size.y), STAGE_COLOR)
	var top := FLOOR_TOP + STAGE_HEIGHT
	for z: float in ROW_ZS:
		for i in MARKS_PER_ROW:
			var at := Vector3((i - (MARKS_PER_ROW - 1) / 2.0) * MARK_GAP, top, z)
			marks.append(at)
			# A white cross of tape on the floor.
			_build.mesh_box(at + Vector3(0, 0.005, 0), Vector3(0.4, 0.01, 0.06), MARK)
			_build.mesh_box(at + Vector3(0, 0.005, 0), Vector3(0.06, 0.01, 0.4), MARK)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * (STAGE.size.x / 2 + 0.3), (ROOF - 0.2) / 2, middle.y + 1.0),
			Vector3(0.6, ROOF - 0.2, 1.4), CURTAIN)
	_build.box(TRUNK_AT + Vector3(0, FLOOR_TOP + TRUNK_SIZE.y / 2, 0), TRUNK_SIZE, WOOD.darkened(0.2))


## The dressing room and the prop room behind the stage: a mirror and a dresser in the first, shelves and boxes in the
## second.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [DRESSING_DOOR_X, PROPS_DOOR_X], INSIDE)
	_build.wall("z", ROOMS_SPLIT_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	# Dressing room: a dresser with a mirror ringed by bulbs, against the back wall.
	_build.box(Vector3(-6.0, FLOOR_TOP + 0.4, -9.5), Vector3(1.8, 0.8, 0.6), WOOD)
	_build.mesh_box(Vector3(-6.0, FLOOR_TOP + 1.4, -9.82), Vector3(1.2, 0.9, 0.02), Color(0.8, 0.88, 0.92))
	for i in 6:
		_build.mesh_box(Vector3(-6.6 + i * 0.24, FLOOR_TOP + 1.9, -9.8), Vector3(0.08, 0.08, 0.08), Color(1, 0.95, 0.7))
	# Prop room: shelves along the back wall and boxes of props.
	_build.open_box(Vector3(6.0, FLOOR_TOP, -9.5), Vector3(6.0, 2.0, 0.6), "+z", WOOD)
	_build.box(Vector3(2.5, FLOOR_TOP + 0.3, -7.6), Vector3(0.8, 0.6, 0.6), CARDBOARD)
	_build.box(Vector3(3.4, FLOOR_TOP + 0.25, -8.4), Vector3(0.7, 0.5, 0.6), CARDBOARD.darkened(0.1))
