class_name PrintShop
extends Node3D

## The print shop "La Tinta Loca" as a place to raid (docs/diseno/allanamiento-imprenta.md, step 1): a brick shed in
## the city with its front to +Z and the wide door open on the west side under the sign and its smiling inkwell. By
## the front, the counter with the till and the bell, and the display of fine invitations behind its four glass panes.
## In the middle the rotativa (PrintingPress) with the four ink barrels and the empty one beside it; along the west
## wall the chibalete and the plates cabinet, with the binding table and the paper guillotine in front of them; on the
## east wall the shelf of ink jars. At the back, the paper store (reams and rolls), the fax, the recycling basket and
## the owner's office, locked with the till's key. Something thrown hard at a display pane or at an ink jar breaks it,
## a fine each. Don Renglón walks between the counter and the press and fills his complaint; the fax's "enviar prueba"
## sends him to the chibalete with an urgent order (step 4). Tipito, the apprentice, sorts type by the chibalete and
## wants one of the six wooden letters lying around (step 5). The case is one of its stories (STORIES), drawn with the
## seed, run by the same RaidCase as the other places (step 6). Every number here is (propuesta).

signal pane_broken(index: int)
signal jar_broken(index: int)
signal barrel_tipped(index: int)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const OWNER_SCENE := preload("res://scenes/npc/print_shop_owner.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the print shop can be suspected of (allanamiento-imprenta.md, "Las historias"): SUSPECT_<id> names it
## and CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["fake_bills", "fake_tickets", "fake_diplomas", "stolen_book", "fake_stickers", "fake_fines"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_PRINT_SHOP_TIP_B", "BRIEF_TIP_C",
	"BRIEF_PRINT_SHOP_TIP_D", "BRIEF_PRINT_SHOP_TIP_E"]
## The stories the print shop can tell, like Nursery.STORIES: what the comisario says once it's guessed, its "find it"
## row, what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist
## rows of its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras.
const STORIES := {
	"fake_bills": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FAKE_BILLS_B", "BRIEF_FAKE_BILLS_C", "BRIEF_FAKE_BILLS_D"],
		"find": "OBJ_FIND_BILLS_PLATE",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/bills_plate.tscn"), preload("res://scenes/props/bill_loupe.tscn"),
			preload("res://scenes/props/green_ink_tin.tscn")],
		"half_heights": [0.03, 0.015, 0.07],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_BILL_LOUPE", "OBJ_EXTRA_GREEN_INK"],
		"rig": preload("res://scripts/case/print_shop/fake_bills_rig.gd"),
	},
	"fake_tickets": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FAKE_TICKETS_B", "BRIEF_FAKE_TICKETS_C", "BRIEF_FAKE_TICKETS_D"],
		"find": "OBJ_FIND_TICKET_BOX",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/ticket_box.tscn"), preload("res://scenes/props/concert_poster.tscn"),
			preload("res://scenes/props/vip_stamp.tscn")],
		"half_heights": [0.125, 0.04, 0.06],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_CONCERT_POSTER", "OBJ_EXTRA_VIP_STAMP"],
		"rig": preload("res://scripts/case/print_shop/fake_tickets_rig.gd"),
	},
	"fake_diplomas": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FAKE_DIPLOMAS_B", "BRIEF_FAKE_DIPLOMAS_C", "BRIEF_FAKE_DIPLOMAS_D"],
		"find": "OBJ_FIND_DIPLOMA_ROLL",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/diploma_roll.tscn"), preload("res://scenes/props/university_seal.tscn"),
			preload("res://scenes/props/mortarboard.tscn")],
		"half_heights": [0.1, 0.06, 0.05],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_UNIVERSITY_SEAL", "OBJ_EXTRA_MORTARBOARD"],
		"rig": preload("res://scripts/case/print_shop/fake_diplomas_rig.gd"),
	},
	"stolen_book": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_STOLEN_BOOK_B", "BRIEF_STOLEN_BOOK_C", "BRIEF_STOLEN_BOOK_D"],
		"find": "OBJ_FIND_MANUSCRIPT",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/manuscript.tscn"), preload("res://scenes/props/writer_typewriter.tscn"),
			preload("res://scenes/props/book_cover.tscn")],
		"half_heights": [0.06, 0.125, 0.01],
		"heavy": [false, true, false],
		"extra_keys": ["OBJ_EXTRA_WRITER_TYPEWRITER", "OBJ_EXTRA_BOOK_COVER"],
		"rig": preload("res://scripts/case/print_shop/stolen_book_rig.gd"),
	},
	"fake_stickers": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FAKE_STICKERS_B", "BRIEF_FAKE_STICKERS_C", "BRIEF_FAKE_STICKERS_D"],
		"find": "OBJ_FIND_STICKER_PLATE",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/sticker_plate.tscn"), preload("res://scenes/props/sticker_album.tscn"),
			preload("res://scenes/props/sticker_pack.tscn")],
		"half_heights": [0.025, 0.015, 0.01],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_STICKER_ALBUM", "OBJ_EXTRA_STICKER_PACK"],
		"rig": preload("res://scripts/case/print_shop/fake_stickers_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the floor by the door, by the display, the paper store, the back, the east
## side and by the binding table.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-4.5, FLOOR_TOP, 7.0), Vector3(5.5, FLOOR_TOP, 6.5), Vector3(-8.5, FLOOR_TOP, -6.0),
	Vector3(-2.0, FLOOR_TOP, -6.5), Vector3(9.0, FLOOR_TOP, 3.0), Vector3(-6.0, FLOOR_TOP, 3.5),
]
const PRESS_MODEL := preload("res://assets/models/printing_press.glb")
const BARREL_MODELS: Array[PackedScene] = [preload("res://assets/models/ink_barrel_blue.glb"),
	preload("res://assets/models/ink_barrel_red.glb"), preload("res://assets/models/ink_barrel_yellow.glb"),
	preload("res://assets/models/ink_barrel_black.glb")]
