class_name GymRaid
extends Node3D

## The gym "Hierro Puro" as a place to raid (docs/diseno/allanamiento-gimnasio.md, step 1): the same hall as the
## infiltration (GymHall.build_hall) on the city's gym lot, without el Toro and his band. Six common members train on
## spots drawn with the seed and the record wall hangs on the east wall. El profe Fito walks the hall and fills the
## complaint with every dumbbell he sees on the floor and every treadmill that breaks; the stereo on the reception is
## his weak spot: E puts on his song and he gives a class to the mirror with the members, seeing nothing (step 2). Lula,
## the receptionist, jogs on treadmill 1 and tells what she saw to whoever runs beside her (step 3). The big mirror
## breaks when something hits it fast and a treadmill breaks when something heavy falls on it, each a fine. The office and the locker room are locked; their key is in the reception's till.
## Every number here is (propuesta).

signal mirror_broken
signal treadmill_broken(index: int)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const RECORD_WALL_MODEL := preload("res://assets/models/gym_record_wall.glb")
const RECORD_BAR_MODEL := preload("res://assets/models/gym_record_bar.glb")
const COACH_SCENE := preload("res://scenes/npc/gym_coach.tscn")
## Lula jogs on the first treadmill; a cop runs with her on the next one.
const LULA_TREADMILL := 0
const BESIDE_LULA := 1
const FLOOR_TOP := GymHall.FLOOR_TOP
const MEMBERS := 6
## The stereo on the reception's counter, and the till with the key next to it.
const STEREO_AT := Vector3(-1.8, FLOOR_TOP + GymHall.RECEPTION_SIZE.y, 6.3)
const TILL_ON := Vector3(-3.4, FLOOR_TOP + GymHall.RECEPTION_SIZE.y, 6.3)
## The record wall on the hall's east wall, facing the ring: the photo of the profe's "300 kg" and the bar below it.
const RECORD_WALL_AT := Vector3(GymHall.HALF_X - 0.06, 1.45, -1.0)
const RECORD_BAR_AT := Vector3(GymHall.HALF_X - 0.2, 1.05, -1.0)
## The big mirror on the back wall: something hitting it faster than MIRROR_SPEED breaks it.
const MIRROR_AT := Vector3(0, 1.3, -GymHall.HALF_Z + 0.12)
const MIRROR_SIZE := Vector3(5.6, 1.8, 0.02)
const MIRROR_SPEED := 3.0
const MIRROR_FINE := 30
## A treadmill breaks when something of TREADMILL_KG or more lands on its belt falling faster than TREADMILL_FALL.
const TREADMILL_KG := 10.0
const TREADMILL_FALL := 1.5
const TREADMILL_FINE := 20
## El profe's round, back and forth: in front of the benches, along the treadmills, down the east side and behind the
## ring. His class is in front of the mirror, facing it.
const COACH_ROUTE: Array[Vector3] = [
	Vector3(-3.5, FLOOR_TOP, 3.8), Vector3(0.0, FLOOR_TOP, 3.0), Vector3(6.8, FLOOR_TOP, 2.2),
	Vector3(6.8, FLOOR_TOP, -3.6), Vector3(-0.5, FLOOR_TOP, -3.6),
]
const CLASS_SPOT := Vector3(0, FLOOR_TOP, -6.2)
## Seeing a dumbbell on the floor, and a treadmill break.
const SAW_DUMBBELL := 5.0
const SAW_TREADMILL := 10.0
## A dumbbell lower than this is on the floor; higher than PICKED_UP it's back up.
const DUMBBELL_DOWN := FLOOR_TOP + 0.25
const PICKED_UP := 0.6
## A cop who jumps during the class dances with them: the profe likes it, once a class.
const DANCED := 5.0
const DANCE_JUMP := 2.0
## How high and fast everyone bounces in the class.
const BOUNCE := 0.25
const BOUNCE_SPEED := 6.0
## The towel bin by the east wall, a hiding spot.
const TOWEL_BIN_AT := Vector3(8.3, FLOOR_TOP, 3.2)
const TOWEL_BIN_SIZE := Vector3(0.6, 0.7, 0.6)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "behind_ring", "at": Vector3(5.4, FLOOR_TOP, -2.4), "heavy": true},
	{"id": "between_benches", "at": Vector3(-6.4, FLOOR_TOP + 0.01, 0.2), "heavy": true},
	{"id": "in_office_corner", "at": Vector3(8.2, FLOOR_TOP, -5.4), "heavy": true},
	{"id": "in_locker_room", "at": Vector3(-8.2, FLOOR_TOP, -5.4), "heavy": true},
	{"id": "behind_reception", "at": Vector3(-3.6, FLOOR_TOP, 7.3), "heavy": true},
	{"id": "by_treadmills", "at": Vector3(7.3, FLOOR_TOP, 5.6), "heavy": true},
	{"id": "on_dumbbell_rack", "at": Vector3(-8.6, FLOOR_TOP + 0.92, 1.3), "heavy": false},
	{"id": "in_towel_bin", "at": TOWEL_BIN_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "on_locker_bench", "at": Vector3(-6.5, FLOOR_TOP + 0.44, -6.0), "heavy": false},
	{"id": "on_ring_corner", "at": Vector3(GymHall.RING.end.x - 0.3, FLOOR_TOP + GymHall.RING_HEIGHT, -2.5),
		"heavy": false},
	{"id": "on_profe_desk", "at": Vector3(6.2, FLOOR_TOP + 0.8, -7.2), "heavy": false},
	{"id": "on_reception", "at": Vector3(-2.6, FLOOR_TOP + GymHall.RECEPTION_SIZE.y, 6.4), "heavy": false},
]
const DARK := Color(0.1, 0.1, 0.12)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var locker_door: FrontDoor
var till: Till
var stereo: GymStereo
var coach: FloorBoss
var lula: GymReceptionist
var complaint_bar: ProgressBar
var members: Array[ClubMember] = []
var dumbbells: Array[Grabbable] = []
var mirror_is_broken := false
var broken_treadmills: Array[int] = []
var broken_goods := 0
## Money taken off the case pay: the mirror and the treadmills.
var fines := 0
## Same seed, same members.
@export var case_seed := 0
var _build: PlaceBuilder
var _cracks: Node3D
## Dumbbells the profe already saw on the floor (until they're picked up again).
var _seen_down := {}
## Cops who danced in this class, and where the members stood before it.
var _dancers := {}
var _before_class := {}
var _beat := 0.0
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	GymHall.build_hall(_build, $Built)
	_build_extras()
	office_door = _door(GymHall.OFFICE_DOOR_X)
	locker_door = _door(GymHall.LOCKERS_DOOR_X)
	_place_members()
	_place_dumbbells()
	_watch_mirror()
	_watch_treadmills()
	_place_coach()
	_place_lula()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("gym")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "gym", car)


