class_name Bowling
extends Node3D

## The bowling alley "Bolos Chuza Feliz" as a place to raid (docs/diseno/allanamiento-bolera.md, step 1): an alley on
## its lot in the city, open and with the front to +Z. Six lanes run from the approach by the door (their foul line at
## FOUL_Z) to the pins at the back, with a curb between lanes, the pin machines over their ends and a narrow corridor
## behind them. Between each two lanes stands a ball return, over the foul line hang the score screens and behind the
## approach the benches. On the east side are the shoe counter by the door (the office's key in its till), the bar with
## the popcorn machine, and the owner's office in the back east corner, locked, with the trophy case. The trophy case
## breaks if something hits it fast and a screen if a ball flies into it, a fine each. It's a raid case like the
## supermarket (step 5): one of its stories (STORIES), drawn with the seed, run by the same RaidCase as the other places.
## Every number here is (propuesta).

signal trophy_case_broken
signal screen_broken(lane: int)
## A ball reached lane `lane`'s pit and the machine counted the pins down before setting them up again (step 2).
signal rolled(lane: int, knocked: int, ball: BowlingBall)
## A league player complained (Don Chuza adds it to the complaint, step 3).
signal player_complained(player: BowlPlayer)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const OWNER_SCENE := preload("res://scenes/npc/bowl_owner.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the alley can be suspected of (allanamiento-bolera.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["bowl_magnet", "bowl_lead_pins", "bowl_skates", "bowl_tournament", "bowl_popcorn", "bowl_lane7"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_BOWL_TIP_B", "BRIEF_TIP_C", "BRIEF_BOWL_TIP_D",
	"BRIEF_BOWL_TIP_E"]
## The stories the alley can tell, like Supermarket.STORIES: what the comisario says once it's guessed, its "find it"
## row, what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist
## rows of its extras and its rig. With "main_hidden" the first hidden item is the main evidence.
const STORIES := {
	"bowl_magnet": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_BOWL_MAGNET_B", "BRIEF_BOWL_MAGNET_C", "BRIEF_BOWL_MAGNET_D"],
		"find": "OBJ_FIND_MAGNET_BALL",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/bowl_magnet_ball.tscn"), preload("res://scenes/props/bowl_pin_remote.tscn"),
			preload("res://scenes/props/bowl_bet_list.tscn")],
		"half_heights": [0.12, 0.02, 0.01],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_PIN_REMOTE", "OBJ_EXTRA_BET_LIST"],
		"rig": preload("res://scripts/case/bowling/magnet_ball_rig.gd"),
	},
	"bowl_lead_pins": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_BOWL_LEAD_B", "BRIEF_BOWL_LEAD_C", "BRIEF_BOWL_LEAD_D"],
		"find": "OBJ_FIND_LEAD_MOLD",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/bowl_lead_mold.tscn"), preload("res://scenes/props/bowl_lead_pin.tscn"),
			preload("res://scenes/props/bowl_lead_invoice.tscn")],
		"half_heights": [0.3, 0.19, 0.01],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_LEAD_PIN", "OBJ_EXTRA_LEAD_INVOICE"],
		"rig": preload("res://scripts/case/bowling/lead_pins_rig.gd"),
	},
	"bowl_skates": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_BOWL_SKATES_B", "BRIEF_BOWL_SKATES_C", "BRIEF_BOWL_SKATES_D"],
		"find": "OBJ_FIND_SKATE_BOX",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/bowl_skate_box.tscn"), preload("res://scenes/props/bowl_skate_parts.tscn"),
			preload("res://scenes/props/bowl_skate_manual.tscn")],
		"half_heights": [0.13, 0.03, 0.015],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_SKATE_PARTS", "OBJ_EXTRA_SKATE_MANUAL"],
		"rig": preload("res://scripts/case/bowling/wheeled_shoes_rig.gd"),
	},
	"bowl_tournament": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_BOWL_CUP_B", "BRIEF_BOWL_CUP_C", "BRIEF_BOWL_CUP_D"],
		"find": "OBJ_FIND_RIGGED_CUP",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/bowl_rigged_cup.tscn"), preload("res://scenes/props/bowl_fake_scores.tscn"),
			preload("res://scenes/props/bowl_judge_envelope.tscn")],
		"half_heights": [0.2, 0.005, 0.02],
		"heavy": [false, false, false],
		"extra_keys": ["OBJ_EXTRA_FAKE_SCORES", "OBJ_EXTRA_JUDGE_ENVELOPE"],
		"rig": preload("res://scripts/case/bowling/rigged_tournament_rig.gd"),
	},
}
## Where the clue notes for the suspicions can lie, on the floor.
const NOTE_PLACES: Array[Vector3] = [Vector3(-1.5, FLOOR_TOP, 8.0), Vector3(3.0, FLOOR_TOP, 5.0),
	Vector3(-8.0, FLOOR_TOP, 9.5), Vector3(-2.0, FLOOR_TOP, -6.0), Vector3(6.0, FLOOR_TOP, -2.5),
	Vector3(11.0, FLOOR_TOP, -6.0)]
