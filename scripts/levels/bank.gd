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
## A quarter of the seeds are the variant where the hostages don't want to leave (robo-banco-rehenes.md, decision 121): the
## hall is a party, with garlands, the robbers' boombox on the bench and a tray of croissants on the counter, and the
## hostages sway to the music. Two of them are fans of the gang, with a cardboard mask, who warn the robbers when they
## see a cop (SNITCHES). A quarter of the seeds are the grandpa robbers (robo-banco-abuelos.md, decision 122): the same
## gang, retired, with cane and cardigan; they walk at half pace and their old drill takes longer (BankDrill.SLOW_TIME).
## A quarter are the sorry robber (robo-banco-arrepentido.md, decision 123): one of the three under El Oso cries under
## his mask with a white hanky and wants to give it all back. In every robbery Mr. Moneda, the manager, waits in
## pajamas on the sidewalk by his car and gives the back door's key to whoever talks to him (BankManager,
## robo-banco-gerente.md, decision 124); a fifth of the seeds he's the gang's real boss, and the others share the rest
## in quarters. A sixth of the seeds, drawn before them, the duck's drill punctured the pipe behind the vault and the
## bank floods (BankWater, robo-banco-inundado.md, decision 125). A seventh, drawn before everything, the gang leaves
## by the roof (robo-banco-techo.md, decision 126): fire escape stairs up the east wall, a hatch in the corridor's
## ceiling, the giant toy helicopter on its helipad on the roof (ToyHelicopter) and El Oso's nephew with its remote on a
## bench across the street (BankNephew), who flies it away when he sees a cop on the roof; taken off the roof, the gang
## can't leave by it. Cuffing the nephew crashes it (+100). An eighth, drawn before everything, is the town bank
## (robo-banco-pueblo.md, decision 127): a wall of shelves cuts the hall down to a small one with no queue, Mr. Moneda
## isn't there, there are no hostages on the floor but don Plácido, the only clerk, asleep on his stool behind the
## counter (BankClerk), and the gang is El Conejo alone, at the drill. A ninth, drawn before everything, is the blood
## bank (robo-banco-sangre.md, decision 128): the power is cut at night, candles burn in the dark hall, the vault is a
## white fridge full of blood bags, the hostages came to give blood and the gang wears vampire capes and fangs
## (BankBlood). --bank=party, --bank=grandpas, --bank=sorry, --bank=manager, --bank=flood, --bank=roof, --bank=town,
## --bank=blood or --bank=base forces one.
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
## The manager's car, parked along the curb west of the entrance, and the two ends of his pacing on the sidewalk
## beside it (robo-banco-gerente.md, step 1).
const MANAGER_CAR_MODEL := preload("res://assets/models/manager_car.glb")
const MANAGER_CAR_AT := Vector3(-8.0, 0, VAN_AT.z)
const MANAGER_CAR_WHEELS: Array[Vector3] = [Vector3(-1.05, 0.38, 1.55), Vector3(1.05, 0.38, 1.55),
	Vector3(-1.05, 0.38, -1.55), Vector3(1.05, 0.38, -1.55)]
const MANAGER_CAR_SIZE := Vector3(2.1, 1.5, 4.6)
const MANAGER_SPOTS: Array[Vector3] = [Vector3(-10.0, 0, HALF_Z + 2.0), Vector3(-5.5, 0, HALF_Z + 2.0)]
## The boss manager's walkie (step 2): with no cop this close to him (m), the drill hurries this long (s).
const WALKIE_NEAR := 6.0
const WALKIE_HURRY := 10.0
## Where the boss manager rides in the patrol car once walked there (step 3): the fifth one, on top of the two in the
## trunk.
const MANAGER_SEAT := ChaseCase.TRUNK_SEAT + Vector3(0, 1.0, 0)
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
## The way back in for the party's hostage El Oso let go: through the entrance and between the queue posts.
const WAY_IN: Array[Vector3] = [Vector3(ENTRANCE_X, 0, HALF_Z - 1.5), Vector3(-0.4, 0, 6.0)]
## The free spots on the hostages' floor, between its two rows, where the grandpa robbers sit down to pass for hostages
## (robo-banco-abuelos.md, step 2).
const HIDE_SPOTS: Array[Vector3] = [Vector3(-5.0, 0, 3.65), Vector3(-2.0, 0, 3.65), Vector3(1.0, 0, 3.65),
	Vector3(4.0, 0, 3.65)]
## Where the duck grandma's marbles land: on the hall's floor in front of the entrance (robo-banco-abuelos.md, step 3).
const MARBLES_AT := Vector3(ENTRANCE_X + 0.6, 0, HALF_Z - 1.3)
## Who can be the sorry robber: never El Oso.
const SORRY_ANIMALS: Array[String] = ["conejo", "chancho", "pato"]
## The sorry robber's ways (robo-banco-arrepentido.md, steps 2 and 3): between the hall and the corridor he goes by
## the counter's gap, behind the counter and through the corridor's door; out of the back door counts as the
## corridor's side. Where he opens the back door from, where he unplugs the drill (past the duck, by the vault's door)
## and where he leaves the two hostages, out of the back door far enough for them to be out too.
const HALL_TO_CORRIDOR: Array[Vector3] = [Vector3(7.5, 0, 0.4), Vector3(7.5, 0, -2.6), Vector3(CORRIDOR_DOOR_X, 0, -3.7),
	Vector3(CORRIDOR_DOOR_X, 0, BACK_Z - 0.6)]
