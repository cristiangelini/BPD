class_name CakeLab
extends Node3D

## The cake lab "Dulce Ciencia" (docs/diseno/laboratorio.md, step 1): one floor on its lot in the city, with the front
## to +Z and the rest of the building closed above it. The tasting room at the front, the big kitchen in the middle,
## the flour storeroom and the locker room in the west, the flavor lab behind glass at the back and the cold room in
## the back east corner. The tasting room is open; the flavor lab and the cold room are locked. The showcase cakes
## break (a fine each) and the flour sacks burst into white footprints. Chef Bruno goes from counter to counter, and
## runs to his soufflé when a cop turns its oven up to the max (step 2); Pocha gossips behind her tray of samples
## (step 3). The case is one of its stories (STORIES), drawn with the seed, run by the same RaidCase as the other
## places (step 4). Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const CAKE_SCENE := preload("res://scenes/props/bakery_cake.tscn")
const SACK_SCENE := preload("res://scenes/props/lab_flour_sack.tscn")
const CHEF_SCENE := preload("res://scenes/npc/pastry_chef.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the lab can be suspected of (laboratorio.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["silver_cake", "stolen_recipe", "sleepy_cakes", "gold_flour", "foam_cakes", "robot_arm"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_CAKE_LAB_TIP_B", "BRIEF_TIP_C", "BRIEF_CAKE_LAB_TIP_D",
	"BRIEF_CAKE_LAB_TIP_E"]
## The stories the lab can tell, like InsuranceOffice.STORIES: what the comisario says once it's guessed, its "find
## it" row, what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the
## checklist rows of its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the
## rest extras; without it the rig sets the main evidence.
const STORIES := {
	"silver_cake": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SILVER_CAKE_B", "BRIEF_SILVER_CAKE_C", "BRIEF_SILVER_CAKE_D"],
		"find": "OBJ_FIND_SILVER_CAKE",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/silver_cake.tscn"), preload("res://scenes/props/bill_mold.tscn"),
			preload("res://scenes/props/orders_notebook.tscn")],
		"half_heights": [0.31, 0.02, 0.01],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_BILL_MOLD", "OBJ_EXTRA_ORDERS_NOTEBOOK"],
		"rig": preload("res://scripts/case/cake_lab/silver_cake_rig.gd"),
	},
	"stolen_recipe": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_STOLEN_RECIPE_B", "BRIEF_STOLEN_RECIPE_C", "BRIEF_STOLEN_RECIPE_D"],
		"find": "OBJ_FIND_RECIPE_BOOK",
		"hidden": [preload("res://scenes/props/disguise_photo.tscn"), preload("res://scenes/props/delivery_cap.tscn")],
		"half_heights": [0.004, 0.035],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_DISGUISE_PHOTO", "OBJ_EXTRA_DELIVERY_CAP"],
		"rig": preload("res://scripts/case/cake_lab/stolen_recipe_rig.gd"),
	},
	"sleepy_cakes": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SLEEPY_CAKES_B", "BRIEF_SLEEPY_CAKES_C", "BRIEF_SLEEPY_CAKES_D"],
		"find": "OBJ_FIND_SLEEP_POWDER",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/sleep_powder_jar.tscn"), preload("res://scenes/props/sleepers_list.tscn"),
			preload("res://scenes/props/measuring_spoon.tscn")],
		"half_heights": [0.09, 0.003, 0.045],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_SLEEPERS_LIST", "OBJ_EXTRA_MEASURING_SPOON"],
		"rig": preload("res://scripts/case/cake_lab/sleepy_cakes_rig.gd"),
	},
}
## Surfaces where the suspicions' clue notes can lie, one in each part of the lab; three are drawn with the seed.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-6.5, FLOOR_TOP + 0.75, 9.4), Vector3(1.0, FLOOR_TOP + 0.9, 3.5), Vector3(-9.0, FLOOR_TOP, -1.0),
	Vector3(-9.6, FLOOR_TOP + 0.44, -7.0), Vector3(9.0, FLOOR_TOP, -1.4), Vector3(4.5, FLOOR_TOP, -7.0),
]
const CAKE_MODEL := preload("res://assets/models/bakery_cake.glb")
const OVEN_MODEL := preload("res://assets/models/lab_oven.glb")
const MIXER_MODEL := preload("res://assets/models/giant_mixer.glb")
const MICROSCOPE_MODEL := preload("res://assets/models/microscope.glb")
const TUBES_MODEL := preload("res://assets/models/test_tubes.glb")
const HALF_X := 12.0
const HALF_Z := 11.0
## The lab's ceiling, and the closed floors of the building over it up to the lot's height.
const WALL_TOP := 3.5
const BUILDING_TOP := 8.0
const FLOOR_TOP := 0.06
const ENTRANCE_WIDTH := 2.4
const OPENING_WIDTH := 1.8
## The wall between the tasting room and the kitchen, with its two openings.
const TASTING_Z := 6.0
const TASTING_OPENINGS: Array[float] = [-6.0, 6.0]
## The west band: the flour storeroom in front of the locker room.
const WEST_X := -7.0
const STOREROOM_DOOR_Z := 1.0
const BACK_Z := -4.0
const LOCKER_DOOR_X := -9.5
## The flavor lab behind glass at the back, and its locked door.
const LAB_EAST_X := 3.0
const LAB_DOOR_X := -2.0
## The cold room in the back east corner, and its locked door.
const COLD_X := 6.0
const COLD_DOOR_X := 9.0

