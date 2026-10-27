class_name Fair
extends Node3D

## The fun fair "La Vuelta Loca" as a place to raid (docs/diseno/allanamiento-parque.md, step 1): it fills block (7, 4)
## with its front to +Z on the street, at nightfall, closed to the public but with the lights on. Through the arch: the
## ticket booth (the trailer's key is in its till), the carousel with its 12 horses, the bumper cars' rink under its
## net, the Ferris wheel, the ghost train's dark tunnel with its carts and skeletons, the mirror house, the cans booth
## with the giant teddy, Nube's cotton candy cart, the strength tester and Don Tómbola's trailer at the back, locked. A
## mirror that something hits fast breaks, a fine each. The rides go with their lever, button and crank (FairRides, step
## 2). Don Tómbola walks his round with the megaphone and fills his complaint; the strength tester's bell takes him off
## to hand over a prize (step 3). Nube tells whoever knocks down her 3 cans what she saw (step 4). The case is one of
## its stories (STORIES), drawn with the seed, run by the same RaidCase as the other places (step 5). Every number here
## is (propuesta).

signal mirror_broken(index: int)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const ARCH_MODEL := preload("res://assets/models/fair_arch.glb")
const CAROUSEL_MODEL := preload("res://assets/models/fair_carousel.glb")
const HORSE_MODEL := preload("res://assets/models/fair_horse.glb")
const STAND_MODEL := preload("res://assets/models/ferris_stand.glb")
const WHEEL_MODEL := preload("res://assets/models/ferris_wheel.glb")
const CABIN_MODEL := preload("res://assets/models/ferris_cabin.glb")
const BUMPER_MODEL := preload("res://assets/models/bumper_car.glb")
const OWNER_SCENE := preload("res://scenes/npc/fair_owner.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the fair can be suspected of (allanamiento-parque.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["stuffed_prizes", "rigged_games", "fake_tickets", "loose_wheel", "ghost_storage",
	"bronze_horse"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_FAIR_TIP_B", "BRIEF_TIP_C", "BRIEF_FAIR_TIP_D",
	"BRIEF_FAIR_TIP_E"]
## The stories the fair can tell, like GymRaid.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist rows of
## its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras.
const STORIES := {
	"stuffed_prizes": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_STUFFED_PRIZES_B", "BRIEF_STUFFED_PRIZES_C", "BRIEF_STUFFED_PRIZES_D"],
		"find": "OBJ_FIND_WATCH_BAG",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/fair_watch_bag.tscn"),
			preload("res://scenes/props/fair_client_list.tscn"), preload("res://scenes/props/fair_needle_thread.tscn")],
		"half_heights": [0.22, 0.003, 0.06],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_CLIENT_LIST", "OBJ_EXTRA_NEEDLE_THREAD"],
		"rig": preload("res://scripts/case/fair/stuffed_prizes_rig.gd"),
	},
	"rigged_games": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_RIGGED_GAMES_B", "BRIEF_RIGGED_GAMES_C", "BRIEF_RIGGED_GAMES_D"],
		"find": "OBJ_FIND_MAGNET",
		"hidden": [preload("res://scenes/props/fair_glued_cans.tscn"),
			preload("res://scenes/props/fair_rig_manual.tscn")],
		"half_heights": [0.15, 0.025],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_GLUED_CANS", "OBJ_EXTRA_RIG_MANUAL"],
		"rig": preload("res://scripts/case/fair/rigged_games_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the paved paths.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(1.5, FLOOR_TOP, 15.0), Vector3(-1.6, FLOOR_TOP, 9.5), Vector3(-10.0, FLOOR_TOP, -7.0),
	Vector3(8.0, FLOOR_TOP, -9.0), Vector3(-1.0, FLOOR_TOP, -1.5), Vector3(16.0, FLOOR_TOP, -7.0),
]
const CANDY_MODEL := preload("res://assets/models/cotton_candy_cart.glb")
const BOOTH_MODEL := preload("res://assets/models/cans_booth.glb")
const TICKETS_MODEL := preload("res://assets/models/ticket_booth.glb")
const FACE_MODEL := preload("res://assets/models/ghost_train_face.glb")
const CART_MODEL := preload("res://assets/models/ghost_cart.glb")
const SKELETON_MODEL := preload("res://assets/models/fair_skeleton.glb")
const TEDDY_MODEL := preload("res://assets/models/giant_teddy.glb")

