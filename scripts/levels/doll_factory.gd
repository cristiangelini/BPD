class_name DollFactory
extends Node3D

## The doll factory "Sonrisas" (docs/diseno/fabrica.md, step 1): a tall hall on its lot in the city with the front to
## +Z. The reception at the front, the factory floor with the U-shaped belt and its machines in the west part, the
## storeroom in the east part with the foreman's office upstairs at its back, and the loading dock behind the hall.
## The reception is open; the office is locked and the dock's shutter opens with a button inside. The porcelain dolls
## of the showcase and the plaster molds of the floor break, each one a fine. Fermín, the foreman, walks along the
## belt, restarts it when a cop stops it and clears it when it jams (step 3). Bare dolls keep dropping onto the
## belt, and Nilda wants five of them in her box (step 4). The case is one of its stories (STORIES), drawn with the
## seed, run by the same RaidCase as the other places (step 5). Every number here is (propuesta).

## The feeder dropped a bare doll onto the belt (the stories can dress it).
signal fed_doll(doll: Node3D)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const FERMIN_SCENE := preload("res://scenes/npc/foreman.tscn")
const BELT_DOLL_SCENE := preload("res://scenes/props/factory_doll.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")

## Every story the factory can be suspected of (fabrica.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["diamond_doll", "spy_dolls", "fake_captain", "ghost_workers", "giant_doll", "poodle_hair"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_FACTORY_TIP_B", "BRIEF_TIP_C", "BRIEF_FACTORY_TIP_D",
	"BRIEF_FACTORY_TIP_E"]
