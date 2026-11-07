class_name PizzaRaid
extends Node3D

## The pizzeria "Don Muzza" as a place to raid (docs/diseno/allanamiento-pizzeria.md, step 2): one floor on its lot in
## the city, with the front to +Z and the back yard behind. The dining room at the front, with the counter (the phone,
## the stacks of plates, the tray of slices and the tower of pizza boxes on it), the tables and the drinks fridge; at
## the back the kitchen with the clay oven, the dough table and the flour sacks, and Don Muzza's office with the cold
## room behind it, locked. Behind the kitchen, the yard with the three new delivery scooters and the bin. Each plate
## that breaks counts; a flour sack that bursts leaves a white patch, and a cop who walks through it leaves white
## footprints (FlourPrints, like in the cake lab). SPOTS are the 12 hiding spots the stories draw from (step 5). Don
## Muzza walks the dining room and the kitchen singing (step 3): he fills the complaint ("¡Me arruinaron la masa!")
## with every plate he sees break and every floured cop he sees, and the phone on the counter sends him to the dough
## table to make an order, his back to the kitchen. Tito waits on his bench in the yard and talks for a slice from the
## counter's tray (step 4), and what stays in the clay oven's mouth burns (PizzaOven): Don Muzza minds seeing anyone
## put something in. The case is one of its stories (STORIES), drawn with the seed, run by the same RaidCase as the
## other places (step 5). Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const SACK_SCENE := preload("res://scenes/props/lab_flour_sack.tscn")
const OVEN_MODEL := preload("res://assets/models/clay_oven.glb")
const DOUGH_TABLE_MODEL := preload("res://assets/models/dough_table.glb")
const DOUGH_MODEL := preload("res://assets/models/dough_ball.glb")
const SLICE_MODEL := preload("res://assets/models/pizza_slice.glb")
const PLATE_MODEL := preload("res://assets/models/kitchen_plate.glb")
const BOX_MODEL := preload("res://assets/models/pizza_box.glb")
const SCOOTER_MODEL := preload("res://assets/models/pizza_scooter.glb")
const MUZZA_SCENE := preload("res://scenes/npc/pizza_muzza.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the pizzeria can be suspected of (allanamiento-pizzeria.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["jewels", "crazy_yeast", "oven_tunnel", "phone_backpack", "plastic_cheese", "giant_pizza"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_PIZZA_TIP_B", "BRIEF_TIP_C", "BRIEF_PIZZA_TIP_D",
	"BRIEF_PIZZA_TIP_E"]