## The block, half its side; the fence round it stops at the arch.
const HALF := 27.0
const FLOOR_TOP := 0.06
## The raid is at night: the city's clock starts at this hour.
const OPENS_AT := 21.0
const FENCE_HEIGHT := 1.6
const ARCH_AT := Vector3(0, 0, 25.5)
const ARCH_GAP := 8.0
## The ticket booth just inside the arch, and its till on the counter.
const TICKETS_AT := Vector3(5.5, FLOOR_TOP, 21.0)
const TILL_ON := Vector3(5.5, FLOOR_TOP + 1.05, 22.2)
## The carousel: its middle, its deck's top, and its 12 horses in two rings.
const CAROUSEL_AT := Vector3(-13.0, 0, 12.0)
const DECK_TOP := 0.4
const DECK_RADIUS := 5.5
const DRUM_RADIUS := 1.4
const HORSE_RINGS: Array[Vector2] = [Vector2(4.3, 8), Vector2(3.0, 4)]
## The bumper cars' rink: its middle and size, its rail and the net's height, and the six cars on it.
const RINK_AT := Vector3(12.0, 0, 11.0)
const RINK_SIZE := Vector2(14.0, 10.0)
const RAIL_HEIGHT := 0.45
const NET_HEIGHT := 3.2
const BUMPERS: Array[Vector3] = [Vector3(-4.5, 0, -2.5), Vector3(-1.0, 0, 3.0), Vector3(2.5, 0, -1.0),
	Vector3(5.0, 0, 2.5), Vector3(-3.0, 0, 1.0), Vector3(1.0, 0, -3.5)]
const BUMPER_SIZE := Vector3(1.3, 0.6, 1.9)
## The Ferris wheel: its stand, its hub's height and the cabins' radius (8 cabins; the first one at the top).
const WHEEL_AT := Vector3(14.0, 0, -12.0)
const HUB_HEIGHT := 6.6
const WHEEL_RADIUS := 4.8
const CABINS := 8
const CABIN_FLOOR := 1.5
## The ghost train: its building (x, z rect), its height, its two doorways in the front and the wall between.
const GHOST := Rect2(-20.0, -20.0, 14.0, 10.0)
const GHOST_HEIGHT := 6.0
const GHOST_DOORS: Array[float] = [-17.5, -8.5]
const GHOST_CARTS: Array[Vector3] = [Vector3(-17.5, FLOOR_TOP, -13.0), Vector3(-13.0, FLOOR_TOP, -18.3),
	Vector3(-8.5, FLOOR_TOP, -14.5)]
const SKELETONS: Array[Vector3] = [Vector3(-19.3, FLOOR_TOP, -16.0), Vector3(-15.0, FLOOR_TOP, -12.5),
	Vector3(-6.7, FLOOR_TOP, -18.5)]
## The mirror house beside it: its rect, its doorway, and the six mirrors on its inner walls (middle, turn).
const MIRRORS_HOUSE := Rect2(-4.0, -20.0, 7.0, 7.0)
const MIRRORS_HEIGHT := 3.2
const MIRRORS_DOOR := -0.5
const MIRRORS: Array[Vector4] = [Vector4(-3.8, 1.2, -18.0, PI / 2), Vector4(-3.8, 1.2, -15.0, PI / 2),
	Vector4(2.8, 1.2, -18.0, -PI / 2), Vector4(2.8, 1.2, -15.0, -PI / 2), Vector4(-2.0, 1.2, -19.8, 0.0),
	Vector4(1.0, 1.2, -19.8, 0.0)]
