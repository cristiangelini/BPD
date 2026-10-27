class_name PartyHall
extends InfiltrationPlace

## The costume party's "Salón Gala" (docs/diseno/infiltracion-fiesta.md, step 2, decision 171): one floor on its lot in
## the city, the front to +Z. The dance floor with its mirror ball in the middle, the long food table along the west
## wall, the three photo steps against the back wall with the party's banner over them, the coat check by the entrance
## (west) and the restroom (east), and behind, the hall's office (locked), where the gang keeps the jewels. The cops
## start in the station, where the party disguises are, and drive here. --place=party opens it from Play.
## Twelve guests mingle on spots drawn with the seed, each in a cop costume told apart by four bits (PartyTraits), the
## Sargento Trucho one of them; the señora Serpentina by the food and the bouncer at the door, who only lets in cops
## dressed as party cops (step 2b). The guests watch the cops (ClubSuspicion, "PARTY_" texts). Every so often
## Serpentina calls the group photo on the steps, and the boss slips into the office meanwhile (PartyPhoto, step 3).
## The case (InfiltrationCase, variant "party", step 4): 3 of the 6 clues, each telling one bit of the boss's costume
## (`clues`), and seeing him in the office during the photo tells the fourth (`bonus_kind`).
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway in the middle of the front wall.
const ENTRANCE_X := 0.0
## The dance floor in the middle, a checkerboard of TILE m squares, and the mirror ball over it.
const DANCE := Rect2(-4.0, -4.5, 8.0, 8.0)
const TILE := 1.0
## The long food table along the west wall.
const FOOD_TABLE_AT := Vector3(-10.6, 0, -1.5)
const FOOD_TABLE_SIZE := Vector3(1.0, 0.8, 6.0)
## The photo steps against the back wall: STEPS rows from STEPS_FRONT_Z back, each STEP_DEPTH deep and STEP_RISE higher
## than the one in front, from STEPS_X0 to STEPS_X1; on each, a spot to pose every SPOT_GAP m.
const STEPS := 3
const STEPS_X0 := -9.0
const STEPS_X1 := 3.0
const STEPS_FRONT_Z := -7.9
const STEP_DEPTH := 0.7
const STEP_RISE := 0.2
const SPOT_GAP := 2.0
## The coat check, west of the entrance behind its counter, open on its east side.
const COAT_CHECK := Rect2(-12.0, 6.65, 6.0, 3.35)
const COAT_COUNTER_Z := 6.4
## The restroom, east of the entrance, with its door into the hall on its west wall.
const RESTROOM_X := 7.5
const RESTROOM_Z := 6.0
const RESTROOM_DOOR_Z := 8.0
## The office at the back east corner, its locked door into the hall.
const OFFICE_X := 6.0
const OFFICE_Z := -6.5
const OFFICE_DOOR_X := 9.0
## Where the guests mingle: on the dance floor, by the food and around (step 2b picks GUESTS of them with the seed).
## How many guests, of the MINGLE_SPOTS.
const GUESTS := 12
## The señora Serpentina, by the punch bowl looking at the hall (+X), and the bouncer outside by the entrance.
const SERPENTINA_AT := Vector3(-9.2, 0, 3.6)
const DOORMAN_AT := Vector3(ENTRANCE_X + 1.4, 0, HALF_Z + 0.7)
## In the group photo (step 3): where Serpentina takes it from, facing the steps, and where the boss counts the jewels,
## by the safe.
const PHOTOGRAPHER_AT := Vector3(-3.0, 0, -4.0)
const JEWELS_AT := Vector3(10.4, 0, -8.6)
## The clues (step 4) and the bit of the boss's costume each tells: the coat check ticket on its counter (grab it), a
## mustache hair on the jewel bag hidden in the restroom (photo), last year's photo framed in the office (photo), the
## optician's receipt on the food table (grab it); the recording of two guests gossiping by each other and the señora
## Serpentina, talked to with no guest within HOSTESS_ALONE m, tell a bit no other clue here tells.
const EVIDENCE_KINDS: Array[String] = ["ticket", "hair", "old_photo", "recording", "receipt", "hostess"]
const CLUE_OF := {"ticket": "cap", "hair": "mustache", "old_photo": "badge", "receipt": "glasses"}
const HOSTESS_ALONE := 6.0
const TALK_PAIR := 2.6
const TICKET_AT := Vector3(-8.4, 0, 6.4)
const HAIR_BAG_AT := Vector3(10.6, 0, 7.6)
const OLD_PHOTO_AT := Vector3(9.4, 1.6, -9.9)
const RECEIPT_AT := Vector3(-10.5, 0, -4.3)
const TICKET_MODEL := preload("res://assets/models/lottery_ticket.glb")
const RECEIPT_MODEL := preload("res://assets/models/pawn_receipt.glb")
const JEWEL_BAG_MODEL := preload("res://assets/models/jewelry_bag.glb")
const MINGLE_SPOTS: Array[Vector3] = [
	Vector3(-3.0, 0, -3.5), Vector3(-1.0, 0, -3.0), Vector3(1.2, 0, -3.6), Vector3(3.0, 0, -2.8),
	Vector3(-2.6, 0, -1.0), Vector3(-0.4, 0, -0.6), Vector3(2.0, 0, -0.8), Vector3(-3.2, 0, 1.4),
	Vector3(-1.2, 0, 1.8), Vector3(1.0, 0, 1.2), Vector3(3.2, 0, 1.8), Vector3(-9.2, 0, -3.6),
	Vector3(-9.2, 0, -1.0), Vector3(-9.2, 0, 1.4), Vector3(6.0, 0, -2.0), Vector3(6.4, 0, 2.6),
]