const EMPTY_BARREL_MODEL := preload("res://assets/models/empty_ink_barrel.glb")
const TYPE_CASE_MODEL := preload("res://assets/models/type_case.glb")
const GUILLOTINE_MODEL := preload("res://assets/models/paper_guillotine.glb")
const ROLL_MODEL := preload("res://assets/models/paper_roll.glb")
const JAR_MODEL := preload("res://assets/models/ink_jar.glb")
const BELL_MODEL := preload("res://assets/models/counter_bell.glb")
const INKWELL_MODEL := preload("res://assets/models/smiling_inkwell.glb")
const HALF_X := 14.0
const HALF_Z := 9.0
const FLOOR_TOP := 0.06
## The shed's walls and roof, and the wide front door (open) from ENTRANCE_X - ENTRANCE_HALF to + ENTRANCE_HALF.
const SHOP_TOP := 4.5
const ENTRANCE_X := -6.5
const ENTRANCE_HALF := 1.3
const ENTRANCE_TOP := 2.6
## The rotativa along X in the middle: its infeed table (the belt, -X), the roller housing (open underneath up to
## HOUSING_LOW) and the output tray (+X). In this scene's space, from the press's middle.
const PRESS_AT := Vector3(0.0, FLOOR_TOP, 0.0)
const PRESS_HALF_Z := 0.7
const BELT_X := Vector2(-4.0, -0.5)
const BELT_TOP := 0.93
const HOUSING_X := Vector2(-0.5, 1.5)
const HOUSING_LOW := 0.6
const HOUSING_TOP := 2.3
const TRAY_X := Vector2(1.5, 4.0)
const TRAY_TOP := 0.85
## The red lever on the housing's +Z side, in the press's space.
const LEVER_AT := Vector3(0.5, 1.2, PRESS_HALF_Z + 0.05)
## The four ink barrels (blue, red, yellow, black) by the press, and the empty one a bit further.
const BARRELS: Array[Vector3] = [Vector3(-3.5, FLOOR_TOP, -2.0), Vector3(-2.5, FLOOR_TOP, -2.0),
	Vector3(-1.5, FLOOR_TOP, -2.0), Vector3(-0.5, FLOOR_TOP, -2.0)]
