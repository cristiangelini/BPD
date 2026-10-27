class_name RadioStation
extends Node3D

## "Radio La Antena Loca" as a place to raid (docs/diseno/allanamiento-radio.md, step 1): a one-floor neighborhood FM
## station on its lot in the city, the front to +Z. The reception has the listeners' desk with the till, the sofa, the
## mailbox and the week's ranking; behind it, the studio with its big window to the reception and the mixing console,
## the control room with the record player, and the kitchen. At the back, the record archive (locked with the till's
## key), the storage room and the bathroom. A metal stair up the east wall reaches the roof and the antenna. Something
## thrown hard at the studio's window cracks it, and at the archive's shelves drops a record that breaks, a fine each.
## Don Volumen talks on air at the console and goes to the archive for a record now and then, filling the complaint;
## E on the record player puts on the long song, the light goes off and he goes to the kitchen for a coffee, his back
## to everything (step 3). Doña Rosa calls the reception now and then and tells a cop who hears her out what don
## Volumen let slip on air (step 4). The case is one of its stories (STORIES), drawn with the seed, run by the same
## RaidCase as the other places (step 5).
## Every number here is (propuesta).

signal glass_broken
signal record_broken
## Something went out on air and the listeners' phone rang (step 2).
signal went_on_air
## Nobody answered a listener's call in CALL_WAIT seconds: don Volumen's complaint counts it (step 3).
signal listener_complained

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const PHONE_SCENE := preload("res://scenes/props/desk_phone.tscn")
const CONSOLE_MODEL := preload("res://assets/models/radio_console.glb")
const VOLUMEN_SCENE := preload("res://scenes/npc/don_volumen.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the radio can be suspected of (allanamiento-radio.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["rigged_contest", "phantom_ads", "hidden_mics", "collector_records", "coded_dedications",
	"fake_chart"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_RADIO_TIP_B", "BRIEF_TIP_C", "BRIEF_RADIO_TIP_D",
	"BRIEF_RADIO_TIP_E"]
