class_name AuctionHouse
extends InfiltrationPlace

## The auction house "El Martillo de Oro" (docs/diseno/infiltracion-subasta.md, step 2, decision 177): one floor on its
## own city lot, the front to +Z. The doorman stands inside the entrance and only lets millionaires through; the
## auction hall with Don Martillo behind his podium at the back and rows of chairs facing him, and the gallery east of
## it with the paintings for sale on its walls; behind, the storeroom with its crates (from the hall) and Don
## Martillo's locked office (from the gallery). The buyers sit in the chairs or look at the paintings, drawn with the
## seed. The whole house is for millionaires only. The cops start in the station, where the disguises are, and drive
## here. --place=auction opens it from Play. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const KEY_POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const ORIGINAL_MODEL := preload("res://assets/models/original_painting.glb")
const EASEL_MODEL := preload("res://assets/models/auction_easel.glb")
const FORGERY_MODEL := preload("res://assets/models/forgery.glb")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway in the middle of the front wall, into the hall.
const ENTRANCE_X := 0.0
## The wall between the hall (west) and the gallery (east) at GALLERY_X, with its doorway at GALLERY_DOOR_Z.
const GALLERY_X := 4.0
const GALLERY_DOOR_Z := 5.0
## The back wall at BACK_Z: the storeroom's doorway, from the hall, at STORE_DOOR_X and the office's locked door, from
## the gallery, at OFFICE_DOOR_X. Behind, west of GALLERY_X the storeroom and east of it the office.
const BACK_Z := 0.0
const STORE_DOOR_X := -9.0
const OFFICE_DOOR_X := 8.0
## Don Martillo's podium at the back of the hall, him behind it facing the chairs (+Z), and the easel of the lots.
const PODIUM_AT := Vector3(-4.0, 0, 1.6)
const MARTILLO_AT := Vector3(-4.0, 0, 0.9)
const EASEL_AT := Vector3(-1.2, 0, 1.4)
## The chairs, in rows facing the podium; a buyer in one sits on it, SEAT up.
const CHAIRS: Array[Vector3] = [
	Vector3(-9.5, 0, 4.5), Vector3(-7.5, 0, 4.5), Vector3(-5.5, 0, 4.5), Vector3(-3.5, 0, 4.5), Vector3(-1.5, 0, 4.5),
	Vector3(-9.5, 0, 6.0), Vector3(-7.5, 0, 6.0), Vector3(-5.5, 0, 6.0), Vector3(-3.5, 0, 6.0), Vector3(-1.5, 0, 6.0),
	Vector3(-9.5, 0, 7.5), Vector3(-7.5, 0, 7.5), Vector3(-5.5, 0, 7.5), Vector3(-3.5, 0, 7.5), Vector3(-1.5, 0, 7.5),
]
const SEAT := BidSeat.SEAT
## Where the buyers can be, facing where they look: [position, turn] (turn 0 faces -Z, the podium). The first ones are
## chairs (they sit there); the seed picks BUYERS of them.
const SPOTS: Array[Array] = [
	[CHAIRS[0], 0.0], [CHAIRS[2], 0.0], [CHAIRS[3], 0.0], [CHAIRS[6], 0.0], [CHAIRS[9], 0.0], [CHAIRS[11], 0.0],
	[CHAIRS[13], 0.0], [Vector3(10.0, 0, 7.0), -PI / 2], [Vector3(7.0, 0, 2.0), 0.0], [Vector3(8.0, 0, 8.0), PI],
	[Vector3(-6.0, 0, -5.0), -PI / 2],
]
const BUYERS := 8
## The doorman by the entrance.
const DOORKEEPER_AT := Vector3(ENTRANCE_X + 1.2, 0, HALF_Z - 1.2)
## The gallery's paintings: [middle on its wall, size, the wall's inward direction], and the pedestal.
const PAINTINGS: Array[Array] = [
	[Vector3(HALF_X - 0.1, 1.7, 3.0), Vector2(1.6, 1.2), Vector3.LEFT],
	[Vector3(HALF_X - 0.1, 1.6, 7.0), Vector2(1.2, 1.6), Vector3.LEFT],
	[Vector3(6.5, 1.7, HALF_Z - 0.1), Vector2(1.4, 1.0), Vector3.FORWARD],
	[Vector3(10.0, 1.6, HALF_Z - 0.1), Vector2(1.0, 1.3), Vector3.FORWARD],
	[Vector3(9.5, 1.7, BACK_Z + 0.1), Vector2(1.6, 1.0), Vector3.BACK],
]
const PEDESTAL_AT := Vector3(8.0, 0, 5.0)
## The evidence (step 5), 3 of these by the seed: the stolen original lying in the storeroom (grabbed), the catalogue
## with the "real" prices on a little table in the hall and the forger's half-painted copy in the storeroom (photos),
## two buyers talking about "the original" (the recording), one of the sale's lots, stolen from a museum (the cops have
## to buy it: AuctionSale.stolen) and the sales book on the office's desk (searched with E; the key is on the podium).
const EVIDENCE_KINDS: Array[String] = ["original", "catalog", "forgery", "recording", "lot", "ledger"]
const ORIGINAL_AT := Vector3(-6.0, FLOOR_TOP + 0.05, -8.8)
## Its copy leans in front of it, hiding it from the door (rad off upright).
const COPY_LEAN := 0.25
const CATALOG_TABLE_AT := Vector3(3.0, 0, 8.2)
const CATALOG_AT := Vector3(3.0, FLOOR_TOP + 0.82, 8.2)
const FORGER_AT := Vector3(0.0, 0, -6.0)
const LEDGER_AT := Vector3(8.5, FLOOR_TOP + 0.85, -3.0)
## Two buyers this close (m) talk business together: the recording's pair.
const TALK_PAIR := 2.6
## The storeroom's crates.
const CRATES: Array[Vector3] = [Vector3(-10.5, 0, -8.5), Vector3(-9.0, 0, -8.5), Vector3(-1.0, 0, -8.5),
	Vector3(2.5, 0, -3.0)]