## The stories the pizzeria can tell, like GymRaid.STORIES: what the comisario says once it's guessed, its "find it"
## row, what it hides in spots drawn with the seed (with their half heights and whether they're heavy; the first one
## is the main evidence), the checklist rows of its extras and its rig.
const STORIES := {
	"jewels": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_JEWELS_B", "BRIEF_JEWELS_C", "BRIEF_JEWELS_D"],
		"find": "OBJ_FIND_FROZEN_JEWELS",
		"hidden": [preload("res://scenes/props/frozen_pizza_jewels.tscn"),
			preload("res://scenes/props/pizza_jeweler_loupe.tscn"), preload("res://scenes/props/special_clients_list.tscn")],
		"half_heights": [0.06, 0.02, 0.003],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_JEWELER_LOUPE", "OBJ_EXTRA_SPECIAL_CLIENTS"],
		"rig": preload("res://scripts/case/pizza/jewels_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the floor of the dining room, the kitchen, the office and the yard, away from
## the furniture.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(0.0, FLOOR_TOP, 3.0), Vector3(3.3, FLOOR_TOP, 5.8), Vector3(-6.0, FLOOR_TOP, 6.0),
	Vector3(-1.0, FLOOR_TOP, -3.2), Vector3(4.0, FLOOR_TOP, 1.2), Vector3(1.0, FLOOR_TOP, -6.5),
]
const HALF_X := 8.0
const HALF_Z := 8.0
const WALL_TOP := 3.2
const BUILDING_TOP := 4.0
const FLOOR_TOP := 0.06
const ENTRANCE_WIDTH := 2.0
const OPENING_WIDTH := 1.4
## The building's back wall: the yard is behind it, open to the sky, with a low fence.
const YARD_Z := -4.0
const FENCE_TOP := 1.2
const BACK_DOOR_X := 0.0
## The dining room's back wall, with the openings to the kitchen and to the office.
const DINING_Z := 2.0
const KITCHEN_OPENING_X := -3.0
const OFFICE_OPENING_X := 5.0
## The wall between the kitchen (west) and the office and the cold room (east), and the cold room's wall behind the
## office, with its locked door.
const KITCHEN_X := 2.0
const COLD_Z := -1.0
const COLD_DOOR_X := 5.0
const COUNTER_AT := Vector3(-4.5, FLOOR_TOP, 3.3)
const COUNTER_SIZE := Vector3(4.0, 1.0, 0.8)
const PHONE_AT := Vector3(-6.1, FLOOR_TOP + 1.0, 3.35)
const TRAY_AT := Vector3(-5.3, FLOOR_TOP + 1.0, 3.3)
const TOWER_AT := Vector3(-2.9, FLOOR_TOP + 1.0, 3.3)
const TOWER_BOXES := 8
## The stacks of plates on the counter: each plate that breaks counts (Don Muzza minds it, step 3).
const PLATE_STACKS: Array[Vector3] = [Vector3(-4.6, FLOOR_TOP + 1.0, 3.3), Vector3(-3.9, FLOOR_TOP + 1.0, 3.3)]
const PLATES_PER_STACK := 5
## A plate's collision is thicker than its model: thin boxes in a stack sink into each other and break.
const PLATE_HEIGHT := 0.05
const TABLES: Array[Vector3] = [Vector3(1.5, FLOOR_TOP, 4.6), Vector3(5.0, FLOOR_TOP, 4.6), Vector3(1.5, FLOOR_TOP, 7.0),
	Vector3(5.0, FLOOR_TOP, 7.0)]
const TABLE_SIZE := Vector3(1.0, 0.75, 1.0)
const FRIDGE_AT := Vector3(7.5, FLOOR_TOP, 3.2)
const FRIDGE_SIZE := Vector3(0.7, 1.8, 1.0)
const TRUNK_AT := Vector3(-7.2, FLOOR_TOP, 7.2)
const TRUNK_SIZE := Vector3(1.0, 0.5, 0.6)
const OVEN_AT := Vector3(-5.5, FLOOR_TOP, -2.8)
const OVEN_SIZE := Vector3(1.6, 1.7, 1.6)
## The oven's mouth, where what is put in burns (step 4).
const OVEN_MOUTH := Vector3(-5.5, FLOOR_TOP + 1.175, -2.3)
const WOODBOX_AT := Vector3(-3.4, FLOOR_TOP, -3.5)
const WOODBOX_SIZE := Vector3(0.9, 0.5, 0.6)
const DOUGH_TABLE_AT := Vector3(-3.0, FLOOR_TOP, -0.3)
const DOUGH_TABLE_SIZE := Vector3(2.0, 0.9, 0.9)
const SACK_X := -7.4
const SACKS_ALONG: Array[float] = [-2.4, -1.4, -0.4, 0.6]
const DESK_AT := Vector3(3.6, FLOOR_TOP, 0.0)
const DESK_SIZE := Vector3(1.6, 0.75, 0.7)
const WARDROBE_AT := Vector3(7.5, FLOOR_TOP, 0.5)
const WARDROBE_SIZE := Vector3(0.6, 1.9, 1.4)
const COLD_SHELF_AT := Vector3(7.5, FLOOR_TOP, -2.5)
const COLD_SHELF_SIZE := Vector3(0.6, 1.8, 2.0)
const SCOOTERS: Array[Vector3] = [Vector3(3.0, FLOOR_TOP, -6.0), Vector3(5.0, FLOOR_TOP, -6.0), Vector3(7.0, FLOOR_TOP, -6.0)]
const BIN_AT := Vector3(-6.8, FLOOR_TOP, -6.8)
const BIN_SIZE := Vector3(0.6, 0.9, 0.6)
## Where Tito waits on his bench in the yard (step 4).
const BENCH_AT := Vector3(-3.0, FLOOR_TOP, -7.4)
const BENCH_SIZE := Vector3(1.6, 0.45, 0.45)
## Don Muzza's round, back and forth from the dining room's tables, past the counter, to the kitchen and the oven.
const MUZZA_ROUTE: Array[Vector3] = [Vector3(6.0, FLOOR_TOP, 5.8), Vector3(-2.0, FLOOR_TOP, 5.8),
	Vector3(-2.0, FLOOR_TOP, 2.5), Vector3(-3.0, FLOOR_TOP, 2.3), Vector3(-3.0, FLOOR_TOP, 1.0),
	Vector3(-1.3, FLOOR_TOP, 0.6), Vector3(-1.3, FLOOR_TOP, -1.5), Vector3(-5.0, FLOOR_TOP, -1.4)]
## Where he makes a phoned-in order: behind the dough table, facing the dining room, his back to the oven and sacks.
const ORDER_SPOT := Vector3(-3.0, FLOOR_TOP, -1.2)
const ORDER_TIME := 20.0
## Seeing a plate break, and a floured cop.
const SAW_PLATE := 2.0
const SAW_FLOURED := 5.0
const SAW_OVEN := 10.0
## The oven's brick base, and the dome behind its mouth: the mouth is the ledge on the base, in front of the dome.
const OVEN_BASE := 0.95
const OVEN_LEDGE := 0.6
## The slices on the counter's tray, and where Tito waits (in front of his bench, facing the back door).
const SLICES := 3
const TITO_AT := BENCH_AT + Vector3(0, 0, 0.55)

const OUTSIDE := Color(0.82, 0.32, 0.22)
const CREAM := Color(0.96, 0.9, 0.78)
const TILE := Color(0.92, 0.9, 0.86)
const FLOOR := Color(0.7, 0.42, 0.3)
const YARD := Color(0.62, 0.6, 0.56)
const WOOD := Color(0.62, 0.45, 0.3)
const GREEN := Color(0.3, 0.6, 0.35)
const STEEL := Color(0.74, 0.77, 0.8)
const GLASS := Color(0.6, 0.8, 0.9, 0.35)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "pizza_under_counter", "at": COUNTER_AT + Vector3(1.0, 0.0, -0.75), "heavy": true},
	{"id": "pizza_behind_oven", "at": Vector3(-6.9, FLOOR_TOP, -3.5), "heavy": true},
	{"id": "pizza_in_cold_room", "at": Vector3(4.0, FLOOR_TOP, -3.0), "heavy": true},
	{"id": "pizza_under_dough_table", "at": DOUGH_TABLE_AT + Vector3(0.0, 0.22, 0.0), "heavy": true},
	{"id": "pizza_in_flour_pile", "at": Vector3(-6.7, FLOOR_TOP, -0.9), "heavy": true},
	{"id": "pizza_on_scooter_box", "at": SCOOTERS[2] + Vector3(0.0, 1.6, -0.95), "heavy": true},
	{"id": "pizza_in_wardrobe", "at": WARDROBE_AT + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "pizza_in_drinks_fridge", "at": FRIDGE_AT + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "pizza_in_firewood_box", "at": WOODBOX_AT + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "pizza_in_tablecloth_trunk", "at": TRUNK_AT + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "pizza_in_yard_bin", "at": BIN_AT + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "pizza_in_box_tower", "at": TOWER_AT + Vector3(0.0, TOWER_BOXES * 0.05 + 0.02, 0.0), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var cold_door: FrontDoor
var plates: Array[StackedPlate] = []
var sacks: Array[FlourSack] = []
var flour: FlourPrints
var broken_plates := 0
var burst_sacks := 0
## The case flow every raid shares.
var raid: RaidCase
## Same seed, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: PizzaRaidRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## The boxes of the counter's tower, bottom to top (the jewels story lifts them).
var tower_boxes: Array[Node3D] = []
var muzza: FloorBoss
var phone: PizzaPhone
var complaint_bar: ProgressBar
## Floured cops Don Muzza already saw (until the flour wears off).
var _seen_floured := {}
var oven: PizzaOven
var tito: PizzaTito
var slices: Array[Grabbable] = []
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
	flour = FlourPrints.new()
	add_child(flour)
	_build_shell()
	_build_dining_room()
	_build_kitchen()
	_build_office()
	_build_yard()
	_place_plates()
	_place_sacks()
	cold_door = _door(Vector3(COLD_DOOR_X, FLOOR_TOP, COLD_Z))
	_place_muzza()
	_place_tito()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("pizzeria")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "pizzeria", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = muzza
	raid.owner_id = "pizzeria"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The pizzeria's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_PIZZA",
		"guess_key": "OBJ_GUESS_PIZZA",
		"broken_key": "OBJ_BROKEN_PIZZA",
		"complaint_key": "OBJ_COMPLAINT_PIZZA",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_plates,
		"complaint": muzza.complaint,
	}


