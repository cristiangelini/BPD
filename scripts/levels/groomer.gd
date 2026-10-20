class_name Groomer
extends Node3D

## The pet salon "Pelito Feliz" (docs/diseno/peluqueria.md, step 1): the reception and the grooming room at the front,
## the cages and the storeroom behind them, and the yard at the back, on its lot in the city with the front to +Z.
## The salon is open; the storeroom ("Solo personal") and its back door to the yard are locked. The shampoo bottles
## and the collar vitrine break, each one a fine. Ramiro cuts dogs at the first table, watches what breaks and tells a
## dog's life to whoever sits in the waiting armchair with one (step 2). Six dogs roam the salon and the yard, follow
## whoever has something in hand and hide small things in the doghouse (step 3). The poodle lady waits in the
## reception for Fifí, caged in the back, and tells what she saw when she gets her (step 4). The case is one of its
## stories (STORIES), drawn with the seed, run by the same RaidCase as the other places (step 5).
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const SHAMPOO_SCENE := preload("res://scenes/props/shampoo_bottle.tscn")
const COLLAR_SCENE := preload("res://scenes/props/dog_collar.tscn")
const GROOMER_SCENE := preload("res://scenes/npc/dog_groomer.tscn")
const DOG_SCENE := preload("res://scenes/npc/dog.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the salon can be suspected of (peluqueria.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["millionaire", "hair_growth", "contest", "bones", "diamonds", "human_salon"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_GROOMER_TIP_B", "BRIEF_TIP_C", "BRIEF_GROOMER_TIP_D",
	"BRIEF_GROOMER_TIP_E"]
