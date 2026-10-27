class_name BirthdayRaid
extends Node3D

## The birthday party as a place to raid (docs/diseno/allanamiento-cumple.md, step 1, decision 340): the costume
## party's Salón Gala (PartyHall.build_hall) on its lot in the city, by day and decked out for Tomasito's 7th birthday.
## The bouncy castle stands on the east side, open to the hall, and bounces whoever stands on it; the piñata hangs
## under the mirror ball; the gift table waits by the coat check and the three-tier cake on the food table. The cake
## and the balloon arch inside the entrance are fragile: the cake falling off the table is a fine, and a cop or a prop
## touching a balloon pops it. The office is locked; its key is in Chispita's case of tricks on the coat check's
## counter. Tomasito and his seven guests stand around the hall (they run about in step 3).
## Chispita (step 2) walks his round as the floor boss: the complaint goes up with every balloon he sees pop, the cake
## falling (the kids cry), the office door broken and his case opened. The matchbox by the cake is his distraction:
## lit, the lights go off and he and the kids sing round the table for 15 s, seeing nothing; a cop singing along calms
## him down once a song.
## The kids (step 3, PartyKid) run about, hang on cops' legs and carry small things off to the castle; E on Chispita
## gets a cop one of his balloon dogs (one every BALLOON_EVERY seconds) to trade a kid for what they carry. A kid a cop
## runs into cries, and Chispita counts it. Whoever breaks the piñata (BirthdayPinata) gets Tomasito's secret, once,
## while the guests sit under it picking up candies.
## The case (step 4) is the RaidCase every raid shares: the tip, three suspicions, the story drawn with the seed (or
## --story=<id>) and its things hidden in SPOTS, Chispita's slips and lawyer, Tomasito's secret, the escape and the
## interrogation. Every number here is (propuesta).

signal cake_fell
signal balloon_popped(index: int)
## Tomasito told the cop who broke the piñata his secret (the case fills it in, step 4).
signal tomasito_told(cop: Cop)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const CHISPITA_SCENE := preload("res://scenes/npc/birthday_clown.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the party can be suspected of (allanamiento-cumple.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["diamond_balloons", "pinata_bills", "endless_birthday", "watch_castle", "returning_gifts",
	"double_clown"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_BIRTHDAY_TIP_B", "BRIEF_TIP_C", "BRIEF_BIRTHDAY_TIP_D",
	"BRIEF_BIRTHDAY_TIP_E"]
