class_name DentistRaid
extends Node3D

## The dental office "Sonrisa Total" as a place to raid (docs/diseno/allanamiento-dentista.md, step 2): one floor on
## its lot in the city, with the front to +Z. The waiting room at the front, with the reception desk (the candy jar and
## the next-patient bell on it), the fish tank and the chairs; a corridor across; and at the back the two consulting
## rooms with their chairs and gas tanks, the lab with the cabinet of denture molds and the X-ray light box, and Dr.
## Molina's office with the storeroom behind it, locked. The fish tank breaks when something hits it hard: a fine,
## and the floor around it stays wet (a cop running there slips, like on the jail's wet floor). Each mold that breaks
## counts. SPOTS are the 12 hiding spots the stories draw from (step 5). Dr. Molina walks the corridor (step 3): he
## fills the complaint ("¡Eso no es estéril!") with every mold he sees break and every cop he sees up on one of his
## chairs, and the next-patient bell on the reception sends him to consulting room 1 with his back to the door.
## Lucho waits in the waiting room and talks for a candy from the jar (step 4), and the gas tanks in the consulting
## rooms leak laughing gas when knocked over. The case is one of its stories (STORIES), drawn with the seed, run by the
## same RaidCase as the other places (step 5).
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const CHAIR_MODEL := preload("res://assets/models/dentist_chair.glb")
const TANK_MODEL := preload("res://assets/models/fish_tank.glb")
const CABINET_MODEL := preload("res://assets/models/mold_cabinet.glb")
const MOLD_MODEL := preload("res://assets/models/denture_mold.glb")
const XRAY_MODEL := preload("res://assets/models/xray_lightbox.glb")
const JAR_MODEL := preload("res://assets/models/candy_jar.glb")
const CANDY_MODEL := preload("res://assets/models/candy_pop.glb")
const MOLINA_SCENE := preload("res://scenes/npc/dentist_molina.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the office can be suspected of (allanamiento-dentista.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["gold_teeth", "laughing_gas", "tooth_mouse", "famous_dentures", "rising_chair", "dental_floss"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_DENTIST_TIP_B", "BRIEF_TIP_C", "BRIEF_DENTIST_TIP_D",
	"BRIEF_DENTIST_TIP_E"]