## The stereo and the till on the reception, the record wall with its bar and the towel bin.
func _build_extras() -> void:
	stereo = GymStereo.new()
	stereo.position = STEREO_AT
	stereo.rotation.y = PI
	add_child(stereo)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_GYM"
	add_child(till)
	_model(RECORD_WALL_MODEL, RECORD_WALL_AT, -PI / 2)
	_model(RECORD_BAR_MODEL, RECORD_BAR_AT, PI / 2)
	_build.open_box(TOWEL_BIN_AT, TOWEL_BIN_SIZE, "top", Color(0.3, 0.5, 0.8))


## A locked door in the back wall, its middle at x.
func _door(x: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(x - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, GymHall.BACK_Z)
	add_child(door)
	return door


## The common members on training spots drawn with the seed, like the infiltration's (GymHall._add_people).
func _place_members() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["gym raid members", case_seed])
	var free := GymHall.TRAIN_SPOTS.duplicate()
	for i: int in [BESIDE_LULA, LULA_TREADMILL]:
		free.remove_at(i)
	for i in MEMBERS:
		var member := ClubMember.new()
		member.name = "Member%d" % i
		member.look = "gym_member" if rng.randf() < 0.5 else "gym_member_b"
		member.next_line = rng.randi_range(0, ClubMember.TALK[member.look][1] - 1)
		add_child(member)
		var spot: Vector3 = free.pop_at(rng.randi_range(0, free.size() - 1))
		member.position = spot + Vector3(0, FLOOR_TOP, 0)
		var facing := Vector3.BACK if spot.y > 0.0 else Vector3(0, 0, 1.0) - spot
		member.rotation.y = atan2(-facing.x, -facing.z)
		members.append(member)