const MIRROR_SIZE := Vector3(1.4, 2.0, 0.3)
const MIRROR_SPEED := 3.0
const MIRROR_FINE := 30
## The booths in the middle, facing the arch.
const CANS_AT := Vector3(0.0, FLOOR_TOP, 4.0)
## Nube minds the cans from inside the booth, beside the shelf.
const NUBE_AT := CANS_AT + Vector3(-0.9, 0, 0.0)
const TEDDY_AT := Vector3(-2.4, FLOOR_TOP, 5.0)
const CANDY_AT := Vector3(4.0, FLOOR_TOP, 5.0)
const TESTER_AT := Vector3(-6.0, FLOOR_TOP, 4.0)
## Don Tómbola's round, back and forth: from the arch down the middle path, past the booths and to the back.
const OWNER_ROUTE: Array[Vector3] = [
	Vector3(0, FLOOR_TOP, 20.0), Vector3(0, FLOOR_TOP, 8.5), Vector3(-4.2, FLOOR_TOP, 8.5),
	Vector3(-4.2, FLOOR_TOP, -8.0), Vector3(6.0, FLOOR_TOP, -8.0),
]
## Where he stands to hand over the strength tester's prize.
const PRIZE_SPOT := TESTER_AT + Vector3(1.4, 0, 1.6)
## Seeing a ride switched on (once per ride) and something flung off the carousel.
const SAW_RIDE := 5.0
const SAW_FLUNG := 10.0
## The third bell: he knows what's going on.
const CAUGHT_ON := 10.0
## The small teddies on the cans booth's prize shelf (x in the booth), what they weigh and how big they are.
const PLUSHES: Array[float] = [-1.1, -0.7, -0.3, 0.1]
const PLUSH_KG := 0.3
const PLUSH_SIZE := Vector3(0.22, 0.3, 0.2)
const TOOLBOX_AT := Vector3(10.6, FLOOR_TOP, -9.0)
const TOOLBOX_SIZE := Vector3(0.7, 0.4, 0.4)
## Don Tómbola's trailer at the back, its door in the front wall.
const TRAILER := Rect2(5.0, -24.0, 8.0, 3.0)
const TRAILER_HEIGHT := 2.8
const TRAILER_DOOR_X := 9.0

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "under_bumper_car", "at": RINK_AT + Vector3(5.0, FLOOR_TOP, 3.6), "heavy": true},
	{"id": "in_ghost_cart", "at": Vector3(-13.0, FLOOR_TOP + 0.3, -18.3), "heavy": true},
	{"id": "behind_skeleton", "at": Vector3(-19.3, FLOOR_TOP, -17.2), "heavy": true},
	{"id": "behind_ticket_booth", "at": Vector3(5.5, FLOOR_TOP, 19.5), "heavy": true},
	{"id": "in_fair_trailer", "at": Vector3(11.5, FLOOR_TOP, -22.6), "heavy": true},
	{"id": "on_carousel_deck", "at": CAROUSEL_AT + Vector3(0, DECK_TOP, -1.9), "heavy": true},
	{"id": "in_carousel_horse", "at": CAROUSEL_AT + Vector3(0, DECK_TOP + 1.2, 4.3), "heavy": false},
	{"id": "on_prize_shelf", "at": CANS_AT + Vector3(0.8, 1.93, -0.78), "heavy": false},
	{"id": "in_giant_teddy", "at": TEDDY_AT + Vector3(0, 0.5, 0.2), "heavy": false},
	{"id": "in_cotton_candy_cart", "at": CANDY_AT + Vector3(0.4, 1.06, 0), "heavy": false},
	{"id": "in_fair_toolbox", "at": TOOLBOX_AT + Vector3(0, 0.42, 0), "heavy": false},
	{"id": "in_top_ferris_cabin", "at": WHEEL_AT + Vector3(0, HUB_HEIGHT + WHEEL_RADIUS - CABIN_FLOOR + 0.05, 0),
		"heavy": false},
]

const GRASS := Color(0.2, 0.32, 0.18)
const PAVING := Color(0.55, 0.5, 0.46)
const FENCE := Color(0.85, 0.82, 0.75)
const PURPLE := Color(0.3, 0.15, 0.4)
const DARK := Color(0.08, 0.08, 0.1)
const WOOD := Color(0.54, 0.35, 0.2)
const SILVER := Color(0.78, 0.84, 0.9)
const RED := Color(0.82, 0.23, 0.23)
const WARM := Color(1.0, 0.8, 0.5)

