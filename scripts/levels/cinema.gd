class_name Cinema
extends Node3D

## The "Cine Butaca Floja" as a place to raid (docs/diseno/allanamiento-cine.md, step 1): an old neighborhood cinema on
## its lot in the city, the front to +Z under the marquee. The hall has the ticket booth with the till, the candy
## counter with the popcorn machine, the posters and the restroom. Through the red curtain by the screen, the theater:
## dark, 40 seats in 8 rows on a floor that rises toward the back, lit only by the projector's beam; up a narrow stair
## at the back the projection booth, locked with the till's key. Something thrown hard at the screen rips it, and at the
## popcorn machine breaks its glass, a fine each. Doña Bobina spends her time in the booth and comes down the west aisle
## to the front now and then, filling the complaint; E on the projector cuts the tape and sends her to splice it, her
## back to everything (step 3). Chicho the usher sits in a free seat and whispers what he saw to a cop who sits it out
## next to him (step 4). The case is one of its stories (STORIES), drawn with the seed, run by the same RaidCase as the
## other places (step 5). Every number here is (propuesta).

signal screen_ripped
signal glass_broken
## A spectator said "¡Shhh!" (doña Bobina's complaint counts it, step 3).
signal shushed(spectator: CinemaSpectator)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const SEAT_MODEL := preload("res://assets/models/cinema_seat.glb")
const POPCORN_MODEL := preload("res://assets/models/popcorn_machine.glb")
const BOBINA_SCENE := preload("res://scenes/npc/dona_bobina.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## Every story the cinema can be suspected of (allanamiento-cine.md, "Las historias"): SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const SUSPICION_POOL := ["pirate_copies", "floor_popcorn", "haunted_cinema", "fake_tickets", "stolen_film",
	"popcorn_watches"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_CINEMA_TIP_B", "BRIEF_TIP_C", "BRIEF_CINEMA_TIP_D",
	"BRIEF_CINEMA_TIP_E"]