const AT_BACK_DOOR := Vector3(BACK_DOOR_X, 0, -HALF_Z + 0.9)
const AT_DRILL := Vector3(0.6, 0, VAULT_DOOR_Z - 0.5)
const OUT_BACK := Vector3(BACK_DOOR_X, 0, -HALF_Z - 1.4)
## How long the unplugged drill stands still, and how many hostages he walks out.
const UNPLUGGED := 60.0
const SORRY_HOSTAGES := 2
## The flooding bank's valve (robo-banco-inundado.md, step 2): on the back wall, outside, east of the back door.
const VALVE_AT := Vector3(BACK_DOOR_X + 2.2, 0, -HALF_Z - 0.15)
## Step 3: where the hostages get up on the counter, one each from the west end, and the duck floats in the patrol
## car's trunk.
const PERCH_XS: Array[float] = [-9.3, -7.9, -6.5, -5.1, -3.7, -2.3, -0.9, 0.5]
const FLOATS_IN_TRUNK := Vector3(0, 0.45, -1.75)
## The roof robbery (decision 126): the fire escape's foot outside the east wall (it climbs to -Z), its landing at the
## roof, the hatch in the corridor's ceiling, the helipad on the roof and the nephew's bench on the sidewalk across.
const ESCAPE_FOOT := Vector3(HALF_X + 0.9, 0, 0.0)
const ESCAPE_RUN := 5.0
const LANDING := Vector2(1.4, 1.4)
const HATCH_AT := Vector3(-1.8, 0, -6.0)
const HATCH_SIZE := 0.9
const HELIPAD_AT := Vector3(6.0, 0, -1.0)
const HELIPAD_SIZE := 3.6
const NEPHEW_BENCH := Vector3(-4.0, 0, HALF_Z + CityLayout.SIDEWALK + CityLayout.STREET + 1.6)
const PAINT := Color(0.95, 0.95, 0.9)
## The town bank (decision 127): the shelves' wall closing the hall's west side off, its shelves (heights over the
## floor) with jars and binders, the clerk's stool behind the counter and the hand-painted sign over the entrance.
const TOWN_WALL_X := -1.0
const TOWN_SHELVES: Array[float] = [0.5, 1.1, 1.7]
const TOWN_SHELF_ZS: Array[float] = [-3.0, 1.0, 3.0, 5.0, 7.0]
const CLERK_AT := Vector3(2.0, 0, COUNTER_Z - 0.75)
const STOOL_TOP := 0.55
## Step 4: El Conejo takes this many sacks when the vault opens.
const TOWN_SACKS := 2
const JAR := Color(0.85, 0.55, 0.25)
const BINDER := Color(0.25, 0.4, 0.7)
## Step 2: after a flight the nephew's remote needs this long (s) before it flies again; that's when the cops on the
## roof can take the helicopter. Off the roof (down on the street, in the trunk) it's taken: no getaway by the roof.
const NEPHEW_REST := 40.0
const ON_ROOF := 0.4
## Step 4: the nephew's shopping cart beside his bench, where the helicopter drops the sacks one trip at a time.
const CART_AT := NEPHEW_BENCH + Vector3(1.8, 0, 0)
const CART_SIZE := Vector3(0.6, 0.55, 0.9)
const CART_TOP := 0.95
const BAG_MODEL := preload("res://assets/models/money_bag.glb")
## Step 4: with this much water or more when the vault opens, the gang wades out with the sacks before they get away:
## up to WADE_OUT seconds with the water at the top, less the shallower it is.
const WADE_FROM := 0.2
const WADE_OUT := 12.0
## Where the gang ties the sorry robber when they catch him helping (step 4): a chair by the hall's west wall, facing
## the hall.
const CHAIR_AT := Vector3(-10.5, 0, 1.2)
const CHAIR_YAW := -PI / 2
## How many of the party's hostages are fans of the gang (propuesta).
const SNITCHES := 2
const GARLAND_MODEL := preload("res://assets/models/bank_garland.glb")
const BOOMBOX_MODEL := preload("res://assets/models/bank_boombox.glb")
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
## The variant where the robbers are grandpas (decision 122).
var grandpas := false
## The variant where one robber is sorry and wants to give it all back (decision 123): that robber, or null.
var sorry: BankRobber
var _sorry_variant := false
## Mr. Moneda, the manager, by his car outside (every robbery), and his car.
var manager: BankManager
var manager_car: StaticBody3D
## The boss manager's open trunk with the empty sacks (null when he's not the boss).
var manager_trunk: ManagerTrunk
## The duck grandma's marbles on the floor, once she threw them.
var marbles: BankMarbles
var croissant_tray: BankCroissantTray
var drill: BankDrill
## The flooding vault's water (decision 125), its valve out back and the front door that holds it in, or null.
var water: BankWater
var valve: BankValve
var front_door: FrontDoor
var floats: BankFloats
var roof := false
## The town bank (decision 127) and don Plácido, its clerk.
var town := false
var clerk: BankClerk
## The blood bank (decision 128), dark with its candles, and the hall's ceiling lamps (off in it).
var blood := false
var blood_bank: BankBlood
var lamps: Array[OmniLight3D] = []
## El Conejo's nerves (step 3).
var nerves: BankNerves
var helicopter: ToyHelicopter
var nephew: BankNephew
## Seconds until the nephew can fly the helicopter again, and whether the cops have taken it off the roof (said once).
var nephew_rest := 0.0
var helicopter_gone := false
## Step 4: the gang went up the hatch with the sacks; the sacks still on the roof, and the cart's.
var roof_getaway := false
var roof_bags := 0
var cart: Node3D
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
## Which robber took each of HIDE_SPOTS (by index).
var _hide_taken := {}

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var drawn := variant(case_seed, OS.get_cmdline_user_args())
	party = drawn == "party"
	grandpas = drawn == "grandpas"
	_sorry_variant = drawn == "sorry"
	var manager_boss := drawn == "manager"
	roof = drawn == "roof"
	town = drawn == "town"
	blood = drawn == "blood"
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_hall()
	_build_back()
	if roof:
		_build_roof()
	if town:
		_build_town()
	if party:
		_add_party()
	if _sorry_variant:
		_build.legs(CHAIR_AT + Vector3.UP * FLOOR_TOP, Vector2(0.5, 0.5), 0.45, WOOD)
		_build.box(CHAIR_AT + Vector3(0.0, FLOOR_TOP + 0.47, 0.0), Vector3(0.5, 0.04, 0.5), WOOD)
		_build.box(CHAIR_AT + Vector3(-0.23, FLOOR_TOP + 0.8, 0.0), Vector3(0.04, 0.65, 0.5), WOOD)
	back_door = DOOR_SCENE.instantiate()
	back_door.name = "BackDoor"
	back_door.position = Vector3(BACK_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, -HALF_Z)
	add_child(back_door)
	_add_vault_door()
	_add_van()
	_add_manager(manager_boss)
	_add_robbers()
	_add_hostages()
	drill = BankDrill.new()
	drill.name = "Drill"
	if grandpas:
		drill.drill_time = BankDrill.SLOW_TIME
	elif town:
		drill.drill_time = BankDrill.TOWN_TIME
	drill.position = DRILL_AT + Vector3.UP * FLOOR_TOP
	drill.rotation.y = PI / 2
	add_child(drill)
	drill.watch(robbers)
	drill.watch_hostages(hostages)
	drill.opened.connect(open_vault)
	drill.opened.connect(_on_vault_opened)
	if drawn == "flood":
		_add_water()
	phone = BankPhone.new()
	phone.name = "Phone"
	phone.position = PHONE_ON_CAR
	phone.setup(self, car, case_seed)
	phone.deaf = grandpas
	if town:
		phone.voice = "CONEJO"
	car.add_child(phone)
	car.add_collision_exception_with(phone)
	if town:
		_add_nerves()
	if blood:
		blood_bank = BankBlood.new()
		add_child(blood_bank)
		blood_bank.setup(self)
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


