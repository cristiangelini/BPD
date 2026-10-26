class_name RestaurantHall
extends InfiltrationPlace

## The restaurant "La Cuchara de Oro" (docs/diseno/infiltracion-restaurante.md, step 2, decision 174): one floor on its
## own city lot, the front to +Z. The dining room from the entrance, open to anyone; the pass (a counter window with a
## bell) and the kitchen door, where the maître only lets cooks through; the kitchen with the stove's four burners along
## the back wall, the island to prep and plate and the sink; and behind it the pantry (west), the walk-in fridge
## (middle) and the Chef's office (east, locked). The gang's cooks work in the kitchen and its waiters in the dining
## room, all watching; the Chef Flambé stands at the pass, calling the orders (step 4). The cops start in the station,
## where the disguises are, and drive here. --place=restaurant opens it from Play. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const KEY_POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const LEDGER_MODEL := preload("res://assets/models/fight_notebook.glb")
const NECKLACE_POT_MODEL := preload("res://assets/models/kitchen_pot_necklaces.glb")
const POT_MODEL := preload("res://assets/models/kitchen_pot.glb")
const RING_MODEL := preload("res://assets/models/stolen_ring.glb")
const APRON_MODEL := preload("res://assets/models/folded_chef_apron.glb")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway in the middle of the front wall, into the dining room.
const ENTRANCE_X := 0.0
## The wall between the dining room (+Z) and the kitchen at PASS_Z: the pass, a window over a counter between PASS_FROM
## and PASS_TO, and the kitchen door at KITCHEN_DOOR_X.
const PASS_Z := 2.0
const PASS_FROM := -6.0
const PASS_TO := -2.0
const PASS_COUNTER := 1.0
const PASS_TOP := 2.1
const PASS_DEPTH := 0.6
const KITCHEN_DOOR_X := 5.0
## The back rooms, behind the wall at BACK_Z: the pantry west of PANTRY_X (its door at PANTRY_DOOR_X), the walk-in fridge
## between PANTRY_X and OFFICE_X (its door at FRIDGE_DOOR_X) and the office east of OFFICE_X (locked, at OFFICE_DOOR_X).
const BACK_Z := -4.0
const PANTRY_X := -4.0
const PANTRY_DOOR_X := -8.0
const FRIDGE_DOOR_X := 0.0
const OFFICE_X := 4.0
const OFFICE_DOOR_X := 8.0
## The kitchen: the stove along the back wall with its four burners on top, the island and the sink.
const STOVE_AT := Vector3(-7.0, 0, -3.45)
const STOVE_SIZE := Vector3(4.0, 0.9, 0.9)
const BURNERS: Array[Vector3] = [Vector3(-8.5, 0.9, -3.45), Vector3(-7.5, 0.9, -3.45), Vector3(-6.5, 0.9, -3.45),
	Vector3(-5.5, 0.9, -3.45)]
const ISLAND_AT := Vector3(1.5, 0, -1.0)
const ISLAND_SIZE := Vector3(4.0, 0.9, 1.2)
const SINK_AT := Vector3(8.5, 0, -3.45)
const SINK_SIZE := Vector3(2.0, 0.9, 0.9)
## The bell on the pass's counter, on the kitchen's side.
const BELL_AT := Vector3(-2.6, PASS_COUNTER, 2.0)
## The rail with the orders' tickets, over the pass, facing the kitchen.
const RAIL_AT := Vector3(-2.9, 2.0, PASS_Z - 0.12)
## The Chef stands at the pass, his back to it, looking at the kitchen.
const CHEF_AT := Vector3(-4.0, 0, 0.9)
## Where the pots and pans start (two pots on the first burners, two pans on the island) and the plates (on the island,
## by the pass), and the ingredients' crates: tomato, onion, lettuce and pasta in the pantry, fish in the fridge (step 3).
const POTS: Array[Vector3] = [Vector3(-8.5, 1.12, -3.45), Vector3(-7.5, 1.12, -3.45)]
const PANS: Array[Vector3] = [Vector3(0.3, 1.0, -1.2), Vector3(1.0, 1.0, -1.2)]
const PLATES: Array[Vector3] = [Vector3(1.8, 0.99, -0.8), Vector3(2.25, 0.99, -0.8), Vector3(2.7, 0.99, -0.8),
	Vector3(1.8, 0.99, -1.25), Vector3(2.25, 0.99, -1.25), Vector3(2.7, 0.99, -1.25)]
