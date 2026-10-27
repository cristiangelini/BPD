class_name FarmRaid
extends Node3D

## The farm "Las Margaritas" as a place to raid (docs/diseno/allanamiento-granja.md, step 2): an open-air farm that
## fills the city's farm block (a park, so the city leaves it grass). A wooden fence of FENCE_HALF with its gate to the
## street (+Z), and inside Don Florencio's house with its porch and the feeding bell, the barn with its hay bales and
## loft, the tractor beside it, the hen house, the pigsty with its mud, the cow's corral with her feeder, the locked
## tool shed, the vegetable garden with the scarecrow and a little glass greenhouse, the well and the market stall
## with its baskets of eggs by the gate. A cop running in the mud slips, like on the jail's wet floor. SPOTS are the 12
## hiding spots the stories draw from (step 5). Don Florencio walks his round and fills the complaint (step 3); E on the
## bell's cord is feeding time: he goes to the corral and feeds the animals with his back to the farm, and a cop behind
## him can take the shed's key from his apron. Eight hens peck around the yard (step 4): a cop who runs close scares
## them, and Don Florencio counts every scared animal he sees; Pancho, by the hen house, talks once three of them are
## back in its run. Tota the goat eats the paper she finds on the ground and gives it back chewed in the corral 30 s
## later, and three pigs wallow in the mud shoving whoever comes in. Margarita the cow walks out of her corral if its
## gate stays open, and follows a cop carrying a hay bale back in; Don Florencio is not happy to see her out. The case
## is one of its stories (STORIES), drawn with the seed and run by the same RaidCase as the other places (step 5): Don
## Florencio lets slip where things are when asked, and Pancho tells where he saw his uncle hide one of them.
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const COOP_MODEL := preload("res://assets/models/chicken_coop.glb")
const WELL_MODEL := preload("res://assets/models/farm_well.glb")
const OWNER_SCENE := preload("res://scenes/npc/farm_owner.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the farm can be suspected of (allanamiento-granja.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["golden_eggs", "many_owners_cow", "racing_tractor", "giant_carrots", "piggy_bank",
	"living_scarecrow"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_FARM_TIP_B", "BRIEF_TIP_C", "BRIEF_FARM_TIP_D",
	"BRIEF_FARM_TIP_E"]
