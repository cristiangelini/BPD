class_name BankLevel
extends Node3D

## The neighborhood bank, robbed live (docs/diseno/robo-banco.md, step 1, decision 102): one floor on its lot in the
## city, the front to +Z. The hall has the queue posts and the benches by the entrance, the open floor where the
## hostages lie, and the tellers' counter across it with a gap at the east end. Behind the counter, a back wall with
## two doors: the manager's office (west, with the air vent high in its outer wall, reached standing on a partner) and
## the corridor to the vault (east, behind its round steel door) and to the back door (locked; the key comes later).
## The robbers' van waits parked on the street. The cops start in the station and drive here; --place=bank opens it
## from Play. Step 2 adds the four robbers at their tasks (BankRobber: the rabbit at the entrance, the pig over the
## hostages, the duck at the vault, El Oso behind the counter) and the hostages crouched on the hall's floor. The
## drill (BankDrill, step 3) stands in front of the vault's door with the duck beside it; when it gets through, the
## door swings open. Step 4: robbers cuffed from behind are walked to the patrol car (OwnerEscort; four seats, two of
## them in the trunk), the pig runs to the van when he sees a cop, and hostages led out by the hand go free. Step 5:
## the phone on the patrol car's side (BankPhone) to deal with El Oso; each kept promise lets a hostage go. Step 6a:
## the traffic control's barrier and cones wait at the station's door to box the van in (van_boxed_in). When the
## drill gets through, the robbers still loose take a sack of money each and go; if El Oso is one of them, he gets
## away in the van, or on foot and slower if it's boxed in, and the chase is on (ChaseCase.begin). The case and its
## end are BankCase's (step 6b): the comisario gives it over the radio as the shift starts. Online the host's bank
## decides and a guest's follows it (`follower`, BankCase's snapshot).
## Half the seeds are the variant where the hostages don't want to leave (robo-banco-rehenes.md, decision 121): the
## hall is a party, with garlands, the robbers' boombox on the bench and a tray of croissants on the counter, and the
## hostages sway to the music. --bank=party or --bank=base forces one.
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const VAN_MODEL := preload("res://assets/models/robbers_van.glb")
const WHEEL_MODEL := preload("res://assets/models/car_wheel.glb")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
const ENTRANCE_X := 0.0
## The tellers' counter across the hall, with its gap to walk behind it at the east end.
const COUNTER_Z := -1.0
const COUNTER_FROM := -10.0
const COUNTER_GAP := Vector2(6.8, 8.2)
const COUNTER_SIZE := Vector2(0.7, 1.1)
## The back wall behind the tellers, with the office's door (west) and the corridor's (middle).
const BACK_Z := -4.5
const OFFICE_DOOR_X := -7.0
const CORRIDOR_DOOR_X := 0.0
## The office (west) and the corridor (middle, to the back door) split by this wall; the vault east of VAULT_X.
const OFFICE_X := -3.0
const VAULT_X := 3.0
const BACK_DOOR_X := 0.0
## The vault's doorway in its west wall, and its round steel door (step 3 opens it).
const VAULT_DOOR_Z := -7.5
const VAULT_DOOR_RADIUS := 1.0
## The air vent: a hole high in the office's outer wall (x = -HALF_X), its bottom above a jump but within reach from a
## partner's shoulders, tall enough to crawl through crouched.
const VENT_Z := -8.0
const VENT_BOTTOM := 1.5
const VENT_SIZE := Vector2(1.0, 1.15)
## Where the hostages lie (step 2): the open floor between the queue and the counter.
const HOSTAGE_AREA := Rect2(-8.0, 1.0, 13.0, 5.5)
## The robbers' van, parked along the curb east of the entrance, nose to the west.
const VAN_AT := Vector3(8.0, 0, HALF_Z + CityLayout.SIDEWALK + 2.2)
const VAN_WHEELS: Array[Vector3] = [Vector3(-1.1, 0.38, 1.7), Vector3(1.1, 0.38, 1.7), Vector3(-1.1, 0.38, -1.7),
	Vector3(1.1, 0.38, -1.7)]