## Which robbery this seed is (propuesta): a ninth "blood" (the blood bank) drawn first, an eighth of the rest "town"
## (the town bank), then a seventh of the rest "roof" (they leave by the roof), a sixth "flood" (the vault floods), a
## fifth "manager" (the manager is the boss), and the rest in quarters: "party" (the hostages don't want to leave), "grandpas", "sorry" (one robber wants to give
## it all back) or "base"; --bank=party, --bank=grandpas, --bank=sorry, --bank=manager, --bank=flood, --bank=roof,
## --bank=town, --bank=blood or --bank=base among the user args forces one.
static func variant(seed_: int, args: PackedStringArray) -> String:
	for arg in args:
		if arg in ["--bank=party", "--bank=grandpas", "--bank=sorry", "--bank=manager", "--bank=flood", "--bank=roof",
				"--bank=town", "--bank=blood", "--bank=base"]:
			return arg.trim_prefix("--bank=")
	if hash(["bank sangre", seed_]) % 9 == 0:
		return "blood"
	if hash(["bank pueblo", seed_]) % 8 == 0:
		return "town"
	if hash(["bank azotea", seed_]) % 7 == 0:
		return "roof"
	if hash(["bank caño", seed_]) % 6 == 0:
		return "flood"
	if hash(["bank moneda", seed_]) % 5 == 0:
		return "manager"
	return ["party", "grandpas", "sorry", "base"][hash(["bank party", seed_]) % 4]


## Which of the three under El Oso is the sorry robber for this seed (robo-banco-arrepentido.md, decision 123).
static func sorry_animal(seed_: int) -> String:
	return SORRY_ANIMALS[hash(["bank sorry", seed_]) % SORRY_ANIMALS.size()]


## Whether this seed's robbery is the party where the hostages don't want to leave.
static func is_party(seed_: int, args: PackedStringArray) -> bool:
	return variant(seed_, args) == "party"


## The flooding vault's water: over the whole bank's floor, its jet out of the hole the drill made in the vault's door.
## Step 2: a front door in the entrance holds it in, and the valve out back stops it. The pig running for the van and
## the hostages walking out open the door on their way.
func _add_water() -> void:
	water = BankWater.new()
	water.name = "Water"
	water.area = Rect2(-HALF_X, -HALF_Z, HALF_X * 2.0, HALF_Z * 2.0).grow(-0.15)
	water.floor_top = FLOOR_TOP
	water.jet_from = Vector3(VAULT_X - 0.25, FLOOR_TOP + VAULT_DOOR_RADIUS + 0.4, VAULT_DOOR_Z + 0.3)
	for robber in robbers:
		water.waders.append(robber)
	for hostage in hostages:
		water.waders.append(hostage)
	add_child(water)
	front_door = DOOR_SCENE.instantiate()
	front_door.name = "FrontDoor"
	front_door.locked = false
	front_door.position = Vector3(ENTRANCE_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, HALF_Z)
	add_child(front_door)
	water.watch_door(front_door, global_transform * Vector3(ENTRANCE_X, FLOOR_TOP, HALF_Z - 0.5))
	valve = BankValve.new()
	valve.name = "Valve"
	valve.water = water
	valve.position = VALVE_AT
	valve.rotation.y = PI
	add_child(valve)
	for robber in robbers:
		if robber.animal == "chancho":
			robber.spotted.connect(func(_robber: BankRobber, _cop: Node3D) -> void: open_front())
		elif robber.animal == "pato":
			water.duck = robber
	water.drill = drill
	for i in hostages.size():
		var x: float = PERCH_XS[i % PERCH_XS.size()]
		water.hostages.append(hostages[i])
		water.perches.append(global_transform * Vector3(x, FLOOR_TOP + COUNTER_SIZE.y, COUNTER_Z))
		water.down_at.append(global_transform * Vector3(x, FLOOR_TOP, COUNTER_Z + 1.0))
	floats = BankFloats.new()
	floats.name = "Floats"
	floats.position = FLOATS_IN_TRUNK
	car.add_child(floats)
	car.add_collision_exception_with(floats)


## Someone inside walks out of the flooding bank's front door: it swings open (and the wave rushes out).
func open_front() -> void:
	if front_door and not front_door.is_open:
		front_door.open_from_inside()


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
	croissant_tray = BankCroissantTray.new()
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
	sign_label.text = "PLACE_BANK_TOWN" if town else "PLACE_BANK_BLOOD" if blood else "PLACE_BANK"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = GOLD
	sign_label.position = Vector3(0, ROOF + 0.7, HALF_Z + 0.2)
	$Built.add_child(sign_label)
	for x: float in [-8.0, 0.0, 8.0]:
		for z: float in [-7.5, -2.5, 3.0, 7.5]:
			lamps.append(_build.light(Vector3(x, ROOF - 0.6, z)))


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