## The stories the factory can tell, like HardwareStore.STORIES: what the comisario says once it's guessed, its
## "find it" row, what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the
## checklist rows of its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the
## rest extras; without it the rig sets the main evidence.
const STORIES := {
	"diamond_doll": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_DIAMOND_DOLL_B", "BRIEF_DIAMOND_DOLL_C", "BRIEF_DIAMOND_DOLL_D"],
		"find": "OBJ_FIND_DIAMOND_DOLL",
		"hidden": [preload("res://scenes/props/jeweler_loupe.tscn"), preload("res://scenes/props/delivery_list.tscn")],
		"half_heights": [0.02, 0.005],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_JEWELER_LOUPE", "OBJ_EXTRA_DELIVERY_LIST"],
		"rig": preload("res://scripts/case/factory/diamond_doll_rig.gd"),
	},
	"spy_dolls": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SPY_DOLLS_B", "BRIEF_SPY_DOLLS_C", "BRIEF_SPY_DOLLS_D"],
		"find": "OBJ_FIND_TAPE_RECORDER",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/tape_recorder.tscn"), preload("res://scenes/props/mic_box.tscn"),
			preload("res://scenes/props/client_list.tscn")],
		"half_heights": [0.08, 0.04, 0.005],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_MIC_BOX", "OBJ_EXTRA_CLIENT_LIST"],
		"rig": preload("res://scripts/case/factory/spy_dolls_rig.gd"),
	},
	"fake_captain": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FAKE_CAPTAIN_B", "BRIEF_FAKE_CAPTAIN_C", "BRIEF_FAKE_CAPTAIN_D"],
		"find": "OBJ_FIND_STOLEN_MOLD",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/stolen_mold.tscn"), preload("res://scenes/props/fake_labels.tscn"),
			preload("res://scenes/props/prototype_photos.tscn")],
		"half_heights": [0.16, 0.05, 0.005],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_FAKE_LABELS", "OBJ_EXTRA_PROTOTYPE_PHOTOS"],
		"rig": preload("res://scripts/case/factory/fake_captain_rig.gd"),
	},
	"ghost_workers": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_GHOST_WORKERS_B", "BRIEF_GHOST_WORKERS_C", "BRIEF_GHOST_WORKERS_D"],
		"find": "OBJ_FIND_PAYROLL_BOOK",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/payroll_book.tscn"), preload("res://scenes/props/time_cards.tscn"),
			preload("res://scenes/props/foreman_wig.tscn")],
		"half_heights": [0.025, 0.015, 0.05],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_TIME_CARDS", "OBJ_EXTRA_FOREMAN_WIG"],
		"rig": preload("res://scripts/case/factory/ghost_workers_rig.gd"),
	},
	"giant_doll": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_GIANT_DOLL_B", "BRIEF_GIANT_DOLL_C", "BRIEF_GIANT_DOLL_D"],
		"find": "OBJ_FIND_JEWELERS_SAFE",
		"hidden": [preload("res://scenes/props/parade_plan.tscn"), preload("res://scenes/props/safe_key.tscn")],
		"half_heights": [0.005, 0.005],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_PARADE_PLAN", "OBJ_EXTRA_SAFE_KEY"],
		"rig": preload("res://scripts/case/factory/giant_doll_rig.gd"),
	},
	"poodle_hair": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_POODLE_HAIR_B", "BRIEF_POODLE_HAIR_C", "BRIEF_POODLE_HAIR_D"],
		"find": "OBJ_FIND_POODLE_HAIR",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/poodle_hair_bag.tscn"), preload("res://scenes/props/gold_comb.tscn"),
			preload("res://scenes/props/fake_invoice.tscn")],
		"half_heights": [0.18, 0.005, 0.005],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_GOLD_COMB", "OBJ_EXTRA_FAKE_INVOICE"],
		"rig": preload("res://scripts/case/factory/poodle_hair_rig.gd"),
	},
}
## Surfaces where the suspicions' clue notes can lie, one in each part of the factory; three are drawn with the seed.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(2.0, FLOOR_TOP, 11.5), Vector3(-12.8, FLOOR_TOP, -1.0), Vector3(-6.6, FLOOR_TOP + 0.88, 1.8),
	Vector3(9.0, FLOOR_TOP, -2.0), Vector3(8.0, FLOOR_TOP + GameScale.FLOOR_HEIGHT, -5.5), Vector3(-6.0, 0.04, -12.0),
]
const MOLD_SCENE := preload("res://scenes/props/plaster_mold.tscn")
const DOLL_SCENE := preload("res://scenes/props/porcelain_doll.tscn")
## The dresses of the showcase's dolls, one model each (tools/modelgen/models/factory.js).
const DOLL_MODELS: Array[PackedScene] = [
	preload("res://assets/models/porcelain_doll_0.glb"), preload("res://assets/models/porcelain_doll_1.glb"),
	preload("res://assets/models/porcelain_doll_2.glb"), preload("res://assets/models/porcelain_doll_3.glb"),
	preload("res://assets/models/porcelain_doll_4.glb"), preload("res://assets/models/porcelain_doll_5.glb"),
]
const HALF_X := 14.0
## The lot runs from -HALF_Z to HALF_Z; the hall covers it from DOCK_Z on, the dock the rest.
const HALF_Z := 13.0
const DOCK_Z := -9.0
const HALL_TOP := 6.0
const FLOOR_TOP := 0.06
const GROUND_TOP := 0.04
## The wall between the reception and the factory floor, and the one between the floor and the storeroom (east).
const RECEPTION_Z := 9.0
const STOREROOM_X := 5.0
const ENTRANCE_WIDTH := 2.4
const RECEPTION_DOORS: Array[float] = [-6.0, 7.0]
const STOREROOM_DOORS: Array[float] = [1.0, 6.0]
## The foreman's office upstairs, over the back of the storeroom, and the stairs that climb to it along -Z.
const OFFICE_FRONT_Z := -4.0
const OFFICE_TOP := FLOOR_TOP + GameScale.FLOOR_HEIGHT
const OFFICE_DOOR_X := 6.0
const STAIRS_FOOT := Vector3(6.0, FLOOR_TOP, 0.0)
const STAIRS_RUN := 4.0
## The shutter of the dock, in the back wall: its middle along x, how wide and how tall the opening is.
const SHUTTER_X := -6.0
const SHUTTER_SIZE := Vector2(3.0, 3.0)
const SHUTTER_BUTTON_AT := Vector3(-8.2, 1.3, DOCK_Z + 0.12)
const SHUTTER_TIME := 1.5
## The belt: a U of three runs, each from one corner to the next, its top at BELT_TOP (ConveyorBelt).
const BELT_CORNERS: Array[Vector3] = [Vector3(-10, 0, 5), Vector3(-10, 0, -6), Vector3(-2, 0, -6), Vector3(-2, 0, 5)]
const BELT_TOP := 0.8
const BELT_WIDTH := 0.8
## The machines over the belt, in the order the dolls go through them.
## The machines over the belt, in the order the dolls go through them, and where Fermín stands to clear each one.
const MACHINES := [
	{"id": "heads", "at": Vector3(-10, 0, 2), "stand": Vector3(-11.5, FLOOR_TOP, 2), "color": Color(0.95, 0.8, 0.3)},
	{"id": "hair", "at": Vector3(-10, 0, -3), "stand": Vector3(-11.5, FLOOR_TOP, -3), "color": Color(0.95, 0.55, 0.7)},
	{"id": "eyes", "at": Vector3(-6, 0, -6), "stand": Vector3(-6, FLOOR_TOP, -7.5), "color": Color(0.35, 0.55, 0.9)},
	{"id": "paint", "at": Vector3(-2, 0, -1), "stand": Vector3(-0.6, FLOOR_TOP, -1), "color": Color(0.85, 0.3, 0.45)},
]
## Fermín's walk around the outside of the U, back and forth, and where he stands to press the red button.
const FERMIN_ROUTE: Array[Vector3] = [
	Vector3(-12, FLOOR_TOP, 4), Vector3(-12, FLOOR_TOP, -7.5), Vector3(0, FLOOR_TOP, -7.5), Vector3(0, FLOOR_TOP, 4),
]
const BUTTON_SPOT := Vector3(-0.2, FLOOR_TOP, 5.0)
## Nilda at the eyes machine, inside the U, facing the belt (-z), with her box of dolls at her right.
const NILDA_AT := Vector3(-6.5, FLOOR_TOP, -4.5)
## A new bare doll drops onto the start of the belt every FEED_EVERY seconds while it moves, up to MAX_DOLLS around;
## the ones that fall in the box cart are packed (gone) PACK_DELAY seconds later.
const FEED_AT := Vector3(-10.0, 1.0, 4.8)
const FEED_EVERY := 4.0
const MAX_DOLLS := 16
const PACK_DELAY := 1.5
## The red button that stops the belt, on a post by its end, facing the street side.
const BELT_BUTTON_AT := Vector3(-0.8, 1.1, 4.3)
## The box cart catches what falls off the end of the belt.
const BOX_CART_AT := Vector3(-2.0, FLOOR_TOP, 5.9)
const MOLD_TABLE_AT := Vector3(-6.0, FLOOR_TOP, 1.5)
const MOLD_TABLE_SIZE := Vector3(2.4, 0.85, 1.0)
const MOLDS := 4
const MOLD_HALF_HEIGHT := 0.06
const DESK_AT := Vector3(-8.0, FLOOR_TOP, 11.0)
const DESK_SIZE := Vector3(3.0, 1.0, 0.8)
## The till on the reception desk, with the office key.
const TILL_AT := Vector3(-7.0, FLOOR_TOP + 1.0, 11.0)
## The quality control scale on the factory floor, by the reception wall.
const SCALE_AT := Vector3(3.0, FLOOR_TOP, 7.9)
## The bin of finished dolls in the storeroom, and how many lie in it (rows along x, columns along z).
const BIN_AT := Vector3(9.5, FLOOR_TOP, 1.0)
const BIN_SIZE := Vector3(1.8, 0.7, 1.2)
const PILE := Vector2i(6, 4)
## The showcase of porcelain dolls in the reception: a low cabinet open to the front, with a glass board over it.
const SHOWCASE_AT := Vector3(10.0, FLOOR_TOP, 11.6)
const SHOWCASE_SIZE := Vector3(2.6, 0.8, 0.6)
const SHOWCASE_BOARD_Y := 1.4
const DOLLS := 6
const DOLL_HALF_HEIGHT := 0.16
const CLOCK_AT := Vector3(5.0, 1.4, RECEPTION_Z + 0.1)
const RACKS_X := 13.1
const RACK_BOARDS: Array[float] = [0.6, 1.4, 2.2]
const RACKS_Z := Vector2(-3.0, 8.0)
const RACK_GAP_Z := 0.2
const CRATE_AT := Vector3(8.0, FLOOR_TOP, 6.5)
const OFFICE_DESK_AT := Vector3(10.0, OFFICE_TOP, -7.0)
const OFFICE_DESK_SIZE := Vector3(1.6, 0.75, 0.8)
const FILING_AT := Vector3(13.2, OFFICE_TOP, -8.3)
const TRUCK_AT := Vector3(3.0, GROUND_TOP, -11.2)
const CARGO_SIZE := Vector3(3.6, 2.0, 2.2)
const DUMPSTER_AT := Vector3(-11.0, GROUND_TOP, -11.6)
const DUMPSTER_SIZE := Vector3(1.8, 1.1, 1.2)
const FENCE_HEIGHT := 1.2
## The gap in the dock's west fence: the dock can be walked into from the side street.
const GATE_Z := -11.0
const GATE_WIDTH := 2.4