const VAN_SIZE := Vector3(2.2, 2.3, 5.2)
## Where each robber stands and which way they face (their body's yaw): the rabbit by the entrance looking at the
## door, the pig in front of the counter looking at the hostages, the duck in the corridor looking at the vault's
## door and El Oso behind the middle desk looking at the hall.
const ROBBER_SPOTS := {
	"conejo": [Vector3(2.0, 0, 8.5), PI],
	"chancho": [Vector3(-1.5, 0, 0.0), PI],
	"pato": [Vector3(1.4, 0, -6.8), -1.12],
	"oso": [Vector3(-2.5, 0, -3.4), PI],
}
## The drill on its tripod, its bit's tip against the vault's door, facing east.
const DRILL_AT := Vector3(VAULT_X - 0.15 - 0.1 - BankDrill.BIT_AT.z - BankDrill.BIT_LENGTH, 0, VAULT_DOOR_Z)
## How the vault's door ends up when the drill gets through: swung into the vault on its hinge at the doorway's edge.
const VAULT_DOOR_OPEN := Vector3(VAULT_X + VAULT_DOOR_RADIUS + 0.05, 0, VAULT_DOOR_Z - VAULT_DOOR_RADIUS - 0.12)
## Where each robber rides in the patrol car once walked there (shifted from the prisoner's seat): the two at the
## back seat, two in the trunk.
const ROBBER_SEATS: Array[Vector3] = [Vector3(-0.35, 0, 0), Vector3(0.35, 0, 0), ChaseCase.TRUNK_SEAT,
	ChaseCase.TRUNK_SEAT + Vector3(0, 0.5, 0)]
## The pig's run to the van: across the hall between the queue posts, out of the entrance and to the van's side.
const PIG_RUN: Array[Vector3] = [Vector3(-0.4, 0, 6.0), Vector3(ENTRANCE_X, 0, HALF_Z + 1.0),
	Vector3(VAN_AT.x, 0, VAN_AT.z - 1.6)]
## Where the phone hangs on the patrol car: on its side, by the driver's door, at hand's height.
const PHONE_ON_CAR := Vector3(-1.2, 1.0, 0.4)
## The perimeter: the barrier within BARRIER_REACH of the van's nose and PERIMETER_CONES standing cones within
## CONES_REACH of its middle box it in. They wait by the station's door, where the traffic control has them.
const PERIMETER_CONES := 4
const CONES_REACH := 5.0
const BARRIER_REACH := 3.5
const CONES := 6
const BARRIER_FROM_DOOR := Vector3(6, 0, 1.5)
const CONES_FROM_DOOR := Vector3(-5, 0, 1.5)
## The hostages: rows across the hostages' floor, facing the counter.
const HOSTAGES := 8
const HOSTAGE_XS: Array[float] = [-6.5, -3.5, -0.5, 2.5]
const HOSTAGE_ZS: Array[float] = [2.5, 4.8]
## The party (robo-banco-rehenes.md, step 1): garlands hung across the hall in rows under the roof, the boombox on the
## west bench and the croissants' tray on the counter.
const GARLAND_MODEL := preload("res://assets/models/bank_garland.glb")
const BOOMBOX_MODEL := preload("res://assets/models/bank_boombox.glb")
const TRAY_MODEL := preload("res://assets/models/bank_croissant_tray.glb")
const GARLAND_XS: Array[float] = [-10.0, -6.0, -2.0, 2.0, 6.0, 10.0]
const GARLAND_ZS: Array[float] = [1.2, 4.0, 6.8]
const GARLAND_DROP := 0.12
const BOOMBOX_AT := Vector3(-10.0, 0.44, 6.6)
const TRAY_AT := Vector3(-4.0, COUNTER_SIZE.y + 0.04, COUNTER_Z)