## The stories the farm can tell, like GymRaid.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (the first one is the main evidence), their half heights and whether
## they're heavy, the checklist rows of its extras and its rig. The other stories come one per PR (step 6).
const STORIES := {
	"golden_eggs": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_GOLDEN_EGGS_B", "BRIEF_GOLDEN_EGGS_C", "BRIEF_GOLDEN_EGGS_D"],
		"find": "OBJ_FIND_GOLDEN_EGGS",
		"hidden": [preload("res://scenes/props/golden_egg_box.tscn"), preload("res://scenes/props/gold_paint_can.tscn"),
			preload("res://scenes/props/magic_hen_flyer.tscn")],
		"half_heights": [0.13, 0.12, 0.003],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_GOLD_PAINT", "OBJ_EXTRA_MAGIC_HEN_FLYER"],
		"rig": preload("res://scripts/case/farm/golden_eggs_rig.gd"),
	},
	"many_owners_cow": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_COW_OWNERS_B", "BRIEF_COW_OWNERS_C", "BRIEF_COW_OWNERS_D"],
		"find": "OBJ_FIND_COW_RECEIPTS",
		"hidden": [preload("res://scenes/props/cow_receipts.tscn"), preload("res://scenes/props/cowbell_names.tscn"),
			preload("res://scenes/props/spot_brush.tscn")],
		"half_heights": [0.03, 0.12, 0.145],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_COWBELL_NAMES", "OBJ_EXTRA_SPOT_BRUSH"],
		"rig": preload("res://scripts/case/farm/cow_owners_rig.gd"),
	},
	"racing_tractor": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_RACING_TRACTOR_B", "BRIEF_RACING_TRACTOR_C", "BRIEF_RACING_TRACTOR_D"],
		"find": "OBJ_FIND_RACING_ENGINE",
		"hidden": [preload("res://scenes/props/racing_engine.tscn"), preload("res://scenes/props/tractor_trophy.tscn"),
			preload("res://scenes/props/flame_helmet.tscn")],
		"half_heights": [0.295, 0.24, 0.095],
		"heavy": [true, false, false],
		## The engine only hides in the barn (it's too tall for the other heavy spots).
		"main_spots": ["between_bales", "in_loft"],
		"extra_keys": ["OBJ_EXTRA_RACE_TROPHY", "OBJ_EXTRA_FLAME_HELMET"],
		"rig": preload("res://scripts/case/farm/racing_tractor_rig.gd"),
	},
	"giant_carrots": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_GIANT_CARROTS_B", "BRIEF_GIANT_CARROTS_C", "BRIEF_GIANT_CARROTS_D"],
		"find": "OBJ_FIND_FERTILIZER_JUGS",
		"hidden": [preload("res://scenes/props/fertilizer_jugs.tscn"), preload("res://scenes/props/growth_diary.tscn"),
			preload("res://scenes/props/ruler_2m.tscn")],
		"half_heights": [0.195, 0.015, 0.015],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_GROWTH_DIARY", "OBJ_EXTRA_RULER_2M"],
		"rig": preload("res://scripts/case/farm/giant_carrots_rig.gd"),
	},
}
## Where the suspicion notes lie: on the yard's dirt, out of the buildings and the pens (Tota may eat them).
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-4.0, 0.04, 1.0), Vector3(2.5, 0.04, 6.0), Vector3(-2.0, 0.04, 11.0), Vector3(4.0, 0.04, 14.5),
	Vector3(-8.0, 0.04, 15.0), Vector3(1.0, 0.04, -3.0),
]
const BALE_MODEL := preload("res://assets/models/hay_bale.glb")
const TRACTOR_MODEL := preload("res://assets/models/farm_tractor.glb")
const SCARECROW_MODEL := preload("res://assets/models/scarecrow.glb")
const BASKET_MODEL := preload("res://assets/models/egg_basket.glb")
## The ground of the block, as the city leaves it (CityLayout: the grass on its sidewalk ring).
const GROUND := 0.035
## The fence: 40 x 30 m, its gate in the middle of the front (+Z) side.
const FENCE_HALF := Vector2(20, 15)
const FENCE_Z := 3.0
const FENCE_HEIGHT := 1.1
const GATE_WIDTH := 3.0
## Don Florencio's house: the kitchen (east) and his room (west), with a porch in front where the bell hangs.
const HOUSE := Rect2(-19, -11, 8, 7)
const HOUSE_HEIGHT := 3.0
const HOUSE_DOOR_X := -13.0
const ROOM_WALL_X := -15.5
const PORCH_DEPTH := 2.0
const BELL_AT := Vector3(-11.2, 1.4, -2.05)
## The barn, open to the yard, with its loft (LOFT_TOP up, over the back half) and the ladder to it.
const BARN := Rect2(6, -11, 12, 10)
const BARN_HEIGHT := 6.0
const BARN_DOOR := 4.0
const LOFT_TOP := 3.0
const LOFT_FRONT := -6.0
const TRACTOR_AT := Vector3(2.8, 0, -4.0)
## The locked tool shed behind the house's east side (the key is in Don Florencio's apron, step 3).
const SHED := Rect2(-9, -11.5, 4, 3)
const COOP_AT := Vector3(-1.5, 0, -9.0)
## The pigsty: a low fence round the mud.
const STY := Rect2(8, 3, 9, 7)
const STY_FENCE := 0.8
## The cow's corral, its gate on the east side (the cow and the gate come in step 4), and her feeder.
const CORRAL := Rect2(-19, 3, 10, 9)
const CORRAL_GATE_Z := 7.5
const FEEDER_AT := Vector3(-17.4, 0, 5.0)
const FEEDER_SIZE := Vector3(2.0, 0.6, 0.7)
## The vegetable garden in front of the pigsty, the scarecrow in its middle and the little greenhouse in its corner.
const GARDEN := Rect2(7, 11.5, 12, 6)
const SCARECROW_AT := Vector3(12.5, 0, 14.5)
const GREENHOUSE := Rect2(16.6, 14.6, 2.0, 2.4)
const GREENHOUSE_HEIGHT := 2.0
const WELL_AT := Vector3(0, 0, 3.5)
## The market stall by the gate, with the baskets of eggs on it, and the milk cans by the barn.
const STALL_AT := Vector3(-5.5, 0, 15.5)
const STALL_SIZE := Vector3(3.0, 0.85, 1.0)
const BASKETS: Array[Vector3] = [Vector3(-6.6, 0, 15.5), Vector3(-5.5, 0, 15.5), Vector3(-4.4, 0, 15.5)]
const MILK_CANS_AT := Vector3(5.0, 0, -4.5)
## Bales stacked along the barn's west wall, and two in the loft.
const BALES: Array[Vector3] = [
	Vector3(7.0, 0.25, -3.0), Vector3(7.0, 0.25, -4.1), Vector3(7.0, 0.75, -3.5), Vector3(8.2, 0.25, -3.0),
	Vector3(7.0, LOFT_TOP + 0.25, -9.5), Vector3(8.2, LOFT_TOP + 0.25, -9.5),
]
## Don Florencio's round, back and forth: by the corral, the porch, the hen house, the barn's door, between the pigsty
## and the barn, along the garden and to the egg stall. At feeding time he stands by the corral's gate, facing the
## feeder.
const OWNER_ROUTE: Array[Vector3] = [
	Vector3(-7.0, GROUND, 3.0), Vector3(-13.0, GROUND, -0.5), Vector3(-9.5, GROUND, -0.8), Vector3(-1.5, GROUND, -6.3),
	Vector3(0.5, GROUND, -1.5), Vector3(12.0, GROUND, 1.2), Vector3(6.2, GROUND, 1.5), Vector3(6.2, GROUND, 10.8),
	Vector3(-5.5, GROUND, 13.6),
]
const FEED_SPOT := Vector3(-7.6, GROUND, 7.5)
## The hens: how many, where they peck, and the run in front of the hen house where Pancho wants them back.
const HENS := 8
const YARD := Rect2(-6, -3, 7.5, 11)
const COOP_RUN := Rect2(-3, -8.5, 3, 1.6)
const PANCHO_AT := Vector3(1.2, GROUND, -7.6)
## Where Tota gives back what she ate: in the corral, by the feeder.
const GOAT_GIVES_BACK := Vector3(-15.0, GROUND + 0.1, 9.0)
const PIGS := 3
## The two loose hay bales in the barn, to lead the cow with.
const LOOSE_BALES: Array[Vector3] = [Vector3(10.5, 0.26, -2.2), Vector3(13.5, 0.26, -2.2)]
const BALE_KG := 8.0
const COW_AT := Vector3(-14.0, GROUND, 7.5)
const SAW_COW := 10.0
## Don Florencio sees an animal running scared.
const SAW_SCARED := 5.0
## The eggs in each basket on the stall, and the greenhouse's glass: something hitting it faster than GLASS_SPEED
## breaks it, a fine.
const EGGS_PER_BASKET := 3
const GLASS_SPEED := 3.0
const GLASS_FINE := 20
## Running faster than this in the mud slips: down for MUD_SLIP seconds, and not again for MUD_AGAIN.
const MUD := Rect2(9, 4, 7, 5)
const MUD_SLIP := 2.0
const MUD_PUSH := 3.0
const MUD_AGAIN := 3.0

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "between_bales", "at": Vector3(8.2, GROUND, -4.2), "heavy": true},
	{"id": "in_loft", "at": Vector3(12.0, GROUND + LOFT_TOP, -9.0), "heavy": true},
	{"id": "under_tractor", "at": TRACTOR_AT + Vector3(0, GROUND, -0.2), "heavy": true},
	{"id": "in_mud", "at": Vector3(14.5, GROUND, 7.5), "heavy": true},
	{"id": "in_shed", "at": Vector3(-7.0, GROUND, -10.6), "heavy": true},
	{"id": "in_feeder", "at": FEEDER_AT + Vector3(0, 0.12, 0), "heavy": true},
	{"id": "in_coop", "at": Vector3(-0.4, GROUND, -8.2), "heavy": false},
	{"id": "in_scarecrow", "at": SCARECROW_AT + Vector3(0.35, GROUND, 0.3), "heavy": false},
	{"id": "on_well", "at": WELL_AT + Vector3(0.45, 0.8, 0), "heavy": false},
	{"id": "by_milk_cans", "at": MILK_CANS_AT + Vector3(0, GROUND, 0.6), "heavy": false},
	{"id": "in_kitchen", "at": Vector3(-12.2, GROUND + 0.79, -9.8), "heavy": false},
	{"id": "under_stall", "at": STALL_AT + Vector3(0, GROUND, 0), "heavy": false},
]
const WOOD := Color(0.55, 0.38, 0.22)
const WHITE_WALL := Color(0.95, 0.92, 0.84)
const BARN_RED := Color(0.72, 0.18, 0.14)
const ROOF := Color(0.4, 0.22, 0.16)
const DIRT := Color(0.6, 0.48, 0.32)
const MUD_COLOR := Color(0.32, 0.22, 0.12)
const SOIL := Color(0.4, 0.28, 0.16)
const STRAW := Color(0.85, 0.74, 0.42)
const GLASS := Color(0.75, 0.9, 1.0, 0.35)
const MILK_CAN := Color(0.78, 0.8, 0.82)

