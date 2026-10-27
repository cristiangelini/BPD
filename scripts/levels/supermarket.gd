class_name Supermarket
extends Node3D

## The supermarket "Súper El Changuito" as a place to raid (docs/diseno/allanamiento-super.md, step 1): a store on its
## lot in the city, open and with the front to +Z. Four gondolas make aisles 1 to 4, the dairy fridge runs along the
## back wall with the chest freezer in front of it, the produce stand with its scale is in the west corner, three
## checkouts face the door, the manager's office is in the front east corner (locked, its key in checkout 1's till) and
## the storeroom in the back east corner. By the door the offer table holds a pyramid of 21 cans: it falls with nothing,
## and the fridge's glass cracks if something hits it fast, a fine each. It's a raid case like the gym (step 5): one of
## its stories (STORIES), drawn with the seed, run by the same RaidCase as the other places. Every number here is
## (propuesta).

signal pyramid_fell
signal fridge_broken

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the supermarket can be suspected of (allanamiento-super.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["super_dates", "super_cheese", "super_carts", "super_scale", "super_raffle", "super_aisle13"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_SUPER_TIP_B", "BRIEF_TIP_C", "BRIEF_SUPER_TIP_D",
	"BRIEF_SUPER_TIP_E"]
## The stories the supermarket can tell, like GymRaid.STORIES: what the comisario says once it's guessed, its "find
## it" row, what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the
## checklist rows of its extras and its rig. With "main_hidden" the first hidden item is the main evidence.
const STORIES := {
	"super_dates": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SUPER_DATES_B", "BRIEF_SUPER_DATES_C", "BRIEF_SUPER_DATES_D"],
		"find": "OBJ_FIND_PRICE_GUN",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/super_price_gun.tscn"), preload("res://scenes/props/super_label_box.tscn"),
			preload("res://scenes/props/super_old_yogurt.tscn")],
		"half_heights": [0.14, 0.115, 0.075],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_LABEL_BOX", "OBJ_EXTRA_OLD_YOGURT"],
		"rig": preload("res://scripts/case/super/changed_dates_rig.gd"),
	},
	"super_cheese": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SUPER_CHEESE_B", "BRIEF_SUPER_CHEESE_C", "BRIEF_SUPER_CHEESE_D"],
		"find": "OBJ_FIND_FAKE_CHEESE",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/super_fake_cheese.tscn"), preload("res://scenes/props/super_cheese_mold.tscn"),
			preload("res://scenes/props/super_wax_block.tscn")],
		"half_heights": [0.14, 0.15, 0.05],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_CHEESE_MOLD", "OBJ_EXTRA_WAX_BLOCK"],
		"rig": preload("res://scripts/case/super/fake_cheese_rig.gd"),
	},
	"super_carts": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SUPER_CARTS_B", "BRIEF_SUPER_CARTS_C", "BRIEF_SUPER_CARTS_D"],
		"find": "OBJ_FIND_DOUBLE_CART",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/super_double_cart.tscn"), preload("res://scenes/props/super_welder.tscn"),
			preload("res://scenes/props/super_cart_plan.tscn")],
		"half_heights": [0.5, 0.15, 0.01],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_WELDER", "OBJ_EXTRA_CART_PLAN"],
		"rig": preload("res://scripts/case/super/double_carts_rig.gd"),
	},
	"super_scale": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SUPER_SCALE_B", "BRIEF_SUPER_SCALE_C", "BRIEF_SUPER_SCALE_D"],
		"find": "OBJ_FIND_MAGIC_SCREW",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/super_magic_screw.tscn"), preload("res://scenes/props/super_weigh_manual.tscn"),
			preload("res://scenes/props/super_golden_screwdriver.tscn")],
		"half_heights": [0.075, 0.02, 0.03],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_WEIGH_MANUAL", "OBJ_EXTRA_GOLDEN_SCREWDRIVER"],
		"rig": preload("res://scripts/case/super/rigged_scale_rig.gd"),
	},
	"super_raffle": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SUPER_RAFFLE_B", "BRIEF_SUPER_RAFFLE_C", "BRIEF_SUPER_RAFFLE_D"],
		"find": "OBJ_FIND_RAFFLE_URN",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/super_raffle_urn.tscn"), preload("res://scenes/props/super_prize_car.tscn"),
			preload("res://scenes/props/super_winners_photo.tscn")],
		"half_heights": [0.215, 0.385, 0.015],
		"heavy": [false, true, false],
		"extra_keys": ["OBJ_EXTRA_PRIZE_CAR", "OBJ_EXTRA_WINNERS_PHOTO"],
		"rig": preload("res://scripts/case/super/rigged_raffle_rig.gd"),
	},
}
## Where the clue notes for the suspicions can lie, on the floor.
const NOTE_PLACES: Array[Vector3] = [Vector3(-7.5, FLOOR_TOP, 2.0), Vector3(-2.5, FLOOR_TOP, -4.0),
	Vector3(2.5, FLOOR_TOP, -2.0), Vector3(-12.0, FLOOR_TOP, -3.0), Vector3(12.0, FLOOR_TOP, 2.0),
	Vector3(-4.0, FLOOR_TOP, 10.5)]
