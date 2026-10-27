class_name Rink
extends Node3D

## The ice rink "Patinódromo Resbalón" as a place to raid (docs/diseno/allanamiento-pista.md, step 1): a hall on its lot
## in the city, the front to +Z. By the door, the skate rental with the till, the skate rack and the lost and found box,
## the trophy case, and the bar with the hot chocolate machine. In the middle the ice, behind low boards with glass
## panels on the front ones, two gates, the resurfacer parked in a corner and the skating penguin; the stands along the
## west side and the DJ booth on the east one, the scoreboard and the mirror ball overhead. At the back, along a
## corridor, the locker room, the cold room with its ice blocks and compressor, and the owner's office, locked with the
## till's key. Something thrown hard at a glass panel or at the trophy case breaks it, a fine each. The ice, the skates
## and the resurfacer (RinkIce, step 2). Doña Pirueta skates her round and fills her complaint; her song at the DJ
## booth takes her off to dance (step 3). Copito tells whoever brings him a full hot chocolate what he saw (step 4).
## The case is one of its stories (STORIES), drawn with the seed, run by the same RaidCase as the other places (step
## 5). Every number here is (propuesta).

signal glass_broken(index: int)
signal trophies_broken

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const PENGUIN_MODEL := preload("res://assets/models/skating_penguin.glb")
const COCOA_MODEL := preload("res://assets/models/cocoa_machine.glb")
const OWNER_SCENE := preload("res://scenes/npc/rink_owner.tscn")
const CUP_SCENE := preload("res://scenes/props/cocoa_cup.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the rink can be suspected of (allanamiento-pista.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["ice_surprise", "resurfacer_smuggling", "fixed_match", "golden_skate", "stolen_power",
	"real_sequins"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_RINK_TIP_B", "BRIEF_TIP_C", "BRIEF_RINK_TIP_D",
	"BRIEF_RINK_TIP_E"]
