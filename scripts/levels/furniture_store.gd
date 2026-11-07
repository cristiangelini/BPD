class_name FurnitureStore
extends Node3D

## The furniture store "El Ropero Feliz" as a place to raid (docs/diseno/allanamiento-muebleria.md, step 1a): a shop
## on its lot in the city with the front to +Z, the glass door open because it's opening hours and the shop window on
## either side. Inside, three showroom setups (the living room at the front left, the bedroom at the back left and the
## dining room at the front right), the counter with the till and the stockroom at the back right, locked with the
## till's key. Something that hits a floor lamp or the mirror fast breaks it, a fine each. Every number here is
## (propuesta). Step 1b: the mattresses bounce whoever lands on them, the tower of chairs by the door comes down when
## pushed, and a wardrobe tips over when two cops pull it together. Step 2: Don Cajón walks among the setups filling the
## complaint, and comes to sell the sofa or the bed a cop tries out (E), his back to the shop, until the pitch ends or
## the cop gets up. Step 3: Tablita puts a bookcase together in the middle of the shop and tells whoever holds its
## shelf up for 5 s what he saw. The case is one of its stories (STORIES), drawn with the seed, run by the same RaidCase
## as the other places (step 4).

signal good_broken(index: int)
signal wardrobe_tipped(index: int)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const SOFA_MODEL := preload("res://assets/models/showroom_sofa.glb")
const BED_MODEL := preload("res://assets/models/showroom_bed.glb")
const WARDROBE_MODEL := preload("res://assets/models/showroom_wardrobe.glb")
const DRESSER_MODEL := preload("res://assets/models/showroom_dresser.glb")
const LAMP_MODEL := preload("res://assets/models/showroom_lamp.glb")
const MIRROR_MODEL := preload("res://assets/models/standing_mirror.glb")
const TABLE_MODEL := preload("res://assets/models/dining_table.glb")
const CHAIR_MODEL := preload("res://assets/models/dining_chair.glb")
const BOX_MODEL := preload("res://assets/models/flatpack_box.glb")
const CAJON_SCENE := preload("res://scenes/npc/don_cajon.tscn")
const BOOKCASE_MODEL := preload("res://assets/models/half_bookcase.glb")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the store can be suspected of (allanamiento-muebleria.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["stuffed_sofas", "cardboard_wood", "wardrobe_hotel", "fake_antiques", "comisario_chair",
	"endless_installments"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_FURNITURE_TIP_B", "BRIEF_TIP_C",
	"BRIEF_FURNITURE_TIP_D", "BRIEF_FURNITURE_TIP_E"]
## The stories the store can tell, like Garage.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist rows
## of its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras.
const STORIES := {
	"stuffed_sofas": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_STUFFED_SOFAS_B", "BRIEF_STUFFED_SOFAS_C", "BRIEF_STUFFED_SOFAS_D"],
		"find": "OBJ_FIND_MONEY_CUSHION",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/money_cushion.tscn"), preload("res://scenes/props/other_ledger.tscn"),
			preload("res://scenes/props/upholstery_needle.tscn")],
		"half_heights": [0.15, 0.025, 0.025],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_OTHER_LEDGER", "OBJ_EXTRA_NEEDLE"],
		"rig": preload("res://scripts/case/furniture/stuffed_sofas_rig.gd"),
	},
	"cardboard_wood": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_CARDBOARD_WOOD_B", "BRIEF_CARDBOARD_WOOD_C", "BRIEF_CARDBOARD_WOOD_D"],
		"find": "OBJ_FIND_WOOD_STAMP",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/wood_stamp.tscn"), preload("res://scenes/props/wood_decal_roll.tscn"),
			preload("res://scenes/props/cardboard_invoices.tscn")],
		"half_heights": [0.075, 0.08, 0.006],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_DECAL_ROLL", "OBJ_EXTRA_CARDBOARD_INVOICES"],
		"rig": preload("res://scripts/case/furniture/cardboard_wood_rig.gd"),
	},
	"wardrobe_hotel": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_WARDROBE_HOTEL_B", "BRIEF_WARDROBE_HOTEL_C", "BRIEF_WARDROBE_HOTEL_D"],
		"find": "OBJ_FIND_GUEST_BOOK",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/guest_book.tscn"), preload("res://scenes/props/drooly_pillow.tscn"),
			preload("res://scenes/props/toothbrush.tscn")],
		"half_heights": [0.015, 0.07, 0.015],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_DROOLY_PILLOW", "OBJ_EXTRA_TOOTHBRUSH"],
		"rig": preload("res://scripts/case/furniture/wardrobe_hotel_rig.gd"),
	},
	"fake_antiques": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FAKE_ANTIQUES_B", "BRIEF_FAKE_ANTIQUES_C", "BRIEF_FAKE_ANTIQUES_D"],
		"find": "OBJ_FIND_AGING_MACHINE",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/aging_machine.tscn"), preload("res://scenes/props/antique_labels.tscn"),
			preload("res://scenes/props/sawdust_bag.tscn")],
		"half_heights": [0.09, 0.025, 0.18],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_ANTIQUE_LABELS", "OBJ_EXTRA_SAWDUST"],
		"rig": preload("res://scripts/case/furniture/fake_antiques_rig.gd"),
	},
	"comisario_chair": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_COMISARIO_CHAIR_B", "BRIEF_COMISARIO_CHAIR_C", "BRIEF_COMISARIO_CHAIR_D"],
		"find": "OBJ_FIND_COMISARIO_CHAIR",
		"hidden": [preload("res://scenes/props/comisario_photo.tscn"),
			preload("res://scenes/props/station_screwdriver.tscn")],
		"half_heights": [0.01, 0.02],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_COMISARIO_PHOTO", "OBJ_EXTRA_STATION_SCREWDRIVER"],
		"rig": preload("res://scripts/case/furniture/comisario_chair_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the shop's floor, in the open between the setups.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-4.0, FLOOR_TOP, 9.0), Vector3(2.0, FLOOR_TOP, 5.0), Vector3(-3.5, FLOOR_TOP, -4.5),
	Vector3(1.5, FLOOR_TOP, -9.0), Vector3(5.5, FLOOR_TOP, 0.5), Vector3(-11.0, FLOOR_TOP, 0.5),
]
const HALF_X := 14.0
const HALF_Z := 12.0
## The shop's ceiling, and the closed roof over it up to the lot's height.
const WALL_TOP := 4.5
const BUILDING_TOP := 8.0
const FLOOR_TOP := 0.06
## The open doorway in the middle of the front, and the shop windows on either side of it.
const DOOR_HALF := 1.5
const WINDOW_FROM := 0.6
const WINDOW_TO := 3.2