const BARREL_RADIUS := 0.32
const BARREL_TOP := 0.9
## A barrel tips over when something hits it faster than this, or a running cop bumps into it (step 3).
const BARREL_SPEED := 3.0
const EMPTY_BARREL_AT := Vector3(4.8, FLOOR_TOP, -2.0)
## By the front: the counter with the till and the bell, and the display of invitations (four glass panes, each a
## fine) with a gap behind it against the front wall.
const COUNTER_AT := Vector3(-10.5, FLOOR_TOP, 5.5)
const COUNTER_SIZE := Vector3(2.4, 1.0, 0.8)
const DISPLAY_AT := Vector3(2.5, FLOOR_TOP, 7.6)
const DISPLAY_SIZE := Vector3(3.2, 1.2, 0.6)
const DISPLAY_PANES := 4
const PANE_SPEED := 3.0
const PANE_FINE := 30
## Along the west wall: the chibalete (with a drawer pulled out on top), the plates cabinet, and in front of them the
## binding table and the paper guillotine.
const TYPE_CASE_AT := Vector3(-13.5, FLOOR_TOP, 1.0)
const DRAWER_AT := Vector3(-12.9, FLOOR_TOP + 1.1, 1.0)
const CABINET_AT := Vector3(-13.4, FLOOR_TOP, -3.0)
const CABINET_SIZE := Vector3(0.9, 1.9, 1.6)
const BINDING_AT := Vector3(-8.0, FLOOR_TOP, 2.5)
const BINDING_SIZE := Vector3(2.0, 0.8, 1.0)
const GUILLOTINE_AT := Vector3(-8.0, FLOOR_TOP, -2.0)
## On the east wall, the shelf of ink jars (each a fine).
const SHELF_AT := Vector3(13.5, FLOOR_TOP, 3.0)
const SHELF_SIZE := Vector3(0.45, 1.4, 3.2)
const SHELF_BOARD := 0.7
const INK_JARS := 8
const JARS_PER_ROW := 4
const JAR_FINE := 10
## At the back: the paper store (two rolls on the floor and the reams' stack with a gap behind it), the fax, the
## recycling basket and the office (east, locked).
const ROLLS: Array[Vector3] = [Vector3(-12.3, FLOOR_TOP, -6.5), Vector3(-10.0, FLOOR_TOP, -6.5)]
const REAMS_AT := Vector3(-6.5, FLOOR_TOP, -7.7)
const REAMS_SIZE := Vector3(2.4, 1.4, 0.8)
const FAX_AT := Vector3(0.0, FLOOR_TOP, -8.4)
const BASKET_AT := Vector3(3.5, FLOOR_TOP, -8.2)
const BASKET_SIZE := Vector3(0.8, 0.6, 0.7)
const OFFICE_WEST := 7.0
const OFFICE_FRONT := -3.0
const OFFICE_DOOR_X := 10.5
## Don Renglón's round: from the counter to the press, along its south side to the tray and back, checking sheets
## against the light. Where he sets the urgent orders, at the chibalete with his back to everything, and how long.
const OWNER_ROUTE: Array[Vector3] = [
	Vector3(-9.0, FLOOR_TOP, 3.8), Vector3(-5.0, FLOOR_TOP, 1.6), Vector3(-1.0, FLOOR_TOP, 1.6),
	Vector3(3.0, FLOOR_TOP, 1.6), Vector3(5.5, FLOOR_TOP, 1.6),
]
const ORDER_SPOT := Vector3(-12.0, FLOOR_TOP, 1.0)
const ORDER_TIME := 20.0
## "¡Me están llenando todo de huellas!": a cop he sees leaving footprints (once per cop), and a barrel tipping over.
const SAW_FOOTPRINTS := 5.0
const SAW_BARREL := 10.0
## The third urgent order: it's his own number.
const CAUGHT_ON := 10.0
## Tipito by the chibalete, facing the shop, and the six wooden letters lying around: the one he wants is drawn by
## the seed. One of them lies on the press's belt.
const KID_AT := Vector3(-12.0, FLOOR_TOP, 3.4)
const LETTERS: Array[String] = ["Ñ", "Q", "G", "R", "A", "Z"]
const LETTER_SPOTS: Array[Vector3] = [Vector3(-5.5, FLOOR_TOP + 0.3, 6.0), Vector3(6.0, FLOOR_TOP + 0.3, 4.5),
	Vector3(-3.0, BELT_TOP + 0.25, 0.0), Vector3(8.5, FLOOR_TOP + 0.3, -1.5), Vector3(-10.0, FLOOR_TOP + 0.3, -4.5),
	Vector3(2.0, FLOOR_TOP + 0.3, -6.0)]

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "under_press_rollers", "at": Vector3(0.5, FLOOR_TOP, 0.0), "heavy": true},
	{"id": "among_paper_rolls", "at": Vector3(-11.15, FLOOR_TOP, -6.5), "heavy": true},
	{"id": "behind_reams", "at": Vector3(-6.5, FLOOR_TOP, -8.5), "heavy": true},
	{"id": "in_empty_ink_barrel", "at": Vector3(4.8, FLOOR_TOP + 0.05, -2.0), "heavy": true},
	{"id": "in_print_office", "at": Vector3(12.0, FLOOR_TOP, -7.0), "heavy": true},
	{"id": "under_binding_table", "at": Vector3(-8.0, FLOOR_TOP, 2.5), "heavy": true},
	{"id": "in_print_counter", "at": Vector3(-10.5, FLOOR_TOP + 0.05, 5.5), "heavy": false},
	{"id": "in_type_case_drawer", "at": DRAWER_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "under_guillotine", "at": Vector3(-8.0, FLOOR_TOP, -2.0), "heavy": false},
	{"id": "behind_invitations", "at": Vector3(2.5, FLOOR_TOP, 8.45), "heavy": false},
	{"id": "in_recycling_basket", "at": BASKET_AT + Vector3(0, 0.05, 0), "heavy": false},
	{"id": "on_plates_cabinet", "at": CABINET_AT + Vector3(0, CABINET_SIZE.y, 0), "heavy": false},
]