## The stories the rink can tell, like Fair.STORIES: what the comisario says once it's guessed, its "find it" row, what
## it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist rows of its
## extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras.
const STORIES := {
	"ice_surprise": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_ICE_SURPRISE_B", "BRIEF_ICE_SURPRISE_C", "BRIEF_ICE_SURPRISE_D"],
		"find": "OBJ_FIND_ICE_BLOCK",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/rink_ice_block.tscn"),
			preload("res://scenes/props/rink_jeweler_list.tscn"), preload("res://scenes/props/ice_chisel.tscn")],
		"half_heights": [0.25, 0.003, 0.025],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_JEWELER_LIST", "OBJ_EXTRA_ICE_CHISEL"],
		"rig": preload("res://scripts/case/rink/ice_surprise_rig.gd"),
	},
	"resurfacer_smuggling": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_RESURFACER_SMUGGLING_B", "BRIEF_RESURFACER_SMUGGLING_C",
			"BRIEF_RESURFACER_SMUGGLING_D"],
		"find": "OBJ_FIND_PERFUME_BOX",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/rink_perfume_box.tscn"),
			preload("res://scenes/props/rink_client_list.tscn"), preload("res://scenes/props/rink_funnel.tscn")],
		"half_heights": [0.17, 0.003, 0.12],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_CLIENT_LIST", "OBJ_EXTRA_FUNNEL"],
		"rig": preload("res://scripts/case/rink/resurfacer_smuggling_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the floor of the lobby, the corridor and by the stands.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(1.5, FLOOR_TOP, 11.0), Vector3(-9.0, FLOOR_TOP, 9.5), Vector3(11.0, FLOOR_TOP, 8.2),
	Vector3(0.0, FLOOR_TOP, -9.0), Vector3(-12.0, FLOOR_TOP, -9.0), Vector3(18.5, FLOOR_TOP, 5.0),
]
const SCOREBOARD_MODEL := preload("res://assets/models/rink_scoreboard.glb")
const HALF_X := 22.0
const HALF_Z := 15.0
const WALL_TOP := 8.0
const BUILDING_TOP := 9.0
const FLOOR_TOP := 0.06
## The ice, a little over the floor, and how little it grips.
const ICE_TOP := 0.08
const ICE_HALF_X := 15.0
const ICE_Z0 := -8.0
const ICE_Z1 := 7.0
const ICE_FRICTION := 0.05
## The boards around the ice, with the two gates on the front ones.
const BOARD_HEIGHT := 1.1
const BOARD_THICK := 0.2
const GATES: Array[float] = [-8.0, 8.0]
const GATE_WIDTH := 1.6
## The glass panels on the front boards: their middles, size, how fast a prop breaks one and the fine.
const GLASS_XS: Array[float] = [-13.4, -10.8, -4.0, 4.0, 10.8, 13.4]
const GLASS_SIZE := Vector2(2.4, 1.2)
const GLASS_SPEED := 3.0
const GLASS_FINE := 30
## The trophy case on the front wall, its trophies and the fine for each one.
const TROPHY_CASE_AT := Vector3(-5.0, FLOOR_TOP, 14.5)
const TROPHY_CASE_SIZE := Vector3(3.0, 1.8, 0.5)
const TROPHIES := 4
const TROPHY_FINE := 10
## The skate rental with the till, the skate rack behind it and the lost and found box; the bar with the hot chocolate
## machine on the east side.
const RENTAL_AT := Vector3(-14.0, FLOOR_TOP, 12.6)
const RENTAL_SIZE := Vector3(5.0, 1.1, 0.8)
const RACK_AT := Vector3(-14.0, FLOOR_TOP, 9.6)
const RACK_SIZE := Vector3(4.0, 1.8, 0.5)
const LOST_AT := Vector3(-9.5, FLOOR_TOP, 14.2)
const LOST_SIZE := Vector3(0.8, 0.5, 0.6)
const BAR_AT := Vector3(14.0, FLOOR_TOP, 12.6)
const BAR_SIZE := Vector3(4.0, 1.1, 0.8)
const COCOA_AT := Vector3(15.3, FLOOR_TOP + 1.1, 12.6)
const COCOA_SIZE := Vector3(0.5, 0.8, 0.45)
## Where a poured cup lands, in front of the machine, and how many cups can be around at once.
const CUP_AT := COCOA_AT + Vector3(0, 0.08, 0.34)
const MAX_CUPS := 3
## Copito, by the east gate, shivering.
const COPITO_AT := Vector3(6.0, FLOOR_TOP, 8.6)
## The resurfacer parked on the ice and the penguin the kids push around.
const RESURFACER_AT := Vector3(12.0, ICE_TOP, -5.0)
## The resurfacer's button, on the outside of the east boards.
const RESURFACER_BUTTON_AT := Vector3(ICE_HALF_X + 0.2, FLOOR_TOP + 0.9, -6.5)
## The skates for rent, on the rental's counter.
const SKATES_AT := Vector3(-15.4, FLOOR_TOP + 1.1, 12.6)
const PENGUIN_AT := Vector3(-10.0, ICE_TOP, 3.0)
## The stands along the west side: STAND_TIERS tiers STAND_DEPTH deep, each STAND_RISE higher, hollow underneath.
const STAND_X := -16.2
const STAND_TIERS := 4
const STAND_DEPTH := 1.3
const STAND_RISE := 0.45
const STAND_HALF_Z := 6.0
## The DJ booth on the east side, its crowd side to the ice.
const DJ_AT := Vector3(19.0, FLOOR_TOP, -2.0)
## Doña Pirueta's round on the ice, back and forth, and where she dances her routine when her song plays.
const OWNER_ROUTE: Array[Vector3] = [
	Vector3(-9.0, ICE_TOP, 2.0), Vector3(-9.0, ICE_TOP, -3.0), Vector3(9.0, ICE_TOP, -3.0), Vector3(9.0, ICE_TOP, 2.0),
]
const DANCE_SPOT := Vector3(0.0, ICE_TOP, -0.5)
const DANCE_TIME := 20.0
## How fast she spins while dancing, in turns a second.
const SPIN := 0.8
## "¡Con zapatos no!": a cop on the ice without skates (once per cop), and something heavy (HEAVY_KG or more) falling
## on the ice.
const SAW_SHOES := 5.0
const SAW_HEAVY := 10.0
const HEAVY_KG := 5.0
const SHOES_CHECK_EVERY := 0.5
## The third song: she knows what's going on.
const CAUGHT_ON := 10.0
## The back rooms behind the corridor: the wall along it with its doors, and the walls between the rooms.
const BACK_Z := -10.0
const LOCKER_DOOR_X := -15.0
const COLD_DOOR_X := -1.0
const OFFICE_DOOR_X := 14.0
const LOCKERS_EAST := -8.0
const COLD_EAST := 6.0
const COMPRESSOR_AT := Vector3(4.0, FLOOR_TOP, -13.5)
const COMPRESSOR_SIZE := Vector3(1.4, 1.6, 1.0)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "under_rink_stands", "at": Vector3(-19.4, FLOOR_TOP, 5.3), "heavy": true},
	{"id": "in_rink_cold_room", "at": Vector3(-1.5, FLOOR_TOP, -12.0), "heavy": true},
	{"id": "behind_compressor", "at": Vector3(4.0, FLOOR_TOP, -14.5), "heavy": true},
	{"id": "in_rink_office", "at": Vector3(12.0, FLOOR_TOP, -13.5), "heavy": true},
	{"id": "behind_dj_booth", "at": Vector3(21.0, FLOOR_TOP, -2.0), "heavy": true},
	{"id": "in_rink_locker_room", "at": Vector3(-11.0, FLOOR_TOP, -11.2), "heavy": true},
	# Inside the penguin's body, on its sled: only its head and the bar are solid.
	{"id": "in_skating_penguin", "at": Vector3(-10.0, ICE_TOP + 0.08, 3.0), "heavy": false},
	{"id": "in_resurfacer_tank", "at": Vector3(12.0, ICE_TOP + 1.56, -5.55), "heavy": false},
	{"id": "on_cocoa_machine", "at": Vector3(15.3, FLOOR_TOP + 1.9, 12.6), "heavy": false},
	{"id": "on_skate_rack", "at": Vector3(-14.8, FLOOR_TOP + 0.95, 9.6), "heavy": false},
	{"id": "in_lost_and_found", "at": Vector3(-9.5, FLOOR_TOP + 0.05, 14.2), "heavy": false},
	{"id": "in_trophy_case", "at": Vector3(-5.8, FLOOR_TOP + 0.05, 14.5), "heavy": false},
]