var city: Node3D
## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var trailer_door: FrontDoor
var till: Till
var carousel: Node3D
var horses: Array[Node3D] = []
var bumpers: Array[AnimatableBody3D] = []
var wheel: Node3D
var cabins: Array[Node3D] = []
var skeletons: Array[Node3D] = []
## What makes the rides go: the carousel's lever, the bumper cars' button, the wheel's crank and the skeletons.
var rides: FairRides
## The strength tester with its mallet: Don Tómbola's distraction (step 3).
var tester: StrengthTester
## Don Tómbola, the owner, and his complaint bar.
var owner_npc: FloorBoss
var complaint_bar: ProgressBar
## The cans booth with its 3 cans and 3 balls, and Nube who tells whoever knocks them all down (step 4).
var cans_booth: CansBooth
var nube: CandySeller
## The small teddies on the prize shelf.
var plushes: Array[Grabbable] = []
## The rides he already saw switched on.
var _rides_seen: Array[String] = []
var mirrors: Array[Area3D] = []
var broken_mirrors: Array[int] = []
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the mirrors.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## Same seed, same fair: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: FairRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
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
	_build_grounds()
	_build_carousel()
	_build_rink()
	_build_wheel()
	_build_ghost_train()
	_build_mirror_house()
	_build_booths()
	_build_trailer()
	rides = FairRides.new()
	rides.name = "Rides"
	rides.fair = self
	add_child(rides)
	_place_owner()
	city = $City
	city.transform = CityLayout.anchor("fair")
	var clock := (city as City).clock
	if clock:
		clock.hour = OPENS_AT
		clock.apply()
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "fair", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = owner_npc
	raid.owner_id = "fair"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The fair's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_FAIR",
		"guess_key": "OBJ_GUESS_FAIR",
		"broken_key": "OBJ_BROKEN_FAIR",
		"complaint_key": "OBJ_COMPLAINT_FAIR",
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


## What Don Tómbola lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Nube saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		owner_npc.slips.append(tr("TOMBOLA_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	owner_npc.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	nube.clue = tr("CLUE_NUBE") % where
	nube.clue_speech = tr("NUBE_CLUE_" + story_id) % where
	nube.told.connect(raid.add_clue)


## Don Tómbola on his round with his megaphone, what he can't stand to see and the complaint bar.
func _place_owner() -> void:
	owner_npc = OWNER_SCENE.instantiate()
	owner_npc.name = "DonTombola"
	owner_npc.route = OWNER_ROUTE
	owner_npc.printer_spot = PRIZE_SPOT
	owner_npc.printer = tester
	add_child(owner_npc)
	owner_npc.start_at(0)
	trailer_door.broken.connect(owner_npc.door_broken)
	owner_npc.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_FAIR"))
	till.opened.connect(func(at: Vector3) -> void: owner_npc.saw(at, FloorBoss.SAW_TILL))
	tester.caught_on.connect(func() -> void: owner_npc.scold(CAUGHT_ON, "TOMBOLA_CAUGHT_ON"))
	rides.ride_started.connect(_on_ride_started)
	rides.flung.connect(func(body: RigidBody3D) -> void:
		owner_npc.saw(body.global_position, SAW_FLUNG, "TOMBOLA_FLUNG"))
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


## "¡No me toquen los juegos!": a ride he sees switched on raises the complaint, once per ride.
func _on_ride_started(ride: String) -> void:
	if ride in _rides_seen:
		return
	var at: Vector3 = {"carousel": FairRides.CAROUSEL_LEVER_AT, "bumpers": FairRides.BUMPERS_BUTTON_AT,
		"wheel": FairRides.WHEEL_CRANK_AT}[ride]
	if owner_npc.saw(to_global(at + Vector3.UP), SAW_RIDE, "TOMBOLA_RIDE"):
		_rides_seen.append(ride)


