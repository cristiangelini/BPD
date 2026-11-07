class_name PawnShop
extends Node3D

## The pawn shop "Empeños La Última Oferta" as a place to raid (docs/diseno/allanamiento-empenos.md, step 1): a shop
## on its lot in the city, open and with the front to +Z. The barred counter stands by the door on the east side, with
## the stock room's key in its till, the parrot's cage hanging beside it and the cookie jar on top; three glass cases
## stand in a row in the middle, four shelves of pawned things behind them and along the west wall, with the knight's
## armor, the stuffed crocodile, the old TV and the guitar case among them. The stock room is the locked back of the
## shop, with its shelves, boxes, the big safe and the desk. The glass cases break if something hits them fast and so
## does the armor, which falls apart, a fine each. Every number here is (propuesta).

signal case_broken(index: int)
signal armor_fallen
## A customer complained (Don Regateo adds it to the complaint, step 3).
signal customer_complained(customer: PawnCustomer)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const OWNER_SCENE := preload("res://scenes/npc/pawn_owner.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the shop can be suspected of (allanamiento-empenos.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["train_watches", "fake_trophy", "walking_armor", "gold_dentures", "singer_guitar",
	"croc_smuggler"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_PAWN_TIP_B", "BRIEF_TIP_C", "BRIEF_PAWN_TIP_D",
	"BRIEF_PAWN_TIP_E"]