## The pieces, each standing on the floor at `at` and turned `turn` around Y (its front to +Z before the turn).
const SOFAS := [{"at": Vector3(-8.5, FLOOR_TOP, 4.5), "turn": 0.0}, {"at": Vector3(-12.6, FLOOR_TOP, 8.0), "turn": PI / 2}]
const BEDS := [{"at": Vector3(-10.0, FLOOR_TOP, -10.9), "turn": 0.0}, {"at": Vector3(-5.5, FLOOR_TOP, -10.9), "turn": 0.0}]
const WARDROBES := [{"at": Vector3(-13.6, FLOOR_TOP, -6.5), "turn": PI / 2}, {"at": Vector3(-13.6, FLOOR_TOP, -3.0), "turn": PI / 2}]
const DRESSER_AT := Vector3(-2.8, FLOOR_TOP, -11.65)
const COFFEE_TABLE_AT := Vector3(-8.5, FLOOR_TOP, 7.0)
const COFFEE_TABLE_SIZE := Vector3(1.0, 0.4, 0.6)
const TABLE_AT := Vector3(7.5, FLOOR_TOP, 6.0)
const CHAIR_XS: Array[float] = [6.75, 7.5, 8.25]
const CHAIR_ZS: Array[float] = [5.3, 6.7]
## A dining chair's seat and back, [center, size] in its own space.
const CHAIR_SHAPES := [[Vector3(0, 0.245, 0), Vector3(0.45, 0.49, 0.45)], [Vector3(0, 0.7, -0.2), Vector3(0.45, 0.42, 0.05)]]
## The tower of stacked chairs, in the open by the door so they have room to fall.
const TOWER_AT := Vector3(2.5, FLOOR_TOP, 8.5)
## A cop landing on a mattress faster than BOUNCE_FROM goes back up BOUNCE_GAIN times as fast, up to BOUNCE_HEIGHT
## over it. Props bounce off it too.
const BOUNCE_FROM := 2.0
const BOUNCE_GAIN := 1.2
const BOUNCE_HEIGHT := 1.5
const MATTRESS_BOUNCE := 0.6
## The fragile goods: the living room's lamp, the bedroom's lamp and the big mirror.
const GOODS := [
	{"kind": "lamp", "at": Vector3(-12.8, FLOOR_TOP, 4.2)},
	{"kind": "lamp", "at": Vector3(-7.75, FLOOR_TOP, -11.5)},
	{"kind": "mirror", "at": Vector3(-2.6, FLOOR_TOP, -8.5)},
]
const GOOD_SPEED := 3.0
const GOOD_FINE := 25
## The counter in the middle of the right side, with the till; the salesman's side is -Z.
const COUNTER_AT := Vector3(9.0, FLOOR_TOP, 0.5)
const COUNTER_SIZE := Vector3(3.0, 1.0, 0.8)
const TILL_ON := Vector3(9.8, FLOOR_TOP + 1.0, 0.5)
## The stockroom in the back right corner, its locked door and its stacks of flat-pack boxes.
const STOCK_X := 4.0
const STOCK_Z := -4.0
const STOCK_DOOR_X := 9.0
const BOX_STACKS: Array[Vector3] = [Vector3(7.8, FLOOR_TOP, -10.8), Vector3(12.2, FLOOR_TOP, -10.8), Vector3(12.6, FLOOR_TOP, -6.5)]
const BOXES_PER_STACK := 5
const BOX_SIZE := Vector3(1.2, 0.15, 0.6)