const OUTSIDE := Color(0.55, 0.2, 0.45)
const INSIDE := Color(0.95, 0.9, 0.8)
const FLOOR := Color(0.36, 0.26, 0.2)
const TILE_A := Color(0.95, 0.95, 0.95)
const TILE_B := Color(0.12, 0.12, 0.16)
const STEP_COLOR := Color(0.75, 0.1, 0.18)
const TABLECLOTH := Color(0.96, 0.96, 0.92)
const WOOD := Color(0.48, 0.3, 0.18)
const MIRROR := Color(0.85, 0.88, 0.95)
const BALLOONS: Array[Color] = [Color(0.95, 0.2, 0.25), Color(0.2, 0.45, 0.95), Color(0.98, 0.85, 0.2),
	Color(0.3, 0.8, 0.4)]

var office_door: FrontDoor
## Each guest's costume ({kind: value}, PartyTraits), in the order of `members`.
var guest_traits: Array[Dictionary] = []
var serpentina: ClubMember
var doorman: ClubDoorman
## The group photo (step 3).
var photo: PartyPhoto
## The spots to pose on the photo steps, in the hall's space.
var photo_spots: Array[Vector3] = []
## The bit of the boss's costume each clue in the hall tells ({kind: trait kind}), and the one the office tells.
var clues := {}
var bonus_kind := ""
var _build: PlaceBuilder


func _ready() -> void:
	variant = "party"
	take_seed()
	_build = PlaceBuilder.new($Built)
	build_shell(_build, $Built, BALLOONS)
	build_dance_floor(_build)
	_build_food_table()
	_build_steps()
	build_rooms(_build)
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_Z)
	add_child(office_door)
	_add_people()
	_add_evidence()
	place_in_city("party_hall")
	start_case()
	photo.boss_seen.connect(func(_cop: Cop) -> void: case.give_bonus())


## The boss runs off from the street, out of the entrance (step 5).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


## The guests on spots drawn with the seed, in their costumes, the Sargento Trucho among them; the señora Serpentina,
## the bouncer and the guests' suspicion.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["party guests", case_seed])
	var costumes := PartyTraits.draw(case_seed, GUESTS)
	guest_traits.assign(costumes.traits)
	var spots := MINGLE_SPOTS.duplicate()
	for i in GUESTS:
		var guest := ClubMember.new()
		guest.name = "Guest%d" % i
		guest.look = "invitado" if rng.randf() < 0.5 else "invitado_b"
		guest.next_line = rng.randi_range(0, ClubMember.TALK[guest.look][1] - 1)
		guest.accessories = PartyTraits.models_of(guest_traits[i])
		guest.secret_boss = i == costumes.boss
		add_child(guest)
		guest.position = spots.pop_at(rng.randi_range(0, spots.size() - 1)) + Vector3(0, FLOOR_TOP, 0)
		guest.rotation.y = rng.randf_range(-PI, PI)
		members.append(guest)
	boss = members[costumes.boss]
	serpentina = ClubMember.new()
	serpentina.name = "Serpentina"
	serpentina.look = "serpentina"
	add_child(serpentina)
	serpentina.position = SERPENTINA_AT + Vector3(0, FLOOR_TOP, 0)
	serpentina.rotation.y = -PI / 2
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	doorman.look = "patovica"
	doorman.disguise_look = "party"
	add_child(doorman)
	doorman.position = DOORMAN_AT
	doorman.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = boss
	suspicion.boss_found_out = "TRUCHO_FOUND_OUT"
	suspicion.disguise_look = "party"
	suspicion.prefix = "PARTY_"
	suspicion.inside = is_inside
	suspicion.in_back_room = in_back_room
	add_child(suspicion)
	photo = PartyPhoto.new()
	photo.name = "Photo"
	photo.case_seed = case_seed
	photo.guests = members
	photo.boss = boss
	photo.photo_spots = photo_spots
	photo.office_spot = JEWELS_AT + Vector3(0, FLOOR_TOP, 0)
	photo.office_way = Vector3(OFFICE_DOOR_X, FLOOR_TOP, OFFICE_Z + 1.0)
	photo.office_door = office_door
	photo.serpentina = serpentina
	photo.photographer_spot = PHOTOGRAPHER_AT + Vector3(0, FLOOR_TOP, 0)
	photo.on_steps = on_steps
	photo.inside = is_inside
	photo.in_office = in_back_room
	add_child(photo)
	suspicion.watch_photo(photo)