## The stories the shop can tell, like CostumeShop.STORIES: what the comisario says once it's guessed, its "find it"
## row, what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist
## rows of its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras;
## without it the rig sets the main evidence.
const STORIES := {
	"train_watches": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_TRAIN_WATCHES_B", "BRIEF_TRAIN_WATCHES_C", "BRIEF_TRAIN_WATCHES_D"],
		"find": "OBJ_FIND_TRAIN_WATCHES",
		"hidden": [preload("res://scenes/props/watch_suitcase.tscn"), preload("res://scenes/props/passenger_list.tscn"),
			preload("res://scenes/props/train_ticket.tscn")],
		"half_heights": [0.0, 0.0, 0.0],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_PASSENGER_LIST", "OBJ_EXTRA_TRAIN_TICKET"],
		"main_hidden": true,
		"rig": preload("res://scripts/case/pawn/train_watches_rig.gd"),
	},
	"fake_trophy": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FAKE_TROPHY_B", "BRIEF_FAKE_TROPHY_C", "BRIEF_FAKE_TROPHY_D"],
		"find": "OBJ_FIND_FAKE_TROPHY",
		"hidden": [preload("res://scenes/props/gold_trophy.tscn"), preload("res://scenes/props/painter_receipt.tscn")],
		"half_heights": [0.0, 0.0],
		"heavy": [true, false],
		"extra_keys": ["OBJ_EXTRA_PAINTER_RECEIPT", "OBJ_EXTRA_PLASTIC_TROPHY"],
		"main_hidden": true,
		"rig": preload("res://scripts/case/pawn/fake_trophy_rig.gd"),
	},
	"walking_armor": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_WALKING_ARMOR_B", "BRIEF_WALKING_ARMOR_C", "BRIEF_WALKING_ARMOR_D"],
		"find": "OBJ_FIND_WALKING_ARMOR",
		"hidden": [preload("res://scenes/props/armor_costume.tscn"), preload("res://scenes/props/oil_rag.tscn"),
			preload("res://scenes/props/robbed_houses_map.tscn")],
		"half_heights": [0.0, 0.0, 0.0],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_OIL_RAG", "OBJ_EXTRA_ROBBED_MAP"],
		"main_hidden": true,
		"rig": preload("res://scripts/case/pawn/walking_armor_rig.gd"),
	},
	"gold_dentures": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_GOLD_DENTURES_B", "BRIEF_GOLD_DENTURES_C", "BRIEF_GOLD_DENTURES_D"],
		"find": "OBJ_FIND_GOLD_DENTURES",
		"hidden": [preload("res://scenes/props/dentures_box.tscn"), preload("res://scenes/props/dentist_pliers.tscn"),
			preload("res://scenes/props/patient_list.tscn")],
		"half_heights": [0.0, 0.0, 0.0],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_DENTIST_PLIERS", "OBJ_EXTRA_PATIENT_LIST"],
		"main_hidden": true,
		"rig": preload("res://scripts/case/pawn/gold_dentures_rig.gd"),
	},
	"singer_guitar": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SINGER_GUITAR_B", "BRIEF_SINGER_GUITAR_C", "BRIEF_SINGER_GUITAR_D"],
		"find": "OBJ_FIND_SINGER_GUITAR",
		"hidden": [preload("res://scenes/props/star_guitar.tscn"), preload("res://scenes/props/signed_photo.tscn"),
			preload("res://scenes/props/tour_contract.tscn")],
		"half_heights": [0.0, 0.0, 0.0],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_SIGNED_PHOTO", "OBJ_EXTRA_TOUR_CONTRACT"],
		"main_hidden": true,
		"rig": preload("res://scripts/case/pawn/singer_guitar_rig.gd"),
	},
	"croc_smuggler": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_CROC_SMUGGLER_B", "BRIEF_CROC_SMUGGLER_C", "BRIEF_CROC_SMUGGLER_D"],
		"find": "OBJ_FIND_CROC_SMUGGLER",
		"hidden": [preload("res://scenes/props/customs_label.tscn"), preload("res://scenes/props/ship_receipt.tscn")],
		"half_heights": [0.0, 0.0],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_CUSTOMS_LABEL", "OBJ_EXTRA_SHIP_RECEIPT"],
		"rig": preload("res://scripts/case/pawn/croc_smuggler_rig.gd"),
	},
}
## Surfaces where the suspicions' clue notes can lie, one in each part of the shop (never on the counter, which would
## buy them); three are drawn with the seed.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(3.5, FLOOR_TOP + 0.8, -7.8), Vector3(3.2, FLOOR_TOP + 0.55, -1.5), Vector3(-6.6, FLOOR_TOP, 7.6),
	Vector3(-9.6, FLOOR_TOP, -0.3), Vector3(9.5, FLOOR_TOP, -6.0), Vector3(-8.5, FLOOR_TOP, 3.6),
]
const COUNTER_MODEL := preload("res://assets/models/pawn_counter.glb")
const CASE_MODEL := preload("res://assets/models/pawn_case.glb")
const SHELF_MODEL := preload("res://assets/models/pawn_shelf.glb")
const ARMOR_MODEL := preload("res://assets/models/knight_armor.glb")
const CROC_MODEL := preload("res://assets/models/stuffed_croc.glb")
const TV_MODEL := preload("res://assets/models/old_tv.glb")
const GUITAR_MODEL := preload("res://assets/models/guitar_case.glb")
const CAGE_MODEL := preload("res://assets/models/pawn_parrot_cage.glb")
const STOCK_SHELF_MODEL := preload("res://assets/models/pawn_stock_shelf.glb")
const BOXES_MODEL := preload("res://assets/models/pawn_boxes.glb")
const SAFE_MODEL := preload("res://assets/models/pawn_safe.glb")
const TAG_MODEL := preload("res://assets/models/giant_price_tag.glb")
## The shop's own goods for sale on the glass cases (step 2): model, size, kg and price.
const GOODS := [
	{"name": "Trophy", "model": preload("res://assets/models/pawn_trophy.glb"), "size": Vector3(0.2, 0.36, 0.2),
		"kg": 1.5, "price": 8},
	{"name": "Radio", "model": preload("res://assets/models/pawn_radio.glb"), "size": Vector3(0.4, 0.26, 0.16),
		"kg": 3.0, "price": 12},
	{"name": "CuckooClock", "model": preload("res://assets/models/pawn_clock.glb"), "size": Vector3(0.26, 0.36, 0.14),
		"kg": 2.0, "price": 6},
]
const HALF_X := 11.0
const HALF_Z := 9.0
const WALL_TOP := 4.5
const BUILDING_TOP := 6.0
const FLOOR_TOP := 0.06
## The open doorway in the middle of the front wall.
const ENTRANCE_X := 0.0
const ENTRANCE_WIDTH := 3.5
const ENTRANCE_HEIGHT := 3.0