## Same seed, same hens and the same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The case flow every raid shares.
var raid: RaidCase
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: FarmRaidRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## Money taken off the case pay for what breaks.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
var broken_goods := 0
var owner_npc: FarmOwner
var hens: Array[FarmHen] = []
var pancho: FarmNephew
var goat: FarmGoat
var pigs: Array[FarmPig] = []
var cow: FarmCow
var corral_gate: FarmGate
## The tractor beside the barn: its body and its look (they move together when it starts in the racing story).
var tractor: FarmTractor
var tractor_model: Node3D
var loose_bales: Array[Grabbable] = []
## Don Florencio already saw the cow out this time.
var _cow_seen := false
var bell: FeedBell
var complaint_bar: ProgressBar
var house_door: FrontDoor
var shed_door: FrontDoor
var city_map: CityMap
var station_parking: Transform3D
## The baskets of eggs on the stall and the greenhouse's glass, what breaks (steps 3 and 5 count it).
var baskets: Array[Node3D] = []
var greenhouse: Node3D
var greenhouse_broken := false
var eggs: Array[FarmEgg] = []
var _build: PlaceBuilder
## Cop -> seconds until it can slip in the mud again.
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
	_build_yard()
	_build_house()
	_build_barn()
	_build_pens()
	_build_garden()
	_place_owner()
	_place_hens()
	_place_goat_and_pigs()
	_place_cow()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("farm")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "farm", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = owner_npc
	raid.owner_id = "farm"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The farm's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_FARM",
		"guess_key": "OBJ_GUESS_FARM",
		"broken_key": "OBJ_BROKEN_FARM",
		"complaint_key": "OBJ_COMPLAINT_FARM",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": owner_npc.complaint,
	}