## The stories the party can tell, like GymRaid.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist rows of
## its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras.
const STORIES := {
	"diamond_balloons": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_DIAMOND_BALLOONS_B", "BRIEF_DIAMOND_BALLOONS_C", "BRIEF_DIAMOND_BALLOONS_D"],
		"find": "OBJ_FIND_DIAMOND_BALLOONS",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/diamond_balloons.tscn"), preload("res://scenes/props/trick_pump.tscn"),
			preload("res://scenes/props/client_list.tscn")],
		"half_heights": [0.13, 0.305, 0.005],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_TRICK_PUMP", "OBJ_EXTRA_CLIENT_LIST"],
		"rig": preload("res://scripts/case/birthday/diamond_balloons_rig.gd"),
	},
	"pinata_bills": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_PINATA_BILLS_B", "BRIEF_PINATA_BILLS_C", "BRIEF_PINATA_BILLS_D"],
		"find": "OBJ_FIND_PINATA_PLATE",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/pinata_plate.tscn"), preload("res://scenes/props/fake_bills.tscn"),
			preload("res://scenes/props/fake_stamp.tscn")],
		"half_heights": [0.04, 0.03, 0.06],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_PINATA_BILLS", "OBJ_EXTRA_HAPPY_BANK_STAMP"],
		"rig": preload("res://scripts/case/birthday/pinata_bills_rig.gd"),
	},
}
## Where the suspicions' clue notes may lie, on the floor of the hall.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-4.5, FLOOR_TOP, 4.6), Vector3(2.6, FLOOR_TOP, 3.0), Vector3(-6.5, FLOOR_TOP, -3.8),
	Vector3(3.8, FLOOR_TOP, -5.0), Vector3(-1.2, FLOOR_TOP, -6.6), Vector3(5.2, FLOOR_TOP, 5.6),
]
const CASTLE_MODEL := preload("res://assets/models/bouncy_castle.glb")
const CAKE_MODEL := preload("res://assets/models/birthday_cake.glb")
const GIFT_MODEL := preload("res://assets/models/gift_box.glb")
const CASE_MODEL := preload("res://assets/models/chispita_case.glb")
const FLOOR_TOP := PartyHall.FLOOR_TOP
## The bouncy castle, its opening to the west (the hall); a cop on its floor bounces up at BOUNCE m/s.
const CASTLE_AT := Vector3(8.5, FLOOR_TOP, -0.5)
const CASTLE_HALF := 2.0
const CASTLE_FLOOR := 0.4
const CASTLE_WALL := Vector3(0.3, 1.6, 4.0)
const BOUNCE := 6.0
## Where the kids play by the castle's opening with what they carry, and where it ends up when they're bored.
const CASTLE_PLAY := Vector3(CASTLE_AT.x - CASTLE_HALF - 0.6, FLOOR_TOP, CASTLE_AT.z)
const CASTLE_DROP := CASTLE_AT + Vector3(-0.8, CASTLE_FLOOR + 0.3, 0)
## The piñata under the mirror ball.
const PINATA_AT := Vector3(0, 1.75, -0.5)
## The gift table by the coat check, with its gifts.
const GIFT_TABLE_AT := Vector3(-3.6, FLOOR_TOP, 7.6)
const GIFT_TABLE_SIZE := Vector3(2.0, 0.75, 0.8)
const GIFTS := 6
## The cake on the food table; if it ends up this far under the table's top, it fell.
const CAKE_AT := PartyHall.FOOD_TABLE_AT + Vector3(0, FLOOR_TOP + PartyHall.FOOD_TABLE_SIZE.y, 0.6)
const CAKE_SIZE := Vector3(0.6, 0.5, 0.6)
const CAKE_KG := 3.0
const CAKE_DROP := 0.3
const CAKE_FINE := 20
## Chispita's case of tricks on the coat check's counter, the office key inside.
const CASE_ON := Vector3(-7.2, FLOOR_TOP + 1.0, PartyHall.COAT_COUNTER_Z)
## The balloon arch inside the entrance: BALLOONS balloons up both sides of the door and across over it, out of the
## way of a cop walking in.
const ARCH_Z := PartyHall.HALF_Z - 0.6
const ARCH_SIDE := GameScale.DOOR_WIDTH / 2 + 0.4
const ARCH_TOP := 2.25
const BALLOONS := 13
const SIDE_BALLOONS := 4
const BALLOON_RADIUS := 0.2
## The bin of paper cups at the end of the food table, a hiding spot.
const CUP_BIN_AT := Vector3(-10.8, FLOOR_TOP, 3.0)
const CUP_BIN_SIZE := Vector3(0.5, 0.6, 0.5)
## Where Tomasito and his guests start, and the spots the guests run between.
const KIDS := 8
const KID_SPOTS: Array[Vector3] = [
	Vector3(-2.5, 0, -2.5), Vector3(2.4, 0, -2.0), Vector3(-1.5, 0, 1.6), Vector3(1.8, 0, 1.2), Vector3(5.5, 0, -1.0),
	Vector3(5.6, 0, 1.4), Vector3(-6.0, 0, 3.4), Vector3(-8.2, 0, -2.6), Vector3(-2.6, 0, 6.0), Vector3(0.6, 0, -3.8),
	Vector3(3.6, 0, 4.4), Vector3(-5.0, 0, -5.4),
]
const TOMASITO_AT := Vector3(0.8, 0, 0.6)
## Chispita's round (back and forth around the dance floor, clear of the castle and the rooms), where he stands to sing
## at the head of the cake and what the complaint goes up by.
const CHISPITA_ROUTE: Array[Vector3] = [
	Vector3(-8.0, FLOOR_TOP, -4.0), Vector3(-5.5, FLOOR_TOP, -5.6), Vector3(0.0, FLOOR_TOP, -5.6),
	Vector3(4.8, FLOOR_TOP, -4.0), Vector3(4.8, FLOOR_TOP, 4.0), Vector3(0.0, FLOOR_TOP, 5.0),
	Vector3(-5.0, FLOOR_TOP, 4.8), Vector3(-8.0, FLOOR_TOP, 3.0),
]
const SING_SPOT := Vector3(CAKE_AT.x + 1.0, FLOOR_TOP, CAKE_AT.z)
const SAW_POP := 2.0
const SAW_CRYING := 10.0
## A cop singing along calms him down this much, once a song.
const SANG := 5.0
## The candles on the table, and how dark the hall gets while they sing.
const CANDLES_AT := CAKE_AT + Vector3(0, 0, 1.2)
const DARK := 0.12
## Where the kids stand round the cake while they sing, two rows on the east side (distance and angle from the cake,
## leaving Chispita the middle).
## Chispita hands out a balloon dog this often, and it floats over the cop's shoulder.
const BALLOON_EVERY := 20.0
const BALLOON_ON := Vector3(0.35, 0.5, 0)
const BALLOON_DOG := Color(0.3, 0.75, 1.0)
## How often the loose things the kids may pick up are counted again.
const ITEMS_EVERY := 1.0
const SING_ROWS: Array[Vector2] = [
	Vector2(1.8, 0.15), Vector2(1.8, -0.15), Vector2(1.8, 0.3), Vector2(1.8, -0.3), Vector2(2.6, 0.06),
	Vector2(2.6, -0.06), Vector2(2.6, 0.22), Vector2(2.6, -0.22),
]

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_bouncy_castle", "at": CASTLE_AT + Vector3(0.4, CASTLE_FLOOR, 1.0), "heavy": true},
	{"id": "under_gift_table", "at": GIFT_TABLE_AT, "heavy": true},
	{"id": "in_office", "at": Vector3(7.2, FLOOR_TOP, -7.6), "heavy": true},
	{"id": "in_coat_check", "at": Vector3(-10.6, FLOOR_TOP, 8.6), "heavy": true},
	{"id": "in_restroom", "at": Vector3(9.6, FLOOR_TOP, 9.0), "heavy": true},
	{"id": "by_photo_steps", "at": Vector3(-10.6, FLOOR_TOP, -6.6), "heavy": true},
	{"id": "on_food_table", "at": PartyHall.FOOD_TABLE_AT + Vector3(0, FLOOR_TOP + 0.8, -3.6), "heavy": false},
	{"id": "in_cup_bin", "at": CUP_BIN_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "on_gift_table", "at": GIFT_TABLE_AT + Vector3(0.7, 0.75, 0), "heavy": false},
	{"id": "behind_balloon_arch", "at": Vector3(ARCH_SIDE + 0.6, FLOOR_TOP, ARCH_Z), "heavy": false},
	{"id": "on_hall_office_desk", "at": Vector3(8.0, FLOOR_TOP + 0.8, -9.0), "heavy": false},
	{"id": "on_top_step", "at": Vector3(-1.0, FLOOR_TOP + 0.6, -9.6), "heavy": false},
]
const TABLECLOTH := Color(0.98, 0.85, 0.92)
const CUPS := Color(0.95, 0.4, 0.5)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var chispita_case: Till
var cake: Grabbable
var cake_broken := false
var kids: Array[PartyKid] = []
var tomasito: PartyKid
var pinata: BirthdayPinata
var pinata_breaker: Cop
var told := false
## Everything grabbable lying about the hall, for the kids.
var loose_items: Array[Grabbable] = []
var balloon_left := 0.0
## Where Tomasito saw the clown hide something (a LOC_ text), his secret.
var tomasito_secret := ""
var balloons: Array[Area3D] = []
var popped: Array[int] = []
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the cake.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: BirthdayRaidRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var chispita: FloorBoss
var candles: BirthdayCandles
var complaint_bar: ProgressBar
## Same seed, same kids.
@export var case_seed := 0
var _build: PlaceBuilder
var _castle_top: Area3D
var _flames: Node3D
var _cake_glow: OmniLight3D
var _lamps: Array[OmniLight3D] = []
var _before_song := {}
var _singers := {}
var _balloon_of := {}
var _items_left := 0.0
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
	PartyHall.build_hall(_build, $Built, "BIRTHDAY_RAID_BANNER")
	_build_castle()
	_build_extras()
	_build_arch()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(PartyHall.OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, PartyHall.OFFICE_Z)
	add_child(office_door)
	_place_kids()
	_place_chispita()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("party_hall")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "party_hall", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = chispita
	raid.owner_id = "birthday"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The party's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_BIRTHDAY",
		"guess_key": "OBJ_GUESS_BIRTHDAY",
		"broken_key": "OBJ_BROKEN_BIRTHDAY",
		"complaint_key": "OBJ_COMPLAINT_BIRTHDAY",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": chispita.complaint,
	}


