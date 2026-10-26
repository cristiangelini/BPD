class_name SchoolHall
extends InfiltrationPlace

## The thieves' school "Academia Manos Ligeras" (docs/diseno/infiltracion-escuela.md, step 2, decision 173): one floor
## on its own city lot, the front to +Z. A lobby from the entrance, the classroom to the west (desks facing the
## blackboard and the Profesora's desk) and the practice yard to the east (the locks on the wall, the dummy in a coat
## and the creaky floor); behind, the library (west) and the Director's office (east, locked), where he waits unseen
## until the graduation (step 4). The students sit at the desks, the Profesora Ganzúa teaches in front of them and the
## lookout only lets in cops dressed as thieves. When the cops' grades are good enough, the Director comes down to the
## classroom for the graduation (step 4). The cops start in the station, where the disguises are, and drive here.
## --place=school opens it from Play. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const KEY_POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const HOMEWORK_MODEL := preload("res://assets/models/school_homework.glb")
const TRUNK_MODEL := preload("res://assets/models/school_trunk.glb")
const LOOT_MODEL := preload("res://assets/models/jewelry_bag.glb")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway in the middle of the front wall, into the lobby between LOBBY_X and -LOBBY_X;
## the classroom and the yard open onto it through a door at DOORS_Z.
const ENTRANCE_X := 0.0
const LOBBY_X := 2.0
const DOORS_Z := 5.0
## The back rooms, behind the wall at BACK_Z: the library west of LIBRARY_X (its door at LIBRARY_DOOR_X) and the
## office east of OFFICE_X (its locked door at OFFICE_DOOR_X); the hall between them is open.
const BACK_Z := 0.0
const LIBRARY_X := -3.0
const LIBRARY_DOOR_X := -7.5
const OFFICE_X := 3.0
const OFFICE_DOOR_X := 7.5
## The classroom: the blackboard on the west wall, the Profesora's desk in front of it and twelve desks facing it
## (the students stand behind them, to the east).
const BOARD_AT := Vector3(-HALF_X + 0.12, 1.5, 5.0)
const TEACHER_DESK := Vector3(-9.6, 0, 5.0)
const TEACHER_AT := Vector3(-10.9, 0, 5.0)
const DESK_COLUMNS: Array[float] = [-7.6, -5.9, -4.2]
const DESK_ROWS: Array[float] = [2.0, 4.0, 6.0, 8.0]
const DESK_SIZE := Vector3(0.6, 0.72, 0.9)
## Where a student stands behind its desk.
const SEAT_BEHIND := 0.65
## The practice yard (step 3): the training locks on the east wall, the dummy in a coat and the creaky floor.
const LOCKS: Array[Vector3] = [Vector3(HALF_X - 0.1, 1.1, 1.8), Vector3(HALF_X - 0.1, 1.1, 3.2),
	Vector3(HALF_X - 0.1, 1.1, 4.6), Vector3(HALF_X - 0.1, 1.1, 6.0)]
const DUMMY_AT := Vector3(6.0, 0, 2.6)
const CREAKY := Rect2(3.4, 6.6, 7.4, 2.6)
## The Director waits in his office until the graduation (step 4), when he stands by the blackboard, next to the
## Profesora, facing the class.
const DIRECTOR_AT := Vector3(8.5, 0, -6.5)
const GRADUATION_AT := Vector3(-10.9, 0, 3.4)
## The 6 pieces of evidence (the seed picks 3, ClubEvidence) and where they are: the "homework" (the houses to rob) on
## the Profesora's desk, the bank's plan on the classroom's back board (a photo), the students' real names in a book
## sticking out of a library shelf (E), the video of two students going over the job at their desks, the "practice"
## loot in the open trunk in the yard and the blank diploma signed by the Director on his desk in the office (a photo).
## The office key is in the Profesora's desk drawer.
const EVIDENCE_KINDS: Array[String] = ["homework", "board", "register", "recording", "loot", "diploma"]
const HOMEWORK_AT := Vector3(-9.6, FLOOR_TOP + 0.82, 4.5)
const PLAN_AT := Vector3(-LOBBY_X - 0.14, 1.5, 8.0)
const REGISTER_AT := Vector3(-8.0, FLOOR_TOP + 1.25, -HALF_Z + 0.7)
const TRUNK_AT := Vector3(9.0, 0, 0.6)
const LOOT_AT := Vector3(9.0, FLOOR_TOP + 0.5, 0.6)
const DIPLOMA_AT := Vector3(8.5, FLOOR_TOP + 0.82, -8.3)
const DRAWER_AT := Vector3(-10.02, FLOOR_TOP + 0.35, 5.5)
## Two students this close talk about the job (the recording).
const TALK_PAIR := 2.6
## How many students, of the 12 desks; the rest are for the cops.
const MEMBERS := 9
## The lookout stands outside, by the entrance.
const DOORMAN_AT := Vector3(ENTRANCE_X + 1.4, 0, HALF_Z + 0.7)