const GONDOLA_MODEL := preload("res://assets/models/gondola.glb")
const FRIDGE_MODEL := preload("res://assets/models/dairy_fridge.glb")
const CHECKOUT_MODEL := preload("res://assets/models/checkout.glb")
const PRODUCE_MODEL := preload("res://assets/models/produce_stand.glb")
const FREEZER_MODEL := preload("res://assets/models/chest_freezer.glb")
const CAN_MODEL := preload("res://assets/models/food_can.glb")
const HALF_X := 15.0
const HALF_Z := 12.0
const WALL_TOP := 5.0
const BUILDING_TOP := 7.0
const FLOOR_TOP := 0.06
## The open doorway in the front wall, east of the checkouts.
const ENTRANCE_X := 3.0
const ENTRANCE_WIDTH := 4.0
const ENTRANCE_HEIGHT := 3.0

## The gondolas: each aisle's west side, three 3 m modules from GONDOLA_FROM_Z, and the aisle signs between them.
const GONDOLA_X: Array[float] = [-10.0, -5.0, 0.0, 5.0]
const GONDOLA_FROM_Z := -6.0
const GONDOLA_MODULE := 3.0
const GONDOLA_SIZE := Vector3(1.2, 1.8, 9.0)
## The dairy fridge along the back wall (three of 4 m), and the fragile glass in front of them.
const FRIDGE_X: Array[float] = [-11.0, -7.0, -3.0]
const FRIDGE_Z := -11.4
const FRIDGE_SIZE := Vector3(4.0, 2.2, 0.9)
const FRIDGE_SPEED := 3.0
const FRIDGE_FINE := 30
const FREEZER_AT := Vector3(-3.0, FLOOR_TOP, -8.6)
const FREEZER_SIZE := Vector3(2.0, 0.9, 0.9)
const PRODUCE_AT := Vector3(-13.6, FLOOR_TOP, 2.0)
const PRODUCE_SIZE := Vector3(1.0, 0.9, 2.95)
## The checkouts, their middles; the till sits on checkout 1's stand.
const CHECKOUT_X: Array[float] = [-10.0, -6.0, -2.0]
const CHECKOUT_Z := 7.6
const CHECKOUT_SIZE := Vector3(0.8, 0.9, 2.4)
const TILL_ON := Vector3(-10.0, FLOOR_TOP + 0.92, 8.45)
## The offer table by the door with its pyramid: six rows of cans, from 6 at the bottom to 1 at the top.
const OFFER_AT := Vector3(3.0, FLOOR_TOP, 4.0)
const OFFER_SIZE := Vector3(1.4, 0.8, 0.7)
const CAN_SIZE := Vector3(0.1, 0.12, 0.1)
const PYRAMID_ROWS := 6
## How far a can has to move from its place for the pyramid to count as fallen, and the fine.
const PYRAMID_MOVED := 0.15
const PYRAMID_FINE := 20
## The office in the front east corner, its door in its north wall; and the storeroom in the back east corner, its
## swing door an open gap.
const OFFICE_X := 8.0
const OFFICE_Z := 5.0
const OFFICE_DOOR_X := 10.0
const DESK_AT := Vector3(12.5, FLOOR_TOP, 9.5)
const DESK_SIZE := Vector3(1.8, 0.8, 0.9)
const STORE_X := 8.0
const STORE_Z := -5.0
const STORE_DOOR_X := 11.5
const BOX_STACKS: Array[Vector3] = [Vector3(10.0, FLOOR_TOP, -9.5), Vector3(13.5, FLOOR_TOP, -8.0),
	Vector3(13.5, FLOOR_TOP, -10.8)]