const PIN_MODEL := preload("res://assets/models/bowling_pin.glb")
const SETTER_MODEL := preload("res://assets/models/pin_setter.glb")
const RETURN_MODEL := preload("res://assets/models/ball_return.glb")
const SCREEN_MODEL := preload("res://assets/models/score_screen.glb")
const COUNTER_MODEL := preload("res://assets/models/shoe_counter.glb")
const BAR_MODEL := preload("res://assets/models/bowling_bar.glb")
const POPCORN_MODEL := preload("res://assets/models/popcorn_machine.glb")
const CASE_MODEL := preload("res://assets/models/trophy_case.glb")
const BENCH_MODEL := preload("res://assets/models/bowling_bench.glb")
const GIANT_PIN_MODEL := preload("res://assets/models/giant_pin.glb")
const HALF_X := 15.0
const HALF_Z := 12.0
const WALL_TOP := 5.0
const BUILDING_TOP := 7.0
const FLOOR_TOP := 0.06
## The open doorway in the front wall, between the lanes and the shoe counter.
const ENTRANCE_X := 0.5
const ENTRANCE_WIDTH := 4.0
const ENTRANCE_HEIGHT := 3.0

## The lanes: their middles, the wood's width (the gutters on both sides), where the approach ends and where the head
## pin stands; the curbs between lanes run from the foul line to the pin wall.
const LANE_X: Array[float] = [-12.5, -10.9, -9.3, -7.7, -6.1, -4.5]
const LANE_PITCH := 1.6
const LANE_WIDTH := 1.05
const FOUL_Z := 4.0
const HEAD_PIN_Z := -6.6
const PIN_WALL_Z := -9.0
const CURB_SIZE := Vector3(0.1, 0.12, FOUL_Z - PIN_WALL_Z)
## The 10 pins of a lane: rows of 1 to 4, 0.3 m apart, from the head pin back.
const PIN_SPACING := 0.3
const PIN_SIZE := Vector3(0.12, 0.38, 0.12)
const PIN_KG := 1.5
## The corridor behind the pin machines, its door at its east end.
const CORRIDOR_EAST_X := -3.0
const CORRIDOR_DOOR_Z := -10.6
const SETTER_Z := -8.5
## The ball returns, between lanes 1-2, 3-4 and 5-6, the benches behind them and the score screens over the foul line.
const RETURN_X: Array[float] = [-11.7, -8.5, -5.3]
const RETURN_Z := 5.4
const RETURN_SIZE := Vector3(0.62, 0.86, 1.0)
const BENCH_Z := 7.6
const SCREEN_Z := 3.8
const SCREEN_Y := 3.3
const SCREEN_SIZE := Vector3(1.2, 0.7, 0.3)
const SCREEN_SPEED := 3.0
const SCREEN_FINE := 15
## The balls (step 2): three on each return's rack, their weights, and the rack they rest on (behind the hood). A ball
## in a lane's pit comes back to its rack RETURN_TIME later, and the machine sets the pins up RESET_TIME after it
## came, counting the ones down: tipped over or moved off their place.
const BALL_KG: Array[float] = [4.0, 5.0, 6.0, 7.0, 5.0, 6.0, 7.0, 4.0, 6.0]
const RACK_SIZE := Vector3(0.6, 0.5, 0.6)
const RACK_Z := 0.2
const SLOT_STEP := 0.22
const PIT_SIZE := Vector3(1.5, 0.8, 1.6)
const PIT_Z := -8.2
const RETURN_TIME := 4.0
const RESET_TIME := 6.0
const PIN_DOWN := 0.7
const PIN_MOVED := 0.25
## The waxed lanes: a cop running on one skates on, pushed along, and can't skate again for a moment.
const SKATE_TIME := 0.9
const SKATE_PUSH := 3.0
const SKATE_AGAIN := 1.5
## With a pair of Pipo's bowling shoes on, a cop only slides a little.
const SHOD_PUSH := 1.2
const SHOD_TIME := 0.4
## The Thursday league: two players on each of these lanes, waiting between the rack and the bench.
const LEAGUE_LANES: Array[int] = [0, 2, 4]
const PLAYER_Z := 6.6
## Both players of a lane wait on its west side, off the spot in front of the return.
const PLAYER_GAP := 0.3
## Don Chuza's round: along the approach, in front of the returns, and up the east side to the counter. At a strike he
## celebrates by the lane's foul line facing its pins.
const OWNER_ROUTE: Array[Vector3] = [Vector3(1.5, FLOOR_TOP, 8.0), Vector3(1.5, FLOOR_TOP, 4.5),
	Vector3(-3.8, FLOOR_TOP, 4.5), Vector3(-8.5, FLOOR_TOP, 4.5), Vector3(-12.8, FLOOR_TOP, 4.5)]