const SHOWCASE_AT := Vector3(0.0, FLOOR_TOP, 7.4)
const SHOWCASE_SIZE := Vector3(4.0, 0.9, 0.8)
const CAKES := 8
const CAKE_HALF_HEIGHT := 0.09
const TILL_AT := Vector3(-8.5, FLOOR_TOP, 7.5)
const TILL_SIZE := Vector3(2.0, 1.0, 0.7)
## The till on the counter, with the key to the cold room and the flavor lab.
const TILL_ON := Vector3(-8.0, FLOOR_TOP + 1.0, 7.5)
const TRAY_AT := Vector3(4.0, FLOOR_TOP, 7.5)
const TRAY_SIZE := Vector3(1.6, 0.9, 0.6)
## Pocha, behind her tray.
const POCHA_AT := Vector3(4.0, FLOOR_TOP, 6.6)
const TABLES: Array[Vector3] = [
	Vector3(-6.5, FLOOR_TOP, 9.4), Vector3(-3.5, FLOOR_TOP, 9.4), Vector3(3.5, FLOOR_TOP, 9.4), Vector3(6.5, FLOOR_TOP, 9.4),
]
const TABLE_SIZE := Vector3(0.9, 0.75, 0.9)
## The three long steel counters across the kitchen.
const COUNTER_X := -1.0
const COUNTER_ROWS: Array[float] = [3.5, 0.5, -2.2]
const COUNTER_SIZE := Vector3(6.0, 0.9, 0.9)
const MIXERS: Array[Vector3] = [Vector3(7.0, FLOOR_TOP, 3.2), Vector3(7.0, FLOOR_TOP, 0.2)]
## The wall of ovens on the east side, facing the kitchen; the one at HIDING_OVEN is hollow.
const OVEN_X := 11.4
const OVENS: Array[float] = [4.2, 2.6, 1.0, -0.6, -2.2]
const OVEN_SIZE := Vector3(0.9, 1.6, 1.2)
const HIDING_OVEN := 3
## The soufflé oven, with the red knob: the chef's distraction (LabOven), and where he stands to save it.
const SOUFFLE_OVEN := 0
const SOUFFLE_SPOT := Vector3(10.2, FLOOR_TOP, 4.2)
## Chef Bruno's round, back and forth: the aisle in front of the counters and the two between them.
const CHEF_ROUTE: Array[Vector3] = [
	Vector3(-5.0, FLOOR_TOP, 4.9), Vector3(4.5, FLOOR_TOP, 4.9), Vector3(4.5, FLOOR_TOP, 2.0),
	Vector3(-5.0, FLOOR_TOP, 2.0), Vector3(-5.0, FLOOR_TOP, -0.85), Vector3(4.5, FLOOR_TOP, -0.85),
]
## Seeing a flour sack burst.
const SAW_FLOUR := 10.0
## The flour sacks: two rows along the storeroom's west wall, with a gap in the middle.
const SACK_ROWS: Array[float] = [-11.35, -10.75]
const SACK_ALONG: Array[float] = [5.0, 4.0, 3.0, 1.0, 0.0]
const SACK_SIZE := Vector3(0.58, 0.36, 0.88)
const SACK_GAP_Z := 2.0
const LOCKERS := 5
const LOCKER_SIZE := Vector3(0.5, 1.9, 0.6)
const OPEN_LOCKER := 2
const LAB_TABLE_AT := Vector3(-2.0, FLOOR_TOP, -7.5)
const LAB_TABLE_SIZE := Vector3(3.0, 0.9, 1.0)
const RECIPE_CABINET_AT := Vector3(-6.4, FLOOR_TOP, -9.5)
const RECIPE_CABINET_SIZE := Vector3(0.8, 1.6, 1.0)
const COLD_SHELF_X := 11.6
const COLD_BOARDS: Array[float] = [0.5, 1.0, 1.5]
const BIN_AT := Vector3(4.5, FLOOR_TOP, -9.6)
const BIN_SIZE := Vector3(0.5, 0.6, 0.5)