## Online, what the guests' pizzeria takes from the host's (RaidCase.snapshot): what the story's rig decides on the
## host.
func net_state() -> Dictionary:
	return {"rig": rig.net_state() if rig else null}


func apply_net_state(state: Dictionary) -> void:
	if rig and state.rig != null:
		rig.apply_net_state(state.rig)


## The story with that id from --story=<id> among the user args, or one drawn from the seed.
static func pick_story(seed_value: int, args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with("--story=") and STORIES.has(arg.trim_prefix("--story=")):
			return arg.trim_prefix("--story=")
	return STORIES.keys()[seed_value % STORIES.size()]


## The story's hidden items, each in a spot drawn with the seed (heavy ones only where they fit). The first is the
## main evidence.
func _place_hidden() -> void:
	var story: Dictionary = STORIES[story_id]
	var spot_heavy: Array = SPOTS.map(func(spot: Dictionary) -> bool: return spot.heavy)
	hidden_spots = HidingDraw.draw(case_seed, spot_heavy, story.heavy, 1).spots
	for i in story.hidden.size():
		var item: Evidence = story.hidden[i].instantiate()
		item.position = SPOTS[hidden_spots[i]].at + Vector3.UP * (story.half_heights[i] + 0.01)
		add_child(item)
		hidden.append(item)
	main = hidden[0]
	extras.assign(hidden.slice(1))


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


## What Don Muzza lets slip when asked (where the story's things are, in an order drawn from the seed), and what Tito
## saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		muzza.slips.append(tr("MUZZA_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	muzza.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	tito.clue = tr("CLUE_TITO") % where
	tito.clue_speech = tr("TITO_CLUE_" + story_id) % where
	tito.told.connect(raid.add_clue)


## Red brick walls, the shop window with the entrance, the ceiling, the roof and the sign; behind, the yard's floor.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, YARD_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, YARD_Z, FLOOR_TOP, YARD)
	_build.slab(-HALF_X, HALF_X, YARD_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, CREAM)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.0, 1.0, OUTSIDE)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.0, 1.0, OUTSIDE)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 1.0, 2.6, GLASS)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 1.0, 2.6, GLASS)
	_wall_box("x", HALF_Z, -HALF_X, HALF_X, 2.6, WALL_TOP, OUTSIDE)
	_wall("x", YARD_Z, -HALF_X, HALF_X, [Vector3(BACK_DOOR_X, OPENING_WIDTH, 2.4)], OUTSIDE)
	_wall("z", -HALF_X, YARD_Z, HALF_Z, [], OUTSIDE)
	_wall("z", HALF_X, YARD_Z, HALF_Z, [], OUTSIDE)
	var roof := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	var depth := HALF_Z - YARD_Z
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + roof / 2, (HALF_Z + YARD_Z) / 2), Vector3(HALF_X * 2, roof, depth),
		OUTSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_PIZZERIA"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.modulate = Color(1.0, 0.86, 0.3)
	sign_label.position = Vector3(0, WALL_TOP + 0.4, HALF_Z + 0.08)
	$Built.add_child(sign_label)


