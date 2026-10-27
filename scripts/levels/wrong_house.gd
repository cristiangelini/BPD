class_name WrongHouse
extends Node3D

## The wrong house (docs/diseno/casa-equivocada.md, step 1, decision 223): two twin two-storey houses joined by the
## party wall, on one lot with the fronts to +Z. Same color, same roof, same green door, and each lost a digit of its
## number ("1_" and "_4"): the warrant says 14 and either could be it. Which one is the guilty neighbor's, the west or
## the east, comes from the seed (or --guilty=left|right); the other is doña Chola's, who knows nothing (step 2:
## everything broken in hers costs CHOLA_FINES times the fine, and she sees it). Each house
## has its front door locked with the key in one of its pots, its ornaments (fines), its mailbox, and an old station
## wagon parked in the side passage, nose to the street, with a roof rack. Step 3: the guilty neighbor, if he sees the
## cops go into doña Chola's house, carries his things out to his rack one by one and drives off with the main one.
## Step 4: the door clues (a letter for the 14, the newspaper and Don Sobre the mailman), one of the first two wrong.
## Steps 5 to 7: his stories (STORIES), drawn with the seed or --story=<id>, each with its rig.
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const CHOLA_SCENE := preload("res://scenes/npc/neighbor_chola.tscn")
const GUILTY_SCENE := preload("res://scenes/npc/guilty_neighbor.tscn")

## A door clue went to the checklist: its line, already translated (the case adds it, step 8).
signal clue_found(text: String)