const OUTSIDE := Color(0.78, 0.86, 0.92)
const RUBBER := Color(0.22, 0.24, 0.3)
const ICE := Color(0.86, 0.94, 1.0)
const BOARD := Color(0.95, 0.95, 0.97)
const BOARD_STRIPE := Color(0.2, 0.45, 0.85)
const WALL_IN := Color(0.62, 0.74, 0.86)
const WOOD := Color(0.55, 0.36, 0.22)
const COLD := Color(0.7, 0.85, 0.95)
const TILE := Color(0.85, 0.88, 0.9)
const GOLD := Color(0.95, 0.78, 0.3)
const DARK := Color(0.12, 0.12, 0.15)
const SKATES: Array[Color] = [Color(0.95, 0.95, 0.95), Color(0.15, 0.15, 0.18), Color(0.9, 0.4, 0.6)]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
var resurfacer: IceResurfacer
var resurfacer_button: PushButton
var ice: RinkIce
var skate_rental: SkateRental
var penguin: StaticBody3D
## The DJ booth with her song: Doña Pirueta's distraction (step 3).
var song: DjSong
## The bar's hot chocolate button and Copito, the gossip (step 4).
var cocoa_button: PushButton
var copito: ResurfacerDriver
var cups: Array[CocoaCup] = []
## Doña Pirueta, the owner, and her complaint bar.
var owner_npc: FloorBoss
var complaint_bar: ProgressBar
## The cops she already scolded for their shoes (id -> true).
var shoes_seen := {}
var _shoes_check := 0.0
var _spin := 0.0
var glass_panels: Array[StaticBody3D] = []
var trophies_cracked := false
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
var car: PatrolCar
## Money taken off the case pay: the glass panels and the trophies.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## Same seed, same rink: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: RinkRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var _build: PlaceBuilder


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	if story_id == "":
		story_id = pick_story(case_seed, OS.get_cmdline_user_args())
	car = $PatrolCar
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
	ice = RinkIce.new()
	ice.name = "RinkIce"
	ice.rink = self
	add_child(ice)
	_build_shell()
	_build_ice()
	_build_stands()
	_build_lobby()
	_build_back()
	_place_owner()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("rink")
	station_parking = city.transform * CityLayout.parking("station")
	_park_car()
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "rink", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = owner_npc
	raid.owner_id = "rink"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The rink's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_RINK",
		"guess_key": "OBJ_GUESS_RINK",
		"broken_key": "OBJ_BROKEN_RINK",
		"complaint_key": "OBJ_COMPLAINT_RINK",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": owner_npc.complaint,
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