const BOX_STACK_SIZE := Vector3(1.2, 1.6, 1.2)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
## The 8 carts (step 2): three in a row in the front parking, three inside by the door and two loose in the aisles.
const CART_SPOTS: Array[Vector3] = [Vector3(7.0, FLOOR_TOP, HALF_Z + 2.5), Vector3(7.7, FLOOR_TOP, HALF_Z + 2.5),
	Vector3(8.4, FLOOR_TOP, HALF_Z + 2.5), Vector3(-0.2, FLOOR_TOP, 10.6), Vector3(0.5, FLOOR_TOP, 10.6),
	Vector3(1.2, FLOOR_TOP, 10.6), Vector3(-7.5, FLOOR_TOP, -2.0), Vector3(-2.5, FLOOR_TOP, 1.0)]
## The customers' aisles (not the one of the offer table), the walkways at both ends and how much each one keeps to a
## side so they don't walk through each other.
const CUSTOMER_AISLES: Array[float] = [-12.0, -7.5, -2.5]
const FRONT_WALK := 5.0
const BACK_WALK := -7.2
const CUSTOMER_LANE := 0.4
## Each customer: up one aisle, down another and the checkout whose queue they wait in.
const CUSTOMER_LOOPS: Array[Vector3i] = [Vector3i(1, 2, 1), Vector3i(2, 1, 0), Vector3i(0, 1, 0),
	Vector3i(1, 0, 2), Vector3i(2, 0, 1), Vector3i(0, 2, 2)]
## What one customer's complaint adds to the manager's.
const COMPLAINT_BUMP := 5.0
const MANAGER_SCENE := preload("res://scenes/npc/super_manager.tscn")
## Don Ofertón's round (step 3), back and forth: the front walkway, up the east aisle and along the back walkway.
const MANAGER_ROUTE: Array[Vector3] = [Vector3(-12.0, FLOOR_TOP, 5.6), Vector3(-7.5, FLOOR_TOP, 5.6),
	Vector3(-2.5, FLOOR_TOP, 5.6), Vector3(2.0, FLOOR_TOP, 5.6), Vector3(6.8, FLOOR_TOP, 5.6),
	Vector3(6.8, FLOOR_TOP, -1.0), Vector3(6.8, FLOOR_TOP, -7.2), Vector3(-2.5, FLOOR_TOP, -7.2),
	Vector3(-12.0, FLOOR_TOP, -7.2)]
## Where he stands at a checkout to look up a price (the cashier's side), facing the shop windows.
const CASHIER_SIDE := -0.75
## The price button on each checkout's counter, by the cashier.
const PRICE_BUTTON := Vector3(-0.25, FLOOR_TOP + 0.95, 7.0)
const SAW_PYRAMID := 10.0
## Lalo, the stocker (step 4), with his pyramid in front of him, and the crate of cans to restock beside him.
const STOCKER_AT := Vector3(9.5, FLOOR_TOP, -1.2)
const RESTOCK_AT := Vector3(10.8, FLOOR_TOP, -1.6)
const RESTOCK_SIZE := Vector3(0.6, 0.4, 0.4)
const RESTOCK_CANS := 6
const CAUGHT_ON := 10.0
## How often the loudspeaker tells everyone where the cops are, while one is inside.
const ANNOUNCE_EVERY := 20.0