## The stories the radio can tell, like Cinema.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist rows of
## its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras.
const STORIES := {
	"rigged_contest": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_RIGGED_CONTEST_B", "BRIEF_RIGGED_CONTEST_C", "BRIEF_RIGGED_CONTEST_D"],
		"find": "OBJ_FIND_RAFFLE_URN",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/raffle_urn.tscn"), preload("res://scenes/props/contest_blender.tscn"),
			preload("res://scenes/props/winners_list.tscn")],
		"half_heights": [0.23, 0.205, 0.01],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_BLENDER", "OBJ_EXTRA_WINNERS_LIST"],
		"rig": preload("res://scripts/case/radio/rigged_contest_rig.gd"),
	},
	"phantom_ads": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_PHANTOM_ADS_B", "BRIEF_PHANTOM_ADS_C", "BRIEF_PHANTOM_ADS_D"],
		"find": "OBJ_FIND_AD_CONTRACTS",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/ad_contracts.tscn"), preload("res://scenes/props/billing_book.tscn"),
			preload("res://scenes/props/paid_stamp.tscn")],
		"half_heights": [0.19, 0.015, 0.065],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_BILLING_BOOK", "OBJ_EXTRA_PAID_STAMP"],
		"rig": preload("res://scripts/case/radio/phantom_ads_rig.gd"),
	},
	"hidden_mics": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_HIDDEN_MICS_B", "BRIEF_HIDDEN_MICS_C", "BRIEF_HIDDEN_MICS_D"],
		"find": "OBJ_FIND_NEIGHBOR_TAPES",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/neighbor_tapes.tscn"), preload("res://scenes/props/pot_mic.tscn"),
			preload("res://scenes/props/crossed_map.tscn")],
		"half_heights": [0.16, 0.14, 0.015],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_POT_MIC", "OBJ_EXTRA_CROSSED_MAP"],
		"rig": preload("res://scripts/case/radio/hidden_mics_rig.gd"),
	},
	"collector_records": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_COLLECTOR_RECORDS_B", "BRIEF_COLLECTOR_RECORDS_C",
			"BRIEF_COLLECTOR_RECORDS_D"],
		"find": "OBJ_FIND_VINYL_CRATE",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/vinyl_crate.tscn"), preload("res://scenes/props/collector_catalog.tscn"),
			preload("res://scenes/props/golden_player.tscn")],
		"half_heights": [0.165, 0.02, 0.07],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_COLLECTOR_CATALOG", "OBJ_EXTRA_GOLDEN_PLAYER"],
		"rig": preload("res://scripts/case/radio/collector_records_rig.gd"),
	},
	"coded_dedications": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_CODED_DEDICATIONS_B", "BRIEF_CODED_DEDICATIONS_C",
			"BRIEF_CODED_DEDICATIONS_D"],
		"find": "OBJ_FIND_CODE_BOX",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/code_box.tscn"), preload("res://scenes/props/listener_list.tscn"),
			preload("res://scenes/props/delivery_clock.tscn")],
		"half_heights": [0.11, 0.01, 0.1],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_LISTENER_LIST", "OBJ_EXTRA_DELIVERY_CLOCK"],
		"rig": preload("res://scripts/case/radio/coded_dedications_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the reception's floor, in the studio, the control room, the kitchen and the
## storage room.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(0.0, FLOOR_TOP, 9.0), Vector3(6.0, FLOOR_TOP, 7.0), Vector3(-3.0, FLOOR_TOP, 2.0),
	Vector3(2.5, FLOOR_TOP, 0.5), Vector3(6.5, FLOOR_TOP, 0.0), Vector3(3.0, FLOOR_TOP, -7.0),
]
const SHELF_MODEL := preload("res://assets/models/record_shelf.glb")
const ANTENNA_MODEL := preload("res://assets/models/radio_antenna.glb")
const HALF_X := 9.0
const HALF_Z := 11.0
const FLOOR_TOP := 0.06
## The walls go up to WALL_TOP and the flat roof's top is one floor up, where the outside stair arrives.
const WALL_TOP := GameScale.FLOOR_HEIGHT - PlaceBuilder.SLAB
const ROOF_TOP := GameScale.FLOOR_HEIGHT
const ENTRANCE_X := 2.0
## The wall between the reception (z > FRONT_Z) and the rooms behind it, with the studio's, the control room's and the
## kitchen's doors; the studio's big window in it, from WINDOW_X0 to WINDOW_X1 between WINDOW_LOW and WINDOW_HIGH.
const FRONT_Z := 4.0
const STUDIO_DOOR_X := -6.5
const CONTROL_DOOR_X := 1.5
const KITCHEN_DOOR_X := 6.5
const WINDOW_X0 := -5.2
const WINDOW_X1 := -1.6
const WINDOW_LOW := 0.9
const WINDOW_HIGH := 2.1
## The walls between the studio and the control room (with the inner window) and the control room and the kitchen.
const STUDIO_X1 := -1.0
const KITCHEN_X0 := 4.0
## The wall between those rooms and the back ones, with the archive's (locked), the storage's and the bathroom's doors;
## the walls between the back rooms.
const BACK_Z := -4.0
const ARCHIVE_DOOR_X := -5.0
const STORAGE_DOOR_X := 2.0
const BATH_DOOR_X := 6.5
const ARCHIVE_X1 := 0.0
const BATH_X0 := 5.0
## The furniture: the reception's desk and the studio's console, the record player in the control room, and the
## archive's two rows of shelves (each SHELF_COUNT shelves long).
const DESK_AT := Vector3(-4.0, FLOOR_TOP, 7.5)
const DESK_SIZE := Vector3(2.6, 1.0, 0.8)
const CONSOLE_AT := Vector3(-5.0, FLOOR_TOP, -0.6)
const CONSOLE_SIZE := Vector3(2.0, 0.8, 0.8)
const PLAYER_AT := Vector3(1.5, FLOOR_TOP, -2.6)
const SHELF_ROWS: Array[float] = [-6.4, -9.0]
const SHELF_X0 := -8.6
const SHELF_COUNT := 2
const SHELF_SIZE := Vector3(3.0, 2.2, 0.5)
## The antenna on the roof, and the outside stair's foot by the east wall, going up along -Z to a landing on the roof.
const ANTENNA_AT := Vector3(-5.0, ROOF_TOP, -7.0)
const STAIR_FOOT := Vector3(HALF_X + 0.8, 0.0, HALF_Z - 1.0)
const STAIR_RUN := 5.4
## How fast a prop must hit to crack the studio's window or drop a record, and their fines; at most MAX_RECORDS
## records break.
const GLASS_SPEED := 3.0
const GLASS_FINE := 30
const RECORD_SPEED := 3.0
const RECORD_FINE := 10
const MAX_RECORDS := 5
## While the "AL AIRE" light is on, a hit near the microphone this fast goes out on air; the listeners' call waits
## CALL_WAIT seconds for someone to answer before it becomes a complaint.
const NOISE_SPEED := 2.0
const CALL_WAIT := 10.0
## What the listeners say when someone answers, in turn.
const CALLS: Array[String] = ["RADIO_CALL_NOISE", "RADIO_CALL_SONG", "RADIO_CALL_VOLUMEN"]