## The dumbbells on the rack (the profe hates seeing them on the floor, step 2).
func _place_dumbbells() -> void:
	for i in GymHall.DUMBBELLS.size():
		var dumbbell := ClubEvidence.make_item("Dumbbell%d" % i, GymHall.DUMBBELL_MODEL, GymHall.DUMBBELL_SIZE,
			GymRoutine.DUMBBELL_KG)
		dumbbell.add_to_group("gym_dumbbells")
		add_child(dumbbell)
		dumbbell.position = GymHall.DUMBBELLS[i] + Vector3(0, FLOOR_TOP, 0)
		dumbbell.rotation.y = PI / 2
		dumbbells.append(dumbbell)


## An area just in front of the mirror: a prop flying into it fast enough breaks it.
func _watch_mirror() -> void:
	var area := _area(MIRROR_AT + Vector3(0, 0, 0.2), Vector3(MIRROR_SIZE.x, MIRROR_SIZE.y, 0.4))
	area.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > MIRROR_SPEED:
			break_mirror())


## Cracks the mirror, once: a fine and the cracks over the glass.
func break_mirror() -> void:
	if mirror_is_broken:
		return
	mirror_is_broken = true
	broken_goods += 1
	fines += MIRROR_FINE
	_cracks = Node3D.new()
	_cracks.name = "Cracks"
	$Built.add_child(_cracks)
	var material := StandardMaterial3D.new()
	material.albedo_color = DARK
	for i in 9:
		var turn := i * TAU / 9.0 + 0.2
		var length := 0.5 + (i % 3) * 0.25
		var crack := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(length, 0.025, 0.01)
		mesh.material = material
		crack.mesh = mesh
		crack.position = MIRROR_AT + Vector3(cos(turn) * length / 2, sin(turn) * length / 2, 0.02)
		crack.rotation.z = turn
		_cracks.add_child(crack)
	_say(MIRROR_AT + Vector3(0, 0.6, 0.8), "GYM_MIRROR_BROKEN")
	mirror_broken.emit()


## An area over each treadmill's belt: something heavy landing on it breaks it.
func _watch_treadmills() -> void:
	for i in GymHall.TREADMILLS.size():
		var belt := GymHall.TREADMILLS[i] + Vector3(0, FLOOR_TOP + GymHall.TREADMILL_BELT + 0.3, 0)
		var area := _area(belt, Vector3(GymHall.TREADMILL_SIZE.x, 0.6, GymHall.TREADMILL_SIZE.z))
		area.body_entered.connect(func(body: Node3D) -> void:
			if body is RigidBody3D and (body as RigidBody3D).mass >= TREADMILL_KG \
					and -(body as RigidBody3D).linear_velocity.y > TREADMILL_FALL:
				break_treadmill(i))


## Breaks treadmill `index`, once: a fine, a burnt belt and smoke.
func break_treadmill(index: int) -> void:
	if broken_treadmills.has(index):
		return
	broken_treadmills.append(index)
	broken_goods += 1
	fines += TREADMILL_FINE
	var at := GymHall.TREADMILLS[index]
	_build.mesh_box(at + Vector3(0, FLOOR_TOP + GymHall.TREADMILL_BELT + 0.01, 0),
		Vector3(GymHall.TREADMILL_SIZE.x - 0.1, 0.01, GymHall.TREADMILL_SIZE.z - 0.2), DARK)
	_say(at + Vector3(0, 1.4, 0), "GYM_TREADMILL_BROKEN")
	treadmill_broken.emit(index)


## Whether treadmill `index` still works (the profe's member on it, Lula's run, step 3).
func treadmill_works(index: int) -> bool:
	return not broken_treadmills.has(index)


func _area(center: Vector3, size: Vector3) -> Area3D:
	var area := Area3D.new()
	area.position = center
	area.collision_layer = 0
	area.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	return area


