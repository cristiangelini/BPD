class_name IceCreamShop
extends Node3D

## The "Heladería Pingüino Derretido" as a place to raid (docs/diseno/allanamiento-heladeria.md, step 1): a one-floor
## neighborhood ice cream shop on its lot in the city, the front to +Z, with the fiberglass penguin on the sidewalk by
## the door. The salon has the counter with the 12 flavors, the till, two freezers and the tables; behind it, the
## kitchen with the soft-serve machine, two more freezers and the cold room (locked with the till's key), the owner's
## office and the bathroom. The kitchen's back door opens to the fenced yard with the ice cream truck. Something thrown
## hard at the counter's glass case cracks it (a fine), and at the penguin knocks it over. Whatever is left open melts
## (step 2): a freezer's lid open IceFreezer.MELT_AFTER seconds, or the cold room's door open COLD_MELT_AFTER seconds,
## leaves a slippery puddle (IcePuddle) and a fine. Doña Nieve minds the counter and goes to the cold room now and
## then, filling the complaint; E on the soft-serve machine jams it and she fights it, her back to everything (step 3).
## Lucho the delivery boy rides up to the door now and then: a cone from the dispenser on the till's desk buys what he
## saw (step 4). The case is one of its stories (STORIES), drawn with the seed, run by the same RaidCase as the other
## places (step 5). Every number here is (propuesta).

signal case_cracked
signal penguin_knocked
signal freezer_melted(index: int)
signal cold_room_melted

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const COUNTER_MODEL := preload("res://assets/models/ice_counter.glb")
const NIEVE_SCENE := preload("res://scenes/npc/dona_nieve.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the shop can be suspected of (allanamiento-heladeria.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["stolen_flavors", "frozen_smuggling", "rigged_scale", "rigged_sticks", "frozen_cash",
	"stolen_truck"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_ICE_TIP_B", "BRIEF_TIP_C", "BRIEF_ICE_TIP_D",
	"BRIEF_ICE_TIP_E"]