## The roof robbery's way up (decision 126): fire escape stairs climbing the east wall to a landing at the roof, the
## gang's hatch in the corridor's ceiling with its ladder (only for the look: the cops go up outside), the painted X of
## the helipad with the toy helicopter waiting on it, and the nephew on his bench across the street.
func _build_roof() -> void:
	_build.stairs(ESCAPE_FOOT, ESCAPE_RUN, STEEL.darkened(0.3))
	var landing_z := ESCAPE_FOOT.z - ESCAPE_RUN
	_build.slab(HALF_X, HALF_X + 0.2 + LANDING.x, landing_z - LANDING.y, landing_z, ROOF, STEEL.darkened(0.3))
	# Rails on the outer side of the flight and around the landing.
	var rail_x := ESCAPE_FOOT.x + GameScale.STAIR_WIDTH / 2
	var slope := atan2(ROOF, ESCAPE_RUN)
	var rail := Vector2(ESCAPE_RUN, ROOF).length()
	_build.mesh(_rail_mesh(rail), Vector3(rail_x, ROOF / 2 + 0.9, ESCAPE_FOOT.z - ESCAPE_RUN / 2), STEEL.darkened(0.3),
		Vector3(slope, 0, 0))
	_build.mesh_box(Vector3(HALF_X + 0.2 + LANDING.x, ROOF + 0.5, landing_z - LANDING.y / 2),
		Vector3(0.05, 1.0, LANDING.y), STEEL.darkened(0.3))
	# The hatch: a dark square in the corridor's ceiling with its ladder down the office's wall, and its lid on the roof.
	_build.mesh_box(Vector3(HATCH_AT.x, ROOF - PlaceBuilder.SLAB - 0.01, HATCH_AT.z), Vector3(HATCH_SIZE, 0.02, HATCH_SIZE),
		Color(0.12, 0.12, 0.14))
	_build.mesh_box(Vector3(HATCH_AT.x, ROOF + 0.04, HATCH_AT.z), Vector3(HATCH_SIZE + 0.1, 0.08, HATCH_SIZE + 0.1), STEEL)
	var ladder_x := OFFICE_X + 0.12
	for side: float in [-0.25, 0.25]:
		_build.mesh_box(Vector3(ladder_x, ROOF / 2, HATCH_AT.z + side), Vector3(0.05, ROOF, 0.05), STEEL)
	for i in 8:
		_build.mesh_box(Vector3(ladder_x, 0.3 + i * 0.3, HATCH_AT.z), Vector3(0.04, 0.04, 0.5), STEEL)
	# The helipad: a white circle line and an X.
	var pad := HELIPAD_AT + Vector3.UP * (ROOF + 0.01)
	for turn: float in [PI / 4, -PI / 4]:
		_build.mesh(_flat(Vector2(HELIPAD_SIZE * 0.8, 0.35)), pad, PAINT, Vector3(0, turn, 0))
	var ring := TorusMesh.new()
	ring.inner_radius = HELIPAD_SIZE / 2 - 0.15
	ring.outer_radius = HELIPAD_SIZE / 2
	ring.rings = 24
	_build.mesh(ring, pad, PAINT, Vector3.ZERO)
	helicopter = ToyHelicopter.new()
	helicopter.name = "ToyHelicopter"
	helicopter.position = HELIPAD_AT + Vector3.UP * (ROOF + 0.02)
	helicopter.pad = helicopter.position
	add_child(helicopter)
	helicopter.landed.connect(func() -> void: nephew_rest = NEPHEW_REST)
	# The nephew's bench, facing the bank across the street, and the kid on it.
	_build.legs(NEPHEW_BENCH + Vector3(0, 0, 0.1), Vector2(1.6, 0.45), 0.4, WOOD)
	_build.box(NEPHEW_BENCH + Vector3(0, 0.42, 0.1), Vector3(1.6, 0.05, 0.45), WOOD)
	_build.mesh_box(NEPHEW_BENCH + Vector3(0, 0.7, 0.32), Vector3(1.6, 0.4, 0.05), WOOD)
	nephew = BankNephew.new()
	nephew.name = "Nephew"
	nephew.position = NEPHEW_BENCH
	add_child(nephew)
	nephew.caught_now.connect(_on_nephew_caught)
	# The cart: a wire basket on legs, with the sacks the helicopter brings.
	_build.legs(CART_AT, Vector2(CART_SIZE.x, CART_SIZE.z), CART_TOP - CART_SIZE.y, STEEL)
	_build.open_box(CART_AT + Vector3.UP * (CART_TOP - CART_SIZE.y), CART_SIZE, "top", STEEL)
	cart = Node3D.new()
	cart.name = "Cart"
	cart.position = CART_AT + Vector3.UP * (CART_TOP - 0.2)
	add_child(cart)
	helicopter.dropped.connect(_on_sack_dropped)
	helicopter.trip_done.connect(_next_trip)


## The nephew in handcuffs (step 3): the helicopter loses its pilot and falls wherever it is. In the middle of the
## getaway by the roof (step 4), the sacks still up there stay, and El Oso runs for the van after all.
func _on_nephew_caught(_nephew: BankNephew) -> void:
	helicopter.crash()
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_NEPHEW_CAUGHT")
	if roof_getaway and not follower:
		roof_bags = 0
		_roof_way_lost()


## The getaway by the roof (step 4): every loose robber went up the hatch with a sack, and the helicopter takes them to
## the cart one trip at a time.
func _start_roof_getaway(sacks: int) -> void:
	roof_getaway = true
	roof_bags = sacks
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_ROOF_GETAWAY")
	_next_trip()


## Another sack to the cart while there are sacks on the roof; then El Oso's turn, hanging from the rope.
func _next_trip() -> void:
	if follower or not roof_getaway or helicopter.crashed:
		return
	if roof_bags > 0:
		# It may still be up on one of the nephew's flights: it goes once it lands.
		if helicopter.busy():
			helicopter.landed.connect(_next_trip, CONNECT_ONE_SHOT)
			return
		helicopter.trip(CART_AT + Vector3.UP * CART_TOP)
		return
	_oso_by_air()