const STRIKE_SPOT_Z := 4.5
const PINS := 10
## What he notices: a pin machine's corridor or the office's case, a complaint from the league (each one's own
## cooldown, BowlPlayer) and the cops' third strike.
const PLAYER_COMPLAINT := 5.0
const CAUGHT_ON := 10.0
## The shoe counter east of the door (its till holds the office's key), the bar and the popcorn machine.
const COUNTER_AT := Vector3(6.0, FLOOR_TOP, 9.0)
const COUNTER_SIZE := Vector3(4.1, 1.1, 0.8)
const TILL_ON := Vector3(4.6, FLOOR_TOP + 1.12, 9.0)
## Pipo, behind the counter between it and the shelf, facing the alley, on a crate so he can see over it.
const PIPO_AT := Vector3(6.5, FLOOR_TOP + 0.5, 9.8)
const BAR_AT := Vector3(5.0, FLOOR_TOP, 0.0)
const BAR_SIZE := Vector3(3.1, 1.1, 0.8)
const POPCORN_AT := Vector3(7.3, FLOOR_TOP, 0.0)
const POPCORN_SIZE := Vector3(0.6, 0.92, 0.6)
const FRIDGE_AT := Vector3(2.8, FLOOR_TOP, -0.8)
const FRIDGE_SIZE := Vector3(0.8, 1.8, 0.7)
## The office in the back east corner, its door in its front wall (OFFICE_Z), with the desk and the trophy case against
## the east wall.
const OFFICE_X := 8.0
const OFFICE_Z := -4.0
const OFFICE_DOOR_X := 10.5
const DESK_AT := Vector3(11.5, FLOOR_TOP, -9.5)
const DESK_SIZE := Vector3(1.8, 0.8, 0.9)
const CASE_AT := Vector3(14.4, FLOOR_TOP, -7.5)
const CASE_SIZE := Vector3(0.6, 2.0, 2.0)
const CASE_SPEED := 3.0
const CASE_FINE := 30

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_ball_return", "at": Vector3(-8.5, FLOOR_TOP, 6.2), "heavy": true},
	{"id": "in_pin_machine_corridor", "at": Vector3(-9.3, FLOOR_TOP, -11.2), "heavy": true},
	{"id": "in_old_pins_store", "at": Vector3(-1.0, FLOOR_TOP, -11.0), "heavy": true},
	{"id": "behind_trophy_case", "at": Vector3(13.6, FLOOR_TOP, -5.2), "heavy": true},
	{"id": "in_bowl_office_corner", "at": Vector3(9.0, FLOOR_TOP, -11.2), "heavy": true},
	{"id": "behind_shoe_counter", "at": Vector3(7.5, FLOOR_TOP, 10.0), "heavy": true},
	{"id": "on_shoe_shelf", "at": Vector3(5.0, FLOOR_TOP + 1.4, 10.5), "heavy": false},
	{"id": "under_bench", "at": Vector3(-5.3, FLOOR_TOP, 7.6), "heavy": false},
	{"id": "by_popcorn_machine", "at": Vector3(7.3, FLOOR_TOP + 0.95, 0.0), "heavy": false},
	{"id": "behind_bar", "at": Vector3(5.0, FLOOR_TOP, -0.9), "heavy": false},
	{"id": "in_lane_6_gutter", "at": Vector3(-3.95, FLOOR_TOP, -2.0), "heavy": false},
	{"id": "on_bowl_desk", "at": Vector3(11.5, FLOOR_TOP + 0.8, -9.5), "heavy": false},
]