## Online, what the guests' farm takes from the host's (RaidCase.snapshot): what the story's rig decides on the host.
func net_state() -> Dictionary:
	return {"rig": rig.net_state() if rig else null}


func apply_net_state(state: Dictionary) -> void:
	if rig and state.rig != null:
		rig.apply_net_state(state.rig)


## The story with that id from --story=<id> among the user args, or one drawn from the seed.
static func pick_story(seed_value: int, args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with("--story=") and STORIES.has(arg.trim_prefix("--story=")):
			return arg.trim_prefix("--story=")
	return STORIES.keys()[seed_value % STORIES.size()]


## The story's hidden items, each in a spot drawn with the seed (heavy ones only where they fit); the first one is the
## main evidence.
func _place_hidden() -> void:
	var story: Dictionary = STORIES[story_id]
	var spot_heavy: Array = SPOTS.map(func(spot: Dictionary) -> bool: return spot.heavy)
	if story.has("main_spots"):
		spot_heavy = SPOTS.map(func(spot: Dictionary) -> bool: return story.main_spots.has(spot.id))
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
		note.position = NOTE_PLACES[place] + Vector3.UP * GROUND
		note.rotation.y = place * 0.9
		note.read.connect(raid.add_clue)
		add_child(note)


## What Don Florencio lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Pancho saw: where his uncle hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		owner_npc.slips.append(tr("FARMER_SLIP") % tr("LOC_FARM_" + SPOTS[hidden_spots[item]].id))
	owner_npc.slipped.connect(raid.add_clue)
	var where := tr("LOC_FARM_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	pancho.clue = tr("CLUE_PANCHO") % where
	pancho.clue_speech = tr("PANCHO_CLUE_" + story_id) % where
	pancho.told.connect(raid.add_clue)


## Don Florencio on his round, the bell that calls him to feed the animals, what breaks his doors and the complaint bar.
func _place_owner() -> void:
	owner_npc = OWNER_SCENE.instantiate()
	owner_npc.route = OWNER_ROUTE
	owner_npc.printer_spot = FEED_SPOT
	owner_npc.printer = bell
	add_child(owner_npc)
	owner_npc.fix_facing = to_global(FEEDER_AT)
	owner_npc.start_at(1)
	for door: FrontDoor in [house_door, shed_door]:
		door.broken.connect(owner_npc.door_broken)
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
	owner_npc.lawyer_called.connect(func() -> void: raid.fail("CASE_FAILED_LAWYER_FARM"))


## The hens on spots of the yard drawn with the seed, the run's low fence and Pancho by the hen house.
func _place_hens() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["farm hens", case_seed])
	for i in HENS:
		var hen := FarmHen.new()
		hen.name = "Hen%d" % i
		hen.farm = self
		hen.yard = YARD
		hen.run = COOP_RUN
		hen.rng.seed = rng.randi()
		hen.position = Vector3(rng.randf_range(YARD.position.x, YARD.end.x), GROUND + 0.05,
			rng.randf_range(YARD.position.y, YARD.end.y))
		add_child(hen)
		hen.scared.connect(func(at: Vector3) -> void: owner_npc.saw(at + Vector3.UP * 0.3, SAW_SCARED, "FARMER_SCARED"))
		hens.append(hen)
	var r := COOP_RUN
	for z: float in [r.position.y, r.end.y]:
		_build.mesh_box(Vector3(r.get_center().x, GROUND + 0.25, z), Vector3(r.size.x, 0.5, 0.03), WOOD)
	for x: float in [r.position.x, r.end.x]:
		_build.mesh_box(Vector3(x, GROUND + 0.25, r.get_center().y), Vector3(0.03, 0.5, r.size.y), WOOD)
	pancho = FarmNephew.new()
	pancho.name = "Pancho"
	pancho.position = PANCHO_AT
	pancho.rotation.y = -PI / 2
	add_child(pancho)


## Tota in the yard and the pigs in the mud, on spots drawn with the seed.
func _place_goat_and_pigs() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["farm goat and pigs", case_seed])
	goat = FarmGoat.new()
	goat.name = "Tota"
	goat.farm = self
	goat.yard = YARD
	goat.give_back_at = GOAT_GIVES_BACK
	goat.rng.seed = rng.randi()
	goat.position = Vector3(rng.randf_range(YARD.position.x, YARD.end.x), GROUND + 0.05,
		rng.randf_range(YARD.position.y, YARD.end.y))
	add_child(goat)
	for i in PIGS:
		var pig := FarmPig.new()
		pig.name = "Pig%d" % i
		pig.farm = self
		pig.mud = MUD.grow(-0.5)
		pig.rng.seed = rng.randi()
		pig.position = Vector3(rng.randf_range(MUD.position.x + 0.5, MUD.end.x - 0.5), GROUND,
			rng.randf_range(MUD.position.y + 0.5, MUD.end.y - 0.5))
		add_child(pig)
		pigs.append(pig)