## Online, what the guests' party takes from the host's (RaidCase.snapshot): the cake, the popped balloons and what the
## story's rig decides on the host.
func net_state() -> Dictionary:
	return {"cake": cake_broken, "popped": popped.duplicate(), "rig": rig.net_state() if rig else null}


func apply_net_state(state: Dictionary) -> void:
	if state.cake:
		break_cake()
	for index: int in state.popped:
		pop(index)
	if rig and state.rig != null:
		rig.apply_net_state(state.rig)


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


## What Chispita lets slip when asked (where the story's things are, in an order drawn from the seed), and Tomasito's
## secret for whoever breaks the piñata: where the clown hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		chispita.slips.append(tr("CHISPITA_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	chispita.slipped.connect(raid.add_clue)
	tomasito_secret = tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	tomasito_told.connect(func(_cop: Cop) -> void: raid.add_clue(tr("CLUE_TOMASITO") % tomasito_secret))


func _physics_process(delta: float) -> void:
	_bounce()
	balloon_left = maxf(balloon_left - delta, 0.0)
	_items_left -= delta
	if _items_left <= 0.0:
		_items_left = ITEMS_EVERY
		loose_items.assign(find_children("*", "Grabbable", true, false))
	if not cake_broken and cake.position.y < CAKE_AT.y - CAKE_DROP:
		break_cake()
	if singing():
		_sing()
	elif not _before_song.is_empty():
		_end_song()