## The stories the salon can tell, like Bakery.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist rows
## of its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest are extras.
const STORIES := {
	"contest": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_CONTEST_B", "BRIEF_CONTEST_C", "BRIEF_CONTEST_D"],
		"find": "OBJ_FIND_CONTEST",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/dog_trophy.tscn"), preload("res://scenes/props/judge_cards.tscn"),
			preload("res://scenes/props/golden_comb.tscn")],
		"half_heights": [0.195, 0.015, 0.008],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_JUDGE_CARDS", "OBJ_EXTRA_GOLDEN_COMB"],
		"rig": preload("res://scripts/case/groomer/contest_rig.gd"),
	},
	"diamonds": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_DIAMONDS_B", "BRIEF_DIAMONDS_C", "BRIEF_DIAMONDS_D"],
		"find": "OBJ_FIND_DIAMONDS",
		"hidden": [preload("res://scenes/props/necklace_case.tscn")],
		"half_heights": [0.03],
		"heavy": [false],
		"extra_keys": ["OBJ_EXTRA_NECKLACE_CASE"],
		"rig": preload("res://scripts/case/groomer/diamonds_rig.gd"),
	},
	"millionaire": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_MILLIONAIRE_B", "BRIEF_MILLIONAIRE_C", "BRIEF_MILLIONAIRE_D"],
		"find": "OBJ_FIND_MILLIONAIRE",
		"hidden": [preload("res://scenes/props/dog_dye.tscn"), preload("res://scenes/props/ransom_letter.tscn")],
		"half_heights": [0.1, 0.005],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_DYE", "OBJ_EXTRA_RANSOM_LETTER"],
		"rig": preload("res://scripts/case/groomer/millionaire_rig.gd"),
	},
	"hair_growth": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_HAIR_GROWTH_B", "BRIEF_HAIR_GROWTH_C", "BRIEF_HAIR_GROWTH_D"],
		"find": "OBJ_FIND_HAIR_GROWTH",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/shampoo_jug.tscn"), preload("res://scenes/props/formula_sheet.tscn"),
			preload("res://scenes/props/sample_jar.tscn")],
		"half_heights": [0.23, 0.003, 0.05],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_FORMULA", "OBJ_EXTRA_SAMPLE_JAR"],
		"rig": preload("res://scripts/case/groomer/hair_growth_rig.gd"),
	},
	"bones": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_BONES_B", "BRIEF_BONES_C", "BRIEF_BONES_D"],
		"find": "OBJ_FIND_BONES",
		"hidden": [preload("res://scenes/props/dig_map.tscn")],
		"half_heights": [0.003],
		"heavy": [false],
		"extra_keys": ["OBJ_EXTRA_DIG_MAP"],
		"rig": preload("res://scripts/case/groomer/bones_rig.gd"),
	},
	"human_salon": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_HUMAN_SALON_B", "BRIEF_HUMAN_SALON_C", "BRIEF_HUMAN_SALON_D"],
		"find": "OBJ_FIND_HUMAN_SALON",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/appointment_book.tscn"), preload("res://scenes/props/wig.tscn"),
			preload("res://scenes/props/salon_mirror.tscn")],
		"half_heights": [0.025, 0.07, 0.02],
		"heavy": [false, false, true],
		"extra_keys": ["OBJ_EXTRA_WIG", "OBJ_EXTRA_MIRROR"],
		"rig": preload("res://scripts/case/groomer/human_salon_rig.gd"),
	},
}
## Surfaces where the suspicions' clue notes can lie, one in each room; three are drawn with the seed.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-2.4, FLOOR_TOP + 1.0, 4.0), Vector3(-5.5, FLOOR_TOP, 5.0), Vector3(2.5, FLOOR_TOP + 0.86, 4.5),
	Vector3(-3.0, FLOOR_TOP, 0.5), Vector3(5.0, FLOOR_TOP, 0.8), Vector3(-4.0, GRASS_TOP, -5.0),
]
const LADY_AT := Vector3(-5.2, FLOOR_TOP, 6.3)
## Fifí's cage: lower row, third from the west wall (one with bars).
const POODLE_CAGE := Vector2i(2, 0)
const HALF_X := 8.0
## The lot runs from -HALF_Z to HALF_Z; the building covers its front from BACK_Z on, the yard the rest.
const HALF_Z := 7.0
const BACK_Z := -2.0
## The salon floor sits a little over the city's paved block, which runs under it; the yard's grass a little lower.
const FLOOR_TOP := 0.06
const GRASS_TOP := 0.04
## The wall between the front rooms and the back ones, the one between the reception (west) and the grooming room,
## and the one between the cages (west) and the storeroom.
const SPLIT_Z := 2.5
const RECEPTION_EAST := 0.0
const CAGES_EAST := 2.0
const ENTRANCE_X := -4.0
const GROOMING_DOOR_Z := 4.8
const CAGES_DOOR_X := -4.0
const STORE_DOOR_X := 5.0
const YARD_DOOR_X := -3.0
const BACK_DOOR_X := 5.0
const FENCE_HEIGHT := 0.9
const COUNTER_AT := Vector3(-2.2, FLOOR_TOP, 4.2)
const COUNTER_SIZE := Vector3(2.4, 1.0, 0.7)
const ARMCHAIR_AT := Vector3(-6.8, FLOOR_TOP, 5.8)
const VITRINE_AT := Vector3(-7.4, FLOOR_TOP, 3.8)
const VITRINE_SHELF := FLOOR_TOP + 0.77
const TABLES: Array[Vector3] = [Vector3(2.5, FLOOR_TOP, 4.5), Vector3(5.0, FLOOR_TOP, 4.5)]
const TABLE_HEIGHT := 0.8
## Where Ramiro stands to cut, behind the first table, facing the street.
const RAMIRO_POST := Vector3(2.5, FLOOR_TOP, 3.7)
## Each standing dryer's hood, open on top, behind its table.
const DRYER_HOOD := FLOOR_TOP + 1.4
const DRYER_Z := 5.6
const BATHTUB_AT := Vector3(6.8, FLOOR_TOP, 3.3)
const CAGE_XS: Array[float] = [-7.4, -6.5, -5.6, -4.7]
const CAGE_Z := -1.4
const CAGE_SIZE := Vector3(0.8, 0.8, 0.9)
const CAGE_STEP := 0.85
## The cages without bars (the dogs in them roam the salon, docs/diseno/peluqueria.md "Los perros").
const OPEN_CAGES: Array[Vector2i] = [Vector2i(1, 0), Vector2i(3, 1)]
## Where the loose dogs start, and the floor where they roam: reception, grooming room, cages and yard (not the
## storeroom, which is locked).
const DOGS_AT: Array[Vector3] = [
	Vector3(-5.0, FLOOR_TOP, 5.0), Vector3(-1.0, FLOOR_TOP, 6.0), Vector3(4.0, FLOOR_TOP, 6.2),
	Vector3(-6.0, FLOOR_TOP, 0.5), Vector3(-1.0, FLOOR_TOP, 1.0), Vector3(1.0, GRASS_TOP, -4.5),
]
const DOG_AREAS: Array[Rect2] = [
	Rect2(-7.4, 3.0, 6.8, 3.5), Rect2(0.6, 3.0, 6.8, 3.5), Rect2(-7.4, -0.6, 8.8, 2.6), Rect2(-7.4, -6.4, 14.8, 3.8),
]
const FREEZER_AT := Vector3(7.1, FLOOR_TOP, 0.3)
const TOWELS_AT := Vector3(3.0, FLOOR_TOP, 1.8)
const DOGHOUSE_AT := Vector3(5.5, GRASS_TOP, -5.2)
## The shampoo shelves: board center, length along the wall, the axis it runs along, and how many bottles each holds.
const SHELVES := [
	{"at": Vector3(-5.9, 0.9, 2.8), "length": 1.8, "along": "x", "bottles": 5},
	{"at": Vector3(-5.9, 1.5, 2.8), "length": 1.8, "along": "x", "bottles": 5},
	{"at": Vector3(7.7, 0.9, 5.7), "length": 2.2, "along": "z", "bottles": 7},
	{"at": Vector3(7.7, 1.5, 5.7), "length": 2.2, "along": "z", "bottles": 7},
]
const SHELF_DEPTH := 0.4
const COLLARS := 6
const BOTTLE_HALF_HEIGHT := 0.115
const COLLAR_HALF_HEIGHT := 0.075

