class_name CarWash
extends Node3D

## The car wash "La Espuma Loca" as a place to raid (docs/diseno/allanamiento-lavadero.md, step 1): a long hall on its
## lot in the city, the front to +Z and open wide in the middle. Through the middle runs the wash tunnel along X, with
## its conveyor, the jets arch at the mouth, three brushes, the foam curtain and the blower at the end; two customers'
## cars wait in line at the west end, the first one with its trunk open, and the token machine with the till stands by
## the mouth. Past the end, the drying area with the towels on their line, the rag basket and the toolbox. By the front,
## the vacuums, the wax shelf and the inflatable dancing man. At the back, behind a wall, the storeroom (the foam tank,
## the boiler, the shampoo drums and the pile of tires) and the owner's office, locked with the till's key. Something
## thrown hard at a car's windshield or at the wax shelf breaks it, a fine each. The tunnel at work (WashTunnel, step
## 2). Don Chorro walks his round by the tunnel and fills his complaint; the premium wash at the token machine sends the
## first car through the tunnel and him off to dry it (step 3). Pompita by the exit talks to whoever brings him a dry
## chamois from the rag basket (step 4). The case is one of its stories (STORIES), drawn with the seed, run by the
## same RaidCase as the other places (step 5). Every number here is (propuesta).

signal windshield_broken(index: int)
signal wax_broken

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const BRUSH_MODEL := preload("res://assets/models/wash_brush.glb")
const JETS_MODEL := preload("res://assets/models/wash_jets.glb")
const BLOWER_MODEL := preload("res://assets/models/wash_blower.glb")
const TOKEN_MODEL := preload("res://assets/models/token_machine.glb")
const VACUUM_MODEL := preload("res://assets/models/vacuum_column.glb")
const INFLATABLE_MODEL := preload("res://assets/models/inflatable_man.glb")
const BOILER_MODEL := preload("res://assets/models/carwash_boiler.glb")
const OWNER_SCENE := preload("res://scenes/npc/carwash_owner.tscn")
const CHAMOIS_SCENE := preload("res://scenes/props/chamois.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the car wash can be suspected of (allanamiento-lavadero.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["laundered_money", "stolen_car", "fake_shampoo", "brush_painting", "meter_coins",
	"smuggled_parrot"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_CARWASH_TIP_B", "BRIEF_TIP_C", "BRIEF_CARWASH_TIP_D",
	"BRIEF_CARWASH_TIP_E"]