const CRATES := {"tomato": Vector3(-10.6, 0, -8.7), "onion": Vector3(-9.6, 0, -8.7), "lettuce": Vector3(-7.4, 0, -8.7),
	"pasta": Vector3(-6.4, 0, -8.7), "fish": Vector3(-2.5, 0, -8.7)}
## A pot or a pan this close to a burner's middle, and this high over it, is on it (m).
const BURNER_REACH := 0.3
const BURNER_HEIGHT := 0.35
## Where the cooks work (by the stove, at the island and by the sink) and where the waiters stand in the dining room
## (the seed picks COOKS and WAITERS of them; the cooks' spots left are for the cops).
const COOK_SPOTS: Array[Vector3] = [Vector3(-8.0, 0, -2.3), Vector3(-6.0, 0, -2.3), Vector3(0.5, 0, 0.2),
	Vector3(2.5, 0, 0.2), Vector3(8.5, 0, -2.3), Vector3(-1.0, 0, -2.2)]
const WAITER_SPOTS: Array[Vector3] = [Vector3(-8.0, 0, 3.2), Vector3(-1.0, 0, 6.0), Vector3(3.0, 0, 9.0),
	Vector3(9.0, 0, 6.0)]
const COOKS := 4
const WAITERS := 3
## The dining room's tables (one of them is table 7, the buyer's) and the cash register's counter by the entrance.
const TABLES: Array[Vector3] = [Vector3(-9.5, 0, 4.6), Vector3(-6.5, 0, 4.6), Vector3(-3.5, 0, 4.6),
	Vector3(-9.5, 0, 7.6), Vector3(-6.5, 0, 7.6), Vector3(-3.5, 0, 7.6), Vector3(6.5, 0, 7.6), Vector3(9.5, 0, 7.6)]
const TABLE_SIZE := Vector3(1.4, 0.75, 1.0)
## The buyer's table, with its number on a little stand.
const TABLE_SEVEN := 6
const CASH_AT := Vector3(9.5, 0, 3.6)
## The menu board on the dining room's west wall.
const MENU_AT := Vector3(-HALF_X + 0.12, 1.7, 6.0)
## The 6 pieces of evidence (the seed picks 3, ClubEvidence) and where they are (step 5): the gang's account book by
## the cash register (grabbed), the stolen ring in the Chef's special soup on the pass (a photo, while it's there), the
## double-bottom pot full of necklaces on the walk-in fridge's floor (grabbed), the video of two cooks talking about
## table 7's buyer, the menu board with its prices in carats (a photo) and the jeweller's receipt in the desk of the
## Chef's locked office (E). The office key is in the pocket of the apron hanging in the walk-in fridge.
const EVIDENCE_KINDS: Array[String] = ["ledger", "ring", "pot", "recording", "menu", "receipt"]
const LEDGER_AT := Vector3(8.9, FLOOR_TOP + 1.03, 3.6)
const SPECIAL_AT := Vector3(-5.0, FLOOR_TOP + PASS_COUNTER + 0.17, PASS_Z)
const NECKLACE_POT_AT := Vector3(1.0, FLOOR_TOP + 0.19, -8.6)
const RECEIPT_AT := Vector3(8.5, FLOOR_TOP + 0.85, -8.3)
const APRON_AT := Vector3(OFFICE_X - 0.25, FLOOR_TOP + 0.9, -6.0)
## Two cooks this close talk about the buyer (the recording).
const TALK_PAIR := 2.6
## The maître stands in the dining room by the kitchen door.
const MAITRE_AT := Vector3(KITCHEN_DOOR_X + 1.2, 0, PASS_Z + 0.8)

const OUTSIDE := Color(0.62, 0.22, 0.2)
const INSIDE := Color(0.95, 0.9, 0.78)
const FLOOR := Color(0.52, 0.32, 0.22)
const TILES := Color(0.85, 0.86, 0.84)
const FRIDGE := Color(0.78, 0.88, 0.95)
const WOOD := Color(0.48, 0.3, 0.18)
const STEEL := Color(0.62, 0.64, 0.68)
const CLOTH := Color(0.95, 0.95, 0.92)

var office_door: FrontDoor
## The cooks' spots no cook took, for the cops.
var free_spots: Array[Vector3] = []
var chef: ClubMember
var doorman: ClubDoorman
## The pots, pans and plates (step 3).
var vessels: Array[KitchenVessel] = []
## The Chef's orders and the pass's bell (step 4).
var orders: RestaurantOrders
var bell: PassBell
## The special soup on the pass, with the ring (step 5), shown only while it's there.
var special_soup: Node3D
var _ring_spot: ClubEvidenceSpot
var _build: PlaceBuilder