## The stories the cinema can tell, like Garage.STORIES: what the comisario says once it's guessed, its "find it" row,
## what it hides in spots drawn with the seed (with their half heights and whether they're heavy), the checklist rows of
## its extras and its rig. With "main_hidden" the first hidden item is the main evidence and the rest extras.
const STORIES := {
	"pirate_copies": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_PIRATE_COPIES_B", "BRIEF_PIRATE_COPIES_C", "BRIEF_PIRATE_COPIES_D"],
		"find": "OBJ_FIND_PIRATE_BOX",
		"main_hidden": true,
		"hidden": [preload("res://scenes/props/pirate_copies_box.tscn"), preload("res://scenes/props/cinema_camcorder.tscn"),
			preload("res://scenes/props/cinema_covers.tscn")],
		"half_heights": [0.21, 0.07, 0.03],
		"heavy": [true, false, false],
		"extra_keys": ["OBJ_EXTRA_CAMCORDER", "OBJ_EXTRA_COVERS"],
		"rig": preload("res://scripts/case/cinema/pirate_copies_rig.gd"),
	},
}
## Where the suspicion notes can lie: on the hall's carpet, in front of the screen and along the theater's back.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(-3.0, FLOOR_TOP, 9.0), Vector3(2.0, FLOOR_TOP, 11.5), Vector3(-8.5, FLOOR_TOP, 10.0),
	Vector3(3.5, FLOOR_TOP, 5.2), Vector3(6.0, FLOOR_TOP + RISE, -10.0), Vector3(-4.0, FLOOR_TOP + RISE, -8.5),
]
const HALF_X := 11.0
const HALF_Z := 15.0
const WALL_TOP := 8.0
const BUILDING_TOP := 9.0
const FLOOR_TOP := 0.06
## The wall between the hall (z > LOBBY_Z) and the theater, the screen in front of it, and the curtained door by the
## screen's east end.
const LOBBY_Z := 7.0
const CURTAIN_X := 9.0
## The theater's floor: flat by the screen down to SLOPE_LOW_Z, up a slope RISE high to SLOPE_HIGH_Z and flat again at
## the back.
const SLOPE_LOW_Z := 5.0
const SLOPE_HIGH_Z := -7.4
const RISE := 1.6
## The screen, hung a step in front of the hall's wall: its middle, its size, how fast a prop rips it and the fine.
const SCREEN_AT := Vector3(0, 3.6, 6.2)
const SCREEN_SIZE := Vector2(14.0, 5.0)
const SCREEN_SPEED := 3.0
const SCREEN_FINE := 50
## The seats, facing the screen: ROWS rows of SEATS_PER_ROW, the first row at FIRST_ROW_Z, every ROW_STEP toward the
## back.
const ROWS := 8
const SEATS_PER_ROW := 5
const SEAT_STEP := 1.6
const FIRST_ROW_Z := 3.6
const ROW_STEP := 1.4
const SEAT_SIZE := Vector3(0.7, 1.05, 0.6)
## The free space under a seat.
const SEAT_UNDER := 0.35
## The projection booth over the back of the theater, one floor above it, and its locked door at the top of the stair
## that goes up along the west wall.
const BOOTH_X0 := -HALF_X
const BOOTH_X1 := -2.0
const BOOTH_Z0 := -11.2
const BOOTH_DOOR_X := -10.2
const STAIR_FOOT := Vector3(-10.2, FLOOR_TOP + RISE, -7.6)
const BOOTH_FLOOR := FLOOR_TOP + RISE + GameScale.FLOOR_HEIGHT
const PROJECTOR_AT := Vector3(-6.0, BOOTH_FLOOR, -11.6)
## The ticket booth by the door, with the till; the candy counter with the popcorn machine across the hall.
const TICKETS_AT := Vector3(-5.0, FLOOR_TOP, 12.6)
const TICKETS_SIZE := Vector3(2.4, 1.1, 0.8)
const CANDY_AT := Vector3(4.5, FLOOR_TOP, 9.6)
const CANDY_SIZE := Vector3(3.2, 1.0, 0.8)
const POPCORN_AT := Vector3(5.5, FLOOR_TOP + 1.0, 9.6)
const POPCORN_SIZE := Vector3(0.64, 0.94, 0.54)
const GLASS_SPEED := 3.0
const GLASS_FINE := 20
## The restroom in the hall's front east corner, its door on its west wall.
const RESTROOM_X := 8.0
const RESTROOM_Z := 11.0

## The film: a new scene, with its line under it, every FILM_EVERY seconds, its colors tinting the screen; FILM_LINES
## lines and round again.
const FILM_EVERY := 6.0
const FILM_LINES := 8
const FILM_TINTS: Array[Color] = [Color(0.75, 0.8, 0.95), Color(0.95, 0.75, 0.55), Color(0.6, 0.85, 0.7),
	Color(0.85, 0.6, 0.8)]
## The six spectators, each in a seat drawn with the seed.
const SPECTATORS := 6

