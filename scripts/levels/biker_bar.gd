class_name BikerBar
extends InfiltrationPlace

## The biker bar "El Caño Libre" (docs/diseno/infiltracion-motos.md, step 2, decision 176): one floor on its own city
## lot, the front to +Z. The bouncer stands inside the entrance and only lets bikers through; the bar with its counter,
## stools, tables and the coat rack, and the workshop east of it where El Cromado polishes his moped among the crates;
## behind, the patio of the courage dares (step 3 fills it) and El Cromado's locked office behind the workshop. The
## gang's bikers stand around the bar, the workshop and the patio, drawn with the seed. The whole bar is for bikers
## only. The cops start in the station, where the disguises are, and drive here. --place=biker opens it from Play.
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const MOPED_MODEL := preload("res://assets/models/chopper_moped.glb")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway in the middle of the front wall, into the bar.
const ENTRANCE_X := 0.0
## The wall between the bar (west) and the workshop (east) at SHOP_X, with its doorway at SHOP_DOOR_Z.
const SHOP_X := 4.0
const SHOP_DOOR_Z := 5.0
## The back wall at BACK_Z: the patio's doorway at PATIO_DOOR_X and the office's locked door, from the workshop, at
## OFFICE_DOOR_X. Behind, west of SHOP_X the patio and east of it the office.
const BACK_Z := 0.0
const PATIO_DOOR_X := -4.0
const OFFICE_DOOR_X := 8.0
## The counter along the bar's west wall, its stools in front of it, and the tables.
const COUNTER_AT := Vector3(-10.6, 0, 5.0)
const COUNTER_SIZE := Vector3(1.0, 1.1, 6.0)
const STOOLS: Array[Vector3] = [Vector3(-9.4, 0, 3.0), Vector3(-9.4, 0, 5.0), Vector3(-9.4, 0, 7.0)]
const TABLES: Array[Vector3] = [Vector3(-5.5, 0, 3.0), Vector3(-1.5, 0, 3.0), Vector3(-5.5, 0, 7.0)]
const TABLE_SIZE := Vector3(1.2, 0.75, 1.2)
## Where the bikers stand, facing where they look: [position, turn] (turn 0 faces -Z). The seed picks PLAYERS of them.
const SPOTS: Array[Array] = [
	[Vector3(-9.4, 0, 3.0), -PI / 2], [Vector3(-9.4, 0, 5.0), -PI / 2], [Vector3(-9.4, 0, 7.0), -PI / 2],
	[Vector3(-5.5, 0, 2.0), PI], [Vector3(-1.5, 0, 4.0), 0.0], [Vector3(-6.5, 0, 7.0), -PI / 2],
	[Vector3(-4.5, 0, 7.0), PI / 2], [Vector3(6.0, 0, 6.5), PI / 2], [Vector3(10.0, 0, 3.0), PI],
	[Vector3(-10.5, 0, -5.5), -PI / 2], [Vector3(2.8, 0, -6.0), PI / 2],
]
const PLAYERS := 8
## El Cromado polishes his moped in the workshop, facing it (-X); the coat rack by the entrance and the bouncer.
const CROMADO_AT := Vector3(9.8, 0, 6.5)
const MOPED_AT := Vector3(8.6, 0, 6.5)
const RACK_AT := Vector3(-3.0, 0, HALF_Z - 0.5)
const DOORKEEPER_AT := Vector3(ENTRANCE_X + 1.2, 0, HALF_Z - 1.2)
## The patio (step 3): the arm-wrestling table, the heavy bike lying by the west wall, and the "don't move" lane: the
## biker's bike waits at its far end facing the line painted LANE ahead of it, toward the door.
const ARM_TABLE_AT := Vector3(-8.0, 0, -3.0)
const HEAVY_BIKE_AT := Vector3(-8.0, 0, -7.6)
const CHARGE_AT := Vector3(-0.5, 0, -8.8)
## The workshop's crates against its back wall.
const CRATES: Array[Vector3] = [Vector3(5.5, 0, 0.8), Vector3(7.0, 0, 0.8), Vector3(10.5, 0, 0.8)]

const OUTSIDE := Color(0.22, 0.2, 0.2)
const INSIDE := Color(0.5, 0.36, 0.28)
const FLOOR := Color(0.3, 0.26, 0.24)
const CONCRETE := Color(0.55, 0.55, 0.55)
const WOOD := Color(0.4, 0.24, 0.14)
const STEEL := Color(0.6, 0.62, 0.66)