## The guilty neighbor waits at his front window (house space).
const GUILTY_AT := Vector3(-5.8, FLOOR_TOP, 6.0)
const GRASS_TOP := 0.04
## Doña Chola watches her soap opera standing by the sofa, facing the TV (house space).
const CHOLA_AT := Vector3(-3.5, FLOOR_TOP, 3.4)
## Each house is HALF_U * 2 wide; the west one's middle at -HALF_U and the east one's at +HALF_U, the party wall at x = 0.
const HALF_U := 7.0
const FRONT_Z := 7.0
const BACK_Z := -4.0
## The lot's edges: the front garden runs to LOT_Z, the back yard to -LOT_Z, the side passages to LOT_X.
const LOT_X := 18.0
const LOT_Z := 10.0
const FLOOR_TOP := 0.06
## The wall between the front rooms and the back ones, and the walls of the stair hall (in a house's own x, u).
const SPLIT_Z := 1.5
const HALL_WEST := -2.5
const HALL_EAST := 1.5
const ENTRANCE_U := -3.5
const BACK_DOOR_U := 4.5
const SIDE_DOOR_Z := -1.0
const STAIR_U := -0.5
const STAIR_FOOT_Z := 1.0
const STAIR_RUN := 3.75
const FENCE_HEIGHT := 0.9
## Where each house's three pots stand in its front garden, and its mailbox by the sidewalk (house space).
const POTS: Array[Vector3] = [Vector3(-5.0, 0.0, 7.8), Vector3(-2.0, 0.0, 7.8), Vector3(1.0, 0.0, 8.4)]
const MAILBOX_AT := Vector3(-5.5, 0.0, 9.6)
## The station wagon in the side passage beside each house (outside it, so -/+ by the house's side).
const WAGON_X := 16.0
const WAGON_Z := 3.0
const WAGON_SIZE := Vector3(1.9, 1.5, 4.6)
const NUMBERS: Array[String] = ["1_", "_4"]
## The newspaper for the 14 lies in one front garden (house space).
const PAPER_AT := Vector3(2.5, GRASS_TOP + 0.05, 8.8)
## The mailman rides the sidewalk in front of the lot, between two ends off it.
const MAIL_Z := LOT_Z + 1.2
const MAIL_ENDS := Vector2(-LOT_X - 8.0, LOT_X + 8.0)
## The guilty neighbor's stories (casa-equivocada.md, "Las historias"), like Groomer.STORIES: what the comisario says
## once it's guessed, its "find it" row, what it hides in his house in spots drawn with the seed (half heights, heavy
## ones), the checklist rows of its extras and its rig. With "main_hidden" the first hidden item is the main evidence;
## otherwise the rig places it. Steps 5 to 7 add two each.
const STORIES := {
	"bills": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_WH_BILLS_B", "BRIEF_WH_BILLS_C", "BRIEF_WH_BILLS_D"],
		"find": "OBJ_FIND_WH_BILLS",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/printing_plate.tscn"), preload("res://scenes/props/fake_bills.tscn"),
			preload("res://scenes/props/ink_pot.tscn")],
		"half_heights": [0.04, 0.03, 0.1],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_FAKE_BILLS", "OBJ_EXTRA_INK_POT"],
		"rig": preload("res://scripts/case/wrong_house/bills_rig.gd"),
	},
	"gnomes": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_WH_GNOMES_B", "BRIEF_WH_GNOMES_C", "BRIEF_WH_GNOMES_D"],
		"find": "OBJ_FIND_WH_GNOMES",
		"hidden": [preload("res://scenes/props/garden_list.tscn"), preload("res://scenes/props/loot_wheelbarrow.tscn")],
		"half_heights": [0.005, 0.0],
		"heavy": [false, true],
		"extra_keys": ["OBJ_EXTRA_GARDEN_LIST", "OBJ_EXTRA_WHEELBARROW"],
		"rig": preload("res://scripts/case/wrong_house/gnomes_rig.gd"),
	},
	"parrot": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_WH_PARROT_B", "BRIEF_WH_PARROT_C", "BRIEF_WH_PARROT_D"],
		"find": "OBJ_FIND_WH_PARROT",
		"hidden": [preload("res://scenes/props/bird_cage.tscn"), preload("res://scenes/props/code_notebook.tscn")],
		"half_heights": [0.25, 0.01],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_BIRD_CAGE", "OBJ_EXTRA_CODE_NOTEBOOK"],
		"rig": preload("res://scripts/case/wrong_house/parrot_rig.gd"),
	},
	"fireworks": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_WH_FIREWORKS_B", "BRIEF_WH_FIREWORKS_C", "BRIEF_WH_FIREWORKS_D"],
		"find": "OBJ_FIND_WH_FIREWORKS",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/rocket_box.tscn"), preload("res://scenes/props/fuses.tscn"),
			preload("res://scenes/props/party_plan.tscn")],
		"half_heights": [0.15, 0.02, 0.005],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_FUSES", "OBJ_EXTRA_PARTY_PLAN"],
		"rig": preload("res://scripts/case/wrong_house/fireworks_rig.gd"),
	},
	"letters": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_WH_LETTERS_B", "BRIEF_WH_LETTERS_C", "BRIEF_WH_LETTERS_D"],
		"find": "OBJ_FIND_WH_LETTERS",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/letters_bag.tscn"), preload("res://scenes/props/stamp_album.tscn")],
		"half_heights": [0.28, 0.015],
		"heavy": [true, false],
		"extra_keys": ["OBJ_EXTRA_STAMPS"],
		"rig": preload("res://scripts/case/wrong_house/letters_rig.gd"),
	},
	"perfume": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_WH_PERFUME_B", "BRIEF_WH_PERFUME_C", "BRIEF_WH_PERFUME_D"],
		"find": "OBJ_FIND_WH_PERFUME",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/perfume_jug.tscn"), preload("res://scenes/props/perfume_labels.tscn"),
			preload("res://scenes/props/sample_flask.tscn")],
		"half_heights": [0.2, 0.05, 0.07],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_FAKE_LABELS", "OBJ_EXTRA_SAMPLE_FLASK"],
		"rig": preload("res://scripts/case/wrong_house/perfume_rig.gd"),
	},
}
## Where the guilty neighbor hides his things, in house space: the floor of each spot (an item rests its half height
## over it), and whether a heavy one fits. All downstairs, handy for him, and none in his way out the back.
const SPOTS := [
	{"id": "in_fridge", "at": Vector3(6.4, FLOOR_TOP + 0.05, 6.4), "heavy": false},
	{"id": "in_bathtub", "at": Vector3(-5.6, FLOOR_TOP + 0.05, -3.2), "heavy": true},
	{"id": "in_washer", "at": Vector3(6.4, FLOOR_TOP + 0.05, -3.3), "heavy": false},
	{"id": "under_sofa", "at": Vector3(-3.5, FLOOR_TOP, 2.5), "heavy": false},
	{"id": "on_counter", "at": Vector3(4.5, FLOOR_TOP + 0.9, 2.0), "heavy": false},
	{"id": "kitchen_floor", "at": Vector3(2.5, FLOOR_TOP, 5.8), "heavy": true},
	{"id": "on_the_tv", "at": Vector3(-3.5, 0.95, 6.5), "heavy": false},
]
## Which of the two door clues is the wrong one (the mailman never lies).
const MAILBOX := 0
const PAPER := 1
## Window centers along each facade (u), downstairs and upstairs, front and back alike: only for the look.
const WINDOWS := [[-5.8, -1.2, 3.5], [-3.5, 3.5]]
const LEFT := 0
const RIGHT := 1
## In doña Chola's house each broken thing costs this many times the grandpa's fine.
const CHOLA_FINES := 2
## Ornament shelves in house space (OrnamentLayout units) and the kitchen counter's row of plates.
const SHELVES := [
	{"at": Vector3(-6.75, 0, 4.3), "along": "z", "width": 2.0},  # living
	{"at": Vector3(-6.75, GameScale.FLOOR_HEIGHT, 4.3), "along": "z", "width": 2.0},  # west bedroom
	{"at": Vector3(6.75, GameScale.FLOOR_HEIGHT, 4.3), "along": "z", "width": 2.0},  # east bedroom
]
const COUNTER_AT := Vector3(4.5, FLOOR_TOP, 2.0)
const COUNTER_PLATES := 6