const SPOTS := [
	{"id": "in_super_freezer", "at": Vector3(-3.0, FLOOR_TOP + 0.1, -8.6), "heavy": true},
	{"id": "behind_produce", "at": Vector3(-14.4, FLOOR_TOP, -0.6), "heavy": true},
	{"id": "between_storeroom_boxes", "at": Vector3(11.8, FLOOR_TOP, -9.0), "heavy": true},
	{"id": "by_loading_door", "at": Vector3(10.0, FLOOR_TOP, -11.3), "heavy": true},
	{"id": "in_cardboard_bin", "at": Vector3(-13.8, FLOOR_TOP, -6.5), "heavy": true},
	{"id": "in_super_office_corner", "at": Vector3(14.0, FLOOR_TOP, 11.0), "heavy": true},
	{"id": "on_top_shelf", "at": Vector3(-5.0, FLOOR_TOP + 1.8, -3.0), "heavy": false},
	{"id": "in_aisle_4", "at": Vector3(7.0, FLOOR_TOP, -2.0), "heavy": false},
	{"id": "under_checkout_belt", "at": Vector3(-6.0, FLOOR_TOP, 6.2), "heavy": false},
	{"id": "behind_offer_table", "at": Vector3(3.0, FLOOR_TOP, 3.3), "heavy": false},
	{"id": "by_produce_scale", "at": Vector3(-13.6, FLOOR_TOP + 0.9, 3.3), "heavy": false},
	{"id": "on_super_desk", "at": Vector3(13.0, FLOOR_TOP + 0.8, 9.5), "heavy": false},
]

const OUTSIDE := Color(0.95, 0.86, 0.4)
const TILE := Color(0.93, 0.9, 0.82)
const CEILING := Color(0.94, 0.94, 0.92)
const RED := Color(0.85, 0.25, 0.2)
const WOOD := Color(0.6, 0.44, 0.3)
const DARK := Color(0.1, 0.1, 0.12)
const CARDBOARD := Color(0.72, 0.56, 0.36)
const GLASS := Color(0.6, 0.82, 0.95)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
## The pyramid's cans, bottom row first, and where each one started.
var cans: Array[RigidBody3D] = []
var can_homes: Array[Vector3] = []
var pyramid_fallen := false
var fridge_cracked := false
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the pyramid and the fridge's glass.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: SupermarketRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var carts: Array[ShoppingCart] = []
var customers: Array[SuperCustomer] = []
## Don Ofertón, the manager (step 3), his price call on the checkouts and the complaint bar.
var manager: FloorBoss
var price_call: PriceCall
var complaint_bar: ProgressBar
var _announce_left := ANNOUNCE_EVERY
var stocker: SuperStocker
## Same seed, same supermarket (the stories and the hiding spots come from it, step 5).
@export var case_seed := 0
var _build: PlaceBuilder
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	if story_id == "":
		story_id = pick_story(case_seed, OS.get_cmdline_user_args())
	raid = RaidCase.new()
	raid.case_seed = case_seed
	raid.story_id = story_id
	raid.story_briefing = PackedStringArray(STORIES[story_id].briefing)
	raid.find_key = STORIES[story_id].find
	raid.car = car
	raid.solved_label = %CaseSolved
	raid.failed_label = %CaseFailed
	raid.shift_screen = $ShiftScreen
	raid.place_facts = _place_facts
	raid.place_state = net_state
	raid.apply_place_state = apply_net_state
	add_child(raid)
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_aisles()
	_build_back()
	_build_front()
	_build_rooms()
	_build_pyramid()
	_build_carts()
	_build_customers()
	office_door = _door(OFFICE_DOOR_X)
	_place_manager()
	_place_stocker()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("supermarket")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "supermarket", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = manager
	raid.owner_id = "supermarket"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	manager.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_SUPERMARKET"))
	_place_suspicion_clues()
	_give_clues()


## The supermarket's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_SUPER",
		"guess_key": "OBJ_GUESS_SUPER",
		"broken_key": "OBJ_BROKEN_SUPER",
		"complaint_key": "OBJ_COMPLAINT_SUPER",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": manager.complaint,
	}


## Online, what the guests' supermarket takes from the host's (RaidCase.snapshot): the pyramid, the fridge and what the
## story's rig decides on the host (the rest is step 8).
func net_state() -> Dictionary:
	return {"pyramid": pyramid_fallen, "fridge": fridge_cracked, "rig": rig.net_state() if rig else null}


func apply_net_state(state: Dictionary) -> void:
	if state.pyramid:
		topple_pyramid()
	if state.fridge:
		break_fridge()
	if rig and state.rig != null:
		rig.apply_net_state(state.rig)