## The barred counter by the door, its shop side to -Z (its till holds the stock room's key).
const COUNTER_AT := Vector3(6.0, FLOOR_TOP, 5.0)
const COUNTER_SIZE := Vector3(5.0, 1.0, 0.8)
const TILL_ON := Vector3(7.8, FLOOR_TOP + 1.02, 5.0)
const JAR_ON := Vector3(4.4, FLOOR_TOP + 1.0, 5.0)
## Where a customer stands at the counter to pawn something, and the counter's top where things change hands.
const COUNTER_SPOT := Vector3(5.0, FLOOR_TOP, 4.05)
## The 3 customers browse the shelves and walk to the counter along the aisle in front of the glass cases and the one
## east of them; the next one goes this long after the last is back.
const CUSTOMER_HOMES: Array[Vector3] = [Vector3(-6.0, FLOOR_TOP, 0.6), Vector3(-3.0, FLOOR_TOP, 0.6),
	Vector3(0.0, FLOOR_TOP, 0.6)]
const CUSTOMER_LOOKS := ["cliente", "clienta", "abuelo"]
const AISLE_Z := 1.45
const AISLE_X := 2.8
const TURN_GAP := 4.0
const FIRST_TURN := 3.0
## Don Regateo's round: back and forth behind his counter, never out in the shop. Something to pawn sends him to the
## appraisal mat in the corner behind the counter, crouched over it, his back to the shop.
const OWNER_ROUTE: Array[Vector3] = [Vector3(3.9, FLOOR_TOP, 6.3), Vector3(6.5, FLOOR_TOP, 6.3),
	Vector3(9.3, FLOOR_TOP, 6.3)]
const APPRAISAL_ON := Vector3(10.0, FLOOR_TOP, 7.9)
## What he notices besides what every owner does: a customer's complaint (each one's own cooldown, PawnCustomer),
## something taken out unpaid and the cops' third appraisal.
const CUSTOMER_COMPLAINT := 5.0
const TAKEN_COMPLAINT := 10.0
const CAUGHT_ON := 10.0
## The parrot's cage hangs from the ceiling by the counter's east end.
const CAGE_AT := Vector3(9.6, 2.2, 4.2)
## The three glass cases in a row in the middle of the shop, and what breaks them.
const CASES: Array[Vector3] = [Vector3(-6.0, FLOOR_TOP, 2.5), Vector3(-2.5, FLOOR_TOP, 2.5),
	Vector3(1.0, FLOOR_TOP, 2.5)]
const CASE_SIZE := Vector3(2.0, 1.1, 0.8)
const CASE_SPEED := 3.0
const CASE_FINE := 20
## The four shelves of pawned things: two along the west wall (turned to face +X) and two in the middle.
const SHELVES: Array[Vector3] = [Vector3(-10.4, FLOOR_TOP, 1.5), Vector3(-10.4, FLOOR_TOP, -2.0),
	Vector3(-5.0, FLOOR_TOP, -1.5), Vector3(-0.5, FLOOR_TOP, -1.5)]