## Doña Bobina's round, back and forth: from her booth out of its door, down the stair, along the back and down the west
## aisle to the front of the theater. She splices the tape at the back of the booth, her back to the window.
const BOBINA_ROUTE: Array[Vector3] = [
	Vector3(-7.5, BOOTH_FLOOR, -13.0), Vector3(BOOTH_DOOR_X, BOOTH_FLOOR, -12.4), Vector3(BOOTH_DOOR_X, BOOTH_FLOOR, -10.4),
	Vector3(BOOTH_DOOR_X, FLOOR_TOP + RISE, -7.0), Vector3(-6.5, FLOOR_TOP + RISE, -6.6), Vector3(-6.5, FLOOR_TOP, 4.4),
	Vector3(-1.0, FLOOR_TOP, 4.6),
]
const SPLICE_SPOT := Vector3(-5.0, BOOTH_FLOOR, -13.6)
## How long she stays in her booth between rounds, and splicing the tape.
const BOOTH_PAUSE := 20.0
const SPLICE_TIME := 20.0
## A spectator's "¡Shhh!", her seeing the screen or the glass break, and cutting the tape once she knows the trick.
const SHUSHED := 5.0
const SAW_SCREEN := 10.0
const SAW_GLASS := 10.0
const NOTICED := 10.0
## She opens the booth's door when this close to it and shuts it again once past.
const DOOR_REACH := 2.0

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "behind_screen", "at": Vector3(6.4, FLOOR_TOP, 6.65), "heavy": true},
	{"id": "in_projection_booth", "at": Vector3(-9.0, BOOTH_FLOOR, -13.5), "heavy": true},
	{"id": "behind_candy_counter", "at": Vector3(4.5, FLOOR_TOP, 8.6), "heavy": true},
	{"id": "in_cinema_restroom", "at": Vector3(9.8, FLOOR_TOP, 13.8), "heavy": true},
	{"id": "under_booth_stairs", "at": Vector3(-10.2, FLOOR_TOP + RISE, -10.6), "heavy": true},
	{"id": "by_the_front_row", "at": Vector3(-7.5, FLOOR_TOP, 4.4), "heavy": true},
	{"id": "in_popcorn_machine", "at": Vector3(5.5, FLOOR_TOP + 1.2, 9.6), "heavy": false},
	{"id": "in_ticket_booth", "at": Vector3(-5.6, FLOOR_TOP + 1.1, 12.6), "heavy": false},
	{"id": "behind_posters", "at": Vector3(-8.0, FLOOR_TOP, LOBBY_Z + 0.4), "heavy": false},
	# Under a seat of the third and the sixth row, on the slope (floor_at of the row's z).
	{"id": "under_seat_row_3", "at": Vector3(-1.6, 0.602, FIRST_ROW_Z - 2 * ROW_STEP), "heavy": false},
	{"id": "under_seat_row_6", "at": Vector3(3.2, 1.144, FIRST_ROW_Z - 5 * ROW_STEP), "heavy": false},
	{"id": "in_film_cans", "at": Vector3(-4.0, BOOTH_FLOOR + 0.5, -13.8), "heavy": false},
]

const OUTSIDE := Color(0.82, 0.7, 0.55)
const CARPET := Color(0.45, 0.12, 0.14)
const DARK_FLOOR := Color(0.12, 0.1, 0.1)
const WALL_IN := Color(0.3, 0.12, 0.14)
const CURTAIN := Color(0.7, 0.1, 0.12)
const WOOD := Color(0.55, 0.36, 0.22)
const GOLD := Color(0.95, 0.78, 0.3)
const TILE := Color(0.85, 0.88, 0.9)
const DARK := Color(0.1, 0.1, 0.12)
const POSTERS: Array[Color] = [Color(0.2, 0.4, 0.8), Color(0.9, 0.5, 0.1), Color(0.3, 0.7, 0.35), Color(0.8, 0.2, 0.5)]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var booth_door: FrontDoor
var till: Till
## Each seat's place on the floor, row by row, front row first (the spectators and Chicho sit in them).
var seats: Array[Vector3] = []
var screen_torn := false
var glass_cracked := false
var broken_goods := 0
## The case flow every raid shares.
var raid: RaidCase
## Money taken off the case pay: the screen and the popcorn machine's glass.
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## Same seed, same cinema, same draw: the story and where its things go. 0 draws one.
@export var case_seed := 0
## The story this raid tells (a STORIES key); empty draws one with the seed, or takes --story=<id>.
@export var story_id := ""
## The evidence the case is about, the story's rig, what it hid and where, and its extras (checklist order).
var main: Evidence
var rig: CinemaRig
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
## The seat Chicho sits in (an index of `seats`; the one to his right is the side seat).
var chicho_seat := -1
var _build: PlaceBuilder
## Each seat's solid body, in the order of `seats`.
var _seat_bodies: Array[StaticBody3D] = []
var _screen: MeshInstance3D
var _subtitle: Label3D
var _film_left := FILM_EVERY
## The film playing (false while the tape is cut, step 3), and the line on screen.
var film_running := true
var film_line := 0
var spectators: Array[CinemaSpectator] = []
var shushes := 0
var projector: CinemaProjector
var chicho: CinemaUsher
var side_seat: CinemaSideSeat
var bobina: FloorBoss
var complaint_bar: ProgressBar
## Whether she opened the booth's door on her way, and whether it was locked then.
var _bobina_opened := false
var _was_locked := false
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
	_build_theater()
	_build_seats()
	_build_hall()
	_build_booth()
	_seat_spectators()
	_place_bobina()
	_place_chicho()
	_show_film()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("cinema")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "cinema", car)
	raid.station_parking = station_parking
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.owner_npc = bobina
	raid.owner_id = "cinema"
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()