## A sack in the cart: one more the gang got away with.
func _on_sack_dropped() -> void:
	if follower:
		return
	roof_bags = maxi(roof_bags - 1, 0)
	bags_taken += 1
	_show_cart_bags()


func _show_cart_bags() -> void:
	while cart.get_child_count() < bags_taken:
		var bag: Node3D = BAG_MODEL.instantiate()
		var k := cart.get_child_count()
		bag.position = Vector3((k % 2) * 0.25 - 0.12, (k / 2) * 0.25, 0.0)
		cart.add_child(bag)


## The last trip (step 4b): El Oso grabs the rope and the helicopter flies him off low over the street; the chase is
## on, against something in the air.
func _oso_by_air() -> void:
	if chase or not is_loose(boss):
		return
	helicopter.hide()
	helicopter.freeze = true
	helicopter.collision_layer = 0
	helicopter.set_physics_process(false)
	start_getaway(SuspectCar.TOY_HELICOPTER)
	if case:
		case._on_vault_opened()


## A cop leaning out of the patrol car's window got the rope: El Oso drops into the back seat, cuffed.
func _on_rope_grabbed(_cop: Cop) -> void:
	if follower or not chase or chase.stopped:
		return
	chase.pull_over()
	chase.suspect.cuffed(Handcuffs.SECONDS)
	chase.escort.board()
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_ROPE_GRABBED")


## No helicopter for El Oso: he runs for the van (or on foot) like in the base robbery.
func _roof_way_lost() -> void:
	if is_loose(boss) and not chase:
		_run_getaway(false)


## Whether the gang can still leave by the roof: the helicopter up there, whole, and its pilot free.
func roof_way_out() -> bool:
	return roof and not nephew.caught and not helicopter.crashed and (helicopter.busy()
		or on_roof(helicopter.global_position))


## The hall's ceiling lamps on or off (the blood bank's power cut, robo-banco-sangre.md).
func set_lights(on: bool) -> void:
	for lamp in lamps:
		lamp.visible = on


## The town bank (decision 127): the wall of shelves from the back wall to the facade, its shelves on the small hall's
## side with jars of jam and binders, and don Plácido asleep on his stool behind the counter.
func _build_town() -> void:
	_build.wall("z", TOWN_WALL_X, BACK_Z, HALF_Z, 0, [], WOOD.lightened(0.15))
	for z: float in TOWN_SHELF_ZS:
		for i in TOWN_SHELVES.size():
			var at := Vector3(TOWN_WALL_X + 0.25, FLOOR_TOP + TOWN_SHELVES[i], z)
			_build.mesh_box(at, Vector3(0.4, 0.04, 1.8), WOOD)
			for k in 3:
				var color := JAR if (int(z) + i + k) % 2 == 0 else BINDER
				var size := Vector3(0.22, 0.24, 0.22) if color == JAR else Vector3(0.28, 0.3, 0.08)
				_build.mesh_box(at + Vector3(0, 0.02 + size.y / 2, -0.55 + k * 0.55), size, color)
	_build.legs(CLERK_AT + Vector3.UP * FLOOR_TOP, Vector2(0.4, 0.4), STOOL_TOP - 0.04, WOOD)
	_build.box(CLERK_AT + Vector3(0, FLOOR_TOP + STOOL_TOP - 0.02, 0), Vector3(0.45, 0.04, 0.45), WOOD)
	clerk = BankClerk.new()
	clerk.name = "Clerk"
	clerk.position = CLERK_AT + Vector3.UP * (FLOOR_TOP + STOOL_TOP)
	clerk.car = car
	clerk.is_out = func(at: Vector3) -> bool: return not inside(at)
	add_child(clerk)


## El Conejo's nerves (step 3): their bar over his head, and his way out to the van when they run out.
func _add_nerves() -> void:
	nerves = BankNerves.new()
	boss.add_child(nerves)
	nerves.setup(boss, drill, car, clerk, phone)
	nerves.bolted.connect(_on_conejo_bolted)
	var way := HALL_TO_CORRIDOR.duplicate()
	way.reverse()
	way.append_array(PIG_RUN)
	for at: Vector3 in way:
		boss.run_path.append(global_transform * at)


## El Conejo ran out of nerves (step 4): nobody holds the drill any more, and once he's in the van (or out of the
## entrance, if it's boxed in) the chase is on, with no sacks if the vault was still shut.
func _on_conejo_bolted(_robber: BankRobber) -> void:
	if follower:
		return
	drill.pause(INF)
	boss.hid_in_van.connect(func(_r: BankRobber) -> void: _run_getaway(false), CONNECT_ONE_SHOT)


func _flat(size: Vector2) -> BoxMesh:
	var box := BoxMesh.new()
	box.size = Vector3(size.x, 0.02, size.y)
	return box


func _rail_mesh(length: float) -> BoxMesh:
	var box := BoxMesh.new()
	box.size = Vector3(0.05, 0.05, length)
	return box


## The queue posts with their rope, two benches, the plant and the tellers' counter with its three desks behind.
func _build_hall() -> void:
	# The town bank has no queue.
	for i in 0 if town else 5:
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
			# The blood bank's fridge holds blood bags (BankBlood) instead.
			if not blood:
				_build.mesh_box(Vector3(11.3, FLOOR_TOP + level + 0.12, z), Vector3(0.5, 0.22, 1.1), MONEY)
	var label := Label3D.new()
	label.text = "BANK_FRIDGE" if blood else "BANK_VAULT"
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
	# The blood bank's fridge door is white.
	steel.material_override = _build.material(PAINT if blood else STEEL.lightened(0.1))
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