const OUTSIDE := Color(0.55, 0.85, 0.8)
const INSIDE := Color(0.98, 0.9, 0.93)
const BACK := Color(0.85, 0.87, 0.85)
const TILES := Color(0.82, 0.86, 0.88)
const GRASS := Color(0.42, 0.66, 0.32)
const WOOD := Color(0.6, 0.42, 0.28)
const WHITE := Color(0.93, 0.93, 0.9)
const STEEL := Color(0.62, 0.64, 0.68)
const GLASS := Color(0.55, 0.75, 0.85, 0.35)
const PINK := Color(0.93, 0.55, 0.7)
const SACK := Color(0.78, 0.66, 0.42)
const CARDBOARD := Color(0.7, 0.55, 0.36)
const AWNING := Color(0.3, 0.65, 0.62)
const FRAME := Color(0.95, 0.8, 0.35)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_bathtub", "at": BATHTUB_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "in_cage", "at": Vector3(-6.5, FLOOR_TOP + 0.05, CAGE_Z), "heavy": false},
	{"id": "in_doghouse", "at": DOGHOUSE_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "in_freezer", "at": FREEZER_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "behind_food", "at": Vector3(3.7, FLOOR_TOP, -1.6), "heavy": true},
	{"id": "in_dryer", "at": Vector3(2.5, DRYER_HOOD + 0.05, DRYER_Z), "heavy": false},
	{"id": "under_armchair", "at": ARMCHAIR_AT, "heavy": false},
	{"id": "in_towels", "at": TOWELS_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "under_counter", "at": COUNTER_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "on_cages", "at": Vector3(-5.6, FLOOR_TOP + CAGE_STEP + 0.8, CAGE_Z), "heavy": false},
	{"id": "under_grooming_table", "at": Vector3(2.5, FLOOR_TOP, 4.5), "heavy": true},
	{"id": "in_vitrine", "at": VITRINE_AT + Vector3(0, 0.05, 0), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
## The case flow every raid shares.
var raid: RaidCase
## Same seed, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: GroomerRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var broken_goods := 0
var complaint_bar: ProgressBar
var store_door: FrontDoor
var back_door: FrontDoor
var city_map: CityMap
var shampoos: Array[Ornament] = []
var collars: Array[Ornament] = []
## Fines for what the cops broke (each one is an Ornament.FINE).
var fines: int:
	get: return raid.fines
var ramiro: DogGroomer
var armchair: WaitingArmchair
var dogs: Array[Dog] = []
var lady: PoodleLady
var poodle: Dog
## The look-only dogs behind bars, by cage (column, row).
var caged_looks: Dictionary = {}
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
	add_child(raid)
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_yard()
	_build_reception()
	_build_grooming_room()
	_build_cages()
	_build_storeroom()
	_place_fragile()
	store_door = _door(Vector3(STORE_DOOR_X - GameScale.DOOR_WIDTH / 2, 0, SPLIT_Z), 0.0)
	back_door = _door(Vector3(BACK_DOOR_X + GameScale.DOOR_WIDTH / 2, 0, BACK_Z), PI)
	_place_ramiro()
	_bake_navigation()
	_place_dogs()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("pet_salon")
	station_parking = city.transform * CityLayout.parking("station")
	raid.station_parking = station_parking
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "pet_salon", car)
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = ramiro
	raid.owner_id = "groomer"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The salon's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_GROOMER",
		"guess_key": "OBJ_GUESS_GROOMER",
		"broken_key": "OBJ_BROKEN_GROOMER",
		"complaint_key": "OBJ_COMPLAINT_GROOMER",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": ramiro.complaint,
	}