func _ready() -> void:
	variant = "restaurant"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_dining()
	_build_kitchen()
	_build_back_rooms()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)
	_add_people()
	_add_kitchenware()
	_add_orders()
	_add_evidence()
	place_in_city("restaurant")
	start_case()
	# The Chef's special soup comes and goes with the orders.
	orders.special_changed.connect(_on_special)


## The Chef rides off from the street, out of the entrance (step 6).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


func _local(at: Vector3) -> Vector3:
	return global_transform.affine_inverse() * at


## Whether a world position is inside the restaurant.
func is_inside(at: Vector3) -> bool:
	var local := _local(at)
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is where only the staff goes: the kitchen and the rooms behind it.
func in_staff_area(at: Vector3) -> bool:
	return is_inside(at) and _local(at).z < PASS_Z


## Which of the stove's burners a world position is on, or -1.
func burner_at(at: Vector3) -> int:
	var local := _local(at)
	for i in BURNERS.size():
		var burner := BURNERS[i] + Vector3(0, FLOOR_TOP, 0)
		var above := local.y - burner.y
		if Vector2(local.x - burner.x, local.z - burner.z).length() < BURNER_REACH and above > 0.0 \
				and above < BURNER_HEIGHT:
			return i
	return -1


## The plates standing on the pass's counter.
func plates_on_pass() -> Array[KitchenVessel]:
	return vessels.filter(func(vessel: KitchenVessel) -> bool:
		var local := _local(vessel.global_position)
		var above := local.y - FLOOR_TOP - PASS_COUNTER
		return vessel.kind == "plate" and local.x > PASS_FROM and local.x < PASS_TO \
			and absf(local.z - PASS_Z) < PASS_DEPTH / 2.0 and above > 0.0 and above < 0.3)


## Whether a world position is in the dining room.
func in_dining(at: Vector3) -> bool:
	return is_inside(at) and _local(at).z > PASS_Z