## The bouncy castle: its floor and three walls to stand and bump on, open to the west, and the area over its floor.
func _build_castle() -> void:
	var castle := StaticBody3D.new()
	castle.name = "BouncyCastle"
	castle.position = CASTLE_AT
	castle.rotation.y = -PI / 2
	$Built.add_child(castle)
	castle.add_child(CASTLE_MODEL.instantiate())
	_shape(castle, Vector3(0, CASTLE_FLOOR / 2, 0), Vector3(CASTLE_HALF * 2, CASTLE_FLOOR, CASTLE_HALF * 2))
	_shape(castle, Vector3(0, CASTLE_WALL.y / 2, -CASTLE_HALF + 0.15), Vector3(CASTLE_WALL.z, CASTLE_WALL.y, 0.3))
	for side: float in [-1.0, 1.0]:
		_shape(castle, Vector3(side * (CASTLE_HALF - 0.15), CASTLE_WALL.y / 2, 0), CASTLE_WALL)
	_castle_top = _area(CASTLE_AT + Vector3(0, CASTLE_FLOOR + 0.3, 0), Vector3(CASTLE_HALF * 2 - 0.6, 0.6,
		CASTLE_HALF * 2 - 0.6), 2)


## A cop standing on the castle's floor goes up again, and again.
func _bounce() -> void:
	for body in _castle_top.get_overlapping_bodies():
		var cop := body as Cop
		if cop and cop.velocity.y <= 0.0 and cop.global_position.y <= to_global(CASTLE_AT).y + CASTLE_FLOOR + 0.15:
			cop.velocity.y = BOUNCE