## The story with that id from --story=<id> among the user args, or one drawn from the seed.
static func pick_story(case_seed: int, args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with("--story=") and STORIES.has(arg.trim_prefix("--story=")):
			return arg.trim_prefix("--story=")
	return STORIES.keys()[case_seed % STORIES.size()]


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


## What Ramiro lets slip when asked (where the story's things are, in an order drawn from the seed), and what the
## poodle lady saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		ramiro.slips.append(tr("GROOMER_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	ramiro.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	lady.clue = tr("CLUE_LADY") % where
	lady.clue_speech = tr("LADY_CLUE_" + story_id) % where
	lady.told.connect(raid.add_clue)


func _door(at: Vector3, turn: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = at
	door.rotation.y = turn
	add_child(door)
	return door


## Floor, outer walls, the roof and the front: the entrance, the shop window, the awning and the sign.
func _build_shell() -> void:
	var up := GameScale.FLOOR_HEIGHT
	_build.slab(-HALF_X, HALF_X, BACK_Z, HALF_Z, FLOOR_TOP, TILES)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, BACK_Z - 0.2, HALF_Z + 0.2, up, OUTSIDE.darkened(0.35))
	_build.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [YARD_DOOR_X, BACK_DOOR_X], OUTSIDE)
	_build.wall("z", -HALF_X, BACK_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, BACK_Z, HALF_Z, 0, [], OUTSIDE)
	# Front: wall with the entrance, then the shop window of the grooming room from x = -1 to 7.
	var height := up - PlaceBuilder.SLAB
	_build.wall("x", HALF_Z, -HALF_X, -1.0, 0, [ENTRANCE_X], OUTSIDE)
	_build.box(Vector3(3.0, 0.45, HALF_Z), Vector3(8.0, 0.9, PlaceBuilder.WALL), OUTSIDE)
	_build.box(Vector3(3.0, 2.4, HALF_Z), Vector3(8.0, height - 2.3, PlaceBuilder.WALL), OUTSIDE)
	_build.box(Vector3(3.0, 1.6, HALF_Z), Vector3(8.0, 1.4, 0.04), GLASS)
	_build.box(Vector3(7.5, height / 2, HALF_Z), Vector3(1.0, height, PlaceBuilder.WALL), OUTSIDE)
	_build.mesh_box(Vector3(0, 2.4, HALF_Z + 0.8), Vector3(HALF_X * 2 - 1, 0.1, 1.5), AWNING)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_PET_SALON"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, up + 0.6, HALF_Z + 0.12)
	$Built.add_child(sign_label)
	# A false front over the roof, for the sign.
	_build.box(Vector3(0, up + 0.6, HALF_Z), Vector3(HALF_X * 2, 1.2, PlaceBuilder.WALL), OUTSIDE)