const OUTSIDE := Color(0.86, 0.84, 0.78)
const INSIDE := Color(0.93, 0.92, 0.88)
const MARBLE := Color(0.78, 0.76, 0.72)
const WOOD := Color(0.45, 0.28, 0.16)
const STEEL := Color(0.55, 0.58, 0.62)
const GOLD := Color(0.85, 0.7, 0.3)
const ROPE := Color(0.7, 0.12, 0.15)
const MONEY := Color(0.45, 0.62, 0.38)

var back_door: FrontDoor
## The vault's steel door, a body that closes the doorway until the drill gets through (step 3).
var vault_door: StaticBody3D
var van: Node3D
## The case's seed: which neighbors are the hostages.
var case_seed := 0
var robbers: Array[BankRobber] = []
## El Oso, the one to cuff.
var boss: BankRobber
var hostages: Array[BankHostage] = []
## The variant where the hostages are having a party and don't want to leave (decision 121).
var party := false
var croissant_tray: Node3D
var drill: BankDrill
var hostages_freed := 0
var phone: BankPhone
## How many sacks of money the robbers got away with, the getaway chase if El Oso ran, and how it ended.
var bags_taken := 0
var chase: ChaseCase
var getaway_over := false
var getaway_caught := false
var case: BankCase
## A guest's bank: the host's says how many sacks went and how El Oso gets away (start_getaway).
var follower := false
var station_parking: Transform3D
var _build: PlaceBuilder

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	party = is_party(case_seed, OS.get_cmdline_user_args())
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_hall()
	_build_back()
	if party:
		_add_party()
	back_door = DOOR_SCENE.instantiate()
	back_door.name = "BackDoor"
	back_door.position = Vector3(BACK_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, -HALF_Z)
	add_child(back_door)
	_add_vault_door()
	_add_van()
	_add_robbers()
	_add_hostages()
	drill = BankDrill.new()
	drill.name = "Drill"
	drill.position = DRILL_AT + Vector3.UP * FLOOR_TOP
	drill.rotation.y = PI / 2
	add_child(drill)
	drill.watch(robbers)
	drill.opened.connect(open_vault)
	drill.opened.connect(_on_vault_opened)
	phone = BankPhone.new()
	phone.name = "Phone"
	phone.position = PHONE_ON_CAR
	phone.setup(self, car, case_seed)
	car.add_child(phone)
	car.add_collision_exception_with(phone)
	city.transform = CityLayout.anchor("bank")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	_add_perimeter()
	case = BankCase.new()
	case.name = "Case"
	case.bank = self
	case.shift_screen = $ShiftScreen
	add_child(case)
	case.start()


## Whether this seed's robbery is the party where the hostages don't want to leave: from --bank=party or --bank=base
## among the user args, or half the seeds (propuesta).
static func is_party(seed_: int, args: PackedStringArray) -> bool:
	for arg in args:
		if arg == "--bank=party":
			return true
		if arg == "--bank=base":
			return false
	return hash(["bank party", seed_]) % 2 == 0


