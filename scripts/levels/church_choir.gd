class_name ChurchChoir
extends InfiltrationPlace

## The neighborhood chapel "Capilla del barrio" (docs/diseno/infiltracion-coro.md, step 3, decision 101): one floor on
## its lot in the city, the front to +Z. The nave has two columns of pews with an aisle down the middle, and at the
## back the choir's platform with its music stands and the cardboard organ by the west wall; behind the platform, the
## sacristy (locked) and the storeroom. The cops start in the station, where the robes are, and drive here.
## --place=choir opens it from Play. Choristers stand on the platform's spots (by the seed), Maestro Ernesto on his box
## in front of them, and the lady at the door only lets in cops in a robe (step 3b). Ernesto leads the songs
## (ChoirSinging) and the choristers watch and listen (ClubSuspicion, step 4). The comisario gives the case
## (InfiltrationCase, variant "choir") with 3 of the 6 pieces of evidence (step 5).
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const KEY_POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const COLLECTION_BOX_MODEL := preload("res://assets/models/collection_box.glb")
const LEDGER_MODEL := preload("res://assets/models/deposit_book.glb")
const RECEIPTS_MODEL := preload("res://assets/models/pawn_receipt.glb")
const NEW_CAR_MODEL := preload("res://assets/models/sports_car.glb")
## The chapel's evidence (step 5): the collection box with the false bottom (grab it), Ernesto's ledger with
## "órgano: 0" on the sacristy desk (the sacristy opens with the key in a pot in the storeroom), the back of the
## cardboard organ (photograph it), the receipts of the "organ fund" in the storeroom, the recording of two choristers
## talking about the money, and Ernesto's new car parked behind the chapel (photograph it).
const EVIDENCE_KINDS: Array[String] = ["box", "ledger", "organ", "receipts", "recording", "car"]
const BOX_STAND_AT := Vector3(3.0, 0, 9.6)
const BOX_STAND := Vector3(0.5, 0.9, 0.4)
const LEDGER_AT := Vector3(-6.0, 0.8, -9.6)
const RECEIPTS_AT := Vector3(3.4, 0.6, -9.4)
const KEY_POT_AT := Vector3(2.5, 0.66, -8.6)
const NEW_CAR_AT := Vector3(7.0, 0, -15.0)
const NEW_CAR_SIZE := Vector3(2.2, 1.1, 4.7)
const HALF_X := 12.0
const HALF_Z := 11.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway at the end of the aisle.
const ENTRANCE_X := 0.0
## The pews: one column on each side of the aisle, rows from the front toward the platform.
const PEW_XS: Array[float] = [-3.2, 3.2]
const PEW_ZS: Array[float] = [6.5, 5.0, 3.5, 2.0, 0.5, -1.0]
const PEW_SIZE := Vector3(3.6, 0.45, 0.5)
const PEW_BACK := 0.9
## The choir's platform against the back wall, low enough to step onto, and its two rows of music stands.
const PLATFORM := Rect2(-7.0, -7.5, 14.0, 3.5)
const PLATFORM_HEIGHT := 0.35
const ROW_ZS: Array[float] = [-6.7, -5.2]
const SPOTS_PER_ROW := 7
const SPOT_GAP := 1.8
## Each stand sits this far in front (+Z) of its spot.
const STAND_AHEAD := 0.6
## Where the director stands, on the floor in front of the platform, facing it (-Z).
const DIRECTOR_AT := Vector3(0, 0, -2.6)
## How many choristers sing, of the 14 spots; the rest are for the cops.
const MEMBERS := 10
## The lady at the door stands outside, by the entrance.
const DOOR_LADY_AT := Vector3(ENTRANCE_X + 1.4, 0, HALF_Z + 0.7)
## The cardboard organ along the west wall, by the platform.
const ORGAN_AT := Vector3(-11.2, 0, -3.2)
const ORGAN_SIZE := Vector3(1.2, 2.4, 2.4)
## The back rooms run along the north behind the platform: the sacristy (west, locked) and the storeroom (east).
const BACK_Z := -7.5
const ROOMS_SPLIT_X := 0.0
const SACRISTY_DOOR_X := -10.0
const STORE_DOOR_X := 10.0