## The yard behind: grass, a low fence on three sides (a cop can jump it) and the big doghouse.
func _build_yard() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, BACK_Z, GRASS_TOP, GRASS)
	var fence_y := GRASS_TOP + FENCE_HEIGHT / 2
	_build.box(Vector3(0, fence_y, -HALF_Z), Vector3(HALF_X * 2, FENCE_HEIGHT, 0.06), WHITE)
	for x: float in [-HALF_X, HALF_X]:
		_build.box(Vector3(x, fence_y, (BACK_Z - HALF_Z) / 2), Vector3(0.06, FENCE_HEIGHT, HALF_Z + BACK_Z), WHITE)
	_build.open_box(DOGHOUSE_AT, Vector3(1.4, 1.1, 1.4), "-x", WOOD)
	_build.mesh_box(DOGHOUSE_AT + Vector3(0, 1.15, 0), Vector3(1.6, 0.1, 1.6), AWNING.darkened(0.3))


## The reception: the counter (open on Ramiro's side) with the till, the waiting armchair, the collar vitrine,
## the photos of happy customers and a shampoo shelf.
func _build_reception() -> void:
	_build.wall("z", RECEPTION_EAST, SPLIT_Z, HALF_Z, 0, [GROOMING_DOOR_Z], INSIDE)
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", WOOD)
	_build.box(COUNTER_AT + Vector3(0.7, COUNTER_SIZE.y + 0.15, 0), Vector3(0.5, 0.3, 0.4), STEEL)
	_build.legs(ARMCHAIR_AT, Vector2(1.0, 0.9), 0.35, WOOD)
	_build.mesh_box(ARMCHAIR_AT + Vector3(0, 0.45, 0), WaitingArmchair.SEAT_SIZE, PINK)
	_build.mesh_box(ARMCHAIR_AT + Vector3(0, 0.45, 0) + WaitingArmchair.BACK_AT, WaitingArmchair.BACK_SIZE, PINK)
	_build.open_box(VITRINE_AT, Vector3(0.8, 1.4, 1.6), "+x", GLASS)
	_build.box(Vector3(VITRINE_AT.x, VITRINE_SHELF - 0.02, VITRINE_AT.z), Vector3(0.7, 0.04, 1.5), GLASS)
	for z: float in [3.3, 6.2]:
		_build.mesh_box(Vector3(RECEPTION_EAST - 0.09, 1.6, z), Vector3(0.03, 0.4, 0.5), FRAME)
	for x: float in [-2.5, -1.5]:
		_build.mesh_box(Vector3(x, 1.6, SPLIT_Z + 0.09), Vector3(0.5, 0.4, 0.03), FRAME)
	_build_shelves(SHELVES.slice(0, 2))
	_build.light(Vector3(-4.0, 2.2, 4.8))