var office_door: FrontDoor
var arm_table: ArmTable
var heavy_bike: HeavyBike
var charge: DareCharge
var cromado: ClubMember
var doorman: ClubDoorman
var _build: PlaceBuilder


func _ready() -> void:
	variant = "biker"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_bar()
	_build_back_rooms()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)
	_add_patio()
	_add_people()
	place_in_city("biker")


## El Cromado rides off from the street, out of the entrance (step 6).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


func _local(at: Vector3) -> Vector3:
	return global_transform.affine_inverse() * at


## Whether a world position is inside the bar.
func is_inside(at: Vector3) -> bool:
	var local := _local(at)
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is in the bar room, with the counter.
func in_bar(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z > BACK_Z and local.x < SHOP_X


## Whether a world position is in the workshop.
func in_workshop(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z > BACK_Z and local.x > SHOP_X


## Whether a world position is in the patio of the dares.
func in_patio(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.x < SHOP_X


## Whether a world position is in El Cromado's office.
func in_back_room(at: Vector3) -> bool:
	var local := _local(at)
	return is_inside(at) and local.z < BACK_Z and local.x > SHOP_X


## The bikers at their spots, drawn with the seed; El Cromado by his moped; the bouncer by the entrance and their
## suspicion.
func _add_people() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["biker members", case_seed])
	var spots := SPOTS.duplicate()
	for i in PLAYERS:
		var spot: Array = spots.pop_at(rng.randi_range(0, spots.size() - 1))
		_add_member("motoquero" if rng.randf() < 0.5 else "motoquera", spot[0], spot[1], rng)
	cromado = ClubMember.new()
	cromado.name = "Cromado"
	cromado.look = "cromado"
	add_child(cromado)
	cromado.position = CROMADO_AT + Vector3(0, FLOOR_TOP, 0)
	cromado.rotation.y = PI / 2
	boss = cromado
	doorman = ClubDoorman.new()
	doorman.name = "Doorman"
	doorman.look = "patovica_moto"
	doorman.disguise_look = "biker"
	add_child(doorman)
	doorman.position = DOORKEEPER_AT + Vector3(0, FLOOR_TOP, 0)
	doorman.rotation.y = PI / 2
	doorman.door_at = global_transform * Vector3(ENTRANCE_X, 0, HALF_Z)
	doorman.outward = global_transform.basis * Vector3.BACK
	suspicion = ClubSuspicion.new()
	suspicion.name = "Suspicion"
	suspicion.members = members
	suspicion.boss = cromado
	suspicion.boss_found_out = "CROMADO_FOUND_OUT"
	suspicion.disguise_look = "biker"
	suspicion.prefix = "BIKER_"
	suspicion.inside = is_inside
	suspicion.in_back_room = in_back_room
	add_child(suspicion)


## The patio's arm-wrestling table, heavy bike and the "don't move" lane with its bike and its line.
func _add_patio() -> void:
	arm_table = ArmTable.new()
	arm_table.name = "ArmTable"
	arm_table.position = ARM_TABLE_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(arm_table)
	heavy_bike = HeavyBike.new()
	heavy_bike.name = "HeavyBike"
	heavy_bike.position = HEAVY_BIKE_AT + Vector3(0, FLOOR_TOP, 0)
	heavy_bike.rotation.y = PI / 2
	add_child(heavy_bike)
	charge = DareCharge.new()
	charge.name = "Charge"
	charge.position = CHARGE_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(charge)
	var line := charge.line_at()
	_build.mesh_box(Vector3(line.x, FLOOR_TOP + 0.01, line.z), Vector3(1.6, 0.012, 0.12), Color(0.95, 0.85, 0.2))
	for side: float in [-1.0, 1.0]:
		_build.mesh_box(Vector3(line.x + side * 0.9, FLOOR_TOP + 0.01, (CHARGE_AT.z + line.z) / 2),
			Vector3(0.06, 0.012, DareCharge.LANE), Color(0.9, 0.9, 0.9))


## Where the cop stands for the "don't move" dare, in the bar's space.
func line_at() -> Vector3:
	return charge.line_at() + Vector3(0, 0, 0.3)


func _add_member(look: String, spot: Vector3, turn: float, rng: RandomNumberGenerator) -> void:
	var member := ClubMember.new()
	member.name = "Member%d" % members.size()
	member.look = look
	member.next_line = rng.randi_range(0, ClubMember.TALK[look][1] - 1)
	add_child(member)
	member.position = spot + Vector3(0, FLOOR_TOP, 0)
	member.rotation.y = turn
	members.append(member)


## Floor, outer walls with the entrance, the roof, the sign, the wall between the bar and the workshop and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	_build.wall("z", SHOP_X, BACK_Z, HALF_Z, 0, [SHOP_DOOR_Z], INSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_BIKER"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = Color(1.0, 0.55, 0.2)
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-6.0, 2.5, 7.0]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The bar's counter with its bottles and stools, the tables, the coat rack, and the workshop's moped, crates and
## tool wall.
func _build_bar() -> void:
	_build.box(COUNTER_AT + Vector3(0, FLOOR_TOP + COUNTER_SIZE.y / 2, 0), COUNTER_SIZE, WOOD)
	_build.mesh_box(COUNTER_AT + Vector3(0, FLOOR_TOP + COUNTER_SIZE.y + 0.02, 0), COUNTER_SIZE + Vector3(0.1, -1.06,
		0.1), WOOD.darkened(0.3))
	_build.box(Vector3(-HALF_X + 0.25, FLOOR_TOP + 1.5, 5.0), Vector3(0.3, 0.06, 5.0), WOOD.darkened(0.2))
	for i in 9:
		var bottle := CylinderMesh.new()
		bottle.top_radius = 0.03
		bottle.bottom_radius = 0.05
		bottle.height = 0.3
		_build.mesh(bottle, Vector3(-HALF_X + 0.25, FLOOR_TOP + 1.68, 3.0 + i * 0.5),
			[Color(0.2, 0.5, 0.25), Color(0.5, 0.3, 0.1), Color(0.75, 0.75, 0.7)][i % 3])
	for at in STOOLS:
		_build.box(at + Vector3(0.5, FLOOR_TOP + 0.35, 0), Vector3(0.4, 0.7, 0.4), STEEL.darkened(0.3))
	for at in TABLES:
		_build.box(at + Vector3(0, FLOOR_TOP + TABLE_SIZE.y / 2, 0), TABLE_SIZE, WOOD.lightened(0.1))
	_build.box(RACK_AT + Vector3(0, FLOOR_TOP + 0.9, 0), Vector3(0.12, 1.8, 0.12), STEEL.darkened(0.4))
	_build.mesh_box(RACK_AT + Vector3(0, FLOOR_TOP + 1.75, 0), Vector3(0.6, 0.06, 0.06), STEEL.darkened(0.4))
	# The workshop: concrete floor, the boss's moped on its stand, crates and the tool wall.
	_build.mesh_box(Vector3((SHOP_X + HALF_X) / 2, FLOOR_TOP + 0.004, HALF_Z / 2), Vector3(HALF_X - SHOP_X - 0.1, 0.008,
		HALF_Z - 0.1), CONCRETE)
	var moped := StaticBody3D.new()
	moped.name = "Moped"
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 1.4, 1.7)
	shape.shape = box
	shape.position.y = 0.7
	moped.add_child(shape)
	moped.add_child(MOPED_MODEL.instantiate())
	moped.position = MOPED_AT + Vector3(0, FLOOR_TOP, 0)
	$Built.add_child(moped)
	for at in CRATES:
		_build.box(at + Vector3(0, FLOOR_TOP + 0.4, 0), Vector3(1.1, 0.8, 0.9), WOOD.lightened(0.2))
	_build.mesh_box(Vector3(HALF_X - 0.06, 1.6, 5.0), Vector3(0.04, 1.4, 3.0), Color(0.25, 0.25, 0.3))
	for i in 5:
		_build.mesh_box(Vector3(HALF_X - 0.1, 1.3 + (i % 2) * 0.5, 3.8 + i * 0.6), Vector3(0.04, 0.4, 0.06), STEEL)


## The patio's concrete floor (step 3 brings its arm-wrestling table, the heavy bike and the line) and El Cromado's
## office with its desk.
func _build_back_rooms() -> void:
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [PATIO_DOOR_X, OFFICE_DOOR_X], INSIDE)
	_build.wall("z", SHOP_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	_build.mesh_box(Vector3((SHOP_X - HALF_X) / 2, FLOOR_TOP + 0.004, -HALF_Z / 2), Vector3(HALF_X + SHOP_X - 0.1, 0.008,
		HALF_Z - 0.1), CONCRETE)
	_build.box(Vector3(8.5, FLOOR_TOP + 0.4, -3.0), Vector3(2.4, 0.8, 1.0), WOOD.darkened(0.2))
	_build.box(Vector3(HALF_X - 0.35, FLOOR_TOP + 0.9, -7.0), Vector3(0.5, 1.8, 2.4), STEEL.darkened(0.3))