const FLOOR := Color(0.62, 0.6, 0.56)
const BRICK := Color(0.72, 0.4, 0.3)
const WALL_IN := Color(0.9, 0.87, 0.78)
const WOOD := Color(0.55, 0.36, 0.22)
const STEEL := Color(0.5, 0.52, 0.56)
const PAPER := Color(0.96, 0.95, 0.9)
const SIGN_BLUE := Color(0.18, 0.37, 0.85)
const GLASS := Color(0.8, 0.9, 0.95, 0.3)
const CRACKED := Color(0.45, 0.5, 0.5, 0.75)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
## The rotativa: its belt, rollers, lever and flying sheets (step 2).
var press: PrintingPress
## The ink barrels (their looks and bodies) and the tipped ones by index, and the puddles and footprints (step 3).
var barrel_looks: Array[Node3D] = []
var barrel_bodies: Array[StaticBody3D] = []
var tipped: Array[int] = []
var ink: InkSpills
## The fax (his distraction), Don Renglón and his complaint bar.
var fax: OrderFax
var owner_npc: FloorBoss
var complaint_bar: ProgressBar
## The cops he already saw leaving footprints (id -> true).
var footprints_seen := {}
## Tipito and the wooden letters (step 5).
var kid: PrintShopKid
var letters: Array[WoodenLetter] = []
## The display's panes (each a body with its glass), the broken ones by index, and the ink jars.
var panes: Array[StaticBody3D] = []
var cracked: Array[int] = []
var jars: Array[Node3D] = []
var broken_jars: Array[int] = []
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
var car: PatrolCar
## Money taken off the case pay: the panes and the jars.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## Same seed, same print shop: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: PrintShopRig
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
	ink = InkSpills.new()
	ink.name = "Ink"
	ink.floor_top = FLOOR_TOP
	add_child(ink)
	_build_shed()
	_build_press()
	_build_front()
	_build_west()
	_build_back()
	_place_owner()
	_place_kid()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("print_shop")
	station_parking = city.transform * CityLayout.parking("station")
	_park_car()
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "print_shop", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = owner_npc
	raid.owner_id = "print_shop"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The print shop's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_PRINT_SHOP",
		"guess_key": "OBJ_GUESS_PRINT_SHOP",
		"broken_key": "OBJ_BROKEN_PRINT_SHOP",
		"complaint_key": "OBJ_COMPLAINT_PRINT_SHOP",
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


## What Don Renglón lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Tipito saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		owner_npc.slips.append(tr("RENGLON_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	owner_npc.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	kid.clue = tr("CLUE_TIPITO") % where
	kid.clue_speech = tr("TIPITO_CLUE_" + story_id) % where
	kid.told.connect(raid.add_clue)


func _park_car() -> void:
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))