const OUTSIDE := Color(0.92, 0.88, 0.78)
const INSIDE := Color(0.96, 0.94, 0.88)
const STONE := Color(0.62, 0.6, 0.58)
const WOOD := Color(0.48, 0.3, 0.18)
const PLATFORM_COLOR := Color(0.45, 0.28, 0.2)
const STAND := Color(0.15, 0.15, 0.17)
const CARDBOARD := Color(0.72, 0.56, 0.36)
const PIPE := Color(0.85, 0.75, 0.45)
const WINDOW_COLORS: Array[Color] = [Color(0.85, 0.25, 0.3), Color(0.25, 0.45, 0.9), Color(0.95, 0.8, 0.25),
	Color(0.3, 0.75, 0.4)]

var sacristy_door: FrontDoor
var ernesto: ClubMember
var door_lady: ClubDoorman
var singing: ChoirSinging
## The spots nobody took, for the cops.
var free_spots: Array[Vector3] = []
## The choristers' spots on the platform, on the floor of the platform, in the chapel's space.
var spots: Array[Vector3] = []
var _build: PlaceBuilder


func _ready() -> void:
	variant = "choir"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_nave()
	_build_platform()
	_build_back_rooms()
	sacristy_door = DOOR_SCENE.instantiate()
	sacristy_door.position = Vector3(SACRISTY_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(sacristy_door)
	_add_people()
	_add_evidence()
	place_in_city("chapel")
	start_case()


## The choir van waits on the street, out of the entrance (step 5).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


## The choristers on spots drawn with the seed, facing the nave, Maestro Ernesto on his box facing them, and the lady at
## the door.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["choir members", case_seed])
	free_spots = spots.duplicate()
	for i in MEMBERS:
		var member := ClubMember.new()
		member.name = "Member%d" % i
		member.look = "corista" if rng.randf() < 0.5 else "corista_b"
		member.next_line = rng.randi_range(0, ClubMember.TALK[member.look][1] - 1)
		add_child(member)
		member.position = free_spots.pop_at(rng.randi_range(0, free_spots.size() - 1))
		# Facing the nave (+Z).
		member.rotation.y = PI
		members.append(member)
	ernesto = ClubMember.new()
	ernesto.name = "Ernesto"
	ernesto.look = "ernesto"
	add_child(ernesto)
	ernesto.position = DIRECTOR_AT + Vector3(0, FLOOR_TOP + 0.2, 0)
	boss = ernesto
	door_lady = ClubDoorman.new()
	door_lady.name = "DoorLady"
	door_lady.look = "portera"
	door_lady.disguise_look = "chorister"
	add_child(door_lady)
	door_lady.position = DOOR_LADY_AT
	door_lady.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	door_lady.outward = global_transform.basis * Vector3.BACK
	_add_rehearsal()


## The choristers' suspicion, for a robe and singing in time, and Ernesto's songs.
func _add_rehearsal() -> void:
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = ernesto
	suspicion.boss_found_out = "ERNESTO_FOUND_OUT"
	suspicion.disguise_look = "chorister"
	suspicion.prefix = "CHOIR_"
	suspicion.inside = func(at: Vector3) -> bool:
		var local := global_transform.affine_inverse() * at
		return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF
	suspicion.in_back_room = func(at: Vector3) -> bool:
		var local := global_transform.affine_inverse() * at
		return absf(local.x) < HALF_X and local.z > -HALF_Z and local.z < BACK_Z and local.y < ROOF
	add_child(suspicion)
	singing = ChoirSinging.new()
	singing.name = "Singing"
	singing.case_seed = case_seed
	singing.ernesto = ernesto
	singing.inside = suspicion.inside
	singing.on_platform = func(at: Vector3) -> bool:
		var local := global_transform.affine_inverse() * at
		return PLATFORM.has_point(Vector2(local.x, local.z)) and local.y > FLOOR_TOP + PLATFORM_HEIGHT - 0.2 \
			and local.y < ROOF
	add_child(singing)
	suspicion.watch_singing(singing)


## The 3 pieces of evidence the seed picks (ClubEvidence) and the sacristy's key in a storeroom pot.
func _add_evidence() -> void:
	evidence = ClubEvidence.new()
	evidence.name = "Evidence"
	evidence.held_kinds.assign(["box", "ledger", "receipts"])
	evidence.talk_key = "CHOIR_TALK_%d"
	add_child(evidence)
	var pair := _talking_pair()
	var available := EVIDENCE_KINDS.duplicate()
	if pair.is_empty():
		available.erase("recording")
	evidence.kinds = ClubEvidence.draw(case_seed, available)
	var pot: KeyPot = KEY_POT_SCENE.instantiate()
	pot.name = "KeyPot"
	pot.has_key = true
	add_child(pot)
	pot.position = KEY_POT_AT
	_build.box(BOX_STAND_AT + Vector3(0, FLOOR_TOP + BOX_STAND.y / 2, 0), BOX_STAND, WOOD)
	for kind: String in evidence.kinds:
		match kind:
			"box":
				_item(kind, COLLECTION_BOX_MODEL, Vector3(0.26, 0.2, 0.18), 0.8,
					BOX_STAND_AT + Vector3(0, FLOOR_TOP + BOX_STAND.y + 0.11, 0))
			"ledger":
				_item(kind, LEDGER_MODEL, Vector3(0.22, 0.04, 0.3), 0.3, LEDGER_AT)
			"receipts":
				_item(kind, RECEIPTS_MODEL, Vector3(0.2, 0.02, 0.15), 0.1, RECEIPTS_AT)
			"organ":
				# The organ's back, toward the sacristy's door: a flap open over the bundles of cash inside.
				var back := ORGAN_AT + Vector3(0, FLOOR_TOP + ORGAN_SIZE.y / 2, -ORGAN_SIZE.z / 2 - 0.03)
				_spot(kind, back, Vector3(ORGAN_SIZE.x, ORGAN_SIZE.y, 0.06))
				_build.mesh_box(back + Vector3(0, -0.3, -0.01), Vector3(0.8, 0.8, 0.02), Color(0.15, 0.1, 0.06))
				_build.mesh_box(back + Vector3(0, -0.55, -0.03), Vector3(0.5, 0.12, 0.03), Color(0.35, 0.6, 0.35))
			"car":
				var car_spot := _spot(kind, NEW_CAR_AT + Vector3(0, NEW_CAR_SIZE.y / 2, 0), NEW_CAR_SIZE)
				var model: Node3D = NEW_CAR_MODEL.instantiate()
				model.position.y = -NEW_CAR_SIZE.y / 2
				car_spot.add_child(model)
			"recording":
				evidence.talkers.assign(pair)
				for member: ClubMember in pair:
					member.distracted = true


## A piece of evidence to grab, lying at `at`.
func _item(kind: String, model: PackedScene, size: Vector3, kg: float, at: Vector3) -> void:
	var item := ClubEvidence.make_item("Choir_" + kind, model, size, kg)
	add_child(item)
	item.position = at
	evidence.items[kind] = item


## A piece of evidence to photograph, a box of `size` around `at`.
func _spot(kind: String, at: Vector3, size: Vector3) -> ClubEvidenceSpot:
	var spot := ClubEvidenceSpot.new()
	spot.name = "Evidence_" + kind
	spot.kind = kind
	spot.photo = true
	spot.prompt_prefix = "PROMPT_CHOIR_"
	spot.evidence = evidence
	add_child(spot)
	spot.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	spot.add_child(shape)
	return spot


## Two choristers side by side in the same row (the recording's talkers), or none.
func _talking_pair() -> Array[ClubMember]:
	for first in members:
		for second in members:
			if first != second and absf(first.position.z - second.position.z) < 0.01 \
					and absf(first.position.x - second.position.x) < SPOT_GAP + 0.01:
				return [first, second]
	return []


## Floor, outer walls with the entrance, the roof, the sign and the round colored window over the door.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, STONE)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_CHAPEL"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	for i in WINDOW_COLORS.size():
		var pane := CylinderMesh.new()
		pane.top_radius = 0.35
		pane.bottom_radius = 0.35
		pane.height = 0.02
		var angle := TAU * i / WINDOW_COLORS.size()
		_build.mesh(pane, Vector3(ENTRANCE_X + cos(angle) * 0.4, ROOF + 1.6 + sin(angle) * 0.4, HALF_Z + 0.09),
			WINDOW_COLORS[i], Vector3(PI / 2, 0, 0))
	# The bell gable over the entrance, so it reads as a chapel from the street.
	_build.box(Vector3(ENTRANCE_X, ROOF + 1.6, HALF_Z), Vector3(3.0, 2.6, 0.15), OUTSIDE)
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-9.0, -4.0, 2.0, 7.5]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The pews in two columns along the aisle, each with its backrest toward the entrance.
func _build_nave() -> void:
	for x: float in PEW_XS:
		for z: float in PEW_ZS:
			_build.box(Vector3(x, FLOOR_TOP + PEW_SIZE.y / 2, z), PEW_SIZE, WOOD)
			_build.box(Vector3(x, FLOOR_TOP + PEW_BACK / 2, z + PEW_SIZE.z / 2 + 0.04),
				Vector3(PEW_SIZE.x, PEW_BACK, 0.08), WOOD.darkened(0.15))
	# The cardboard organ: a box with painted pipes on its front, facing the nave (+X).
	var organ_middle := ORGAN_AT + Vector3(0, FLOOR_TOP + ORGAN_SIZE.y / 2, 0)
	_build.box(organ_middle, ORGAN_SIZE, CARDBOARD)
	for i in 7:
		var tall := 0.8 + 0.25 * (3 - absi(i - 3))
		_build.mesh_box(Vector3(ORGAN_AT.x + ORGAN_SIZE.x / 2 + 0.01, FLOOR_TOP + 1.0 + tall / 2, ORGAN_AT.z - 0.9 + i * 0.3),
			Vector3(0.02, tall, 0.18), PIPE)


