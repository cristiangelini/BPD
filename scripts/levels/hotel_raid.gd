class_name HotelRaid
extends Node3D

## The raid on the Hotel Gran Siesta (hotel-allanamiento.md, step 1, decision 240). The building is the crime scene's
## (Hotel, with crime_scene off: no guests, one 13 behind the wardrobe); the raid puts on top what makes it a raid:
## the rooms and the suite locked, the master key on the board behind the desk (or the ram), the vases downstairs and
## the bedside lamps upstairs that break into fines, and the hiding spots. Don Bostezo watches from the desk and fills
## the complaint meter; the little pillow on the desk puts him to sleep and the bell wakes him (step 2). Doña Escoba
## walks the corridor with her cart and tells what she saw to whoever makes one of the unmade beds (step 3). The case
## is one of its stories (STORIES), drawn with the seed, run by the same RaidCase as the other places (step 4).
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const VASE_SCENE := preload("res://scenes/props/ornament_vase.tscn")
const LAMP_SCENE := preload("res://scenes/props/hotel_lamp.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the hotel can be suspected of (hotel-allanamiento.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["regular_guest", "casino_13", "robes", "lift_1987", "sleepwalker", "fake_reviews"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_HOTEL_TIP_B", "BRIEF_TIP_C", "BRIEF_HOTEL_TIP_D",
	"BRIEF_HOTEL_TIP_E"]
## The stories the hotel can tell, like Groomer.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the spots it keeps
## for itself, the checklist rows of its extras and its rig, which places the main evidence.
const STORIES := {
	"regular_guest": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_REGULAR_GUEST_B", "BRIEF_REGULAR_GUEST_C", "BRIEF_REGULAR_GUEST_D"],
		"find": "OBJ_FIND_REGULAR_GUEST",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/costume_trunk.tscn"), preload("res://scenes/props/fake_guest_book.tscn"),
			preload("res://scenes/props/spare_wig.tscn")],
		"half_heights": [0.25, 0.02, 0.06],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_GUEST_BOOK", "OBJ_EXTRA_WIG_SPARE"],
		"rig": preload("res://scripts/case/hotel/regular_guest_rig.gd"),
	},
	"robes": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_ROBES_B", "BRIEF_ROBES_C", "BRIEF_ROBES_D"],
		"find": "OBJ_FIND_ROBES",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/robe_bag.tscn"), preload("res://scenes/props/buyers_list.tscn"),
			preload("res://scenes/props/embroidery_machine.tscn")],
		"half_heights": [0.3, 0.005, 0.18],
		"heavy": [true, false, true],
		"extra_keys": ["OBJ_EXTRA_BUYERS_LIST", "OBJ_EXTRA_EMBROIDERY"],
		"rig": preload("res://scripts/case/hotel/robes_rig.gd"),
	},
	"lift_1987": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_LIFT_B", "BRIEF_LIFT_C", "BRIEF_LIFT_D"],
		"find": "OBJ_FIND_LIFT",
		"hidden": [preload("res://scenes/props/lift_crank.tscn"), preload("res://scenes/props/printing_plates.tscn")],
		"half_heights": [0.13, 0.03],
		"heavy": [false, false],
		"reserved": ["hotel_by_lift"],
		"extra_keys": ["OBJ_EXTRA_LIFT_CRANK", "OBJ_EXTRA_PLATES"],
		"rig": preload("res://scripts/case/hotel/lift_rig.gd"),
	},
	"casino_13": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_CASINO_B", "BRIEF_CASINO_C", "BRIEF_CASINO_D"],
		"find": "OBJ_FIND_CASINO",
		"hidden": [preload("res://scenes/props/casino_chip_box.tscn"), preload("res://scenes/props/debt_book.tscn")],
		"half_heights": [0.06, 0.015],
		"heavy": [false, false],
		"reserved": ["hotel_room_13"],
		"extra_keys": ["OBJ_EXTRA_CHIP_BOX", "OBJ_EXTRA_DEBT_BOOK"],
		"rig": preload("res://scripts/case/hotel/casino_rig.gd"),
	},
}
## Surfaces where the suspicions' clue notes can lie; three are drawn with the seed.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-7.7, 0.77, 3.7), Vector3(-11.2, 0.77, 4.8), Hotel.ARMCHAIRS[0] + Vector3(0, 0.5, 0.1),
	Vector3(-9.4, Hotel.UP + 0.6, 4.0), Vector3(-3.0, Hotel.FLOOR_TOP, 5.5), Vector3(11.8, Hotel.UP, -0.5),
]
## The suite's door in `doors` (rooms go by their number).
const SUITE_DOOR := 0
const VASE_HALF_HEIGHT := 0.13
const LAMP_HALF_HEIGHT := 0.21
## The vases: on the reception desk, on the piano and on each dining table.
const VASES: Array[Vector3] = [
	Vector3(-1.2, 1.05, -6.5), Vector3(-11.6, 1.1, -6.5), Vector3(-10.0, 0.77, 0.0), Vector3(-8.0, 0.77, 4.0),
	Vector3(-11.5, 0.77, 4.5),
]
## The little pillow on the desk, on don Bostezo's side, and the bell's collision over the hotel's bell.
const PILLOW_AT := Vector3(0.2, 1.11, -6.65)
const BELL_HIT_AT := Vector3(0.9, 1.12, -6.4)
## The unmade beds' tops sit over the hotel's bed boxes; doña Escoba walks the corridor south of its middle, clear
## of the wardrobe.
const BED_TOP := Hotel.UP + 0.45
const MAID_Z := 0.4
## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "hotel_in_tub", "at": Hotel.TUB_AT + Vector3(0, 0.6, 0), "heavy": true},
	{"id": "hotel_by_lift", "at": Hotel.LIFT_AT + Vector3(0, Hotel.FLOOR_TOP, 0.5), "heavy": true},
	{"id": "hotel_behind_desk", "at": Vector3(1.2, Hotel.FLOOR_TOP, -7.6), "heavy": true},
	{"id": "hotel_room_13", "at": Vector3(3.5, Hotel.UP, -4.0), "heavy": true},
	{"id": "hotel_by_suite_bed", "at": Hotel.SUITE_BED_AT + Vector3(1.6, 0, 0), "heavy": true},
	{"id": "hotel_behind_piano", "at": Vector3(Hotel.PIANO_AT.x, Hotel.FLOOR_TOP, -7.8), "heavy": true},
	{"id": "hotel_on_piano", "at": Hotel.PIANO_AT + Vector3(0.4, 1.1, 0), "heavy": false},
	{"id": "hotel_on_bed_14", "at": Vector3(7.0, BED_TOP + HotelBed.SIZE.y, Hotel.BACK_Z + 1.1), "heavy": false},
	{"id": "hotel_in_case", "at": Hotel.CASE_AT + Vector3(0, 0.9, 0), "heavy": false},
	{"id": "hotel_in_plant", "at": Hotel.PLANT_AT + Vector3(0, 0.5, 0), "heavy": false},
	{"id": "hotel_on_armchair", "at": Hotel.ARMCHAIRS[1] + Vector3(0, 0.5, 0.1), "heavy": false},
	{"id": "hotel_on_table", "at": Hotel.TABLES[0] + Vector3(0.25, 0.77, 0.25), "heavy": false},
]