## The grass, the paved paths from the arch, the fence round the block with the arch in its gap, the sign and the
## lamps on poles along the paths.
func _build_grounds() -> void:
	_build.mesh_box(Vector3(0, 0.03, 0), Vector3(HALF * 2, 0.02, HALF * 2), GRASS)
	_build.mesh_box(Vector3(0, 0.045, 12.0), Vector3(5.0, 0.03, 28.0), PAVING)
	_build.mesh_box(Vector3(0, 0.045, -8.0), Vector3(36.0, 0.03, 4.0), PAVING)
	_build.mesh_box(Vector3(0, 0.045, 8.5), Vector3(36.0, 0.03, 3.0), PAVING)
	var edge := HALF - 0.3
	var y := FENCE_HEIGHT / 2
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * edge, y, 0), Vector3(0.1, FENCE_HEIGHT, HALF * 2), FENCE)
		_build.box(Vector3(side * (ARCH_GAP / 2 + edge) / 2, y, edge), Vector3(edge - ARCH_GAP / 2, FENCE_HEIGHT, 0.1),
			FENCE)
	_build.box(Vector3(0, y, -edge), Vector3(HALF * 2, FENCE_HEIGHT, 0.1), FENCE)
	_model(ARCH_MODEL, ARCH_AT)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_FAIR"
	sign_label.font_size = 76
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.modulate = Color(1.0, 0.9, 0.5)
	sign_label.position = ARCH_AT + Vector3(0, 5.3, 0.25)
	$Built.add_child(sign_label)
	for side: float in [-1.0, 1.0]:
		_solid(ARCH_AT + Vector3(side * 4.5, 2.7, 0), Vector3(0.8, 5.4, 0.8))
	for at: Vector3 in [Vector3(-3, 0, 18), Vector3(3, 0, 12), Vector3(3, 0, 0), Vector3(-10, 0, 8.5),
			Vector3(10, 0, 8.5), Vector3(-10, 0, -8), Vector3(0, 0, -8), Vector3(10, 0, -8)]:
		_build.box(at + Vector3(0, 2.0, 0), Vector3(0.12, 4.0, 0.12), DARK)
		_build.light(at + Vector3(0, 4.1, 0)).light_color = WARM


## The carousel: its deck and drum to stand on and bump into, the model, and its horses on their poles.
func _build_carousel() -> void:
	carousel = Node3D.new()
	carousel.name = "Carousel"
	carousel.position = CAROUSEL_AT
	add_child(carousel)
	var body := AnimatableBody3D.new()
	body.sync_to_physics = false
	body.name = "Deck"
	carousel.add_child(body)
	_cylinder(body, DECK_RADIUS, DECK_TOP, Vector3(0, DECK_TOP / 2, 0))
	_cylinder(body, DRUM_RADIUS, 3.8, Vector3(0, DECK_TOP + 1.9, 0))
	carousel.add_child(CAROUSEL_MODEL.instantiate())
	for ring in HORSE_RINGS:
		for i in int(ring.y):
			var turn := TAU * i / ring.y + (0.0 if ring.x > 4.0 else TAU / 8)
			var horse := AnimatableBody3D.new()
			horse.sync_to_physics = false
			horse.name = "Horse%d" % horses.size()
			horse.position = Vector3(sin(turn) * ring.x, DECK_TOP, cos(turn) * ring.x)
			horse.rotation.y = turn + PI / 2
			_box_shape(horse, Vector3(0.4, 0.8, 1.0), Vector3(0, 1.0, 0))
			horse.add_child(HORSE_MODEL.instantiate())
			carousel.add_child(horse)
			horses.append(horse)
	_build.light(CAROUSEL_AT + Vector3(0, 3.6, 3.0)).light_color = WARM


## The bumper cars' rink: its dark floor, the rail round it with a gap to come in, the posts and the net over it, and
## the six cars standing where they were left.
func _build_rink() -> void:
	var half := RINK_SIZE / 2
	_build.mesh_box(RINK_AT + Vector3(0, 0.07, 0), Vector3(RINK_SIZE.x, 0.03, RINK_SIZE.y), DARK.lightened(0.15))
	var y := RAIL_HEIGHT / 2
	_build.box(RINK_AT + Vector3(0, y, -half.y), Vector3(RINK_SIZE.x, RAIL_HEIGHT, 0.2), RED)
	_build.box(RINK_AT + Vector3(-half.x, y, 0), Vector3(0.2, RAIL_HEIGHT, RINK_SIZE.y), RED)
	_build.box(RINK_AT + Vector3(half.x, y, 0), Vector3(0.2, RAIL_HEIGHT, RINK_SIZE.y), RED)
	for side: float in [-1.0, 1.0]:
		_build.box(RINK_AT + Vector3(side * (half.x + 1.0) / 2, y, half.y), Vector3(half.x - 1.0, RAIL_HEIGHT, 0.2),
			RED)
	for x: float in [-half.x, half.x]:
		for z: float in [-half.y, half.y]:
			_build.box(RINK_AT + Vector3(x, NET_HEIGHT / 2, z), Vector3(0.15, NET_HEIGHT, 0.15), SILVER)
	for i in 8:
		_build.mesh_box(RINK_AT + Vector3(-half.x + (i + 0.5) * RINK_SIZE.x / 8, NET_HEIGHT, 0),
			Vector3(0.03, 0.03, RINK_SIZE.y), SILVER)
	for i in 6:
		_build.mesh_box(RINK_AT + Vector3(0, NET_HEIGHT, -half.y + (i + 0.5) * RINK_SIZE.y / 6),
			Vector3(RINK_SIZE.x, 0.03, 0.03), SILVER)
	for i in BUMPERS.size():
		var bumper := AnimatableBody3D.new()
		bumper.sync_to_physics = false
		bumper.name = "Bumper%d" % i
		bumper.position = RINK_AT + BUMPERS[i] + Vector3(0, FLOOR_TOP, 0)
		bumper.rotation.y = i * 1.3
		_box_shape(bumper, BUMPER_SIZE, Vector3(0, BUMPER_SIZE.y / 2, 0))
		bumper.add_child(BUMPER_MODEL.instantiate())
		add_child(bumper)
		bumpers.append(bumper)
	_build.light(RINK_AT + Vector3(0, NET_HEIGHT - 0.4, 0))