## The floor, the brick walls with the wide door open in the front, the roof, the lights, and the sign over the door
## with its smiling inkwell.
func _build_shed() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, SHOP_TOP, [], BRICK)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, SHOP_TOP, [], BRICK)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, SHOP_TOP, [], BRICK)
	_build.wall_at("x", HALF_Z, -HALF_X, ENTRANCE_X - ENTRANCE_HALF, 0.0, SHOP_TOP, [], BRICK)
	_build.wall_at("x", HALF_Z, ENTRANCE_X + ENTRANCE_HALF, HALF_X, 0.0, SHOP_TOP, [], BRICK)
	_build.box(Vector3(ENTRANCE_X, (ENTRANCE_TOP + SHOP_TOP) / 2, HALF_Z),
		Vector3(ENTRANCE_HALF * 2, SHOP_TOP - ENTRANCE_TOP, PlaceBuilder.WALL), BRICK)
	var roof := _build.body(Vector3(0, SHOP_TOP + 0.1, 0))
	roof.name = "Roof"
	_build.shape(roof, Vector3(HALF_X * 2, 0.2, HALF_Z * 2))
	var roof_look := MeshInstance3D.new()
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(HALF_X * 2 + 0.4, 0.2, HALF_Z * 2 + 0.4)
	roof_look.mesh = roof_mesh
	roof_look.material_override = _build.material(BRICK.darkened(0.4))
	roof.add_child(roof_look)
	for x: float in [-9.0, 0.0, 9.0]:
		for z: float in [-5.0, 4.0]:
			_build.light(Vector3(x, SHOP_TOP - 0.4, z)).omni_range = 9.0
	_build.mesh_box(Vector3(ENTRANCE_X, SHOP_TOP - 0.9, HALF_Z + 0.12), Vector3(7.0, 1.0, 0.1), SIGN_BLUE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_PRINT_SHOP"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(ENTRANCE_X, SHOP_TOP - 0.9, HALF_Z + 0.19)
	$Built.add_child(sign_label)
	_model(INKWELL_MODEL, Vector3(ENTRANCE_X + 4.2, SHOP_TOP - 1.4, HALF_Z + 0.6))


## The rotativa: its moving belt with the railing and the lever (PrintingPress), the roller housing on its four posts
## with room underneath, the output tray, and the four ink barrels and the empty one beside it.
func _build_press() -> void:
	_model(PRESS_MODEL, PRESS_AT)
	var width := PRESS_HALF_Z * 2
	press = PrintingPress.new()
	press.name = "Press"
	press.position = PRESS_AT
	add_child(press)
	press.build(BELT_X, BELT_TOP, PRESS_HALF_Z, TRAY_X, TRAY_TOP, LEVER_AT, case_seed)
	var housing_high := HOUSING_TOP - HOUSING_LOW
	_build.shape(_build.body(PRESS_AT + Vector3((HOUSING_X.x + HOUSING_X.y) / 2, HOUSING_LOW + housing_high / 2, 0)),
		Vector3(HOUSING_X.y - HOUSING_X.x, housing_high, width))
	_build.shape(_build.body(PRESS_AT + Vector3((TRAY_X.x + TRAY_X.y) / 2, TRAY_TOP - 0.05, 0)),
		Vector3(TRAY_X.y - TRAY_X.x, 0.1, width))
	for x: float in [BELT_X.x + 0.1, HOUSING_X.x + 0.1, HOUSING_X.y - 0.1, TRAY_X.y - 0.1]:
		for z: float in [-PRESS_HALF_Z + 0.1, PRESS_HALF_Z - 0.1]:
			var low := HOUSING_LOW if x > BELT_X.y and x < TRAY_X.x else TRAY_TOP - 0.1
			_build.shape(_build.body(PRESS_AT + Vector3(x, low / 2, z)), Vector3(0.1, low, 0.1))
	for i in BARRELS.size():
		barrel_looks.append(_model(BARREL_MODELS[i], BARRELS[i]))
		barrel_bodies.append(_cylinder(BARRELS[i] + Vector3(0, BARREL_TOP / 2, 0), BARREL_RADIUS, BARREL_TOP))
		var area := _area(BARRELS[i] + Vector3(0, BARREL_TOP / 2, 0), Vector3(1.0, BARREL_TOP, 1.0))
		area.collision_mask = 2 | 4
		area.body_entered.connect(func(hit: Node3D) -> void:
			var away := BARRELS[i] - hit.global_position
			if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > BARREL_SPEED:
				tip_barrel(i, (hit as RigidBody3D).linear_velocity)
			elif hit is Cop and (hit as Cop).is_running:
				tip_barrel(i, away))
	_model(EMPTY_BARREL_MODEL, EMPTY_BARREL_AT)
	var side := BARREL_RADIUS * 1.6
	_build.shape(_build.body(EMPTY_BARREL_AT + Vector3(0, 0.025, 0)), Vector3(side, 0.05, side))
	for turn in 4:
		var out := Vector3(side / 2, 0, 0).rotated(Vector3.UP, turn * PI / 2)
		var size := Vector3(0.05, BARREL_TOP, side) if turn % 2 == 0 else Vector3(side, BARREL_TOP, 0.05)
		_build.shape(_build.body(EMPTY_BARREL_AT + out + Vector3(0, BARREL_TOP / 2, 0)), size)


## By the front: the counter with the till (open at the back, something fits inside) and the bell, the display of
## invitations with its four panes, and the shelf of ink jars on the east wall.
func _build_front() -> void:
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", WOOD)
	till = Till.new()
	till.position = COUNTER_AT + Vector3(0.5, COUNTER_SIZE.y + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_PRINT_SHOP"
	add_child(till)
	_model(BELL_MODEL, COUNTER_AT + Vector3(-0.6, COUNTER_SIZE.y, 0.1))
	_build.box(DISPLAY_AT + Vector3(0, 0.25, 0), Vector3(DISPLAY_SIZE.x, 0.5, DISPLAY_SIZE.z), WOOD)
	_build.box(DISPLAY_AT + Vector3(0, DISPLAY_SIZE.y + 0.03, 0), Vector3(DISPLAY_SIZE.x, 0.06, DISPLAY_SIZE.z), WOOD)
	for i in 6:
		var at := DISPLAY_AT + Vector3(-1.3 + i * 0.52, 0.52, 0.05)
		_build.mesh_box(at, Vector3(0.3, 0.03, 0.22), [PAPER, Color(0.95, 0.8, 0.85), Color(0.85, 0.9, 1.0)][i % 3])
	var pane_width := DISPLAY_SIZE.x / DISPLAY_PANES
	for i in DISPLAY_PANES:
		_pane(DISPLAY_AT + Vector3(-DISPLAY_SIZE.x / 2 + pane_width * (i + 0.5), 0.85, -DISPLAY_SIZE.z / 2),
			Vector3(pane_width - 0.04, 0.7, 0.04))
	_build.open_box(SHELF_AT, SHELF_SIZE, "-x", WOOD)
	_build.box(SHELF_AT + Vector3(0, SHELF_BOARD, 0), Vector3(SHELF_SIZE.x - 0.1, 0.05, SHELF_SIZE.z - 0.1), WOOD)
	for i in INK_JARS:
		var row := 0 if i < JARS_PER_ROW else 1
		var at := SHELF_AT + Vector3(0, SHELF_BOARD + 0.03 + row * (SHELF_SIZE.y - SHELF_BOARD),
			-1.2 + (i % JARS_PER_ROW) * 0.8)
		jars.append(_model(JAR_MODEL, at))
		var area := _area(at + Vector3(-0.1, 0.12, 0), Vector3(0.6, 0.35, 0.4))
		area.body_entered.connect(func(hit: Node3D) -> void:
			if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > PANE_SPEED:
				break_jar(i))


## One glass pane of the display at `center`, `size` big: a body with its glass, and an area in front of it that
## breaks it when something hits it fast.
func _pane(center: Vector3, size: Vector3) -> void:
	var body := _build.body(center)
	body.name = "Pane%d" % panes.size()
	_build.shape(body, size)
	var glass := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	glass.mesh = box
	glass.material_override = _glass(GLASS)
	body.add_child(glass)
	var index := panes.size()
	panes.append(body)
	var area := _area(center, size + Vector3(0, 0, 0.8))
	area.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > PANE_SPEED:
			break_pane(index))


## Along the west wall: the chibalete with its drawer pulled out, the plates cabinet, the binding table and the paper
## guillotine.
func _build_west() -> void:
	_model(TYPE_CASE_MODEL, TYPE_CASE_AT, PI / 2)
	_build.shape(_build.body(TYPE_CASE_AT + Vector3(0, 0.55, 0)), Vector3(0.6, 1.1, 2.0))
	_build.open_box(DRAWER_AT, Vector3(0.6, 0.15, 0.5), "top", WOOD.lightened(0.2))
	_build.box(CABINET_AT + Vector3(0, CABINET_SIZE.y / 2, 0), CABINET_SIZE, WOOD.darkened(0.2))
	for i in 3:
		_build.mesh_box(CABINET_AT + Vector3(CABINET_SIZE.x / 2, 0.4 + i * 0.6, 0), Vector3(0.02, 0.4, 1.3),
			STEEL.lightened(0.2))
	_build.legs(BINDING_AT, Vector2(BINDING_SIZE.x, BINDING_SIZE.z), BINDING_SIZE.y, WOOD)
	_build.box(BINDING_AT + Vector3(0, BINDING_SIZE.y + 0.03, 0), Vector3(BINDING_SIZE.x, 0.06, BINDING_SIZE.z), WOOD)
	for i in 4:
		_build.mesh_box(BINDING_AT + Vector3(-0.6 + i * 0.4, BINDING_SIZE.y + 0.1, 0), Vector3(0.25, 0.08 + i * 0.03,
			0.35), [Color(0.7, 0.2, 0.2), Color(0.2, 0.4, 0.7), Color(0.3, 0.6, 0.3), PAPER][i])
	_model(GUILLOTINE_MODEL, GUILLOTINE_AT)
	_build.shape(_build.body(GUILLOTINE_AT + Vector3(0, 0.85, 0)), Vector3(1.2, 0.1, 0.8))
	_build.shape(_build.body(GUILLOTINE_AT + Vector3(0, 1.25, -0.2)), Vector3(1.2, 0.8, 0.15))


## At the back: the paper store (rolls and reams), the fax on its table, the recycling basket and the office, locked,
## with its desk.
func _build_back() -> void:
	for at in ROLLS:
		_model(ROLL_MODEL, at)
		_build.shape(_build.body(at + Vector3(0, 0.45, 0)), Vector3(0.9, 0.9, 1.2))
	_build.box(REAMS_AT + Vector3(0, REAMS_SIZE.y / 2, 0), REAMS_SIZE, PAPER)
	for i in 7:
		_build.mesh_box(REAMS_AT + Vector3(0, 0.1 + i * 0.2, REAMS_SIZE.z / 2 + 0.005),
			Vector3(REAMS_SIZE.x - 0.1, 0.02, 0.01), Color(0.4, 0.55, 0.85))
	_build.legs(FAX_AT, Vector2(0.9, 0.6), 0.85, WOOD)
	_build.box(FAX_AT + Vector3(0, 0.88, 0), Vector3(0.9, 0.06, 0.6), WOOD)
	fax = OrderFax.new()
	fax.name = "Fax"
	fax.position = FAX_AT + Vector3(0, 0.91, 0)
	add_child(fax)
	_build.open_box(BASKET_AT, BASKET_SIZE, "top", Color(0.3, 0.55, 0.85))
	for i in 3:
		_build.mesh_box(BASKET_AT + Vector3(-0.2 + i * 0.2, BASKET_SIZE.y - 0.05, 0), Vector3(0.2, 0.08, 0.2), PAPER)
	_build.wall_at("x", OFFICE_FRONT, OFFICE_WEST, HALF_X, 0.0, SHOP_TOP, [OFFICE_DOOR_X], WALL_IN)
	_build.wall_at("z", OFFICE_WEST, -HALF_Z, OFFICE_FRONT, 0.0, SHOP_TOP, [], WALL_IN)
	_build.legs(Vector3(10.0, FLOOR_TOP, -8.0), Vector2(2.0, 1.0), 0.75, WOOD)
	_build.box(Vector3(10.0, FLOOR_TOP + 0.78, -8.0), Vector3(2.0, 0.06, 1.0), WOOD)
	_build.light(Vector3(10.5, SHOP_TOP - 0.4, -6.0))
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_FRONT)
	add_child(office_door)