const OUTSIDE := Color(0.95, 0.55, 0.25)
const CARPET := Color(0.26, 0.22, 0.42)
const LANE_WOOD := Color(0.86, 0.68, 0.42)
const GUTTER := Color(0.32, 0.34, 0.38)
const CEILING := Color(0.16, 0.16, 0.22)
const WOOD := Color(0.6, 0.44, 0.3)
const DARK := Color(0.1, 0.1, 0.12)
const GLASS := Color(0.6, 0.82, 0.95)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
## Each lane's pins, in rows from the head pin, and where each one stands.
var pins: Array = []
var pin_homes: Array = []
var balls: Array[BowlingBall] = []
var players: Array[BowlPlayer] = []
var owner_boss: FloorBoss
var pipo: ShoeBoy
var strike_call: StrikeCall
var complaint_bar: ProgressBar
## Ball -> seconds until it's back on its rack; lane -> seconds until its pins are set up, and the ball that came.
var _returning := {}
var _resetting := {}
var _last_ball := {}
## Cop -> seconds until it can skate again.
var _skated := {}
var case_broken := false
var broken_screens: Array[int] = []
## Each lane's points on its screen, and what its screen adds to every roll on top of the pins (a story's trick).
var scores: Array[int] = [0, 0, 0, 0, 0, 0]
var score_bonus: Array[int] = [0, 0, 0, 0, 0, 0]
var _score_labels: Array[Label3D] = []
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the trophy case and the screens.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: BowlingRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## Same seed, same alley (the stories and the hiding spots come from it, step 5).
@export var case_seed := 0
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
	raid.place_state = net_state
	raid.apply_place_state = apply_net_state
	add_child(raid)
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_lanes()
	_build_front()
	_build_office()
	_build_pins()
	_build_balls()
	_build_players()
	office_door = _door(OFFICE_DOOR_X)
	_place_owner()
	_build.box(PIPO_AT - Vector3(0, 0.25, 0), Vector3(0.6, 0.5, 0.6), WOOD.darkened(0.2))
	pipo = ShoeBoy.new()
	pipo.name = "Pipo"
	pipo.position = PIPO_AT
	pipo.rotation.y = PI
	add_child(pipo)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("bowling")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "bowling", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = owner_boss
	raid.owner_id = "bowling"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	owner_boss.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_BOWLING"))
	_place_suspicion_clues()
	_give_clues()


## The alley's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_BOWL",
		"guess_key": "OBJ_GUESS_BOWL",
		"broken_key": "OBJ_BROKEN_BOWL",
		"complaint_key": "OBJ_COMPLAINT_BOWL",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_screens.size() + (1 if case_broken else 0),
		"complaint": owner_boss.complaint,
	}


## Online, what the guests' alley takes from the host's (RaidCase.snapshot): what's broken and what the story's rig
## decides on the host (the rest is step 8).
func net_state() -> Dictionary:
	return {"case": case_broken, "screens": broken_screens.duplicate(), "rig": rig.net_state() if rig else null}


func apply_net_state(state: Dictionary) -> void:
	if state.case:
		break_trophy_case()
	for lane: int in state.screens:
		break_screen(lane)
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


## What Don Chuza lets slip when asked (where the story's things are, in an order drawn from the seed), and what Pipo
## saw: where he hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		owner_boss.slips.append(tr("CHUZA_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	owner_boss.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	pipo.clue = tr("CLUE_PIPO") % where
	pipo.clue_speech = tr("PIPO_CLUE_" + story_id) % where
	pipo.told.connect(raid.add_clue)