## Margarita in her corral, its gate, and the loose bales in the barn.
func _place_cow() -> void:
	corral_gate = FarmGate.new()
	corral_gate.name = "CorralGate"
	corral_gate.position = Vector3(CORRAL.end.x, GROUND, CORRAL_GATE_Z - FarmGate.WIDTH / 2)
	add_child(corral_gate)
	cow = FarmCow.new()
	cow.name = "Margarita"
	cow.farm = self
	cow.corral = CORRAL
	cow.yard = YARD
	cow.gate = corral_gate
	cow.rng.seed = hash(["farm cow", case_seed])
	cow.position = COW_AT + Vector3.UP * 0.05
	add_child(cow)
	cow.returned.connect(func() -> void: _cow_seen = false)
	cow.petted.connect(func(_cop: Cop) -> void:
		if raid:
			raid.float_label(tr("COW_MOO"), cow.global_position + Vector3.UP * 1.7, Color.WHITE))
	for at: Vector3 in LOOSE_BALES:
		var bale := Grabbable.new()
		bale.mass = BALE_KG
		bale.collision_layer = 4
		bale.collision_mask = 15
		bale.set_meta("hay", true)
		bale.position = at + Vector3.UP * GROUND
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(1.0, 0.5, 0.5)
		shape.shape = box
		bale.add_child(shape)
		var look: Node3D = BALE_MODEL.instantiate()
		look.position.y = -0.25
		bale.add_child(look)
		add_child(bale)
		loose_bales.append(bale)


## Don Florencio sees the cow out of her corral: once each time she's out.
func _watch_cow() -> void:
	if cow and cow.is_out and not _cow_seen \
			and owner_npc.saw(cow.global_position + Vector3.UP * 1.0, SAW_COW, "FARMER_COW"):
		_cow_seen = true


## How many hens are back in the hen house's run.
func cooped_hens() -> int:
	return hens.filter(func(hen: FarmHen) -> bool: return hen.is_cooped()).size()


## Whether it's feeding time: the bell rang and Don Florencio is at the corral.
func in_feeding() -> bool:
	return owner_npc != null and owner_npc.is_fixing()


## Whether `at` (this scene's space) is in the pigsty's mud.
static func in_mud(at: Vector3) -> bool:
	return MUD.has_point(Vector2(at.x, at.z)) and at.y < GROUND + 0.5


func _physics_process(delta: float) -> void:
	if pancho:
		pancho.cooped = cooped_hens()
	_watch_cow()
	for cop: Variant in _slipped.keys():
		_slipped[cop] -= delta
		if _slipped[cop] <= 0.0 or not is_instance_valid(cop):
			_slipped.erase(cop)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.sync and not cop.sync.is_multiplayer_authority():
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if _slipped.has(cop) or not cop.is_running or flat.length() <= GameScale.WALK_SPEED \
				or not in_mud(to_local(cop.global_position)):
			continue
		_slipped[cop] = MUD_AGAIN
		cop.get_node("Grabber").release()
		cop.knock_back(flat.normalized() * MUD_PUSH, MUD_SLIP)
		cop.show_hint("HINT_MUD_SLIP")