## The stories the shop can tell, like RadioStation.STORIES: what the comisario says once it's guessed, its "find it"
## row, what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist
## rows of its extras and its rig. The first hidden item is the main evidence and the rest extras.
const STORIES := {
	"stolen_flavors": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_STOLEN_FLAVORS_B", "BRIEF_STOLEN_FLAVORS_C", "BRIEF_STOLEN_FLAVORS_D"],
		"find": "OBJ_FIND_RECIPE_BOX",
		"hidden": [preload("res://scenes/props/recipe_box.tscn"), preload("res://scenes/props/secret_jar.tscn"),
			preload("res://scenes/props/rival_photo.tscn")],
		"half_heights": [0.125, 0.1, 0.04],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_SECRET_JAR", "OBJ_EXTRA_RIVAL_PHOTO"],
		"rig": preload("res://scripts/case/ice_cream/stolen_flavors_rig.gd"),
	},
	"frozen_smuggling": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FROZEN_SMUGGLING_B", "BRIEF_FROZEN_SMUGGLING_C", "BRIEF_FROZEN_SMUGGLING_D"],
		"find": "OBJ_FIND_ICE_BLOCK",
		"hidden": [preload("res://scenes/props/ice_block_watches.tscn"),
			preload("res://scenes/props/ice_delivery_list.tscn"), preload("res://scenes/props/fake_stamp.tscn")],
		"half_heights": [0.2, 0.04, 0.06],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_DELIVERY_LIST", "OBJ_EXTRA_FAKE_STAMP_ICE"],
		"rig": preload("res://scripts/case/ice_cream/frozen_smuggling_rig.gd"),
	},
	"rigged_scale": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_RIGGED_SCALE_B", "BRIEF_RIGGED_SCALE_C", "BRIEF_RIGGED_SCALE_D"],
		"find": "OBJ_FIND_ICE_SCALE",
		"hidden": [preload("res://scenes/props/ice_scale.tscn"), preload("res://scenes/props/scale_magnet.tscn"),
			preload("res://scenes/props/complaints_notebook.tscn")],
		"half_heights": [0.15, 0.03, 0.04],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_SCALE_MAGNET", "OBJ_EXTRA_COMPLAINTS_NOTEBOOK"],
		"rig": preload("res://scripts/case/ice_cream/rigged_scale_rig.gd"),
	},
	"rigged_sticks": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_RIGGED_STICKS_B", "BRIEF_RIGGED_STICKS_C", "BRIEF_RIGGED_STICKS_D"],
		"find": "OBJ_FIND_PRIZE_STICKS",
		"hidden": [preload("res://scenes/props/prize_sticks.tscn"), preload("res://scenes/props/stick_engraver.tscn"),
			preload("res://scenes/props/ice_winners_list.tscn")],
		"half_heights": [0.1, 0.125, 0.04],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_STICK_ENGRAVER", "OBJ_EXTRA_ICE_WINNERS_LIST"],
		"rig": preload("res://scripts/case/ice_cream/rigged_sticks_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the salon's floor, behind the counter, in the kitchen, the office and the
## yard.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(1.0, FLOOR_TOP, 7.6), Vector3(7.0, FLOOR_TOP, 4.0), Vector3(-6.0, FLOOR_TOP, 3.2),
	Vector3(-3.0, FLOOR_TOP, -2.0), Vector3(1.5, FLOOR_TOP, -1.0), Vector3(-2.0, FLOOR_TOP, -7.0),
]
const SHELF_MODEL := preload("res://assets/models/cold_shelf.glb")
const PENGUIN_MODEL := preload("res://assets/models/penguin_statue.glb")
const TRUCK_MODEL := preload("res://assets/models/ice_cream_truck.glb")
const WHEEL_MODEL := preload("res://assets/models/car_wheel.glb")
## The lot; the building goes from BACK_WALL_Z to FRONT_WALL_Z, the yard behind it and the sidewalk strip in front.
const HALF_X := 10.0
const HALF_Z := 10.0
const FRONT_WALL_Z := 8.5
const BACK_WALL_Z := -5.0
const FLOOR_TOP := 0.06
const WALL_TOP := GameScale.FLOOR_HEIGHT - PlaceBuilder.SLAB
const ROOF_TOP := GameScale.FLOOR_HEIGHT
const ENTRANCE_X := 3.0
## The wall between the salon (z > SALON_Z) and the rooms behind it, with the kitchen's, the office's and the
## bathroom's doors; the walls between those rooms.
const SALON_Z := 2.0
const KITCHEN_DOOR_X := -4.0
const OFFICE_DOOR_X := 2.5
const BATH_DOOR_X := 8.5
const KITCHEN_X1 := 0.0
const BATH_X0 := 5.0
## The cold room in the kitchen's back corner, behind its locked door, and the kitchen's back door to the yard.
const COLD_X1 := -5.5
const COLD_Z1 := -1.0
const COLD_DOOR_X := -7.75
const BACK_DOOR_X := -1.5
## The counter (customers on its +Z side), the cashier's desk with the till next to it, and the soft-serve machine.
const COUNTER_AT := Vector3(-4.0, FLOOR_TOP, 4.6)
const COUNTER_SIZE := Vector3(5.0, 1.0, 0.94)
const CASHIER_AT := Vector3(-0.8, FLOOR_TOP, 4.6)
const CASHIER_SIZE := Vector3(1.2, 1.0, 0.9)
const MACHINE_AT := Vector3(-1.0, FLOOR_TOP, 1.5)
## The four freezers, each standing at `at` turned `turn` (their lids hinge on their back, -Z before the turn).
const FREEZERS := [
	{"at": Vector3(-8.5, FLOOR_TOP, 2.9), "turn": 0.0},
	{"at": Vector3(6.4, FLOOR_TOP, 2.9), "turn": 0.0},
	{"at": Vector3(-0.5, FLOOR_TOP, -0.6), "turn": -PI / 2},
	{"at": Vector3(-0.5, FLOOR_TOP, -2.6), "turn": -PI / 2},
]
const SHELVES: Array[Vector3] = [Vector3(-8.9, FLOOR_TOP, -4.6), Vector3(-6.9, FLOOR_TOP, -4.6)]
const SHELF_SIZE := Vector3(2.0, 2.2, 0.6)
## The penguin on the sidewalk strip, and the truck in the yard, its front to +X.
const PENGUIN_AT := Vector3(6.5, FLOOR_TOP, 9.3)
const TRUCK_AT := Vector3(3.5, 0.0, -7.6)
## How fast a prop must hit to crack the counter's glass case or knock the penguin over, and the case's fine.
const CASE_SPEED := 3.0
## Doña Nieve's round, back and forth: behind the counter, through the kitchen's door, to the cold room's door and
## into it. Where she fights the machine (in front of it, facing it), how long, and how long she minds the counter.
const NIEVE_ROUTE: Array[Vector3] = [
	Vector3(-4.5, FLOOR_TOP, 3.3), Vector3(KITCHEN_DOOR_X, FLOOR_TOP, 0.8), Vector3(COLD_DOOR_X, FLOOR_TOP, 0.0),
	Vector3(COLD_DOOR_X, FLOOR_TOP, -3.0),
]
const MACHINE_SPOT := Vector3(-1.0, FLOOR_TOP, 0.6)
const MACHINE_TIME := 25.0
const COUNTER_PAUSE := 90.0
## What she sees melt or break, the penguin falling (she hears it) and the machine once she knows the trick.
const SAW_FREEZER := 5.0
const SAW_COLD_ROOM := 10.0
const SAW_CASE := 10.0
const PENGUIN := 10.0
const NOTICED := 10.0
## She opens the cold room's door when this close to it and shuts it again once past; the machine's spill.
const DOOR_REACH := 2.0
const SPILL_AT := Vector3(-2.0, FLOOR_TOP, 0.6)
const SPILL := Vector2(1.6, 1.4)
## Where Lucho stops by the door, on the sidewalk strip, and where he rides in from and back to.
const LUCHO_DOOR := Vector3(ENTRANCE_X - 1.6, FLOOR_TOP, 9.3)
const LUCHO_AWAY := Vector3(-12.0, FLOOR_TOP, 9.3)
const CASE_FINE := 30
const PENGUIN_SPEED := 3.0
## What melting costs: each freezer, and the whole cold room when its door stays open COLD_MELT_AFTER seconds; the
## puddles they leave (the freezer's in front of it, the cold room's out its door).
const FREEZER_FINE := 10
const COLD_FINE := 30
const COLD_MELT_AFTER := 20.0
const FREEZER_PUDDLE := Vector2(3.0, 3.0)
## What melts in each freezer: its puddle's color (chocolate, strawberry, vanilla and pistachio).
const FREEZER_FLAVORS: Array[Color] = [Color(0.42, 0.24, 0.14, 0.9), Color(0.98, 0.55, 0.68, 0.9),
	Color(1.0, 0.94, 0.72, 0.9), Color(0.6, 0.82, 0.45, 0.9)]