## Don Volumen's round, back and forth: from behind the console, through the archive's door and around the shelves'
## end to the middle of the archive. His coffee spot in the kitchen, facing the wall, and the way there through the
## studio's door, the reception and the kitchen's door.
const VOLUMEN_ROUTE: Array[Vector3] = [
	Vector3(-5.0, FLOOR_TOP, -1.8), Vector3(ARCHIVE_DOOR_X, FLOOR_TOP, -5.2), Vector3(-1.5, FLOOR_TOP, -5.2),
	Vector3(-1.5, FLOOR_TOP, -7.7), Vector3(-4.0, FLOOR_TOP, -7.7),
]
const COFFEE_PATH: Array[Vector3] = [
	Vector3(-7.8, FLOOR_TOP, -1.8), Vector3(-7.8, FLOOR_TOP, 2.6), Vector3(STUDIO_DOOR_X, FLOOR_TOP, 2.6),
	Vector3(STUDIO_DOOR_X, FLOOR_TOP, 5.4), Vector3(KITCHEN_DOOR_X, FLOOR_TOP, 5.4), Vector3(KITCHEN_DOOR_X, FLOOR_TOP, 2.6),
]
const COFFEE_SPOT := Vector3(5.8, FLOOR_TOP, -2.5)
## How long he talks on air at the console between trips to the archive, and the coffee.
const STUDIO_PAUSE := 90.0
const COFFEE_TIME := 25.0
## A listener's complaint, him seeing the window crack or a record break, and the long song once he knows the trick.
const LISTENER := 5.0
const SAW_GLASS := 10.0
const SAW_RECORD := 5.0
const NOTICED := 10.0
## He opens the archive's door when this close to it and shuts it again once past.
const DOOR_REACH := 2.0

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "behind_reception_desk", "at": Vector3(-4.0, FLOOR_TOP, 6.6), "heavy": true},
	{"id": "behind_radio_sofa", "at": Vector3(5.5, FLOOR_TOP, 10.5), "heavy": true},
	{"id": "in_record_archive", "at": Vector3(-1.0, FLOOR_TOP, -10.2), "heavy": true},
	{"id": "in_radio_storage", "at": Vector3(3.6, FLOOR_TOP, -9.8), "heavy": true},
	{"id": "in_radio_bathroom", "at": Vector3(7.0, FLOOR_TOP, -9.0), "heavy": true},
	{"id": "on_radio_roof", "at": Vector3(-2.5, ROOF_TOP, -9.0), "heavy": true},
	{"id": "in_mailbox", "at": Vector3(8.0, FLOOR_TOP + 1.1, 6.0), "heavy": false},
	{"id": "on_record_shelf", "at": Vector3(-7.0, FLOOR_TOP + 2.2, -9.0), "heavy": false},
	{"id": "on_kitchen_fridge", "at": Vector3(8.2, FLOOR_TOP + 1.8, -3.2), "heavy": false},
	{"id": "under_ranking", "at": Vector3(3.5, FLOOR_TOP, 4.4), "heavy": false},
	{"id": "in_control_room", "at": Vector3(3.0, FLOOR_TOP, 2.8), "heavy": false},
	{"id": "behind_console", "at": Vector3(-3.0, FLOOR_TOP, -1.4), "heavy": false},
]