const OUTSIDE := Color(0.9, 0.86, 0.72)
const GLASS := Color(0.6, 0.8, 0.9, 0.35)
const TILE := Color(0.86, 0.87, 0.83)
const FLOOR := Color(0.74, 0.6, 0.5)
const PINK := Color(0.96, 0.7, 0.78)
const MINT := Color(0.62, 0.85, 0.75)
const STEEL := Color(0.72, 0.75, 0.78)
const WOOD := Color(0.6, 0.44, 0.3)
const DARK := Color(0.22, 0.22, 0.25)
const ICE := Color(0.78, 0.9, 0.98)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_oven", "at": Vector3(OVEN_X, FLOOR_TOP + 0.05, OVENS[HIDING_OVEN]), "heavy": true},
	{"id": "under_steel_counter", "at": Vector3(COUNTER_X - 1.5, FLOOR_TOP, COUNTER_ROWS[1]), "heavy": true},
	{"id": "between_flour_sacks", "at": Vector3(-11.05, FLOOR_TOP, SACK_GAP_Z), "heavy": true},
	{"id": "in_cold_room", "at": Vector3(8.0, FLOOR_TOP, -9.0), "heavy": true},
	{"id": "under_tasting_table", "at": TABLES[1], "heavy": true},
	{"id": "behind_showcase", "at": Vector3(1.0, FLOOR_TOP, 6.6), "heavy": true},
	{"id": "in_locker", "at": Vector3(-11.6, FLOOR_TOP + 0.05, -9.8 + OPEN_LOCKER * 0.7), "heavy": false},
	{"id": "in_recipe_cabinet", "at": RECIPE_CABINET_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "on_cold_shelf", "at": Vector3(COLD_SHELF_X - 0.05, FLOOR_TOP + COLD_BOARDS[1] + 0.02, -6.0), "heavy": false},
	{"id": "in_mixer_bowl", "at": MIXERS[0] + Vector3(0, 0.35, 0.05), "heavy": false},
	{"id": "in_kitchen_bin", "at": BIN_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "on_lab_table", "at": LAB_TABLE_AT + Vector3(0.8, LAB_TABLE_SIZE.y, 0), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var lab_door: FrontDoor
var cold_door: FrontDoor
var city_map: CityMap
var cakes: Array[Ornament] = []
var sacks: Array[FlourSack] = []
var flour: FlourPrints
var oven: LabOven
var chef: FloorBoss
var pocha: LabAssistant
var complaint_bar: ProgressBar
var broken_goods := 0
var burst_sacks := 0
## The case flow every raid shares.
var raid: RaidCase
## Same seed, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: CakeLabRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var till: Till
## Money taken off the case pay: squashed cakes (each one an Ornament.FINE).
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
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
	flour = FlourPrints.new()
	add_child(flour)
	_build_shell()
	_build_tasting_room()
	_build_kitchen()
	_build_storeroom()
	_build_locker_room()
	_build_flavor_lab()
	_build_cold_room()
	_place_cakes()
	_place_sacks()
	lab_door = _door(Vector3(LAB_DOOR_X, FLOOR_TOP, BACK_Z))
	cold_door = _door(Vector3(COLD_DOOR_X, FLOOR_TOP, BACK_Z))
	_place_chef()
	_place_pocha()
	_place_case_props()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("cake_lab")
	station_parking = city.transform * CityLayout.parking("station")
	raid.station_parking = station_parking
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "cake_lab", car)
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = chef
	raid.owner_id = "cake_lab"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The lab's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_CAKE_LAB",
		"guess_key": "OBJ_GUESS_CAKE_LAB",
		"broken_key": "OBJ_BROKEN_CAKE_LAB",
		"complaint_key": "OBJ_COMPLAINT_CAKE_LAB",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": chef.complaint,
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