const OUTSIDE := Color(0.86, 0.82, 0.74)
const INSIDE := Color(0.45, 0.13, 0.17)
const FLOOR := Color(0.42, 0.28, 0.18)
const CARPET := Color(0.6, 0.1, 0.14)
const WOOD := Color(0.35, 0.2, 0.12)
const GOLD := Color(0.85, 0.68, 0.25)
const CONCRETE := Color(0.55, 0.55, 0.55)

var office_door: FrontDoor
## The hall's chairs, one per CHAIRS, the podium and the easel (step 3).
var seats: Array[BidSeat] = []
var podium: AuctionPodium
var easel: LotEasel
var sale: AuctionSale
var martillo: ClubMember
var doorman: ClubDoorman
var _build: PlaceBuilder


func _ready() -> void:
	variant = "auction"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_hall()
	_build_gallery()
	_build_back_rooms()
	_add_hall()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)
	_add_people()
	_add_evidence()
	sale = AuctionSale.new()
	sale.name = "Sale"
	sale.house = self
	sale.case_seed = case_seed
	if evidence.kinds.has("lot"):
		sale.stolen = LotEasel.KINDS[hash(["stolen lot", case_seed]) % LotEasel.KINDS.size()]
	add_child(sale)
	place_in_city("auction")
	start_case()


## Don Martillo drives off from the street, out of the entrance (step 6).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


func _local(at: Vector3) -> Vector3:
	return global_transform.affine_inverse() * at