## Breaks display pane `index`, once: a fine, the glass goes grey and cracked and the invitations are in reach.
func break_pane(index: int) -> void:
	if cracked.has(index):
		return
	cracked.append(index)
	broken_goods += 1
	fines += PANE_FINE
	raid.float_label("-%d" % PANE_FINE, panes[index].global_position + Vector3.UP, Color(1, 0.3, 0.25))
	var pane := panes[index]
	(pane.get_child(0) as CollisionShape3D).set_deferred("disabled", true)
	(pane.get_child(1) as MeshInstance3D).material_override = _glass(CRACKED)
	(pane.get_child(1) as MeshInstance3D).scale = Vector3(1, 0.25, 1)
	(pane.get_child(1) as MeshInstance3D).position.y = -0.26
	_say(pane.position + Vector3(0, 1.2, 0), "PRINT_SHOP_GLASS_BROKEN")
	pane_broken.emit(index)


## Breaks ink jar `index`, once: a fine, it's gone and its ink spills on the floor below the shelf.
func break_jar(index: int) -> void:
	if broken_jars.has(index):
		return
	broken_jars.append(index)
	broken_goods += 1
	fines += JAR_FINE
	raid.float_label("-%d" % JAR_FINE, jars[index].global_position + Vector3.UP, Color(1, 0.3, 0.25))
	jars[index].visible = false
	ink.spill(Vector3(SHELF_AT.x - 1.0, FLOOR_TOP, jars[index].position.z), 0)
	_say(jars[index].position + Vector3(-0.6, 1.0, 0), "PRINT_SHOP_JAR_BROKEN")
	jar_broken.emit(index)