const COLD_PUDDLE := Vector2(3.0, 2.4)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "behind_ice_counter", "at": Vector3(-4.0, FLOOR_TOP, 3.4), "heavy": true},
	{"id": "in_ice_cold_room", "at": Vector3(-7.9, FLOOR_TOP, -3.4), "heavy": true},
	{"id": "behind_ice_desk", "at": Vector3(3.6, FLOOR_TOP, -4.3), "heavy": true},
	{"id": "in_ice_bathroom", "at": Vector3(8.6, FLOOR_TOP, -1.5), "heavy": true},
	{"id": "behind_ice_truck", "at": Vector3(3.5, FLOOR_TOP, -9.3), "heavy": true},
	{"id": "among_yard_buckets", "at": Vector3(-6.5, FLOOR_TOP, -8.0), "heavy": true},
	{"id": "on_ice_cold_shelf", "at": Vector3(-6.9, FLOOR_TOP + 2.2, -4.6), "heavy": false},
	{"id": "on_soft_machine", "at": Vector3(-1.0, FLOOR_TOP + 1.7, 1.5), "heavy": false},
	{"id": "under_ice_table", "at": Vector3(8.0, FLOOR_TOP, 7.0), "heavy": false},
	{"id": "on_kitchen_bench", "at": Vector3(-3.4, FLOOR_TOP + 0.9, -4.6), "heavy": false},
	{"id": "under_flavor_board", "at": Vector3(3.8, FLOOR_TOP, 2.4), "heavy": false},
	{"id": "on_ice_cashier", "at": Vector3(-0.5, FLOOR_TOP + 1.0, 4.6), "heavy": false},
]