## The story with that id from --story=<id> among the user args, or one drawn from the seed.
static func pick_story(seed_value: int, args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with("--story=") and STORIES.has(arg.trim_prefix("--story=")):
			return arg.trim_prefix("--story=")
	return STORIES.keys()[seed_value % STORIES.size()]


## The story's hidden items, each in a spot drawn with the seed (heavy ones only where they fit).
func _place_hidden() -> void:
	var story: Dictionary = STORIES[story_id]
	var spot_heavy: Array = SPOTS.map(func(spot: Dictionary) -> bool: return spot.heavy)
	hidden_spots = HidingDraw.draw(case_seed, spot_heavy, story.heavy, 1).spots
	for i in story.hidden.size():
		var item: Evidence = story.hidden[i].instantiate()
		item.position = SPOTS[hidden_spots[i]].at + Vector3.UP * (story.half_heights[i] + 0.01)
		add_child(item)
		hidden.append(item)
	if story.get("main_hidden", false):
		main = hidden[0]
		extras.assign(hidden.slice(1))
	else:
		extras.assign(hidden)


## One clue note for each suspicion, the true one too, on note places drawn with the seed.
func _place_suspicion_clues() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed * 17 + 3
	var free: Array = range(NOTE_PLACES.size())
	for id: String in raid.suspicions:
		var place: int = free.pop_at(rng.randi_range(0, free.size() - 1))
		var note: ClueNote = NOTE_SCENE.instantiate()
		note.text = tr("CLUE_SUSPECT_" + id)
		note.position = NOTE_PLACES[place] + Vector3.UP * 0.01
		note.rotation.y = place * 0.9
		note.read.connect(raid.add_clue)
		add_child(note)


## What Don Ofertón lets slip when asked (where the story's things are, in an order drawn from the seed), and what Lalo
## saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		manager.slips.append(tr("OFERTON_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	manager.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	stocker.clue = tr("CLUE_LALO") % where
	stocker.clue_speech = tr("LALO_CLUE_" + story_id) % where
	stocker.told.connect(raid.add_clue)


## The tiled floor, the walls with the doorway and the shop windows, the roof and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, TILE)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, CEILING)
	var x0 := ENTRANCE_X - ENTRANCE_WIDTH / 2
	var x1 := ENTRANCE_X + ENTRANCE_WIDTH / 2
	_build.wall_at("x", HALF_Z, -HALF_X, x0, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x1, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x0, x1, ENTRANCE_HEIGHT, WALL_TOP - ENTRANCE_HEIGHT, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	# The shop windows on the front, with the week's offers painted on them.
	for x: float in [-11.0, -6.0, -1.5]:
		_build.mesh_box(Vector3(x, 1.7, HALF_Z + 0.08), Vector3(3.6, 2.0, 0.02), GLASS)
		_build.mesh_box(Vector3(x, 2.3, HALF_Z + 0.1), Vector3(2.0, 0.4, 0.02), RED)
	_label("PLACE_SUPERMARKET", Vector3(0, WALL_TOP + 0.9, HALF_Z + 0.08), 110)
	for x: float in [-10.0, -5.0, 0.0, 5.0, 10.0]:
		for z: float in [-7.0, 0.0, 7.0]:
			_build.light(Vector3(x, 4.6, z))


## The four gondolas, each of three modules, and the aisle signs hanging over the aisles on their east side.
func _build_aisles() -> void:
	for i in GONDOLA_X.size():
		var x := GONDOLA_X[i]
		_solid(Vector3(x, FLOOR_TOP + GONDOLA_SIZE.y / 2, GONDOLA_FROM_Z + GONDOLA_SIZE.z / 2), GONDOLA_SIZE)
		for m in 3:
			_model(GONDOLA_MODEL, Vector3(x, FLOOR_TOP, GONDOLA_FROM_Z + GONDOLA_MODULE * (m + 0.5)))
		var sign_at := Vector3(x + 2.5, 3.6, GONDOLA_FROM_Z + GONDOLA_SIZE.z / 2)
		_build.mesh_box(sign_at, Vector3(1.6, 0.6, 0.04), RED)
		# Read from both ends of the aisle.
		_label("SUPER_AISLE_%d" % (i + 1), sign_at + Vector3(0, 0, 0.04), 40)
		_label("SUPER_AISLE_%d" % (i + 1), sign_at - Vector3(0, 0, 0.04), 40, PI)


## The dairy fridge along the back wall, its glass that cracks, and the chest freezer in front of it.
func _build_back() -> void:
	for x: float in FRIDGE_X:
		_solid(Vector3(x, FLOOR_TOP + FRIDGE_SIZE.y / 2, FRIDGE_Z), FRIDGE_SIZE)
		_model(FRIDGE_MODEL, Vector3(x, FLOOR_TOP, FRIDGE_Z))
	var width := FRIDGE_SIZE.x * FRIDGE_X.size()
	var glass := _area(Vector3(-7.0, FLOOR_TOP + 1.0, FRIDGE_Z + FRIDGE_SIZE.z / 2 + 0.2), Vector3(width, 1.6, 0.4))
	glass.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > FRIDGE_SPEED:
			break_fridge())
	_build.open_box(FREEZER_AT, FREEZER_SIZE, "top", Color(0.93, 0.94, 0.95))
	_model(FREEZER_MODEL, FREEZER_AT)
	# The cardboard bin in the back west corner, open on top.
	_build.open_box(Vector3(-13.8, FLOOR_TOP, -6.5), Vector3(1.4, 1.0, 1.2), "top", CARDBOARD.darkened(0.2))


## The produce stand, the three checkouts with checkout 1's till, and the offer table by the door.
func _build_front() -> void:
	_solid(PRODUCE_AT + Vector3(0, PRODUCE_SIZE.y / 2, 0), PRODUCE_SIZE)
	_model(PRODUCE_MODEL, PRODUCE_AT, PI)
	for x: float in CHECKOUT_X:
		_solid(Vector3(x, FLOOR_TOP + CHECKOUT_SIZE.y / 2, CHECKOUT_Z), CHECKOUT_SIZE)
		_model(CHECKOUT_MODEL, Vector3(x, FLOOR_TOP, CHECKOUT_Z))
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_SUPERMARKET"
	add_child(till)
	_solid(OFFER_AT + Vector3(0, OFFER_SIZE.y / 2, 0), OFFER_SIZE)
	_build.mesh_box(OFFER_AT + Vector3(0, OFFER_SIZE.y / 2, 0), OFFER_SIZE, RED)
	_label("SUPER_OFFER", OFFER_AT + Vector3(0, 1.9, 0), 48, 0.0, 0.004)


## The manager's office (walls, its locked door and a desk) and the storeroom with its stacks of boxes.
func _build_rooms() -> void:
	_build.wall_at("x", OFFICE_Z, OFFICE_X, HALF_X, 0.0, WALL_TOP, [OFFICE_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("z", OFFICE_X, OFFICE_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.04, DARK)
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.02, 0), Vector3(DESK_SIZE.x, 0.04, DESK_SIZE.z), WOOD)
	_build.wall_at("x", STORE_Z, STORE_X, HALF_X, 0.0, WALL_TOP, [STORE_DOOR_X], OUTSIDE.lightened(0.1))
	_build.wall_at("z", STORE_X, -HALF_Z, STORE_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.1))
	for at: Vector3 in BOX_STACKS:
		_build.box(at + Vector3(0, BOX_STACK_SIZE.y / 2, 0), BOX_STACK_SIZE, CARDBOARD)
	# The loading door in the back wall, closed.
	_build.mesh_box(Vector3(10.0, 1.6, -HALF_Z + 0.1), Vector3(3.0, 3.2, 0.04), DARK.lightened(0.3))