const OUTSIDE := Color(0.95, 0.6, 0.75)
const INSIDE := Color(0.95, 0.92, 0.9)
const FLOOR := Color(0.7, 0.72, 0.74)
const CONCRETE := Color(0.6, 0.6, 0.58)
const WOOD := Color(0.62, 0.45, 0.3)
const STEEL := Color(0.55, 0.58, 0.62)
const TIRE := Color(0.18, 0.18, 0.2)
const GLASS := Color(0.55, 0.75, 0.85, 0.35)
const CARDBOARD := Color(0.72, 0.56, 0.36)
const TRUCK := Color(0.95, 0.95, 0.92)
const GREEN := Color(0.25, 0.5, 0.3)
const YELLOW := Color(0.95, 0.8, 0.2)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "under_reception_desk", "at": DESK_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "in_showcase", "at": SHOWCASE_AT + Vector3(0.8, 0.05, 0), "heavy": false},
	{"id": "under_belt", "at": Vector3(-10.0, FLOOR_TOP, 1.0), "heavy": true},
	{"id": "in_box_cart", "at": BOX_CART_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "on_mold_table", "at": MOLD_TABLE_AT + Vector3(0.6, MOLD_TABLE_SIZE.y + 0.03, 0.3), "heavy": false},
	{"id": "in_crate", "at": CRATE_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "on_storeroom_rack", "at": Vector3(RACKS_X, FLOOR_TOP + RACK_BOARDS[0] + 0.02, RACK_GAP_Z), "heavy": false},
	{"id": "under_office", "at": Vector3(10.0, FLOOR_TOP, -7.5), "heavy": true},
	{"id": "on_office_desk", "at": OFFICE_DESK_AT + Vector3(0.4, OFFICE_DESK_SIZE.y + 0.06, 0), "heavy": false},
	{"id": "in_filing_cabinet", "at": FILING_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "in_truck", "at": TRUCK_AT + Vector3(-0.5, 0.5, 0), "heavy": true},
	{"id": "in_dumpster", "at": DUMPSTER_AT + Vector3(0, 0.05, 0), "heavy": true},
]
## The spots out on the dock (the rest are inside the hall).
const DOCK_SPOTS: Array[String] = ["in_truck", "in_dumpster"]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var office_door: FrontDoor
var shutter: StaticBody3D
var shutter_button: PushButton
var shutter_open := false
var belt: ConveyorBelt
var belt_button: PushButton
var city_map: CityMap
var dolls: Array[Ornament] = []
var molds: Array[Ornament] = []
var broken_goods := 0
## Money taken off the case pay: broken things (each one an Ornament.FINE).
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## The case flow every raid shares.
var raid: RaidCase
## Same seed, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: FactoryRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var till: Till
var scale_: WeighScale
## The finished dolls in the storeroom's bin.
var pile: Array[Grabbable] = []
var fermin: Foreman
var nilda: QuotaWorker
## Dolls that came out of the end of the belt into the box cart.
var shipped := 0
var _feed_left := 0.0
var complaint_bar: ProgressBar
## The dolls the feeder dropped that are still around.
var fed: Array[Node3D] = []
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
	_build_dock()
	_build_reception()
	_build_floor()
	_build_storeroom()
	_build_office()
	_place_fragile()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, OFFICE_TOP - FLOOR_TOP, OFFICE_FRONT_Z)
	add_child(office_door)
	_place_fermin()
	_place_nilda()
	_place_case_props()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("doll_factory")
	station_parking = city.transform * CityLayout.parking("station")
	raid.station_parking = station_parking
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "doll_factory", car)
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = fermin
	raid.owner_id = "factory"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The factory's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_FACTORY",
		"guess_key": "OBJ_GUESS_FACTORY",
		"broken_key": "OBJ_BROKEN_FACTORY",
		"complaint_key": "OBJ_COMPLAINT_FACTORY",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": fermin.complaint,
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