## The Ferris wheel: the stand, the wheel on its hub (it turns in step 2) and its cabins, which hang straight down.
func _build_wheel() -> void:
	_model(STAND_MODEL, WHEEL_AT)
	_solid(WHEEL_AT + Vector3(0, 0.15, 0), Vector3(4.0, 0.3, 3.2))
	for side: float in [-1.0, 1.0]:
		_solid(WHEEL_AT + Vector3(side * 2.6, 1.0, 0), Vector3(0.4, 2.0, 2.0))
	wheel = Node3D.new()
	wheel.name = "Wheel"
	wheel.position = WHEEL_AT + Vector3(0, HUB_HEIGHT, 0)
	add_child(wheel)
	wheel.add_child(WHEEL_MODEL.instantiate())
	for i in CABINS:
		var turn := TAU * i / CABINS
		var cabin := AnimatableBody3D.new()
		cabin.sync_to_physics = false
		cabin.name = "Cabin%d" % i
		cabin.position = Vector3(sin(turn), cos(turn), 0) * WHEEL_RADIUS
		_box_shape(cabin, Vector3(1.2, 0.1, 1.0), Vector3(0, -CABIN_FLOOR, 0))
		cabin.add_child(CABIN_MODEL.instantiate())
		wheel.add_child(cabin)
		cabins.append(cabin)
	_box(TOOLBOX_AT + Vector3(0, TOOLBOX_SIZE.y / 2, 0), TOOLBOX_SIZE, RED)


## The ghost train: a purple building with two doorways under its face, a wall in the middle so the way in goes round
## to the way out, the three carts and the three skeletons, and one dim purple light.
func _build_ghost_train() -> void:
	var x0 := GHOST.position.x
	var x1 := GHOST.end.x
	var z0 := GHOST.position.y
	var z1 := GHOST.end.y
	_build.wall_at("x", z1, x0, x1, 0.0, GHOST_HEIGHT, GHOST_DOORS, PURPLE)
	_build.wall_at("x", z0, x0, x1, 0.0, GHOST_HEIGHT, [], PURPLE)
	_build.wall_at("z", x0, z0, z1, 0.0, GHOST_HEIGHT, [], PURPLE)
	_build.wall_at("z", x1, z0, z1, 0.0, GHOST_HEIGHT, [], PURPLE)
	_build.wall_at("z", (x0 + x1) / 2, z0 + 2.6, z1, 0.0, GHOST_HEIGHT, [], DARK)
	_build.slab(x0, x1, z0, z1, GHOST_HEIGHT, PURPLE.darkened(0.3))
	_build.slab(x0, x1, z0, z1, FLOOR_TOP, DARK)
	_model(FACE_MODEL, Vector3((x0 + x1) / 2, 2.6, z1 + 0.1))
	for at in GHOST_CARTS:
		var cart := StaticBody3D.new()
		cart.position = at
		cart.rotation.y = PI / 2 if at.z < z0 + 2.0 else 0.0
		_box_shape(cart, Vector3(0.9, 0.6, 1.4), Vector3(0, 0.3, 0))
		cart.add_child(CART_MODEL.instantiate())
		add_child(cart)
	for at in SKELETONS:
		skeletons.append(_model(SKELETON_MODEL, at, PI if at.z > -14.0 else 0.0))
	var glow := OmniLight3D.new()
	glow.light_color = Color(0.6, 0.3, 0.9)
	glow.light_energy = 0.6
	glow.omni_range = 9.0
	glow.position = Vector3((x0 + x1) / 2, 3.0, (z0 + z1) / 2)
	$Built.add_child(glow)