## The cinema's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_CINEMA",
		"guess_key": "OBJ_GUESS_CINEMA",
		"broken_key": "OBJ_BROKEN_CINEMA",
		"complaint_key": "OBJ_COMPLAINT_CINEMA",
		"door_open": true,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods,
		"complaint": bobina.complaint,
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


## What doña Bobina lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Chicho saw: where she hid one of them.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		bobina.slips.append(tr("BOBINA_SLIP") % tr("LOC_" + SPOTS[hidden_spots[item]].id))
	bobina.slipped.connect(raid.add_clue)
	var where := tr("LOC_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id)
	chicho.clue = tr("CLUE_CHICHO") % where
	chicho.clue_speech = tr("CHICHO_CLUE_" + story_id) % where
	chicho.told.connect(raid.add_clue)


## The theater floor's height at z: up the slope from the screen to the back.
static func floor_at(z: float) -> float:
	var t := clampf((SLOPE_LOW_Z - z) / (SLOPE_LOW_Z - SLOPE_HIGH_Z), 0.0, 1.0)
	return FLOOR_TOP + RISE * t


## The outer walls with the open entrance, the roof, the marquee with its bulbs and the sign.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, LOBBY_Z, HALF_Z, FLOOR_TOP, CARPET)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, WALL_IN.darkened(0.4))
	_build.wall_at("x", HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [0.0], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_build.mesh_box(Vector3(0, 4.2, HALF_Z + 1.0), Vector3(9.0, 1.4, 2.0), DARK)
	for i in 15:
		_bulb(Vector3(-4.2 + i * 0.6, 3.45, HALF_Z + 2.02))
		_bulb(Vector3(-4.2 + i * 0.6, 4.95, HALF_Z + 2.02))
	for line: Array in [["PLACE_CINEMA", 90, 4.5], ["CINEMA_NOW_SHOWING", 48, 3.85]]:
		var label := Label3D.new()
		label.text = line[0]
		label.font_size = line[1]
		label.pixel_size = 0.01
		label.outline_size = 14
		label.modulate = GOLD
		label.position = Vector3(0, line[2], HALF_Z + 2.04)
		$Built.add_child(label)


## The theater: its floor rising to the back, the screen with the projector's beam on it, the wall to the hall with
## its curtain, and dim aisle lights.
func _build_theater() -> void:
	_build.slab(-HALF_X, HALF_X, SLOPE_LOW_Z, LOBBY_Z, FLOOR_TOP, DARK_FLOOR)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, SLOPE_HIGH_Z, FLOOR_TOP + RISE, DARK_FLOOR)
	var run := SLOPE_LOW_Z - SLOPE_HIGH_Z
	var length := Vector2(run, RISE).length()
	var ramp := _build.body(Vector3(0, FLOOR_TOP + RISE / 2 - PlaceBuilder.SLAB / 2, (SLOPE_LOW_Z + SLOPE_HIGH_Z) / 2))
	ramp.rotation.x = atan2(RISE, run)
	_build.shape(ramp, Vector3(HALF_X * 2, PlaceBuilder.SLAB, length))
	var look := MeshInstance3D.new()
	var plank := BoxMesh.new()
	plank.size = Vector3(HALF_X * 2, PlaceBuilder.SLAB, length)
	look.mesh = plank
	look.material_override = _build.material(DARK_FLOOR)
	ramp.add_child(look)
	# Under the raised back, down to the ground, so nothing rolls in below it.
	_build.box(Vector3(0, FLOOR_TOP + (RISE - PlaceBuilder.SLAB) / 2, (SLOPE_HIGH_Z - HALF_Z) / 2),
		Vector3(HALF_X * 2, RISE - PlaceBuilder.SLAB, HALF_Z + SLOPE_HIGH_Z), DARK_FLOOR.darkened(0.3))
	_screen = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = SCREEN_SIZE
	_screen.mesh = quad
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(0.92, 0.94, 1.0)
	glow.emission_enabled = true
	glow.emission = Color(0.75, 0.8, 0.95)
	glow.emission_energy_multiplier = 0.8
	_screen.material_override = glow
	_screen.position = SCREEN_AT
	_screen.rotation.y = PI
	$Built.add_child(_screen)
	_build.mesh_box(SCREEN_AT + Vector3(0, 0, 0.05), Vector3(SCREEN_SIZE.x + 0.6, SCREEN_SIZE.y + 0.6, 0.05), DARK)
	for side: float in [-1.0, 1.0]:
		_build.box(SCREEN_AT + Vector3(side * (SCREEN_SIZE.x / 2 + 0.2), -SCREEN_AT.y / 2, 0.05),
			Vector3(0.15, SCREEN_AT.y, 0.15), DARK)
	var area := _area(SCREEN_AT + Vector3(0, 0, -0.3), Vector3(SCREEN_SIZE.x, SCREEN_SIZE.y, 0.6))
	area.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > SCREEN_SPEED:
			rip_screen())
	_build.wall_at("x", LOBBY_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [CURTAIN_X], WALL_IN)
	# The dark velvet lining of the theater's walls, inside the outer ones.
	var inner := HALF_X - PlaceBuilder.WALL
	for side: float in [-1.0, 1.0]:
		_build.mesh_box(Vector3(side * inner, WALL_TOP / 2, (LOBBY_Z - HALF_Z) / 2), Vector3(0.02, WALL_TOP, LOBBY_Z + HALF_Z),
			WALL_IN.darkened(0.5))
	_build.mesh_box(Vector3(0, WALL_TOP / 2, -HALF_Z + PlaceBuilder.WALL), Vector3(HALF_X * 2, WALL_TOP, 0.02),
		WALL_IN.darkened(0.5))
	for side: float in [-1.0, 1.0]:
		_build.mesh_box(Vector3(CURTAIN_X + side * 0.45, GameScale.DOOR_HEIGHT / 2, LOBBY_Z - 0.12),
			Vector3(0.3, GameScale.DOOR_HEIGHT, 0.06), CURTAIN)
	var beam := SpotLight3D.new()
	beam.position = PROJECTOR_AT + Vector3(0, 1.0, 0.9)
	beam.spot_range = 24.0
	beam.spot_angle = 16.0
	beam.light_energy = 3.0
	beam.light_color = Color(1.0, 0.97, 0.85)
	$Built.add_child(beam)
	beam.look_at(SCREEN_AT)
	for z: float in [4.0, -1.0, -6.0]:
		var dim := _build.light(Vector3(HALF_X - 0.4, floor_at(z) + 0.4, z))
		dim.light_energy = 0.25
		dim.omni_range = 3.0