## The pyramid of cans on the offer table: each row half a can in from the one under it, asleep until bumped.
func _build_pyramid() -> void:
	var top := OFFER_AT.y + OFFER_SIZE.y
	for row in PYRAMID_ROWS:
		var count := PYRAMID_ROWS - row
		for i in count:
			var at := OFFER_AT + Vector3((i - (count - 1) / 2.0) * CAN_SIZE.x, 0, 0)
			at.y = top + CAN_SIZE.y * (row + 0.5)
			var can := ClubEvidence.make_item("Can", CAN_MODEL, CAN_SIZE, 0.4)
			(can.get_child(1) as Node3D).position.y = -CAN_SIZE.y / 2
			add_child(can)
			can.position = at
			can.sleeping = true
			can.add_to_group("super_cans")
			cans.append(can)
			can_homes.append(at)


func _build_carts() -> void:
	for i in CART_SPOTS.size():
		var cart := ShoppingCart.new()
		cart.name = "Cart%d" % i
		add_child(cart)
		cart.position = CART_SPOTS[i]
		cart.rotation.y = PI if i < 6 else PI / 2
		carts.append(cart)


## Six customers on their loops, each starting at a different point of it so they're spread through the store.
func _build_customers() -> void:
	for i in CUSTOMER_LOOPS.size():
		var loop := CUSTOMER_LOOPS[i]
		var lane := CUSTOMER_LANE * (1 if i % 2 == 0 else -1)
		var up := CUSTOMER_AISLES[loop.x] + lane
		var down := CUSTOMER_AISLES[loop.y] - lane
		var customer := SuperCustomer.new()
		customer.name = "Customer%d" % i
		customer.look = SuperCustomer.LOOKS[i % SuperCustomer.LOOKS.size()]
		customer.route = [Vector3(up, FLOOR_TOP, FRONT_WALK), Vector3(up, FLOOR_TOP, BACK_WALK),
			Vector3(down, FLOOR_TOP, BACK_WALK), Vector3(down, FLOOR_TOP, FRONT_WALK),
			Vector3(CHECKOUT_X[loop.z] + 0.9, FLOOR_TOP, FRONT_WALK + 0.4)]
		customer.queue_at = 4
		customer.next_line = i * 3
		var start := i % customer.route.size()
		customer.next_point = (start + 1) % customer.route.size()
		add_child(customer)
		customer.position = customer.route[start]
		customer.complained.connect(func(_c: SuperCustomer) -> void:
			if manager:
				manager.blame(COMPLAINT_BUMP, "OFERTON_CUSTOMER"))
		customers.append(customer)