## Same seed, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The case flow every raid shares.
var raid: RaidCase
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: HotelRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var city_map: CityMap
## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var hotel: Hotel
var key_board: HotelKeyBoard
## The locked doors by room number, the suite's under SUITE_DOOR.
var doors: Dictionary = {}
var vases: Array[Ornament] = []
var lamps: Array[Ornament] = []
var broken_goods := 0
## Fines for what the cops broke (each one is an Ornament.FINE).
var fines: int:
	get: return raid.fines
var concierge: HotelConcierge
var pillow: HotelPillow
var bell: HotelBell
var complaint_bar: ProgressBar
var maid: HotelRaidMaid
## The unmade beds by room number.
var beds: Dictionary = {}
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
	hotel = Hotel.new()
	hotel.name = "Hotel"
	hotel.crime_scene = false
	hotel.case_seed = case_seed
	add_child(hotel)
	_place_doors()
	_place_key_board()
	_place_fragile()
	_place_concierge()
	_place_maid()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("hotel")
	station_parking = city.transform * CityLayout.parking("station")
	raid.station_parking = station_parking
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "hotel", car)
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = concierge
	raid.owner_id = "concierge"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The hotel's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_HOTEL",
		"guess_key": "OBJ_GUESS_HOTEL",
		"broken_key": "OBJ_BROKEN_HOTEL",
		"complaint_key": "OBJ_COMPLAINT_HOTEL",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": concierge.complaint,
	}