## Mr. Moneda pacing on the sidewalk by his car, a body too so the patrol car bumps into it (robo-banco-gerente.md).
func _add_manager(is_boss: bool) -> void:
	manager_car = StaticBody3D.new()
	manager_car.name = "ManagerCar"
	manager_car.position = MANAGER_CAR_AT
	manager_car.rotation.y = -PI / 2
	add_child(manager_car)
	var shape := CollisionShape3D.new()
	var body := BoxShape3D.new()
	body.size = MANAGER_CAR_SIZE
	shape.shape = body
	shape.position.y = MANAGER_CAR_SIZE.y / 2 + 0.05
	manager_car.add_child(shape)
	manager_car.add_child(MANAGER_CAR_MODEL.instantiate())
	for at in MANAGER_CAR_WHEELS:
		var wheel: Node3D = WHEEL_MODEL.instantiate()
		wheel.position = at
		manager_car.add_child(wheel)
	manager = BankManager.new()
	manager.name = "Manager"
	manager.boss = is_boss
	manager.position = MANAGER_SPOTS[0] + Vector3.UP * FLOOR_TOP
	for at in MANAGER_SPOTS:
		manager.spots.append(global_transform * (at + Vector3.UP * FLOOR_TOP))
	add_child(manager)
	manager.seed_with(hash(["bank walkie", case_seed]))
	if town:
		# The town bank has no manager: neither he nor his car are there.
		for gone: CollisionObject3D in [manager, manager_car]:
			gone.hide()
			gone.collision_layer = 0
			gone.process_mode = Node.PROCESS_MODE_DISABLED
		return
	if not is_boss:
		return
	# The boss (step 2): the key he gives doesn't fit, his walkie hurries the gang and his trunk waits open.
	back_door.wrong_key = true
	manager.radioed.connect(_on_manager_radioed)
	manager.caught_now.connect(_on_manager_caught)
	var escort := OwnerEscort.attach(manager, car)
	escort.seat_shift = MANAGER_SEAT
	escort.in_car_hint = "HINT_MANAGER_IN_CAR"
	manager_trunk = ManagerTrunk.new()
	manager_trunk.name = "Trunk"
	manager_trunk.manager = manager
	manager_car.add_child(manager_trunk)


## The boss manager in handcuffs (step 3): the gang hears it on the walkie and gets nervous once, and El Oso hangs up
## the phone for good.
func _on_manager_caught(_manager: BankManager) -> void:
	if follower:
		return
	drill.hurry(BankDrill.NERVOUS)
	phone.hang_up()


## The boss manager murmured into his walkie: the drill hurries unless a cop stands close to him.
func _on_manager_radioed(_manager: BankManager) -> void:
	if follower:
		return
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(manager.global_position) <= WALKIE_NEAR:
			return
	drill.hurry(WALKIE_HURRY)


func _add_robbers() -> void:
	for animal: String in BankRobber.ANIMALS:
		# In the town bank El Conejo robs it alone, at the drill.
		if town and animal != "conejo":
			continue
		var robber := BankRobber.new()
		robber.alone = town
		robber.vampire = blood
		robber.name = "Robber_" + animal
		robber.animal = animal
		robber.grandpa = grandpas
		robber.sorry = _sorry_variant and animal == sorry_animal(case_seed)
		robber.claim_spot = _claim_hide_spot
		robber.is_out = func(at: Vector3) -> bool: return not inside(at)
		robber.slipped_out.connect(func(_robber: BankRobber) -> void: bags_taken += 1)
		if grandpas:
			robber.spotted.connect(func(_robber: BankRobber, _cop: Node3D) -> void: _gang_nervous())
		var spot: Array = ROBBER_SPOTS["pato" if town else animal]
		robber.position = spot[0] + Vector3.UP * FLOOR_TOP
		robber.rotation.y = spot[1]
		add_child(robber)
		robbers.append(robber)
		var escort := OwnerEscort.attach(robber, car)
		escort.seat_shift = ROBBER_SEATS[robbers.size() - 1]
		escort.in_car_hint = "HINT_OWNER_IN_CAR" if robber.is_boss() else "HINT_ROBBER_IN_CAR"
		if grandpas:
			escort.speed = OwnerEscort.SPEED * BankRobber.GRANDPA_PACE
		if animal == "chancho":
			for at in PIG_RUN:
				robber.run_path.append(global_transform * at)
		if robber.is_boss():
			boss = robber
		if robber.sorry:
			sorry = robber
			robber.watched = _sorry_watched
			robber.help_way = _sorry_way
			robber.way_back = _sorry_way_back
			robber.do_help = _sorry_help


func _physics_process(delta: float) -> void:
	if not follower and sorry:
		_watch_the_sorry_one()
	if not follower and roof:
		_watch_the_roof(delta)


## The roof robbery (step 2): the nephew sees a cop up on the roof and flies the helicopter away from them, if it's
## still up there and his remote is ready. Taken off the roof, the gang has no way out by it.
func _watch_the_roof(delta: float) -> void:
	nephew_rest = maxf(nephew_rest - delta, 0.0)
	if helicopter.busy() or helicopter.crashed or roof_getaway:
		return
	if not on_roof(helicopter.global_position):
		if not helicopter_gone:
			helicopter_gone = true
			for cop in get_tree().get_nodes_in_group("cops"):
				(cop as Cop).show_hint("HINT_HELICOPTER_TAKEN")
		return
	helicopter_gone = false
	if nephew_rest > 0.0 or nephew.caught:
		return
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if on_roof(cop.global_position):
			helicopter.take_off()
			nephew.say("NEPHEW_TAKE_OFF")
			(cop as Cop).show_hint("HINT_HELICOPTER_UP")
			return


## Whether `at` (global) is up on the bank's roof.
func on_roof(at: Vector3) -> bool:
	var local := to_local(at)
	return local.y > ROOF - ON_ROOF and absf(local.x) <= HALF_X + 0.2 and absf(local.z) <= HALF_Z + 0.2


## The gang keeps an eye on the sorry robber: one who sees him on a help (not resting at his spot) shouts "¡Traidor!",
## the gang gets nervous and he ends up tied to the chair.
func _watch_the_sorry_one() -> void:
	if not sorry.turned or sorry.tied or sorry.helping == "" or not is_loose(sorry):
		return
	for robber in robbers:
		if robber != sorry and is_loose(robber) and not robber.in_van \
				and robber.sees(sorry.global_position + Vector3.UP, sorry):
			robber.say("ROBBER_TRAITOR")
			drill.hurry(BankDrill.NERVOUS)
			sorry.tie(global_transform * (CHAIR_AT + Vector3(0.1, FLOOR_TOP, 0)), rotation.y + CHAIR_YAW)
			return