const SHELF_SIZE := Vector3(3.0, 2.2, 0.6)
## The knight's armor by the west wall up front, and what makes it fall apart.
const ARMOR_AT := Vector3(-9.6, FLOOR_TOP, 5.5)
const ARMOR_SPEED := 3.0
const ARMOR_FINE := 15
## The stuffed crocodile along the front wall, the old TV by the middle shelves and the guitar case on the floor.
const CROC_AT := Vector3(-4.5, FLOOR_TOP, 7.8)
const TV_AT := Vector3(3.2, FLOOR_TOP, -1.5)
const GUITAR_AT := Vector3(-7.6, FLOOR_TOP, 6.8)
## The stock room: the locked back of the shop, its front wall at STOCK_Z with the door at STOCK_DOOR_X; its shelves on
## the back wall, a pile of boxes, the big safe and the desk with the pawn book.
const STOCK_Z := -4.5
const STOCK_DOOR_X := -3.0
const STOCK_SHELVES_X: Array[float] = [-8.0, -5.5]
const STOCK_SHELF_Z := -8.4
const BOXES_AT := Vector3(-1.5, FLOOR_TOP, -7.8)
const SAFE_AT := Vector3(8.5, FLOOR_TOP, -8.3)
const DESK_AT := Vector3(3.5, FLOOR_TOP, -7.8)
const DESK_SIZE := Vector3(1.8, 0.8, 0.9)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "by_pawn_stock_shelf", "at": Vector3(-6.8, FLOOR_TOP, -7.6), "heavy": true},
	{"id": "in_pawn_boxes", "at": Vector3(-0.4, FLOOR_TOP, -7.8), "heavy": true},
	{"id": "behind_knight_armor", "at": Vector3(-10.2, FLOOR_TOP, 6.6), "heavy": true},
	{"id": "behind_pawn_counter", "at": Vector3(5.0, FLOOR_TOP, 6.0), "heavy": true},
	{"id": "by_old_tv", "at": Vector3(3.2, FLOOR_TOP, -0.6), "heavy": true},
	{"id": "in_pawn_stock_corner", "at": Vector3(10.2, FLOOR_TOP, -5.4), "heavy": true},
	{"id": "in_pawn_safe", "at": Vector3(8.5, FLOOR_TOP, -7.5), "heavy": false},
	{"id": "behind_stuffed_croc", "at": Vector3(-2.9, FLOOR_TOP, 8.4), "heavy": false},
	{"id": "in_guitar_case", "at": Vector3(-7.6, FLOOR_TOP + 0.1, 6.8), "heavy": false},
	{"id": "under_pawn_desk", "at": Vector3(3.5, FLOOR_TOP, -7.8), "heavy": false},
	{"id": "under_parrot_cage", "at": Vector3(9.6, FLOOR_TOP, 3.6), "heavy": false},
	{"id": "on_pawn_case", "at": Vector3(1.0, FLOOR_TOP + CASE_SIZE.y, 2.5), "heavy": false},
]