## The 3 clues the seed picks (ClubEvidence), what each tells, and the one left for the office.
func _add_evidence() -> void:
	evidence = ClubEvidence.new()
	evidence.name = "Evidence"
	evidence.held_kinds.assign(["ticket", "receipt"])
	evidence.talk_key = "PARTY_TALK_%d"
	add_child(evidence)
	var pair := _talking_pair()
	var available := EVIDENCE_KINDS.duplicate()
	if pair.is_empty():
		available.erase("recording")
	evidence.kinds = ClubEvidence.draw(case_seed, available)
	var untold := PartyTraits.KINDS.duplicate()
	for kind: String in evidence.kinds:
		if CLUE_OF.has(kind):
			clues[kind] = CLUE_OF[kind]
			untold.erase(CLUE_OF[kind])
	for kind: String in evidence.kinds:
		if not clues.has(kind):
			clues[kind] = untold.pop_front()
	bonus_kind = untold[0]
	var counter_top := FLOOR_TOP + 1.0
	for kind: String in evidence.kinds:
		match kind:
			"ticket":
				_item(kind, TICKET_MODEL, Vector3(0.12, 0.02, 0.08), 0.05, TICKET_AT + Vector3(0, counter_top + 0.02, 0))
			"receipt":
				_item(kind, RECEIPT_MODEL, Vector3(0.12, 0.02, 0.18), 0.05,
					RECEIPT_AT + Vector3(0, FLOOR_TOP + FOOD_TABLE_SIZE.y + 0.02, 0))
			"hair":
				# The jewel bag behind the sink, a mustache hair caught in its zip.
				var bag := JEWEL_BAG_MODEL.instantiate()
				bag.position = HAIR_BAG_AT + Vector3(0, FLOOR_TOP, 0)
				bag.scale = Vector3.ONE * 2.5
				$Built.add_child(bag)
				_spot(kind, HAIR_BAG_AT + Vector3(0, FLOOR_TOP + 0.2, 0), Vector3(0.5, 0.4, 0.5))
			"old_photo":
				# Last year's party, framed: the whole gang posing, one of them circled in red.
				_spot(kind, OLD_PHOTO_AT, Vector3(1.0, 0.7, 0.1))
				_build.mesh_box(OLD_PHOTO_AT, Vector3(0.9, 0.6, 0.03), WOOD)
				_build.mesh_box(OLD_PHOTO_AT + Vector3(0, 0, 0.02), Vector3(0.78, 0.48, 0.01), Color(0.55, 0.7, 0.9))
				for i in 6:
					_build.mesh_box(OLD_PHOTO_AT + Vector3(-0.3 + i * 0.12, -0.05, 0.03), Vector3(0.07, 0.2, 0.01),
						Color(0.2, 0.3, 0.75) if i != 3 else Color(0.85, 0.1, 0.1))
			"recording":
				evidence.talkers.assign(pair)
				for member: ClubMember in pair:
					member.distracted = true
			"hostess":
				serpentina.talked.connect(_on_hostess_talked)


## A clue to grab, lying at `at`.
func _item(kind: String, model: PackedScene, size: Vector3, kg: float, at: Vector3) -> void:
	var item := ClubEvidence.make_item("Party_" + kind, model, size, kg)
	add_child(item)
	item.position = at
	evidence.items[kind] = item


## A clue to photograph, a box of `size` around `at`.
func _spot(kind: String, at: Vector3, size: Vector3) -> void:
	var spot := ClubEvidenceSpot.new()
	spot.name = "Evidence_" + kind
	spot.kind = kind
	spot.photo = true
	spot.prompt_prefix = "PROMPT_PARTY_"
	spot.evidence = evidence
	add_child(spot)
	spot.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	spot.add_child(shape)