## Whether a loose robber other than the sorry one sees `cop` (then he doesn't dare talk).
func _sorry_watched(cop: Node3D) -> bool:
	for robber in robbers:
		if robber != sorry and is_loose(robber) and not robber.in_van and robber.sees_cop(cop):
			return true
	return false


## On the corridor's side: in the corridor (behind the back wall, between the office and the vault) or out of the back
## door (bank coordinates).
static func in_corridor(at: Vector3) -> bool:
	return (at.z < BACK_Z and at.x > OFFICE_X and at.x < VAULT_X) or at.z < -HALF_Z


## The sorry robber's way (world positions) from where he is to `to` (bank coordinates): round the counter between
## the hall and the corridor's side, straight otherwise.
func _sorry_way_to(to: Vector3) -> Array[Vector3]:
	var from := global_transform.affine_inverse() * sorry.global_position
	var points: Array[Vector3] = []
	if in_corridor(from) and not in_corridor(to):
		points = HALL_TO_CORRIDOR.duplicate()
		points.reverse()
	elif not in_corridor(from) and in_corridor(to):
		points = HALL_TO_CORRIDOR.duplicate()
	points.append(to)
	var way: Array[Vector3] = []
	for at in points:
		way.append(global_transform * Vector3(at.x, FLOOR_TOP, at.z))
	return way


## The sorry robber's way to `help`: the back door, the drill, or the sitting hostage nearest to the counter's gap.
func _sorry_way(help: String) -> Array[Vector3]:
	match help:
		"door":
			return _sorry_way_to(AT_BACK_DOOR)
		"drill":
			return _sorry_way_to(AT_DRILL)
		"hostages":
			var picked := _sorry_pick()
			if picked.is_empty():
				return []
			var at := global_transform.affine_inverse() * picked[0].global_position
			return _sorry_way_to(at + Vector3(0.9, 0, 0))
	return []


## Up to SORRY_HOSTAGES hostages still sitting, the nearest to the counter's gap first.
func _sorry_pick() -> Array[BankHostage]:
	var gap := global_transform * HALL_TO_CORRIDOR[0]
	var sitting: Array[BankHostage] = []
	for hostage in hostages:
		if hostage.sitting() and not hostage.is_cuffed():
			sitting.append(hostage)
	sitting.sort_custom(func(a: BankHostage, b: BankHostage) -> bool:
		return a.global_position.distance_to(gap) < b.global_position.distance_to(gap))
	return sitting.slice(0, SORRY_HOSTAGES)


## The sorry robber's way back to his spot.
func _sorry_way_back(_help: String) -> Array[Vector3]:
	return _sorry_way_to(ROBBER_SPOTS[sorry.animal][0])


## The sorry robber does `help`'s leg `stage` and gives the way of the next leg (empty when the help is done): the back
## door unlocked and swung open from inside; the drill unplugged for UNPLUGGED seconds; the hostages taken by the hand
## and then walked out of the back door, where they go free.
func _sorry_help(help: String, stage: int) -> Array[Vector3]:
	match help:
		"door":
			back_door.open_from_inside()
		"drill":
			drill.pause(UNPLUGGED)
		"hostages":
			if stage == 0:
				var picked := _sorry_pick()
				for i in picked.size():
					picked[i].take_by(sorry, i == 0)
				if not picked.is_empty():
					back_door.open_from_inside()
					return _sorry_way_to(OUT_BACK)
			else:
				for hostage in hostages:
					if hostage.led_by == sorry:
						hostage.free_hostage()
	var none: Array[Vector3] = []
	return none


## The grandpa gang got nervous: the duck grandma, if she's still loose, throws her marbles in front of the entrance
## (once).
func _gang_nervous() -> void:
	if follower or marbles:
		return
	for robber in robbers:
		if robber.animal == "pato" and is_loose(robber):
			robber.say("ROBBER_GRANDPA_MARBLES")
			spill_marbles()


## The marbles on the floor (also a guest's, when the host's are there: BankCase's snapshot).
func spill_marbles() -> void:
	if marbles:
		return
	marbles = BankMarbles.new()
	marbles.name = "Marbles"
	marbles.position = MARBLES_AT + Vector3.UP * FLOOR_TOP
	add_child(marbles)
	for robber in robbers:
		if robber.animal == "pato":
			var bag := robber.find_child("props", true, false) as Node3D
			if bag:
				bag.hide()


## The free spot among the hostages nearest to `robber` (a world position), now his.
func _claim_hide_spot(robber: BankRobber) -> Vector3:
	var best := -1
	for i in HIDE_SPOTS.size():
		if _hide_taken.has(i):
			continue
		if best < 0 or robber.global_position.distance_to(global_transform * HIDE_SPOTS[i]) \
				< robber.global_position.distance_to(global_transform * HIDE_SPOTS[best]):
			best = i
	if best < 0:
		return robber.global_position
	_hide_taken[best] = robber
	return global_transform * (HIDE_SPOTS[best] + Vector3.UP * FLOOR_TOP)