## Don Cajón's round among the setups, back and forth: the living room, the bedroom, the middle and the dining room.
const CAJON_ROUTE: Array[Vector3] = [
	Vector3(-6.0, FLOOR_TOP, 9.5), Vector3(-5.5, FLOOR_TOP, 2.0), Vector3(-6.0, FLOOR_TOP, -6.5),
	Vector3(1.0, FLOOR_TOP, -6.0), Vector3(1.5, FLOOR_TOP, 2.5), Vector3(5.0, FLOOR_TOP, 3.0),
]
## What he sees: a lamp or the mirror broken, a wardrobe tipped or the tower of chairs down; and trying a piece once
## he knows the trick.
const SAW_GOOD := 10.0
const SAW_TIPPED := 5.0
const SAW_TOWER := 5.0
const NOTICED := 10.0
## A cop on a piece being sold who gets this far from it cuts the pitch short.
const LEAVE_DISTANCE := 1.2

## Tablita in the middle of the shop with the bookcase he's putting together, its front to the door.
const BOOKCASE_AT := Vector3(-1.5, FLOOR_TOP, -1.0)
const TABLITA_AT := Vector3(-2.6, FLOOR_TOP, -0.6)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_wardrobe_0", "at": Vector3(-13.65, FLOOR_TOP + 0.1, -6.5), "heavy": true},
	{"id": "in_wardrobe_1", "at": Vector3(-13.65, FLOOR_TOP + 0.1, -3.0), "heavy": true},
	{"id": "behind_showroom_sofa", "at": Vector3(-8.5, FLOOR_TOP, 3.5), "heavy": true},
	{"id": "behind_furniture_counter", "at": Vector3(9.0, FLOOR_TOP, -0.4), "heavy": true},
	{"id": "in_stockroom_corner", "at": Vector3(5.0, FLOOR_TOP, -11.0), "heavy": true},
	{"id": "between_flatpack_boxes", "at": Vector3(10.0, FLOOR_TOP, -10.8), "heavy": true},
	{"id": "under_bed_0", "at": Vector3(-10.0, FLOOR_TOP, -10.6), "heavy": false},
	{"id": "under_bed_1", "at": Vector3(-5.5, FLOOR_TOP, -10.6), "heavy": false},
	{"id": "in_sofa_cushions_0", "at": Vector3(-8.5, FLOOR_TOP + 0.52, 4.3), "heavy": false},
	{"id": "in_sofa_cushions_1", "at": Vector3(-12.4, FLOOR_TOP + 0.52, 8.0), "heavy": false},
	{"id": "on_dresser", "at": Vector3(-2.8, FLOOR_TOP + 0.93, -11.65), "heavy": false},
	{"id": "in_furniture_counter", "at": Vector3(9.0, FLOOR_TOP + 0.05, 0.5), "heavy": false},
]