## The dining room: the counter with the phone, the tray of slices and the tower of boxes, the tables, the drinks
## fridge and the trunk of tablecloths.
func _build_dining_room() -> void:
	var openings: Array = [Vector3(KITCHEN_OPENING_X, OPENING_WIDTH * 1.2, 2.4), Vector3(OFFICE_OPENING_X, OPENING_WIDTH, 2.4)]
	_wall("x", DINING_Z, -HALF_X, HALF_X, openings, CREAM)
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", WOOD)
	phone = PizzaPhone.new()
	phone.position = PHONE_AT
	add_child(phone)
	_build.mesh_box(TRAY_AT + Vector3(0, 0.01, 0), Vector3(0.5, 0.02, 0.36), STEEL)
	for i in TOWER_BOXES:
		tower_boxes.append(_model(BOX_MODEL, TOWER_AT + Vector3(0, i * 0.05, 0), i * 0.25))
	var tower := _build.body(TOWER_AT + Vector3(0, TOWER_BOXES * 0.025, 0))
	_build.shape(tower, Vector3(0.4, TOWER_BOXES * 0.05, 0.4))
	for at: Vector3 in TABLES:
		_table(at, TABLE_SIZE, WOOD.darkened(0.2), Color(0.9, 0.25, 0.2))
		for side: float in [-1.0, 1.0]:
			_build.box(at + Vector3(side * 0.85, 0.23, 0), Vector3(0.4, 0.46, 0.4), GREEN)
	_build.open_box(FRIDGE_AT, FRIDGE_SIZE, "-x", STEEL)
	_build.mesh_box(FRIDGE_AT + Vector3(-FRIDGE_SIZE.x / 2, FRIDGE_SIZE.y / 2, 0), Vector3(0.02, FRIDGE_SIZE.y - 0.1,
		FRIDGE_SIZE.z - 0.1), GLASS)
	_build.open_box(TRUNK_AT, TRUNK_SIZE, "top", WOOD.darkened(0.3))
	_build.light(Vector3(-4.0, 2.9, 5.0))
	_build.light(Vector3(3.5, 2.9, 5.5))