## The carpet, the walls with the doorway, the dark ceiling with its lights, the roof, the sign and its giant pin.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, CARPET)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, CEILING)
	var x0 := ENTRANCE_X - ENTRANCE_WIDTH / 2
	var x1 := ENTRANCE_X + ENTRANCE_WIDTH / 2
	_build.wall_at("x", HALF_Z, -HALF_X, x0, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x1, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x0, x1, ENTRANCE_HEIGHT, WALL_TOP - ENTRANCE_HEIGHT, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_label("PLACE_BOWLING", Vector3(-6.0, WALL_TOP + 0.9, HALF_Z + 0.08), 110)
	_model(GIANT_PIN_MODEL, Vector3(-12.5, BUILDING_TOP, HALF_Z - 1.0))
	for x: float in [-11.0, -6.0, -1.0, 5.0, 11.0]:
		for z: float in [-6.0, 0.0, 7.0]:
			_build.light(Vector3(x, 4.6, z))


## The six lanes with their gutters and curbs, the pin machines and the wall over the pins, the corridor behind them,
## the ball returns, the benches and the score screens.
func _build_lanes() -> void:
	var length := FOUL_Z - PIN_WALL_Z
	var mid_z := (FOUL_Z + PIN_WALL_Z) / 2
	for i in LANE_X.size():
		var x := LANE_X[i]
		_build.mesh_box(Vector3(x, FLOOR_TOP + 0.005, mid_z), Vector3(LANE_WIDTH, 0.01, length), LANE_WOOD)
		for side: float in [-1.0, 1.0]:
			var gutter_x := x + side * (LANE_WIDTH / 2 + 0.12)
			_build.mesh_box(Vector3(gutter_x, FLOOR_TOP + 0.004, mid_z), Vector3(0.24, 0.008, length), GUTTER)
		_build.mesh_box(Vector3(x, FLOOR_TOP + 0.012, FOUL_Z), Vector3(LANE_WIDTH, 0.01, 0.05), Color(0.85, 0.2, 0.2))
		_model(SETTER_MODEL, Vector3(x, FLOOR_TOP, SETTER_Z))
		var screen := _model(SCREEN_MODEL, Vector3(x, SCREEN_Y, SCREEN_Z))
		screen.name = "Screen%d" % i
		var points := Label3D.new()
		points.text = "0"
		points.font_size = 64
		points.pixel_size = 0.005
		points.outline_size = 10
		points.double_sided = false
		points.position = Vector3(x, SCREEN_Y - 0.15, SCREEN_Z + 0.06)
		$Built.add_child(points)
		_score_labels.append(points)
		var pit := _area(Vector3(x, FLOOR_TOP + PIT_SIZE.y / 2, PIT_Z), PIT_SIZE)
		pit.body_entered.connect(func(body: Node3D) -> void:
			if body is BowlingBall and not (body as BowlingBall).is_held():
				in_pit(i, body))
		var hit := _area(Vector3(x, SCREEN_Y, SCREEN_Z), SCREEN_SIZE)
		hit.body_entered.connect(func(body: Node3D) -> void:
			if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > SCREEN_SPEED:
				break_screen(i))
	# A curb on each lane's outer edge, so a ball stays in its lane.
	for i in LANE_X.size() + 1:
		var x := LANE_X[0] - LANE_PITCH / 2 + i * LANE_PITCH
		_build.box(Vector3(x, FLOOR_TOP + CURB_SIZE.y / 2, mid_z), CURB_SIZE, GUTTER.darkened(0.3))
	# The wall over the pins (the pit under it lets pins and balls through) and the corridor of the machines.
	var west := -HALF_X
	_build.wall_at("x", PIN_WALL_Z, west, CORRIDOR_EAST_X, 1.0, WALL_TOP - 1.0, [], DARK.lightened(0.15))
	_build.wall_at("z", CORRIDOR_EAST_X, -HALF_Z, PIN_WALL_Z, 0.0, WALL_TOP, [CORRIDOR_DOOR_Z], DARK.lightened(0.15))
	for x: float in RETURN_X:
		# The hood where the balls come up, and the lower rack they rest on.
		_solid(Vector3(x, FLOOR_TOP + RETURN_SIZE.y / 2, RETURN_Z - 0.3), Vector3(RETURN_SIZE.x, RETURN_SIZE.y, 0.4))
		_solid(Vector3(x, FLOOR_TOP + RACK_SIZE.y / 2, RETURN_Z + RACK_Z), RACK_SIZE)
		_model(RETURN_MODEL, Vector3(x, FLOOR_TOP, RETURN_Z))
		_solid(Vector3(x, FLOOR_TOP + 0.45, BENCH_Z), Vector3(2.4, 0.9, 0.5))
		_model(BENCH_MODEL, Vector3(x, FLOOR_TOP, BENCH_Z), PI)
	# The old pins' store against the back wall, east of the corridor, open on top.
	_build.open_box(Vector3(-1.0, FLOOR_TOP, -11.0), Vector3(1.6, 0.9, 1.2), "top", WOOD.darkened(0.2))


## The shoe counter with its till, the bar, the popcorn machine and the drinks fridge.
func _build_front() -> void:
	_solid(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0), COUNTER_SIZE)
	_solid(COUNTER_AT + Vector3(0, 1.1, 1.4), Vector3(4.0, 2.2, 0.4))
	_model(COUNTER_MODEL, COUNTER_AT, PI)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_BOWLING"
	add_child(till)
	_solid(BAR_AT + Vector3(0, BAR_SIZE.y / 2, 0), BAR_SIZE)
	_model(BAR_MODEL, BAR_AT)
	_solid(POPCORN_AT + Vector3(0, POPCORN_SIZE.y / 2, 0), POPCORN_SIZE)
	_model(POPCORN_MODEL, POPCORN_AT)
	_build.box(FRIDGE_AT + Vector3(0, FRIDGE_SIZE.y / 2, 0), FRIDGE_SIZE, Color(0.9, 0.92, 0.95))
	_build.mesh_box(FRIDGE_AT + Vector3(0, FRIDGE_SIZE.y / 2, FRIDGE_SIZE.z / 2 + 0.01), Vector3(0.7, 1.6, 0.02), GLASS)