## The stories the car wash can tell, like Rink.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist rows
## of its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras.
const STORIES := {
	"laundered_money": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_LAUNDERED_MONEY_B", "BRIEF_LAUNDERED_MONEY_C", "BRIEF_LAUNDERED_MONEY_D"],
		"find": "OBJ_FIND_CASH_BAG",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/carwash_cash_bag.tscn"),
			preload("res://scenes/props/carwash_ledger.tscn"), preload("res://scenes/props/carwash_iron.tscn")],
		"half_heights": [0.2, 0.01, 0.07],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_TWO_BOOKS", "OBJ_EXTRA_IRON"],
		"rig": preload("res://scripts/case/carwash/laundered_money_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the floor by the front, the storeroom and the drying area.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-3.0, FLOOR_TOP, 6.5), Vector3(4.5, FLOOR_TOP, 7.5), Vector3(-16.0, FLOOR_TOP, 4.0),
	Vector3(0.0, FLOOR_TOP, -7.5), Vector3(13.5, FLOOR_TOP, -1.0), Vector3(-12.0, FLOOR_TOP, -3.5),
]
const HALF_X := 20.0
const HALF_Z := 11.0
const WALL_TOP := 5.5
const BUILDING_TOP := 6.0
const FLOOR_TOP := 0.06
## The front's wide opening, from -FRONT_GAP to FRONT_GAP, up to FRONT_LINTEL.
const FRONT_GAP := 6.0
const FRONT_LINTEL := 4.0
## The wash tunnel along X: from TUNNEL_X0 to TUNNEL_X1, its walls at ±TUNNEL_HALF_Z, its roof at TUNNEL_TOP. The
## conveyor down its middle, CONVEYOR_HALF_Z each side and CONVEYOR_TOP high.
const TUNNEL_X0 := -8.0
const TUNNEL_X1 := 8.0
const TUNNEL_HALF_Z := 2.2
const TUNNEL_TOP := 3.4
const CONVEYOR_HALF_Z := 1.2
const CONVEYOR_TOP := FLOOR_TOP + 0.12
## Along the tunnel: the jets arch, the two side brushes and the top one, the foam curtain and the blower.
const JETS_X := -6.5
const SIDE_BRUSHES: Array[Vector3] = [Vector3(-3.5, FLOOR_TOP, -1.45), Vector3(-3.5, FLOOR_TOP, 1.45)]
const TOP_BRUSH := Vector3(0.5, FLOOR_TOP + 2.25, -1.35)
const CURTAIN_X := 3.5
const BLOWER_X := 6.5
## The customers' cars waiting in line, facing the tunnel (+X); the second one's open trunk; their windshields. The
## first one is the premium wash's (step 3).
const CARS: Array[Vector3] = [Vector3(-11.6, FLOOR_TOP, 0.0), Vector3(-16.9, FLOOR_TOP, 0.0)]
const CAR_SIZE := Vector3(4.6, 1.5, 2.1)
const TRUNK_CAR := 1
const TRUNK_LENGTH := 1.2
const WINDSHIELD_AHEAD := 1.0
const WINDSHIELD_SIZE := Vector3(0.5, 0.6, 1.8)
const HOOD := 2.0
const WINDSHIELD_SPEED := 3.0
const WINDSHIELD_FINE := 30
## The button that starts the tunnel, on a post by its mouth.
const TUNNEL_BUTTON_AT := Vector3(-8.6, FLOOR_TOP + 1.2, 2.7)
## The token machine by the tunnel's mouth, and its till.
const TOKEN_AT := Vector3(-9.0, FLOOR_TOP, 3.4)
const TOKEN_SIZE := Vector3(0.7, 1.6, 0.5)
## The vacuums by the front, the wax shelf on the front wall (its bottles and the fine for each) and the inflatable man.
const VACUUMS: Array[Vector3] = [Vector3(-15.0, FLOOR_TOP, 7.6), Vector3(-12.0, FLOOR_TOP, 7.6)]
const WAX_AT := Vector3(10.0, FLOOR_TOP, 10.5)
const WAX_SIZE := Vector3(3.0, 1.8, 0.45)
const WAX_BOTTLES := 6
const WAX_FINE := 10
const WAX_COLORS: Array[Color] = [Color(0.95, 0.3, 0.3), Color(0.3, 0.6, 0.95), Color(0.95, 0.85, 0.3),
	Color(0.4, 0.85, 0.4), Color(0.85, 0.45, 0.9), Color(0.95, 0.6, 0.25)]
const INFLATABLE_AT := Vector3(15.5, FLOOR_TOP, 8.0)
## The drying area past the tunnel's end: the towel line, the rag basket and the toolbox.
const LINE_Z := 3.6
const LINE_XS: Array[float] = [10.0, 16.0]
const BASKET_AT := Vector3(12.5, FLOOR_TOP, -4.0)
const BASKET_SIZE := Vector3(0.9, 0.6, 0.6)
const TOOLBOX_AT := Vector3(17.5, FLOOR_TOP, -0.5)
const TOOLBOX_SIZE := Vector3(0.6, 0.35, 0.35)
## The rag basket's button, where a chamois lands in front of it, and how many can be around at once. Pompita by the
## tunnel's exit, and the puddles that wet a chamois dropped in them (step 4).
const CHAMOIS_BUTTON_AT := BASKET_AT + Vector3(0.3, BASKET_SIZE.y + 0.04, BASKET_SIZE.z / 2)
const CHAMOIS_AT := BASKET_AT + Vector3(-0.2, 0.12, BASKET_SIZE.z / 2 + 0.35)
const MAX_CHAMOIS := 3
const POMPITA_AT := Vector3(17.0, FLOOR_TOP, 2.2)
const PUDDLES: Array[Vector3] = [Vector3(10.5, FLOOR_TOP, -2.2), Vector3(15.5, FLOOR_TOP, 2.6),
	Vector3(-6.0, FLOOR_TOP, 4.2)]