## The fax's order, Don Renglón walking his round, what he can't stand to see and the complaint bar.
func _place_owner() -> void:
	owner_npc = OWNER_SCENE.instantiate()
	owner_npc.name = "DonRenglon"
	owner_npc.route = OWNER_ROUTE
	owner_npc.printer_spot = ORDER_SPOT
	owner_npc.printer = fax
	owner_npc.fix_time = ORDER_TIME
	owner_npc.fix_facing = TYPE_CASE_AT + Vector3(0, 1, 0)
	add_child(owner_npc)
	owner_npc.start_at(0)
	office_door.broken.connect(owner_npc.door_broken)
	owner_npc.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_PRINT_SHOP"))
	till.opened.connect(func(at: Vector3) -> void: owner_npc.saw(at, FloorBoss.SAW_TILL))
	fax.caught_on.connect(func() -> void: owner_npc.scold(CAUGHT_ON, "RENGLON_CAUGHT_ON"))
	ink.footprint_left.connect(_on_footprint)
	barrel_tipped.connect(func(index: int) -> void:
		owner_npc.saw(BARRELS[index] + Vector3.UP * 0.5, SAW_BARREL, "RENGLON_BARREL"))
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


## Tipito by the chibalete, missing the letter the seed draws, and the six wooden letters around the shop.
func _place_kid() -> void:
	kid = PrintShopKid.new()
	kid.name = "Tipito"
	kid.position = KID_AT
	kid.rotation.y = PI / 2
	kid.wanted = LETTERS[absi(case_seed) % LETTERS.size()]
	add_child(kid)
	for i in LETTERS.size():
		var letter := WoodenLetter.new()
		letter.name = "Letter%d" % i
		letter.letter = LETTERS[i]
		letter.position = LETTER_SPOTS[i]
		letter.rotation.y = i * 1.1
		add_child(letter)
		letters.append(letter)