const OUTSIDE := Color(0.25, 0.42, 0.34)
const FLOOR := Color(0.5, 0.42, 0.36)
const CEILING := Color(0.9, 0.88, 0.82)
const WALLS := Color(0.92, 0.84, 0.66)
const STOCK := Color(0.7, 0.66, 0.6)
const WOOD := Color(0.42, 0.25, 0.16)
const DARK := Color(0.1, 0.1, 0.12)
const STEEL := Color(0.72, 0.74, 0.77)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var stock_door: FrontDoor
var till: Till
## Which glass cases are broken, by index into CASES.
var cases_broken: Array[bool] = [false, false, false]
var armor_down := false
## Where the armor stands now (a story can walk it, move_armor), and its collider, look and hit area.
var armor_at := ARMOR_AT
var armor_parts: Array[Node3D] = []
## The stuffed crocodile's collider and look (a story can swap it for evidence).
var croc_parts: Array[Node3D] = []
## What broke: the glass cases and the armor (the case pay also loses what the cops paid the shop and gains what it
## paid them, RaidCase.fines).
var fines := 0
## The case flow every raid shares.
var raid: RaidCase
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: PawnRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## Same seed, same shop (the stories and the hiding spots come from it, step 5).
@export var case_seed := 0
## The counter's top: what the shop buys and sells (step 2).
var counter: PawnCounter
## Chicharra the parrot and the cookie jar on the counter (step 4).
var parrot: PawnParrot
var cookie_jar: CookieJar
var owner_boss: FloorBoss
var appraisal: Appraisal
var complaint_bar: ProgressBar
var goods: Array[Grabbable] = []
var customers: Array[PawnCustomer] = []
## The customer whose turn it is (null between turns), the next one in line and how long until they go.
var on_turn: PawnCustomer
var _next_customer := 0
var _turn_left := FIRST_TURN
var _displayed := 0
var _build: PlaceBuilder
var _armor: Node3D
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
	add_child(raid)
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_counter()
	_build_cases()
	_build_shelves()
	_build_odd_things()
	_build_stock()
	stock_door = _door(STOCK_DOOR_X)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("pawn_shop")
	station_parking = city.transform * CityLayout.parking("station")
	raid.station_parking = station_parking
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "pawn_shop", car)
	_build_trade()
	_build_customers()
	_place_owner()
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = owner_boss
	raid.owner_id = "pawn_shop"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The shop's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_PAWN",
		"guess_key": "OBJ_GUESS_PAWN",
		"broken_key": "OBJ_BROKEN_PAWN",
		"complaint_key": "OBJ_COMPLAINT_PAWN",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": cases_broken.count(true) + int(armor_down),
		"complaint": owner_boss.complaint,
	}


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


## What Don Regateo lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Chicharra heard: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		owner_boss.slips.append(tr("REGATEO_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	owner_boss.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	parrot.clue = tr("CLUE_CHICHARRA") % where
	parrot.clue_speech = tr("CHICHARRA_CLUE_" + story_id) % where
	parrot.told.connect(raid.add_clue)


## The floor, the walls with the doorway, the ceiling with its lights, the roof, the sign and its giant price tag.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, CEILING)
	var x0 := ENTRANCE_X - ENTRANCE_WIDTH / 2
	var x1 := ENTRANCE_X + ENTRANCE_WIDTH / 2
	_build.wall_at("x", HALF_Z, -HALF_X, x0, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x1, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x0, x1, ENTRANCE_HEIGHT, WALL_TOP - ENTRANCE_HEIGHT, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], WALLS)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], WALLS)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], WALLS)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_label("PLACE_PAWN_SHOP", Vector3(-5.5, WALL_TOP + 0.6, HALF_Z + 0.08), 96)
	_label("PAWN_MOTTO", Vector3(-5.5, ENTRANCE_HEIGHT + 0.6, HALF_Z + 0.08), 60)
	_model(TAG_MODEL, Vector3(6.0, BUILDING_TOP + 0.8, HALF_Z - 0.6))
	for x: float in [-7.5, -2.5, 2.5, 7.5]:
		for z: float in [-7.0, -2.0, 2.5, 7.0]:
			_build.light(Vector3(x, 4.1, z)).light_energy = 1.2


## The barred counter by the door with its till, the cookie jar and the parrot's cage.
func _build_counter() -> void:
	_solid(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0), COUNTER_SIZE)
	_model(COUNTER_MODEL, COUNTER_AT)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_PAWN"
	add_child(till)
	cookie_jar = CookieJar.new()
	cookie_jar.name = "CookieJar"
	cookie_jar.position = JAR_ON
	add_child(cookie_jar)
	_model(CAGE_MODEL, CAGE_AT + Vector3.UP * 0.75)
	parrot = PawnParrot.new()
	parrot.name = "Chicharra"
	parrot.jar = cookie_jar
	parrot.position = CAGE_AT + Vector3.UP * 0.75
	add_child(parrot)
	var hook := CAGE_AT.y + 0.75
	_build.mesh_box(Vector3(CAGE_AT.x, (hook + WALL_TOP) / 2, CAGE_AT.z), Vector3(0.02, WALL_TOP - hook, 0.02), DARK)