## The mirror house: silver walls with a doorway, and six mirrors inside that break when something flies into them.
func _build_mirror_house() -> void:
	var x0 := MIRRORS_HOUSE.position.x
	var x1 := MIRRORS_HOUSE.end.x
	var z0 := MIRRORS_HOUSE.position.y
	var z1 := MIRRORS_HOUSE.end.y
	_build.wall_at("x", z1, x0, x1, 0.0, MIRRORS_HEIGHT, [MIRRORS_DOOR], SILVER)
	_build.wall_at("x", z0, x0, x1, 0.0, MIRRORS_HEIGHT, [], SILVER)
	_build.wall_at("z", x0, z0, z1, 0.0, MIRRORS_HEIGHT, [], SILVER)
	_build.wall_at("z", x1, z0, z1, 0.0, MIRRORS_HEIGHT, [], SILVER)
	_build.slab(x0, x1, z0, z1, MIRRORS_HEIGHT, SILVER.darkened(0.3))
	_build.slab(x0, x1, z0, z1, FLOOR_TOP, PURPLE.lightened(0.2))
	var shine := StandardMaterial3D.new()
	shine.albedo_color = SILVER.lightened(0.2)
	shine.metallic = 0.4
	shine.roughness = 0.15
	for i in MIRRORS.size():
		var spot := MIRRORS[i]
		var glass := MeshInstance3D.new()
		glass.name = "Mirror%d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(MIRROR_SIZE.x, MIRROR_SIZE.y, 0.03)
		mesh.material = shine
		glass.mesh = mesh
		glass.position = Vector3(spot.x, spot.y, spot.z)
		glass.rotation.y = spot.w
		$Built.add_child(glass)
		var area := _area(glass.position, MIRROR_SIZE, spot.w)
		area.body_entered.connect(func(hit: Node3D) -> void:
			if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > MIRROR_SPEED:
				break_mirror(i))
		mirrors.append(area)
	_build.light(Vector3((x0 + x1) / 2, MIRRORS_HEIGHT - 0.4, (z0 + z1) / 2))


## The booths in the middle: the cans booth with the small teddies on its prize shelf and the giant teddy beside it,
## Nube's cart, the strength tester with its mallet on the ground, and the ticket booth by the arch with its till.
func _build_booths() -> void:
	_model(BOOTH_MODEL, CANS_AT)
	_solid(CANS_AT + Vector3(0, 0.5, 0.8), Vector3(3.0, 1.0, 0.4))
	_solid(CANS_AT + Vector3(0, 1.3, -1.0), Vector3(3.0, 2.6, 0.1))
	for side: float in [-1.0, 1.0]:
		_solid(CANS_AT + Vector3(side * 1.5, 1.3, 0), Vector3(0.1, 2.6, 2.0))
	cans_booth = CansBooth.new()
	cans_booth.name = "CansBooth"
	cans_booth.position = CANS_AT
	add_child(cans_booth)
	nube = CandySeller.new()
	nube.name = "Nube"
	nube.position = NUBE_AT
	add_child(nube)
	cans_booth.won.connect(func(cop: Cop) -> void:
		if cop:
			nube.won(cop))
	cans_booth.missed.connect(nube.missed)
	for x: float in PLUSHES:
		var plush := ClubEvidence.make_item("Plush", TEDDY_MODEL, PLUSH_SIZE, PLUSH_KG)
		var look := plush.get_child(1) as Node3D
		look.scale = Vector3.ONE * 0.22
		look.position.y = -PLUSH_SIZE.y / 2
		plush.position = CANS_AT + Vector3(x, CansBooth.PRIZE_SHELF_TOP + PLUSH_SIZE.y / 2 + 0.01, -0.78)
		add_child(plush)
		plushes.append(plush)
	_model(TEDDY_MODEL, TEDDY_AT, 0.3)
	_solid(TEDDY_AT + Vector3(0, 0.55, 0), Vector3(0.9, 1.1, 0.8))
	_model(CANDY_MODEL, CANDY_AT, -0.2)
	_solid(CANDY_AT + Vector3(0, 0.6, 0), Vector3(1.6, 1.2, 0.8))
	tester = StrengthTester.new()
	tester.name = "StrengthTester"
	tester.case_seed = case_seed
	tester.position = TESTER_AT
	add_child(tester)
	var mallet := tester.make_mallet()
	mallet.position = TESTER_AT + Vector3(-1.0, StrengthTester.MALLET_SIZE.y / 2 + 0.02, 1.0)
	mallet.rotation.y = 0.6
	add_child(mallet)
	_model(TICKETS_MODEL, TICKETS_AT)
	_solid(TICKETS_AT + Vector3(0, 1.25, 0), Vector3(1.8, 2.5, 1.8))
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_FAIR"
	add_child(till)
	_build.light(Vector3(0, 3.2, 5.5)).light_color = WARM