## The stories the office can tell, like GymRaid.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy; the first one is the
## main evidence, unless "main_hidden" is false and the rig places it), the checklist rows of its extras and its rig.
const STORIES := {
	"gold_teeth": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_GOLD_TEETH_B", "BRIEF_GOLD_TEETH_C", "BRIEF_GOLD_TEETH_D"],
		"find": "OBJ_FIND_GOLD_CROWN_BOX",
		"hidden": [preload("res://scenes/props/gold_crown_box.tscn"), preload("res://scenes/props/gold_crucible.tscn"),
			preload("res://scenes/props/crown_price_list.tscn")],
		"half_heights": [0.08, 0.07, 0.003],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_GOLD_CRUCIBLE", "OBJ_EXTRA_CROWN_PRICE_LIST"],
		"rig": preload("res://scripts/case/dentist/gold_teeth_rig.gd"),
	},
	"laughing_gas": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_LAUGHING_GAS_B", "BRIEF_LAUGHING_GAS_C", "BRIEF_LAUGHING_GAS_D"],
		"find": "OBJ_FIND_GAS_BUNDLE",
		"hidden": [preload("res://scenes/props/gas_bundle.tscn"), preload("res://scenes/props/gas_balloons.tscn"),
			preload("res://scenes/props/carcajada_invoice.tscn")],
		"half_heights": [0.38, 0.3, 0.003],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_GAS_BALLOONS", "OBJ_EXTRA_CARCAJADA_INVOICE"],
		"rig": preload("res://scripts/case/dentist/laughing_gas_rig.gd"),
	},
	"tooth_mouse": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_TOOTH_MOUSE_B", "BRIEF_TOOTH_MOUSE_C", "BRIEF_TOOTH_MOUSE_D"],
		"find": "OBJ_FIND_TEETH_JAR",
		"hidden": [preload("res://scenes/props/teeth_jar.tscn"), preload("res://scenes/props/mouse_costume.tscn"),
			preload("res://scenes/props/pillow_map.tscn")],
		"half_heights": [0.17, 0.15, 0.003],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_MOUSE_COSTUME", "OBJ_EXTRA_PILLOW_MAP"],
		"rig": preload("res://scripts/case/dentist/tooth_mouse_rig.gd"),
	},
	"famous_dentures": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_FAMOUS_DENTURES_B", "BRIEF_FAMOUS_DENTURES_C", "BRIEF_FAMOUS_DENTURES_D"],
		"find": "OBJ_FIND_DENTURES_CASE",
		"hidden": [preload("res://scenes/props/celebrity_dentures_case.tscn"), preload("res://scenes/props/smile_photo.tscn"),
			preload("res://scenes/props/half_mold.tscn")],
		"half_heights": [0.175, 0.16, 0.045],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_SMILE_PHOTO", "OBJ_EXTRA_HALF_MOLD"],
		"rig": preload("res://scripts/case/dentist/famous_dentures_rig.gd"),
	},
	"rising_chair": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_RISING_CHAIR_B", "BRIEF_RISING_CHAIR_C", "BRIEF_RISING_CHAIR_D"],
		"find": "OBJ_FIND_LOOT_BAG",
		"main_hidden": false,
		"hidden": [preload("res://scenes/props/hatch_key.tscn"), preload("res://scenes/props/ceiling_plan.tscn")],
		"half_heights": [0.006, 0.003],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_HATCH_KEY", "OBJ_EXTRA_CEILING_PLAN"],
		"rig": preload("res://scripts/case/dentist/rising_chair_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the floor of the waiting room, the corridor and the rooms, away from the furniture.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-4.0, FLOOR_TOP, 4.2), Vector3(1.5, FLOOR_TOP, 5.5), Vector3(-6.0, FLOOR_TOP, 2.0),
	Vector3(5.0, FLOOR_TOP, 2.2), Vector3(-1.5, FLOOR_TOP, -2.0), Vector3(7.0, FLOOR_TOP, -2.6),
]
const HALF_X := 11.0
const HALF_Z := 8.0
const WALL_TOP := 3.2
const BUILDING_TOP := 4.0
const FLOOR_TOP := 0.06
const ENTRANCE_WIDTH := 2.0
const OPENING_WIDTH := 1.4
## The waiting room's back wall, and the corridor behind it up to the rooms' wall.
const WAITING_Z := 3.0
const ROOMS_Z := 1.0
## The rooms across the back, west to east: consulting room 1, consulting room 2, the lab and the office (with the
## storeroom behind it, from STOREROOM_Z back).
const ROOM_WALLS: Array[float] = [-5.5, 0.0, 5.5]
const ROOM_DOORS: Array[float] = [-8.25, -2.75, 2.75, 8.25]
const STOREROOM_Z := -3.5
const STOREROOM_DOOR_X := 8.25
const CHAIRS: Array[Vector3] = [Vector3(-8.25, FLOOR_TOP, -3.5), Vector3(-2.75, FLOOR_TOP, -3.5)]
const GAS_TANKS: Array[Vector3] = [Vector3(-10.4, FLOOR_TOP, -6.0), Vector3(-0.6, FLOOR_TOP, -6.0)]
const ROOM_CUPBOARDS: Array[Vector3] = [Vector3(-6.3, FLOOR_TOP, -7.4), Vector3(-1.0, FLOOR_TOP, -7.4)]
const CUPBOARD_SIZE := Vector3(1.4, 0.9, 0.6)
const CABINET_AT := Vector3(4.0, FLOOR_TOP, -7.7)
const LAB_TABLE_AT := Vector3(2.75, FLOOR_TOP, -3.0)
const LAB_TABLE_SIZE := Vector3(2.4, 0.9, 1.0)
const KILN_AT := Vector3(5.0, FLOOR_TOP, -3.0)
const KILN_SIZE := Vector3(0.7, 1.0, 0.7)
const XRAY_AT := Vector3(0.2, FLOOR_TOP + 1.3, -5.0)
const DESK_AT := Vector3(8.25, FLOOR_TOP, -1.3)
const DESK_SIZE := Vector3(2.2, 0.75, 0.9)
const SHELF_X := 10.6
const RECEPTION_AT := Vector3(-7.0, FLOOR_TOP, 5.0)
const RECEPTION_SIZE := Vector3(3.0, 1.0, 0.8)
const TANK_AT := Vector3(9.4, FLOOR_TOP, 5.5)
const SEATS: Array[Vector3] = [Vector3(-1.5, FLOOR_TOP, 7.3), Vector3(0.0, FLOOR_TOP, 7.3), Vector3(1.5, FLOOR_TOP, 7.3),
	Vector3(4.0, FLOOR_TOP, 4.0), Vector3(5.5, FLOOR_TOP, 4.0)]