## The platform with its two rows of spots and a music stand in front of each, a step up from the nave.
func _build_platform() -> void:
	var middle := PLATFORM.get_center()
	_build.box(Vector3(middle.x, FLOOR_TOP + PLATFORM_HEIGHT / 2, middle.y),
		Vector3(PLATFORM.size.x, PLATFORM_HEIGHT, PLATFORM.size.y), PLATFORM_COLOR)
	var top := FLOOR_TOP + PLATFORM_HEIGHT
	for z: float in ROW_ZS:
		for i in SPOTS_PER_ROW:
			var at := Vector3((i - (SPOTS_PER_ROW - 1) / 2.0) * SPOT_GAP, top, z)
			spots.append(at)
			var stand := at + Vector3(0, 0, STAND_AHEAD)
			# Low enough that the sheet sits under the chorister's face.
			_build.mesh_box(stand + Vector3(0, 0.33, 0), Vector3(0.04, 0.66, 0.04), STAND)
			_build.mesh_box(stand + Vector3(0, 0.72, 0), Vector3(0.45, 0.28, 0.03), STAND)
	# The director's little box to stand on, so the choir sees the baton.
	_build.box(DIRECTOR_AT + Vector3(0, FLOOR_TOP + 0.1, 0), Vector3(0.7, 0.2, 0.7), WOOD)