## The 40 seats, row by row, facing the screen up the slope: solid from the seat up, with room underneath for something
## small.
func _build_seats() -> void:
	for row in ROWS:
		var z := FIRST_ROW_Z - row * ROW_STEP
		for i in SEATS_PER_ROW:
			var at := Vector3((i - (SEATS_PER_ROW - 1) / 2.0) * SEAT_STEP, floor_at(z), z)
			seats.append(at)
			_model(SEAT_MODEL, at)
			var body := _build.body(at + Vector3(0, SEAT_UNDER + (SEAT_SIZE.y - SEAT_UNDER) / 2, 0))
			_build.shape(body, Vector3(SEAT_SIZE.x, SEAT_SIZE.y - SEAT_UNDER, SEAT_SIZE.z))
			_seat_bodies.append(body)


## The hall: the ticket booth with the till, the candy counter with the popcorn machine, the posters, the restroom and
## warm lights.
func _build_hall() -> void:
	_build.open_box(TICKETS_AT, TICKETS_SIZE, "-z", WOOD)
	_build.mesh_box(TICKETS_AT + Vector3(0, TICKETS_SIZE.y + 0.7, 0.35), Vector3(TICKETS_SIZE.x, 1.4, 0.04),
		Color(0.8, 0.9, 1.0))
	till = Till.new()
	till.position = TICKETS_AT + Vector3(0.6, TICKETS_SIZE.y + Till.SIZE.y / 2, 0)
	till.key_hint = "HINT_TILL_KEY_CINEMA"
	add_child(till)
	_build.open_box(CANDY_AT, CANDY_SIZE, "-z", CURTAIN.darkened(0.2))
	_model(POPCORN_MODEL, POPCORN_AT)
	_build.shape(_build.body(POPCORN_AT + Vector3(0, POPCORN_SIZE.y / 2, 0)), POPCORN_SIZE)
	var glass := _area(POPCORN_AT + Vector3(0, POPCORN_SIZE.y / 2, 0), POPCORN_SIZE + Vector3(0.3, 0, 0.3))
	glass.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > GLASS_SPEED:
			break_glass())
	# The posters of the coming films on the theater's wall, each in a gold frame.
	for i in POSTERS.size():
		var at := Vector3(-9.6 + i * 1.6, 1.9, LOBBY_Z + 0.1)
		_build.mesh_box(at, Vector3(1.0, 1.4, 0.03), GOLD)
		_build.mesh_box(at + Vector3(0, 0, 0.02), Vector3(0.85, 1.25, 0.03), POSTERS[i])
	var sala := Label3D.new()
	sala.text = "CINEMA_THEATER_SIGN"
	sala.font_size = 56
	sala.pixel_size = 0.01
	sala.outline_size = 10
	sala.modulate = GOLD
	sala.position = Vector3(CURTAIN_X, GameScale.DOOR_HEIGHT + 0.4, LOBBY_Z + 0.1)
	$Built.add_child(sala)
	_build.wall_at("z", RESTROOM_X, RESTROOM_Z, HALF_Z, 0.0, WALL_TOP, [13.0], TILE)
	_build.wall_at("x", RESTROOM_Z, RESTROOM_X, HALF_X, 0.0, WALL_TOP, [], TILE)
	for at: Vector3 in [Vector3(-2.0, 3.5, 12.0), Vector3(4.0, 3.5, 12.0), Vector3(0.0, 3.5, 8.5), Vector3(9.5, 2.4, 13.0)]:
		_build.light(at)