## The piñata, the gift table with its gifts, the cake, Chispita's case and the bin of cups.
func _build_extras() -> void:
	pinata = BirthdayPinata.new()
	pinata.position = PINATA_AT
	pinata.drop = PINATA_AT.y - FLOOR_TOP
	add_child(pinata)
	pinata.broken.connect(_on_pinata_broken)
	_build.box(GIFT_TABLE_AT + Vector3(0, GIFT_TABLE_SIZE.y / 2, 0), GIFT_TABLE_SIZE, TABLECLOTH)
	for i in GIFTS:
		# Three on the cloth and three smaller ones on top of them.
		var row := floori(i / 3.0)
		var gift := _model(GIFT_MODEL, GIFT_TABLE_AT + Vector3(-0.6 + (i % 3) * 0.6, GIFT_TABLE_SIZE.y + row * 0.22,
			-0.1 + (i % 3 % 2) * 0.2), i * 0.7)
		gift.scale = Vector3.ONE * (1.0 - row * 0.25)
	cake = ClubEvidence.make_item("Cake", CAKE_MODEL, CAKE_SIZE, CAKE_KG)
	(cake.get_child(1) as Node3D).position.y = -CAKE_SIZE.y / 2
	add_child(cake)
	cake.position = CAKE_AT + Vector3.UP * (CAKE_SIZE.y / 2 + 0.01)
	_flames = cake.get_child(1).find_child("flames", true, false)
	_flames.visible = false
	_cake_glow = OmniLight3D.new()
	_cake_glow.light_color = Color(1.0, 0.7, 0.35)
	_cake_glow.omni_range = 3.5
	_cake_glow.position = Vector3.UP * 0.4
	_cake_glow.visible = false
	cake.add_child(_cake_glow)
	candles = BirthdayCandles.new()
	candles.position = CANDLES_AT
	candles.rotation.y = PI / 2
	add_child(candles)
	chispita_case = Till.new()
	chispita_case.look = CASE_MODEL
	chispita_case.position = CASE_ON + Vector3.UP * Till.SIZE.y / 2
	chispita_case.key_hint = "HINT_TILL_KEY_BIRTHDAY"
	add_child(chispita_case)
	_build.open_box(CUP_BIN_AT, CUP_BIN_SIZE, "top", CUPS)


## The balloon arch inside the entrance: SIDE_BALLOONS up each side of the door and the rest across the top.
func _build_arch() -> void:
	var across := BALLOONS - SIDE_BALLOONS * 2
	for i in BALLOONS:
		var at: Vector3
		if i < SIDE_BALLOONS * 2:
			var side := -1.0 if i < SIDE_BALLOONS else 1.0
			at = Vector3(side * ARCH_SIDE, 0.4 + (i % SIDE_BALLOONS) * (ARCH_TOP - 0.4) / SIDE_BALLOONS, ARCH_Z)
		else:
			at = Vector3(-ARCH_SIDE + (i - SIDE_BALLOONS * 2 + 0.5) * ARCH_SIDE * 2 / across, ARCH_TOP, ARCH_Z)
		var balloon := _area(at + Vector3(0, FLOOR_TOP, 0), Vector3.ONE * BALLOON_RADIUS * 2, 6)
		balloon.name = "Balloon%d" % i
		var look := SphereMesh.new()
		look.radius = BALLOON_RADIUS
		look.height = BALLOON_RADIUS * 2.4
		var mesh := MeshInstance3D.new()
		mesh.mesh = look
		var material := StandardMaterial3D.new()
		material.albedo_color = PartyHall.BALLOONS[i % PartyHall.BALLOONS.size()]
		mesh.material_override = material
		balloon.add_child(mesh)
		balloon.body_entered.connect(func(_body: Node3D) -> void: pop(i))
		balloons.append(balloon)