## The owner's office (walls, its locked door, the desk and the trophy case that breaks).
func _build_office() -> void:
	_build.wall_at("x", OFFICE_Z, OFFICE_X, HALF_X, 0.0, WALL_TOP, [OFFICE_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("z", OFFICE_X, -HALF_Z, OFFICE_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.04, DARK)
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.02, 0), Vector3(DESK_SIZE.x, 0.04, DESK_SIZE.z), WOOD)
	_solid(CASE_AT + Vector3(0, CASE_SIZE.y / 2, 0), CASE_SIZE)
	_model(CASE_MODEL, CASE_AT, -PI / 2)
	var glass := _area(CASE_AT + Vector3(-CASE_SIZE.x / 2 - 0.2, CASE_SIZE.y / 2, 0), Vector3(0.4, CASE_SIZE.y, CASE_SIZE.z))
	glass.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > CASE_SPEED:
			break_trophy_case())


## The 10 pins of each lane, asleep until something knocks them.
func _build_pins() -> void:
	for x: float in LANE_X:
		var lane: Array[RigidBody3D] = []
		var homes: Array[Vector3] = []
		for row in 4:
			for i in row + 1:
				var at := Vector3(x + (i - row / 2.0) * PIN_SPACING, FLOOR_TOP + PIN_SIZE.y / 2 + 0.005,
					HEAD_PIN_Z - row * PIN_SPACING * 0.87)
				var pin := ClubEvidence.make_item("Pin", PIN_MODEL, PIN_SIZE, PIN_KG)
				(pin.get_child(1) as Node3D).position.y = -PIN_SIZE.y / 2
				add_child(pin)
				pin.position = at
				pin.sleeping = true
				lane.append(pin)
				homes.append(at)
		pins.append(lane)
		pin_homes.append(homes)


## Three balls on each return's rack, of different weights and colors.
func _build_balls() -> void:
	for rack in RETURN_X.size():
		for slot in 3:
			var ball := BowlingBall.make(BALL_KG[(rack * 3 + slot) % BALL_KG.size()], rack * 3 + slot)
			ball.name = "Ball%d" % (rack * 3 + slot)
			ball.rack = rack
			ball.slot = slot
			add_child(ball)
			ball.position = rack_spot(rack, slot)
			ball.sleeping = true
			balls.append(ball)


## The league's six players, two to a lane, each with its own first turn so the lanes take turns.
func _build_players() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["bowling players", case_seed])
	for i in LEAGUE_LANES.size() * 2:
		var player := BowlPlayer.new()
		player.name = "Player%d" % i
		player.look = "bowler" if i % 2 == 0 else "bowler_b"
		player.alley = self
		player.lane = LEAGUE_LANES[i / 2]
		player.home = Vector3(LANE_X[player.lane] - PLAYER_GAP - (i % 2) * 2 * PLAYER_GAP, FLOOR_TOP, PLAYER_Z)
		player.next_throw = 3.0 + (i / 2) * 2.0 + (i % 2) * BowlPlayer.THROW_EVERY / 2
		player.rng.seed = rng.randi()
		player.position = player.home
		add_child(player)
		player.complained.connect(player_complained.emit)
		players.append(player)