## What Fermín lets slip when asked (where the story's things are, in an order drawn from the seed), and what Nilda
## saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		fermin.slips.append(tr("FOREMAN_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	fermin.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	nilda.clue = tr("CLUE_NILDA") % where
	nilda.clue_speech = tr("NILDA_CLUE_" + story_id) % where
	nilda.told.connect(raid.add_clue)


## What every story can use: the till with the office key, the quality control scale and the bin of finished dolls.
func _place_case_props() -> void:
	till = Till.new()
	till.position = TILL_AT + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_FACTORY"
	add_child(till)
	till.opened.connect(func(at: Vector3) -> void: fermin.saw(at, Foreman.SAW_TILL))
	scale_ = WeighScale.new()
	scale_.position = SCALE_AT
	# Its display faces the factory floor, away from the reception wall.
	scale_.rotation.y = PI
	add_child(scale_)
	_build.open_box(BIN_AT, BIN_SIZE, "top", CARDBOARD)
	var step := Vector2(BIN_SIZE.x / PILE.x, BIN_SIZE.z / PILE.y)
	for row in PILE.x:
		for column in PILE.y:
			var doll: Grabbable = BELT_DOLL_SCENE.instantiate()
			doll.position = BIN_AT + Vector3(-BIN_SIZE.x / 2 + (row + 0.5) * step.x, 0.22, -BIN_SIZE.z / 2 + (column + 0.5) * step.y)
			add_child(doll)
			pile.append(doll)


