class_name GymHall
extends InfiltrationPlace

## The gym "Hierro Puro" (docs/diseno/infiltracion-gimnasio.md, step 2, decision 172): one floor on the city's gym
## lot, the front to +Z. The reception counter by the entrance, four treadmills facing the front window, the weights
## (two benches and a rack of dumbbells) along the west wall, the boxing ring and two punching bags in the middle and,
## behind, the locker room (west), a mirror wall where el Toro calls the routine and his office (east, locked). The
## cops start in the station, where the gym disguises are, and drive here. --place=gym opens it from Play.
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const TREADMILL_MODEL := preload("res://assets/models/gym_treadmill.glb")
const BENCH_MODEL := preload("res://assets/models/gym_bench.glb")
const RACK_MODEL := preload("res://assets/models/gym_dumbbell_rack.glb")
const BAG_MODEL := preload("res://assets/models/gym_punching_bag.glb")
const LOCKERS_MODEL := preload("res://assets/models/station_lockers.glb")
const DUMBBELL_MODEL := preload("res://assets/models/gym_dumbbell.glb")
const KEY_POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const BAG_SCENE := preload("res://assets/models/gym_bag.glb")
const NOTEBOOK_MODEL := preload("res://assets/models/deposit_book.glb")
const SAFE_MODEL := preload("res://assets/models/gym_safe_weight.glb")
const SHAKE_MODEL := preload("res://assets/models/gym_shake.glb")
const HALF_X := 9.0
const HALF_Z := 8.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway in the middle of the front wall, and the reception counter west of it.
const ENTRANCE_X := 0.0
const RECEPTION_AT := Vector3(-2.6, 0, 6.3)
const RECEPTION_SIZE := Vector3(2.6, 1.1, 0.6)
## The treadmills in a row facing the front window (+Z), their belts TREADMILL_BELT up.
const TREADMILLS: Array[Vector3] = [Vector3(2.2, 0, 5.6), Vector3(3.4, 0, 5.6), Vector3(4.6, 0, 5.6),
	Vector3(5.8, 0, 5.6)]
const TREADMILL_SIZE := Vector3(0.8, 0.15, 1.8)
const TREADMILL_BELT := 0.17
## The weights along the west wall: the benches (lengthwise along Z) and the rack of dumbbells facing the hall.
const BENCHES: Array[Vector3] = [Vector3(-6.2, 0, -1.6), Vector3(-6.2, 0, 2.0)]
const RACK_AT := Vector3(-8.6, 0, 0.2)
## The boxing ring (RING_HEIGHT up, its ropes around) and the punching bags.
const RING := Rect2(0.6, -2.8, 4.0, 4.0)
const RING_HEIGHT := 0.5
const BAGS: Array[Vector3] = [Vector3(-2.6, 0, -2.2), Vector3(-1.0, 0, -2.2)]
## The back rooms, behind the wall at BACK_Z: the locker room west of LOCKERS_X (its door at LOCKERS_DOOR_X), the
## office east of OFFICE_X (its locked door at OFFICE_DOOR_X) and the mirror wall between them.
const BACK_Z := -4.5
const LOCKERS_X := -3.0
const LOCKERS_DOOR_X := -6.0
const OFFICE_X := 3.0
const OFFICE_DOOR_X := 6.0
## Where el Toro stands to call the routine, in front of the mirror looking at the hall (step 3).
const TORO_AT := Vector3(0, 0, -6.2)
## Where the members train when there's no routine: on the treadmills, by the benches and the rack, at the bags and
## around the ring (step 2b picks them with the seed).
const TRAIN_SPOTS: Array[Vector3] = [
	Vector3(2.2, TREADMILL_BELT, 5.1), Vector3(3.4, TREADMILL_BELT, 5.1), Vector3(4.6, TREADMILL_BELT, 5.1),
	Vector3(5.8, TREADMILL_BELT, 5.1), Vector3(-5.4, 0, -1.6), Vector3(-5.4, 0, 2.0), Vector3(-7.6, 0, 0.2),
	Vector3(-2.6, 0, -1.4), Vector3(-1.0, 0, -1.4), Vector3(-0.2, 0, 0.0), Vector3(5.4, 0, -0.8),
	Vector3(-1.6, 0, 2.6),
]
## The dumbbells for the routine's weight, lying on the rack.
const DUMBBELLS: Array[Vector3] = [Vector3(-8.6, 1.0, -0.5), Vector3(-8.6, 1.0, 0.0), Vector3(-8.6, 1.0, 0.4),
	Vector3(-8.6, 1.0, 0.9)]