## Two guests mingling by each other, not the boss (the recording's pair), or none.
func _talking_pair() -> Array[ClubMember]:
	for first in members:
		for second in members:
			if first != second and first != boss and second != boss \
					and first.position.distance_to(second.position) < TALK_PAIR:
				return [first, second]
	return []


## The señora Serpentina tells what she saw of the boss, but only with no guest close enough to hear her.
func _on_hostess_talked(_cop: Cop) -> void:
	if members.any(func(guest: ClubMember) -> bool:
			return guest.global_position.distance_to(serpentina.global_position) < HOSTESS_ALONE):
		return
	serpentina.say(tr("SERPENTINA_TELLS") % trait_text(clues.hostess))
	if multiplayer.is_server():
		evidence.mark("hostess")


## What the boss wears of `kind`, in words ("gorra azul").
func trait_text(kind: String) -> String:
	return tr(("TRAIT_%s_%s" % [kind, guest_traits[members.find(boss)][kind]]).to_upper())


## "El jefe: gorra azul, ¿?, placa de chocolate, ¿?": what the clues found tell, in the order of the bits.
func clue_row(found: Array[String], bonus: bool) -> String:
	var known := found.filter(func(kind: String) -> bool: return clues.has(kind)).map(
		func(kind: String) -> String: return clues[kind])
	if bonus:
		known.append(bonus_kind)
	if known.is_empty():
		return ""
	var parts := PartyTraits.KINDS.map(func(kind: String) -> String:
		return trait_text(kind) if known.has(kind) else tr("PARTY_TRAIT_UNKNOWN"))
	return tr("PARTY_BOSS_ROW") % ", ".join(PackedStringArray(parts))