## The fence with its gate to the street, the dirt yard, the well and the market stall with its eggs.
func _build_yard() -> void:
	# The dirt is solid up to GROUND, so what lies on it doesn't sink into the grass's look.
	_build.box(Vector3(0, (GROUND + 0.009) / 2, FENCE_Z), Vector3(FENCE_HALF.x * 2, GROUND + 0.009, FENCE_HALF.y * 2), DIRT)
	var front := FENCE_Z + FENCE_HALF.y
	var back := FENCE_Z - FENCE_HALF.y
	_fence("x", front, -FENCE_HALF.x, -GATE_WIDTH / 2, FENCE_HEIGHT)
	_fence("x", front, GATE_WIDTH / 2, FENCE_HALF.x, FENCE_HEIGHT)
	_fence("x", back, -FENCE_HALF.x, FENCE_HALF.x, FENCE_HEIGHT)
	_fence("z", -FENCE_HALF.x, back, front, FENCE_HEIGHT)
	_fence("z", FENCE_HALF.x, back, front, FENCE_HEIGHT)
	_model(WELL_MODEL, WELL_AT)
	var well := _build.body(WELL_AT + Vector3(0, 0.4, 0))
	_build.shape(well, Vector3(1.2, 0.8, 1.2))
	_build.box(STALL_AT + Vector3(0, STALL_SIZE.y - 0.03, 0), Vector3(STALL_SIZE.x, 0.06, STALL_SIZE.z), WOOD)
	_build.legs(STALL_AT, Vector2(STALL_SIZE.x, STALL_SIZE.z), STALL_SIZE.y - 0.06, WOOD)
	for at: Vector3 in BASKETS:
		baskets.append(_model(BASKET_MODEL, at + Vector3.UP * STALL_SIZE.y))
		for i in EGGS_PER_BASKET:
			var turn := i * TAU / EGGS_PER_BASKET
			add_egg(at + Vector3(cos(turn) * 0.07, STALL_SIZE.y + 0.15, sin(turn) * 0.07), false)


## The house: white walls, a door to the porch, the wall between the kitchen and the room, a flat roof, the porch
## with its roof on two posts and the feeding bell, the kitchen's table and the locked tool shed.
func _build_house() -> void:
	var h := HOUSE
	_build.wall_at("x", h.end.y, h.position.x, h.end.x, GROUND, HOUSE_HEIGHT, [HOUSE_DOOR_X], WHITE_WALL)
	_build.wall_at("x", h.position.y, h.position.x, h.end.x, GROUND, HOUSE_HEIGHT, [], WHITE_WALL)
	_build.wall_at("z", h.position.x, h.position.y, h.end.y, GROUND, HOUSE_HEIGHT, [], WHITE_WALL)
	_build.wall_at("z", h.end.x, h.position.y, h.end.y, GROUND, HOUSE_HEIGHT, [], WHITE_WALL)
	_build.wall_at("z", ROOM_WALL_X, h.position.y, h.end.y, GROUND, HOUSE_HEIGHT, [h.get_center().y], WHITE_WALL)
	_build.slab(h.position.x - 0.3, h.end.x + 0.3, h.position.y - 0.3, h.end.y + PORCH_DEPTH, GROUND + HOUSE_HEIGHT + PlaceBuilder.SLAB, ROOF)
	_build.slab(h.position.x, h.end.x, h.position.y, h.end.y, GROUND + 0.06, WOOD)
	for x: float in [h.position.x + 0.2, h.end.x - 0.2]:
		_build.box(Vector3(x, GROUND + HOUSE_HEIGHT / 2, h.end.y + PORCH_DEPTH - 0.2), Vector3(0.15, HOUSE_HEIGHT, 0.15), WOOD)
	bell = FeedBell.new()
	bell.position = BELL_AT
	add_child(bell)
	# The kitchen's table, against the back wall.
	_build.box(Vector3(-12.2, GROUND + 0.76, -9.8), Vector3(1.6, 0.06, 0.9), WOOD)
	_build.legs(Vector3(-12.2, GROUND, -9.8), Vector2(1.6, 0.9), 0.73, WOOD)
	_build.light(Vector3(-13.2, GROUND + HOUSE_HEIGHT - 0.4, -7.5))
	house_door = _door(Vector3(HOUSE_DOOR_X - GameScale.DOOR_WIDTH / 2, GROUND, h.end.y), 0.0)
	house_door.locked = false
	var s := SHED
	var door_x := s.get_center().x
	_build.wall_at("x", s.end.y, s.position.x, s.end.x, GROUND, 2.4, [door_x], WOOD)
	_build.wall_at("x", s.position.y, s.position.x, s.end.x, GROUND, 2.4, [], WOOD)
	_build.wall_at("z", s.position.x, s.position.y, s.end.y, GROUND, 2.4, [], WOOD)
	_build.wall_at("z", s.end.x, s.position.y, s.end.y, GROUND, 2.4, [], WOOD)
	_build.slab(s.position.x - 0.2, s.end.x + 0.2, s.position.y - 0.2, s.end.y + 0.2, GROUND + 2.4 + PlaceBuilder.SLAB, ROOF)
	shed_door = _door(Vector3(door_x - GameScale.DOOR_WIDTH / 2, GROUND, s.end.y), 0.0)