## Don Ofertón on his round, the price buttons on the checkouts, what he notices and the complaint bar.
func _place_manager() -> void:
	price_call = PriceCall.new()
	price_call.name = "PriceCall"
	for x: float in CHECKOUT_X:
		price_call.spots.append(Vector3(x + PRICE_BUTTON.x, PRICE_BUTTON.y, PRICE_BUTTON.z))
	add_child(price_call)
	manager = MANAGER_SCENE.instantiate()
	manager.route = MANAGER_ROUTE
	manager.printer = price_call
	add_child(manager)
	manager.start_at(0)
	price_call.called.connect(func(index: int) -> void:
		manager.printer_spot = cashier_spot(index)
		manager.fix_facing = to_global(cashier_spot(index) + Vector3(0, 0, 5))
		_say(cashier_spot(index) + Vector3(0, 2.6, 0), "OFERTON_PRICE_CALL"))
	price_call.caught_on.connect(manager.blame.bind(CAUGHT_ON, "OFERTON_CAUGHT_ON"))
	office_door.broken.connect(manager.door_broken)
	till.opened.connect(func(at: Vector3) -> void: manager.saw(at, FloorBoss.SAW_TILL))
	pyramid_fell.connect(func() -> void: manager.saw(to_global(OFFER_AT + Vector3.UP), SAW_PYRAMID, "OFERTON_PYRAMID"))
	fridge_broken.connect(func() -> void:
		manager.saw(to_global(Vector3(-7.0, 1.0, FRIDGE_Z + 0.5)), FloorBoss.SAW_BREAK, "OFERTON_FRIDGE"))
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
	manager.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Lalo building his pyramid, and the crate of cans beside him that a cop can hand him.