## A wall of the hall, from the floor up to HALL_TOP, along "x" (at z = fixed) or "z" (at x = fixed), with openings
## given as Vector3(middle, width, height).
func _hall_wall(axis: String, fixed: float, from: float, to: float, openings: Array, color: Color) -> void:
	var start := from
	for opening: Vector3 in openings:
		var a := opening.x - opening.y / 2
		var b := opening.x + opening.y / 2
		_wall_box(axis, fixed, start, a, 0.0, HALL_TOP, color)
		_wall_box(axis, fixed, a, b, opening.z, HALL_TOP, color)
		start = b
	_wall_box(axis, fixed, start, to, 0.0, HALL_TOP, color)


func _wall_box(axis: String, fixed: float, a: float, b: float, y0: float, y1: float, color: Color) -> void:
	if b - a < 0.01 or y1 - y0 < 0.01:
		return
	var size := Vector3(b - a, y1 - y0, PlaceBuilder.WALL) if axis == "x" else Vector3(PlaceBuilder.WALL, y1 - y0, b - a)
	var mid := (a + b) / 2
	var center := Vector3(mid, (y0 + y1) / 2, fixed) if axis == "x" else Vector3(fixed, (y0 + y1) / 2, mid)
	_build.box(center, size, color)


## Floor, outer walls, the roof and the front with the entrance and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, DOCK_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, DOCK_Z - 0.2, HALF_Z + 0.2, HALL_TOP + PlaceBuilder.SLAB, OUTSIDE.darkened(0.35))
	_hall_wall("x", HALF_Z, -HALF_X, HALF_X, [Vector3(0, ENTRANCE_WIDTH, 2.6)], OUTSIDE)
	_hall_wall("x", DOCK_Z, -HALF_X, HALF_X, [Vector3(SHUTTER_X, SHUTTER_SIZE.x, SHUTTER_SIZE.y)], OUTSIDE)
	_hall_wall("z", -HALF_X, DOCK_Z, HALF_Z, [], OUTSIDE)
	_hall_wall("z", HALF_X, DOCK_Z, HALF_Z, [], OUTSIDE)
	_build.mesh_box(Vector3(0, 3.0, HALF_Z + 0.9), Vector3(6.0, 0.1, 1.6), OUTSIDE.darkened(0.2))
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_DOLL_FACTORY"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.position = Vector3(0, HALL_TOP - 1.2, HALF_Z + 0.12)
	$Built.add_child(sign_label)
	# The dock's shutter, rolled down, and the button inside that rolls it up.
	shutter = _build.body(Vector3(SHUTTER_X, SHUTTER_SIZE.y / 2, DOCK_Z))
	_build.shape(shutter, Vector3(SHUTTER_SIZE.x, SHUTTER_SIZE.y, 0.08))
	var slats := MeshInstance3D.new()
	var slats_mesh := BoxMesh.new()
	slats_mesh.size = Vector3(SHUTTER_SIZE.x, SHUTTER_SIZE.y, 0.08)
	slats.mesh = slats_mesh
	slats.material_override = _build.material(STEEL.lightened(0.15))
	shutter.add_child(slats)
	shutter_button = PushButton.new()
	shutter_button.prompt = "PROMPT_SHUTTER_BUTTON"
	shutter_button.position = SHUTTER_BUTTON_AT
	add_child(shutter_button)
	shutter_button.pressed.connect(func(_cop: Cop) -> void: open_shutter())


## The loading dock behind the hall: concrete, a fence with a gate to the side street, the delivery truck that
## doesn't start and the dumpster for the dolls that came out wrong.
func _build_dock() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, DOCK_Z, GROUND_TOP, CONCRETE)
	var fence_y := GROUND_TOP + FENCE_HEIGHT / 2
	var depth := HALF_Z + DOCK_Z
	_build.box(Vector3(0, fence_y, -HALF_Z), Vector3(HALF_X * 2, FENCE_HEIGHT, 0.06), STEEL)
	_build.box(Vector3(HALF_X, fence_y, (DOCK_Z - HALF_Z) / 2), Vector3(0.06, FENCE_HEIGHT, depth), STEEL)
	var gate_a := GATE_Z - GATE_WIDTH / 2
	var gate_b := GATE_Z + GATE_WIDTH / 2
	_build.box(Vector3(-HALF_X, fence_y, (-HALF_Z + gate_a) / 2), Vector3(0.06, FENCE_HEIGHT, gate_a + HALF_Z), STEEL)
	_build.box(Vector3(-HALF_X, fence_y, (gate_b + DOCK_Z) / 2), Vector3(0.06, FENCE_HEIGHT, DOCK_Z - gate_b), STEEL)
	# The truck: its cargo box open at the back (west), the cab ahead of it and four wheels.
	_build.open_box(TRUCK_AT + Vector3(0, 0.45, 0), CARGO_SIZE, "-x", TRUCK)
	_build.box(TRUCK_AT + Vector3(CARGO_SIZE.x / 2 + 0.85, 1.25, 0), Vector3(1.6, 1.6, CARGO_SIZE.z), OUTSIDE)
	for at: Vector3 in [Vector3(-1.1, 0, 1.1), Vector3(-1.1, 0, -1.1), Vector3(2.6, 0, 1.1), Vector3(2.6, 0, -1.1)]:
		var wheel := CylinderMesh.new()
		wheel.top_radius = 0.4
		wheel.bottom_radius = 0.4
		wheel.height = 0.3
		_build.mesh(wheel, TRUCK_AT + at + Vector3(0, 0.4, 0), TIRE, Vector3(PI / 2, 0, 0))
	_build.open_box(DUMPSTER_AT, DUMPSTER_SIZE, "top", GREEN)
	_build.light(Vector3(-4.0, 3.5, -11.0))