## Don Chuza on his round, the strikes that call him, what he notices and the complaint bar.
func _place_owner() -> void:
	strike_call = StrikeCall.new()
	strike_call.name = "StrikeCall"
	add_child(strike_call)
	owner_boss = OWNER_SCENE.instantiate()
	for point: Vector3 in OWNER_ROUTE:
		owner_boss.route.append(to_global(point))
	owner_boss.printer = strike_call
	add_child(owner_boss)
	owner_boss.start_at(0)
	rolled.connect(func(lane: int, down: int, ball: BowlingBall) -> void:
		if down == PINS:
			strike_call.strike(lane, ball != null and ball.thrower() != null))
	strike_call.called.connect(func(lane: int) -> void:
		owner_boss.printer_spot = to_global(Vector3(LANE_X[lane], FLOOR_TOP, STRIKE_SPOT_Z))
		owner_boss.fix_facing = to_global(Vector3(LANE_X[lane], 1.0, HEAD_PIN_Z))
		_say(Vector3(LANE_X[lane], SCREEN_Y - 0.7, SCREEN_Z + 0.3), "BOWL_STRIKE_SCREEN", owner_boss.fix_time))
	strike_call.caught_on.connect(owner_boss.blame.bind(CAUGHT_ON, "CHUZA_CAUGHT_ON"))
	player_complained.connect(func(_player: BowlPlayer) -> void: owner_boss.blame(PLAYER_COMPLAINT, "CHUZA_PLAYER"))
	office_door.broken.connect(owner_boss.door_broken)
	till.opened.connect(func(at: Vector3) -> void: owner_boss.saw(at, FloorBoss.SAW_TILL))
	trophy_case_broken.connect(func() -> void:
		owner_boss.saw(to_global(CASE_AT + Vector3.UP), FloorBoss.SAW_BREAK, "CHUZA_CASE"))
	screen_broken.connect(func(lane: int) -> void:
		owner_boss.saw(to_global(Vector3(LANE_X[lane], SCREEN_Y, SCREEN_Z)), FloorBoss.SAW_BREAK, "CHUZA_SCREEN"))
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
	owner_boss.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## Where slot `slot` of rack `rack` holds a ball.
static func rack_spot(rack: int, slot: int) -> Vector3:
	return Vector3(RETURN_X[rack], FLOOR_TOP + RACK_SIZE.y + BowlingBall.RADIUS + 0.01,
		RETURN_Z + RACK_Z - SLOT_STEP + slot * SLOT_STEP)


## The rack beside lane `lane` (each one serves the two lanes on its sides).
static func rack_of(lane: int) -> int:
	return lane / 2


## A ball resting on rack `rack`, nobody holding it (null: the cops took them all).
func rack_ball(rack: int) -> BowlingBall:
	for ball: BowlingBall in balls:
		if ball.rack == rack and not ball.is_held() and not ball.bowled \
				and ball.position.distance_to(rack_spot(rack, ball.slot)) < RACK_SIZE.x:
			return ball
	return null


## The ball leaves a league player's hand at lane `lane`'s foul line with `velocity` (alley space).
func bowl(ball: BowlingBall, lane: int, velocity: Vector3) -> void:
	ball.position = Vector3(LANE_X[lane], FLOOR_TOP + BowlingBall.RADIUS + 0.01, FOUL_Z - 0.3)
	ball.angular_velocity = Vector3.ZERO
	ball.linear_velocity = global_basis * velocity
	ball.sleeping = false
	ball.bowled = true
	# It flew from the player's hands, not from the last cop's who held it.
	ball.last_holder = 0


## Whether a ball is on its way or the machine hasn't set lane `lane`'s pins up again yet.
func lane_busy(lane: int) -> bool:
	return _resetting.has(lane) or _last_ball.has(lane)


## Whether a cop is standing on lane `lane`, between the foul line and the pins.
func cop_on_lane(lane: int) -> bool:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var at := to_local(cop.global_position)
		if on_lane(at) and absf(at.x - LANE_X[lane]) < LANE_WIDTH / 2:
			return true
	return false


## A ball reached lane `lane`'s pit: it goes back to its rack, and the machine will count and set up the pins.
func in_pit(lane: int, ball: BowlingBall) -> void:
	if _returning.has(ball):
		return
	_returning[ball] = RETURN_TIME
	_last_ball[lane] = ball
	if not _resetting.has(lane):
		_resetting[lane] = RESET_TIME


## How many of lane `lane`'s pins are down: tipped over or moved off their place.
func knocked(lane: int) -> int:
	var down := 0
	for i in (pins[lane] as Array).size():
		var pin: RigidBody3D = pins[lane][i]
		var home: Vector3 = pin_homes[lane][i]
		var moved := Vector2(pin.position.x - home.x, pin.position.z - home.z).length()
		if pin.basis.y.dot(Vector3.UP) < PIN_DOWN or moved > PIN_MOVED:
			down += 1
	return down