const OUTSIDE := Color(0.98, 0.84, 0.9)
const TILE := Color(0.92, 0.9, 0.86)
const CHECKER := Color(0.3, 0.6, 0.75)
const WALL_IN := Color(0.96, 0.94, 0.88)
const MINT := Color(0.6, 0.88, 0.78)
const CONCRETE := Color(0.62, 0.62, 0.6)
const WOOD := Color(0.6, 0.42, 0.28)
const STEEL := Color(0.72, 0.74, 0.78)
const PINK := Color(0.95, 0.45, 0.62)
const COLD := Color(0.78, 0.9, 0.98)
const DARK := Color(0.16, 0.16, 0.2)
const FENCE := Color(0.85, 0.82, 0.72)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var cold_door: FrontDoor
var till: Till
var case_broken := false
var penguin_down := false
var freezers: Array[IceFreezer] = []
var cold_melted := false
## Seconds the cold room's door has been open in a row.
var cold_open_for := 0.0
var puddles: Array[IcePuddle] = []
var machine: SoftServeMachine
var nieve: FloorBoss
var complaint_bar: ProgressBar
var spilled := false
var dispenser: ConeDispenser
var lucho: Lucho
## Whether she opened the cold room's door on her way, and whether it was locked then.
var _nieve_opened := false
var _was_locked := false
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the counter's glass case, the melted freezers and the cold room.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: IceCreamRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## Same seed, same shop, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
var _build: PlaceBuilder
var _penguin: Node3D
var _penguin_body: StaticBody3D
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
	_build_salon()
	_build_kitchen()
	_build_back()
	_build_yard()
	_place_nieve()
	lucho = Lucho.new()
	lucho.door = LUCHO_DOOR
	lucho.away = LUCHO_AWAY
	add_child(lucho)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("ice_cream")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "ice_cream", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = nieve
	raid.owner_id = "nieve"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The shop's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_ICE",
		"guess_key": "OBJ_GUESS_ICE",
		"broken_key": "OBJ_BROKEN_ICE",
		"complaint_key": "OBJ_COMPLAINT_ICE",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": nieve.complaint,
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


## What doña Nieve lets slip when asked (where the story's things are, in an order drawn from the seed), and what Lucho
## saw: where she put one of them away.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		nieve.slips.append(tr("NIEVE_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	nieve.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	lucho.clue = tr("CLUE_LUCHO") % where
	lucho.clue_speech = tr("LUCHO_CLUE_" + story_id) % where
	lucho.told.connect(raid.add_clue)