const OUTSIDE := Color(0.45, 0.4, 0.55)
const INSIDE := Color(0.9, 0.88, 0.8)
const FLOOR := Color(0.55, 0.42, 0.3)
const YARD := Color(0.5, 0.52, 0.5)
const WOOD := Color(0.48, 0.3, 0.18)
const BOARD := Color(0.12, 0.28, 0.18)
const STEEL := Color(0.6, 0.62, 0.66)
const PLANK := Color(0.62, 0.48, 0.3)

var office_door: FrontDoor
## The desks' spots no student took, for the cops (step 3).
var free_seats: Array[Vector3] = []
var teacher: ClubMember
var director: ClubMember
var doorman: ClubDoorman
## The Profesora's practical classes (step 3).
var classes: SchoolClasses
var _build: PlaceBuilder


func _ready() -> void:
	variant = "school"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_classroom()
	_build_yard()
	_build_back_rooms()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)
	_add_people()
	_add_evidence()
	place_in_city("school")
	start_case()
	# Cuffing the Profesora gives the cops away too, like cuffing a student.
	teacher.cuffed_now.connect(case._on_grandparent_cuffed)


## The Director drives off from the street, out of the entrance (step 5).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


## Whether a world position is inside the school.
func is_inside(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is in the Director's office.
func in_back_room(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > OFFICE_X and local.x < HALF_X and local.z > -HALF_Z and local.z < BACK_Z and local.y < ROOF


## Whether a world position is in the library.
func in_library(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > -HALF_X and local.x < LIBRARY_X and local.z > -HALF_Z and local.z < BACK_Z and local.y < ROOF


## Whether a world position is in the classroom.
func in_classroom(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > -HALF_X and local.x < -LOBBY_X and local.z > BACK_Z and local.z < HALF_Z and local.y < ROOF


## Whether a world position is in the practice yard.
func in_yard(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > LOBBY_X and local.x < HALF_X and local.z > BACK_Z and local.z < HALF_Z and local.y < ROOF


## Whether a world position is where the classes happen: the classroom or the yard.
func in_lesson(at: Vector3) -> bool:
	return in_classroom(at) or in_yard(at)


## Whether a world position is on the yard's creaky floor.
func on_creaky(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return CREAKY.has_point(Vector2(local.x, local.z)) and local.y < ROOF


## Whether a world position is by one of the training locks.
func near_lock(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return LOCKS.any(func(lock: Vector3) -> bool:
		return Vector2(local.x - lock.x, local.z - lock.z).length() < SchoolClasses.LOCK_REACH)


## Whether a world position is by the dummy.
func near_dummy(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return Vector2(local.x - DUMMY_AT.x, local.z - DUMMY_AT.z).length() < SchoolClasses.DUMMY_REACH


## Where a student or a cop stands at each desk, on the floor.
static func seats() -> Array[Vector3]:
	var spots: Array[Vector3] = []
	for x in DESK_COLUMNS:
		for z in DESK_ROWS:
			spots.append(Vector3(x + SEAT_BEHIND, 0, z))
	return spots


## The students at desks drawn with the seed, facing the blackboard; the Profesora in front of them; the Director
## hidden in his office; the lookout, their suspicion and the Profesora's classes.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["school members", case_seed])
	free_seats = seats()
	for i in MEMBERS:
		var member := ClubMember.new()
		member.name = "Member%d" % i
		member.look = "alumno" if rng.randf() < 0.5 else "alumna"
		member.next_line = rng.randi_range(0, ClubMember.TALK[member.look][1] - 1)
		add_child(member)
		member.position = free_seats.pop_at(rng.randi_range(0, free_seats.size() - 1)) + Vector3(0, FLOOR_TOP, 0)
		# Facing the blackboard (-X).
		member.rotation.y = PI / 2
		members.append(member)
	teacher = ClubMember.new()
	teacher.name = "Teacher"
	teacher.look = "ganzua"
	add_child(teacher)
	teacher.position = TEACHER_AT + Vector3(0, FLOOR_TOP, 0)
	teacher.rotation.y = -PI / 2
	director = ClubMember.new()
	director.name = "Director"
	director.look = "director"
	add_child(director)
	director.position = DIRECTOR_AT + Vector3(0, FLOOR_TOP, 0)
	director.rotation.y = PI
	set_director_present(false)
	boss = director
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	doorman.look = "vigia"
	doorman.disguise_look = "thief"
	add_child(doorman)
	doorman.position = DOORMAN_AT
	doorman.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = director
	suspicion.boss_found_out = "DIRECTOR_FOUND_OUT"
	suspicion.disguise_look = "thief"
	suspicion.prefix = "SCHOOL_"
	suspicion.inside = is_inside
	suspicion.in_back_room = in_back_room
	add_child(suspicion)
	classes = SchoolClasses.new()
	classes.name = "Classes"
	classes.case_seed = case_seed
	classes.teacher = teacher
	classes.inside = is_inside
	classes.in_lesson = in_lesson
	classes.on_creaky = on_creaky
	classes.near_lock = near_lock
	classes.near_dummy = near_dummy
	add_child(classes)
	suspicion.watch_classes(classes)
	classes.graduation_started.connect(_on_graduation)


## The graduation (step 4): the Director comes down to the classroom with the diplomas, now in sight to be cuffed.
func _on_graduation() -> void:
	if suspicion.found_out or (case and case.chase):
		return
	set_director_present(true)
	director.position = GRADUATION_AT + Vector3(0, FLOOR_TOP, 0)
	director.rotation.y = -PI / 2
	director.say("DIRECTOR_GRADUATION")
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.input_enabled:
			cop.show_hint("HINT_SCHOOL_GRADUATION")
	if case:
		case.checklist.show_rows(case.rows())


## The planilla's report card: the cops' average in each subject, or that they graduated.
func clue_row(_found: Array[String], _bonus: bool) -> String:
	if not classes:
		return ""
	if classes.graduated:
		return tr("SCHOOL_GRADUATED_ROW")
	var shown: Array[String] = []
	for kind: String in SchoolClasses.SUBJECTS:
		var average := classes.average(kind)
		shown.append(tr("SCHOOL_NO_GRADE") if average <= 0.0 else "%.1f" % average)
	return tr("SCHOOL_REPORT_ROW") % [shown[0], shown[1], shown[2], SchoolClasses.GRADUATE]


## The 3 pieces of evidence the seed picks (ClubEvidence) and the office key in the Profesora's desk drawer.
func _add_evidence() -> void:
	evidence = ClubEvidence.new()
	evidence.name = "Evidence"
	evidence.held_kinds.assign(["homework", "loot"])
	evidence.talk_key = "SCHOOL_TALK_%d"
	add_child(evidence)
	var pair := _talking_pair()
	var available := EVIDENCE_KINDS.duplicate()
	if pair.is_empty():
		available.erase("recording")
	evidence.kinds = ClubEvidence.draw(case_seed, available)
	var drawer: KeyPot = KEY_POT_SCENE.instantiate()
	drawer.name = "KeyDrawer"
	drawer.has_key = true
	drawer.prompt = "PROMPT_SCHOOL_DRAWER"
	add_child(drawer)
	drawer.position = DRAWER_AT
	drawer.get_node("Pot").hide()
	drawer.get_node("Plant").hide()
	_build.mesh_box(DRAWER_AT + Vector3(0, 0.2, 0), Vector3(0.04, 0.2, 0.6), WOOD.lightened(0.15))
	_build.mesh_box(DRAWER_AT + Vector3(-0.04, 0.2, 0), Vector3(0.03, 0.04, 0.12), STEEL)
	var trunk := TRUNK_MODEL.instantiate()
	$Built.add_child(trunk)
	trunk.position = TRUNK_AT + Vector3(0, FLOOR_TOP, 0)
	_build.shape(_build.body(TRUNK_AT + Vector3(0, FLOOR_TOP + 0.2, 0)), Vector3(1.0, 0.4, 0.6))
	for kind: String in evidence.kinds:
		match kind:
			"homework":
				_item(kind, HOMEWORK_MODEL, Vector3(0.24, 0.04, 0.32), 0.3, HOMEWORK_AT)
			"loot":
				_item(kind, LOOT_MODEL, Vector3(0.25, 0.25, 0.25), 2.0, LOOT_AT)
			"board":
				_spot(kind, PLAN_AT, Vector3(0.1, 1.0, 1.6), true)
				_build.mesh_box(PLAN_AT + Vector3(0.04, 0, 0), Vector3(0.02, 1.0, 1.6), BOARD)
				# The bank's plan in chalk: the building, the vault inside it and the dotted way in from the sewer.
				_build.mesh_box(PLAN_AT + Vector3(0, 0.1, 0.1), Vector3(0.01, 0.6, 0.9), Color(0.92, 0.92, 0.88))
				_build.mesh_box(PLAN_AT + Vector3(-0.01, 0.1, 0.1), Vector3(0.01, 0.52, 0.82), BOARD)
				_build.mesh_box(PLAN_AT + Vector3(-0.02, 0.0, 0.3), Vector3(0.01, 0.2, 0.2), Color(0.95, 0.85, 0.3))
				for i in 4:
					_build.mesh_box(PLAN_AT + Vector3(-0.02, -0.3, -0.55 + i * 0.2), Vector3(0.01, 0.03, 0.1),
						Color(0.92, 0.92, 0.88))
				_build.mesh_box(PLAN_AT + Vector3(-0.02, -0.15, -0.5), Vector3(0.01, 0.3, 0.03), Color(0.92, 0.3, 0.3))
			"register":
				_spot(kind, REGISTER_AT, Vector3(0.6, 0.4, 0.3), false)
				_build.mesh_box(REGISTER_AT + Vector3(0.1, -0.04, -0.02), Vector3(0.08, 0.3, 0.3), Color(0.3, 0.1, 0.4))
			"diploma":
				_spot(kind, DIPLOMA_AT, Vector3(0.6, 0.1, 0.4), true)
				_build.mesh_box(DIPLOMA_AT, Vector3(0.42, 0.01, 0.3), Color(0.96, 0.92, 0.78))
				_build.mesh_box(DIPLOMA_AT + Vector3(0.12, 0.006, 0.08), Vector3(0.06, 0.01, 0.06), Color(0.8, 0.1, 0.1))
				_build.mesh_box(DIPLOMA_AT + Vector3(-0.05, 0.006, 0.08), Vector3(0.18, 0.01, 0.01), Color(0.1, 0.1, 0.3))
			"recording":
				evidence.talkers.assign(pair)
				for member: ClubMember in pair:
					member.distracted = true


## A piece of evidence to grab, lying at `at`.
func _item(kind: String, model: PackedScene, size: Vector3, kg: float, at: Vector3) -> void:
	var item := ClubEvidence.make_item("School_" + kind, model, size, kg)
	add_child(item)
	item.position = at
	evidence.items[kind] = item


## A piece of evidence that stays put, a box of `size` around `at`: photographed, or searched with E.
func _spot(kind: String, at: Vector3, size: Vector3, photo: bool) -> void:
	var spot := ClubEvidenceSpot.new()
	spot.name = "Evidence_" + kind
	spot.kind = kind
	spot.photo = photo
	spot.prompt_prefix = "PROMPT_SCHOOL_"
	spot.evidence = evidence
	add_child(spot)
	spot.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	spot.add_child(shape)


## Two students at desks by each other (the recording's pair), or none.
func _talking_pair() -> Array[ClubMember]:
	for first in members:
		for second in members:
			if first != second and first.position.distance_to(second.position) < TALK_PAIR:
				return [first, second]
	return []


## The Director is out of sight until the graduation (step 4): unseen and not in the way.
func set_director_present(present: bool) -> void:
	director.visible = present
	director.collision_layer = 8 if present else 0


## Floor, outer walls with the entrance, the roof, the sign, the lobby's walls and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	_build.wall("z", -LOBBY_X, BACK_Z, HALF_Z, 0, [DOORS_Z], INSIDE)
	_build.wall("z", LOBBY_X, BACK_Z, HALF_Z, 0, [DOORS_Z], INSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_SCHOOL"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	var motto := Label3D.new()
	motto.text = "SCHOOL_MOTTO"
	motto.font_size = 40
	motto.pixel_size = 0.01
	motto.outline_size = 12
	motto.position = Vector3(0, 2.2, BACK_Z + 0.2)
	$Built.add_child(motto)
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-5.0, 5.0]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The blackboard, the Profesora's desk and the students' desks.
func _build_classroom() -> void:
	_build.mesh_box(BOARD_AT, Vector3(0.04, 1.2, 3.2), BOARD)
	_build.mesh_box(BOARD_AT + Vector3(0, -0.65, 0), Vector3(0.12, 0.05, 3.3), WOOD)
	var lesson := Label3D.new()
	lesson.text = "SCHOOL_BOARD"
	lesson.font_size = 28
	lesson.pixel_size = 0.006
	lesson.width = 480.0
	lesson.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lesson.position = BOARD_AT + Vector3(0.03, 0.1, 0)
	lesson.rotation.y = PI / 2
	$Built.add_child(lesson)
	_build.box(TEACHER_DESK + Vector3(0, FLOOR_TOP + 0.4, 0), Vector3(0.8, 0.8, 1.6), WOOD)
	for x in DESK_COLUMNS:
		for z in DESK_ROWS:
			_build.box(Vector3(x, FLOOR_TOP + DESK_SIZE.y / 2, z), DESK_SIZE, WOOD)
			_build.mesh_box(Vector3(x, FLOOR_TOP + DESK_SIZE.y + 0.01, z), Vector3(DESK_SIZE.x + 0.04, 0.02,
				DESK_SIZE.z + 0.04), WOOD.lightened(0.2))


## The yard's floor, the training locks on the wall, the dummy in a coat with bells and the creaky planks.
func _build_yard() -> void:
	_build.slab(LOBBY_X, HALF_X, BACK_Z, HALF_Z, FLOOR_TOP + 0.01, YARD)
	for at: Vector3 in LOCKS:
		_build.mesh_box(at, Vector3(0.06, 0.5, 0.5), WOOD)
		_build.mesh_box(at + Vector3(-0.05, 0, 0), Vector3(0.04, 0.16, 0.12), STEEL)
		_build.mesh_box(at + Vector3(-0.05, 0.1, 0), Vector3(0.03, 0.08, 0.08), STEEL.darkened(0.3))
	_build.box(DUMMY_AT + Vector3(0, FLOOR_TOP + 0.45, 0), Vector3(0.08, 0.9, 0.08), WOOD)
	_build.mesh_box(DUMMY_AT + Vector3(0, FLOOR_TOP + 1.25, 0), Vector3(0.5, 0.7, 0.32), Color(0.35, 0.3, 0.25))
	for i in 6:
		var bell := SphereMesh.new()
		bell.radius = 0.035
		bell.height = 0.07
		_build.mesh(bell, DUMMY_AT + Vector3(-0.18 + (i % 3) * 0.18, FLOOR_TOP + 1.05 + floorf(i / 3.0) * 0.3, 0.18),
			Color(0.95, 0.8, 0.3))
	for k in int(CREAKY.size.y / 0.4):
		var z := CREAKY.position.y + 0.2 + k * 0.4
		_build.mesh_box(Vector3(CREAKY.get_center().x, FLOOR_TOP + 0.03, z), Vector3(CREAKY.size.x, 0.02, 0.36),
			PLANK if k % 2 == 0 else PLANK.darkened(0.15))


## The library with its shelves and table, and the Director's office with its desk.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, LIBRARY_X, 0, [LIBRARY_DOOR_X], INSIDE)
	_build.wall("z", LIBRARY_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	_build.wall("x", BACK_Z, OFFICE_X, HALF_X, 0, [OFFICE_DOOR_X], INSIDE)
	_build.wall("z", OFFICE_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	var book_colors: Array[Color] = [Color(0.7, 0.15, 0.15), Color(0.15, 0.3, 0.7), Color(0.2, 0.55, 0.25),
		Color(0.8, 0.65, 0.2)]
	for x: float in [-10.5, -8.0, -5.5]:
		_build.box(Vector3(x, FLOOR_TOP + 1.0, -HALF_Z + 0.35), Vector3(2.2, 2.0, 0.5), WOOD)
		for shelf in 4:
			_build.mesh_box(Vector3(x, FLOOR_TOP + 0.35 + shelf * 0.45, -HALF_Z + 0.61), Vector3(2.0, 0.3, 0.02),
				book_colors[(shelf + int(x)) % book_colors.size()])
	_build.box(Vector3(-7.5, FLOOR_TOP + 0.38, -5.0), Vector3(2.4, 0.76, 1.1), WOOD)
	_build.box(Vector3(8.5, FLOOR_TOP + 0.4, -8.3), Vector3(2.4, 0.8, 1.0), WOOD.darkened(0.2))