const DUMBBELL_SIZE := Vector3(0.34, 0.14, 0.14)
## The 6 pieces of evidence (the seed picks 3, ClubEvidence) and where they are: the notebook of the "lifted" safes
## on the office's desk, the whiteboard with the next job on the office's east wall (a photo), the stolen safe painted
## as a 40 kg weight on the mat (it counts once lifted SAFE_LIFT, which takes two cops), the video of two members
## talking about the job, el Toro's shake with a map inside on a corner of the ring, and the moving truck's ticket in a
## locker (E). The office key is in a gym bag on the locker room's bench.
const EVIDENCE_KINDS: Array[String] = ["notebook", "whiteboard", "safe", "recording", "shake", "ticket"]
const NOTEBOOK_AT := Vector3(6.2, FLOOR_TOP + 0.84, -7.2)
const WHITEBOARD_AT := Vector3(HALF_X - 0.2, 1.5, -6.2)
const SAFE_AT := Vector3(-6.4, FLOOR_TOP + 0.26, 0.2)
const SAFE_KG := 40.0
const SAFE_LIFT := 0.25
const SHAKE_AT := Vector3(4.3, FLOOR_TOP + 0.65, -2.5)
const TICKET_AT := Vector3(-4.2, FLOOR_TOP + 1.2, -7.35)
const KEY_BAG_AT := Vector3(-6.0, FLOOR_TOP + 0.44, -6.0)
## Two members this close talk about the job (the recording).
const TALK_PAIR := 2.6
## How many members train, of the 12 spots; the rest are for the cops.
const MEMBERS := 9
## The receptionist stands between the counter and the front wall, looking at the entrance.
const RECEPTIONIST_AT := Vector3(-1.9, 0, 7.2)

const OUTSIDE := Color(0.4, 0.75, 0.4)
const INSIDE := Color(0.88, 0.9, 0.88)
const FLOOR := Color(0.18, 0.19, 0.21)
const MAT := Color(0.12, 0.3, 0.6)
const RING_BLUE := Color(0.15, 0.3, 0.75)
const ROPE := Color(0.85, 0.12, 0.15)
const STEEL := Color(0.6, 0.62, 0.66)
const WOOD := Color(0.48, 0.3, 0.18)
const MIRROR := Color(0.7, 0.82, 0.92)

var office_door: FrontDoor
## The training spots no member took, for the cops (step 3).
var free_spots: Array[Vector3] = []
var toro: ClubMember
var doorman: ClubDoorman
## El Toro's routine (step 3).
var routine: GymRoutine
var _build: PlaceBuilder


func _ready() -> void:
	variant = "gym"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_machines()
	_build_ring()
	_build_back_rooms()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)
	_add_people()
	_add_evidence()
	place_in_city("gym")
	start_case()


## El Toro runs off from the street, out of the entrance (step 5).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