## The red barn, open to the yard through its big doorway, the loft over its back half with the ladder, the bales,
## the tractor beside it and the milk cans.
func _build_barn() -> void:
	var b := BARN
	var door := b.get_center().x
	_build.wall_at("x", b.position.y, b.position.x, b.end.x, GROUND, BARN_HEIGHT, [], BARN_RED)
	_build.wall_at("z", b.position.x, b.position.y, b.end.y, GROUND, BARN_HEIGHT, [], BARN_RED)
	_build.wall_at("z", b.end.x, b.position.y, b.end.y, GROUND, BARN_HEIGHT, [], BARN_RED)
	_build.wall_at("x", b.end.y, b.position.x, door - BARN_DOOR / 2, GROUND, BARN_HEIGHT, [], BARN_RED)
	_build.wall_at("x", b.end.y, door + BARN_DOOR / 2, b.end.x, GROUND, BARN_HEIGHT, [], BARN_RED)
	_build.wall_at("x", b.end.y, door - BARN_DOOR / 2, door + BARN_DOOR / 2, GROUND + 3.6, BARN_HEIGHT - 3.6, [], BARN_RED)
	_build.slab(b.position.x - 0.3, b.end.x + 0.3, b.position.y - 0.3, b.end.y + 0.3, GROUND + BARN_HEIGHT + PlaceBuilder.SLAB, ROOF)
	_build.slab(b.position.x, b.end.x, b.position.y, LOFT_FRONT, GROUND + LOFT_TOP, WOOD)
	_build.mesh_box(Vector3(b.get_center().x, GROUND + 0.006, b.get_center().y), Vector3(b.size.x, 0.01, b.size.y), STRAW)
	_build.light(Vector3(b.get_center().x, GROUND + LOFT_TOP - 0.3, -3.5)).omni_range = 10.0
	_build.light(Vector3(b.get_center().x, GROUND + BARN_HEIGHT - 0.5, -8.5))
	# The ladder: a steep ramp up to the loft's front edge, by the east wall.
	var ramp := _build.body(Vector3(16.5, GROUND + LOFT_TOP / 2, LOFT_FRONT + 1.2))
	ramp.rotation.x = atan2(LOFT_TOP, 2.4)
	_build.shape(ramp, Vector3(GameScale.STAIR_WIDTH, 0.05, Vector2(2.4, LOFT_TOP).length()))
	for i in 6:
		_build.mesh_box(Vector3(16.5, GROUND + (i + 0.5) * LOFT_TOP / 6, LOFT_FRONT + 2.4 - (i + 0.5) * 0.4),
			Vector3(GameScale.STAIR_WIDTH, 0.05, 0.08), WOOD)
	for at: Vector3 in BALES:
		_model(BALE_MODEL, at + Vector3(0, GROUND - 0.25, 0), PI / 2)
		var bale := _build.body(at + Vector3.UP * GROUND)
		_build.shape(bale, Vector3(0.5, 0.5, 1.0))
	tractor_model = _model(TRACTOR_MODEL, TRACTOR_AT + Vector3.UP * GROUND)
	tractor = FarmTractor.new()
	tractor.name = "Tractor"
	tractor.position = TRACTOR_AT + Vector3(0, GROUND + 1.0, 0)
	$Built.add_child(tractor)
	_build.shape(tractor, Vector3(1.6, 1.2, 2.6))
	for dx: float in [-0.35, 0.0, 0.35]:
		var can := CylinderMesh.new()
		can.top_radius = 0.16
		can.bottom_radius = 0.18
		can.height = 0.7
		_build.mesh(can, MILK_CANS_AT + Vector3(dx, GROUND + 0.35, 0), MILK_CAN)
	var cans := _build.body(MILK_CANS_AT + Vector3(0, GROUND + 0.35, 0))
	_build.shape(cans, Vector3(1.1, 0.7, 0.4))


## The hen house, the pigsty with its mud and the cow's corral with her feeder (its gate comes with her, step 4).
func _build_pens() -> void:
	_model(COOP_MODEL, COOP_AT + Vector3.UP * GROUND)
	var coop := _build.body(COOP_AT + Vector3(0, GROUND + 0.9, -0.2))
	_build.shape(coop, Vector3(2.0, 1.8, 1.2))
	_pen(STY, STY_FENCE, -1.0)
	_build.mesh_box(Vector3(MUD.get_center().x, GROUND + 0.012, MUD.get_center().y), Vector3(MUD.size.x, 0.01, MUD.size.y), MUD_COLOR)
	_pen(CORRAL, FENCE_HEIGHT, CORRAL_GATE_Z)
	_build.open_box(FEEDER_AT + Vector3.UP * GROUND, FEEDER_SIZE, "top", WOOD)