## Balloon `index` pops, once: "¡PUM!" (Chispita counts them, step 2).
func pop(index: int) -> void:
	if popped.has(index):
		return
	popped.append(index)
	var balloon := balloons[index]
	balloon.get_child(1).visible = false
	_say(balloon.position + Vector3.UP * 0.4, "BIRTHDAY_POP")
	balloon_popped.emit(index)


## The cake fell off the table: a fine, a squashed cake and the kids' faces (they cry in step 3).
func break_cake() -> void:
	if cake_broken:
		return
	cake_broken = true
	broken_goods += 1
	fines += CAKE_FINE
	(cake.get_child(1) as Node3D).scale = Vector3(1.3, 0.35, 1.3)
	_say(cake.position + Vector3.UP * 0.8, "BIRTHDAY_CAKE_FELL")
	cake_fell.emit()


## Chispita on his round, cake time at the matchbox, what he notices and the complaint bar.
func _place_chispita() -> void:
	chispita = CHISPITA_SCENE.instantiate()
	chispita.route = CHISPITA_ROUTE
	chispita.printer_spot = SING_SPOT
	chispita.printer = candles
	add_child(chispita)
	chispita.fix_facing = to_global(CAKE_AT)
	chispita.start_at(0)
	chispita.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_BIRTHDAY"))
	office_door.broken.connect(chispita.door_broken)
	chispita_case.opened.connect(func(at: Vector3) -> void: chispita.saw(at, FloorBoss.SAW_TILL))
	balloon_popped.connect(func(index: int) -> void:
		chispita.saw(balloons[index].global_position, SAW_POP, "CHISPITA_BALLOON"))
	cake_fell.connect(func() -> void:
		chispita.saw(cake.global_position + Vector3.UP * 0.3, SAW_CRYING, "CHISPITA_CRYING")
		for kid in kids:
			kid.cry(false))
	for kid in kids:
		kid.cried.connect(func(crying: PartyKid) -> void:
			chispita.saw(crying.global_position + Vector3.UP, SAW_CRYING, "CHISPITA_CRYING"))
	chispita.use_prompt = "PROMPT_ASK_BALLOON"
	chispita.used.connect(_give_balloon)
	candles.sang.connect(_on_sang)
	for node in $Built.get_children():
		if node is OmniLight3D:
			_lamps.append(node)
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
	chispita.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Whether it's cake time: the candles are lit and Chispita sings at the head of the table.
func singing() -> bool:
	return chispita != null and chispita.is_fixing()


## Cake time: the lights go off but the candles' glow, and the kids gather round the cake to sing.
func _sing() -> void:
	if not _before_song.is_empty():
		return
	_singers.clear()
	for kid in kids:
		kid.stop()
	for lamp in _lamps:
		lamp.light_energy *= DARK
	_flames.visible = not cake_broken
	_cake_glow.visible = not cake_broken
	var center := CAKE_AT + Vector3(0, -CAKE_AT.y + FLOOR_TOP, 0)
	for i in kids.size():
		var kid := kids[i]
		_before_song[kid] = kid.transform
		var row := SING_ROWS[i % SING_ROWS.size()]
		kid.position = center + Vector3(cos(row.y * PI), 0, sin(row.y * PI)) * row.x
		# Members face -z.
		kid.look_at(Vector3(center.x, kid.position.y, center.z))


## The song's over: the candles blown out, the lights back on and the kids back where they were.
func _end_song() -> void:
	for lamp in _lamps:
		lamp.light_energy /= DARK
	_flames.visible = false
	_cake_glow.visible = false
	for kid: ClubMember in _before_song:
		if is_instance_valid(kid):
			kid.transform = _before_song[kid]
	_before_song.clear()