const OUTSIDE := Color(0.9, 0.86, 0.78)
const FLOOR := Color(0.55, 0.5, 0.45)
const WALL_IN := Color(0.86, 0.84, 0.8)
const STUDIO_WALL := Color(0.3, 0.32, 0.42)
const WOOD := Color(0.55, 0.36, 0.22)
const TILE := Color(0.85, 0.88, 0.9)
const RED := Color(0.85, 0.12, 0.1)
const DARK := Color(0.16, 0.16, 0.2)
const GLASS := Color(0.7, 0.85, 0.95, 0.35)
const STEEL := Color(0.55, 0.57, 0.6)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var archive_door: FrontDoor
var till: Till
var glass_cracked := false
var records_broken := 0
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the studio's window and the archive's records.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: RadioStationRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## Whether the "AL AIRE" light is on (don Volumen's long song turns it off, step 3).
var on_air := true
var phone: DeskPhone
var mic: RadioMic
## How many listeners called, and how many of them nobody answered.
var calls := 0
var complaints := 0
## Seconds left for the ringing call, 0 when the phone is quiet.
var call_left := 0.0
var record_player: RadioRecordPlayer
var rosa: DonaRosa
## Listeners' calls someone answered, for their lines in turn.
var answered_calls := 0
var volumen: FloorBoss
var complaint_bar: ProgressBar
## Whether he opened the archive's door on his way, and whether it was locked then.
var _volumen_opened := false
var _was_locked := false
## Same seed, same radio, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
var _build: PlaceBuilder
var _glass: MeshInstance3D
var _bulb: OmniLight3D
var _blink := 0.0
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
	_build_reception()
	_build_studio()
	_build_back()
	_build_roof()
	_place_volumen()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("radio")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "radio", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = volumen
	raid.owner_id = "radio"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The radio's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_RADIO",
		"guess_key": "OBJ_GUESS_RADIO",
		"broken_key": "OBJ_BROKEN_RADIO",
		"complaint_key": "OBJ_COMPLAINT_RADIO",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": volumen.complaint,
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


## What don Volumen lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## doña Rosa heard him say on air: where he keeps one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		volumen.slips.append(tr("VOLUMEN_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	volumen.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	rosa.clue = tr("CLUE_ROSA") % where
	rosa.clue_speech = tr("ROSA_CLUE_" + story_id) % where
	rosa.told.connect(raid.add_clue)