const PUDDLE_RADIUS := 0.9
const PUDDLE := Color(0.45, 0.65, 0.85, 0.6)
## The back wall with its doors, the wall between the storeroom and the office, and what's in the storeroom.
const BACK_Z := -5.0
const STORE_DOOR_X := -10.0
const OFFICE_DOOR_X := 14.0
const OFFICE_WEST := 9.0
const FOAM_TANK_AT := Vector3(-4.0, FLOOR_TOP, -8.5)
const FOAM_TANK_SIZE := Vector3(1.8, 1.4, 1.8)
const BOILER_AT := Vector3(3.0, FLOOR_TOP, -9.7)
const TIRES_AT := Vector3(-16.0, FLOOR_TOP, -8.5)
const DRUMS_AT := Vector3(-8.0, FLOOR_TOP, -9.8)
## Don Chorro's round: along the tunnel's front side and across its exit, back and forth. Where he dries the premium
## car, facing it, and for how long.
const OWNER_ROUTE: Array[Vector3] = [
	Vector3(-7.0, FLOOR_TOP, 3.2), Vector3(9.0, FLOOR_TOP, 3.2), Vector3(9.0, FLOOR_TOP, -1.5),
]
const DRY_CAR_AT := Vector3(12.5, FLOOR_TOP, 0.0)
const DRY_SPOT := Vector3(12.5, FLOOR_TOP, 1.8)
const DRY_TIME := 20.0
## "¡Eso no se lava así!": a cop he sees in the tunnel (once per cop), and something falling on the drying area's wet
## floor.
const SAW_TUNNEL := 5.0
const SAW_WET_FLOOR := 10.0
const TUNNEL_CHECK_EVERY := 0.5
## The third premium: he knows what's going on.
const CAUGHT_ON := 10.0

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_queue_car_trunk", "at": Vector3(-18.6, FLOOR_TOP + 0.5, 0.0), "heavy": true},
	{"id": "in_foam_tank", "at": Vector3(-4.0, FLOOR_TOP + 0.05, -8.5), "heavy": true},
	{"id": "behind_boiler", "at": Vector3(3.0, FLOOR_TOP, -10.5), "heavy": true},
	{"id": "among_tires", "at": Vector3(-14.3, FLOOR_TOP, -8.5), "heavy": true},
	{"id": "in_carwash_office", "at": Vector3(16.5, FLOOR_TOP, -8.5), "heavy": true},
	{"id": "behind_shampoo_drums", "at": Vector3(-8.0, FLOOR_TOP, -10.6), "heavy": true},
	{"id": "on_token_machine", "at": Vector3(-9.0, FLOOR_TOP + 1.6, 3.4), "heavy": false},
	{"id": "behind_vacuums", "at": Vector3(-13.5, FLOOR_TOP, 8.5), "heavy": false},
	{"id": "in_rag_basket", "at": Vector3(12.5, FLOOR_TOP + 0.05, -4.0), "heavy": false},
	{"id": "on_wax_shelf", "at": Vector3(10.0, FLOOR_TOP + 0.95, 10.5), "heavy": false},
	{"id": "in_inflatable_man", "at": Vector3(15.5, FLOOR_TOP + 0.5, 8.0), "heavy": false},
	{"id": "in_drying_toolbox", "at": Vector3(17.5, FLOOR_TOP + 0.05, -0.5), "heavy": false},
]