const OUTSIDE := Color(0.93, 0.86, 0.72)
const PARQUET := Color(0.68, 0.5, 0.34)
const RUG := Color(0.72, 0.3, 0.3)
const STOCK_FLOOR := Color(0.6, 0.58, 0.55)
const GREEN := Color(0.3, 0.55, 0.4)
const DARK := Color(0.1, 0.1, 0.12)
const GLASS := Color(0.75, 0.88, 0.95, 0.25)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var stock_door: FrontDoor
var till: Till
## The pieces, in the order of SOFAS, BEDS and WARDROBES, and the fragile goods in the order of GOODS.
var sofas: Array[ShowroomSeat] = []
var beds: Array[ShowroomSeat] = []
var cajon: FloorBoss
var pitch: SalesPitch
var tablita: FurnitureAssembler
var shelf: BookcaseShelf
var complaint_bar: ProgressBar
var wardrobes: Array[TippingWardrobe] = []
## The dining room's six chairs (a story can swap them for light ones).
var chairs: Array[StaticBody3D] = []
var chair_tower: ChairTower
var goods: Array[StaticBody3D] = []
var broken: Array[int] = []
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the lamps and the mirror.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## Same seed, same store, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: FurnitureRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var _build: PlaceBuilder
## Each cop's falling speed in the frame before it touched down (by instance id).
var _falling := {}
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
	_build_living()
	_build_bedroom()
	_build_dining()
	chair_tower = ChairTower.new()
	chair_tower.position = TOWER_AT
	add_child(chair_tower)
	_build_counter()
	_build_stockroom()
	_place_goods()
	_place_cajon()
	_place_tablita()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("furniture")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "furniture", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = cajon
	raid.owner_id = "furniture"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The store's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_FURNITURE",
		"guess_key": "OBJ_GUESS_FURNITURE",
		"broken_key": "OBJ_BROKEN_FURNITURE",
		"complaint_key": "OBJ_COMPLAINT_FURNITURE",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": cajon.complaint,
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


## What Don Cajón lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Tablita saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		cajon.slips.append(tr("CAJON_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	cajon.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	tablita.clue = tr("CLUE_TABLITA") % where
	tablita.clue_speech = tr("TABLITA_CLUE_" + story_id) % where
	tablita.told.connect(raid.add_clue)