const WALLS := Color(0.95, 0.86, 0.6)
const INSIDE := Color(0.96, 0.93, 0.86)
const DOOR_GREEN := Color(0.2, 0.55, 0.3)
const ROOF := Color(0.62, 0.3, 0.24)
const TILES := Color(0.78, 0.7, 0.6)
const WOOD := Color(0.55, 0.38, 0.25)
const WHITE := Color(0.93, 0.93, 0.9)
const FENCE := Color(0.9, 0.9, 0.85)
const WAGON := Color(0.55, 0.62, 0.48)
const WAGON_ROOF := Color(0.45, 0.34, 0.24)
const GLASS := Color(0.55, 0.72, 0.85)

@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where (SPOTS indexes), and its extras.
var main: Evidence
var rig: WrongHouseRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## The guilty neighbor's house: LEFT (west) or RIGHT (east).
var guilty := LEFT
## By house (LEFT, RIGHT): its front door, its pots, which pot has the key, its ornaments and its station wagon.
var doors: Array[FrontDoor] = []
var pots: Array = [[], []]
var key_pot: Array[int] = [0, 0]
var ornaments: Array = [[], []]
var broken: Array[int] = [0, 0]
var wagons: Array[StaticBody3D] = []
var chola: NeighborChola
var neighbor: GuiltyNeighbor
var mailman: Mailman
## The door clue that points at the wrong house (MAILBOX or PAPER), each house's mailbox and the newspaper.
var lying_clue := MAILBOX
var mailboxes: Array[ClueSpot] = []
var paper: ClueSpot
## The door clues the cops found, in order.
var clues: Array[String] = []
## Fines for what the cops broke, in both houses.
var fines := 0
var station_parking: Transform3D
var _build: PlaceBuilder
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	guilty = pick_guilty(case_seed, OS.get_cmdline_user_args())
	if story_id == "":
		story_id = pick_story(case_seed, OS.get_cmdline_user_args())
	_build = PlaceBuilder.new($Built)
	_build_lot()
	for house in 2:
		_build_house(house)
	_place_chola()
	_bake_navigation()
	_place_neighbor()
	_place_door_clues()
	_place_story()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("wrong_house")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = city.transform * CityLayout.parking("wrong_house")
	car.global_position += Vector3.UP * 0.05
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))