## The vegetable garden's rows, the scarecrow and the glass greenhouse.
func _build_garden() -> void:
	var g := GARDEN
	for i in 4:
		var z := g.position.y + 0.8 + i * 1.5
		_build.mesh_box(Vector3(g.get_center().x - 1.2, GROUND + 0.06, z), Vector3(g.size.x - 3.4, 0.12, 0.6), SOIL)
	_model(SCARECROW_MODEL, SCARECROW_AT + Vector3.UP * GROUND)
	var r := GREENHOUSE
	greenhouse = Node3D.new()
	greenhouse.name = "Greenhouse"
	$Built.add_child(greenhouse)
	var glass := PlaceBuilder.new(greenhouse)
	var center := Vector3(r.get_center().x, GROUND + GREENHOUSE_HEIGHT / 2, r.get_center().y)
	glass.box(center + Vector3(0, GREENHOUSE_HEIGHT / 2, 0), Vector3(r.size.x, 0.04, r.size.y), GLASS)
	glass.box(center - Vector3(r.size.x / 2, 0, 0), Vector3(0.04, GREENHOUSE_HEIGHT, r.size.y), GLASS)
	glass.box(center + Vector3(r.size.x / 2, 0, 0), Vector3(0.04, GREENHOUSE_HEIGHT, r.size.y), GLASS)
	glass.box(center - Vector3(0, 0, r.size.y / 2), Vector3(r.size.x, GREENHOUSE_HEIGHT, 0.04), GLASS)
	glass.box(center + Vector3(0, 0, r.size.y / 2), Vector3(r.size.x, GREENHOUSE_HEIGHT, 0.04), GLASS)
	var area := Area3D.new()
	area.position = center
	area.collision_layer = 0
	area.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(r.size.x + 0.4, GREENHOUSE_HEIGHT + 0.2, r.size.y + 0.4)
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if multiplayer.is_server() and body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > GLASS_SPEED:
			break_greenhouse())


## Shatters the greenhouse, once: a fine, the glass gone, and Don Florencio minds it if he sees it.
func break_greenhouse() -> void:
	if greenhouse_broken:
		return
	greenhouse_broken = true
	broken_goods += 1
	var at := to_global(Vector3(GREENHOUSE.get_center().x, GROUND + 1.0, GREENHOUSE.get_center().y))
	if raid:
		fines += GLASS_FINE
		raid.float_label("-%d" % GLASS_FINE, at, Color(1, 0.3, 0.25))
	if owner_npc:
		owner_npc.saw(at, FloorBoss.SAW_BREAK, "FARMER_GLASS")
	greenhouse.queue_free()


## An egg at `at` (this scene's space): on the stall, or just laid. Each one that breaks counts.
func add_egg(at: Vector3, golden: bool) -> FarmEgg:
	var egg := FarmEgg.new()
	egg.golden = golden
	egg.position = at
	add_child(egg)
	eggs.append(egg)
	egg.broken.connect(func(_where: Vector3) -> void:
		eggs.erase(egg)
		broken_goods += 1
		if owner_npc:
			owner_npc.egg_broken())
	return egg


## A wooden pen round `area`, `height` tall, with an opening of GATE_WIDTH on its east side at z = gate (none if
## gate is outside it).
func _pen(area: Rect2, height: float, gate: float) -> void:
	_fence("x", area.position.y, area.position.x, area.end.x, height)
	_fence("x", area.end.y, area.position.x, area.end.x, height)
	_fence("z", area.position.x, area.position.y, area.end.y, height)
	if gate > area.position.y and gate < area.end.y:
		_fence("z", area.end.x, area.position.y, gate - GATE_WIDTH / 2, height)
		_fence("z", area.end.x, gate + GATE_WIDTH / 2, area.end.y, height)
	else:
		_fence("z", area.end.x, area.position.y, area.end.y, height)


## A wooden fence along "x" (at z = fixed) or "z" (at x = fixed): two rails on posts, solid to bump into.
func _fence(axis: String, fixed: float, from: float, to: float, height: float) -> void:
	if to - from < 0.01:
		return
	var mid := (from + to) / 2
	var length := to - from
	var along := Vector3(1, 0, 0) if axis == "x" else Vector3(0, 0, 1)
	var center := Vector3(mid, 0, fixed) if axis == "x" else Vector3(fixed, 0, mid)
	var long := Vector3(length, 0, 0.08) if axis == "x" else Vector3(0.08, 0, length)
	for rail: float in [height * 0.45, height * 0.9]:
		_build.mesh_box(center + Vector3(0, GROUND + rail, 0), long + Vector3(0, 0.12, 0), WOOD)
	var gaps := maxi(1, int(length / 2.0))
	for i in gaps + 1:
		_build.mesh_box(center + along * (-length / 2 + i * length / gaps) + Vector3(0, GROUND + height / 2, 0),
			Vector3(0.12, height, 0.12), WOOD)
	var solid := _build.body(center + Vector3(0, GROUND + height / 2, 0))
	_build.shape(solid, long + Vector3(0, height, 0))


## A door with its hinge at `hinge`, turned `turn` around Y (closed, it runs along +X from the hinge).
func _door(hinge: Vector3, turn: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = hinge
	door.rotation.y = turn
	add_child(door)
	return door


func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