## The party's things: the garlands across the hall, the boombox playing on the bench (its notes bobbing over it) and
## the croissants' tray on the counter.
func _add_party() -> void:
	var party_node := Node3D.new()
	party_node.name = "Party"
	add_child(party_node)
	for z in GARLAND_ZS:
		for x in GARLAND_XS:
			var garland: Node3D = GARLAND_MODEL.instantiate()
			garland.position = Vector3(x, ROOF - GARLAND_DROP, z)
			party_node.add_child(garland)
	var boombox: Node3D = BOOMBOX_MODEL.instantiate()
	boombox.name = "Boombox"
	boombox.position = BOOMBOX_AT + Vector3.UP * FLOOR_TOP
	boombox.rotation.y = PI / 2
	party_node.add_child(boombox)
	var notes := Label3D.new()
	notes.name = "Notes"
	notes.text = "♪ ♫"
	notes.font_size = 64
	notes.pixel_size = 0.006
	notes.outline_size = 10
	notes.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	notes.modulate = Color(0.48, 0.88, 1.0)
	notes.position = Vector3(0, 0.75, 0)
	boombox.add_child(notes)
	var bob := notes.create_tween().set_loops()
	bob.tween_property(notes, "position:y", 0.95, 0.5).set_trans(Tween.TRANS_SINE)
	bob.tween_property(notes, "position:y", 0.75, 0.5).set_trans(Tween.TRANS_SINE)
	croissant_tray = TRAY_MODEL.instantiate()
	croissant_tray.name = "CroissantTray"
	croissant_tray.position = TRAY_AT + Vector3.UP * FLOOR_TOP
	party_node.add_child(croissant_tray)