## The reception: the desk, a few chairs, the showcase of porcelain dolls and the time clock with its cards.
func _build_reception() -> void:
	var doors: Array = RECEPTION_DOORS.map(func(x: float) -> Vector3: return Vector3(x, GameScale.DOOR_WIDTH * 1.5, 2.4))
	_hall_wall("x", RECEPTION_Z, -HALF_X, HALF_X, doors, INSIDE)
	_build.open_box(DESK_AT, DESK_SIZE, "-z", WOOD)
	for i in 3:
		_build.box(Vector3(-3.5 + i * 0.7, FLOOR_TOP + 0.22, 12.4), Vector3(0.5, 0.44, 0.5), OUTSIDE.darkened(0.1))
	_build.open_box(SHOWCASE_AT, SHOWCASE_SIZE, "+z", WOOD)
	_build.box(Vector3(SHOWCASE_AT.x, SHOWCASE_BOARD_Y, SHOWCASE_AT.z), Vector3(SHOWCASE_SIZE.x, 0.03, SHOWCASE_SIZE.z), GLASS)
	for side: float in [-1.0, 1.0]:
		var post := SHOWCASE_AT + Vector3(side * (SHOWCASE_SIZE.x / 2 - 0.03), 0, 0)
		_build.box(Vector3(post.x, (SHOWCASE_SIZE.y + 2.0) / 2, post.z), Vector3(0.04, 2.0 - SHOWCASE_SIZE.y, SHOWCASE_SIZE.z), GLASS)
	# The time clock and its rack of cards, on the reception's side of the wall.
	_build.mesh_box(CLOCK_AT, Vector3(0.4, 0.5, 0.2), STEEL)
	_build.mesh_box(CLOCK_AT + Vector3(0, 0.12, 0.11), Vector3(0.22, 0.12, 0.02), YELLOW.lightened(0.5))
	for i in 12:
		_build.mesh_box(CLOCK_AT + Vector3(0.5 + (i % 6) * 0.1, -0.15 + (i / 6) * 0.3, -0.03), Vector3(0.07, 0.18, 0.01),
			Color(0.98, 0.95, 0.85))
	_build.light(Vector3(-6.0, 2.6, 11.0))
	_build.light(Vector3(6.0, 2.6, 11.0))


## The factory floor: the U-shaped belt on its legs, the four machines over it, the box cart at its end and the table
## of plaster molds inside the U.
func _build_floor() -> void:
	belt = ConveyorBelt.new()
	belt.name = "Belt"
	add_child(belt)
	belt.build(BELT_CORNERS, BELT_TOP, BELT_WIDTH)
	for machine: Dictionary in MACHINES:
		var at: Vector3 = machine.at
		var across := Vector3(1, 0, 0) if absf(at.x - BELT_CORNERS[0].x) < 0.1 or absf(at.x - BELT_CORNERS[3].x) < 0.1 else Vector3(0, 0, 1)
		for side: float in [-1.0, 1.0]:
			_build.box(Vector3(at.x, 1.5, at.z) + across * side * (BELT_WIDTH / 2 + 0.35), Vector3(0.3, 3.0, 0.3), machine.color)
		var top := Vector3(BELT_WIDTH + 1.0, 0.6, 0.9) if across.x > 0 else Vector3(0.9, 0.6, BELT_WIDTH + 1.0)
		# Wide and high enough for a cop riding the belt to go through.
		_build.box(Vector3(at.x, 2.85, at.z), top, machine.color)
		belt.add_machine(machine.id, at)
	# The red button on its post by the end of the belt.
	_build.box(BELT_BUTTON_AT + Vector3(0, -0.6, -0.12), Vector3(0.2, BELT_BUTTON_AT.y, 0.2), YELLOW)
	belt_button = PushButton.new()
	belt_button.prompt = "PROMPT_BELT_BUTTON"
	belt_button.position = BELT_BUTTON_AT
	add_child(belt_button)
	belt_button.pressed.connect(func(cop: Cop) -> void: belt.stop(cop))
	_build.open_box(BOX_CART_AT, Vector3(1.2, 0.6, 0.9), "top", CARDBOARD)
	_build.legs(MOLD_TABLE_AT, Vector2(MOLD_TABLE_SIZE.x, MOLD_TABLE_SIZE.z), MOLD_TABLE_SIZE.y, STEEL)
	_build.box(MOLD_TABLE_AT + Vector3(0, MOLD_TABLE_SIZE.y + 0.015, 0), Vector3(MOLD_TABLE_SIZE.x, 0.03, MOLD_TABLE_SIZE.z), WOOD)
	for at: Vector3 in [Vector3(-10, 4.5, 2), Vector3(-10, 4.5, -4), Vector3(-2, 4.5, -4), Vector3(-2, 4.5, 2), Vector3(-6, 4.5, 6)]:
		_build.light(at)