## What Doña Pirueta lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Copito saw: where she hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		owner_npc.slips.append(tr("PIRUETA_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	owner_npc.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	copito.clue = tr("CLUE_COPITO") % where
	copito.clue_speech = tr("COPITO_CLUE_" + story_id) % where
	copito.told.connect(raid.add_clue)


func _park_car() -> void:
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))


## Whether `at` lies over the ice.
static func on_ice(at: Vector3) -> bool:
	return absf(at.x) < ICE_HALF_X and at.z > ICE_Z0 and at.z < ICE_Z1


## The outer walls with the open entrance, the floor, the roof, the sign with its penguin and the hall's lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, RUBBER)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, WALL_IN.darkened(0.3))
	_build.wall_at("x", HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [0.0], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_build.mesh_box(Vector3(0, 4.4, HALF_Z + 0.1), Vector3(14.0, 1.6, 0.1), BOARD_STRIPE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_RINK"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(1.0, 4.4, HALF_Z + 0.17)
	$Built.add_child(sign_label)
	var mascot := _model(PENGUIN_MODEL, Vector3(-6.2, 3.7, HALF_Z + 0.4))
	mascot.scale = Vector3.ONE * 1.2
	for x: float in [-14.0, -5.0, 5.0, 14.0]:
		for z: float in [-4.0, 4.0]:
			var lamp := _build.light(Vector3(x, WALL_TOP - 1.0, z))
			lamp.light_color = Color(0.9, 0.95, 1.0)
			lamp.omni_range = 12.0
			lamp.light_energy = 0.9


## The ice that hardly grips, the boards around it with the gates and the glass panels, the resurfacer, the penguin, the
## scoreboard and the mirror ball.
func _build_ice() -> void:
	var ice := _build.body(Vector3(0, ICE_TOP - PlaceBuilder.SLAB / 2, (ICE_Z0 + ICE_Z1) / 2))
	var slippery := PhysicsMaterial.new()
	slippery.friction = ICE_FRICTION
	ice.physics_material_override = slippery
	ice.name = "Ice"
	var size := Vector3(ICE_HALF_X * 2, PlaceBuilder.SLAB, ICE_Z1 - ICE_Z0)
	_build.shape(ice, size)
	var look := MeshInstance3D.new()
	var slab := BoxMesh.new()
	slab.size = size
	look.mesh = slab
	var shine := StandardMaterial3D.new()
	shine.albedo_color = ICE
	shine.roughness = 0.08
	shine.metallic_specular = 0.9
	look.material_override = shine
	ice.add_child(look)
	var x0 := -ICE_HALF_X - BOARD_THICK / 2
	var x1 := ICE_HALF_X + BOARD_THICK / 2
	_board_x(ICE_Z0, x0, x1)
	var from := x0
	for gate in GATES:
		_board_x(ICE_Z1, from, gate - GATE_WIDTH / 2)
		from = gate + GATE_WIDTH / 2
	_board_x(ICE_Z1, from, x1)
	for x: float in [x0, x1]:
		_build.box(Vector3(x, FLOOR_TOP + BOARD_HEIGHT / 2, (ICE_Z0 + ICE_Z1) / 2),
			Vector3(BOARD_THICK, BOARD_HEIGHT, ICE_Z1 - ICE_Z0), BOARD)
		_build.mesh_box(Vector3(x, FLOOR_TOP + BOARD_HEIGHT - 0.05, (ICE_Z0 + ICE_Z1) / 2),
			Vector3(BOARD_THICK + 0.02, 0.1, ICE_Z1 - ICE_Z0), BOARD_STRIPE)
	for i in GLASS_XS.size():
		glass_panels.append(_glass_panel(i))
	resurfacer = IceResurfacer.new()
	resurfacer.name = "Resurfacer"
	resurfacer.position = RESURFACER_AT
	resurfacer.rotation.y = -PI / 2
	add_child(resurfacer)
	resurfacer_button = PushButton.new()
	resurfacer_button.prompt = "PROMPT_RINK_RESURFACER"
	resurfacer_button.color = Color(0.2, 0.45, 0.9)
	resurfacer_button.position = RESURFACER_BUTTON_AT
	resurfacer_button.rotation.y = PI / 2
	add_child(resurfacer_button)
	resurfacer_button.pressed.connect(func(_cop: Cop) -> void: resurfacer.start())
	penguin = _build.body(PENGUIN_AT)
	penguin.name = "Penguin"
	_build.shape(penguin, Vector3(0.5, 0.4, 0.5))
	(penguin.get_child(0) as Node3D).position.y = 0.95
	penguin.add_child(PENGUIN_MODEL.instantiate())
	_model(SCOREBOARD_MODEL, Vector3(0, 5.2, ICE_Z0 + 0.5))
	var ball := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.45
	sphere.height = 0.9
	ball.mesh = sphere
	var mirror := StandardMaterial3D.new()
	mirror.albedo_color = Color(0.85, 0.85, 0.9)
	mirror.metallic = 1.0
	mirror.roughness = 0.15
	ball.material_override = mirror
	ball.position = Vector3(0, WALL_TOP - 1.4, 0)
	$Built.add_child(ball)
	_build.mesh_box(Vector3(0, WALL_TOP - 0.5, 0), Vector3(0.03, 1.0, 0.03), DARK)


## A front or back board along x at z, from x0 to x1, with its blue stripe.
func _board_x(z: float, x0: float, x1: float) -> void:
	var mid := (x0 + x1) / 2
	_build.box(Vector3(mid, FLOOR_TOP + BOARD_HEIGHT / 2, z), Vector3(x1 - x0, BOARD_HEIGHT, BOARD_THICK), BOARD)
	_build.mesh_box(Vector3(mid, FLOOR_TOP + BOARD_HEIGHT - 0.05, z), Vector3(x1 - x0, 0.1, BOARD_THICK + 0.02),
		BOARD_STRIPE)


## Glass panel `index` on the front boards: solid until something thrown hard breaks it.
func _glass_panel(index: int) -> StaticBody3D:
	var center := Vector3(GLASS_XS[index], FLOOR_TOP + BOARD_HEIGHT + GLASS_SIZE.y / 2, ICE_Z1)
	var panel := _build.body(center)
	panel.name = "Glass%d" % index
	var size := Vector3(GLASS_SIZE.x - 0.1, GLASS_SIZE.y, 0.04)
	_build.shape(panel, size)
	var look := MeshInstance3D.new()
	var pane := BoxMesh.new()
	pane.size = size
	look.mesh = pane
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.75, 0.9, 1.0, 0.45)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	look.material_override = glass
	panel.add_child(look)
	var area := _area(center, Vector3(GLASS_SIZE.x, GLASS_SIZE.y, 0.6))
	area.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > GLASS_SPEED:
			break_glass(index))
	return panel