## Whether a world position is inside the bank.
func inside(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z


## Whether a world position is on the hostages' floor.
func in_hostage_area(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return HOSTAGE_AREA.has_point(Vector2(local.x, local.z))


## Floor, outer walls with the entrance and the vent, the roof, the facade with its columns and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, MARBLE)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [BACK_DOOR_X], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	_vent_wall()
	# The facade: a parapet over the roof, four columns and steps up to the entrance.
	_build.box(Vector3(0, ROOF + 0.7, HALF_Z), Vector3(HALF_X * 2, 1.4, 0.3), OUTSIDE)
	for x: float in [-4.5, -1.6, 1.6, 4.5]:
		_build.box(Vector3(x, ROOF / 2, HALF_Z + 0.45), Vector3(0.45, ROOF, 0.45), INSIDE)
	_build.box(Vector3(0, ROOF + 0.05, HALF_Z + 0.45), Vector3(10.0, 0.1, 1.0), INSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_BANK"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = GOLD
	sign_label.position = Vector3(0, ROOF + 0.7, HALF_Z + 0.2)
	$Built.add_child(sign_label)
	for x: float in [-8.0, 0.0, 8.0]:
		for z: float in [-7.5, -2.5, 3.0, 7.5]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The west outer wall, with the vent's hole into the office and its bent grille hanging off one screw.
func _vent_wall() -> void:
	var x := -HALF_X
	var a := VENT_Z - VENT_SIZE.x / 2
	var b := VENT_Z + VENT_SIZE.x / 2
	var height := ROOF - PlaceBuilder.SLAB
	_build.box(Vector3(x, height / 2, (-HALF_Z + a) / 2), Vector3(PlaceBuilder.WALL, height, a + HALF_Z), OUTSIDE)
	_build.box(Vector3(x, height / 2, (b + HALF_Z) / 2), Vector3(PlaceBuilder.WALL, height, HALF_Z - b), OUTSIDE)
	_build.box(Vector3(x, VENT_BOTTOM / 2, VENT_Z), Vector3(PlaceBuilder.WALL, VENT_BOTTOM, VENT_SIZE.x), OUTSIDE)
	var top := VENT_BOTTOM + VENT_SIZE.y
	if height > top:
		_build.box(Vector3(x, (top + height) / 2, VENT_Z), Vector3(PlaceBuilder.WALL, height - top, VENT_SIZE.x), OUTSIDE)
	_build.mesh_box(Vector3(x - 0.12, VENT_BOTTOM - 0.2, VENT_Z + 0.4), Vector3(0.03, VENT_SIZE.y * 0.8, VENT_SIZE.x * 0.8),
		STEEL)


## The queue posts with their rope, two benches, the plant and the tellers' counter with its three desks behind.
func _build_hall() -> void:
	for i in 5:
		var at := Vector3(-6.0 + i * 1.6, FLOOR_TOP, 7.5)
		_build.box(at + Vector3(0, 0.45, 0), Vector3(0.12, 0.9, 0.12), GOLD)
		if i < 4:
			_build.mesh_box(at + Vector3(0.8, 0.82, 0), Vector3(1.5, 0.05, 0.05), ROPE)
	for x: float in [-10.0, 9.5]:
		_build.box(Vector3(x, FLOOR_TOP + 0.22, 6.0), Vector3(0.6, 0.44, 2.4), WOOD)
	_build.box(Vector3(10.8, FLOOR_TOP + 0.3, 9.0), Vector3(0.6, 0.6, 0.6), WOOD.darkened(0.3))
	_build.mesh_box(Vector3(10.8, FLOOR_TOP + 1.0, 9.0), Vector3(0.7, 0.8, 0.7), Color(0.3, 0.6, 0.3))
	var top := FLOOR_TOP + COUNTER_SIZE.y
	for piece: Vector2 in [Vector2(COUNTER_FROM, COUNTER_GAP.x), Vector2(COUNTER_GAP.y, HALF_X)]:
		var middle := (piece.x + piece.y) / 2
		_build.box(Vector3(middle, FLOOR_TOP + COUNTER_SIZE.y / 2, COUNTER_Z), Vector3(piece.y - piece.x,
			COUNTER_SIZE.y, COUNTER_SIZE.x), WOOD)
		_build.mesh_box(Vector3(middle, top + 0.02, COUNTER_Z), Vector3(piece.y - piece.x, 0.04, COUNTER_SIZE.x + 0.06),
			MARBLE.darkened(0.2))
	# The counter's west end closes against a short wall, so the only way behind it is the gap.
	_build.wall("z", COUNTER_FROM, BACK_Z, COUNTER_Z, 0, [], INSIDE)
	for x: float in [-6.5, -2.5, 1.5]:
		_build.legs(Vector3(x, FLOOR_TOP, COUNTER_Z - 1.4), Vector2(1.4, 0.6), 0.72, WOOD)
		_build.box(Vector3(x, FLOOR_TOP + 0.74, COUNTER_Z - 1.4), Vector3(1.4, 0.04, 0.6), WOOD)


## The back wall with its two doors, the office (desk, filing cabinet), the corridor to the back door and the vault with
## its shelves of money.
func _build_back() -> void:
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [OFFICE_DOOR_X, CORRIDOR_DOOR_X], INSIDE)
	_build.wall("z", OFFICE_X, -HALF_Z, BACK_Z, 0, [], INSIDE)
	_build.wall("z", VAULT_X, -HALF_Z, BACK_Z, 0, [VAULT_DOOR_Z], STEEL)
	# The corridor runs straight from its door to the back door, with the vault's doorway on its east side.
	_build.legs(Vector3(-7.5, FLOOR_TOP, -8.2), Vector2(1.8, 0.9), 0.72, WOOD)
	_build.box(Vector3(-7.5, FLOOR_TOP + 0.74, -8.2), Vector3(1.8, 0.04, 0.9), WOOD)
	_build.box(Vector3(-4.0, FLOOR_TOP + 0.7, -9.5), Vector3(0.6, 1.4, 0.6), STEEL.darkened(0.2))
	for z: float in [-7.0, -8.6]:
		_build.open_box(Vector3(11.4, FLOOR_TOP, z), Vector3(0.8, 2.0, 1.4), "-x", STEEL)
		for level: float in [0.4, 1.0, 1.6]:
			_build.mesh_box(Vector3(11.3, FLOOR_TOP + level + 0.12, z), Vector3(0.5, 0.22, 1.1), MONEY)
	var label := Label3D.new()
	label.text = "BANK_VAULT"
	label.font_size = 48
	label.pixel_size = 0.01
	label.position = Vector3(VAULT_X - 0.1, 2.3, VAULT_DOOR_Z)
	label.rotation.y = -PI / 2
	$Built.add_child(label)


## The vault's round steel door, closing its doorway from the corridor side, with its wheel.
func _add_vault_door() -> void:
	vault_door = StaticBody3D.new()
	vault_door.name = "VaultDoor"
	vault_door.position = Vector3(VAULT_X - 0.15, FLOOR_TOP + VAULT_DOOR_RADIUS + 0.05, VAULT_DOOR_Z)
	add_child(vault_door)
	var shape := CollisionShape3D.new()
	var body := BoxShape3D.new()
	body.size = Vector3(0.2, VAULT_DOOR_RADIUS * 2, VAULT_DOOR_RADIUS * 2)
	shape.shape = body
	vault_door.add_child(shape)
	var disc := CylinderMesh.new()
	disc.top_radius = VAULT_DOOR_RADIUS
	disc.bottom_radius = VAULT_DOOR_RADIUS
	disc.height = 0.2
	var steel := MeshInstance3D.new()
	steel.mesh = disc
	steel.rotation.z = PI / 2
	steel.material_override = _build.material(STEEL.lightened(0.1))
	vault_door.add_child(steel)
	var wheel := TorusMesh.new()
	wheel.inner_radius = 0.25
	wheel.outer_radius = 0.32
	var handle := MeshInstance3D.new()
	handle.mesh = wheel
	handle.position.x = -0.14
	handle.rotation.z = PI / 2
	handle.material_override = _build.material(GOLD)
	vault_door.add_child(handle)


## The robbers' van parked along the curb, a body so the patrol car bumps into it (step 6 drives it off).
func _add_van() -> void:
	van = StaticBody3D.new()
	van.name = "Van"
	van.position = VAN_AT
	van.rotation.y = -PI / 2
	add_child(van)
	var shape := CollisionShape3D.new()
	var body := BoxShape3D.new()
	body.size = VAN_SIZE
	shape.shape = body
	shape.position.y = VAN_SIZE.y / 2 + 0.2
	van.add_child(shape)
	van.add_child(VAN_MODEL.instantiate())
	for at in VAN_WHEELS:
		var wheel: Node3D = WHEEL_MODEL.instantiate()
		wheel.position = at
		van.add_child(wheel)


func _add_robbers() -> void:
	for animal: String in BankRobber.ANIMALS:
		var robber := BankRobber.new()
		robber.name = "Robber_" + animal
		robber.animal = animal
		robber.position = ROBBER_SPOTS[animal][0] + Vector3.UP * FLOOR_TOP
		robber.rotation.y = ROBBER_SPOTS[animal][1]
		add_child(robber)
		robbers.append(robber)
		var escort := OwnerEscort.attach(robber, car)
		escort.seat_shift = ROBBER_SEATS[robbers.size() - 1]
		escort.in_car_hint = "HINT_OWNER_IN_CAR" if robber.is_boss() else "HINT_ROBBER_IN_CAR"
		if animal == "chancho":
			for at in PIG_RUN:
				robber.run_path.append(global_transform * at)
		if robber.is_boss():
			boss = robber


## The hostages, a different set of neighbors for each seed.
func _add_hostages() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["bank hostages", case_seed])
	var looks := BankHostage.LOOKS.duplicate()
	for i in range(looks.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = looks[i]
		looks[i] = looks[j]
		looks[j] = swap
	for i in HOSTAGES:
		var hostage := BankHostage.new()
		hostage.name = "Hostage%d" % i
		hostage.look = looks[i % looks.size()]
		hostage.next_line = i
		hostage.partying = party
		hostage.sway_phase = rng.randf() * TAU
		hostage.position = Vector3(HOSTAGE_XS[i % HOSTAGE_XS.size()], FLOOR_TOP, HOSTAGE_ZS[i / HOSTAGE_XS.size()])
		hostage.is_out = func(at: Vector3) -> bool: return not inside(at)
		hostage.freed_now.connect(func(_hostage: BankHostage) -> void: hostages_freed += 1)
		add_child(hostage)
		hostages.append(hostage)


## The drill got through: the vault's door swings open against the vault's inner wall and stops blocking.
func open_vault() -> void:
	vault_door.position = Vector3(VAULT_DOOR_OPEN.x, vault_door.position.y, VAULT_DOOR_OPEN.z)
	vault_door.rotation.y = PI / 2


## El Oso keeps his word: the first hostage still on the floor walks out of the entrance and goes free.
func release_hostage() -> void:
	for hostage in hostages:
		if not hostage.freed and not hostage.led_by:
			hostage.global_position = global_transform * Vector3(ENTRANCE_X, FLOOR_TOP, HALF_Z + 1.5)
			hostage.free_hostage()
			return


## The barrier and the cones by the station's door, as for the traffic control.
func _add_perimeter() -> void:
	var door := city.transform * CityLayout.door_of("station")
	var barrier := RoadBarrier.new()
	barrier.name = "Barrier"
	add_child(barrier)
	barrier.global_position = door + BARRIER_FROM_DOOR + Vector3.UP * 0.05
	for i in CONES:
		var cone := TrafficCone.new()
		cone.name = "Cone%d" % i
		add_child(cone)
		cone.global_position = door + CONES_FROM_DOOR + Vector3(-0.8 * i, 0.05, 0)


## Whether the cops boxed the van in: the barrier at its nose and enough cones standing around it.
func van_boxed_in() -> bool:
	if not is_instance_valid(van):
		return false
	var nose := van.global_position + van.global_basis * Vector3(0, 0, VAN_SIZE.z / 2)
	var barrier_ok := false
	for barrier: Node3D in get_tree().get_nodes_in_group("road_barriers"):
		if _flat_distance(barrier.global_position, nose) < BARRIER_REACH:
			barrier_ok = true
	var cones := 0
	for cone: TrafficCone in get_tree().get_nodes_in_group("traffic_cones"):
		if cone.standing() and _flat_distance(cone.global_position, van.global_position) < CONES_REACH:
			cones += 1
	return barrier_ok and cones >= PERIMETER_CONES


static func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


## Whether a robber is still free: not cuffed, not being walked and not in the patrol car (the pig in the van is).
static func is_loose(robber: BankRobber) -> bool:
	var escort := OwnerEscort.of(robber)
	return not robber.is_cuffed() and not (escort and (escort.in_car or escort.escorted_by))


## The vault is open: every robber still loose grabs a sack and leaves; El Oso among them, the chase is on.
func _on_vault_opened() -> void:
	if follower:
		return
	var boss_runs := is_loose(boss)
	for robber in robbers:
		if is_loose(robber):
			bags_taken += 1
			robber.hide()
			robber.collision_layer = 0
			robber.process_mode = Node.PROCESS_MODE_DISABLED
	if boss_runs:
		start_getaway(SuspectCar.BEAR_ON_FOOT if van_boxed_in() else SuspectCar.ROBBERS_VAN)


## El Oso gets away in the van (`kind` ROBBERS_VAN) or on foot (BEAR_ON_FOOT): the chase is on.
func start_getaway(kind: String) -> void:
	if chase:
		return
	var at := Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, FLOOR_TOP, HALF_Z + 1.5))
	if kind == SuspectCar.ROBBERS_VAN and is_instance_valid(van):
		at = van.global_transform
		van.queue_free()
	chase = ChaseCase.begin(self, kind, at, car, city, case_seed)
	chase.who = "oso"
	chase.follower = follower
	if case:
		chase.online = case.online
	chase.ended.connect(_on_getaway_ended)
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_ESCAPE_oso" if kind == SuspectCar.ROBBERS_VAN else "HINT_ESCAPE_oso_FOOT")


func _on_getaway_ended(was_caught: bool) -> void:
	getaway_over = true
	getaway_caught = was_caught