func _place_stocker() -> void:
	stocker = SuperStocker.new()
	stocker.name = "Lalo"
	stocker.position = STOCKER_AT
	add_child(stocker)
	_solid(RESTOCK_AT + Vector3(0, RESTOCK_SIZE.y / 2, 0), RESTOCK_SIZE)
	_build.mesh_box(RESTOCK_AT + Vector3(0, RESTOCK_SIZE.y / 2, 0), RESTOCK_SIZE, CARDBOARD)
	for i in RESTOCK_CANS:
		var can := ClubEvidence.make_item("RestockCan%d" % i, CAN_MODEL, CAN_SIZE, 0.4)
		(can.get_child(1) as Node3D).position.y = -CAN_SIZE.y / 2
		can.add_to_group("super_cans")
		add_child(can)
		can.position = RESTOCK_AT + Vector3((i % 3 - 1) * 0.15, RESTOCK_SIZE.y + CAN_SIZE.y / 2, (i / 3 - 0.5) * 0.15)
		can.sleeping = true


## Where Don Ofertón stands to look up a price at checkout `index`: the cashier's side, in this scene's space.
func cashier_spot(index: int) -> Vector3:
	return Vector3(CHECKOUT_X[index] + CASHIER_SIDE, FLOOR_TOP, CHECKOUT_Z)


## Which aisle (1 to 4) `at` is in, in this scene's space, or 0 when it's not among the gondolas.
static func aisle_of(at: Vector3) -> int:
	if at.z < GONDOLA_FROM_Z or at.z > GONDOLA_FROM_Z + GONDOLA_MODULE * 3:
		return 0
	var aisle := 1
	for x: float in GONDOLA_X:
		if at.x > x:
			aisle += 1
	return clampi(aisle - 1, 1, 4)


## Every ANNOUNCE_EVERY seconds with a cop inside, the loudspeaker tells everyone where: "¡hay policías en el pasillo
## 2!", or only that they're in the store.
func announce(cop: Node3D) -> String:
	var at := to_local(cop.global_position)
	var aisle := aisle_of(at)
	var line := tr("OFERTON_SPEAKER_AISLE") % aisle if aisle > 0 else tr("OFERTON_SPEAKER_STORE")
	var label := MarketShopper.make_bubble()
	label.text = line
	label.position = Vector3(at.x, WALL_TOP - 0.8, at.z)
	label.modulate = Color(1, 0.9, 0.5)
	label.show()
	add_child(label)
	get_tree().create_timer(5.0).timeout.connect(label.queue_free)
	return line


func _cop_inside() -> Node3D:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var at := to_local(cop.global_position)
		if absf(at.x) < HALF_X and absf(at.z) < HALF_Z:
			return cop
	return null


func _physics_process(delta: float) -> void:
	_announce_left -= delta
	if _announce_left <= 0.0:
		_announce_left = ANNOUNCE_EVERY
		var cop := _cop_inside()
		if cop:
			announce(cop)
	if pyramid_fallen:
		return
	for i in cans.size():
		if cans[i].position.distance_to(can_homes[i]) > PYRAMID_MOVED:
			topple_pyramid()
			return


## The pyramid fell, once: a fine and the manager on the loudspeaker.
func topple_pyramid() -> void:
	if pyramid_fallen:
		return
	pyramid_fallen = true
	broken_goods += 1
	fines += PYRAMID_FINE
	for can in cans:
		can.sleeping = false
	_say(OFFER_AT + Vector3(0, 2.2, 0), "SUPER_PYRAMID_FELL")
	pyramid_fell.emit()


## The fridge's glass cracked, once: a fine and the cracks over it.
func break_fridge() -> void:
	if fridge_cracked:
		return
	fridge_cracked = true
	broken_goods += 1
	fines += FRIDGE_FINE
	for i in 9:
		_build.mesh_box(Vector3(-11.5 + i * 1.3, FLOOR_TOP + 0.8 + (i % 3) * 0.3, FRIDGE_Z + FRIDGE_SIZE.z / 2 + 0.03),
			Vector3(0.7, 0.02, 0.02), DARK)
	_say(Vector3(-7.0, 2.8, FRIDGE_Z + 1.0), "SUPER_FRIDGE_BROKEN")
	fridge_broken.emit()


## A locked door in the office's north wall, its middle at x.
func _door(x: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(x - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_Z)
	add_child(door)
	return door


## A box only to bump into, under a model that gives the look.
func _solid(center: Vector3, size: Vector3) -> void:
	_build.shape(_build.body(center), size)


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


func _label(key: String, at: Vector3, size: int, turn := 0.0, pixel := 0.01) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = pixel
	label.outline_size = 18
	label.double_sided = false
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)


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