## The projection booth up the stair at the back: its floor and walls, the projector looking out of its window, the
## film cans, and the locked door.
func _build_booth() -> void:
	_build.stairs(STAIR_FOOT, STAIR_FOOT.z - BOOTH_Z0, WOOD)
	_build.slab(BOOTH_X0, BOOTH_X1, -HALF_Z, BOOTH_Z0, BOOTH_FLOOR, WOOD.darkened(0.2))
	var height := WALL_TOP - BOOTH_FLOOR
	var window := PROJECTOR_AT.x
	_build.wall_at("x", BOOTH_Z0, BOOTH_X0, window - 0.5, BOOTH_FLOOR, height, [BOOTH_DOOR_X], WALL_IN.lightened(0.2))
	_build.wall_at("x", BOOTH_Z0, window + 0.5, BOOTH_X1, BOOTH_FLOOR, height, [], WALL_IN.lightened(0.2))
	_build.wall_at("x", BOOTH_Z0, window - 0.5, window + 0.5, BOOTH_FLOOR, 0.8, [], WALL_IN.lightened(0.2))
	_build.wall_at("x", BOOTH_Z0, window - 0.5, window + 0.5, BOOTH_FLOOR + 1.4, height - 1.4, [], WALL_IN.lightened(0.2))
	_build.wall_at("z", BOOTH_X1, -HALF_Z, BOOTH_Z0, BOOTH_FLOOR, height, [], WALL_IN.lightened(0.2))
	projector = CinemaProjector.new()
	projector.position = PROJECTOR_AT
	add_child(projector)
	for i in 4:
		_build.mesh(_can(), Vector3(-4.0, BOOTH_FLOOR + 0.05 + i * 0.12, -13.8), Color(0.6, 0.62, 0.66))
	_build.light(Vector3(-7.0, BOOTH_FLOOR + 2.2, -13.0)).light_energy = 0.5
	booth_door = DOOR_SCENE.instantiate()
	booth_door.position = Vector3(BOOTH_DOOR_X - GameScale.DOOR_WIDTH / 2, BOOTH_FLOOR, BOOTH_Z0)
	add_child(booth_door)