## The storeroom: tall racks of boxed dolls along the east wall, a crate on the floor, and the stairs to the office.
func _build_storeroom() -> void:
	var doors: Array = STOREROOM_DOORS.map(func(z: float) -> Vector3: return Vector3(z, GameScale.DOOR_WIDTH * 1.5, 2.4))
	_hall_wall("z", STOREROOM_X, OFFICE_FRONT_Z, RECEPTION_Z, doors, INSIDE)
	var rack_length := RACKS_Z.y - RACKS_Z.x
	var rack_middle := (RACKS_Z.x + RACKS_Z.y) / 2
	for y: float in RACK_BOARDS:
		_build.box(Vector3(RACKS_X, FLOOR_TOP + y, rack_middle), Vector3(1.0, 0.04, rack_length), STEEL)
		for i in 7:
			var z := RACKS_Z.x + 2.0 + i * 1.2
			# The low board keeps a gap free for the hiding spot.
			if y == RACK_BOARDS[0] and absf(z - RACK_GAP_Z) < 0.1:
				continue
			_build.mesh_box(Vector3(RACKS_X, FLOOR_TOP + y + 0.27, z), Vector3(0.8, 0.5, 0.9), CARDBOARD)
	for z: float in [RACKS_Z.x, rack_middle, RACKS_Z.y]:
		_build.box(Vector3(RACKS_X, FLOOR_TOP + 1.3, z), Vector3(1.0, 2.6, 0.06), STEEL)
	_build.open_box(CRATE_AT, Vector3(1.2, 0.7, 1.0), "top", CARDBOARD)
	_build.stairs(STAIRS_FOOT, STAIRS_RUN, WOOD)
	_build.light(Vector3(9.5, 4.5, 3.0))
	_build.light(Vector3(9.5, 2.3, -6.5))


## The foreman's office over the back of the storeroom: its floor, walls, the window over the factory floor, the desk
## and the filing cabinet.
func _build_office() -> void:
	_build.slab(STOREROOM_X, HALF_X, DOCK_Z, OFFICE_FRONT_Z, OFFICE_TOP, WOOD.darkened(0.2))
	# Below the office the storeroom is closed to the factory floor; above, the window looks over it.
	_wall_box("z", STOREROOM_X, DOCK_Z, OFFICE_FRONT_Z, 0.0, OFFICE_TOP + 0.9, INSIDE)
	_build.box(Vector3(STOREROOM_X, OFFICE_TOP + 1.6, (DOCK_Z + OFFICE_FRONT_Z) / 2), Vector3(0.04, 1.4, OFFICE_FRONT_Z - DOCK_Z), GLASS)
	_wall_box("z", STOREROOM_X, DOCK_Z, OFFICE_FRONT_Z, OFFICE_TOP + 2.3, HALL_TOP, INSIDE)
	_build.wall("x", OFFICE_FRONT_Z, STOREROOM_X, HALF_X, 1, [OFFICE_DOOR_X], INSIDE)
	_wall_box("x", OFFICE_FRONT_Z, STOREROOM_X, HALF_X, OFFICE_TOP - FLOOR_TOP + GameScale.FLOOR_HEIGHT - PlaceBuilder.SLAB, HALL_TOP, INSIDE)
	_build.legs(OFFICE_DESK_AT, Vector2(OFFICE_DESK_SIZE.x, OFFICE_DESK_SIZE.z), OFFICE_DESK_SIZE.y, WOOD)
	_build.box(OFFICE_DESK_AT + Vector3(0, OFFICE_DESK_SIZE.y + 0.03, 0), Vector3(OFFICE_DESK_SIZE.x, 0.06, OFFICE_DESK_SIZE.z), WOOD)
	_build.open_box(FILING_AT, Vector3(0.6, 1.3, 0.6), "-x", STEEL)
	_build.box(FILING_AT + Vector3(0, 0.65, 0), Vector3(0.5, 0.03, 0.5), STEEL)
	_build.box(Vector3(6.4, OFFICE_TOP + 0.3, -8.5), Vector3(0.6, 0.6, 0.6), STEEL.darkened(0.4))
	_build.light(Vector3(10.0, OFFICE_TOP + 2.0, -6.5))