## The sacristy and the storeroom behind the platform, with the sacristy's desk and cabinet and the storeroom's
## shelves.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [SACRISTY_DOOR_X, STORE_DOOR_X], INSIDE)
	_build.wall("z", ROOMS_SPLIT_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	# Sacristy: a desk and a tall cabinet.
	_build.legs(Vector3(-6.0, FLOOR_TOP, -9.6), Vector2(1.6, 0.8), 0.72, WOOD)
	_build.box(Vector3(-6.0, FLOOR_TOP + 0.74, -9.6), Vector3(1.6, 0.04, 0.8), WOOD)
	_build.box(Vector3(-2.0, FLOOR_TOP + 0.9, -10.4), Vector3(1.4, 1.8, 0.6), WOOD.darkened(0.2))
	# Storeroom: shelves along the back wall and boxes of old songbooks.
	_build.open_box(Vector3(6.0, FLOOR_TOP, -10.5), Vector3(6.0, 2.0, 0.6), "+z", WOOD)
	_build.box(Vector3(2.5, FLOOR_TOP + 0.3, -8.6), Vector3(0.8, 0.6, 0.6), CARDBOARD)
	_build.box(Vector3(3.4, FLOOR_TOP + 0.25, -9.4), Vector3(0.7, 0.5, 0.6), CARDBOARD.darkened(0.1))