## The kitchen: the clay oven against the back wall with its box of firewood, the dough table and the flour sacks.
func _build_kitchen() -> void:
	_wall("z", KITCHEN_X, YARD_Z, DINING_Z, [], TILE)
	_model(OVEN_MODEL, OVEN_AT)
	var base := _build.body(OVEN_AT + Vector3(0, OVEN_BASE / 2, 0))
	_build.shape(base, Vector3(OVEN_SIZE.x, OVEN_BASE, OVEN_SIZE.z))
	var dome_height := OVEN_SIZE.y - OVEN_BASE
	var dome := _build.body(OVEN_AT + Vector3(0, OVEN_BASE + dome_height / 2, -OVEN_LEDGE / 2))
	_build.shape(dome, Vector3(OVEN_SIZE.x, dome_height, OVEN_SIZE.z - OVEN_LEDGE))
	oven = PizzaOven.new()
	oven.position = OVEN_MOUTH
	add_child(oven)
	_build.open_box(WOODBOX_AT, WOODBOX_SIZE, "top", WOOD.darkened(0.2))
	_model(DOUGH_TABLE_MODEL, DOUGH_TABLE_AT)
	var table := _build.body(DOUGH_TABLE_AT + Vector3(0, DOUGH_TABLE_SIZE.y - 0.03, 0))
	_build.shape(table, Vector3(DOUGH_TABLE_SIZE.x, 0.06, DOUGH_TABLE_SIZE.z))
	for x: float in [-0.6, -0.25, 0.1]:
		_model(DOUGH_MODEL, DOUGH_TABLE_AT + Vector3(x, DOUGH_TABLE_SIZE.y, -0.2))
	_build.light(Vector3(-5.0, 2.9, -2.0))
	_build.light(Vector3(-1.0, 2.9, 0.0))


## Don Muzza's office (desk and wardrobe) and the locked cold room behind it, with its shelf.
func _build_office() -> void:
	_wall("x", COLD_Z, KITCHEN_X, HALF_X, [Vector3(COLD_DOOR_X, GameScale.DOOR_WIDTH, 2.4)], TILE)
	_table(DESK_AT, DESK_SIZE, WOOD.darkened(0.2), WOOD)
	_build.open_box(WARDROBE_AT, WARDROBE_SIZE, "-x", WOOD)
	_build.open_box(COLD_SHELF_AT, COLD_SHELF_SIZE, "-x", STEEL)
	_build.light(Vector3(5.0, 2.9, 0.5))
	_build.light(Vector3(5.0, 2.9, -2.5))


## The yard: a low fence around it, the three new scooters, the bin and Tito's bench.
func _build_yard() -> void:
	_wall_box("x", -HALF_Z, -HALF_X, HALF_X, 0.0, FENCE_TOP, CREAM.darkened(0.2))
	_wall_box("z", -HALF_X, -HALF_Z, YARD_Z, 0.0, FENCE_TOP, CREAM.darkened(0.2))
	_wall_box("z", HALF_X, -HALF_Z, YARD_Z, 0.0, FENCE_TOP, CREAM.darkened(0.2))
	for at: Vector3 in SCOOTERS:
		_model(SCOOTER_MODEL, at)
		var scooter := _build.body(at + Vector3(0, 0.4, 0))
		_build.shape(scooter, Vector3(0.45, 0.8, 1.6))
		var box := _build.body(at + Vector3(0, 1.16, -0.95))
		_build.shape(box, Vector3(1.1, 0.8, 0.8))
	_build.open_box(BIN_AT, BIN_SIZE, "top", GREEN.darkened(0.3))
	_build.box(BENCH_AT + Vector3(0, BENCH_SIZE.y / 2, 0), BENCH_SIZE, WOOD)
	_build.light(Vector3(0.0, 2.6, -6.0))