## The three glass cases, each with what breaks it from any side.
func _build_cases() -> void:
	for i in CASES.size():
		_solid(CASES[i] + Vector3(0, CASE_SIZE.y / 2, 0), CASE_SIZE)
		_model(CASE_MODEL, CASES[i])
		var hit := _area(CASES[i] + Vector3(0, CASE_SIZE.y / 2, 0), CASE_SIZE + Vector3(0.4, 0.4, 0.4))
		hit.body_entered.connect(func(body: Node3D) -> void:
			if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > CASE_SPEED:
				break_case(i))


## The four shelves of pawned things, each with its price tag sign.
func _build_shelves() -> void:
	for i in SHELVES.size():
		var turn := PI / 2 if i < 2 else 0.0
		var size := Vector3(SHELF_SIZE.z, SHELF_SIZE.y, SHELF_SIZE.x) if i < 2 else SHELF_SIZE
		_solid(SHELVES[i] + Vector3(0, SHELF_SIZE.y / 2, 0), size)
		_model(SHELF_MODEL, SHELVES[i], turn)


## The knight's armor (it falls apart if hit), the stuffed crocodile, the old TV and the guitar case.
func _build_odd_things() -> void:
	var armor_body := _solid(ARMOR_AT + Vector3(0, 0.95, 0), Vector3(0.7, 1.9, 0.6))
	_armor = _model(ARMOR_MODEL, ARMOR_AT, PI / 2)
	var armor_hit := _area(ARMOR_AT + Vector3(0, 0.95, 0), Vector3(1.1, 1.9, 1.0))
	armor_parts.assign([armor_body, _armor, armor_hit])
	armor_hit.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > ARMOR_SPEED:
			knock_armor())
	croc_parts.assign([_solid(CROC_AT + Vector3(0, 0.2, 0), Vector3(2.2, 0.4, 0.5)), _model(CROC_MODEL, CROC_AT)])
	_solid(TV_AT + Vector3(0, 0.28, 0), Vector3(0.7, 0.55, 0.5))
	_model(TV_MODEL, TV_AT)
	_model(GUITAR_MODEL, GUITAR_AT)


## The counter's top that buys and sells, and the shop's own goods on the glass cases.
func _build_trade() -> void:
	counter = PawnCounter.new()
	counter.name = "TradeCounter"
	add_child(counter)
	counter.setup(self, COUNTER_AT + Vector3(0, COUNTER_SIZE.y + 0.25, 0), Vector3(COUNTER_SIZE.x, 0.5, COUNTER_SIZE.z))
	for i in GOODS.size():
		var good: Dictionary = GOODS[i]
		var item := ClubEvidence.make_item(good.name, good.model, good.size, good.kg)
		(item.get_child(0) as CollisionShape3D).position.y = (good.size as Vector3).y / 2
		add_child(item)
		item.position = CASES[i] + Vector3(0, CASE_SIZE.y + 0.02, 0)
		counter.stock(item, good.price)
		goods.append(item)