const OUTSIDE := Color(0.55, 0.8, 0.95)
const CONCRETE := Color(0.6, 0.62, 0.64)
const WALL_IN := Color(0.85, 0.9, 0.95)
const TUNNEL := Color(0.45, 0.5, 0.58)
const BELT := Color(0.15, 0.15, 0.17)
const FOAM := Color(0.92, 0.96, 1.0)
const STRIPE := Color(0.25, 0.6, 0.95)
const WOOD := Color(0.55, 0.36, 0.22)
const TIRE := Color(0.12, 0.12, 0.14)
const DRUM := Color(0.3, 0.75, 0.45)
const GLASS := Color(0.7, 0.88, 1.0, 0.45)
const CRACKED := Color(0.45, 0.5, 0.55, 0.85)
const TOWELS: Array[Color] = [Color(0.95, 0.4, 0.4), Color(0.4, 0.7, 0.95), Color(0.95, 0.9, 0.5)]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
var conveyor: StaticBody3D
var side_brushes: Array[Node3D] = []
var top_brush: Node3D
## The jets' water, shown while the tunnel runs.
var sprays: Array[MeshInstance3D] = []
var tunnel: WashTunnel
var tunnel_button: PushButton
## The token machine's golden button: Don Chorro's distraction (step 3).
var premium: PremiumWash
## Don Chorro, the owner, and his complaint bar.
var owner_npc: FloorBoss
var complaint_bar: ProgressBar
## The cops he already scolded for going through the tunnel (id -> true).
var tunnel_seen := {}
## The rag basket's chamois button and Pompita, the gossip (step 4).
var chamois_button: PushButton
var pompita: RagBoy
var chamois: Array[Chamois] = []
var _tunnel_check := 0.0
var cars: Array[AnimatableBody3D] = []
var windshields: Array[MeshInstance3D] = []
var cracked: Array[int] = []
var wax_broken_down := false
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
var car: PatrolCar
## Money taken off the case pay: the windshields and the wax.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## Same seed, same car wash: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: CarWashRig
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
	_build_shell()
	_build_tunnel()
	_build_queue()
	_build_front()
	_build_drying()
	_build_back()
	_place_owner()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("carwash")
	station_parking = city.transform * CityLayout.parking("station")
	_park_car()
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "carwash", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = owner_npc
	raid.owner_id = "carwash"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The car wash's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_CARWASH",
		"guess_key": "OBJ_GUESS_CARWASH",
		"broken_key": "OBJ_BROKEN_CARWASH",
		"complaint_key": "OBJ_COMPLAINT_CARWASH",
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


## What Don Chorro lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Pompita saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		owner_npc.slips.append(tr("CHORRO_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	owner_npc.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	pompita.clue = tr("CLUE_POMPITA") % where
	pompita.clue_speech = tr("POMPITA_CLUE_" + story_id) % where
	pompita.told.connect(raid.add_clue)


func _park_car() -> void:
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))


## Whether `at` lies inside the wash tunnel, over its conveyor.
static func in_tunnel(at: Vector3) -> bool:
	return at.x > TUNNEL_X0 and at.x < TUNNEL_X1 and absf(at.z) < CONVEYOR_HALF_Z