## The hostages, a different set of neighbors for each seed.
func _add_hostages() -> void:
	if town:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["bank hostages", case_seed])
	var looks := BankHostage.LOOKS.duplicate()
	for i in range(looks.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = looks[i]
		looks[i] = looks[j]
		looks[j] = swap
	var fans: Array[int] = []
	if party:
		var order := range(HOSTAGES)
		for i in range(order.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var swap: int = order[i]
			order[i] = order[j]
			order[j] = swap
		for i in SNITCHES:
			fans.append(order[i])
	for i in HOSTAGES:
		var hostage := BankHostage.new()
		if fans.has(i):
			hostage.snitch = BankRobber.ANIMALS[rng.randi_range(0, BankRobber.ANIMALS.size() - 1)]
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


## El Oso keeps his word: the first hostage still on the floor walks out of the entrance and goes free. At the party
## (step 4) they only get as far as the door, and walk back in unless a cop takes them by the hand there.
func release_hostage() -> void:
	for hostage in hostages:
		if hostage.sitting():
			if party:
				var way_in: Array[Vector3] = []
				for at in WAY_IN:
					way_in.append(global_transform * (at + Vector3.UP * FLOOR_TOP))
				open_front()
				hostage.walk_out(global_transform * Vector3(ENTRANCE_X, FLOOR_TOP, HALF_Z + 1.2), way_in)
				return
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


## Whether a robber is still free: not cuffed, not being walked and not in the patrol car (the pig in the van is), and
## not a grandpa who already slipped out as a hostage (his sack is counted).
static func is_loose(robber: BankRobber) -> bool:
	var escort := OwnerEscort.of(robber)
	return not robber.slipped and not robber.is_cuffed() and not (escort and (escort.in_car or escort.escorted_by))


## The vault is open: every robber still loose grabs a sack and leaves; El Oso among them, the chase is on.
func _on_vault_opened() -> void:
	if follower:
		return
	# The boss manager still loose (robo-banco-gerente.md, step 4): the gang loads the sacks in his trunk and they all
	# drive off with him.
	var manager_runs := manager.boss and not manager.caught
	var boss_runs := is_loose(boss) and not manager_runs
	# The roof robbery (robo-banco-techo.md, step 4): up the hatch with the sacks, if the helicopter is still theirs.
	var by_roof := roof and roof_way_out()
	if blood:
		# The blood bank (robo-banco-sangre.md, step 3): they run in for the bags and out with them.
		blood_bank.load_up()
		return
	var sacks := 0
	for robber in robbers:
		if robber.sorry and is_loose(robber):
			# He doesn't take a sack: he sits down to wait for the cops (robo-banco-arrepentido.md, step 5).
			robber.wait_for_cops()
		elif is_loose(robber):
			sacks += 1
			if not by_roof:
				bags_taken += TOWN_SACKS if town else 1
			robber.hide()
			robber.collision_layer = 0
			robber.process_mode = Node.PROCESS_MODE_DISABLED
	if by_roof and sacks > 0:
		_start_roof_getaway(sacks)
		if case:
			case._on_vault_opened()
		return
	if not manager_runs and not boss_runs:
		return
	var wading := wade_out_time()
	if wading > 0.0:
		# The flooding bank (robo-banco-inundado.md, step 4): wading out with the sacks takes them a while.
		for cop in get_tree().get_nodes_in_group("cops"):
			(cop as Cop).show_hint("HINT_FLOOD_WADING")
		get_tree().create_timer(wading, false, true).timeout.connect(_run_getaway.bind(manager_runs))
		return
	_run_getaway(manager_runs)


## How long the gang takes to wade out of the flooding bank with the sacks (0 dry).
func wade_out_time() -> float:
	if not water or water.level < WADE_FROM:
		return 0.0
	return WADE_OUT * (1.0 - BankWater.factor(water.level)) / (1.0 - BankWater.factor(BankWater.MAX_LEVEL))


## El Oso (or the boss manager) gets away: in his car, on a motor walker, in the van or on foot if it's boxed in.
func _run_getaway(manager_runs: bool) -> void:
	if manager_runs:
		start_getaway(SuspectCar.MANAGER_CAR)
	elif grandpas:
		start_getaway(SuspectCar.WALKER)
	else:
		start_getaway(SuspectCar.BEAR_ON_FOOT if van_boxed_in() else SuspectCar.ROBBERS_VAN)
	if case:
		case._on_vault_opened()


## El Oso gets away in the van (`kind` ROBBERS_VAN) or on foot (BEAR_ON_FOOT), or the grandpa Oso on a motor walker
## along the sidewalk (WALKER, robo-banco-abuelos.md, step 4), or the boss manager in his car (MANAGER_CAR,
## robo-banco-gerente.md, step 4), or El Oso hanging from the toy helicopter (TOY_HELICOPTER, robo-banco-techo.md,
## step 4b) with the rope a cop can grab from the patrol car (RopeGrab): the chase is on.
func start_getaway(kind: String) -> void:
	if chase:
		return
	var at := Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, FLOOR_TOP, HALF_Z + 1.5))
	if kind == SuspectCar.ROBBERS_VAN and is_instance_valid(van):
		at = van.global_transform
		van.queue_free()
	if kind == SuspectCar.MANAGER_CAR:
		at = manager_car.global_transform
		manager_car.queue_free()
		manager.hide()
		manager.collision_layer = 0
		manager.process_mode = Node.PROCESS_MODE_DISABLED
	chase = ChaseCase.begin(self, kind, at, car, city, case_seed)
	chase.who = "manager" if kind == SuspectCar.MANAGER_CAR else "oso_grandpa" if grandpas \
		else "conejo" if town else "oso"
	if grandpas or (town and kind == SuspectCar.BEAR_ON_FOOT):
		chase.truck.set_rider(ChaseSuspect.model_for(chase.who))
	chase.follower = follower
	if case:
		chase.online = case.online
	chase.ended.connect(_on_getaway_ended)
	if kind == SuspectCar.TOY_HELICOPTER:
		var rope := RopeGrab.new()
		rope.name = "RopeGrab"
		rope.position.y = SuspectCar.ROPE_FROM
		chase.truck.add_child(rope)
		rope.grabbed.connect(_on_rope_grabbed)
	for cop in get_tree().get_nodes_in_group("cops"):
		var hint: String = {SuspectCar.ROBBERS_VAN: "HINT_ESCAPE_oso", SuspectCar.WALKER: "HINT_ESCAPE_oso_WALKER",
			SuspectCar.MANAGER_CAR: "HINT_ESCAPE_manager", SuspectCar.TOY_HELICOPTER: "HINT_ESCAPE_oso_AIR"}.get(kind,
			"HINT_ESCAPE_oso_FOOT")
		(cop as Cop).show_hint(hint.replace("_oso", "_conejo") if town else hint)


func _on_getaway_ended(was_caught: bool) -> void:
	getaway_over = true
	getaway_caught = was_caught