const RACK_AT := Vector3(3.0, FLOOR_TOP, 7.4)
## The molds on the lab's table that break (the cabinet's are only for the look).
const MOLDS := 6
## Something hitting the fish tank faster than this breaks it: a fine, and the wet floor around it.
const TANK_SPEED := 4.0
const TANK_FINE := 20
const WET := Rect2(6.0, 3.2, 4.8, 4.6)
## Running faster than walking on the wet floor slips: down for WET_SLIP seconds, and not again for WET_AGAIN.
const WET_SLIP := 2.0
const WET_PUSH := 3.0
const WET_AGAIN := 3.0

## Dr. Molina's round, back and forth along the corridor, looking into every room through its door.
const MOLINA_ROUTE: Array[Vector3] = [Vector3(-8.25, FLOOR_TOP, 2.0), Vector3(-2.75, FLOOR_TOP, 2.0),
	Vector3(2.75, FLOOR_TOP, 2.0), Vector3(8.25, FLOOR_TOP, 2.0)]
## Where he "sees" the next patient: beside chair 1, facing it, his back to the room's door.
const PATIENT_SPOT := Vector3(-7.7, FLOOR_TOP, -2.3)
## Seeing a mold break, and a cop up on one of his chairs.
const SAW_MOLD := 2.0
const SAW_IN_CHAIR := 10.0
## Seeing Lucho get a candy (he has them forbidden).
const SAW_CANDY := 5.0
## The candies in the reception's jar, and where Lucho waits (by the seats, facing the reception).
const CANDIES := 4
const JAR_AT := RECEPTION_AT + Vector3(-0.8, RECEPTION_SIZE.y, 0.1)
const LUCHO_AT := Vector3(-3.0, FLOOR_TOP, 6.6)
## Up on a chair: over its seat (from its middle, across and back to front) and higher than this.
const SEAT := Vector2(0.5, 1.0)
const SEAT_HEIGHT := 0.5

const OUTSIDE := Color(0.92, 0.95, 0.97)
const MINT := Color(0.55, 0.82, 0.74)
const TILE := Color(0.9, 0.92, 0.93)
const FLOOR := Color(0.78, 0.86, 0.88)
const WOOD := Color(0.62, 0.48, 0.34)
const STEEL := Color(0.74, 0.77, 0.8)
const GLASS := Color(0.6, 0.8, 0.9, 0.35)
const WATER := Color(0.45, 0.65, 0.85, 0.5)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "dentist_under_chair_1", "at": CHAIRS[0] + Vector3(0.0, 0.0, 0.75), "heavy": true},
	{"id": "dentist_under_chair_2", "at": CHAIRS[1] + Vector3(0.0, 0.0, 0.75), "heavy": true},
	{"id": "dentist_behind_fish_tank", "at": TANK_AT + Vector3(-0.2, 0.0, -0.75), "heavy": true},
	{"id": "dentist_under_reception", "at": RECEPTION_AT + Vector3(0.0, 0.0, -0.9), "heavy": true},
	{"id": "dentist_in_storeroom", "at": Vector3(9.0, FLOOR_TOP, -6.5), "heavy": true},
	{"id": "dentist_under_lab_table", "at": LAB_TABLE_AT, "heavy": true},
	{"id": "dentist_in_cupboard_1", "at": ROOM_CUPBOARDS[0] + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "dentist_in_cupboard_2", "at": ROOM_CUPBOARDS[1] + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "dentist_in_kiln", "at": KILN_AT + Vector3(0.0, 0.05, 0.0), "heavy": false},
	{"id": "dentist_in_magazine_rack", "at": RACK_AT + Vector3(0.0, 0.3, 0.0), "heavy": false},
	{"id": "dentist_on_office_desk", "at": DESK_AT + Vector3(0.6, DESK_SIZE.y, 0.0), "heavy": false},
	{"id": "dentist_on_office_shelf", "at": Vector3(SHELF_X, FLOOR_TOP + 1.2, -1.2), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var storeroom_door: FrontDoor
var molds: Array[Ornament] = []
var fish_tank: Node3D
var tank_broken := false
var broken_goods := 0
## The chairs' looks and bodies (the rising chair story lifts chair 2).
var chair_looks: Array[Node3D] = []
var chair_bodies: Array[StaticBody3D] = []
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the fish tank.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## Same seed, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: DentistRaidRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## The X-ray light box on the lab's wall (the gold teeth story changes its film).
var xray: Node3D
var molina: FloorBoss
var bell: NextPatientBell
var complaint_bar: ProgressBar
var lucho: DentistKid
var candies: Array[Grabbable] = []
var gas_tanks: Array[LaughingGasTank] = []
## Cops Dr. Molina already saw up on a chair (until they get down).
var _seen_in_chair := {}
var _build: PlaceBuilder
## Cop -> seconds until it can slip on the wet floor again.
var _slipped := {}
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
	_build_shell()
	_build_waiting_room()
	_build_rooms()
	_build_lab()
	_build_office()
	_place_molds()
	storeroom_door = _door(Vector3(STOREROOM_DOOR_X, FLOOR_TOP, STOREROOM_Z))
	_place_molina()
	_place_lucho()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("dentist")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "dentist", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = molina
	raid.owner_id = "dentist"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The office's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_DENTIST",
		"guess_key": "OBJ_GUESS_DENTIST",
		"broken_key": "OBJ_BROKEN_DENTIST",
		"complaint_key": "OBJ_COMPLAINT_DENTIST",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": molina.complaint,
	}