func _can() -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.3
	mesh.bottom_radius = 0.3
	mesh.height = 0.1
	return mesh


## The six neighbors in seats drawn with the seed, never the same seat twice.
func _seat_spectators() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["cinema spectators", case_seed])
	var free: Array[int] = []
	for i in seats.size():
		free.append(i)
	for n in SPECTATORS:
		seat_spectator(free.pop_at(rng.randi_range(0, free.size() - 1)), n)


## One more neighbor in the seat `seat` (an index of `seats`) with the look `look`, counted with the others.
func seat_spectator(seat: int, look: int) -> CinemaSpectator:
	var spectator := CinemaSpectator.new()
	spectator.name = "Spectator%d" % spectators.size()
	spectator.look = look
	spectator.seat = seat
	spectator.position = seats[seat] + Vector3(0, 0.05, 0)
	add_child(spectator)
	spectator.shushed.connect(func() -> void:
		shushes += 1
		shushed.emit(spectator))
	spectators.append(spectator)
	return spectator


## Whether nobody sits in the seat `seat`: no spectator, nor Chicho, nor the seat beside him.
func seat_free(seat: int) -> bool:
	if seat == chicho_seat or seat == chicho_seat + 1:
		return false
	return spectators.all(func(spectator: CinemaSpectator) -> bool: return spectator.seat != seat)


## What the screen shows: the film's scene and its line, or white with the tape cut.
func _show_film() -> void:
	if not _subtitle:
		_subtitle = Label3D.new()
		_subtitle.font_size = 64
		_subtitle.pixel_size = 0.01
		_subtitle.outline_size = 14
		_subtitle.width = 1200.0
		_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_subtitle.position = SCREEN_AT + Vector3(0, -SCREEN_SIZE.y / 2 + 0.6, -0.05)
		_subtitle.rotation.y = PI
		$Built.add_child(_subtitle)
	var glow := _screen.material_override as StandardMaterial3D
	if film_running:
		glow.emission = FILM_TINTS[film_line % FILM_TINTS.size()]
		_subtitle.text = "CINEMA_FILM_%d" % (film_line % FILM_LINES)
	else:
		glow.emission = Color(1, 1, 1)
		_subtitle.text = "CINEMA_FILM_CUT"


## The tape breaks (a cop cut it, step 3): the screen goes white and every spectator boos.
func cut_film() -> void:
	if not film_running:
		return
	film_running = false
	_show_film()
	for spectator in spectators:
		spectator.say("CINEMA_BOO", 4.0)


## Doña Bobina mended it: the film goes on where it was.
func mend_film() -> void:
	if film_running:
		return
	film_running = true
	_film_left = FILM_EVERY
	_show_film()


func _physics_process(delta: float) -> void:
	if bobina:
		_bobina_door()
	if not film_running:
		return
	_film_left -= delta
	if _film_left <= 0.0:
		_film_left = FILM_EVERY
		film_line += 1
		_show_film()


## Chicho in a free seat drawn with the seed, with a free seat to his right that a cop can sit in.
func _place_chicho() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["cinema usher", case_seed])
	var taken := {}
	for spectator in spectators:
		taken[spectator.seat] = true
	var free: Array[int] = []
	for i in seats.size():
		if i % SEATS_PER_ROW < SEATS_PER_ROW - 1 and not taken.has(i) and not taken.has(i + 1):
			free.append(i)
	var at := free[rng.randi_range(0, free.size() - 1)]
	chicho_seat = at
	_seat_bodies[at + 1].queue_free()
	side_seat = CinemaSideSeat.new()
	side_seat.name = "SideSeat"
	side_seat.position = seats[at + 1]
	side_seat.rotation.y = PI
	add_child(side_seat)
	chicho = CinemaUsher.new()
	chicho.name = "Chicho"
	chicho.side_seat = side_seat
	chicho.position = seats[at] + Vector3(0, 0.05, 0)
	add_child(chicho)