## The story with that id from --story=<id> among the user args, or one drawn from the seed.
static func pick_story(case_seed: int, args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with("--story=") and STORIES.has(arg.trim_prefix("--story=")):
			return arg.trim_prefix("--story=")
	return STORIES.keys()[case_seed % STORIES.size()]


## The story's hidden items, each in a spot drawn with the seed among the ones it doesn't keep for itself (heavy ones
## only where they fit).
func _place_hidden() -> void:
	var story: Dictionary = STORIES[story_id]
	var reserved: Array = story.get("reserved", [])
	var free: Array = range(SPOTS.size()).filter(func(i: int) -> bool: return not reserved.has(SPOTS[i].id))
	var spot_heavy: Array = free.map(func(i: int) -> bool: return SPOTS[i].heavy)
	hidden_spots = HidingDraw.draw(case_seed, spot_heavy, story.heavy, 1).spots.map(func(i: int) -> int: return free[i])
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


## What don Bostezo lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## doña Escoba saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		concierge.slips.append(tr("HOTEL_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	concierge.slipped.connect(raid.add_clue)
	maid.clue = tr("HOTEL_MAID_CLUE") % tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	maid.told.connect(raid.add_clue)


## A locked door on each guest room (the 13 has none: the wardrobe hides it) and on the suite. Each one hangs from
## its hinge, turned on a holder so it swings into its room.
func _place_doors() -> void:
	var half := GameScale.DOOR_WIDTH / 2
	for number: int in Hotel.ROOMS:
		if number == Hotel.HIDDEN_ROOM:
			continue
		var room: Dictionary = Hotel.ROOMS[number]
		if room.side == "n":
			doors[number] = _door(Vector3(room.door - half, Hotel.UP, -Hotel.CORRIDOR), 0.0)
		else:
			doors[number] = _door(Vector3(room.door + half, Hotel.UP, Hotel.CORRIDOR), PI)
	doors[SUITE_DOOR] = _door(Vector3(Hotel.SUITE_X, Hotel.UP, Hotel.DOOR_SUITE_Z + half), PI / 2)


## FrontDoor swings to an absolute turn, so a turned door sits on a holder that carries the turn.
func _door(at: Vector3, turn: float) -> FrontDoor:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = turn
	add_child(holder)
	var door: FrontDoor = DOOR_SCENE.instantiate()
	holder.add_child(door)
	return door


func _place_key_board() -> void:
	key_board = HotelKeyBoard.new()
	key_board.name = "KeyBoard"
	key_board.position = Hotel.KEY_BOARD_AT
	add_child(key_board)


## The vases downstairs and a lamp on every nightstand upstairs: each one that breaks is a fine.
func _place_fragile() -> void:
	for at: Vector3 in VASES:
		vases.append(_fragile(VASE_SCENE, at + Vector3.UP * (VASE_HALF_HEIGHT + 0.005)))
	for number: int in Hotel.ROOMS:
		var room: Dictionary = Hotel.ROOMS[number]
		var north: bool = room.side == "n"
		var far := (Hotel.BACK_Z + 1.1) if north else (Hotel.FRONT_Z - 1.1)
		var stand := Vector3(Hotel.room_middle(number).x + 1.1, Hotel.UP + 0.6, far + (-0.6 if north else 0.6))
		lamps.append(_fragile(LAMP_SCENE, stand + Vector3.UP * (LAMP_HALF_HEIGHT + 0.005)))


func _fragile(scene: PackedScene, at: Vector3) -> Ornament:
	var item: Ornament = scene.instantiate()
	item.position = at
	add_child(item)
	item.broken.connect(_on_fragile_broken)
	return item


func _on_fragile_broken(at: Vector3) -> void:
	broken_goods += 1
	raid.fines += Ornament.FINE
	raid.float_label("-%d" % Ornament.FINE, at, Color(1, 0.3, 0.25))
	concierge.saw(at, HotelConcierge.SAW_BREAK)


## Don Bostezo behind the desk, the pillow and the bell on it, and the complaint meter. A rammed door reaches him
## anywhere, and the key only counts if he's awake.
func _place_concierge() -> void:
	concierge = HotelConcierge.new()
	concierge.name = "Concierge"
	concierge.position = Hotel.CONCIERGE_AT + Vector3(0, Hotel.FLOOR_TOP, 0)
	add_child(concierge)
	pillow = HotelPillow.new()
	pillow.name = "Pillow"
	pillow.position = PILLOW_AT
	pillow.concierge = concierge
	add_child(pillow)
	bell = HotelBell.new()
	bell.name = "Bell"
	bell.position = BELL_HIT_AT
	bell.concierge = concierge
	add_child(bell)
	for door: FrontDoor in doors.values():
		door.broken.connect(concierge.door_broken)
	key_board.taken.connect(concierge.key_taken)
	concierge.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_HOTEL"))
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
	concierge.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Doña Escoba in the corridor, and an unmade bed in each guest room: whoever makes one gets her chat.
func _place_maid() -> void:
	maid = HotelRaidMaid.new()
	maid.name = "Maid"
	maid.position = Vector3(Hotel.MAID_AT.x, Hotel.UP, MAID_Z)
	maid.rotation.y = -PI / 2
	add_child(maid)
	for number: int in Hotel.GUEST_ROOMS:
		var north: bool = Hotel.ROOMS[number].side == "n"
		var bed := HotelBed.new()
		bed.name = "Bed%d" % number
		bed.room = number
		var far := (Hotel.BACK_Z + 1.1) if north else (Hotel.FRONT_Z - 1.1)
		bed.position = Vector3(Hotel.room_middle(number).x, BED_TOP, far)
		bed.rotation.y = 0.0 if north else PI
		add_child(bed)
		bed.started.connect(maid.helping.bind(number))
		bed.made_by.connect(maid.helped)
		beds[number] = bed