## The floor, the outer walls with the entrance, the roof and the sign over the door.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, ROOF_TOP, OUTSIDE.darkened(0.3))
	_build.wall_at("x", HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [ENTRANCE_X], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	for line: Array in [["PLACE_RADIO", 72, 2.45], ["RADIO_FREQUENCY", 40, 1.95]]:
		var label := Label3D.new()
		label.text = line[0]
		label.font_size = line[1]
		label.pixel_size = 0.01
		label.outline_size = 12
		label.modulate = RED
		label.position = Vector3(-3.0, line[2], HALF_Z + 0.1)
		$Built.add_child(label)


## The reception: the listeners' desk with the till, the sofa, the mailbox, the week's ranking on the wall, and the
## wall to the rooms behind with the studio's big window and the red "AL AIRE" sign over its door.
func _build_reception() -> void:
	_build.open_box(DESK_AT, DESK_SIZE, "-z", WOOD)
	till = Till.new()
	till.position = DESK_AT + Vector3(0.7, DESK_SIZE.y + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_RADIO"
	add_child(till)
	phone = PHONE_SCENE.instantiate()
	phone.position = DESK_AT + Vector3(-0.6, DESK_SIZE.y, 0)
	phone.answered.connect(_on_phone_answered)
	add_child(phone)
	rosa = DonaRosa.new()
	rosa.name = "DonaRosa"
	rosa.phone = phone
	rosa.position = phone.position
	add_child(rosa)
	_build.box(Vector3(5.5, FLOOR_TOP + 0.25, 9.5), Vector3(2.2, 0.5, 0.9), Color(0.25, 0.45, 0.7))
	_build.box(Vector3(5.5, FLOOR_TOP + 0.6, 9.95), Vector3(2.2, 0.7, 0.2), Color(0.25, 0.45, 0.7))
	_build.box(Vector3(8.0, FLOOR_TOP + 0.55, 6.0), Vector3(0.5, 1.1, 0.4), RED)
	_build.mesh_box(Vector3(3.5, 1.6, FRONT_Z + 0.09), Vector3(1.4, 1.0, 0.03), DARK)
	var ranking := Label3D.new()
	ranking.text = "RADIO_RANKING"
	ranking.font_size = 28
	ranking.pixel_size = 0.005
	ranking.position = Vector3(3.5, 1.95, FRONT_Z + 0.12)
	$Built.add_child(ranking)
	_build.wall_at("x", FRONT_Z, -HALF_X, WINDOW_X0, 0.0, WALL_TOP, [STUDIO_DOOR_X], STUDIO_WALL)
	_build.wall_at("x", FRONT_Z, WINDOW_X0, WINDOW_X1, 0.0, WINDOW_LOW, [], STUDIO_WALL)
	_build.wall_at("x", FRONT_Z, WINDOW_X0, WINDOW_X1, WINDOW_HIGH, WALL_TOP - WINDOW_HIGH, [], STUDIO_WALL)
	_build.wall_at("x", FRONT_Z, WINDOW_X1, HALF_X, 0.0, WALL_TOP, [CONTROL_DOOR_X, KITCHEN_DOOR_X], WALL_IN)
	var pane := Vector3(WINDOW_X1 - WINDOW_X0, WINDOW_HIGH - WINDOW_LOW, 0.04)
	var center := Vector3((WINDOW_X0 + WINDOW_X1) / 2, (WINDOW_LOW + WINDOW_HIGH) / 2, FRONT_Z)
	_glass = _pane(center, pane)
	var hit := _area(center, pane + Vector3(0, 0, 0.6))
	hit.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > GLASS_SPEED:
			break_glass())
	var on_air := Label3D.new()
	on_air.name = "OnAirSign"
	on_air.text = "RADIO_ON_AIR"
	on_air.font_size = 40
	on_air.pixel_size = 0.006
	on_air.outline_size = 8
	on_air.modulate = RED
	on_air.position = Vector3(STUDIO_DOOR_X, GameScale.DOOR_HEIGHT + 0.2, FRONT_Z + 0.1)
	$Built.add_child(on_air)
	for at: Vector3 in [Vector3(-4.0, 2.2, 8.0), Vector3(4.0, 2.2, 8.0)]:
		_build.light(at)


## The studio with the mixing console, the control room with the record player behind the inner window, and the
## kitchen with its counter, coffee maker and fridge.
func _build_studio() -> void:
	_build.wall_at("z", STUDIO_X1, BACK_Z, -2.0, 0.0, WALL_TOP, [], STUDIO_WALL)
	_build.wall_at("z", STUDIO_X1, -2.0, 2.0, 0.0, WINDOW_LOW, [], STUDIO_WALL)
	_build.wall_at("z", STUDIO_X1, -2.0, 2.0, WINDOW_HIGH, WALL_TOP - WINDOW_HIGH, [], STUDIO_WALL)
	_build.wall_at("z", STUDIO_X1, 2.0, FRONT_Z, 0.0, WALL_TOP, [], STUDIO_WALL)
	_pane(Vector3(STUDIO_X1, (WINDOW_LOW + WINDOW_HIGH) / 2, 0.0), Vector3(0.04, WINDOW_HIGH - WINDOW_LOW, 4.0))
	_build.wall_at("z", KITCHEN_X0, BACK_Z, FRONT_Z, 0.0, WALL_TOP, [], WALL_IN)
	_model(CONSOLE_MODEL, CONSOLE_AT)
	_build.shape(_build.body(CONSOLE_AT + Vector3(0, CONSOLE_SIZE.y / 2, 0)), CONSOLE_SIZE)
	mic = RadioMic.new()
	mic.position = CONSOLE_AT + Vector3(0.4, CONSOLE_SIZE.y + RadioMic.SIZE.y / 2, 0)
	mic.spoken.connect(func(_cop: Cop) -> void: make_noise())
	add_child(mic)
	var near_mic := _area(Vector3((-HALF_X + STUDIO_X1) / 2, 1.2, (BACK_Z + FRONT_Z) / 2),
		Vector3(STUDIO_X1 + HALF_X, 2.4, FRONT_Z - BACK_Z))
	near_mic.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > NOISE_SPEED:
			make_noise())
	# The swivel chairs are only for the look: don Volumen walks past them.
	for x: float in [-6.2, -3.8]:
		_build.mesh_box(Vector3(x, FLOOR_TOP + 0.25, -1.6), Vector3(0.5, 0.5, 0.5), DARK)
	record_player = RadioRecordPlayer.new()
	record_player.position = PLAYER_AT
	add_child(record_player)
	_build.box(Vector3(6.5, FLOOR_TOP + 0.45, -3.4), Vector3(3.0, 0.9, 0.6), WOOD)
	_build.mesh_box(Vector3(5.8, FLOOR_TOP + 1.05, -3.4), Vector3(0.25, 0.3, 0.2), DARK)
	_build.box(Vector3(8.2, FLOOR_TOP + 0.9, -3.2), Vector3(0.8, 1.8, 0.7), TILE)
	for at: Vector3 in [Vector3(-5.0, 2.2, 0.0), Vector3(1.5, 2.2, 0.0), Vector3(6.5, 2.2, 0.0)]:
		_build.light(at).light_energy = 0.5