## The stands along the west wall: tiers that rise away from the ice, each a plank over a riser, hollow underneath.
func _build_stands() -> void:
	for i in STAND_TIERS:
		var top := FLOOR_TOP + (i + 1) * STAND_RISE
		var east := STAND_X - i * STAND_DEPTH
		var mid := east - STAND_DEPTH / 2
		_build.box(Vector3(mid, top - 0.05, 0), Vector3(STAND_DEPTH, 0.1, STAND_HALF_Z * 2), WOOD)
		_build.box(Vector3(east - 0.05, (FLOOR_TOP + top - 0.1) / 2, 0), Vector3(0.1, top - 0.1 - FLOOR_TOP,
			STAND_HALF_Z * 2), BOARD_STRIPE.darkened(0.3))
	song = DjSong.new()
	song.name = "DjSong"
	song.position = DJ_AT
	song.rotation.y = -PI / 2
	add_child(song)


## By the door: the skate rental with the till, the rack and the lost and found box, the trophy case, and the bar with
## the hot chocolate machine.
func _build_lobby() -> void:
	_build.open_box(RENTAL_AT, RENTAL_SIZE, "-z", WOOD)
	till = Till.new()
	till.position = RENTAL_AT + Vector3(1.4, RENTAL_SIZE.y + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_RINK"
	add_child(till)
	skate_rental = SkateRental.new()
	skate_rental.ice = ice
	skate_rental.position = SKATES_AT
	add_child(skate_rental)
	_build.open_box(RACK_AT, RACK_SIZE, "+z", WOOD.darkened(0.2))
	_build.box(RACK_AT + Vector3(0, 0.9, 0), Vector3(RACK_SIZE.x - 0.1, 0.05, RACK_SIZE.z - 0.1), WOOD.darkened(0.2))
	for i in 10:
		var shelf := 0.05 if i < 5 else 0.95
		_build.mesh_box(RACK_AT + Vector3(-1.6 + (i % 5) * 0.8, shelf + 0.1, 0), Vector3(0.22, 0.2, 0.3),
			SKATES[i % SKATES.size()])
	_build.open_box(LOST_AT, LOST_SIZE, "top", Color(0.7, 0.55, 0.35))
	var lost := Label3D.new()
	lost.text = "RINK_LOST_AND_FOUND"
	lost.font_size = 32
	lost.pixel_size = 0.01
	lost.position = LOST_AT + Vector3(0, LOST_SIZE.y + 0.25, 0)
	lost.rotation.y = PI
	$Built.add_child(lost)
	_build.open_box(TROPHY_CASE_AT, TROPHY_CASE_SIZE, "-z", WOOD)
	_build.box(TROPHY_CASE_AT + Vector3(0, 0.9, 0), Vector3(TROPHY_CASE_SIZE.x - 0.1, 0.05, TROPHY_CASE_SIZE.z - 0.1),
		WOOD)
	for i in TROPHIES:
		var cup := CylinderMesh.new()
		cup.top_radius = 0.12
		cup.bottom_radius = 0.05
		cup.height = 0.3
		_build.mesh(cup, TROPHY_CASE_AT + Vector3(-1.05 + i * 0.7, 1.1, 0), GOLD)
	var front := MeshInstance3D.new()
	var pane := BoxMesh.new()
	pane.size = Vector3(TROPHY_CASE_SIZE.x, TROPHY_CASE_SIZE.y, 0.02)
	front.mesh = pane
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.8, 0.92, 1.0, 0.25)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	front.material_override = glass
	front.position = TROPHY_CASE_AT + Vector3(0, TROPHY_CASE_SIZE.y / 2, -TROPHY_CASE_SIZE.z / 2)
	$Built.add_child(front)
	var area := _area(TROPHY_CASE_AT + Vector3(0, TROPHY_CASE_SIZE.y / 2, -TROPHY_CASE_SIZE.z / 2),
		Vector3(TROPHY_CASE_SIZE.x, TROPHY_CASE_SIZE.y, 0.6))
	area.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > GLASS_SPEED:
			break_trophies())
	_build.open_box(BAR_AT, BAR_SIZE, "-z", BOARD_STRIPE.darkened(0.2))
	_model(COCOA_MODEL, COCOA_AT)
	_build.shape(_build.body(COCOA_AT + Vector3(0, COCOA_SIZE.y / 2, 0)), COCOA_SIZE)
	cocoa_button = PushButton.new()
	cocoa_button.prompt = "PROMPT_RINK_COCOA"
	cocoa_button.color = Color(0.85, 0.25, 0.15)
	cocoa_button.position = COCOA_AT + Vector3(0.17, 0.38, COCOA_SIZE.z / 2 + 0.04)
	add_child(cocoa_button)
	cocoa_button.pressed.connect(pour_cocoa)
	copito = ResurfacerDriver.new()
	copito.name = "Copito"
	copito.position = COPITO_AT
	add_child(copito)
	for x: float in [11.5, 16.0]:
		_build.box(Vector3(x, FLOOR_TOP + 0.72, 9.6), Vector3(0.8, 0.06, 0.8), BOARD)
		_build.box(Vector3(x, FLOOR_TOP + 0.35, 9.6), Vector3(0.08, 0.7, 0.08), DARK)