## The floors, the outer walls with the entrance, the roof, the sign over the door and the penguin on the sidewalk.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, BACK_WALL_Z, FRONT_WALL_Z, FLOOR_TOP, TILE)
	_build.slab(-HALF_X, HALF_X, FRONT_WALL_Z, HALF_Z, FLOOR_TOP, CONCRETE)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, BACK_WALL_Z, FLOOR_TOP, CONCRETE)
	_build.slab(-HALF_X, HALF_X, BACK_WALL_Z, FRONT_WALL_Z, ROOF_TOP, OUTSIDE.darkened(0.25))
	# The salon's checkered floor, only for the look.
	for i in 20:
		for j in 6:
			if (i + j) % 2 == 0:
				_build.mesh_box(Vector3(-9.5 + i, FLOOR_TOP + 0.005, 2.5 + j), Vector3(1.0, 0.01, 1.0), CHECKER)
	_build.wall_at("x", FRONT_WALL_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [ENTRANCE_X], OUTSIDE)
	_build.wall_at("x", BACK_WALL_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [BACK_DOOR_X], OUTSIDE)
	_build.wall_at("z", -HALF_X, BACK_WALL_Z, FRONT_WALL_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, BACK_WALL_Z, FRONT_WALL_Z, 0.0, WALL_TOP, [], OUTSIDE)
	# A pink awning over the front.
	_build.mesh_box(Vector3(0, WALL_TOP - 0.2, FRONT_WALL_Z + 0.6), Vector3(HALF_X * 2, 0.08, 1.2), PINK)
	for line: Array in [["PLACE_ICE_CREAM", 64, 2.75], ["ICE_SINCE", 32, 3.2]]:
		var label := Label3D.new()
		label.text = line[0]
		label.font_size = line[1]
		label.pixel_size = 0.01
		label.outline_size = 12
		label.modulate = PINK.lightened(0.4)
		label.position = Vector3(-3.0, line[2], FRONT_WALL_Z + 0.1)
		$Built.add_child(label)
	_penguin = _model(PENGUIN_MODEL, PENGUIN_AT)
	_penguin_body = _build.body(PENGUIN_AT + Vector3(0, 1.0, 0))
	_build.shape(_penguin_body, Vector3(0.9, 2.0, 0.8))
	var hit := _area(PENGUIN_AT + Vector3(0, 1.0, 0), Vector3(1.6, 2.0, 1.6))
	hit.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > PENGUIN_SPEED:
			knock_penguin())