## Whether a world position is inside the house.
func is_inside(at: Vector3) -> bool:
	var local := _local(at)
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is in the auction hall, with the podium and the chairs.
func in_hall(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z > BACK_Z and local.x < GALLERY_X


## Whether a world position is in the gallery.
func in_gallery(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z > BACK_Z and local.x > GALLERY_X


## Whether a world position is in the storeroom.
func in_storeroom(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.x < GALLERY_X


## Whether a world position is in Don Martillo's office.
func in_back_room(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.x > GALLERY_X


## The buyers at their spots, drawn with the seed; Don Martillo behind his podium; the doorman by the entrance and
## their suspicion.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["auction members", case_seed])
	var spots := SPOTS.duplicate()
	for i in BUYERS:
		var spot: Array = spots.pop_at(rng.randi_range(0, spots.size() - 1))
		var seated := CHAIRS.has(spot[0])
		_add_member("comprador" if rng.randf() < 0.5 else "compradora", spot[0] + Vector3(0, SEAT if seated else 0.0, 0),
			spot[1], rng)
	martillo = ClubMember.new()
	martillo.name = "Martillo"
	martillo.look = "martillo"
	add_child(martillo)
	martillo.position = MARTILLO_AT + Vector3(0, FLOOR_TOP, 0)
	martillo.rotation.y = PI
	boss = martillo
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	doorman.look = "portero_subasta"
	doorman.disguise_look = "auction"
	add_child(doorman)
	doorman.position = DOORKEEPER_AT + Vector3(0, FLOOR_TOP, 0)
	doorman.rotation.y = PI / 2
	doorman.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = martillo
	suspicion.boss_found_out = "MARTILLO_FOUND_OUT"
	suspicion.disguise_look = "auction"
	suspicion.prefix = "AUCTION_"
	suspicion.inside = is_inside
	suspicion.in_back_room = in_back_room
	add_child(suspicion)


func _add_member(look: String, spot: Vector3, turn: float, rng: RandomNumberGenerator) -> void:
	var member := ClubMember.new()
	member.name = "Member%d" % members.size()
	member.look = look
	member.next_line = rng.randi_range(0, ClubMember.TALK[look][1] - 1)
	add_child(member)
	member.position = spot + Vector3(0, FLOOR_TOP, 0)
	member.rotation.y = turn
	members.append(member)


## Floor, outer walls with the entrance, the roof, the sign, the wall between the hall and the gallery and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.3))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	_build.wall("z", GALLERY_X, BACK_Z, HALF_Z, 0, [GALLERY_DOOR_Z], INSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_AUCTION"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = GOLD
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-6.0, 2.5, 7.0]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The hall's red carpet.
func _build_hall() -> void:
	_build.mesh_box(Vector3((GALLERY_X - HALF_X) / 2, FLOOR_TOP + 0.004, HALF_Z / 2), Vector3(HALF_X + GALLERY_X - 0.1,
		0.008, HALF_Z - 0.1), CARPET)


## Don Martillo's podium with the gavel and the price board, the easel of the lots and the chairs with their paddles,
## facing the podium (step 3).
func _add_hall() -> void:
	podium = AuctionPodium.new()
	podium.name = "Podium"
	podium.position = PODIUM_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(podium)
	easel = LotEasel.new()
	easel.name = "Easel"
	easel.position = EASEL_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(easel)
	for i in CHAIRS.size():
		var seat := BidSeat.new()
		seat.name = "Seat%d" % (i + 1)
		seat.number = i + 1
		seat.position = CHAIRS[i] + Vector3(0, FLOOR_TOP, 0)
		add_child(seat)
		seats.append(seat)


## The gallery: the paintings for sale in their gold frames and the pedestal with its vase.
func _build_gallery() -> void:
	var colors: Array[Color] = [Color(0.85, 0.55, 0.2), Color(0.25, 0.45, 0.75), Color(0.3, 0.6, 0.35),
		Color(0.75, 0.3, 0.55), Color(0.9, 0.85, 0.4)]
	for i in PAINTINGS.size():
		var at: Vector3 = PAINTINGS[i][0]
		var size: Vector2 = PAINTINGS[i][1]
		var inward: Vector3 = PAINTINGS[i][2]
		var turn := Vector3(0, PI / 2 if inward.x != 0.0 else 0.0, 0)
		var frame := BoxMesh.new()
		frame.size = Vector3(size.x + 0.16, size.y + 0.16, 0.04)
		_build.mesh(frame, at, GOLD, turn)
		var canvas := BoxMesh.new()
		canvas.size = Vector3(size.x, size.y, 0.03)
		_build.mesh(canvas, at + inward * 0.02, colors[i], turn)
	_build.box(PEDESTAL_AT + Vector3(0, FLOOR_TOP + 0.5, 0), Vector3(0.6, 1.0, 0.6), OUTSIDE.lightened(0.1))
	var vase := CylinderMesh.new()
	vase.top_radius = 0.12
	vase.bottom_radius = 0.18
	vase.height = 0.5
	_build.mesh(vase, PEDESTAL_AT + Vector3(0, FLOOR_TOP + 1.25, 0), Color(0.2, 0.55, 0.6))


## The storeroom's concrete floor and crates, and Don Martillo's office with its desk and its safe.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [STORE_DOOR_X, OFFICE_DOOR_X], INSIDE)
	_build.wall("z", GALLERY_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	_build.mesh_box(Vector3((GALLERY_X - HALF_X) / 2, FLOOR_TOP + 0.004, -HALF_Z / 2), Vector3(HALF_X + GALLERY_X - 0.1,
		0.008, HALF_Z - 0.1), CONCRETE)
	for at in CRATES:
		_build.box(at + Vector3(0, FLOOR_TOP + 0.5, 0), Vector3(1.2, 1.0, 0.3), WOOD.lightened(0.3))
	_build.box(Vector3(8.5, FLOOR_TOP + 0.4, -3.0), Vector3(2.4, 0.8, 1.0), WOOD)
	_build.box(Vector3(HALF_X - 0.35, FLOOR_TOP + 0.6, -7.0), Vector3(0.6, 1.2, 0.8), Color(0.25, 0.25, 0.28))


func bought() -> int:
	return sale.bought


func spent() -> int:
	return sale.spent


## 3 of the 6 pieces of evidence by the seed, the key on the podium and, for the recording, two buyers talking. The
## catalogue and the forger's corner are there whether they're evidence or not.
func _add_evidence() -> void:
	evidence = ClubEvidence.new()
	evidence.name = "Evidence"
	evidence.held_kinds.assign(["original"])
	evidence.talk_key = "AUCTION_TALK_%d"
	add_child(evidence)
	var pair := _talking_pair()
	var available := EVIDENCE_KINDS.duplicate()
	if pair.is_empty():
		available.erase("recording")
	evidence.kinds = ClubEvidence.draw(case_seed, available)
	var key: KeyPot = KEY_POT_SCENE.instantiate()
	key.name = "KeyPodium"
	key.has_key = true
	key.prompt = "PROMPT_AUCTION_PODIUM_KEY"
	add_child(key)
	key.position = PODIUM_AT + Vector3(0.45, FLOOR_TOP + 1.12, 0.05)
	key.get_node("Pot").hide()
	key.get_node("Plant").hide()
	_build_catalog_and_forger()
	for kind: String in evidence.kinds:
		match kind:
			"original":
				var size := Vector3(1.0, 0.1, 0.8)
				var item := ClubEvidence.make_item("Auction_original", ORIGINAL_MODEL, size, 8.0)
				(item.get_child(1) as Node3D).position.y = -size.y / 2
				add_child(item)
				item.position = ORIGINAL_AT
				evidence.items[kind] = item
				var copy: Node3D = ORIGINAL_MODEL.instantiate()
				copy.basis = Basis(Vector3.RIGHT, PI / 2 - COPY_LEAN)
				copy.position = ORIGINAL_AT + Vector3(0, -0.05 + 0.4 * cos(COPY_LEAN), 0.75)
				$Built.add_child(copy)
			"catalog":
				_spot(kind, CATALOG_AT, Vector3(0.4, 0.1, 0.3), true)
			"forgery":
				_spot(kind, FORGER_AT + Vector3(0, FLOOR_TOP + 1.18, 0.1), Vector3(0.8, 0.6, 0.2), true)
			"ledger":
				_spot(kind, LEDGER_AT, Vector3(0.6, 0.1, 0.4), false)
				_build.mesh_box(LEDGER_AT + Vector3(0, -0.02, 0), Vector3(0.3, 0.04, 0.22), Color(0.45, 0.1, 0.12))
			"recording":
				evidence.talkers.assign(pair)
				for member: ClubMember in pair:
					member.distracted = true


## A piece of evidence that stays put, a box of `size` around `at`: photographed, or searched with E.
func _spot(kind: String, at: Vector3, size: Vector3, photo: bool) -> ClubEvidenceSpot:
	var spot := ClubEvidenceSpot.new()
	spot.name = "Evidence_" + kind
	spot.kind = kind
	spot.photo = photo
	spot.prompt_prefix = "PROMPT_AUCTION_"
	spot.evidence = evidence
	add_child(spot)
	spot.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	spot.add_child(shape)
	return spot


## Two buyers by each other (the recording's pair), or none.
func _talking_pair() -> Array[ClubMember]:
	for first in members:
		for second in members:
			if first != second and first.position.distance_to(second.position) < TALK_PAIR:
				return [first, second]
	return []


## The catalogue open on its little table in the hall, and the forger's corner in the storeroom: his easel with the
## half-painted copy and his paint tubes on a stool.
func _build_catalog_and_forger() -> void:
	_build.box(CATALOG_TABLE_AT + Vector3(0, FLOOR_TOP + 0.38, 0), Vector3(0.6, 0.76, 0.5), WOOD)
	_build.mesh_box(CATALOG_AT, Vector3(0.36, 0.02, 0.26), Color(0.95, 0.92, 0.85))
	for i in 4:
		_build.mesh_box(CATALOG_AT + Vector3(-0.08, 0.011, -0.08 + i * 0.05), Vector3(0.14, 0.002, 0.012), Color(0.2, 0.2, 0.25))
		_build.mesh_box(CATALOG_AT + Vector3(0.1, 0.011, -0.08 + i * 0.05), Vector3(0.08, 0.002, 0.012), Color(0.75, 0.1, 0.1))
	var easel_model: Node3D = EASEL_MODEL.instantiate()
	easel_model.position = FORGER_AT + Vector3(0, FLOOR_TOP, 0)
	$Built.add_child(easel_model)
	var copy: Node3D = FORGERY_MODEL.instantiate()
	copy.position = FORGER_AT + Vector3(0, FLOOR_TOP + 0.905, 0.1)
	$Built.add_child(copy)
	_build.box(FORGER_AT + Vector3(1.0, FLOOR_TOP + 0.3, 0.3), Vector3(0.5, 0.6, 0.5), WOOD.lightened(0.2))
	for i in 5:
		_build.mesh_box(FORGER_AT + Vector3(0.85 + i * 0.07, FLOOR_TOP + 0.62, 0.3), Vector3(0.03, 0.03, 0.12),
			[Color(0.85, 0.2, 0.2), Color(0.2, 0.4, 0.85), Color(0.95, 0.85, 0.2), Color(0.3, 0.65, 0.3),
				Color(0.95, 0.95, 0.95)][i])