## Whether a world position is inside the hall.
func is_inside(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is in the office.
func in_back_room(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > OFFICE_X and local.x < HALF_X and local.z > -HALF_Z and local.z < OFFICE_Z and local.y < ROOF


## Whether a world position is up on the photo steps.
func on_steps(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	var back := STEPS_FRONT_Z - STEPS * STEP_DEPTH
	return local.x > STEPS_X0 and local.x < STEPS_X1 and local.z < STEPS_FRONT_Z and local.z > back \
		and local.y > FLOOR_TOP + STEP_RISE - 0.15 and local.y < ROOF


## Whether a world position is in the coat check, behind its counter.
func in_coat_check(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return COAT_CHECK.has_point(Vector2(local.x, local.z)) and local.y < ROOF


## Whether a world position is in the restroom.
func in_restroom(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > RESTROOM_X and local.x < HALF_X and local.z > RESTROOM_Z and local.z < HALF_Z and local.y < ROOF


## Floor, outer walls with the entrance, the roof, the sign, balloons of `balloons` by the door and the lights. The
## wedding crime scene (WeddingHall) builds the same hall.
static func build_shell(build: PlaceBuilder, built: Node3D, balloons: Array[Color]) -> void:
	build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_PARTY_HALL"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	built.add_child(sign_label)
	# A bunch of balloons on each side of the door, so it reads as a party from the street.
	for side: float in [-1.0, 1.0]:
		for i in 4:
			var balloon := SphereMesh.new()
			balloon.radius = 0.22
			balloon.height = 0.5
			build.mesh(balloon, Vector3(side * (1.6 + (i % 2) * 0.35), 1.9 + floorf(i / 2.0) * 0.45, HALF_Z + 0.35),
				balloons[i % balloons.size()])
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-8.0, -3.5, 1.0, 6.5]:
			build.light(Vector3(x, ROOF - 0.6, z))


## The checkered dance floor with the mirror ball over it.
static func build_dance_floor(build: PlaceBuilder) -> void:
	var columns := roundi(DANCE.size.x / TILE)
	var rows := roundi(DANCE.size.y / TILE)
	for i in columns:
		for j in rows:
			var at := Vector3(DANCE.position.x + (i + 0.5) * TILE, FLOOR_TOP + 0.005, DANCE.position.y + (j + 0.5) * TILE)
			build.mesh_box(at, Vector3(TILE, 0.01, TILE), TILE_A if (i + j) % 2 == 0 else TILE_B)
	var middle := DANCE.get_center()
	var ball := SphereMesh.new()
	ball.radius = 0.3
	ball.height = 0.6
	build.mesh(ball, Vector3(middle.x, ROOF - 0.6, middle.y), MIRROR)
	build.mesh_box(Vector3(middle.x, ROOF - 0.25, middle.y), Vector3(0.02, 0.3, 0.02), TILE_B)


## The long food table with its plates and the punch bowl.
func _build_food_table() -> void:
	_build.box(FOOD_TABLE_AT + Vector3(0, FLOOR_TOP + FOOD_TABLE_SIZE.y / 2, 0), FOOD_TABLE_SIZE, TABLECLOTH)
	var top := FLOOR_TOP + FOOD_TABLE_SIZE.y
	for i in 6:
		var plate := CylinderMesh.new()
		plate.top_radius = 0.16
		plate.bottom_radius = 0.12
		plate.height = 0.04
		_build.mesh(plate, FOOD_TABLE_AT + Vector3(0, top + 0.02, -2.5 + i), Color(0.9, 0.9, 0.95))
		_build.mesh_box(FOOD_TABLE_AT + Vector3(0, top + 0.07, -2.5 + i), Vector3(0.14, 0.06, 0.14), BALLOONS[i % 4])
	var bowl := CylinderMesh.new()
	bowl.top_radius = 0.25
	bowl.bottom_radius = 0.15
	bowl.height = 0.2
	_build.mesh(bowl, FOOD_TABLE_AT + Vector3(0, top + 0.1, 2.6), Color(0.85, 0.2, 0.35))


## The three photo steps against the back wall, a spot on each every SPOT_GAP m, and the banner over them.
func _build_steps() -> void:
	var width := STEPS_X1 - STEPS_X0
	var middle_x := (STEPS_X0 + STEPS_X1) / 2
	for k in STEPS:
		var height := STEP_RISE * (k + 1)
		var z := STEPS_FRONT_Z - (k + 0.5) * STEP_DEPTH
		_build.box(Vector3(middle_x, FLOOR_TOP + height / 2, z), Vector3(width, height, STEP_DEPTH),
			STEP_COLOR.darkened(k * 0.12))
		var spots := floori(width / SPOT_GAP)
		for i in spots:
			photo_spots.append(Vector3(STEPS_X0 + (i + 0.5) * SPOT_GAP, FLOOR_TOP + height, z))
	var banner := Label3D.new()
	banner.text = "PARTY_BANNER"
	banner.font_size = 48
	banner.pixel_size = 0.01
	banner.outline_size = 16
	banner.modulate = Color(1, 0.85, 0.2)
	banner.position = Vector3(middle_x, 2.3, -HALF_Z + 0.15)
	$Built.add_child(banner)
	_build.mesh_box(Vector3(middle_x, 2.3, -HALF_Z + 0.1), Vector3(width, 0.4, 0.02), Color(0.3, 0.1, 0.45))


## The coat check with its counter and coat rail, the restroom and the office.
static func build_rooms(build: PlaceBuilder) -> void:
	# Coat check: the counter across its front, a rail of coats along the west wall.
	build.box(Vector3(COAT_CHECK.position.x + COAT_CHECK.size.x / 2, FLOOR_TOP + 0.5, COAT_COUNTER_Z),
		Vector3(COAT_CHECK.size.x, 1.0, 0.5), WOOD)
	build.mesh_box(Vector3(-11.6, FLOOR_TOP + 1.7, 8.3), Vector3(0.04, 0.04, 3.0), TILE_B)
	for i in 7:
		build.mesh_box(Vector3(-11.6, FLOOR_TOP + 1.15, 7.0 + i * 0.42), Vector3(0.5, 1.0, 0.12),
			BALLOONS[i % 4].darkened(0.4))
	# Restroom: walls, a toilet and a sink.
	build.wall("z", RESTROOM_X, RESTROOM_Z, HALF_Z, 0, [RESTROOM_DOOR_Z], INSIDE)
	build.wall("x", RESTROOM_Z, RESTROOM_X, HALF_X, 0, [], INSIDE)
	build.box(Vector3(11.3, FLOOR_TOP + 0.22, 9.2), Vector3(0.5, 0.44, 0.7), TILE_A)
	build.box(Vector3(11.5, FLOOR_TOP + 0.45, 6.9), Vector3(0.6, 0.9, 0.5), TILE_A)
	# Office: walls, a desk and the safe.
	build.wall("x", OFFICE_Z, OFFICE_X, HALF_X, 0, [OFFICE_DOOR_X], INSIDE)
	build.wall("z", OFFICE_X, -HALF_Z, OFFICE_Z, 0, [], INSIDE)
	build.box(Vector3(8.0, FLOOR_TOP + 0.4, -9.0), Vector3(2.0, 0.8, 0.9), WOOD)
	build.box(Vector3(11.3, FLOOR_TOP + 0.5, -9.3), Vector3(0.8, 1.0, 0.8), Color(0.3, 0.32, 0.35))