## A floating line over `at` for a few seconds.
func _say(at: Vector3, key: String) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(3.0).timeout.connect(label.queue_free)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look


## El profe on his round, the class at the stereo, what he notices and the complaint bar.
func _place_coach() -> void:
	coach = COACH_SCENE.instantiate()
	coach.route = COACH_ROUTE
	coach.printer_spot = CLASS_SPOT
	coach.printer = stereo
	add_child(coach)
	coach.fix_facing = to_global(GymRaid.MIRROR_AT)
	coach.start_at(0)
	for door: FrontDoor in [office_door, locker_door]:
		door.broken.connect(coach.door_broken)
	till.opened.connect(func(at: Vector3) -> void: coach.saw(at, FloorBoss.SAW_TILL))
	mirror_broken.connect(func() -> void: coach.saw(to_global(MIRROR_AT), FloorBoss.SAW_BREAK, "COACH_MIRROR"))
	treadmill_broken.connect(func(index: int) -> void:
		coach.saw(to_global(GymHall.TREADMILLS[index] + Vector3.UP * 0.6), SAW_TREADMILL, "COACH_TREADMILL"))
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
	coach.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Lula on her treadmill, looking out the window like everyone who runs (her model already faces +z).
func _place_lula() -> void:
	lula = GymReceptionist.new()
	lula.name = "Lula"
	lula.position = GymHall.TREADMILLS[LULA_TREADMILL] + Vector3(0, FLOOR_TOP + GymHall.TREADMILL_BELT, -0.5)
	add_child(lula)


## Every cop running on the treadmill beside Lula's, if it still works.
func _watch_runners(delta: float) -> void:
	if not lula:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var on_it := GymHall.treadmill_index(to_local(cop.global_position)) == BESIDE_LULA
		lula.run_beside(cop, cop.is_running and on_it and treadmill_works(BESIDE_LULA), delta)


## Whether the class is on: the song plays and the profe is at the mirror.
func in_class() -> bool:
	return coach != null and coach.is_fixing()


func _physics_process(delta: float) -> void:
	if not coach:
		return
	_watch_dumbbells()
	_watch_runners(delta)
	if in_class():
		_class(delta)
	elif not _before_class.is_empty():
		_end_class()


## Every dumbbell on the floor that the profe sees, once until it's picked up.
func _watch_dumbbells() -> void:
	for dumbbell: Grabbable in dumbbells:
		if not is_instance_valid(dumbbell):
			continue
		var height := to_local(dumbbell.global_position).y
		if height > PICKED_UP:
			_seen_down.erase(dumbbell)
		elif height < DUMBBELL_DOWN and not dumbbell.is_held() and not _seen_down.has(dumbbell) \
				and coach.saw(dumbbell.global_position + Vector3.UP * 0.1, SAW_DUMBBELL, "COACH_DUMBBELL"):
			_seen_down[dumbbell] = true


## The class: the members turn to the mirror and everyone bounces; a cop who jumps along dances with them.
func _class(delta: float) -> void:
	if _before_class.is_empty():
		_dancers.clear()
		for member: ClubMember in members:
			_before_class[member] = member.transform
			member.rotation.y = 0.0
	_beat += delta
	var bounce := absf(sin(_beat * BOUNCE_SPEED)) * BOUNCE
	for member: ClubMember in members:
		member.position.y = (_before_class[member] as Transform3D).origin.y + bounce
	(coach.get_node("Model") as Node3D).position.y = bounce
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not _dancers.has(cop) and cop.velocity.y > DANCE_JUMP and _is_inside(cop.global_position):
			_dancers[cop] = true
			coach.praise(DANCED, "COACH_DANCE")


## Back to training where they were.
func _end_class() -> void:
	for member: ClubMember in _before_class:
		if is_instance_valid(member):
			member.transform = _before_class[member]
	_before_class.clear()
	(coach.get_node("Model") as Node3D).position.y = 0.0


func _is_inside(at: Vector3) -> bool:
	var local := to_local(at)
	return absf(local.x) < GymHall.HALF_X and absf(local.z) < GymHall.HALF_Z and local.y < GymHall.ROOF