## Doña Bobina on her round, the projector's cuts, what she notices and the complaint bar.
func _place_bobina() -> void:
	bobina = BOBINA_SCENE.instantiate()
	bobina.route = BOBINA_ROUTE
	bobina.printer_spot = SPLICE_SPOT
	bobina.printer = projector
	bobina.fix_time = SPLICE_TIME
	bobina.first_pause = BOOTH_PAUSE
	add_child(bobina)
	bobina.fix_facing = to_global(SPLICE_SPOT + Vector3(0, 0, -10))
	bobina.start_at(0)
	booth_door.broken.connect(bobina.door_broken)
	bobina.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_CINEMA"))
	till.opened.connect(func(at: Vector3) -> void: bobina.saw(at, FloorBoss.SAW_TILL))
	screen_ripped.connect(func() -> void: bobina.saw(to_global(SCREEN_AT), SAW_SCREEN, "BOBINA_SCREEN"))
	glass_broken.connect(func() -> void: bobina.saw(to_global(POPCORN_AT), SAW_GLASS, "BOBINA_GLASS"))
	shushed.connect(func(_spectator: CinemaSpectator) -> void: bobina.scold(SHUSHED, "BOBINA_SHUSHED"))
	projector.jammed.connect(cut_film)
	projector.spliced.connect(mend_film)
	projector.noticed.connect(func() -> void: bobina.scold(NOTICED, "BOBINA_NOTICED"))
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
	bobina.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## She has the booth's key: its door opens before her and shuts behind her, locked again as she found it unless a cop
## slipped in.
func _bobina_door() -> void:
	if booth_door.is_broken:
		return
	var at := to_local(bobina.global_position)
	var near := Vector2(at.x - BOOTH_DOOR_X, at.z - BOOTH_Z0).length() < DOOR_REACH
	if near and not booth_door.is_open:
		_was_locked = booth_door.locked
		_bobina_opened = true
		booth_door.open_from_inside()
	elif not near and _bobina_opened:
		_bobina_opened = false
		booth_door.close()
		booth_door.locked = _was_locked and not _cop_in_booth()


func _cop_in_booth() -> bool:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var at := to_local(cop.global_position)
		if at.x > BOOTH_X0 and at.x < BOOTH_X1 and at.z < BOOTH_Z0 and at.y > BOOTH_FLOOR - 0.5:
			return true
	return false


## Rips the screen, once: a fine and a dark gash across it.
func rip_screen() -> void:
	if screen_torn:
		return
	screen_torn = true
	broken_goods += 1
	fines += SCREEN_FINE
	raid.float_label("-%d" % SCREEN_FINE, to_global(SCREEN_AT) + Vector3.UP * 2.0, Color(1, 0.3, 0.25))
	_build.mesh_box(SCREEN_AT + Vector3(0.8, -0.3, 0.03), Vector3(3.0, 0.2, 0.02), DARK)
	_say(SCREEN_AT + Vector3(0, 3.2, 1.0), "CINEMA_SCREEN_RIPPED")
	screen_ripped.emit()


## Breaks the popcorn machine's glass, once: a fine and popcorn all over the hall's floor.
func break_glass() -> void:
	if glass_cracked:
		return
	glass_cracked = true
	broken_goods += 1
	fines += GLASS_FINE
	raid.float_label("-%d" % GLASS_FINE, to_global(POPCORN_AT) + Vector3.UP * 1.5, Color(1, 0.3, 0.25))
	for i in 14:
		var turn := i * 2.4
		_build.mesh_box(POPCORN_AT + Vector3(cos(turn) * (0.4 + i * 0.08), -0.96, 0.6 + sin(turn) * (0.3 + i * 0.06)),
			Vector3(0.06, 0.05, 0.06), Color(1.0, 0.95, 0.75))
	_say(POPCORN_AT + Vector3(0, 1.6, 0), "CINEMA_GLASS_BROKEN")
	glass_broken.emit()


## A small lit bulb of the marquee.
func _bulb(at: Vector3) -> void:
	var bulb := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.08
	sphere.height = 0.16
	bulb.mesh = sphere
	var lit := StandardMaterial3D.new()
	lit.albedo_color = GOLD
	lit.emission_enabled = true
	lit.emission = GOLD
	bulb.material_override = lit
	bulb.position = at
	$Built.add_child(bulb)


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