## Online, what the guests' office takes from the host's (RaidCase.snapshot): the fish tank and what the story's rig
## decides on the host.
func net_state() -> Dictionary:
	return {"tank": tank_broken, "rig": rig.net_state() if rig else null}


func apply_net_state(state: Dictionary) -> void:
	if state.tank:
		break_fish_tank()
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
	if story.get("main_hidden", true):
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


## What the doctor lets slip when asked (where the story's things are, in an order drawn from the seed), and what Lucho
## saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		molina.slips.append(tr("MOLINA_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	molina.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	lucho.clue = tr("CLUE_LUCHO") % where
	lucho.clue_speech = tr("LUCHO_CLUE_" + story_id) % where
	lucho.told.connect(raid.add_clue)


## Whether `at` (this scene's space) is on the wet floor of the broken fish tank.
func on_wet_floor(at: Vector3) -> bool:
	return tank_broken and WET.has_point(Vector2(at.x, at.z)) and at.y < FLOOR_TOP + 0.5


func _physics_process(delta: float) -> void:
	for cop: Variant in _slipped.keys():
		_slipped[cop] -= delta
		if _slipped[cop] <= 0.0 or not is_instance_valid(cop):
			_slipped.erase(cop)
	# Online the host's doctor minds his chairs; the guests' one only follows.
	if molina and multiplayer.is_server():
		_watch_chairs()
	if not tank_broken:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.sync and not cop.sync.is_multiplayer_authority():
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if _slipped.has(cop) or not cop.is_running or flat.length() <= GameScale.WALK_SPEED \
				or not on_wet_floor(to_local(cop.global_position)):
			continue
		_slipped[cop] = WET_AGAIN
		cop.get_node("Grabber").release()
		cop.knock_back(flat.normalized() * WET_PUSH, WET_SLIP)
		cop.show_hint("HINT_WET_FLOOR")


## Shatters the fish tank, once: a fine, the glass and the water gone, and a wet floor around it.
func break_fish_tank() -> void:
	if tank_broken:
		return
	tank_broken = true
	broken_goods += 1
	fines += TANK_FINE
	if molina:
		molina.saw(fish_tank.global_position + Vector3.UP * 0.6, FloorBoss.SAW_BREAK, "MOLINA_TANK")
	fish_tank.queue_free()
	_build.mesh_box(Vector3(WET.get_center().x, FLOOR_TOP + 0.006, WET.get_center().y), Vector3(WET.size.x, 0.004,
		WET.size.y), WATER)