## Don Regateo behind his counter, the appraisal that turns him away, what he notices and the complaint bar.
func _place_owner() -> void:
	appraisal = Appraisal.new()
	appraisal.name = "Appraisal"
	appraisal.position = APPRAISAL_ON
	add_child(appraisal)
	appraisal.appraised.connect(counter.appraisal_done)
	owner_boss = OWNER_SCENE.instantiate()
	for point: Vector3 in OWNER_ROUTE:
		owner_boss.route.append(to_global(point))
	owner_boss.printer = appraisal
	owner_boss.printer_spot = to_global(APPRAISAL_ON + Vector3(-0.5, 0, -0.4))
	owner_boss.fix_facing = to_global(APPRAISAL_ON + Vector3(1.0, 1.0, 1.0))
	add_child(owner_boss)
	owner_boss.start_at(0)
	appraisal.caught_on.connect(owner_boss.blame.bind(CAUGHT_ON, "REGATEO_CAUGHT_ON"))
	customer_complained.connect(func(_customer: PawnCustomer) -> void:
		owner_boss.blame(CUSTOMER_COMPLAINT, "REGATEO_CUSTOMER"))
	counter.taken.connect(func(_item: Grabbable) -> void: owner_boss.blame(TAKEN_COMPLAINT, "REGATEO_TAKEN"))
	stock_door.broken.connect(owner_boss.door_broken)
	owner_boss.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_PAWN"))
	till.opened.connect(func(at: Vector3) -> void: owner_boss.saw(at, FloorBoss.SAW_TILL))
	case_broken.connect(func(index: int) -> void:
		owner_boss.saw(to_global(CASES[index] + Vector3.UP), FloorBoss.SAW_BREAK, "REGATEO_CASE"))
	armor_fallen.connect(func() -> void:
		owner_boss.saw(to_global(ARMOR_AT + Vector3.UP), FloorBoss.SAW_BREAK, "REGATEO_ARMOR"))
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
	owner_boss.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## The 3 customers, each browsing in front of the shelves.
func _build_customers() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["pawn customers", case_seed])
	for i in CUSTOMER_HOMES.size():
		var customer := PawnCustomer.new()
		customer.name = "Customer%d" % (i + 1)
		customer.look = CUSTOMER_LOOKS[i]
		customer.shop = self
		customer.home = CUSTOMER_HOMES[i]
		customer.position = customer.home
		customer.rng.seed = rng.randi()
		add_child(customer)
		customer.complained.connect(customer_complained.emit)
		customer.turn_over.connect(func(_done: PawnCustomer) -> void:
			on_turn = null
			_turn_left = TURN_GAP)
		customers.append(customer)


## The way from `from` to the customers' spot at the counter (shop space): out to the aisle in front of the glass
## cases, along it east of them, up to the counter and in front of it.
func counter_path(from: Vector3) -> Array:
	return [Vector3(from.x, FLOOR_TOP, AISLE_Z), Vector3(AISLE_X, FLOOR_TOP, AISLE_Z),
		Vector3(AISLE_X, FLOOR_TOP, COUNTER_SPOT.z), COUNTER_SPOT]


## Whether a cop stands less than `reach` from `at` (shop space).
func cop_near(at: Vector3, reach: float) -> bool:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var here := to_local(cop.global_position)
		if Vector2(here.x - at.x, here.z - at.z).length() < reach:
			return true
	return false


## Whether `at` (shop space) is inside the shop's walls.
func is_inside(at: Vector3) -> bool:
	return absf(at.x) < HALF_X and absf(at.z) < HALF_Z


## Where the next pawned thing goes on show (shop space): on a glass case beside the shop's goods, then behind the
## counter once the cases are full.
func free_display_slot() -> Vector3:
	var index := _displayed
	_displayed += 1
	if index < CASES.size() * 2:
		var side := -0.6 if index % 2 == 0 else 0.6
		return CASES[index / 2] + Vector3(side, CASE_SIZE.y + 0.02, 0)
	return COUNTER_AT + Vector3(-2.0 + (index - CASES.size() * 2) * 0.5, 0, 1.2)


## What the case pay loses: what broke and what the cops paid the shop, less what the shop paid them.
func _physics_process(delta: float) -> void:
	raid.fines = maxi(0, fines + counter.spent - counter.cash_out)
	_next_turn(delta)


## Between turns the next customer in line goes to the counter.
func _next_turn(delta: float) -> void:
	if on_turn:
		return
	_turn_left -= delta
	if _turn_left > 0.0:
		return
	on_turn = customers[_next_customer % customers.size()]
	on_turn.start_turn()
	_next_customer += 1