## Behind the corridor: the locker room, the cold room with the ice blocks and the compressor, and the office, locked.
func _build_back() -> void:
	_build.wall_at("x", BACK_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [LOCKER_DOOR_X, COLD_DOOR_X, OFFICE_DOOR_X], WALL_IN)
	_build.wall_at("z", LOCKERS_EAST, -HALF_Z, BACK_Z, 0.0, WALL_TOP, [], TILE)
	_build.wall_at("z", COLD_EAST, -HALF_Z, BACK_Z, 0.0, WALL_TOP, [], COLD)
	for i in 12:
		var x := -21.2 + i * 1.0
		_build.box(Vector3(x, FLOOR_TOP + 0.95, -14.6), Vector3(0.95, 1.9, 0.6), BOARD_STRIPE if i % 2 else BOARD)
	_build.box(Vector3(-15.0, FLOOR_TOP + 0.22, -12.6), Vector3(5.0, 0.08, 0.4), WOOD)
	for i in 8:
		var at := Vector3(-6.4 + (i % 4) * 0.9, FLOOR_TOP + 0.4 + floorf(i / 4.0) * 0.8, -14.3)
		_build.box(at, Vector3(0.8, 0.8, 0.8), COLD)
	_build.box(COMPRESSOR_AT + Vector3(0, COMPRESSOR_SIZE.y / 2, 0), COMPRESSOR_SIZE, Color(0.5, 0.55, 0.6))
	var cold := _build.light(Vector3(-1.0, 3.0, -12.5))
	cold.light_color = Color(0.7, 0.85, 1.0)
	_build.legs(Vector3(17.0, FLOOR_TOP, -13.0), Vector2(2.0, 1.0), 0.75, WOOD)
	_build.box(Vector3(17.0, FLOOR_TOP + 0.78, -13.0), Vector3(2.0, 0.06, 1.0), WOOD)
	_build.light(Vector3(-15.0, 3.0, -12.5))
	_build.light(Vector3(14.0, 3.0, -12.5))
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)