## The stacks of plates on the counter: each plate that breaks counts.
func _place_plates() -> void:
	for stack: Vector3 in PLATE_STACKS:
		var stacked: Array[StackedPlate] = []
		for i in PLATES_PER_STACK:
			var plate := StackedPlate.new()
			plate.mass = 0.4
			plate.collision_layer = 4
			plate.collision_mask = 15
			plate.freeze = true
			var shape := CollisionShape3D.new()
			var box := BoxShape3D.new()
			box.size = Vector3(0.34, PLATE_HEIGHT, 0.34)
			shape.shape = box
			plate.add_child(shape)
			plate.add_child(PLATE_MODEL.instantiate())
			plate.position = stack + Vector3(0, PLATE_HEIGHT / 2 + 0.002 + i * (PLATE_HEIGHT + 0.004), 0)
			add_child(plate)
			plates.append(plate)
			stacked.append(plate)
			plate.grabbed.connect(_wake_stack.bind(stacked))
			plate.broken.connect(func(at: Vector3) -> void:
				plates.erase(plate)
				broken_plates += 1
				if muzza:
					muzza.saw(at, SAW_PLATE, "MUZZA_PLATE"))
		var reach := Area3D.new()
		reach.collision_layer = 0
		reach.collision_mask = 6
		var zone := CollisionShape3D.new()
		var zone_box := BoxShape3D.new()
		zone_box.size = Vector3(0.6, PLATES_PER_STACK * (PLATE_HEIGHT + 0.004) + 0.2, 0.6)
		zone.shape = zone_box
		reach.add_child(zone)
		reach.position = stack + Vector3.UP * zone_box.size.y / 2
		add_child(reach)
		reach.body_entered.connect(func(body: Node3D) -> void:
			if not body is StackedPlate:
				_wake_stack(stacked))


## Something reached a stack of plates: they fall like plates do.
func _wake_stack(stacked: Array[StackedPlate]) -> void:
	for plate in stacked:
		if is_instance_valid(plate):
			plate.freeze = false


## The flour sacks in a row against the kitchen's west wall: a burst one leaves a white patch on the floor.
func _place_sacks() -> void:
	for z: float in SACKS_ALONG:
		var sack: FlourSack = SACK_SCENE.instantiate()
		sack.position = Vector3(SACK_X, FLOOR_TOP + 0.185, z)
		add_child(sack)
		sacks.append(sack)
		sack.burst.connect(func(at: Vector3) -> void:
			sacks.erase(sack)
			burst_sacks += 1
			flour.spill(at))


func _physics_process(_delta: float) -> void:
	# Online the host's Don Muzza minds the flour; the guests' one only follows.
	if muzza and multiplayer.is_server():
		_watch_flour()


## Don Muzza on his round, his orders at the phone, what he notices and the complaint bar.
func _place_muzza() -> void:
	muzza = MUZZA_SCENE.instantiate()
	muzza.route = MUZZA_ROUTE
	muzza.printer_spot = ORDER_SPOT
	muzza.printer = phone
	muzza.fix_time = ORDER_TIME
	add_child(muzza)
	muzza.fix_facing = to_global(ORDER_SPOT + Vector3(0, 0, 3.0))
	muzza.start_at(0)
	cold_door.broken.connect(muzza.door_broken)
	muzza.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_PIZZA"))
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
	muzza.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Tito by his bench, and the slices on the tray he'd talk for.
func _place_tito() -> void:
	for i in SLICES:
		var slice := ClubEvidence.make_item("Slice%d" % (i + 1), SLICE_MODEL, Vector3(0.12, 0.03, 0.2), 0.15)
		slice.add_to_group(PizzaTito.SLICE_GROUP)
		slice.position = TRAY_AT + Vector3(-0.14 + i * 0.14, 0.04, 0.0)
		slice.rotation.y = PI if i % 2 else 0.0
		add_child(slice)
		slices.append(slice)
	tito = PizzaTito.new()
	tito.name = "Tito"
	tito.position = TITO_AT
	add_child(tito)
	oven.fed.connect(func(_item: Grabbable) -> void:
		muzza.saw(oven.global_position, SAW_OVEN, "MUZZA_OVEN"))


## Every floured cop that Don Muzza sees, once until the flour wears off.
func _watch_flour() -> void:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if not flour.is_floured(cop):
			_seen_floured.erase(cop)
		elif not _seen_floured.has(cop) and muzza.saw(cop.global_position + Vector3.UP * 0.8, SAW_FLOURED,
				"MUZZA_FLOUR"):
			_seen_floured[cop] = true


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