## Light walls, the shop window with the entrance, the ceiling, the roof and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, TILE)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 0.0, 1.0, MINT)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 0.0, 1.0, MINT)
	_wall_box("x", HALF_Z, -HALF_X, -ENTRANCE_WIDTH / 2, 1.0, 2.6, GLASS)
	_wall_box("x", HALF_Z, ENTRANCE_WIDTH / 2, HALF_X, 1.0, 2.6, GLASS)
	_wall_box("x", HALF_Z, -HALF_X, HALF_X, 2.6, WALL_TOP, OUTSIDE)
	_wall("x", -HALF_Z, -HALF_X, HALF_X, [], OUTSIDE)
	_wall("z", -HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	_wall("z", HALF_X, -HALF_Z, HALF_Z, [], OUTSIDE)
	var roof := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + roof / 2, 0), Vector3(HALF_X * 2, roof, HALF_Z * 2), OUTSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_DENTIST"
	sign_label.font_size = 96
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 18
	sign_label.modulate = MINT.darkened(0.3)
	sign_label.position = Vector3(0, WALL_TOP + 0.4, HALF_Z + 0.08)
	$Built.add_child(sign_label)


## The waiting room: the reception desk with the candy jar and the bell, the fish tank, the seats and the magazines.
func _build_waiting_room() -> void:
	var doors: Array = [-6.0, 0.0, 6.0].map(func(x: float) -> Vector3: return Vector3(x, OPENING_WIDTH * 1.5, 2.4))
	_wall("x", WAITING_Z, -HALF_X, HALF_X, doors, TILE)
	_build.open_box(RECEPTION_AT, RECEPTION_SIZE, "-z", WOOD)
	_model(JAR_MODEL, JAR_AT)
	bell = NextPatientBell.new()
	bell.position = RECEPTION_AT + Vector3(0.9, RECEPTION_SIZE.y, 0.15)
	add_child(bell)
	fish_tank = _model(TANK_MODEL, TANK_AT, -PI / 2)
	var tank_body := StaticBody3D.new()
	tank_body.position = Vector3(0, 0.65, 0)
	fish_tank.add_child(tank_body)
	_build.shape(tank_body, Vector3(1.0, 1.3, 0.45))
	var area := Area3D.new()
	area.position = Vector3(0, 0.65, 0)
	area.collision_layer = 0
	area.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.3, 1.5, 0.75)
	shape.shape = box
	area.add_child(shape)
	fish_tank.add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if multiplayer.is_server() and body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > TANK_SPEED:
			break_fish_tank())
	for at: Vector3 in SEATS:
		_build.box(at + Vector3(0, 0.23, 0), Vector3(0.5, 0.46, 0.5), MINT.darkened(0.15))
		_build.mesh_box(at + Vector3(0, 0.7, -0.22 if at.z > 6.0 else 0.22), Vector3(0.5, 0.5, 0.06), MINT.darkened(0.15))
	_build.open_box(RACK_AT, Vector3(0.8, 0.6, 0.35), "y", WOOD)
	_build.light(Vector3(-5.0, 2.9, 5.5))
	_build.light(Vector3(5.0, 2.9, 5.5))


## The two consulting rooms, each with its chair, its gas tank and its cupboard, opening to the corridor.
func _build_rooms() -> void:
	var doors: Array = ROOM_DOORS.map(func(x: float) -> Vector3: return Vector3(x, OPENING_WIDTH, 2.4))
	_wall("x", ROOMS_Z, -HALF_X, HALF_X, doors, TILE)
	for x: float in ROOM_WALLS:
		_wall("z", x, -HALF_Z, ROOMS_Z, [], TILE)
	for i in CHAIRS.size():
		chair_looks.append(_model(CHAIR_MODEL, CHAIRS[i]))
		var chair := _build.body(CHAIRS[i] + Vector3(0, 0.45, -0.3))
		_build.shape(chair, Vector3(0.7, 0.9, 1.3))
		chair_bodies.append(chair)
		var tank := LaughingGasTank.new()
		tank.name = "GasTank%d" % (i + 1)
		tank.position = GAS_TANKS[i]
		add_child(tank)
		gas_tanks.append(tank)
		_build.open_box(ROOM_CUPBOARDS[i], CUPBOARD_SIZE, "z", TILE.darkened(0.05))
		_build.light(CHAIRS[i] + Vector3(0, 2.8, 0))
	_build.light(Vector3(0, 2.9, 2.0))