## The stock room at the back: its wall with the locked door, the shelves, the pile of boxes, the safe and the desk.
func _build_stock() -> void:
	_build.wall_at("x", STOCK_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [STOCK_DOOR_X], STOCK)
	_label("PAWN_STOCK_SIGN", Vector3(STOCK_DOOR_X, GameScale.DOOR_HEIGHT + 0.4, STOCK_Z + 0.1), 40)
	for x: float in STOCK_SHELVES_X:
		var at := Vector3(x, FLOOR_TOP, STOCK_SHELF_Z)
		_solid(at + Vector3(0, 1.1, 0), Vector3(2.0, 2.2, 0.6))
		_model(STOCK_SHELF_MODEL, at)
	_solid(BOXES_AT + Vector3(0, 0.65, 0), Vector3(1.2, 1.3, 0.6))
	_model(BOXES_MODEL, BOXES_AT)
	_solid(SAFE_AT + Vector3(0, 0.6, 0), Vector3(0.9, 1.2, 0.8))
	_model(SAFE_MODEL, SAFE_AT)
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.04, DARK)
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.02, 0), Vector3(DESK_SIZE.x, 0.04, DESK_SIZE.z), WOOD)
	_build.mesh_box(DESK_AT + Vector3(0.2, DESK_SIZE.y + 0.03, 0), Vector3(0.5, 0.06, 0.35), Color(0.55, 0.15, 0.15))


## Something hit glass case `index` hard, once: a fine, no glass and its watches and rings on the floor.
func break_case(index: int) -> void:
	if cases_broken[index]:
		return
	cases_broken[index] = true
	fines += CASE_FINE
	var at := CASES[index]
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed + index
	for i in 8:
		var spot := Vector3(at.x + rng.randf_range(-1.0, 1.0), FLOOR_TOP + 0.01, at.z + rng.randf_range(-0.9, 0.9))
		_build.mesh_box(spot, Vector3(0.1, 0.02, 0.1), [Color(0.88, 0.69, 0.25), Color(0.78, 0.8, 0.82),
			Color(0.85, 0.22, 0.2)][i % 3])
	_build.mesh_box(at + Vector3(0, CASE_SIZE.y - 0.15, 0), Vector3(1.9, 0.02, 0.7), DARK)
	_say(at + Vector3(0, 2.0, 0), "PAWN_CASE_BROKEN")
	for customer in customers:
		customer.near_crash(to_global(at))
	case_broken.emit(index)


## Something hit the knight's armor hard, once: a fine and it falls apart in six pieces on the floor.
func knock_armor() -> void:
	if armor_down:
		return
	armor_down = true
	fines += ARMOR_FINE
	_armor.visible = false
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed
	for i in 6:
		var spot := Vector3(armor_at.x + rng.randf_range(0.0, 1.4), FLOOR_TOP + 0.08, armor_at.z + rng.randf_range(-0.8, 0.8))
		_build.mesh_box(spot, Vector3(0.3, 0.16, 0.25) if i > 0 else Vector3(0.3, 0.3, 0.3), STEEL)
	_say(armor_at + Vector3(1.0, 2.2, 0), "PAWN_ARMOR_FALLEN")
	for customer in customers:
		customer.near_crash(to_global(armor_at))
	armor_fallen.emit()


## The armor takes a step of `offset` (shop space), unless it already fell apart.
func move_armor(offset: Vector3) -> void:
	if armor_down:
		return
	armor_at += offset
	for part in armor_parts:
		part.position += offset


## The locked door in the stock room's wall, its middle at x.
func _door(x: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(x - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, STOCK_Z)
	add_child(door)
	return door


## A box only to bump into, under a model that gives the look.
func _solid(center: Vector3, size: Vector3) -> StaticBody3D:
	var body := _build.body(center)
	_build.shape(body, size)
	return body


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
func _say(at: Vector3, key: String, seconds := 3.0) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(seconds).timeout.connect(label.queue_free)


## A floating line over `at` (global) for a few seconds.
func say_at(at: Vector3, text: String) -> void:
	_say(to_local(at), text)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