## What the chef lets slip when asked (where the story's things are, in an order drawn from the seed), and what Pocha
## saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		chef.slips.append(tr("CHEF_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	chef.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	pocha.clue = tr("CLUE_POCHA") % where
	pocha.clue_speech = tr("POCHA_CLUE_" + story_id) % where
	pocha.told.connect(raid.add_clue)


## What every story can use: the till on the counter with the key to the cold room and the flavor lab.
func _place_case_props() -> void:
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_CAKE_LAB"
	add_child(till)
	till.opened.connect(func(at: Vector3) -> void: chef.saw(at, FloorBoss.SAW_TILL))


## A locked door in a wall along x, its middle at `at`.
func _door(at: Vector3) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(at.x - GameScale.DOOR_WIDTH / 2, at.y - FLOOR_TOP, at.z)
	add_child(door)
	return door


## A wall from the floor up to WALL_TOP, along "x" (at z = fixed) or "z" (at x = fixed), with openings given as
## Vector3(middle, width, height).
func _wall(axis: String, fixed: float, from: float, to: float, openings: Array, color: Color) -> void:
	var start := from
	for opening: Vector3 in openings:
		var a := opening.x - opening.y / 2
		var b := opening.x + opening.y / 2
		_wall_box(axis, fixed, start, a, 0.0, WALL_TOP, color)
		_wall_box(axis, fixed, a, b, opening.z, WALL_TOP, color)
		start = b
	_wall_box(axis, fixed, start, to, 0.0, WALL_TOP, color)


func _wall_box(axis: String, fixed: float, a: float, b: float, y0: float, y1: float, color: Color) -> void:
	if b - a < 0.01 or y1 - y0 < 0.01:
		return
	var size := Vector3(b - a, y1 - y0, PlaceBuilder.WALL) if axis == "x" else Vector3(PlaceBuilder.WALL, y1 - y0, b - a)
	var mid := (a + b) / 2
	var center := Vector3(mid, (y0 + y1) / 2, fixed) if axis == "x" else Vector3(fixed, (y0 + y1) / 2, mid)
	_build.box(center, size, color)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look


## A table: four legs and a top, `size` high.
func _table(at: Vector3, size: Vector3, color: Color, top_color: Color) -> void:
	_build.legs(at, Vector2(size.x, size.z), size.y - 0.04, color)
	_build.box(at + Vector3(0, size.y - 0.02, 0), Vector3(size.x, 0.04, size.z), top_color)