## The back rooms: the record archive behind its locked door with its rows of shelves, the storage room with boxes of
## cables, and the bathroom.
func _build_back() -> void:
	_build.wall_at("x", BACK_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [ARCHIVE_DOOR_X, STORAGE_DOOR_X, BATH_DOOR_X], WALL_IN)
	_build.wall_at("z", ARCHIVE_X1, -HALF_Z, BACK_Z, 0.0, WALL_TOP, [], WALL_IN)
	_build.wall_at("z", BATH_X0, -HALF_Z, BACK_Z, 0.0, WALL_TOP, [], TILE)
	for z: float in SHELF_ROWS:
		for i in SHELF_COUNT:
			var at := Vector3(SHELF_X0 + SHELF_SIZE.x / 2 + i * SHELF_SIZE.x, FLOOR_TOP, z)
			_model(SHELF_MODEL, at)
			_build.shape(_build.body(at + Vector3(0, SHELF_SIZE.y / 2, 0)), SHELF_SIZE)
		var shelves := _area(Vector3(SHELF_X0 + SHELF_SIZE.x * SHELF_COUNT / 2, FLOOR_TOP + SHELF_SIZE.y / 2, z),
			Vector3(SHELF_SIZE.x * SHELF_COUNT, SHELF_SIZE.y, SHELF_SIZE.z + 0.6))
		shelves.body_entered.connect(func(body: Node3D) -> void:
			if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > RECORD_SPEED:
				drop_record(body.global_position))
	archive_door = DOOR_SCENE.instantiate()
	archive_door.position = Vector3(ARCHIVE_DOOR_X - GameScale.DOOR_WIDTH / 2, 0.0, BACK_Z)
	add_child(archive_door)
	for i in 3:
		_build.box(Vector3(1.2 + i * 0.7, FLOOR_TOP + 0.25, -10.4), Vector3(0.6, 0.5, 0.5), Color(0.7, 0.55, 0.35))
	_build.box(Vector3(7.8, FLOOR_TOP + 0.25, -10.4), Vector3(0.5, 0.5, 0.6), TILE)
	_build.box(Vector3(5.6, FLOOR_TOP + 0.45, -7.0), Vector3(0.5, 0.9, 0.6), TILE)
	for at: Vector3 in [Vector3(-4.5, 2.2, -7.7), Vector3(2.5, 2.2, -7.5), Vector3(7.0, 2.2, -7.5)]:
		_build.light(at).light_energy = 0.4