## The salon: the counter with its glass case, the cashier's desk with the till and the cones, the two freezers, the
## tables and the "flavor of the month" board, and the wall to the rooms behind.
func _build_salon() -> void:
	_model(COUNTER_MODEL, COUNTER_AT)
	_build.shape(_build.body(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0)), COUNTER_SIZE)
	var glass := _area(COUNTER_AT + Vector3(0, 1.1, 0.6), Vector3(COUNTER_SIZE.x, 0.6, 0.6))
	glass.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > CASE_SPEED:
			crack_case())
	_build.open_box(CASHIER_AT, CASHIER_SIZE, "-z", PINK)
	till = Till.new()
	till.position = CASHIER_AT + Vector3(-0.3, CASHIER_SIZE.y + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_ICE"
	add_child(till)
	# The scale, only for the look.
	_build.mesh_box(CASHIER_AT + Vector3(0.3, CASHIER_SIZE.y + 0.05, 0.1), Vector3(0.3, 0.1, 0.3), STEEL)
	dispenser = ConeDispenser.new()
	dispenser.position = CASHIER_AT + Vector3(0.45, CASHIER_SIZE.y + ConeDispenser.SIZE.y / 2, -0.3)
	add_child(dispenser)
	for i in 2:
		_freezer(i)
	for at: Vector3 in [Vector3(5.5, FLOOR_TOP, 7.0), Vector3(8.0, FLOOR_TOP, 7.0), Vector3(8.0, FLOOR_TOP, 5.0)]:
		_build.box(at + Vector3(0, 0.75, 0), Vector3(0.8, 0.05, 0.8), MINT)
		_build.box(at + Vector3(0, 0.37, 0), Vector3(0.1, 0.74, 0.1), STEEL)
		for side: float in [-1.0, 1.0]:
			_build.box(at + Vector3(side * 0.75, 0.22, 0), Vector3(0.4, 0.44, 0.4), PINK)
	_build.mesh_box(Vector3(3.8, 1.7, SALON_Z + 0.09), Vector3(1.4, 0.9, 0.03), DARK)
	var board := Label3D.new()
	board.text = "ICE_FLAVOR_OF_THE_MONTH"
	board.font_size = 26
	board.pixel_size = 0.005
	board.position = Vector3(3.8, 1.95, SALON_Z + 0.12)
	$Built.add_child(board)
	_build.wall_at("x", SALON_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [KITCHEN_DOOR_X, OFFICE_DOOR_X, BATH_DOOR_X], MINT)
	for at: Vector3 in [Vector3(-4.0, 2.2, 6.0), Vector3(4.0, 2.2, 6.0)]:
		_build.light(at)


## The kitchen: the soft-serve machine, the bench with the mixer and the sink, two freezers, and the cold room behind
## its locked door with shelves of tubs and blocks of ice.
func _build_kitchen() -> void:
	_build.wall_at("z", KITCHEN_X1, BACK_WALL_Z, SALON_Z, 0.0, WALL_TOP, [], WALL_IN)
	machine = SoftServeMachine.new()
	machine.position = MACHINE_AT
	machine.rotation.y = PI
	add_child(machine)
	_build.box(Vector3(-3.4, FLOOR_TOP + 0.45, -4.6), Vector3(2.4, 0.9, 0.6), STEEL)
	_build.mesh_box(Vector3(-2.7, FLOOR_TOP + 1.1, -4.6), Vector3(0.35, 0.4, 0.35), PINK)
	_build.mesh_box(Vector3(-4.2, FLOOR_TOP + 0.92, -4.6), Vector3(0.6, 0.04, 0.4), DARK)
	for i in range(2, 4):
		_freezer(i)
	_build.wall_at("x", COLD_Z1, -HALF_X, COLD_X1, 0.0, WALL_TOP, [COLD_DOOR_X], COLD)
	_build.wall_at("z", COLD_X1, BACK_WALL_Z, COLD_Z1, 0.0, WALL_TOP, [], COLD)
	_build.mesh_box(Vector3((-HALF_X + COLD_X1) / 2, FLOOR_TOP + 0.05, (BACK_WALL_Z + COLD_Z1) / 2),
		Vector3(COLD_X1 + HALF_X - 0.3, 0.1, COLD_Z1 - BACK_WALL_Z - 0.3), Color(0.95, 0.97, 1.0))
	for at: Vector3 in SHELVES:
		_model(SHELF_MODEL, at)
		_build.shape(_build.body(at + Vector3(0, SHELF_SIZE.y / 2, 0)), SHELF_SIZE)
	cold_door = DOOR_SCENE.instantiate()
	cold_door.position = Vector3(COLD_DOOR_X - GameScale.DOOR_WIDTH / 2, 0.0, COLD_Z1)
	add_child(cold_door)
	var frost := _build.light(Vector3(-7.75, 2.2, -3.0))
	frost.light_color = COLD
	frost.light_energy = 0.6
	_build.light(Vector3(-3.0, 2.2, -1.5)).light_energy = 0.6


## The owner's office with the desk and the toy safe, and the bathroom.
func _build_back() -> void:
	_build.wall_at("z", BATH_X0, BACK_WALL_Z, SALON_Z, 0.0, WALL_TOP, [], WALL_IN)
	_build.box(Vector3(2.5, FLOOR_TOP + 0.4, -3.0), Vector3(1.8, 0.8, 0.8), WOOD)
	_build.box(Vector3(2.5, FLOOR_TOP + 0.25, -3.9), Vector3(0.5, 0.5, 0.5), PINK)
	_build.box(Vector3(4.4, FLOOR_TOP + 0.3, -4.5), Vector3(0.5, 0.6, 0.5), DARK)
	_build.box(Vector3(9.4, FLOOR_TOP + 0.25, -4.2), Vector3(0.5, 0.5, 0.6), TILE)
	_build.box(Vector3(5.6, FLOOR_TOP + 0.45, -1.0), Vector3(0.5, 0.9, 0.6), TILE)
	for at: Vector3 in [Vector3(2.5, 2.2, -1.5), Vector3(7.5, 2.2, -1.5)]:
		_build.light(at).light_energy = 0.4


## The fenced yard behind the kitchen with the ice cream truck and a pile of empty buckets.
func _build_yard() -> void:
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, 1.2, [], FENCE)
	for x: float in [-HALF_X, HALF_X]:
		_build.wall_at("z", x, -HALF_Z, BACK_WALL_Z, 0.0, 1.2, [], FENCE)
	var truck := _model(TRUCK_MODEL, TRUCK_AT, PI / 2)
	for at: Vector3 in [Vector3(-1.1, 0.38, 1.7), Vector3(1.1, 0.38, 1.7), Vector3(-1.1, 0.38, -1.7),
			Vector3(1.1, 0.38, -1.7)]:
		var wheel: Node3D = WHEEL_MODEL.instantiate()
		wheel.position = at
		truck.add_child(wheel)
	_build.shape(_build.body(TRUCK_AT + Vector3(0, 1.3, 0)), Vector3(5.2, 2.6, 2.2))
	for i in 4:
		_build.box(Vector3(-7.4 + (i % 2) * 0.6, FLOOR_TOP + 0.25 + (i / 2) * 0.5, -8.6), Vector3(0.45, 0.5, 0.45),
			[MINT, PINK, COLD, FENCE][i])


