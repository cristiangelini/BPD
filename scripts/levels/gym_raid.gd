class_name GymRaid
extends Node3D

## The gym "Hierro Puro" as a place to raid (docs/diseno/allanamiento-gimnasio.md, step 1): the same hall as the
## infiltration (GymHall.build_hall) on the city's gym lot, without el Toro and his band. Six common members train on
## spots drawn with the seed, the stereo waits on the reception (the profe's distraction, step 2) and the record wall
## hangs on the east wall. The big mirror breaks when something hits it fast and a treadmill breaks when something
## heavy falls on it, each a fine. The office and the locker room are locked; their key is in the reception's till.
## Every number here is (propuesta).

signal mirror_broken
signal treadmill_broken(index: int)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const STEREO_MODEL := preload("res://assets/models/gym_stereo.glb")
const RECORD_WALL_MODEL := preload("res://assets/models/gym_record_wall.glb")
const RECORD_BAR_MODEL := preload("res://assets/models/gym_record_bar.glb")
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
	_model(STEREO_MODEL, STEREO_AT, PI)
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