## The stair up the east wall to a landing on the roof, the antenna with its blinking red light, and a low parapet.
func _build_roof() -> void:
	_build.stairs(STAIR_FOOT, STAIR_RUN, STEEL)
	_build.slab(HALF_X, STAIR_FOOT.x + GameScale.STAIR_WIDTH / 2, STAIR_FOOT.z - STAIR_RUN - 1.0,
		STAIR_FOOT.z - STAIR_RUN, ROOF_TOP, STEEL)
	_model(ANTENNA_MODEL, ANTENNA_AT)
	_build.shape(_build.body(ANTENNA_AT + Vector3(0, 3.0, 0)), Vector3(0.5, 6.0, 0.5))
	_bulb = OmniLight3D.new()
	_bulb.light_color = RED
	_bulb.light_energy = 2.0
	_bulb.omni_range = 4.0
	_bulb.position = ANTENNA_AT + Vector3(0, 6.9, 0)
	$Built.add_child(_bulb)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(0, ROOF_TOP + 0.25, side * (HALF_Z - 0.1)), Vector3(HALF_X * 2, 0.5, 0.2), OUTSIDE)
	_build.box(Vector3(-HALF_X + 0.1, ROOF_TOP + 0.25, 0), Vector3(0.2, 0.5, HALF_Z * 2), OUTSIDE)


func _process(delta: float) -> void:
	_blink += delta
	_bulb.visible = fmod(_blink, 1.2) < 0.6
	if call_left > 0.0:
		call_left -= delta
		if call_left <= 0.0:
			_unanswered()


func _physics_process(_delta: float) -> void:
	if volumen:
		_volumen_door()


## Don Volumen on his round, the long song, what he notices and the complaint bar.
func _place_volumen() -> void:
	volumen = VOLUMEN_SCENE.instantiate()
	volumen.route = VOLUMEN_ROUTE
	volumen.printer_spot = COFFEE_SPOT
	volumen.printer_path = COFFEE_PATH
	volumen.printer = record_player
	volumen.fix_time = COFFEE_TIME
	volumen.first_pause = STUDIO_PAUSE
	add_child(volumen)
	volumen.fix_facing = to_global(COFFEE_SPOT + Vector3(0, 0, -10))
	volumen.start_at(0)
	archive_door.broken.connect(volumen.door_broken)
	volumen.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_RADIO"))
	till.opened.connect(func(at: Vector3) -> void: volumen.saw(at, FloorBoss.SAW_TILL))
	glass_broken.connect(func() -> void: volumen.saw(to_global(_glass.position), SAW_GLASS, "VOLUMEN_GLASS"))
	record_broken.connect(func() -> void:
		volumen.saw(to_global(Vector3(-4.0, FLOOR_TOP + 1.0, -7.7)), SAW_RECORD, "VOLUMEN_RECORD"))
	listener_complained.connect(func() -> void: volumen.scold(LISTENER, "VOLUMEN_LISTENER"))
	record_player.jammed.connect(func() -> void: set_on_air(false))
	record_player.song_ended.connect(func() -> void: set_on_air(true))
	record_player.noticed.connect(func() -> void: volumen.scold(NOTICED, "VOLUMEN_NOTICED"))
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
	volumen.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## He has the archive's key: its door opens before him and shuts behind him, locked again as he found it unless a cop
## slipped in.
func _volumen_door() -> void:
	if archive_door.is_broken:
		return
	var at := to_local(volumen.global_position)
	var near := Vector2(at.x - ARCHIVE_DOOR_X, at.z - BACK_Z).length() < DOOR_REACH
	if near and not archive_door.is_open:
		_was_locked = archive_door.locked
		_volumen_opened = true
		archive_door.open_from_inside()
	elif not near and _volumen_opened:
		_volumen_opened = false
		archive_door.close()
		archive_door.locked = _was_locked and not _cop_in_archive()