## Freezer `i` of FREEZERS, whose lid melts what's inside if left open.
func _freezer(i: int) -> void:
	var freezer := IceFreezer.new()
	freezer.position = FREEZERS[i].at
	freezer.rotation.y = FREEZERS[i].turn
	add_child(freezer)
	freezers.append(freezer)
	freezer.melted.connect(_on_freezer_melted.bind(i))


func _physics_process(delta: float) -> void:
	if nieve:
		_nieve_door()
	if cold_melted:
		return
	if cold_door.is_open or cold_door.is_broken:
		cold_open_for += delta
		if cold_open_for >= COLD_MELT_AFTER:
			melt_cold_room()
	else:
		cold_open_for = 0.0


func _on_freezer_melted(i: int) -> void:
	var freezer := freezers[i]
	broken_goods += 1
	fines += FREEZER_FINE
	raid.float_label("-%d" % FREEZER_FINE, freezer.global_position + Vector3.UP * 2.2, Color(1, 0.3, 0.25))
	_puddle(freezer.position + Vector3(0, 0, IceFreezer.SIZE.z / 2 + FREEZER_PUDDLE.y / 2).rotated(Vector3.UP,
		freezer.rotation.y), FREEZER_PUDDLE, FREEZER_FLAVORS[i])
	_say(freezer.position + Vector3(0, 1.8, 0), "ICE_FREEZER_MELTED_%d" % (i + 1))
	if nieve:
		nieve.saw(freezer.global_position + Vector3.UP, SAW_FREEZER, "NIEVE_FREEZER_%d" % (i + 1))
	freezer_melted.emit(i)


## The cold room melts, once: a fine and a big puddle out its door.
func melt_cold_room() -> void:
	if cold_melted:
		return
	cold_melted = true
	broken_goods += 1
	fines += COLD_FINE
	raid.float_label("-%d" % COLD_FINE, to_global(Vector3(COLD_DOOR_X, 2.6, COLD_Z1 + 0.8)), Color(1, 0.3, 0.25))
	_puddle(Vector3(COLD_DOOR_X, FLOOR_TOP, COLD_Z1 + COLD_PUDDLE.y / 2), COLD_PUDDLE)
	_say(Vector3(COLD_DOOR_X, 2.2, COLD_Z1 + 0.8), "ICE_COLD_ROOM_MELTED")
	if nieve:
		nieve.saw(to_global(Vector3(COLD_DOOR_X, 1.2, COLD_Z1 + 0.5)), SAW_COLD_ROOM, "NIEVE_COLD_ROOM")
	cold_room_melted.emit()