## Tiles, outer walls with the shop window, the ceiling, the closed floors above and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, TILE.darkened(0.08))
	# The front is a shop window from waist height, with the entrance in the middle.
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.0, 0.9, PINK)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.0, 0.9, PINK)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.9, 2.7, GLASS)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.9, 2.7, GLASS)
	_wall_box("x", HALF_Z, -HALF_X, HALF_X, 2.7, WALL_TOP, OUTSIDE)
	_wall("x", -HALF_Z, -HALF_X, HALF_X, [], OUTSIDE)
	_wall("z", -HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	_wall("z", HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	for i in 8:
		_build.mesh_box(Vector3(-HALF_X + 1.6 + i * 2.97, WALL_TOP + 2.4, HALF_Z + 0.02), Vector3(1.6, 1.2, 0.04), GLASS.darkened(0.3))
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_CAKE_LAB"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.position = Vector3(0, WALL_TOP + 0.6, HALF_Z + 0.08)
	$Built.add_child(sign_label)
	# A striped awning over the shop window.
	for i in 12:
		var color := PINK if i % 2 == 0 else TILE
		_build.mesh_box(Vector3(-HALF_X + 1.0 + i * 2.0, 2.9, HALF_Z + 0.7), Vector3(2.0, 0.06, 1.4), color)


## The tasting room: the showcase, the till with the cold room's key (step 2), Pocha's tray and four little tables.
func _build_tasting_room() -> void:
	var openings: Array = TASTING_OPENINGS.map(func(x: float) -> Vector3: return Vector3(x, OPENING_WIDTH, 2.4))
	_wall("x", TASTING_Z, -HALF_X, HALF_X, openings, TILE)
	_build.box(SHOWCASE_AT + Vector3(0, SHOWCASE_SIZE.y / 2, 0), SHOWCASE_SIZE, PINK)
	# The glass hood over the cakes, only for the look, so the cakes can be taken out.
	var hood := SHOWCASE_AT + Vector3(0, SHOWCASE_SIZE.y + 0.3, 0)
	_build.mesh_box(hood + Vector3(0, 0, SHOWCASE_SIZE.z / 2), Vector3(SHOWCASE_SIZE.x, 0.6, 0.02), GLASS)
	_build.mesh_box(hood + Vector3(0, 0.3, 0), Vector3(SHOWCASE_SIZE.x, 0.02, SHOWCASE_SIZE.z), GLASS)
	_build.open_box(TILL_AT, TILL_SIZE, "-z", WOOD)
	_build.box(TRAY_AT + Vector3(0, TRAY_SIZE.y / 2, 0), TRAY_SIZE, MINT)
	_build.mesh_box(TRAY_AT + Vector3(0, TRAY_SIZE.y + 0.01, 0), Vector3(0.7, 0.02, 0.4), STEEL)
	for at: Vector3 in TABLES:
		_table(at, TABLE_SIZE, WOOD.darkened(0.2), TILE)
		for side: float in [-1.0, 1.0]:
			_build.mesh_box(at + Vector3(side * 0.7, 0.23, 0), Vector3(0.4, 0.46, 0.4), PINK.darkened(0.15))
	_build.light(Vector3(-6.0, 3.1, 8.5))
	_build.light(Vector3(6.0, 3.1, 8.5))


## The big kitchen: three long steel counters, the two giant mixers, the wall of ovens and the giant piping bag.
func _build_kitchen() -> void:
	for z: float in COUNTER_ROWS:
		_table(Vector3(COUNTER_X, FLOOR_TOP, z), COUNTER_SIZE, STEEL.darkened(0.2), STEEL)
		_build.mesh_box(Vector3(COUNTER_X, FLOOR_TOP + 0.25, z), Vector3(COUNTER_SIZE.x - 0.2, 0.03, COUNTER_SIZE.z - 0.2), STEEL.darkened(0.1))
	for at: Vector3 in MIXERS:
		_build.box(at + Vector3(0, 0.1, 0), Vector3(0.9, 0.2, 0.9), MINT)
		_build.box(at + Vector3(0, 0.8, -0.35), Vector3(0.3, 1.2, 0.3), MINT)
		var bowl := at + Vector3(0, 0.3, 0.05)
		_build.open_box(bowl, Vector3(0.5, 0.5, 0.5), "top", STEEL)
		_model(MIXER_MODEL, at)
	for i in OVENS.size():
		var at := Vector3(OVEN_X, FLOOR_TOP, OVENS[i])
		if i == SOUFFLE_OVEN:
			oven = LabOven.new()
			oven.position = at
			oven.rotation.y = -PI / 2
			add_child(oven)
			continue
		if i == HIDING_OVEN:
			_build.open_box(at, OVEN_SIZE, "-x", STEEL)
		else:
			_build.box(at + Vector3(0, OVEN_SIZE.y / 2, 0), OVEN_SIZE, STEEL)
		_model(OVEN_MODEL, at, -PI / 2)
	# The giant piping bag, 1 m long, hanging over the middle counter.
	var bag := CylinderMesh.new()
	bag.top_radius = 0.18
	bag.bottom_radius = 0.02
	bag.height = 1.0
	_build.mesh(bag, Vector3(COUNTER_X, 2.6, COUNTER_ROWS[1]), Color(0.97, 0.97, 0.95))
	for at: Vector3 in [Vector3(-3.5, 3.1, 2.0), Vector3(2.0, 3.1, 2.0), Vector3(-3.5, 3.1, -2.0), Vector3(2.0, 3.1, -2.0), Vector3(9.0, 3.1, 1.0)]:
		_build.light(at)


## The flour storeroom in the west, open to the kitchen: shelves of eggs and colourings over the sacks.
func _build_storeroom() -> void:
	_wall("z", WEST_X, BACK_Z, TASTING_Z, [Vector3(STOREROOM_DOOR_Z, OPENING_WIDTH, 2.4)], TILE)
	for y: float in [1.2, 1.8]:
		_build.box(Vector3(-9.5, FLOOR_TOP + y, TASTING_Z - 0.3), Vector3(4.0, 0.04, 0.5), WOOD)
		for i in 6:
			var at := Vector3(-11.0 + i * 0.6, FLOOR_TOP + y + 0.1, TASTING_Z - 0.3)
			var color := Color(0.9, 0.82, 0.6) if y < 1.5 else Color.from_hsv(i / 6.0, 0.6, 0.9)
			_build.mesh_box(at, Vector3(0.4, 0.16, 0.3), color)
	_build.light(Vector3(-9.5, 3.1, 1.0))


## The locker room behind the storeroom: five lockers (one ajar), a bench, the chef's hats and aprons.
func _build_locker_room() -> void:
	_wall("x", BACK_Z, -HALF_X, WEST_X, [Vector3(LOCKER_DOOR_X, OPENING_WIDTH, 2.4)], TILE)
	_wall("z", WEST_X, -HALF_Z, BACK_Z, [], TILE)
	for i in LOCKERS:
		var at := Vector3(-11.6, FLOOR_TOP, -9.8 + i * 0.7)
		if i == OPEN_LOCKER:
			_build.open_box(at, LOCKER_SIZE, "+x", MINT.darkened(0.2))
		else:
			_build.box(at + Vector3(0, LOCKER_SIZE.y / 2, 0), LOCKER_SIZE, MINT.darkened(0.2))
	_build.box(Vector3(-9.6, FLOOR_TOP + 0.22, -7.5), Vector3(0.4, 0.44, 2.4), WOOD)
	for i in 4:
		var at := Vector3(-7.2, 1.6, -9.5 + i * 0.8)
		_build.mesh_box(at, Vector3(0.04, 0.8, 0.5), TILE)
		_build.mesh(_hat_mesh(), at + Vector3(-0.12, 0.65, 0), TILE)
	_build.light(Vector3(-9.5, 3.1, -7.5))


func _hat_mesh() -> CylinderMesh:
	var hat := CylinderMesh.new()
	hat.top_radius = 0.14
	hat.bottom_radius = 0.1
	hat.height = 0.3
	return hat


## The flavor lab behind glass: the lab table with the microscope and the test tubes, the formula board and the
## recipe cabinet.
func _build_flavor_lab() -> void:
	var door_x := LAB_DOOR_X
	var half := GameScale.DOOR_WIDTH / 2
	for piece: Array in [[WEST_X, door_x - half], [door_x + half, LAB_EAST_X]]:
		_wall_box("x", BACK_Z, piece[0], piece[1], 0.0, 1.0, TILE)
		_wall_box("x", BACK_Z, piece[0], piece[1], 1.0, 2.4, GLASS)
		_wall_box("x", BACK_Z, piece[0], piece[1], 2.4, WALL_TOP, TILE)
	_wall_box("x", BACK_Z, door_x - half, door_x + half, GameScale.DOOR_HEIGHT, WALL_TOP, TILE)
	_wall("z", LAB_EAST_X, -HALF_Z, BACK_Z, [], TILE)
	_table(LAB_TABLE_AT, LAB_TABLE_SIZE, DARK, TILE)
	var top := LAB_TABLE_AT + Vector3(0, LAB_TABLE_SIZE.y, 0)
	_model(MICROSCOPE_MODEL, top + Vector3(-0.9, 0, 0))
	_model(TUBES_MODEL, top + Vector3(-0.2, 0, -0.2))
	_model(TUBES_MODEL, top + Vector3(-0.2, 0, 0.2))
	_build.open_box(RECIPE_CABINET_AT, RECIPE_CABINET_SIZE, "+x", WOOD)
	# The formula board on the back wall.
	_build.mesh_box(Vector3(-2.0, 1.8, -HALF_Z + 0.1), Vector3(3.0, 1.4, 0.03), DARK.lightened(0.1))
	for i in 5:
		_build.mesh_box(Vector3(-3.1 + i * 0.5, 1.9 - (i % 2) * 0.3, -HALF_Z + 0.12), Vector3(0.35, 0.05, 0.01), TILE)
	_build.light(Vector3(-2.0, 3.1, -7.5))


## The cold room in the back east corner: shelves of finished cakes and a cold blue light.
func _build_cold_room() -> void:
	_wall("x", BACK_Z, COLD_X, HALF_X, [Vector3(COLD_DOOR_X, GameScale.DOOR_WIDTH, GameScale.DOOR_HEIGHT)], ICE)
	_wall("z", COLD_X, -HALF_Z, BACK_Z, [], ICE)
	for y: float in COLD_BOARDS:
		_build.box(Vector3(COLD_SHELF_X, FLOOR_TOP + y, -7.5), Vector3(0.6, 0.04, 6.4), STEEL)
		for i in 6:
			var z := -10.2 + i * 1.0
			# The middle board keeps a place free for the hiding spot.
			if y == COLD_BOARDS[1] and absf(z + 6.0) < 0.6:
				continue
			_model(CAKE_MODEL, Vector3(COLD_SHELF_X, FLOOR_TOP + y + 0.02, z))
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(9.0, 3.0, -7.5)
	lamp.light_color = ICE
	lamp.light_energy = 0.8
	lamp.omni_range = 7.0
	$Built.add_child(lamp)
	# The back nook between the lab and the cold room: the sink and the bin.
	_build.box(Vector3(4.5, FLOOR_TOP + 0.45, -10.6), Vector3(2.0, 0.9, 0.6), STEEL)
	_build.open_box(BIN_AT, BIN_SIZE, "top", DARK)
	_build.light(Vector3(4.5, 3.1, -7.5))


## The cakes in the showcase, two rows of four: each one that breaks is a fine.
func _place_cakes() -> void:
	for i in CAKES:
		var cake: Ornament = CAKE_SCENE.instantiate()
		var x := SHOWCASE_AT.x - 1.35 + (i % 4) * 0.9
		var z := SHOWCASE_AT.z + (0.18 if i < 4 else -0.18)
		cake.position = Vector3(x, SHOWCASE_AT.y + SHOWCASE_SIZE.y + CAKE_HALF_HEIGHT + 0.005, z)
		add_child(cake)
		cake.broken.connect(_on_cake_broken)
		cakes.append(cake)


## The ten flour sacks in the storeroom, two rows with a gap in the middle.
func _place_sacks() -> void:
	for x: float in SACK_ROWS:
		for z: float in SACK_ALONG:
			var sack: FlourSack = SACK_SCENE.instantiate()
			sack.position = Vector3(x, FLOOR_TOP + SACK_SIZE.y / 2 + 0.005, z)
			add_child(sack)
			sack.burst.connect(_on_sack_burst)
			sacks.append(sack)


## Chef Bruno on his round between the counters, ready for his soufflé, and his complaint meter. A rammed door reaches
## him anywhere; squashed cakes and burst sacks only if he sees them.
func _place_chef() -> void:
	chef = CHEF_SCENE.instantiate()
	chef.route = CHEF_ROUTE
	chef.printer_spot = SOUFFLE_SPOT
	chef.printer = oven
	add_child(chef)
	chef.start_at(0)
	for door: FrontDoor in [lab_door, cold_door]:
		door.broken.connect(chef.door_broken)
	chef.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_CAKE_LAB"))
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
	chef.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Pocha behind her tray of samples, facing the tasting room.
func _place_pocha() -> void:
	pocha = LabAssistant.new()
	pocha.name = "Pocha"
	pocha.position = POCHA_AT
	add_child(pocha)


func _on_cake_broken(at: Vector3) -> void:
	broken_goods += 1
	raid.fines += Ornament.FINE
	raid.float_label("-%d" % Ornament.FINE, at, Color(1, 0.3, 0.25))
	if chef:
		chef.saw(at, FloorBoss.SAW_BREAK, "CHEF_CAKE")


func _on_sack_burst(at: Vector3) -> void:
	burst_sacks += 1
	flour.spill(at)
	if chef:
		chef.saw(at + Vector3.UP * 0.5, SAW_FLOUR, "CHEF_FLOUR")