## Whether a world position is in the kitchen.
func in_kitchen(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z > BACK_Z and local.z < PASS_Z


## Whether a world position is in the pantry.
func in_pantry(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.x < PANTRY_X


## Whether a world position is in the walk-in fridge.
func in_fridge(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.x > PANTRY_X and local.x < OFFICE_X


## Whether a world position is in the Chef's office.
func in_back_room(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.x > OFFICE_X


## The cooks at their spots and the waiters in the dining room, drawn with the seed; the Chef at the pass; the maître
## by the kitchen door and their suspicion.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["restaurant staff", case_seed])
	free_spots = COOK_SPOTS.duplicate()
	for i in COOKS:
		var spot: Vector3 = free_spots.pop_at(rng.randi_range(0, free_spots.size() - 1))
		# Working facing the back wall, or the island from its south side.
		_add_member("cocinero" if rng.randf() < 0.5 else "cocinera", spot, 0.0, rng)
	var waiter_spots := WAITER_SPOTS.duplicate()
	for i in WAITERS:
		var spot: Vector3 = waiter_spots.pop_at(rng.randi_range(0, waiter_spots.size() - 1))
		# Looking at the pass, where the dishes come out.
		var facing := Vector3(PASS_FROM / 2.0 + PASS_TO / 2.0, 0, PASS_Z) - spot
		_add_member("mozo", spot, atan2(-facing.x, -facing.z), rng)
	chef = ClubMember.new()
	chef.name = "Chef"
	chef.look = "flambe"
	add_child(chef)
	chef.position = CHEF_AT + Vector3(0, FLOOR_TOP, 0)
	boss = chef
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	doorman.look = "maitre"
	doorman.disguise_look = "chef"
	add_child(doorman)
	doorman.position = MAITRE_AT + Vector3(0, FLOOR_TOP, 0)
	doorman.rotation.y = PI / 2
	doorman.door_at = global_transform * Vector3(KITCHEN_DOOR_X, 0, PASS_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = chef
	suspicion.boss_found_out = "FLAMBE_FOUND_OUT"
	suspicion.disguise_look = "chef"
	suspicion.prefix = "RESTAURANT_"
	suspicion.inside = in_staff_area
	suspicion.in_back_room = in_back_room
	add_child(suspicion)


## The pots, pans and plates where they start, and the ingredients' crates (step 3).
func _add_kitchenware() -> void:
	for spots: Array in [[POTS, "pot"], [PANS, "pan"], [PLATES, "plate"]]:
		var places: Array[Vector3] = spots[0]
		for i in places.size():
			var vessel := KitchenVessel.new()
			vessel.kind = spots[1]
			vessel.name = "%s%d" % [String(spots[1]).capitalize(), i]
			vessel.burner_at = burner_at
			add_child(vessel)
			vessel.position = places[i] + Vector3(0, FLOOR_TOP, 0)
			vessels.append(vessel)
	for kind: String in CRATES:
		var crate := IngredientCrate.new()
		crate.kind = kind
		crate.name = "Crate_" + kind
		add_child(crate)
		crate.position = CRATES[kind] + Vector3(0, FLOOR_TOP, 0)


## The Chef's orders, the rail over the pass with their tickets, and the bell; a lost order makes the cooks who see
## the kitchen suspicious (step 4).
func _add_orders() -> void:
	orders = RestaurantOrders.new()
	orders.name = "Orders"
	orders.case_seed = case_seed
	orders.chef = chef
	orders.inside = in_staff_area
	orders.plates_on_pass = plates_on_pass
	add_child(orders)
	orders.position = RAIL_AT + Vector3(0, FLOOR_TOP, 0)
	orders.rotation.y = PI
	orders.failed.connect(_on_order_failed)
	bell = PassBell.new()
	bell.name = "Bell"
	bell.orders = orders
	add_child(bell)
	bell.position = BELL_AT + Vector3(0, FLOOR_TOP, 0)


func _on_order_failed(amount: float) -> void:
	if not multiplayer.is_server():
		return
	for member in members:
		if member.look.begins_with("cocin") and in_kitchen(member.global_position + Vector3.UP):
			suspicion.raise(member, amount)


## The 3 pieces of evidence the seed picks (ClubEvidence), the special soup on the pass and the office key in the
## apron hanging in the walk-in fridge (step 5).
func _add_evidence() -> void:
	evidence = ClubEvidence.new()
	evidence.name = "Evidence"
	evidence.held_kinds.assign(["ledger", "pot"])
	evidence.talk_key = "RESTAURANT_TALK_%d"
	add_child(evidence)
	var pair := _talking_pair()
	var available := EVIDENCE_KINDS.duplicate()
	if pair.is_empty():
		available.erase("recording")
	evidence.kinds = ClubEvidence.draw(case_seed, available)
	var apron: KeyPot = KEY_POT_SCENE.instantiate()
	apron.name = "KeyApron"
	apron.has_key = true
	apron.prompt = "PROMPT_RESTAURANT_APRON"
	add_child(apron)
	apron.position = APRON_AT
	apron.get_node("Pot").hide()
	apron.get_node("Plant").hide()
	var hanging := APRON_MODEL.instantiate()
	hanging.rotation = Vector3(PI / 2, -PI / 2, 0)
	hanging.position = Vector3(0, 0.3, 0)
	apron.add_child(hanging)
	_add_special_soup()
	for kind: String in evidence.kinds:
		match kind:
			"ledger":
				_item(kind, LEDGER_MODEL, Vector3(0.22, 0.04, 0.3), 0.3, LEDGER_AT)
			"pot":
				_item(kind, NECKLACE_POT_MODEL, Vector3(0.4, 0.34, 0.4), 4.0, NECKLACE_POT_AT)
			"ring":
				orders.specials = true
				_ring_spot = _spot(kind, SPECIAL_AT, Vector3(0.5, 0.4, 0.5), true)
				_show_special(false)
			"menu":
				_spot(kind, MENU_AT, Vector3(0.1, 1.0, 1.6), true)
			"receipt":
				_spot(kind, RECEIPT_AT, Vector3(0.6, 0.1, 0.4), false)
				_build.mesh_box(RECEIPT_AT + Vector3(0, -0.12, 0.51), Vector3(0.5, 0.18, 0.02), WOOD.lightened(0.15))
				_build.mesh_box(RECEIPT_AT + Vector3(0, -0.12, 0.53), Vector3(0.12, 0.03, 0.02), STEEL)
			"recording":
				evidence.talkers.assign(pair)
				for member: ClubMember in pair:
					member.distracted = true


## The Chef's special soup for table 7: a pot with the ring sticking out of the soup, hidden until it comes out.
func _add_special_soup() -> void:
	special_soup = Node3D.new()
	special_soup.name = "SpecialSoup"
	add_child(special_soup)
	special_soup.position = SPECIAL_AT
	special_soup.add_child(POT_MODEL.instantiate())
	var soup := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.18
	disc.bottom_radius = 0.18
	disc.height = 0.02
	soup.mesh = disc
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.85, 0.35, 0.2)
	soup.material_override = red
	soup.position.y = 0.1
	special_soup.add_child(soup)
	var ring := RING_MODEL.instantiate()
	ring.position = Vector3(0.05, 0.13, 0.02)
	ring.scale = Vector3.ONE * 1.5
	special_soup.add_child(ring)
	special_soup.hide()


func _on_special(on: bool) -> void:
	_show_special(on)


## The special soup and, with the ring as evidence, its photo spot, there or not.
func _show_special(on: bool) -> void:
	special_soup.visible = on
	if _ring_spot:
		_ring_spot.collision_layer = 1 if on else 0
		_ring_spot.get_child(0).disabled = not on


## A piece of evidence to grab, lying at `at`.
func _item(kind: String, model: PackedScene, size: Vector3, kg: float, at: Vector3) -> void:
	var item := ClubEvidence.make_item("Restaurant_" + kind, model, size, kg)
	add_child(item)
	item.position = at
	evidence.items[kind] = item


## A piece of evidence that stays put, a box of `size` around `at`: photographed, or searched with E.
func _spot(kind: String, at: Vector3, size: Vector3, photo: bool) -> ClubEvidenceSpot:
	var spot := ClubEvidenceSpot.new()
	spot.name = "Evidence_" + kind
	spot.kind = kind
	spot.photo = photo
	spot.prompt_prefix = "PROMPT_RESTAURANT_"
	spot.evidence = evidence
	add_child(spot)
	spot.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	spot.add_child(shape)
	return spot


## Two cooks by each other (the recording's pair), or none.
func _talking_pair() -> Array[ClubMember]:
	for first in members:
		for second in members:
			if first != second and first.look.begins_with("cocin") and second.look.begins_with("cocin") \
					and first.position.distance_to(second.position) < TALK_PAIR:
				return [first, second]
	return []


func _add_member(look: String, spot: Vector3, turn: float, rng: RandomNumberGenerator) -> void:
	var member := ClubMember.new()
	member.name = "Member%d" % members.size()
	member.look = look
	member.next_line = rng.randi_range(0, ClubMember.TALK[look][1] - 1)
	add_child(member)
	member.position = spot + Vector3(0, FLOOR_TOP, 0)
	member.rotation.y = turn
	members.append(member)


## Floor, outer walls with the entrance, the roof, the sign, the wall with the pass and the kitchen door, and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, PASS_Z, FLOOR_TOP + 0.005, TILES)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	_build.wall("x", PASS_Z, -HALF_X, PASS_FROM, 0, [], INSIDE)
	_build.wall("x", PASS_Z, PASS_TO, HALF_X, 0, [KITCHEN_DOOR_X], INSIDE)
	var height := ROOF - PlaceBuilder.SLAB
	var middle := (PASS_FROM + PASS_TO) / 2.0
	var width := PASS_TO - PASS_FROM
	_build.box(Vector3(middle, PASS_COUNTER / 2.0, PASS_Z), Vector3(width, PASS_COUNTER, PASS_DEPTH), STEEL)
	_build.box(Vector3(middle, (PASS_TOP + height) / 2.0, PASS_Z), Vector3(width, height - PASS_TOP, PlaceBuilder.WALL),
		INSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_RESTAURANT"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-7.0, -1.0, 6.0]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The tables with their cloths (table 7 with its number), the cash register's counter and the menu board.
func _build_dining() -> void:
	for i in TABLES.size():
		var at := TABLES[i]
		_build.box(at + Vector3(0, FLOOR_TOP + TABLE_SIZE.y / 2, 0), TABLE_SIZE, WOOD)
		_build.mesh_box(at + Vector3(0, FLOOR_TOP + TABLE_SIZE.y + 0.01, 0), TABLE_SIZE + Vector3(0.1, -TABLE_SIZE.y + 0.02,
			0.1), CLOTH)
		for side: float in [-1.0, 1.0]:
			_build.box(at + Vector3(side * 0.95, FLOOR_TOP + 0.23, 0), Vector3(0.45, 0.46, 0.45), WOOD.darkened(0.2))
	var seven := Label3D.new()
	seven.text = "7"
	seven.font_size = 64
	seven.pixel_size = 0.004
	seven.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	seven.modulate = Color(0.1, 0.1, 0.1)
	seven.position = TABLES[TABLE_SEVEN] + Vector3(0, FLOOR_TOP + TABLE_SIZE.y + 0.15, 0)
	$Built.add_child(seven)
	_build.box(CASH_AT + Vector3(0, FLOOR_TOP + 0.5, 0), Vector3(2.0, 1.0, 0.7), WOOD)
	_build.mesh_box(CASH_AT + Vector3(0.3, FLOOR_TOP + 1.12, 0), Vector3(0.4, 0.24, 0.35), Color(0.2, 0.2, 0.22))
	_build.mesh_box(MENU_AT, Vector3(0.05, 1.08, 1.68), WOOD)
	_build.mesh_box(MENU_AT + Vector3(0.01, 0, 0), Vector3(0.04, 1.0, 1.6), Color(0.12, 0.12, 0.12))
	var menu := Label3D.new()
	menu.text = "RESTAURANT_MENU"
	menu.font_size = 28
	menu.pixel_size = 0.005
	menu.width = 300.0
	menu.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu.position = MENU_AT + Vector3(0.04, 0, 0)
	menu.rotation.y = PI / 2
	$Built.add_child(menu)


## The stove with its burners, the island and the sink.
func _build_kitchen() -> void:
	_build.box(STOVE_AT + Vector3(0, FLOOR_TOP + STOVE_SIZE.y / 2, 0), STOVE_SIZE, STEEL.darkened(0.2))
	for at in BURNERS:
		var ring := CylinderMesh.new()
		ring.top_radius = 0.2
		ring.bottom_radius = 0.2
		ring.height = 0.02
		_build.mesh(ring, at + Vector3(0, FLOOR_TOP + 0.01, 0), Color(0.12, 0.12, 0.12))
	for i in BURNERS.size():
		_build.mesh_box(BURNERS[i] + Vector3(0, FLOOR_TOP - 0.3, 0.46), Vector3(0.08, 0.08, 0.02), Color(0.85, 0.85, 0.85))
	_build.box(ISLAND_AT + Vector3(0, FLOOR_TOP + ISLAND_SIZE.y / 2, 0), ISLAND_SIZE, STEEL)
	_build.mesh_box(ISLAND_AT + Vector3(0, FLOOR_TOP + ISLAND_SIZE.y + 0.01, 0), Vector3(ISLAND_SIZE.x, 0.02,
		ISLAND_SIZE.z), STEEL.lightened(0.2))
	_build.box(SINK_AT + Vector3(0, FLOOR_TOP + SINK_SIZE.y / 2, 0), SINK_SIZE, STEEL)
	_build.mesh_box(SINK_AT + Vector3(0, FLOOR_TOP + SINK_SIZE.y + 0.01, 0.05), Vector3(0.9, 0.02, 0.5),
		Color(0.3, 0.4, 0.5))


## The pantry with its shelves of crates, the walk-in fridge and the Chef's office with its desk.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [PANTRY_DOOR_X, FRIDGE_DOOR_X, OFFICE_DOOR_X], INSIDE)
	_build.wall("z", PANTRY_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	_build.wall("z", OFFICE_X, -HALF_Z, BACK_Z, 0, [], FRIDGE)
	_build.slab(PANTRY_X, OFFICE_X, -HALF_Z, BACK_Z, FLOOR_TOP + 0.01, FRIDGE)
	var crates: Array[Color] = [Color(0.85, 0.2, 0.15), Color(0.9, 0.85, 0.75), Color(0.3, 0.65, 0.25),
		Color(0.95, 0.75, 0.2)]
	for x: float in [-10.5, -8.0, -5.5]:
		_build.box(Vector3(x, FLOOR_TOP + 0.9, -HALF_Z + 0.35), Vector3(2.2, 1.8, 0.5), WOOD)
		for shelf in 3:
			_build.mesh_box(Vector3(x, FLOOR_TOP + 0.4 + shelf * 0.55, -HALF_Z + 0.62), Vector3(1.9, 0.3, 0.04),
				crates[(shelf + int(x)) % crates.size()])
	for x: float in [-2.5, 2.5]:
		_build.box(Vector3(x, FLOOR_TOP + 0.9, -HALF_Z + 0.35), Vector3(2.4, 1.8, 0.5), STEEL.lightened(0.3))
	_build.box(Vector3(8.5, FLOOR_TOP + 0.4, -8.3), Vector3(2.4, 0.8, 1.0), WOOD.darkened(0.2))