## Doña Nieve on her round, the machine, what she notices and the complaint bar.
func _place_nieve() -> void:
	nieve = NIEVE_SCENE.instantiate()
	nieve.route = NIEVE_ROUTE
	nieve.printer_spot = MACHINE_SPOT
	nieve.printer = machine
	nieve.fix_time = MACHINE_TIME
	nieve.first_pause = COUNTER_PAUSE
	add_child(nieve)
	nieve.start_at(0)
	cold_door.broken.connect(nieve.door_broken)
	nieve.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_ICE"))
	till.opened.connect(func(at: Vector3) -> void: nieve.saw(at, FloorBoss.SAW_TILL))
	case_cracked.connect(func() -> void:
		nieve.saw(to_global(COUNTER_AT + Vector3(0, 1.1, 0.4)), SAW_CASE, "NIEVE_CASE"))
	penguin_knocked.connect(func() -> void: nieve.scold(PENGUIN, "NIEVE_PENGUIN"))
	machine.jammed.connect(spill)
	machine.noticed.connect(func() -> void: nieve.scold(NOTICED, "NIEVE_NOTICED"))
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
	nieve.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## The jammed machine pours ice cream on the kitchen's floor: a small puddle, the first time.
func spill() -> void:
	if spilled:
		return
	spilled = true
	_puddle(SPILL_AT, SPILL, Color(1.0, 0.95, 0.85, 0.9))


## She has the cold room's key: its door opens before her and shuts behind her, locked again as she found it unless a
## cop slipped in.
func _nieve_door() -> void:
	if cold_door.is_broken:
		return
	var at := to_local(nieve.global_position)
	var near := Vector2(at.x - COLD_DOOR_X, at.z - COLD_Z1).length() < DOOR_REACH
	if near and not cold_door.is_open:
		_was_locked = cold_door.locked
		_nieve_opened = true
		cold_door.open_from_inside()
	elif not near and _nieve_opened:
		_nieve_opened = false
		cold_door.close()
		cold_door.locked = _was_locked and not _cop_in_cold_room()


func _cop_in_cold_room() -> bool:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var at := to_local(cop.global_position)
		if at.x < COLD_X1 and at.z < COLD_Z1:
			return true
	return false


func _puddle(at: Vector3, size: Vector2, color := Color(0.85, 0.62, 0.55, 0.9)) -> IcePuddle:
	var puddle := IcePuddle.new(size, color)
	puddle.position = Vector3(at.x, FLOOR_TOP, at.z)
	add_child(puddle)
	puddles.append(puddle)
	return puddle


## Cracks the counter's glass case, once: a fine and a crack across it.
func crack_case() -> void:
	if case_broken:
		return
	case_broken = true
	broken_goods += 1
	fines += CASE_FINE
	raid.float_label("-%d" % CASE_FINE, to_global(COUNTER_AT + Vector3.UP * 2.0), Color(1, 0.3, 0.25))
	_build.mesh_box(COUNTER_AT + Vector3(0.4, 1.2, 0.36), Vector3(2.0, 0.03, 0.01), DARK)
	_build.mesh_box(COUNTER_AT + Vector3(-0.5, 1.15, 0.36), Vector3(0.03, 0.3, 0.01), DARK)
	_say(COUNTER_AT + Vector3(0, 2.2, 0.6), "ICE_CASE_BROKEN")
	case_cracked.emit()


## Knocks the penguin over, once: it lies on the sidewalk (no fine; the owner minds, step 3).
func knock_penguin() -> void:
	if penguin_down:
		return
	penguin_down = true
	_penguin.rotation.x = PI / 2
	_penguin.position = PENGUIN_AT + Vector3(0, 0.45, 0)
	_penguin_body.position = PENGUIN_AT + Vector3(0, 0.45, 1.0)
	_penguin_body.rotation.x = PI / 2
	_say(PENGUIN_AT + Vector3(0, 2.0, 0), "ICE_PENGUIN_DOWN")
	penguin_knocked.emit()


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