## Doña Pirueta skating her round, what she can't stand to see, her song and the complaint bar.
func _place_owner() -> void:
	owner_npc = OWNER_SCENE.instantiate()
	owner_npc.name = "DonaPirueta"
	owner_npc.route = OWNER_ROUTE
	owner_npc.printer_spot = DANCE_SPOT
	owner_npc.printer = song
	owner_npc.fix_time = DANCE_TIME
	add_child(owner_npc)
	owner_npc.start_at(0)
	office_door.broken.connect(owner_npc.door_broken)
	owner_npc.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_RINK"))
	till.opened.connect(func(at: Vector3) -> void: owner_npc.saw(at, FloorBoss.SAW_TILL))
	song.caught_on.connect(func() -> void: owner_npc.scold(CAUGHT_ON, "PIRUETA_CAUGHT_ON"))
	var thuds := _area(Vector3(0, ICE_TOP + 0.3, (ICE_Z0 + ICE_Z1) / 2), Vector3(ICE_HALF_X * 2, 0.6, ICE_Z1 - ICE_Z0))
	thuds.body_entered.connect(_on_ice_hit)
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
	owner_npc.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Something heavy falling on the ice: "¡Me lo van a partir!".
func _on_ice_hit(body: Node3D) -> void:
	var item := body as RigidBody3D
	if item and item.mass >= HEAVY_KG and item.linear_velocity.y < -2.0:
		owner_npc.saw(item.global_position, SAW_HEAVY, "PIRUETA_ICE_HIT")