## Who isn't the guilty one's house.
func chola_house() -> int:
	return RIGHT if guilty == LEFT else LEFT


## Doña Chola in her living, facing the TV; a door of her house rammed down reaches her anywhere.
func _place_chola() -> void:
	chola = CHOLA_SCENE.instantiate()
	chola.position = at(chola_house(), CHOLA_AT)
	add_child(chola)
	doors[chola_house()].broken.connect(chola.door_broken)


## The guilty neighbor at his window, with his house, his rack and where he stands to load it.
func _place_neighbor() -> void:
	neighbor = GUILTY_SCENE.instantiate()
	neighbor.position = at(guilty, GUILTY_AT)
	neighbor.home = neighbor.position
	neighbor.house_rect = house_rect(guilty)
	neighbor.grounds = grounds_rect(guilty)
	var side := -1.0 if guilty == LEFT else 1.0
	neighbor.rack = Vector3(side * WAGON_X, WAGON_SIZE.y + 0.55, WAGON_Z - 0.6)
	neighbor.rack_spot = Vector3(side * WAGON_X, FLOOR_TOP, WAGON_Z - WAGON_SIZE.z / 2 - 0.8)
	add_child(neighbor)
	neighbor.fled.connect(_on_fled)


## The story's hidden items in the guilty house, in spots drawn with the seed, then its rig; he takes the extras out
## first and the main evidence last.
func _place_story() -> void:
	var story: Dictionary = STORIES[story_id]
	var spot_heavy: Array = SPOTS.map(func(spot: Dictionary) -> bool: return spot.heavy)
	hidden_spots = HidingDraw.draw(case_seed, spot_heavy, story.heavy, 1).spots
	for i in story.hidden.size():
		var item: Evidence = story.hidden[i].instantiate()
		item.position = at(guilty, SPOTS[hidden_spots[i]].at) + Vector3.UP * (story.half_heights[i] + 0.01)
		add_child(item)
		hidden.append(item)
	if story.get("main_hidden", false):
		main = hidden[0]
		extras.assign(hidden.slice(1))
	else:
		extras.assign(hidden)
	rig = (story.rig as Script).new()
	add_child(rig)
	rig.setup(self)
	var loot: Array[Grabbable] = []
	loot.assign(extras)
	loot.append(main)
	neighbor.loot = loot