## The parquet, the walls with the doorway and the two shop windows, the roof and the signs.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, PARQUET)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, OUTSIDE.darkened(0.1))
	for side: float in [-1.0, 1.0]:
		var a := side * DOOR_HALF
		var b := side * HALF_X
		_build.wall_at("x", HALF_Z, minf(a, b), maxf(a, b), 0.0, WINDOW_FROM, [], OUTSIDE)
		_build.wall_at("x", HALF_Z, minf(a, b), maxf(a, b), WINDOW_TO, WALL_TOP - WINDOW_TO, [], OUTSIDE)
		_glass(Vector3(side * (DOOR_HALF + HALF_X) / 2, (WINDOW_FROM + WINDOW_TO) / 2, HALF_Z),
			Vector3(HALF_X - DOOR_HALF, WINDOW_TO - WINDOW_FROM, 0.06))
	_build.wall_at("x", HALF_Z, -DOOR_HALF, DOOR_HALF, WINDOW_TO, WALL_TOP - WINDOW_TO, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_label("PLACE_FURNITURE", Vector3(0, WALL_TOP + 0.9, HALF_Z + 0.08), 110)
	_label("FURNITURE_WINDOW_SIGN", Vector3(-7.75, WINDOW_TO - 0.4, HALF_Z + 0.06), 64)
	_label("FURNITURE_WINDOW_SIGN", Vector3(7.75, WINDOW_TO - 0.4, HALF_Z + 0.06), 64)
	for x: float in [-9.0, 0.0, 9.0]:
		for z: float in [-8.0, 0.0, 8.0]:
			_build.light(Vector3(x, WALL_TOP - 0.4, z if x < STOCK_X or z > STOCK_Z else -8.0))


## The living room: the two sofas on the rug, the coffee table between them.
func _build_living() -> void:
	_build.mesh_box(Vector3(-9.5, FLOOR_TOP + 0.005, 6.5), Vector3(5.0, 0.01, 4.0), RUG)
	for spec: Dictionary in SOFAS:
		sofas.append(_piece(SOFA_MODEL, spec.at, spec.turn, [
			[Vector3(0, 0.26, 0.05), Vector3(2.1, 0.52, 0.8)],
			[Vector3(0, 0.42, -0.35), Vector3(2.1, 0.84, 0.2)],
		], ShowroomSeat.new()))
	_build.legs(COFFEE_TABLE_AT, Vector2(COFFEE_TABLE_SIZE.x, COFFEE_TABLE_SIZE.z), COFFEE_TABLE_SIZE.y - 0.04, DARK)
	_build.box(COFFEE_TABLE_AT + Vector3(0, COFFEE_TABLE_SIZE.y - 0.02, 0),
		Vector3(COFFEE_TABLE_SIZE.x, 0.04, COFFEE_TABLE_SIZE.z), PARQUET.darkened(0.3))


## The bedroom: two beds with room underneath, the two wardrobes open on the west wall and the chest of drawers.
func _build_bedroom() -> void:
	_build.mesh_box(Vector3(-7.75, FLOOR_TOP + 0.005, -8.5), Vector3(8.0, 0.01, 4.0), RUG.lightened(0.4))
	var springy := PhysicsMaterial.new()
	springy.bounce = MATTRESS_BOUNCE
	for spec: Dictionary in BEDS:
		var bed := ShowroomSeat.new()
		bed.kind = "bed"
		_piece(BED_MODEL, spec.at, spec.turn, [
			[Vector3(0, 0.46, 0), Vector3(1.5, 0.32, 2.0)],
			[Vector3(0, 0.75, -1.0), Vector3(1.56, 0.7, 0.08)],
		], bed)
		bed.physics_material_override = springy
		beds.append(bed)
	for i in WARDROBES.size():
		var spec: Dictionary = WARDROBES[i]
		var wardrobe := TippingWardrobe.new()
		wardrobe.name = "Wardrobe%d" % i
		wardrobe.tipped.connect(func() -> void: wardrobe_tipped.emit(i))
		wardrobes.append(_piece(WARDROBE_MODEL, spec.at, spec.turn, [
			[Vector3(0, 1.0, -0.28), Vector3(1.2, 2.0, 0.04)],
			[Vector3(-0.58, 1.0, 0), Vector3(0.04, 2.0, 0.6)],
			[Vector3(0.58, 1.0, 0), Vector3(0.04, 2.0, 0.6)],
			[Vector3(0, 0.05, 0), Vector3(1.2, 0.1, 0.6)],
			[Vector3(0, 1.97, 0), Vector3(1.3, 0.12, 0.66)],
		], wardrobe))
	_piece(DRESSER_MODEL, DRESSER_AT, 0.0, [[Vector3(0, 0.465, 0), Vector3(1.04, 0.93, 0.54)]])


## The dining room: the long table with its six chairs.
func _build_dining() -> void:
	_build.mesh_box(TABLE_AT + Vector3(0, 0.005, 0), Vector3(4.4, 0.01, 3.4), GREEN.lightened(0.3))
	_piece(TABLE_MODEL, TABLE_AT, 0.0, [[Vector3(0, 0.38, 0), Vector3(2.4, 0.76, 1.0)]])
	for z: float in CHAIR_ZS:
		for x: float in CHAIR_XS:
			chairs.append(_piece(CHAIR_MODEL, Vector3(x, FLOOR_TOP, z), 0.0 if z < TABLE_AT.z else PI, CHAIR_SHAPES))


## The counter with the till, open on the salesman's side.
func _build_counter() -> void:
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", GREEN)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_FURNITURE"
	add_child(till)


## The stockroom: its walls with the locked door, a concrete floor and the stacks of flat-pack boxes.
func _build_stockroom() -> void:
	_build.mesh_box(Vector3((STOCK_X + HALF_X) / 2, FLOOR_TOP + 0.005, (STOCK_Z - HALF_Z) / 2),
		Vector3(HALF_X - STOCK_X, 0.01, HALF_Z + STOCK_Z), STOCK_FLOOR)
	_build.wall_at("x", STOCK_Z, STOCK_X, HALF_X, 0.0, WALL_TOP, [STOCK_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("z", STOCK_X, -HALF_Z, STOCK_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	for at: Vector3 in BOX_STACKS:
		var tall := BOX_SIZE.y * BOXES_PER_STACK
		_build.shape(_build.body(at + Vector3(0, tall / 2, 0)), Vector3(BOX_SIZE.x, tall, BOX_SIZE.z))
		for i in BOXES_PER_STACK:
			_model(BOX_MODEL, at + Vector3(0, BOX_SIZE.y * i, 0), (i % 2) * 0.08)
	stock_door = DOOR_SCENE.instantiate()
	stock_door.position = Vector3(STOCK_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, STOCK_Z)
	add_child(stock_door)


## The lamps and the mirror: a slim body each, and an area around it that breaks it when something flies in fast.
func _place_goods() -> void:
	for i in GOODS.size():
		var spec: Dictionary = GOODS[i]
		var lamp: bool = spec.kind == "lamp"
		var size := Vector3(0.4, 1.7, 0.4) if lamp else Vector3(0.8, 1.9, 0.12)
		var body := _piece(LAMP_MODEL if lamp else MIRROR_MODEL, spec.at, 0.0, [[Vector3(0, size.y / 2, 0), size]])
		body.name = "Good%d" % i
		goods.append(body)
		var area := Area3D.new()
		area.position = Vector3(0, size.y / 2, 0)
		area.collision_layer = 0
		area.collision_mask = 4
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size + Vector3(0.3, 0.1, 0.3)
		shape.shape = box
		area.add_child(shape)
		body.add_child(area)
		area.body_entered.connect(func(hit: Node3D) -> void:
			if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > GOOD_SPEED:
				break_good(i))


## Don Cajón on his round, the pitch that brings him to a cop trying a piece, what he notices and the complaint bar.
func _place_cajon() -> void:
	pitch = SalesPitch.new()
	add_child(pitch)
	cajon = CAJON_SCENE.instantiate()
	cajon.route = CAJON_ROUTE
	cajon.printer = pitch
	add_child(cajon)
	cajon.start_at(0)
	for seat: ShowroomSeat in sofas + beds:
		seat.tried.connect(func(cop: Cop) -> void: try_out(seat, cop))
	stock_door.broken.connect(cajon.door_broken)
	cajon.lawyer_called.connect(func() -> void: raid.fail("CASE_FAILED_LAWYER_FURNITURE"))
	till.opened.connect(func(at: Vector3) -> void: cajon.saw(at, FloorBoss.SAW_TILL))
	good_broken.connect(func(index: int) -> void:
		cajon.saw(to_global(goods[index].position + Vector3.UP), SAW_GOOD, "CAJON_GOOD"))
	wardrobe_tipped.connect(func(index: int) -> void:
		cajon.saw(wardrobes[index].global_position + Vector3.UP, SAW_TIPPED, "CAJON_TIPPED"))
	chair_tower.fell.connect(func() -> void:
		cajon.saw(chair_tower.global_position + Vector3.UP, SAW_TOWER, "CAJON_TOWER"))
	pitch.noticed.connect(func() -> void: cajon.scold(NOTICED, "CAJON_NOTICED"))
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
	cajon.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Tablita and his bookcase: whoever holds its shelf up long enough hears what he saw.
func _place_tablita() -> void:
	var bookcase := _piece(BOOKCASE_MODEL, BOOKCASE_AT, 0.0, [
		[Vector3(-0.435, 0.9, 0), Vector3(0.03, 1.8, 0.35)], [Vector3(0.435, 0.9, 0), Vector3(0.03, 1.8, 0.35)],
		[Vector3(0, 0.9, -0.17), Vector3(0.9, 1.8, 0.02)], [Vector3(0, 1.785, 0), Vector3(0.9, 0.03, 0.35)],
	])
	bookcase.name = "Bookcase"
	shelf = BookcaseShelf.new()
	shelf.name = "Shelf"
	bookcase.add_child(shelf)
	tablita = FurnitureAssembler.new()
	tablita.name = "Tablita"
	tablita.position = TABLITA_AT
	tablita.rotation.y = 0.5
	add_child(tablita)
	shelf.taken.connect(tablita.holding)
	shelf.held.connect(tablita.held_by)
	shelf.dropped.connect(func(_cop: Cop) -> void: tablita.dropped())


## A cop tries `seat` out: Don Cajón comes to stand in front of it and sell it, facing it (or notices the trick).
func try_out(seat: ShowroomSeat, cop: Cop) -> void:
	if not pitch.can_offer(cop):
		return
	cajon.printer_spot = to_local(seat.to_global(seat.pitch_point()))
	cajon.fix_facing = seat.global_position
	pitch.offer(seat, cop)


## The cop on the piece being sold got up and walked off: he stops and goes back to his round.
func _check_pitch() -> void:
	if not pitch.is_jammed or not is_instance_valid(pitch.buyer):
		return
	var seat := pitch.seat
	if pitch.buyer.global_position.distance_to(seat.to_global(seat.sit_point())) > LEAVE_DISTANCE:
		cajon.interrupt()
		cajon.scold(0.0, "CAJON_CUT")
		pitch.fix()


func _physics_process(_delta: float) -> void:
	_check_pitch()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var id := cop.get_instance_id()
		if not cop.is_on_floor():
			_falling[id] = cop.velocity.y
			continue
		var fall: float = _falling.get(id, 0.0)
		_falling[id] = 0.0
		if -fall > BOUNCE_FROM and _on_a_mattress(cop):
			cop.velocity.y = minf(-fall * BOUNCE_GAIN, sqrt(2.0 * GameScale.GRAVITY * BOUNCE_HEIGHT))


## Whether the cop stands on top of a bed's mattress.
func _on_a_mattress(cop: Cop) -> bool:
	for i in cop.get_slide_collision_count():
		var hit := cop.get_slide_collision(i)
		# Checked by type first: a typed array refuses to look for the floor or a wall.
		var bed := hit.get_collider() as ShowroomSeat
		if hit.get_normal().y > 0.7 and bed and beds.has(bed):
			return true
	return false


## Breaks good `index`, once: a fine, and the lamp lies on the floor dark or the mirror shows its cracks.
func break_good(index: int) -> void:
	if broken.has(index):
		return
	broken.append(index)
	broken_goods += 1
	fines += GOOD_FINE
	var body := goods[index]
	raid.float_label("-%d" % GOOD_FINE, body.global_position + Vector3.UP * 2.0, Color(1, 0.3, 0.25))
	if GOODS[index].kind == "lamp":
		body.rotation.x = PI / 2
		body.position.y = FLOOR_TOP + 0.2
	else:
		for i in 6:
			var turn := i * TAU / 6.0 + 0.4
			var crack := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = Vector3(0.35 + (i % 3) * 0.12, 0.015, 0.015)
			crack.mesh = mesh
			crack.material_override = _build.material(DARK)
			crack.position = Vector3(cos(turn) * 0.15, 1.1 + sin(turn) * 0.25, 0.04)
			crack.rotation.z = turn
			body.add_child(crack)
	_say(body.position + Vector3(0, 2.2, 0), "FURNITURE_GOOD_BROKEN")
	good_broken.emit(index)


## A piece of furniture: a body (a new one, or `body`) at `at` turned `turn`, with its model and one box shape per
## [center, size].
func _piece(scene: PackedScene, at: Vector3, turn: float, shapes: Array, body: StaticBody3D = null) -> StaticBody3D:
	if body == null:
		body = StaticBody3D.new()
	body.position = at
	body.rotation.y = turn
	for spec: Array in shapes:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = spec[1]
		shape.shape = box
		shape.position = spec[0]
		body.add_child(shape)
	body.add_child(scene.instantiate())
	add_child(body)
	return body


## The shop window's pane: see-through, but solid.
func _glass(center: Vector3, size: Vector3) -> void:
	_build.shape(_build.body(center), size)
	var pane := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	pane.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = GLASS
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pane.material_override = material
	pane.position = center
	$Built.add_child(pane)


func _label(key: String, at: Vector3, size: int) -> void:
	var sign_label := Label3D.new()
	sign_label.text = key
	sign_label.font_size = size
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.position = at
	$Built.add_child(sign_label)


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