func _physics_process(delta: float) -> void:
	if owner_npc.is_fixing():
		# Her routine: round and round in the middle of the ice, eyes closed.
		_spin += SPIN * TAU * delta
		owner_npc.fix_facing = owner_npc.global_position + Vector3(sin(_spin), 0, cos(_spin))
	_shoes_check += delta
	if _shoes_check < SHOES_CHECK_EVERY:
		return
	_shoes_check = 0.0
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop == null or shoes_seen.has(cop.get_instance_id()) or ice.has_skates(cop) or not ice.is_on_ice(cop):
			continue
		if owner_npc.saw(cop.global_position + Vector3.UP, SAW_SHOES, "PIRUETA_SHOES"):
			shoes_seen[cop.get_instance_id()] = true


## The bar's machine pours a hot chocolate in front of it, if there aren't MAX_CUPS around already (online, the host's
## cup is the one everyone sees: PropSync).
func pour_cocoa(cop: Cop = null) -> CocoaCup:
	var left: Array[CocoaCup] = []
	for cup: Variant in cups:
		if is_instance_valid(cup) and not (cup as CocoaCup).is_queued_for_deletion():
			left.append(cup)
	cups = left
	if cups.size() >= MAX_CUPS:
		if cop:
			cop.show_hint("HINT_RINK_COCOA_MAX")
		return null
	if not multiplayer.is_server():
		return null
	var cup: CocoaCup = CUP_SCENE.instantiate()
	cup.position = CUP_AT + Vector3(-0.16 * cups.size(), 0, 0)
	add_child(cup)
	cups.append(cup)
	return cup


## Breaks glass panel `index`, once: a fine, and the panel is gone.
func break_glass(index: int) -> void:
	var panel := glass_panels[index]
	if panel == null:
		return
	glass_panels[index] = null
	broken_goods += 1
	fines += GLASS_FINE
	raid.float_label("-%d" % GLASS_FINE, to_global(panel.position + Vector3.UP), Color(1, 0.3, 0.25))
	_say(panel.position + Vector3(0, 1.2, 0), "RINK_GLASS_BROKEN")
	panel.queue_free()
	glass_broken.emit(index)


func glass_left() -> int:
	return glass_panels.filter(func(panel: StaticBody3D) -> bool: return panel != null).size()


## Breaks the trophy case, once: a fine for each trophy.
func break_trophies() -> void:
	if trophies_cracked:
		return
	trophies_cracked = true
	broken_goods += 1
	fines += TROPHY_FINE * TROPHIES
	raid.float_label("-%d" % (TROPHY_FINE * TROPHIES), to_global(TROPHY_CASE_AT + Vector3.UP * 2.0),
		Color(1, 0.3, 0.25))
	_say(TROPHY_CASE_AT + Vector3(0, 2.4, -0.5), "RINK_TROPHIES_BROKEN")
	trophies_broken.emit()


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