## A cop sang along: Chispita's pleased, once a song for each cop (online the host's Chispita decides).
func _on_sang(cop: Cop) -> void:
	if not singing() or _singers.has(cop) or not multiplayer.is_server():
		return
	_singers[cop] = true
	chispita.praise(SANG, "CHISPITA_SANG")


## E on Chispita: a balloon dog for the cop, one every BALLOON_EVERY seconds, one a cop.
func _give_balloon(cop: Cop) -> void:
	if has_balloon(cop):
		return
	if balloon_left > 0.0:
		cop.show_hint("HINT_BALLOON_WAIT")
		return
	balloon_left = BALLOON_EVERY
	var balloon := MeshInstance3D.new()
	var look := SphereMesh.new()
	look.radius = 0.14
	look.height = 0.5
	balloon.mesh = look
	var material := StandardMaterial3D.new()
	material.albedo_color = BALLOON_DOG
	balloon.material_override = material
	balloon.position = BALLOON_ON
	balloon.rotation.z = PI / 2
	cop.add_child(balloon)
	_balloon_of[cop] = balloon
	chispita.praise(0.0, "CHISPITA_BALLOON_DOG")


func has_balloon(cop: Cop) -> bool:
	return _balloon_of.has(cop)


func take_balloon(cop: Cop) -> void:
	if has_balloon(cop):
		(_balloon_of[cop] as Node).queue_free()
		_balloon_of.erase(cop)


func is_hung_on(cop: Cop) -> bool:
	return kids.any(func(kid: PartyKid) -> bool: return kid.hanging_on == cop)


## The piñata broke: the guests sit under it picking up candies, and Tomasito is happy with whoever did it.
func _on_pinata_broken(cop: Cop) -> void:
	pinata_breaker = cop
	var under := Vector3(PINATA_AT.x, FLOOR_TOP, PINATA_AT.z)
	for i in range(1, kids.size()):
		var angle := TAU * i / (kids.size() - 1)
		kids[i].pick_candies(under + Vector3(cos(angle), 0, sin(angle)) * 1.3, i % 3 == 1)
		kids[i].look_at(to_global(under))
	tomasito.say("TOMASITO_THANKS")


## E on Tomasito: only whoever broke the piñata gets his secret, once. True if he said something about it.
func tomasito_talks(cop: Cop) -> bool:
	if told:
		return false
	if pinata_breaker == null:
		tomasito.say("TOMASITO_PINATA_FIRST")
	elif pinata_breaker != cop:
		tomasito.say("TOMASITO_NOT_YOU")
	else:
		told = true
		tomasito.say(tr("TOMASITO_SECRET") % tomasito_secret)
		tomasito_told.emit(cop)
	return true


## Tomasito by the piñata and his seven guests on spots drawn with the seed.
func _place_kids() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["birthday raid kids", case_seed])
	var free := KID_SPOTS.duplicate()
	for i in KIDS:
		var kid := PartyKid.new()
		kid.setup(self, hash(["birthday kid", case_seed, i]))
		kid.wanders = i > 0
		kid.name = "Tomasito" if i == 0 else "Kid%d" % i
		kid.look = "tomasito" if i == 0 else ("party_kid" if rng.randf() < 0.5 else "party_kid_b")
		kid.next_line = rng.randi_range(0, ClubMember.TALK[kid.look][1] - 1)
		add_child(kid)
		var spot: Vector3 = TOMASITO_AT if i == 0 else free.pop_at(rng.randi_range(0, free.size() - 1))
		kid.position = spot + Vector3(0, FLOOR_TOP, 0)
		kid.rotation.y = rng.randf_range(-PI, PI)
		kids.append(kid)
	tomasito = kids[0]


func _shape(body: CollisionObject3D, at: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	body.add_child(shape)


func _area(center: Vector3, size: Vector3, mask: int) -> Area3D:
	var area := Area3D.new()
	area.position = center
	area.collision_layer = 0
	area.collision_mask = mask
	_shape(area, Vector3.ZERO, size)
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