## The lab: the cabinet of molds against the back wall, the work table, the kiln and the X-ray light box.
func _build_lab() -> void:
	_model(CABINET_MODEL, CABINET_AT)
	var cabinet := _build.body(CABINET_AT + Vector3(0, 0.8, 0))
	_build.shape(cabinet, Vector3(1.2, 1.6, 0.4))
	_table(LAB_TABLE_AT, LAB_TABLE_SIZE, STEEL.darkened(0.2), STEEL)
	_build.open_box(KILN_AT, KILN_SIZE, "z", STEEL.darkened(0.3))
	xray = _model(XRAY_MODEL, XRAY_AT, PI / 2)
	_build.light(Vector3(2.75, 2.9, -4.0))


## Dr. Molina's office (desk and shelf) and the locked storeroom behind it.
func _build_office() -> void:
	_wall("x", STOREROOM_Z, ROOM_WALLS[2], HALF_X, [Vector3(STOREROOM_DOOR_X, GameScale.DOOR_WIDTH, 2.4)], TILE)
	_table(DESK_AT, DESK_SIZE, WOOD.darkened(0.2), WOOD)
	_build.open_box(Vector3(SHELF_X, FLOOR_TOP, -1.2), Vector3(0.6, 1.9, 1.6), "-x", WOOD)
	_build.light(Vector3(8.25, 2.9, -1.0))
	_build.light(Vector3(8.25, 2.9, -6.0))


## The molds on the lab's table: each one that breaks counts (Dr. Molina minds it, step 3).
func _place_molds() -> void:
	for i in MOLDS:
		var mold := Ornament.new()
		mold.mass = 0.3
		mold.collision_layer = 4
		mold.collision_mask = 15
		mold.shard_color = Color(0.94, 0.9, 0.84)
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(0.14, 0.07, 0.1)
		shape.shape = box
		mold.add_child(shape)
		var look: Node3D = MOLD_MODEL.instantiate()
		look.position.y = -0.035
		mold.add_child(look)
		mold.position = LAB_TABLE_AT + Vector3(-0.9 + i * 0.36, LAB_TABLE_SIZE.y + 0.045, 0.2)
		add_child(mold)
		molds.append(mold)
		mold.broken.connect(func(at: Vector3) -> void:
			molds.erase(mold)
			broken_goods += 1
			if molina:
				molina.saw(at, SAW_MOLD, "MOLINA_MOLD"))


## Dr. Molina on his round, his patient at the bell, what he notices and the complaint bar.
func _place_molina() -> void:
	molina = MOLINA_SCENE.instantiate()
	molina.route = MOLINA_ROUTE
	molina.printer_spot = PATIENT_SPOT
	molina.printer = bell
	add_child(molina)
	molina.fix_facing = to_global(CHAIRS[0])
	molina.start_at(0)
	storeroom_door.broken.connect(molina.door_broken)
	molina.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_DENTIST"))
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
	molina.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Lucho by the seats, and the candies in the jar he'd talk for (the doctor minds seeing him get one).
func _place_lucho() -> void:
	for i in CANDIES:
		var candy := ClubEvidence.make_item("Candy%d" % (i + 1), CANDY_MODEL, Vector3(0.05, 0.14, 0.05), 0.02)
		candy.add_to_group(DentistKid.CANDY_GROUP)
		(candy.get_child(1) as Node3D).position.y = -0.07
		candy.position = JAR_AT + Vector3(-0.04 + (i % 2) * 0.08, 0.075, -0.03 + (i / 2) * 0.06)
		add_child(candy)
		candies.append(candy)
	lucho = DentistKid.new()
	lucho.name = "Lucho"
	lucho.position = LUCHO_AT
	lucho.rotation.y = PI
	add_child(lucho)
	lucho.ate_candy.connect(func(at: Vector3) -> void: molina.saw(at, SAW_CANDY, "MOLINA_CANDY"))


## Which chair `at` (this scene's space) is up on, or -1.
func chair_under(at: Vector3) -> int:
	for i in CHAIRS.size():
		var from := at - CHAIRS[i]
		if absf(from.x) < SEAT.x and from.z > -SEAT.y and from.z < SEAT.y * 0.4 and from.y > SEAT_HEIGHT:
			return i
	return -1


## Every cop up on a chair that the doctor sees, once until they get down.
func _watch_chairs() -> void:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if chair_under(to_local(cop.global_position)) < 0:
			_seen_in_chair.erase(cop)
		elif not _seen_in_chair.has(cop) and molina.saw(cop.global_position + Vector3.UP * 0.8, SAW_IN_CHAIR,
				"MOLINA_CHAIR"):
			_seen_in_chair[cop] = true


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