## The machine counts lane `lane`'s pins down and stands all ten up again.
func reset_pins(lane: int) -> void:
	var down := knocked(lane)
	for i in (pins[lane] as Array).size():
		var pin: RigidBody3D = pins[lane][i]
		pin.linear_velocity = Vector3.ZERO
		pin.angular_velocity = Vector3.ZERO
		pin.transform = Transform3D(Basis.IDENTITY, pin_homes[lane][i])
		pin.sleeping = true
	scores[lane] += down + score_bonus[lane]
	_score_labels[lane].text = str(scores[lane])
	rolled.emit(lane, down, _last_ball.get(lane) as BowlingBall)
	_last_ball.erase(lane)


## The ball comes up its return: onto its own slot of the rack, or on top of whatever is there.
func send_back(ball: BowlingBall) -> void:
	ball.bowled = false
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.position = rack_spot(ball.rack, ball.slot)
	ball.sleeping = false


func _physics_process(delta: float) -> void:
	for ball: BowlingBall in _returning.keys():
		_returning[ball] -= delta
		if _returning[ball] <= 0.0:
			_returning.erase(ball)
			if is_instance_valid(ball) and not ball.is_held():
				send_back(ball)
	for lane: int in _resetting.keys():
		_resetting[lane] -= delta
		if _resetting[lane] <= 0.0:
			_resetting.erase(lane)
			reset_pins(lane)
	_skate(delta)


## This PC's own cop running on a waxed lane skates on, out of control (a copy of another player's cop only follows);
## with Pipo's shoes on, only a little.
func _skate(delta: float) -> void:
	for cop: Variant in _skated.keys():
		_skated[cop] -= delta
		if _skated[cop] <= 0.0 or not is_instance_valid(cop):
			_skated.erase(cop)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.sync and not cop.sync.is_multiplayer_authority():
			continue
		if _skated.has(cop) or not cop.is_running or not on_lane(to_local(cop.global_position)):
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if flat.length() < 0.5:
			continue
		_skated[cop] = SKATE_AGAIN
		var shod := pipo != null and pipo.wears(cop)
		cop.knock_back(flat.normalized() * (SHOD_PUSH if shod else SKATE_PUSH), SHOD_TIME if shod else SKATE_TIME)
		cop.show_hint("HINT_BOWL_SKATE")


## Whether `at` (alley space) is on the wood of a lane, between the foul line and the pins.
static func on_lane(at: Vector3) -> bool:
	if at.z > FOUL_Z or at.z < HEAD_PIN_Z:
		return false
	for x: float in LANE_X:
		if absf(at.x - x) < LANE_WIDTH / 2:
			return true
	return false


## The trophy case's glass broke, once: a fine and the cracks over it.
func break_trophy_case() -> void:
	if case_broken:
		return
	case_broken = true
	fines += CASE_FINE
	for i in 6:
		_build.mesh_box(CASE_AT + Vector3(-CASE_SIZE.x / 2 - 0.02, 0.4 + i * 0.27, -0.7 + (i % 3) * 0.6),
			Vector3(0.02, 0.02, 0.6), DARK)
	_say(CASE_AT + Vector3(-1.0, 2.6, 0), "BOWL_CASE_BROKEN")
	trophy_case_broken.emit()


## A ball flew into lane `lane`'s screen, once per screen: a fine and the screen goes dark.
func break_screen(lane: int) -> void:
	if broken_screens.has(lane):
		return
	broken_screens.append(lane)
	fines += SCREEN_FINE
	_build.mesh_box(Vector3(LANE_X[lane], SCREEN_Y, SCREEN_Z + 0.06), Vector3(1.12, 0.62, 0.01), DARK)
	_score_labels[lane].hide()
	_say(Vector3(LANE_X[lane], SCREEN_Y + 0.8, SCREEN_Z), "BOWL_SCREEN_BROKEN")
	screen_broken.emit(lane)


## A locked door in the office's front wall, its middle at x.
func _door(x: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(x - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_Z)
	add_child(door)
	return door


## A box only to bump into, under a model that gives the look.
func _solid(center: Vector3, size: Vector3) -> void:
	_build.shape(_build.body(center), size)


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


func _label(key: String, at: Vector3, size: int, turn := 0.0, pixel := 0.01) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = pixel
	label.outline_size = 18
	label.double_sided = false
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)


## A floating line over `at` for a few seconds.
func _say(at: Vector3, key: String, seconds := 3.0) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(seconds).timeout.connect(label.queue_free)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