## The grooming room: two tables with a standing dryer each, the bathtub for dogs and the big shampoo shelf.
func _build_grooming_room() -> void:
	for at: Vector3 in TABLES:
		_build.legs(at, Vector2(1.2, 0.6), TABLE_HEIGHT, STEEL)
		_build.box(at + Vector3(0, TABLE_HEIGHT + 0.03, 0), Vector3(1.2, 0.06, 0.6), WHITE)
		var dryer := Vector3(at.x, DRYER_HOOD, DRYER_Z)
		_build.box(Vector3(dryer.x, FLOOR_TOP + 0.7, dryer.z), Vector3(0.08, 1.4, 0.08), STEEL)
		_build.open_box(dryer, Vector3(0.5, 0.35, 0.5), "top", PINK)
		# Scissors hanging on the wall to the reception.
		_build.mesh_box(Vector3(RECEPTION_EAST + 0.09, 1.5, 3.2 + (at.x - 2.5) * 0.2), Vector3(0.02, 0.25, 0.08), STEEL)
	_build.open_box(BATHTUB_AT, Vector3(1.8, 0.6, 1.0), "top", WHITE)
	_build_shelves(SHELVES.slice(2, 4))
	_build.light(Vector3(4.0, 2.2, 4.8))


## The cages: two rows of four along the back wall, most with bars, and the doorway to the yard.
func _build_cages() -> void:
	_build.wall("x", SPLIT_Z, -HALF_X, HALF_X, 0, [CAGES_DOOR_X, STORE_DOOR_X], INSIDE)
	_build.wall("z", CAGES_EAST, BACK_Z, SPLIT_Z, 0, [], BACK)
	for level in 2:
		for i in CAGE_XS.size():
			var at := Vector3(CAGE_XS[i], FLOOR_TOP + level * CAGE_STEP, CAGE_Z)
			_build.open_box(at, CAGE_SIZE, "+z", STEEL)
			if OPEN_CAGES.has(Vector2i(i, level)) or Vector2i(i, level) == POODLE_CAGE:
				continue
			# A dog waiting its turn behind the bars (only the look: the loose ones are Dog bodies).
			var caged: Node3D = Dog.MODELS[(i + level * 3) % Dog.MODELS.size()].instantiate()
			caged.position = at + Vector3(0, 0.05, 0)
			caged.scale = Vector3.ONE * 0.9
			$Built.add_child(caged)
			caged_looks[Vector2i(i, level)] = caged
			for b in 5:
				var x := at.x - CAGE_SIZE.x / 2 + 0.08 + b * 0.16
				_build.mesh_box(Vector3(x, at.y + CAGE_SIZE.y / 2, CAGE_Z + CAGE_SIZE.z / 2), Vector3(0.02, CAGE_SIZE.y, 0.02), STEEL)
	_build.light(Vector3(-4.0, 2.2, 0.3))


## The storeroom: dog food sacks against the back wall, the chest freezer, the towel box and shampoo boxes.
func _build_storeroom() -> void:
	for x: float in [3.0, 3.65, 4.3]:
		_build.box(Vector3(x, FLOOR_TOP + 0.3, -0.9), Vector3(0.6, 0.6, 0.5), SACK)
	_build.box(Vector3(3.3, FLOOR_TOP + 0.85, -0.9), Vector3(0.6, 0.5, 0.5), SACK)
	_build.open_box(FREEZER_AT, Vector3(1.0, 0.9, 1.4), "top", WHITE)
	_build.open_box(TOWELS_AT, Vector3(0.8, 0.6, 0.6), "top", CARDBOARD)
	for y: float in [0.2, 0.6]:
		_build.box(Vector3(7.3, FLOOR_TOP + y, -1.4), Vector3(0.6, 0.4, 0.6), CARDBOARD)
	_build.light(Vector3(5.0, 2.2, 0.3))


## Boards on the wall; their bottles are placed by _place_fragile.
func _build_shelves(shelves: Array) -> void:
	for shelf: Dictionary in shelves:
		var size := Vector3(shelf.length, 0.04, SHELF_DEPTH) if shelf.along == "x" else Vector3(SHELF_DEPTH, 0.04, shelf.length)
		_build.box(shelf.at, size, WOOD)