## The wooden letter Tipito is missing.
func wanted_letter() -> WoodenLetter:
	return letters[LETTERS.find(kid.wanted)]


## A cop left a footprint: "¡Me están llenando todo de huellas!", once per cop, if he sees it.
func _on_footprint(cop: Cop, at: Vector3) -> void:
	if footprints_seen.has(cop.get_instance_id()):
		return
	if owner_npc.saw(at + Vector3.UP * 0.3, SAW_FOOTPRINTS, "RENGLON_FOOTPRINTS"):
		footprints_seen[cop.get_instance_id()] = true


## Tips ink barrel `index` over toward `away`, once: it lies on the floor and leaves a puddle of its ink in front.
func tip_barrel(index: int, away: Vector3) -> void:
	if tipped.has(index):
		return
	tipped.append(index)
	var flat := Vector3(away.x, 0, away.z).normalized()
	if flat == Vector3.ZERO:
		flat = Vector3.BACK
	(barrel_bodies[index].get_child(0) as CollisionShape3D).set_deferred("disabled", true)
	var look := barrel_looks[index]
	look.basis = Basis(Vector3.UP.cross(flat).normalized(), PI / 2)
	look.position = BARRELS[index] + Vector3(0, BARREL_RADIUS, 0)
	ink.spill(BARRELS[index] + flat * (BARREL_TOP + 0.3), index)
	_say(BARRELS[index] + Vector3(0, 1.5, 0), "PRINT_SHOP_BARREL_TIPPED")
	barrel_tipped.emit(index)


func _glass(color: Color) -> StandardMaterial3D:
	var glass := StandardMaterial3D.new()
	glass.albedo_color = color
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return glass


## A standing cylinder body for the collisions, `height` tall, centered at `center`.
func _cylinder(center: Vector3, radius: float, height: float) -> StaticBody3D:
	var body := _build.body(center)
	var collision := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = height
	collision.shape = cylinder
	body.add_child(collision)
	return body


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