## The outer walls with the wide front opening, the floor, the roof, the sign with its bubble and the hall's lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, CONCRETE)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, WALL_IN.darkened(0.3))
	_build.wall_at("x", HALF_Z, -HALF_X, -FRONT_GAP, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, FRONT_GAP, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.box(Vector3(0, (FRONT_LINTEL + WALL_TOP) / 2, HALF_Z), Vector3(FRONT_GAP * 2, WALL_TOP - FRONT_LINTEL,
		PlaceBuilder.WALL), OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_build.mesh_box(Vector3(0, 4.75, HALF_Z + 0.1), Vector3(12.0, 1.2, 0.1), STRIPE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_CARWASH"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0.6, 4.75, HALF_Z + 0.17)
	$Built.add_child(sign_label)
	var bubble := SphereMesh.new()
	bubble.radius = 0.55
	bubble.height = 1.1
	_build.mesh(bubble, Vector3(-5.2, 4.75, HALF_Z + 0.5), FOAM)
	for x: float in [-14.0, -5.0, 5.0, 14.0]:
		for z: float in [-2.5, 6.5]:
			var lamp := _build.light(Vector3(x, WALL_TOP - 0.8, z))
			lamp.light_color = Color(0.95, 0.97, 1.0)
			lamp.omni_range = 10.0
			lamp.light_energy = 0.9


## The wash tunnel: its two walls and roof, open at both ends, the conveyor, the jets arch, the brushes, the foam
## curtain and the blower, and the button that sets it going (WashTunnel, step 2).
func _build_tunnel() -> void:
	var length := TUNNEL_X1 - TUNNEL_X0
	var mid_x := (TUNNEL_X0 + TUNNEL_X1) / 2
	for z: float in [-TUNNEL_HALF_Z, TUNNEL_HALF_Z]:
		_build.box(Vector3(mid_x, FLOOR_TOP + TUNNEL_TOP / 2, z), Vector3(length, TUNNEL_TOP, 0.15), TUNNEL)
		_build.mesh_box(Vector3(mid_x, FLOOR_TOP + 1.2, z * 0.96), Vector3(length, 0.3, 0.02), STRIPE)
	_build.box(Vector3(mid_x, FLOOR_TOP + TUNNEL_TOP + 0.1, 0), Vector3(length, 0.2, TUNNEL_HALF_Z * 2 + 0.15), TUNNEL)
	conveyor = _build.body(Vector3(mid_x, (FLOOR_TOP + CONVEYOR_TOP) / 2, 0))
	conveyor.name = "Conveyor"
	_build.shape(conveyor, Vector3(length, CONVEYOR_TOP - FLOOR_TOP, CONVEYOR_HALF_Z * 2))
	_build.mesh_box(Vector3(mid_x, (FLOOR_TOP + CONVEYOR_TOP) / 2, 0),
		Vector3(length, CONVEYOR_TOP - FLOOR_TOP, CONVEYOR_HALF_Z * 2), BELT)
	for i in 16:
		_build.mesh_box(Vector3(TUNNEL_X0 + 0.5 + i, CONVEYOR_TOP + 0.003, 0), Vector3(0.08, 0.005,
			CONVEYOR_HALF_Z * 2), STRIPE.darkened(0.4))
	_model(JETS_MODEL, Vector3(JETS_X, FLOOR_TOP, 0))
	for z: float in [-1.6, 0.0, 1.6]:
		var spray := MeshInstance3D.new()
		var water := BoxMesh.new()
		water.size = Vector3(0.3, TUNNEL_TOP - 0.3, 1.0)
		spray.mesh = water
		spray.material_override = _glass(Color(0.55, 0.8, 1.0, 0.35))
		spray.position = Vector3(JETS_X, FLOOR_TOP + (TUNNEL_TOP - 0.3) / 2, z)
		spray.hide()
		$Built.add_child(spray)
		sprays.append(spray)
	for at in SIDE_BRUSHES:
		side_brushes.append(_model(BRUSH_MODEL, at))
	top_brush = _model(BRUSH_MODEL, TOP_BRUSH)
	top_brush.rotation.x = PI / 2
	for i in 9:
		var z := -1.8 + i * 0.45
		_build.mesh_box(Vector3(CURTAIN_X, FLOOR_TOP + 2.2, z), Vector3(0.04, 2.3, 0.35),
			FOAM if i % 2 else STRIPE.lightened(0.5))
	_model(BLOWER_MODEL, Vector3(BLOWER_X, FLOOR_TOP, 0))
	tunnel = WashTunnel.new()
	tunnel.name = "Tunnel"
	tunnel.car_wash = self
	add_child(tunnel)
	_build.box(TUNNEL_BUTTON_AT + Vector3(0, -0.6, -0.08), Vector3(0.12, 1.2, 0.12), TUNNEL)
	tunnel_button = PushButton.new()
	tunnel_button.prompt = "PROMPT_CARWASH_TUNNEL"
	tunnel_button.color = Color(0.2, 0.55, 0.95)
	tunnel_button.position = TUNNEL_BUTTON_AT
	add_child(tunnel_button)
	tunnel_button.pressed.connect(func(_cop: Cop) -> void: tunnel.start())
	tunnel.soaked.connect(func(body: Node3D) -> void:
		if body is Chamois:
			(body as Chamois).soak())


## The two customers' cars waiting in line, facing the tunnel; the second one with its trunk open (a box you can put
## something in), and both windshields, which break if something hits them hard. Each car is its own body, so the
## first one can ride through the tunnel for the premium wash (step 3).
func _build_queue() -> void:
	for i in CARS.size():
		var at := CARS[i]
		var car := AnimatableBody3D.new()
		car.name = "Car%d" % i
		car.position = at
		$Built.add_child(car)
		var look: Node3D = TrafficCar.MODELS[(i + 1) % TrafficCar.MODELS.size()].instantiate()
		look.rotation.y = PI / 2
		car.add_child(look)
		for wheel_at in SuspectCar.SEDAN_WHEELS:
			var wheel: Node3D = TrafficCar.WHEEL.instantiate()
			wheel.position = wheel_at
			look.add_child(wheel)
		var trunk := TRUNK_LENGTH if i == TRUNK_CAR else 0.0
		var collision := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = Vector3(CAR_SIZE.x - trunk, CAR_SIZE.y, CAR_SIZE.z)
		collision.shape = box_shape
		collision.position = Vector3(trunk / 2, CAR_SIZE.y / 2, 0)
		car.add_child(collision)
		cars.append(car)
		var pane := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = WINDSHIELD_SIZE
		pane.mesh = box
		pane.material_override = _glass(GLASS)
		pane.position = Vector3(WINDSHIELD_AHEAD, 1.25, 0)
		pane.rotation.z = 0.5
		car.add_child(pane)
		windshields.append(pane)
		# Over the hood too: what flies at the windshield hits the car's front first.
		var area := _area(pane.position + Vector3(HOOD / 2, 0.15, 0), WINDSHIELD_SIZE + Vector3(HOOD, 0.2, 0), car)
		area.body_entered.connect(func(hit: Node3D) -> void:
			if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > WINDSHIELD_SPEED:
				break_windshield(i))
	var rear := CARS[TRUNK_CAR].x - CAR_SIZE.x / 2
	_build.open_box(Vector3(rear + TRUNK_LENGTH / 2, FLOOR_TOP + 0.45, 0), Vector3(TRUNK_LENGTH, 0.5, 1.8), "top",
		Color(0.25, 0.25, 0.28))


## By the front: the token machine with the till, the vacuums, the wax shelf with its bottles and the inflatable man.
func _build_front() -> void:
	_model(TOKEN_MODEL, TOKEN_AT)
	premium = PremiumWash.new()
	premium.name = "Premium"
	premium.position = TOKEN_AT
	premium.car = cars[0]
	premium.home = CARS[0]
	premium.dry_at = DRY_CAR_AT
	premium.tunnel = tunnel
	add_child(premium)
	_build.shape(_build.body(TOKEN_AT + Vector3(0, TOKEN_SIZE.y / 2, 0)), TOKEN_SIZE)
	_build.box(TOKEN_AT + Vector3(0.75, 0.45, 0), Vector3(0.6, 0.9, 0.5), TUNNEL)
	till = Till.new()
	till.position = TOKEN_AT + Vector3(0.75, 0.9 + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_CARWASH"
	add_child(till)
	for at in VACUUMS:
		_model(VACUUM_MODEL, at)
		_build.shape(_build.body(at + Vector3(0, 0.9, 0)), Vector3(0.6, 1.8, 0.6))
	_build.open_box(WAX_AT, WAX_SIZE, "-z", WOOD)
	_build.box(WAX_AT + Vector3(0, 0.9, 0), Vector3(WAX_SIZE.x - 0.1, 0.05, WAX_SIZE.z - 0.1), WOOD)
	for i in WAX_BOTTLES:
		var bottle := CylinderMesh.new()
		bottle.top_radius = 0.06
		bottle.bottom_radius = 0.08
		bottle.height = 0.28
		_build.mesh(bottle, WAX_AT + Vector3(-1.25 + i * 0.5, 1.07, 0.05), WAX_COLORS[i])
	var area := _area(WAX_AT + Vector3(0, WAX_SIZE.y / 2, -WAX_SIZE.z / 2), Vector3(WAX_SIZE.x, WAX_SIZE.y, 0.6))
	area.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > WINDSHIELD_SPEED:
			break_wax())
	_model(INFLATABLE_MODEL, INFLATABLE_AT)
	_build.shape(_build.body(INFLATABLE_AT + Vector3(0, 0.25, 0)), Vector3(0.9, 0.5, 0.9))


## Past the tunnel's end: the towel line with its towels, the rag basket and the toolbox.
func _build_drying() -> void:
	for x in LINE_XS:
		_build.box(Vector3(x, FLOOR_TOP + 1.0, LINE_Z), Vector3(0.08, 2.0, 0.08), TUNNEL)
	_build.mesh_box(Vector3((LINE_XS[0] + LINE_XS[1]) / 2, FLOOR_TOP + 1.95, LINE_Z),
		Vector3(LINE_XS[1] - LINE_XS[0], 0.02, 0.02), BELT)
	for i in 7:
		_build.mesh_box(Vector3(LINE_XS[0] + 0.7 + i * 0.8, FLOOR_TOP + 1.65, LINE_Z), Vector3(0.5, 0.6, 0.02),
			TOWELS[i % TOWELS.size()])
	_build.open_box(BASKET_AT, BASKET_SIZE, "top", WOOD.lightened(0.3))
	chamois_button = PushButton.new()
	chamois_button.prompt = "PROMPT_CARWASH_CHAMOIS"
	chamois_button.color = Chamois.DRY
	chamois_button.position = CHAMOIS_BUTTON_AT
	add_child(chamois_button)
	chamois_button.pressed.connect(take_chamois)
	pompita = RagBoy.new()
	pompita.name = "Pompita"
	pompita.position = POMPITA_AT
	pompita.rotation.y = -PI / 2
	add_child(pompita)
	for at in PUDDLES:
		var puddle := CylinderMesh.new()
		puddle.top_radius = PUDDLE_RADIUS
		puddle.bottom_radius = PUDDLE_RADIUS
		puddle.height = 0.01
		var look := MeshInstance3D.new()
		look.mesh = puddle
		look.material_override = _glass(PUDDLE)
		look.position = at + Vector3(0, 0.006, 0)
		$Built.add_child(look)
		var wet := _area(at + Vector3(0, 0.15, 0), Vector3(PUDDLE_RADIUS * 1.6, 0.3, PUDDLE_RADIUS * 1.6))
		wet.body_entered.connect(func(hit: Node3D) -> void:
			if hit is Chamois:
				(hit as Chamois).soak())
	_build.open_box(TOOLBOX_AT, TOOLBOX_SIZE, "top", Color(0.8, 0.2, 0.2))


## Behind the back wall: the storeroom with the foam tank, the boiler, the shampoo drums and the tires, and the office,
## locked.
func _build_back() -> void:
	_build.wall_at("x", BACK_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [STORE_DOOR_X, OFFICE_DOOR_X], WALL_IN)
	_build.wall_at("z", OFFICE_WEST, -HALF_Z, BACK_Z, 0.0, WALL_TOP, [], WALL_IN)
	_build.open_box(FOAM_TANK_AT, FOAM_TANK_SIZE, "top", STRIPE.lightened(0.3))
	_build.mesh_box(FOAM_TANK_AT + Vector3(0, FOAM_TANK_SIZE.y - 0.15, 0), FOAM_TANK_SIZE - Vector3(0.12, 1.3, 0.12),
		FOAM)
	_model(BOILER_MODEL, BOILER_AT)
	_build.shape(_build.body(BOILER_AT + Vector3(0, 1.0, 0)), Vector3(1.0, 2.0, 1.0))
	for i in 4:
		var drum := CylinderMesh.new()
		drum.top_radius = 0.3
		drum.bottom_radius = 0.3
		drum.height = 0.9
		var at := DRUMS_AT + Vector3(-0.95 + (i % 2) * 0.65 + floorf(i / 2.0) * 1.3, 0.45, 0.2)
		_build.mesh(drum, at, DRUM)
		_build.shape(_build.body(at), Vector3(0.6, 0.9, 0.6))
	for i in 6:
		var tire := CylinderMesh.new()
		tire.top_radius = 0.35
		tire.bottom_radius = 0.35
		tire.height = 0.22
		var at := TIRES_AT + Vector3((i % 2) * 0.8 - 0.4, 0.11 + floorf(i / 2.0) * 0.23, 0)
		_build.mesh(tire, at, TIRE)
	_build.shape(_build.body(TIRES_AT + Vector3(0, 0.35, 0)), Vector3(1.5, 0.7, 0.75))
	_build.legs(Vector3(17.0, FLOOR_TOP, -9.8), Vector2(2.0, 1.0), 0.75, WOOD)
	_build.box(Vector3(17.0, FLOOR_TOP + 0.78, -9.8), Vector3(2.0, 0.06, 1.0), WOOD)
	_build.light(Vector3(-8.0, 3.0, -8.0))
	_build.light(Vector3(15.0, 3.0, -8.0))
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, BACK_Z)
	add_child(office_door)


## Don Chorro walking his round, what he can't stand to see, the premium wash and the complaint bar.
func _place_owner() -> void:
	owner_npc = OWNER_SCENE.instantiate()
	owner_npc.name = "DonChorro"
	owner_npc.route = OWNER_ROUTE
	owner_npc.printer_spot = DRY_SPOT
	owner_npc.printer = premium
	owner_npc.fix_time = DRY_TIME
	owner_npc.fix_facing = DRY_CAR_AT + Vector3.UP
	add_child(owner_npc)
	owner_npc.start_at(0)
	office_door.broken.connect(owner_npc.door_broken)
	owner_npc.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_CARWASH"))
	till.opened.connect(func(at: Vector3) -> void: owner_npc.saw(at, FloorBoss.SAW_TILL))
	premium.caught_on.connect(func() -> void: owner_npc.scold(CAUGHT_ON, "CHORRO_CAUGHT_ON"))
	var x0 := TUNNEL_X1 + 0.3
	var thuds := _area(Vector3((x0 + HALF_X) / 2, FLOOR_TOP + 0.3, (BACK_Z + LINE_Z) / 2),
		Vector3(HALF_X - x0, 0.6, LINE_Z - BACK_Z))
	thuds.body_entered.connect(_on_wet_floor_hit)
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


## Something falling on the drying area's wet floor: "¡Eso no se lava así!".
func _on_wet_floor_hit(body: Node3D) -> void:
	var item := body as RigidBody3D
	if item and item.linear_velocity.y < -2.0:
		owner_npc.saw(item.global_position, SAW_WET_FLOOR, "CHORRO_WET_FLOOR")


func _physics_process(delta: float) -> void:
	_tunnel_check += delta
	if _tunnel_check < TUNNEL_CHECK_EVERY:
		return
	_tunnel_check = 0.0
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop == null or tunnel_seen.has(cop.get_instance_id()):
			continue
		var at := to_local(cop.global_position)
		if at.x < TUNNEL_X0 or at.x > TUNNEL_X1 or absf(at.z) > TUNNEL_HALF_Z:
			continue
		if owner_npc.saw(cop.global_position + Vector3.UP, SAW_TUNNEL, "CHORRO_TUNNEL"):
			tunnel_seen[cop.get_instance_id()] = true


## The rag basket gives a dry chamois in front of it, if there aren't MAX_CHAMOIS around already (online, the host's
## is the one everyone sees: PropSync).
func take_chamois(cop: Cop = null) -> Chamois:
	var left: Array[Chamois] = []
	for cloth: Variant in chamois:
		if is_instance_valid(cloth) and not (cloth as Chamois).is_queued_for_deletion():
			left.append(cloth)
	chamois = left
	if chamois.size() >= MAX_CHAMOIS:
		if cop:
			cop.show_hint("HINT_CARWASH_CHAMOIS_MAX")
		return null
	if not multiplayer.is_server():
		return null
	var cloth: Chamois = CHAMOIS_SCENE.instantiate()
	cloth.position = CHAMOIS_AT + Vector3(0.3 * chamois.size(), 0, 0)
	add_child(cloth)
	chamois.append(cloth)
	return cloth


## Breaks the windshield of car `index`, once: a fine, and the glass goes grey and cracked.
func break_windshield(index: int) -> void:
	if cracked.has(index):
		return
	cracked.append(index)
	broken_goods += 1
	fines += WINDSHIELD_FINE
	raid.float_label("-%d" % WINDSHIELD_FINE, windshields[index].global_position + Vector3.UP, Color(1, 0.3, 0.25))
	windshields[index].material_override = _glass(CRACKED)
	_say(to_local(windshields[index].global_position) + Vector3(0, 1.0, 0), "CARWASH_WINDSHIELD_BROKEN")
	windshield_broken.emit(index)


## Breaks the wax shelf, once: a fine for each bottle.
func break_wax() -> void:
	if wax_broken_down:
		return
	wax_broken_down = true
	broken_goods += 1
	fines += WAX_FINE * WAX_BOTTLES
	raid.float_label("-%d" % (WAX_FINE * WAX_BOTTLES), to_global(WAX_AT + Vector3.UP * 2.0), Color(1, 0.3, 0.25))
	_say(WAX_AT + Vector3(0, 2.4, -0.6), "CARWASH_WAX_BROKEN")
	wax_broken.emit()


func _glass(color: Color) -> StandardMaterial3D:
	var glass := StandardMaterial3D.new()
	glass.albedo_color = color
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return glass


func _area(center: Vector3, size: Vector3, parent: Node3D = self) -> Area3D:
	var area := Area3D.new()
	area.position = center
	area.collision_layer = 0
	area.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	area.add_child(shape)
	parent.add_child(area)
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