## The porcelain dolls in the showcase and the plaster molds on their table: each one that breaks is a fine.
func _place_fragile() -> void:
	for i in DOLLS:
		var doll: Ornament = DOLL_SCENE.instantiate()
		doll.get_node("Model").free()
		var look: Node3D = DOLL_MODELS[i].instantiate()
		look.name = "Model"
		doll.add_child(look)
		var y := SHOWCASE_AT.y + SHOWCASE_SIZE.y if i < 3 else SHOWCASE_BOARD_Y + 0.015
		doll.position = Vector3(SHOWCASE_AT.x - 0.8 + (i % 3) * 0.8, y + DOLL_HALF_HEIGHT + 0.005, SHOWCASE_AT.z)
		add_child(doll)
		doll.broken.connect(_on_fragile_broken)
		dolls.append(doll)
	for i in MOLDS:
		var mold: Ornament = MOLD_SCENE.instantiate()
		mold.position = MOLD_TABLE_AT + Vector3(-0.9 + i * 0.6, MOLD_TABLE_SIZE.y + 0.03 + MOLD_HALF_HEIGHT + 0.005, -0.25)
		add_child(mold)
		mold.broken.connect(_on_fragile_broken)
		molds.append(mold)


## Rolls the dock's shutter up into the wall, once.
func open_shutter() -> void:
	if shutter_open:
		return
	shutter_open = true
	var up := shutter.position + Vector3.UP * (SHUTTER_SIZE.y - 0.3)
	create_tween().tween_property(shutter, "position", up, SHUTTER_TIME)


## Fermín on his walk along the belt, ready to restart it or clear it, and his complaint meter. A rammed door
## reaches him anywhere.
func _place_fermin() -> void:
	fermin = FERMIN_SCENE.instantiate()
	fermin.route = FERMIN_ROUTE
	fermin.button_spot = BUTTON_SPOT
	for machine: Dictionary in MACHINES:
		fermin.machine_spots[machine.id] = machine.stand
	fermin.belt = belt
	add_child(fermin)
	fermin.start_at(0)
	office_door.broken.connect(fermin.door_broken)
	fermin.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_FACTORY"))
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
	fermin.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Nilda at her machine, and the box cart that packs the dolls reaching the end of the belt.
func _place_nilda() -> void:
	nilda = QuotaWorker.new()
	nilda.name = "Nilda"
	nilda.position = NILDA_AT
	nilda.rotation.y = PI
	add_child(nilda)
	var cart := Area3D.new()
	cart.collision_layer = 0
	cart.collision_mask = 4
	var inside := CollisionShape3D.new()
	var space := BoxShape3D.new()
	space.size = Vector3(1.1, 0.5, 0.8)
	inside.shape = space
	inside.position = BOX_CART_AT + Vector3(0, 0.3, 0)
	cart.add_child(inside)
	add_child(cart)
	cart.body_entered.connect(func(body: Node3D) -> void:
		if body.is_in_group("factory_dolls") and not body.has_meta("packed"):
			body.set_meta("packed", true)
			shipped += 1
			get_tree().create_timer(PACK_DELAY).timeout.connect(body.queue_free))


func _physics_process(delta: float) -> void:
	_feed_left -= delta
	if _feed_left > 0.0 or not belt.is_moving():
		return
	_feed_left = FEED_EVERY
	fed = fed.filter(func(doll: Node3D) -> bool: return is_instance_valid(doll))
	if fed.size() >= MAX_DOLLS:
		return
	var doll: Node3D = BELT_DOLL_SCENE.instantiate()
	doll.position = FEED_AT
	add_child(doll)
	fed.append(doll)
	fed_doll.emit(doll)


func _on_fragile_broken(at: Vector3) -> void:
	broken_goods += 1
	raid.fines += Ornament.FINE
	raid.float_label("-%d" % Ornament.FINE, at, Color(1, 0.3, 0.25))
	if fermin:
		fermin.saw(at, Foreman.SAW_BREAK)