## The shampoo bottles on the shelves and the collars on the vitrine shelf: each one that breaks is a fine.
func _place_fragile() -> void:
	for shelf: Dictionary in SHELVES:
		var count: int = shelf.bottles
		var axis := Vector3.RIGHT if shelf.along == "x" else Vector3.BACK
		for i in count:
			var offset: float = (i - (count - 1) / 2.0) * (shelf.length - 0.3) / (count - 1)
			var bottle: Ornament = SHAMPOO_SCENE.instantiate()
			bottle.position = (shelf.at as Vector3) + axis * offset + Vector3.UP * (0.02 + BOTTLE_HALF_HEIGHT + 0.005)
			add_child(bottle)
			bottle.broken.connect(_on_fragile_broken)
			shampoos.append(bottle)
	for i in COLLARS:
		var collar: Ornament = COLLAR_SCENE.instantiate()
		collar.position = Vector3(VITRINE_AT.x, VITRINE_SHELF + COLLAR_HALF_HEIGHT + 0.005, VITRINE_AT.z - 0.6 + i * 0.24)
		collar.rotation.y = PI / 2
		add_child(collar)
		collar.broken.connect(_on_fragile_broken)
		collars.append(collar)


## Ramiro at his table, and the armchair where he tells a dog's life. A rammed door reaches him anywhere.
func _place_ramiro() -> void:
	ramiro = GROOMER_SCENE.instantiate()
	ramiro.position = RAMIRO_POST
	add_child(ramiro)
	armchair = WaitingArmchair.new()
	armchair.position = ARMCHAIR_AT + Vector3(0, 0.45, 0)
	armchair.groomer = ramiro
	add_child(armchair)
	for door: FrontDoor in [store_door, back_door]:
		door.broken.connect(ramiro.door_broken)
	ramiro.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_GROOMER"))
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
	ramiro.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## The dogs walk on a navigation mesh baked from the built salon, with the locked doors closed.
func _bake_navigation() -> void:
	var nav: NavigationRegion3D = $Navigation
	NavigationServer3D.map_set_cell_size(get_world_3d().navigation_map, nav.navigation_mesh.cell_size)
	NavigationServer3D.map_set_cell_height(get_world_3d().navigation_map, nav.navigation_mesh.cell_height)
	$Built.add_to_group("navigation_source")
	store_door.add_to_group("navigation_source")
	back_door.add_to_group("navigation_source")
	nav.bake_navigation_mesh(false)


## The loose dogs. What they take ends up in the doghouse; every bark reaches Ramiro.
func _place_dogs() -> void:
	for i in DOGS_AT.size():
		var dog: Dog = DOG_SCENE.instantiate()
		dog.coat = i
		dog.position = DOGS_AT[i] + Vector3.UP * 0.02
		dog.rotation.y = i * 1.1
		dog.areas = DOG_AREAS
		dog.den = DOGHOUSE_AT
		dog.floor_y = FLOOR_TOP
		dog.rng.seed = i + 1
		add_child(dog)
		dog.barked.connect(ramiro.dog_barked)
		dogs.append(dog)
	poodle = DOG_SCENE.instantiate()
	poodle.poodle = true
	poodle.caged = true
	poodle.position = Vector3(CAGE_XS[POODLE_CAGE.x], FLOOR_TOP + POODLE_CAGE.y * CAGE_STEP + 0.07, CAGE_Z)
	poodle.areas = DOG_AREAS
	poodle.den = DOGHOUSE_AT
	poodle.floor_y = FLOOR_TOP
	add_child(poodle)
	poodle.barked.connect(ramiro.dog_barked)
	lady = PoodleLady.new()
	lady.position = LADY_AT
	lady.rotation.y = PI
	add_child(lady)


func _on_fragile_broken(at: Vector3) -> void:
	broken_goods += 1
	raid.fines += Ornament.FINE
	raid.float_label("-%d" % Ornament.FINE, at, Color(1, 0.3, 0.25))
	if ramiro:
		ramiro.saw(at, DogGroomer.SAW_BREAK)