## The story with that id from --story=<id> among the user args, or one drawn from the seed.
static func pick_story(seed_value: int, args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with("--story=") and STORIES.has(arg.trim_prefix("--story=")):
			return arg.trim_prefix("--story=")
	return STORIES.keys()[seed_value % STORIES.size()]


## The door clues: a letter for the 14 in one mailbox, the 14's newspaper in one front garden and the mailman. One
## of the first two is in the wrong house.
func _place_door_clues() -> void:
	lying_clue = pick_lying(case_seed)
	var letter_house := chola_house() if lying_clue == MAILBOX else guilty
	for house in 2:
		var box := _clue_spot(at(house, MAILBOX_AT + Vector3(0, 1.1, 0)), Vector3(0.36, 0.32, 0.52), "PROMPT_OPEN_MAILBOX")
		if house == letter_house:
			box.text = tr("CLUE_WH_LETTER") % tr(side_key(house))
			box.read.connect(_on_clue)
		else:
			box.text = "WH_MAILBOX_ADS"
		mailboxes.append(box)
	var paper_house := chola_house() if lying_clue == PAPER else guilty
	paper = _clue_spot(at(paper_house, PAPER_AT), Vector3(0.4, 0.14, 0.2), "PROMPT_READ_PAPER")
	paper.text = tr("CLUE_WH_PAPER") % tr(side_key(paper_house))
	paper.read.connect(_on_clue)
	var roll := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.06
	cylinder.bottom_radius = 0.06
	cylinder.height = 0.36
	roll.mesh = cylinder
	roll.rotation.z = PI / 2
	roll.material_override = _build.material(Color(0.88, 0.86, 0.8))
	paper.add_child(roll)
	mailman = Mailman.new()
	mailman.route_z = MAIL_Z
	mailman.ends = MAIL_ENDS
	mailman.stops = [at(LEFT, MAILBOX_AT).x, at(RIGHT, MAILBOX_AT).x]
	mailman.position.y = GRASS_TOP
	mailman.clue = tr("CLUE_WH_MAILMAN") % tr(side_key(guilty))
	mailman.told.connect(_on_clue)
	add_child(mailman)


func _clue_spot(where: Vector3, size: Vector3, prompt: String) -> ClueSpot:
	var spot := ClueSpot.new()
	spot.size = size
	spot.prompt = prompt
	spot.position = where
	add_child(spot)
	return spot


func _on_clue(text: String) -> void:
	clues.append(text)
	clue_found.emit(text)


## Which door clue lies, drawn from the seed.
static func pick_lying(seed_value: int) -> int:
	return hash(["wrong house clue", seed_value]) % 2


## How a house is named from the sidewalk: the west one is on the left.
static func side_key(house: int) -> String:
	return "WH_SIDE_LEFT" if house == LEFT else "WH_SIDE_RIGHT"


## A house and its back yard on the ground (x, z): what the guilty neighbor takes out has to be in there.
static func grounds_rect(house: int) -> Rect2:
	return Rect2(house_x(house) - HALF_U, -LOT_Z, HALF_U * 2, FRONT_Z + LOT_Z)


## A house's floor on the ground (x, z).
static func house_rect(house: int) -> Rect2:
	return Rect2(house_x(house) - HALF_U, BACK_Z, HALF_U * 2, FRONT_Z - BACK_Z)


## The first house a cop walks into decides it: doña Chola's and the neighbor sees it; his, and he's off guard.
func _physics_process(_delta: float) -> void:
	if not neighbor or neighbor.noticed or neighbor.off_guard:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var spot := Vector2(cop.global_position.x, cop.global_position.z)
		if house_rect(chola_house()).has_point(spot):
			neighbor.notice()
			return
		if house_rect(guilty).has_point(spot):
			neighbor.caught_off_guard()
			return


## He drove off: his wagon and what's on its rack leave with him (the chase comes with the case, step 8).
func _on_fled() -> void:
	var wagon := wagons[guilty]
	wagon.visible = false
	wagon.collision_layer = 0
	for item in neighbor.on_rack:
		item.freeze = true
		item.visible = false
		item.collision_layer = 0


## The neighbor walks on a navigation mesh baked from the built houses and the lot, with the front doors closed.
func _bake_navigation() -> void:
	var nav: NavigationRegion3D = $Navigation
	NavigationServer3D.map_set_cell_size(get_world_3d().navigation_map, nav.navigation_mesh.cell_size)
	NavigationServer3D.map_set_cell_height(get_world_3d().navigation_map, nav.navigation_mesh.cell_height)
	$Built.add_to_group("navigation_source")
	for door in doors:
		door.add_to_group("navigation_source")
	nav.bake_navigation_mesh(false)


## The guilty house from --guilty=left|right among the user args, or drawn from the seed.
static func pick_guilty(seed_value: int, args: PackedStringArray) -> int:
	for arg: String in args:
		if arg == "--guilty=left":
			return LEFT
		if arg == "--guilty=right":
			return RIGHT
	return hash(["wrong house", seed_value]) % 2


## A house's middle on the lot.
static func house_x(house: int) -> float:
	return -HALF_U if house == LEFT else HALF_U


## Where `local` (in a house's own space, u along x) sits on the lot.
static func at(house: int, local: Vector3) -> Vector3:
	return local + Vector3(house_x(house), 0, 0)


## Which house a point of the lot is in, by its side of the party wall.
static func house_of(point: Vector3) -> int:
	return LEFT if point.x < 0.0 else RIGHT


## The low fences round the back yards (one between them, over the party wall) and down the side passages.
func _build_lot() -> void:
	_build.slab(-LOT_X, LOT_X, FRONT_Z, LOT_Z, GRASS_TOP, Color(0.42, 0.66, 0.32))
	_build.slab(-LOT_X, LOT_X, -LOT_Z, BACK_Z, GRASS_TOP, Color(0.42, 0.66, 0.32))
	for x: float in [-LOT_X, HALF_U * 2]:
		_build.slab(x, x + LOT_X - HALF_U * 2, BACK_Z, FRONT_Z, GRASS_TOP, Color(0.5, 0.5, 0.48))
	var y := FENCE_HEIGHT / 2
	_build.box(Vector3(0, y, -LOT_Z), Vector3(LOT_X * 2, FENCE_HEIGHT, 0.06), FENCE)
	_build.box(Vector3(0, y, (BACK_Z - LOT_Z) / 2), Vector3(0.06, FENCE_HEIGHT, LOT_Z + BACK_Z), FENCE)
	for x: float in [-LOT_X, LOT_X]:
		_build.box(Vector3(x, y, 0), Vector3(0.06, FENCE_HEIGHT, LOT_Z * 2), FENCE)


func _build_house(house: int) -> void:
	var x := house_x(house)
	var up := GameScale.FLOOR_HEIGHT
	_build.slab(x - HALF_U, x + HALF_U, BACK_Z, FRONT_Z, FLOOR_TOP, TILES)
	# Upstairs floor with the hole over the stairs (a little wider to the west, for the head), and the ceiling.
	var hole_w := x + STAIR_U - GameScale.STAIR_WIDTH / 2 - 0.3
	var hole_e := x + STAIR_U + GameScale.STAIR_WIDTH / 2
	var hole_n := STAIR_FOOT_Z - STAIR_RUN
	_build.slab(x - HALF_U, hole_w, BACK_Z, FRONT_Z, up, TILES)
	_build.slab(hole_e, x + HALF_U, BACK_Z, FRONT_Z, up, TILES)
	_build.slab(hole_w, hole_e, BACK_Z, hole_n, up, TILES)
	_build.slab(hole_w, hole_e, STAIR_FOOT_Z, FRONT_Z, up, TILES)
	_build.slab(x - HALF_U - 0.2, x + HALF_U + 0.2, BACK_Z - 0.2, FRONT_Z + 0.2, up * 2, ROOF)
	var roof := PrismMesh.new()
	roof.size = Vector3(HALF_U * 2 + 0.4, 2.0, FRONT_Z - BACK_Z + 0.6)
	_build.mesh(roof, Vector3(x, up * 2 + 1.0, (FRONT_Z + BACK_Z) / 2), ROOF)
	_build.box(Vector3(x + hole_w - x - 0.04, up + 0.5, (hole_n + STAIR_FOOT_Z) / 2), Vector3(0.08, 1.0, STAIR_RUN), WHITE)
	for level in 2:
		_build.wall("x", FRONT_Z, x - HALF_U, x + HALF_U, level, [x + ENTRANCE_U] if level == 0 else [], WALLS)
		_build.wall("x", BACK_Z, x - HALF_U, x + HALF_U, level, [x + BACK_DOOR_U] if level == 0 else [], WALLS)
		# The outer side walls; the party wall at x = 0 is built once, by the west house.
		var outer := x - HALF_U if house == LEFT else x + HALF_U
		_build.wall("z", outer, BACK_Z, FRONT_Z, level, [], WALLS)
		if house == LEFT:
			_build.wall("z", 0.0, BACK_Z, FRONT_Z, level, [], WALLS)
		# Front rooms (living and kitchen downstairs, two bedrooms up) off the stair hall behind them; bathroom and
		# laundry (storeroom up) on each side of the hall.
		_build.wall("x", SPLIT_Z, x - HALF_U, x + HALF_U, level, [x + STAIR_U - 1.0] if level == 0 else [x - 4.0, x + 3.5], INSIDE)
		_build.wall("z", x, SPLIT_Z, FRONT_Z, level, [4.0] if level == 0 else [], INSIDE)
		_build.wall("z", x + HALL_WEST, BACK_Z, SPLIT_Z, level, [SIDE_DOOR_Z], INSIDE)
		_build.wall("z", x + HALL_EAST, BACK_Z, SPLIT_Z, level, [SIDE_DOOR_Z], INSIDE)
		for u: float in [-3.5, 3.5]:
			_build.light(Vector3(x + u, level * up + 2.2, 4.3))
		_build.light(Vector3(x - 0.5, level * up + 2.2, -1.5))
	_build.stairs(Vector3(x + STAIR_U, FLOOR_TOP, STAIR_FOOT_Z), STAIR_RUN, WOOD)
	_furniture(house)
	_front(house)
	_fragile(house)


## The same furniture in both: sofa and TV, kitchen counter and fridge, bathtub, washing machine, two beds and boxes.
func _furniture(house: int) -> void:
	var up := GameScale.FLOOR_HEIGHT
	_build.legs(at(house, Vector3(-3.5, FLOOR_TOP, 2.5)), Vector2(2.2, 0.8), 0.3, WOOD)
	_build.box(at(house, Vector3(-3.5, 0.45, 2.5)), Vector3(2.2, 0.3, 0.8), DOOR_GREEN.lightened(0.3))
	_build.box(at(house, Vector3(-3.5, 0.5, 6.5)), Vector3(1.4, 0.9, 0.5), Color(0.2, 0.2, 0.22))
	_build.box(COUNTER_AT + Vector3(house_x(house), 0.45, 0), Vector3(3.0, 0.9, 0.6), WHITE)
	_build.open_box(at(house, Vector3(6.4, FLOOR_TOP, 6.4)), Vector3(0.8, 1.8, 0.7), "-x", WHITE)
	_build.open_box(at(house, Vector3(-5.6, FLOOR_TOP, -3.2)), Vector3(1.7, 0.6, 0.8), "top", WHITE)
	_build.open_box(at(house, Vector3(6.4, FLOOR_TOP, -3.3)), Vector3(0.9, 0.9, 0.9), "-x", WHITE)
	for u: float in [-3.5, 3.5]:
		_build.legs(at(house, Vector3(u, up, 5.5)), Vector2(1.5, 2.1), 0.34, WOOD)
		_build.box(at(house, Vector3(u, up + 0.45, 5.5)), Vector3(1.4, 0.2, 2.0), WHITE)
	_build.box(at(house, Vector3(5.5, up + 0.3, -2.8)), Vector3(0.8, 0.6, 0.8), Color(0.7, 0.55, 0.35))


## The front: the green door (locked), its lost digit over it, the windows, the pots, the mailbox and the wagon in
## the passage.
func _front(house: int) -> void:
	for level in 2:
		for u: float in WINDOWS[level]:
			for z: float in [FRONT_Z + 0.09, BACK_Z - 0.09]:
				_build.mesh_box(at(house, Vector3(u, level * GameScale.FLOOR_HEIGHT + 1.5, z)), Vector3(1.2, 1.0, 0.04), GLASS)
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = at(house, Vector3(ENTRANCE_U - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, FRONT_Z))
	add_child(door)
	(door.get_node("Panel/Mesh") as MeshInstance3D).material_override = _build.material(DOOR_GREEN)
	doors.append(door)
	var number := Label3D.new()
	number.text = NUMBERS[house]
	number.font_size = 96
	number.pixel_size = 0.006
	number.outline_size = 12
	number.position = at(house, Vector3(ENTRANCE_U, GameScale.DOOR_HEIGHT + 0.35, FRONT_Z + 0.1))
	$Built.add_child(number)
	key_pot[house] = hash(["wrong house key", case_seed, house]) % POTS.size()
	for i in POTS.size():
		var pot: KeyPot = POT_SCENE.instantiate()
		pot.position = at(house, POTS[i])
		pot.has_key = i == key_pot[house]
		$Built.add_child(pot)
		pots[house].append(pot)
	_build.box(at(house, MAILBOX_AT + Vector3(0, 0.5, 0)), Vector3(0.06, 1.0, 0.06), WOOD)
	_build.box(at(house, MAILBOX_AT + Vector3(0, 1.1, 0)), Vector3(0.3, 0.25, 0.45), Color(0.2, 0.35, 0.7))
	var side := -1.0 if house == LEFT else 1.0
	var wagon := _build.body(Vector3(side * WAGON_X, 0, WAGON_Z))
	_build.shape(wagon, WAGON_SIZE)
	wagon.get_child(0).position.y = WAGON_SIZE.y / 2 + 0.25
	var parts := [[Vector3(0, 0.75, 0), Vector3(WAGON_SIZE.x, 0.7, WAGON_SIZE.z), WAGON],
		[Vector3(0, 1.35, -0.4), Vector3(WAGON_SIZE.x - 0.1, 0.55, 3.2), WAGON_ROOF]]
	# The roof rack: two rails and three bars over the roof.
	for rx: float in [-0.75, 0.75]:
		parts.append([Vector3(rx, WAGON_SIZE.y + 0.2, -0.4), Vector3(0.05, 0.05, 3.0), Color(0.2, 0.2, 0.22)])
	for rz: float in [-1.6, -0.4, 0.8]:
		parts.append([Vector3(0, WAGON_SIZE.y + 0.22, rz), Vector3(1.6, 0.04, 0.05), Color(0.2, 0.2, 0.22)])
	for part: Array in parts:
		var mesh := BoxMesh.new()
		mesh.size = part[1]
		var piece := MeshInstance3D.new()
		piece.mesh = mesh
		piece.material_override = _build.material(part[2])
		piece.position = part[0]
		wagon.add_child(piece)
	for wheel_at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.position = wheel_at
		wagon.add_child(wheel)
	wagons.append(wagon)


## The ornaments on the shelves and the plates on the kitchen counter; each one that breaks is a fine.
func _fragile(house: int) -> void:
	for unit: Dictionary in SHELVES:
		var placed := unit.duplicate()
		placed.at = at(house, unit.at)
		for piece: Array in OrnamentLayout.shelf_boxes(placed):
			_build.box(piece[0], piece[1], WOOD)
	for spot: Dictionary in ornament_places(case_seed, house):
		var ornament: Ornament = OrnamentLayout.KINDS[spot.kind].instantiate()
		ornament.position = spot.at
		ornament.rotation.y = spot.turn
		add_child(ornament)
		ornament.broken.connect(_on_ornament_broken.bind(house))
		ornaments[house].append(ornament)


## Every ornament of a house: [{"kind", "at", "turn"}], the same for the same seed.
static func ornament_places(seed_value: int, house: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["wrong house ornaments", seed_value, house])
	var result := []
	for unit: Dictionary in SHELVES:
		var along := Vector3.RIGHT if unit.along == "x" else Vector3.BACK
		var count := floori(unit.width / OrnamentLayout.SPACING)
		for level: float in OrnamentLayout.SHELF_LEVELS:
			for i in count:
				var offset: float = (i - (count - 1) / 2.0) * OrnamentLayout.SPACING
				_add(result, rng, rng.randi_range(0, OrnamentLayout.KINDS.size() - 1),
					at(house, unit.at + along * offset + Vector3.UP * level))
	for i in COUNTER_PLATES:
		var offset := (i - (COUNTER_PLATES - 1) / 2.0) * 0.4
		_add(result, rng, OrnamentLayout.PLATE, at(house, COUNTER_AT + Vector3(offset, 0.9, 0)))
	return result


static func _add(result: Array, rng: RandomNumberGenerator, kind: int, surface: Vector3) -> void:
	result.append({"kind": kind, "at": surface + Vector3.UP * (OrnamentLayout.HALF_HEIGHTS[kind] + 0.005),
		"turn": rng.randf() * TAU})


func _on_ornament_broken(where: Vector3, house: int) -> void:
	broken[house] += 1
	if house == chola_house():
		fines += Ornament.FINE * CHOLA_FINES
		chola.saw(where)
	else:
		fines += Ornament.FINE