## Whether a world position is inside the gym.
func is_inside(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is in el Toro's office.
func in_back_room(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > OFFICE_X and local.x < HALF_X and local.z > -HALF_Z and local.z < BACK_Z and local.y < ROOF


## Whether a world position is in the locker room.
func in_locker_room(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > -HALF_X and local.x < LOCKERS_X and local.z > -HALF_Z and local.z < BACK_Z and local.y < ROOF


## The treadmill a world position stands on, or -1.
func treadmill_at(at: Vector3) -> int:
	var local := global_transform.affine_inverse() * at
	for i in TREADMILLS.size():
		var middle := TREADMILLS[i]
		if absf(local.x - middle.x) < TREADMILL_SIZE.x / 2 and absf(local.z - middle.z) < TREADMILL_SIZE.z / 2 \
				and local.y > FLOOR_TOP + TREADMILL_BELT - 0.1 and local.y < ROOF:
			return i
	return -1


## The members on training spots drawn with the seed (on a treadmill looking out the window, elsewhere looking at the
## hall), el Toro in front of the mirror looking at them, the receptionist, their suspicion, the dumbbells on the rack and
## el Toro's routine.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["gym members", case_seed])
	free_spots = TRAIN_SPOTS.duplicate()
	for i in MEMBERS:
		var member := ClubMember.new()
		member.name = "Member%d" % i
		member.look = "socio" if rng.randf() < 0.5 else "socio_b"
		member.next_line = rng.randi_range(0, ClubMember.TALK[member.look][1] - 1)
		add_child(member)
		var spot: Vector3 = free_spots.pop_at(rng.randi_range(0, free_spots.size() - 1))
		member.position = spot + Vector3(0, FLOOR_TOP, 0)
		var facing := Vector3.BACK if spot.y > 0.0 else Vector3(0, 0, 1.0) - spot
		member.rotation.y = atan2(-facing.x, -facing.z)
		members.append(member)
	toro = ClubMember.new()
	toro.name = "Toro"
	toro.look = "toro"
	add_child(toro)
	toro.position = TORO_AT + Vector3(0, FLOOR_TOP, 0)
	toro.rotation.y = PI
	boss = toro
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	doorman.look = "recepcionista"
	doorman.disguise_look = "gym"
	add_child(doorman)
	doorman.position = RECEPTIONIST_AT + Vector3(0, FLOOR_TOP, 0)
	doorman.rotation.y = PI / 2
	doorman.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = toro
	suspicion.boss_found_out = "TORO_FOUND_OUT"
	suspicion.disguise_look = "gym"
	suspicion.prefix = "GYM_"
	suspicion.inside = is_inside
	suspicion.in_back_room = in_back_room
	add_child(suspicion)
	for i in DUMBBELLS.size():
		var dumbbell := ClubEvidence.make_item("Dumbbell%d" % i, DUMBBELL_MODEL, DUMBBELL_SIZE, GymRoutine.DUMBBELL_KG)
		dumbbell.add_to_group("gym_dumbbells")
		add_child(dumbbell)
		dumbbell.position = DUMBBELLS[i] + Vector3(0, FLOOR_TOP, 0)
		dumbbell.rotation.y = PI / 2
	routine = GymRoutine.new()
	routine.name = "Routine"
	routine.case_seed = case_seed
	routine.toro = toro
	routine.members = members
	routine.inside = is_inside
	routine.treadmill_at = treadmill_at
	add_child(routine)
	suspicion.watch_routine(routine)


## The 3 pieces of evidence the seed picks (ClubEvidence) and the office key in a gym bag in the locker room.
func _add_evidence() -> void:
	evidence = ClubEvidence.new()
	evidence.name = "Evidence"
	evidence.held_kinds.assign(["notebook", "shake"])
	evidence.talk_key = "GYM_TALK_%d"
	add_child(evidence)
	var pair := _talking_pair()
	var available := EVIDENCE_KINDS.duplicate()
	if pair.is_empty():
		available.erase("recording")
	evidence.kinds = ClubEvidence.draw(case_seed, available)
	var bag: KeyPot = KEY_POT_SCENE.instantiate()
	bag.name = "KeyBag"
	bag.has_key = true
	bag.prompt = "PROMPT_GYM_BAG"
	add_child(bag)
	bag.position = KEY_BAG_AT
	bag.get_node("Pot").hide()
	bag.get_node("Plant").hide()
	bag.add_child(BAG_SCENE.instantiate())
	for kind: String in evidence.kinds:
		match kind:
			"notebook":
				_item(kind, NOTEBOOK_MODEL, Vector3(0.22, 0.04, 0.3), 0.3, NOTEBOOK_AT)
			"shake":
				_item(kind, SHAKE_MODEL, Vector3(0.11, 0.24, 0.11), 0.6, SHAKE_AT)
			"safe":
				_item(kind, SAFE_MODEL, Vector3(0.5, 0.5, 0.5), SAFE_KG, SAFE_AT)
			"whiteboard":
				_spot(kind, WHITEBOARD_AT, Vector3(0.1, 1.0, 1.6), true)
				_build.mesh_box(WHITEBOARD_AT + Vector3(0.06, 0, 0), Vector3(0.02, 1.0, 1.6), Color(0.97, 0.97, 0.97))
				# The plan: a safe drawn as a box, an arrow to a truck, and the strong arms that carry it.
				_build.mesh_box(WHITEBOARD_AT + Vector3(0.04, 0.15, -0.45), Vector3(0.01, 0.3, 0.3), Color(0.1, 0.1, 0.1))
				_build.mesh_box(WHITEBOARD_AT + Vector3(0.04, 0.15, 0.05), Vector3(0.01, 0.04, 0.5), Color(0.85, 0.1, 0.1))
				_build.mesh_box(WHITEBOARD_AT + Vector3(0.04, 0.1, 0.5), Vector3(0.01, 0.25, 0.4), Color(0.15, 0.3, 0.8))
				_build.mesh_box(WHITEBOARD_AT + Vector3(0.04, -0.3, 0.0), Vector3(0.01, 0.04, 1.2), Color(0.1, 0.1, 0.1))
			"ticket":
				_spot(kind, TICKET_AT, Vector3(0.5, 0.6, 0.2), false)
				_build.mesh_box(TICKET_AT + Vector3(0, -0.15, 0.06), Vector3(0.14, 0.08, 0.01), Color(1.0, 0.85, 0.3))
			"recording":
				evidence.talkers.assign(pair)
				for member: ClubMember in pair:
					member.distracted = true


## A piece of evidence to grab, lying at `at`.
func _item(kind: String, model: PackedScene, size: Vector3, kg: float, at: Vector3) -> void:
	var item := ClubEvidence.make_item("Gym_" + kind, model, size, kg)
	add_child(item)
	item.position = at
	evidence.items[kind] = item


## A piece of evidence that stays put, a box of `size` around `at`: photographed, or searched with E.
func _spot(kind: String, at: Vector3, size: Vector3, photo: bool) -> void:
	var spot := ClubEvidenceSpot.new()
	spot.name = "Evidence_" + kind
	spot.kind = kind
	spot.photo = photo
	spot.prompt_prefix = "PROMPT_GYM_"
	spot.evidence = evidence
	add_child(spot)
	spot.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	spot.add_child(shape)


## Two members training by each other (the recording's pair), or none.
func _talking_pair() -> Array[ClubMember]:
	for first in members:
		for second in members:
			if first != second and first.position.distance_to(second.position) < TALK_PAIR:
				return [first, second]
	return []


## Host: the painted safe counts once it's off the mat, which takes two cops (40 kg); the coins inside jingle.
func _physics_process(_delta: float) -> void:
	var safe: Node3D = evidence.items.get("safe") if evidence else null
	if not multiplayer.is_server() or not safe or evidence.done.has("safe"):
		return
	if (global_transform.affine_inverse() * safe.global_position).y > SAFE_AT.y + SAFE_LIFT:
		evidence.mark("safe")


## Floor, outer walls with the entrance and the window, the roof, the sign, the reception and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	# The front window over the treadmills, inside and out.
	for side: float in [-1.0, 1.0]:
		_build.mesh_box(Vector3(4.0, 1.5, HALF_Z + side * 0.12), Vector3(5.6, 1.4, 0.02), MIRROR)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_GYM"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	_build.box(RECEPTION_AT + Vector3(0, FLOOR_TOP + RECEPTION_SIZE.y / 2, 0), RECEPTION_SIZE, WOOD)
	_build.mesh_box(RECEPTION_AT + Vector3(0, FLOOR_TOP + RECEPTION_SIZE.y + 0.01, 0),
		Vector3(RECEPTION_SIZE.x + 0.1, 0.02, RECEPTION_SIZE.z + 0.1), OUTSIDE)
	for x: float in [-5.0, 0.0, 5.0]:
		for z: float in [-6.2, -1.5, 3.5]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The treadmills, the benches, the rack of dumbbells and the punching bags, each a model on its collision box.
func _build_machines() -> void:
	for at: Vector3 in TREADMILLS:
		_machine(TREADMILL_MODEL, at, 0.0)
		_build.shape(_build.body(at + Vector3(0, FLOOR_TOP + TREADMILL_SIZE.y / 2, 0)), TREADMILL_SIZE)
		_build.shape(_build.body(at + Vector3(0, FLOOR_TOP + 0.7, 0.85)), Vector3(0.8, 1.4, 0.15))
	for at: Vector3 in BENCHES:
		_machine(BENCH_MODEL, at, 0.0)
		_build.shape(_build.body(at + Vector3(0, FLOOR_TOP + 0.25, 0)), Vector3(0.4, 0.5, 1.2))
	_machine(RACK_MODEL, RACK_AT, PI / 2)
	_build.shape(_build.body(RACK_AT + Vector3(0, FLOOR_TOP + 0.45, 0)), Vector3(0.5, 0.9, 1.8))
	_build.slab(-8.0, -4.4, -3.0, 3.6, FLOOR_TOP + 0.01, MAT)
	for at: Vector3 in BAGS:
		_machine(BAG_MODEL, at, 0.0)
		_build.shape(_build.body(at + Vector3(0, FLOOR_TOP + 1.15, 0)), Vector3(0.44, 1.1, 0.44))


## The boxing ring: its platform, a post at each corner and three ropes around.
func _build_ring() -> void:
	var middle := Vector3(RING.get_center().x, 0, RING.get_center().y)
	_build.box(middle + Vector3(0, FLOOR_TOP + RING_HEIGHT / 2, 0), Vector3(RING.size.x, RING_HEIGHT, RING.size.y),
		RING_BLUE)
	var top := FLOOR_TOP + RING_HEIGHT
	for corner: Vector2 in [RING.position, Vector2(RING.end.x, RING.position.y), RING.end,
			Vector2(RING.position.x, RING.end.y)]:
		_build.mesh_box(Vector3(corner.x, top + 0.6, corner.y), Vector3(0.1, 1.2, 0.1), STEEL)
	for k in 3:
		var y := top + 0.35 + k * 0.35
		for z: float in [RING.position.y, RING.end.y]:
			_build.mesh_box(Vector3(middle.x, y, z), Vector3(RING.size.x, 0.03, 0.03), ROPE)
		for x: float in [RING.position.x, RING.end.x]:
			_build.mesh_box(Vector3(x, y, middle.z), Vector3(0.03, 0.03, RING.size.y), ROPE)


## The locker room with its lockers and bench, the mirror wall with the gym's motto, and el Toro's office with its desk.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, LOCKERS_X, 0, [LOCKERS_DOOR_X], INSIDE)
	_build.wall("z", LOCKERS_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	_build.wall("x", BACK_Z, OFFICE_X, HALF_X, 0, [OFFICE_DOOR_X], INSIDE)
	_build.wall("z", OFFICE_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	for x: float in [-7.4, -4.8]:
		_machine(LOCKERS_MODEL, Vector3(x, 0, -7.65), 0.0)
		_build.shape(_build.body(Vector3(x, FLOOR_TOP + 0.95, -7.65)), Vector3(2.4, 1.9, 0.5))
	_build.box(Vector3(-6.0, FLOOR_TOP + 0.22, -6.0), Vector3(2.0, 0.44, 0.45), WOOD)
	_build.mesh_box(Vector3(0, 1.3, -HALF_Z + 0.12), Vector3(5.6, 1.8, 0.02), MIRROR)
	var motto := Label3D.new()
	motto.text = "GYM_MOTTO"
	motto.font_size = 48
	motto.pixel_size = 0.01
	motto.outline_size = 16
	motto.modulate = Color(1, 0.3, 0.25)
	motto.position = Vector3(0, 2.4, -HALF_Z + 0.15)
	$Built.add_child(motto)
	_build.box(Vector3(6.6, FLOOR_TOP + 0.4, -7.2), Vector3(2.0, 0.8, 0.9), WOOD)


## A machine's model at `at` on the floor, turned `turn` about Y.
func _machine(model: PackedScene, at: Vector3, turn: float) -> void:
	var machine: Node3D = model.instantiate()
	machine.position = at + Vector3(0, FLOOR_TOP, 0)
	machine.rotation.y = turn
	$Built.add_child(machine)