## Don Tómbola's trailer: white walls with a red stripe, the locked door in front, a cot and a desk with papers.
func _build_trailer() -> void:
	var x0 := TRAILER.position.x
	var x1 := TRAILER.end.x
	var z0 := TRAILER.position.y
	var z1 := TRAILER.end.y
	_build.wall_at("x", z1, x0, x1, 0.0, TRAILER_HEIGHT, [TRAILER_DOOR_X], FENCE)
	_build.wall_at("x", z0, x0, x1, 0.0, TRAILER_HEIGHT, [], FENCE)
	_build.wall_at("z", x0, z0, z1, 0.0, TRAILER_HEIGHT, [], FENCE)
	_build.wall_at("z", x1, z0, z1, 0.0, TRAILER_HEIGHT, [], FENCE)
	_build.slab(x0, x1, z0, z1, TRAILER_HEIGHT, FENCE.darkened(0.2))
	_build.slab(x0, x1, z0, z1, FLOOR_TOP, WOOD)
	_build.mesh_box(Vector3((x0 + x1) / 2, 1.4, z1 + 0.07), Vector3(x1 - x0, 0.25, 0.02), RED)
	_box(Vector3(x0 + 1.2, FLOOR_TOP + 0.25, z0 + 0.6), Vector3(2.0, 0.5, 0.9), RED.darkened(0.3))
	_build.legs(Vector3(x0 + 4.0, FLOOR_TOP, z0 + 0.6), Vector2(1.4, 0.7), 0.76, DARK)
	_box(Vector3(x0 + 4.0, FLOOR_TOP + 0.78, z0 + 0.6), Vector3(1.4, 0.04, 0.7), WOOD)
	_build.light(Vector3((x0 + x1) / 2, TRAILER_HEIGHT - 0.3, (z0 + z1) / 2))
	trailer_door = DOOR_SCENE.instantiate()
	trailer_door.position = Vector3(TRAILER_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, z1)
	add_child(trailer_door)


## Breaks mirror `index`, once: a fine, the glass goes dark and Don Tómbola's line about bad luck.
func break_mirror(index: int) -> void:
	if broken_mirrors.has(index):
		return
	broken_mirrors.append(index)
	broken_goods += 1
	fines += MIRROR_FINE
	var glass := $Built.get_node("Mirror%d" % index) as MeshInstance3D
	var cracked := StandardMaterial3D.new()
	cracked.albedo_color = DARK.lightened(0.3)
	glass.material_override = cracked
	say(glass.position + Vector3(0, 1.5, 0), "FAIR_MIRROR_BROKEN")
	raid.float_label("-%d" % MIRROR_FINE, to_global(glass.position + Vector3.UP), Color(1, 0.3, 0.25))
	mirror_broken.emit(index)


func _cylinder(body: PhysicsBody3D, radius: float, height: float, at: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = height
	shape.shape = cylinder
	shape.position = at
	body.add_child(shape)


func _box_shape(body: PhysicsBody3D, size: Vector3, at: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	body.add_child(shape)


## A solid coloured box.
func _box(center: Vector3, size: Vector3, color: Color) -> void:
	_build.box(center, size, color)


## A box only to bump into, under a model that gives the look.
func _solid(center: Vector3, size: Vector3) -> void:
	_build.shape(_build.body(center), size)


func _area(center: Vector3, size: Vector3, turn: float) -> Area3D:
	var area := Area3D.new()
	area.position = center
	area.rotation.y = turn
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
func say(at: Vector3, key: String) -> void:
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