func _cop_in_archive() -> bool:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var at := to_local(cop.global_position)
		if at.x < ARCHIVE_X1 and at.z < BACK_Z:
			return true
	return false


## What goes out on air, over the reception by the "AL AIRE" sign (a story's line).
func say_on_air(key: String) -> void:
	var label := _say(Vector3(STUDIO_DOOR_X + 2.5, GameScale.DOOR_HEIGHT - 0.1, FRONT_Z + 2.0), key)
	label.font_size = 36
	label.pixel_size = 0.006
	label.width = 900.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.no_depth_test = true


## Turns the "AL AIRE" light on or off: only on air does the neighborhood hear what happens.
func set_on_air(on: bool) -> void:
	on_air = on
	$Built/OnAirSign.visible = on


## Something loud happened near the microphone: on air, the listeners' phone rings (one call at a time).
func make_noise() -> void:
	if not on_air or call_left > 0.0 or phone.is_ringing() or rosa.listener:
		return
	calls += 1
	call_left = CALL_WAIT
	phone.ring()
	went_on_air.emit()


## E on the ringing phone: doña Rosa if it's her call, a listener otherwise.
func _on_phone_answered(cop: Cop) -> void:
	if rosa.calling:
		rosa.answer(cop)
		return
	call_left = 0.0
	cop.show_hint(CALLS[answered_calls % CALLS.size()])
	answered_calls += 1


## The call rang out with nobody answering: the phone stops and the listener's complaint reaches don Volumen.
func _unanswered() -> void:
	call_left = 0.0
	phone.get_node("Ring").hide()
	complaints += 1
	_say(phone.position + Vector3(0, 1.0, 0.6), "RADIO_LISTENER_COMPLAINT")
	listener_complained.emit()


## Cracks the studio's window, once: a fine and a crack across it.
func break_glass() -> void:
	if glass_cracked:
		return
	glass_cracked = true
	broken_goods += 1
	fines += GLASS_FINE
	raid.float_label("-%d" % GLASS_FINE, to_global(_glass.position) + Vector3.UP * 1.5, Color(1, 0.3, 0.25))
	var center := _glass.position
	_build.mesh_box(center + Vector3(0.2, 0.1, 0.03), Vector3(2.4, 0.04, 0.01), DARK)
	_build.mesh_box(center + Vector3(-0.3, -0.1, 0.03), Vector3(0.04, 0.9, 0.01), DARK)
	_say(center + Vector3(0, 1.0, 0.6), "RADIO_GLASS_BROKEN")
	glass_broken.emit()
	make_noise()


## A record falls off the shelves near `at` and breaks on the floor: a fine each, up to MAX_RECORDS.
func drop_record(at: Vector3) -> void:
	if records_broken >= MAX_RECORDS:
		return
	records_broken += 1
	broken_goods += 1
	fines += RECORD_FINE
	raid.float_label("-%d" % RECORD_FINE, at + Vector3.UP * 2.0, Color(1, 0.3, 0.25))
	var local := to_local(at)
	for i in 3:
		_build.mesh_box(Vector3(local.x + (i - 1) * 0.12, FLOOR_TOP + 0.01, local.z + 0.45 + i * 0.05),
			Vector3(0.12, 0.01, 0.1), Color.BLACK)
	_say(Vector3(local.x, FLOOR_TOP + 2.0, local.z + 0.5), "RADIO_RECORD_BROKEN")
	record_broken.emit()
	make_noise()


## A solid pane of glass you can see through.
func _pane(center: Vector3, size: Vector3) -> MeshInstance3D:
	_build.shape(_build.body(center), size)
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	look.mesh = box
	var see_through := StandardMaterial3D.new()
	see_through.albedo_color = GLASS
	see_through.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	look.material_override = see_through
	look.position = center
	$Built.add_child(look)
	return look


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
func _say(at: Vector3, key: String) -> Label3D:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(3.0).timeout.connect(label.queue_free)
	return label


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
