class_name ApartmentTower
extends Node3D

## The "Las Palomas" apartment building (docs/diseno/edificio.md, step 1): a real 30-floor tower on its lot in the city,
## with the front to +Z. Only two floors are played: the lobby (the glass front door, Don Evaristo's counter with the key
## board, the mailboxes, an armchair and a plastic plant) and floor 30 (the hallway with 30A, 30B, 30C, the fire stairs
## and the elevator, and 30B: living room with its big window and balcony, kitchen, bedroom, bathroom and a locked
## study). Floors 1 to 29 are only windows outside. The front door, 30B, its study and 30C are locked; 30A and the
## fire stairs are shut for good, so the elevator (TowerElevator, step 2) is the way up; what doesn't fit in it goes down on the hanging
## scaffold (HangingScaffold, step 3) at the balcony, and what falls from up there is lost and a fine. The ornaments of 30B break,
## each one a fine. Every number here is (propuesta).

## Something fell from up high in front of the building (Don Evaristo will see it).
signal something_fell(body: Node3D)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const MANAGER_SCENE := preload("res://scenes/npc/concierge.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## The six stories the building can be suspected of (edificio.md, "Las historias"): SUSPECT_<id> and CLUE_SUSPECT_<id>.
const SUSPICION_POOL := ["stolen_aquarium", "floor_31", "carrier_pigeons", "spy_telescope", "smuggling_piano",
	"tenant_of_twenty"]
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_APARTMENTS_TIP_B", "BRIEF_TIP_C", "BRIEF_APARTMENTS_TIP_D",
	"BRIEF_APARTMENTS_TIP_E"]
## The playable stories: what the comisario says when the cops get it right, what to take, what hides where the seed
## says (with half its height and whether it's heavy), the extras' checklist lines and the story's own rig.
const STORIES := {
	"stolen_aquarium": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_STOLEN_AQUARIUM_B", "BRIEF_STOLEN_AQUARIUM_C", "BRIEF_STOLEN_AQUARIUM_D"],
		"find": "OBJ_FIND_STOLEN_AQUARIUM",
		"hidden": [preload("res://scenes/props/fishing_net.tscn"), preload("res://scenes/props/aquarium_ticket.tscn")],
		"half_heights": [0.02, 0.005],
		"heavy": [false, false],
		"extra_keys": ["OBJ_EXTRA_FISHING_NET", "OBJ_EXTRA_AQUARIUM_TICKET"],
		"rig": preload("res://scripts/case/apartments/stolen_aquarium_rig.gd"),
	},
	"smuggling_piano": {
		"briefing": ["BRIEF_RIGHT", "BRIEF_SMUGGLING_PIANO_B", "BRIEF_SMUGGLING_PIANO_C", "BRIEF_SMUGGLING_PIANO_D"],
		"find": "OBJ_FIND_SMUGGLING_PIANO",
		"hidden": [preload("res://scenes/props/piano_sheet.tscn"), preload("res://scenes/props/gold_ingot.tscn")],
		"half_heights": [0.005, 0.035],
		"heavy": [false, true],
		"extra_keys": ["OBJ_EXTRA_PIANO_SHEET", "OBJ_EXTRA_GOLD_INGOT"],
		"rig": preload("res://scripts/case/apartments/smuggling_piano_rig.gd"),
	},
}
const ORNAMENT_SCENES: Array[PackedScene] = [
	preload("res://scenes/props/ornament_vase.tscn"), preload("res://scenes/props/ornament_figurine.tscn"),
	preload("res://scenes/props/ornament_ballerina.tscn"),
]
const ORNAMENT_HALF_HEIGHTS: Array[float] = [0.13, 0.085, 0.105]
const HALF_X := 11.0
const HALF_Z := 8.0
## One storey: floor n has its floor at n * STOREY.
const STOREY := 3.2
const FLOORS := 30
const ROOM_HEIGHT := STOREY - PlaceBuilder.SLAB
const LOBBY_Y := 0.06
const TOP_Y := FLOORS * STOREY
const ROOF_Y := TOP_Y + STOREY
## The elevator shaft, the same on every floor: x from -SHAFT_HALF to SHAFT_HALF, z from SHAFT_BACK to CORE_Z.
const SHAFT_HALF := 1.0
const SHAFT_BACK := -6.0
## The wall across the building behind the lobby and in front of floor 30's back flats.
const CORE_Z := -4.0
const STAIRS_DOOR_X := 2.5
## The wall between the fire stairs and 30A.
const STAIRS_WALL_X := 4.5
## Floor 30: the hallway runs west to east between CORE_Z and HALL_FRONT.
const HALL_FRONT := -1.6
const FLAT_A_DOOR_X := 7.5
const FLAT_C_DOOR_X := -6.0
const FLAT_B_DOOR_X := 2.0
## 30B: kitchen and bathroom west of LIVING_WEST, behind BEDROOM_Z; the bedroom in front of them; the study in the
## living room's back east corner.
const LIVING_WEST := -3.0
const BATH_EAST := -7.0
const BEDROOM_Z := 3.2
const STUDY_WEST := 7.0
const STUDY_FRONT := 3.0
const STUDY_DOOR_X := 9.0
const BALCONY_DOOR_X := 4.0
const BALCONY_DEPTH := 1.6
const RAIL_HEIGHT := 1.1
## The hanging scaffold: the middle of its deck along the front, how far out from the balcony, and the crane's arms
## on the roof that hold its cables.
const SCAFFOLD_X := 6.5
const SCAFFOLD_GAP := 0.1
const SCAFFOLD_Z := HALF_Z + BALCONY_DEPTH + SCAFFOLD_GAP + HangingScaffold.SIZE.z / 2
const CRANE_Y := ROOF_Y + 1.8
## Don Evaristo's round with his broom across the lobby, back and forth, and where he takes the elevator to the 12th.
const MANAGER_ROUTE: Array[Vector3] = [
	Vector3(-6.0, LOBBY_Y, 5.2), Vector3(-2.0, LOBBY_Y, 2.0), Vector3(3.0, LOBBY_Y, 2.0), Vector3(8.5, LOBBY_Y, 1.0),
]
const MANAGER_ELEVATOR := Vector3(0.0, LOBBY_Y, CORE_Z + 0.9)
## Doña Pepa at her door (30A), watching the hallway, and how far down it a lap with Cuqui goes.
const PEPA_AT := Vector3(FLAT_A_DOOR_X, TOP_Y, CORE_Z + 0.5)
## The key board on Don Evaristo's counter: its drawer has the key to 30B and its study.
const KEY_BOARD_ON := Vector3(-6.9, LOBBY_Y + 1.1, 3.5)
## Where the clue notes can lie, one per suspicion, drawn with the seed.
const NOTE_PLACES: Array[Vector3] = [
	Vector3(4.05, TOP_Y + 0.45, 5.9), Vector3(-4.0, TOP_Y + 0.9, -1.1), Vector3(-7.0, TOP_Y + 0.5, 6.6),
	Vector3(6.0, LOBBY_Y + 0.45, 5.1), Vector3(-5.5, TOP_Y, -3.0), Vector3(-5.2, LOBBY_Y + 1.1, 3.5),
]
const LAP_FAR_X := -8.0
## The intercom board outside, beside the glass door.
const INTERCOM_AT := Vector3(1.4, LOBBY_Y + 1.3, HALF_Z + 0.1)
## Where its deck stands at the street.
const STREET_Y := 0.05
## Something falling faster than this (m/s) went over the edge: it's lost, and a fine.
const FALL_SPEED := 12.0
const DROP_FINE := 50

const COUNTER_AT := Vector3(-6.0, LOBBY_Y, 3.5)
const COUNTER_SIZE := Vector3(3.0, 1.1, 0.8)
const MAILBOXES_AT := Vector3(10.6, LOBBY_Y, 1.5)
const MAILBOXES_SIZE := Vector3(0.6, 1.4, 2.4)
const MAILBOX_SHELF := 0.7
const ARMCHAIR_AT := Vector3(6.0, LOBBY_Y, 5.0)
const PLANT_AT := Vector3(-9.5, LOBBY_Y, 6.8)
const SOFA_AT := Vector3(3.5, TOP_Y, 4.6)
const SOFA_SIZE := Vector3(2.6, 0.45, 0.9)
const COFFEE_TABLE_AT := Vector3(3.5, TOP_Y, 5.9)
const COFFEE_TABLE_SIZE := Vector3(1.4, 0.45, 0.7)
const PAINTING_AT := Vector3(-2.6, TOP_Y, 7.2)
const BED_AT := Vector3(-7.0, TOP_Y, 6.0)
const BED_SIZE := Vector3(2.0, 0.5, 2.2)
const CLOSET_AT := Vector3(-4.0, TOP_Y, 7.4)
const CLOSET_SIZE := Vector3(1.6, 2.2, 0.8)
const TUB_AT := Vector3(-9.0, TOP_Y, -0.6)
const TUB_SIZE := Vector3(1.7, 0.55, 0.8)
const TOILET_AT := Vector3(-10.4, TOP_Y, 2.2)
const FRIDGE_AT := Vector3(-6.6, TOP_Y, 2.4)
const FRIDGE_SIZE := Vector3(0.7, 1.8, 0.7)
const KITCHEN_COUNTER_AT := Vector3(-5.0, TOP_Y, -1.1)
const KITCHEN_COUNTER_SIZE := Vector3(3.0, 0.9, 0.7)
const DESK_AT := Vector3(9.0, TOP_Y, -0.6)
const DESK_SIZE := Vector3(1.6, 0.75, 0.8)
## Shelf boards for the ornaments: on the living room's east wall and the bedroom's west wall, two heights each.
const SHELVES := [
	{"at": Vector3(10.8, TOP_Y + 1.0, 5.5), "along": "z", "length": 4.4, "count": 7},
	{"at": Vector3(10.8, TOP_Y + 1.5, 5.5), "along": "z", "length": 4.4, "count": 7},
	{"at": Vector3(-10.8, TOP_Y + 1.0, 5.6), "along": "z", "length": 4.2, "count": 6},
	{"at": Vector3(-10.8, TOP_Y + 1.5, 5.6), "along": "z", "length": 4.2, "count": 6},
]
const SHELF_DEPTH := 0.3
const TABLE_ORNAMENTS := 4

const OUTSIDE := Color(0.75, 0.6, 0.85)
const GLASS := Color(0.6, 0.8, 0.9, 0.35)
const INSIDE := Color(0.93, 0.9, 0.82)
const HALL := Color(0.78, 0.72, 0.6)
const MARBLE := Color(0.88, 0.86, 0.84)
const CARPET := Color(0.55, 0.3, 0.3)
const PARQUET := Color(0.7, 0.52, 0.34)
const TILE := Color(0.82, 0.88, 0.9)
const WOOD := Color(0.55, 0.38, 0.25)
const STEEL := Color(0.7, 0.72, 0.75)
const WHITE := Color(0.95, 0.95, 0.95)
const FABRIC := Color(0.35, 0.5, 0.7)
const GREEN := Color(0.3, 0.65, 0.35)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_mailboxes", "at": MAILBOXES_AT + Vector3(0, MAILBOX_SHELF + 0.02, 0), "heavy": false},
	{"id": "behind_lobby_plant", "at": PLANT_AT + Vector3(-0.8, 0, 0.3), "heavy": false},
	{"id": "behind_sofa", "at": SOFA_AT + Vector3(0, 0.02, -0.95), "heavy": true},
	{"id": "in_closet", "at": CLOSET_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "under_bed", "at": BED_AT + Vector3(0.4, 0, 0), "heavy": false},
	{"id": "in_bathtub", "at": TUB_AT + Vector3(0, 0.05, 0), "heavy": true},
	{"id": "in_fridge", "at": FRIDGE_AT + Vector3(0, 0.92, 0), "heavy": false},
	{"id": "in_toilet_tank", "at": TOILET_AT + Vector3(-0.35, 0.45, 0), "heavy": false},
	{"id": "behind_painting", "at": PAINTING_AT + Vector3(-0.2, 0.02, 0), "heavy": false},
	{"id": "on_balcony", "at": Vector3(9.0, TOP_Y, HALF_Z + BALCONY_DEPTH / 2), "heavy": true},
	{"id": "in_study", "at": DESK_AT + Vector3(0, 0.02, 1.0), "heavy": true},
	{"id": "under_kitchen_counter", "at": KITCHEN_COUNTER_AT + Vector3(0, 0.05, 0), "heavy": false},
]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var front_door: FrontDoor
var flat_door: FrontDoor
var study_door: FrontDoor
var rental_door: FrontDoor
var city_map: CityMap
var elevator: TowerElevator
var calls: Array[ElevatorCall] = []
var ornaments: Array[Ornament] = []
var scaffold: HangingScaffold
var manager: Concierge
var pepa: NosyNeighbor
var intercom: IntercomPanel
var complaint_bar: ProgressBar
var scaffold_calls: Array[ScaffoldButton] = []
## What fell from up high, each one lost and a DROP_FINE.
var dropped: Array[Node3D] = []
var broken_goods := 0
## Money taken off the case pay for broken things and what fell (the raid's fines).
var fines: int:
	get: return raid.fines
	set(value): raid.fines = value
## The raid: the seed and the story (--story=<id>, or drawn), what's hidden where, and the story's rig.
var case_seed := 0
var story_id := ""
var raid: RaidCase
var main: Evidence
var hidden: Array[Evidence] = []
var hidden_spots: Array = []
var extras: Array[Evidence] = []
var key_board: Till
var rig: ApartmentsRig
var _build: PlaceBuilder
var _falls: Area3D
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
	_build_tower()
	_build_lobby()
	_build_hallway()
	_build_flat()
	_place_ornaments()
	front_door = _door(Vector3(0, LOBBY_Y, HALF_Z))
	flat_door = _door(Vector3(FLAT_B_DOOR_X, TOP_Y, HALL_FRONT))
	study_door = _door(Vector3(STUDY_DOOR_X, TOP_Y, STUDY_FRONT))
	rental_door = _door(Vector3(FLAT_C_DOOR_X, TOP_Y, CORE_Z))
	_place_elevator()
	_place_scaffold()
	_place_manager()
	pepa = NosyNeighbor.new()
	pepa.position = PEPA_AT
	pepa.far_x = LAP_FAR_X
	add_child(pepa)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("apartments")
	station_parking = city.transform * CityLayout.parking("station")
	raid.station_parking = station_parking
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "apartments", car)
	_place_hidden()
	rig = (STORIES[story_id].rig as Script).new()
	add_child(rig)
	rig.setup(self)
	raid.main_evidence = main
	raid.start(TIP_BRIEFING, SUSPICION_POOL, (city as City).comisario)
	_place_suspicion_clues()
	_give_clues()
	# Debug: straight to floor 30's hallway, without the ride.
	if OS.get_cmdline_user_args().has("--floor30"):
		$Cop.global_position = to_global(Vector3(-4.0, TOP_Y + 0.1, -2.8))


## The car at the lobby, its doors on both landings, the floor display over them and the call buttons.
func _place_elevator() -> void:
	var doors: Array[Node3D] = []
	for i in 2:
		var y: float = [LOBBY_Y, TOP_Y][i]
		var door := StaticBody3D.new()
		door.position = Vector3(0, y + GameScale.DOOR_HEIGHT / 2 + 0.05, CORE_Z + 0.15)
		door.set_meta("closed_x", 0.0)
		_build.shape(door, Vector3(GameScale.DOOR_WIDTH + 0.1, GameScale.DOOR_HEIGHT, 0.05))
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(GameScale.DOOR_WIDTH + 0.1, GameScale.DOOR_HEIGHT, 0.05)
		mesh.mesh = box
		mesh.material_override = _build.material(STEEL)
		door.add_child(mesh)
		add_child(door)
		var display := Label3D.new()
		display.font_size = 48
		display.pixel_size = 0.004
		display.modulate = Color(1.0, 0.4, 0.2)
		display.position = Vector3(0, y + GameScale.DOOR_HEIGHT + 0.45, CORE_Z + 0.1)
		add_child(display)
		door.set_meta("display", display)
		doors.append(door)
		var button := ElevatorCall.new()
		button.position = Vector3(-SHAFT_HALF - 0.1, y + 1.2, CORE_Z + 0.12)
		_build.shape(button, Vector3(0.15, 0.25, 0.06))
		add_child(button)
		button.stop = i
		calls.append(button)
	elevator = TowerElevator.new()
	elevator.position = Vector3(0, LOBBY_Y, (SHAFT_BACK + CORE_Z) / 2)
	add_child(elevator)
	var heights: Array[float] = [LOBBY_Y, TOP_Y]
	var floors: Array[int] = [0, FLOORS]
	elevator.setup(heights, floors, STOREY, doors)
	for button in calls:
		button.elevator = elevator
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.15, 0.25, 0.06)
		mesh.mesh = box
		mesh.material_override = _build.material(Color(0.95, 0.8, 0.3))
		button.add_child(mesh)


## The scaffold docked at 30B's balcony, the crane on the roof, a call button on the balcony and one at the street,
## and the watch over the front for what falls.
func _place_scaffold() -> void:
	var half := HangingScaffold.SIZE.x / 2 - 0.2
	var crane: Array[Vector3] = []
	for side: float in [-1.0, 1.0]:
		var x := SCAFFOLD_X + side * half
		crane.append(Vector3(x, CRANE_Y, SCAFFOLD_Z))
		_build.box(Vector3(x, ROOF_Y + 0.9, HALF_Z - 1.0), Vector3(0.2, 1.8, 0.2), STEEL.darkened(0.3))
		_build.box(Vector3(x, CRANE_Y, (HALF_Z - 1.0 + SCAFFOLD_Z) / 2), Vector3(0.2, 0.2, SCAFFOLD_Z - HALF_Z + 1.4),
			STEEL.darkened(0.3))
	scaffold = HangingScaffold.new()
	scaffold.position = Vector3(SCAFFOLD_X, TOP_Y, SCAFFOLD_Z)
	add_child(scaffold)
	scaffold.setup(STREET_Y, TOP_Y, crane)
	var places := [Vector3(SCAFFOLD_X + HangingScaffold.OPENING / 2 + 0.3, TOP_Y + RAIL_HEIGHT, HALF_Z + BALCONY_DEPTH),
		Vector3(SCAFFOLD_X + half + 0.6, 1.2, HALF_Z + 0.1)]
	for i in 2:
		var button := ScaffoldButton.new()
		button.scaffold = scaffold
		button.stop = 1 - i
		button.position = places[i]
		_build.shape(button, Vector3(0.15, 0.15, 0.12))
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.15, 0.15, 0.12)
		mesh.mesh = box
		mesh.material_override = _build.material(Color(0.95, 0.8, 0.3))
		button.add_child(mesh)
		add_child(button)
		scaffold_calls.append(button)
	var front := Area3D.new()
	front.collision_mask = 0xFFFFFFFF
	var column := CollisionShape3D.new()
	var column_box := BoxShape3D.new()
	column_box.size = Vector3(HALF_X * 2 + 4, ROOF_Y, 6.0)
	column.shape = column_box
	front.add_child(column)
	front.position = Vector3(0, ROOF_Y / 2, HALF_Z + 3.0)
	add_child(front)
	_falls = front


func _physics_process(_delta: float) -> void:
	if _falls == null:
		return
	for body: Node3D in _falls.get_overlapping_bodies():
		if body is RigidBody3D and not body is Ornament and not dropped.has(body) \
				and (body as RigidBody3D).linear_velocity.y < -FALL_SPEED:
			_drop(body)


## Something went over the edge: it breaks at the bottom and it's a fine.
func _drop(body: Node3D) -> void:
	dropped.append(body)
	fines += DROP_FINE
	if body is Evidence:
		var evidence := body as Evidence
		evidence.hit(INF)
	something_fell.emit(body)


## Don Evaristo on his round, the intercom that calls him away, and his complaint meter. A rammed door reaches him
## anywhere, and so does the crash of anything falling from the scaffold; the elevator overloaded and broken ornaments
## only if he sees them.
func _place_manager() -> void:
	intercom = IntercomPanel.new()
	intercom.position = INTERCOM_AT
	add_child(intercom)
	manager = MANAGER_SCENE.instantiate()
	manager.route = MANAGER_ROUTE
	manager.printer_spot = MANAGER_ELEVATOR
	manager.printer = intercom
	add_child(manager)
	manager.start_at(0)
	for door: FrontDoor in [front_door, flat_door, study_door, rental_door]:
		door.broken.connect(manager.door_broken)
	elevator.overloaded.connect(func(_kg: float) -> void:
		manager.saw(elevator.global_position + Vector3.UP, Concierge.SAW_OVERLOAD, "EVARISTO_OVERLOAD"))
	something_fell.connect(func(_body: Node3D) -> void: manager.heard(Concierge.HEARD_FALL, "EVARISTO_FALL"))
	for ornament in ornaments:
		ornament.broken.connect(func(at: Vector3) -> void: manager.saw(at, FloorBoss.SAW_BREAK, "EVARISTO_ORNAMENT"))
	manager.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER_APARTMENTS"))
	key_board = Till.new()
	key_board.position = KEY_BOARD_ON + Vector3.UP * Till.SIZE.y / 2
	key_board.key_hint = "HINT_KEY_BOARD_APARTMENTS"
	add_child(key_board)
	key_board.opened.connect(func(at: Vector3) -> void: manager.saw(at, FloorBoss.SAW_TILL))
	intercom.manager_called.connect(_on_manager_called)
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
	manager.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)


## The intercom's other button: Don Evaristo comes to the glass door, sees the warrant and lets the cops in (unless
## he's up on the 12th).
func _on_manager_called(cop: Cop) -> void:
	if manager.is_away():
		cop.show_hint("HINT_MANAGER_AWAY")
		return
	if front_door.locked:
		front_door.open_from_inside()
		cop.show_hint("HINT_MANAGER_OPENS")


## The building's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	return {
		"enter_key": "OBJ_ENTER_APARTMENTS",
		"guess_key": "OBJ_GUESS_APARTMENTS",
		"broken_key": "OBJ_BROKEN_APARTMENTS",
		"complaint_key": "OBJ_COMPLAINT_APARTMENTS",
		"door_open": not front_door.locked,
		"extras": range(extras.size()).map(func(i: int) -> Dictionary: return {"text": STORIES[story_id].extra_keys[i],
			"done": car.is_delivered(extras[i])}) if raid.story_known else [],
		"broken": broken_goods + dropped.size(),
		"complaint": manager.complaint,
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


## What Don Evaristo lets slip when asked (where the story's things are, in an order drawn from the seed), and what
## Doña Pepa saw after a walk with Cuqui: the story's own sighting, then where one of the things went.
func _give_clues() -> void:
	var order: Array = range(hidden.size())
	if case_seed % 2 == 1:
		order.reverse()
	for item: int in order:
		manager.slips.append(tr("EVARISTO_SLIP") % tr("LOC_APT_" + SPOTS[hidden_spots[item]].id))
	manager.slipped.connect(raid.add_clue)
	pepa.tips.append(tr("PEPA_TIP_" + story_id))
	pepa.tips.append(tr("PEPA_TIP_WHERE") % tr("LOC_APT_" + SPOTS[hidden_spots[case_seed % hidden.size()]].id))
	pepa.told.connect(raid.add_clue)


## A floor slab at `top` with the elevator shaft's hole.
func _slab_around_shaft(top: float, color: Color) -> void:
	_build.slab(-HALF_X, -SHAFT_HALF, -HALF_Z, HALF_Z, top, color)
	_build.slab(SHAFT_HALF, HALF_X, -HALF_Z, HALF_Z, top, color)
	_build.slab(-SHAFT_HALF, SHAFT_HALF, -HALF_Z, SHAFT_BACK, top, color)
	_build.slab(-SHAFT_HALF, SHAFT_HALF, CORE_Z, HALF_Z, top, color)


## The floor of storey `floor`.
static func floor_y(floor: int) -> float:
	return floor * STOREY


## Whether a point in the building's space is on floor 30 (or its balcony).
static func on_top_floor(at: Vector3) -> bool:
	return at.y > TOP_Y - 0.5 and at.y < ROOF_Y and absf(at.x) < HALF_X + 0.1 and at.z < HALF_Z + BALCONY_DEPTH + 0.1


func _door(at: Vector3) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = at - Vector3(GameScale.DOOR_WIDTH / 2, 0, 0)
	add_child(door)
	return door


## The outer walls all the way up, the slabs of the two played floors and the roof, the windows and balconies of the
## 29 floors nobody plays, and the sign.
func _build_tower() -> void:
	var dead_height := TOP_Y - STOREY
	for z: float in [-HALF_Z, HALF_Z]:
		_build.box(Vector3(0, STOREY + dead_height / 2, z), Vector3(HALF_X * 2, dead_height, PlaceBuilder.WALL), OUTSIDE)
	for x: float in [-HALF_X, HALF_X]:
		_build.box(Vector3(x, STOREY + dead_height / 2, 0), Vector3(PlaceBuilder.WALL, dead_height, HALF_Z * 2), OUTSIDE)
		for y0: float in [0.0, TOP_Y]:
			_build.wall_at("z", x, -HALF_Z, HALF_Z, y0, ROOM_HEIGHT, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, ROOM_HEIGHT, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, TOP_Y, ROOM_HEIGHT, [], OUTSIDE)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, LOBBY_Y, MARBLE)
	_slab_around_shaft(STOREY, OUTSIDE.darkened(0.3))
	_slab_around_shaft(TOP_Y, HALL)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF_Y, OUTSIDE.darkened(0.35))
	for floor in range(1, FLOORS):
		var y := floor_y(floor) + 1.6
		_build.mesh_box(Vector3(0, y, HALF_Z + 0.09), Vector3(HALF_X * 2 - 2, 1.4, 0.04), GLASS.darkened(0.3))
		_build.mesh_box(Vector3(0, floor_y(floor) + 0.05, HALF_Z + 0.6), Vector3(6.0, 0.1, 1.2), OUTSIDE.darkened(0.2))
		for x: float in [-HALF_X - 0.09, HALF_X + 0.09]:
			_build.mesh_box(Vector3(x, y, 0), Vector3(0.04, 1.4, HALF_Z * 2 - 2), GLASS.darkened(0.3))
		_build.mesh_box(Vector3(0, y, -HALF_Z - 0.09), Vector3(HALF_X * 2 - 2, 1.4, 0.04), GLASS.darkened(0.3))
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_APARTMENTS"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, STOREY - 0.1, HALF_Z + 0.12)
	$Built.add_child(sign_label)


## The glass front with the door, the wall across the back with the elevator and the stairs, the counter with the key
## board, the mailboxes, the armchair and the plant.
func _build_lobby() -> void:
	var y := LOBBY_Y
	_build.box(Vector3(-HALF_X / 2 - 0.3, y + ROOM_HEIGHT / 2, HALF_Z), Vector3(HALF_X - 0.6, ROOM_HEIGHT, 0.06), GLASS)
	_build.box(Vector3(HALF_X / 2 + 0.3, y + ROOM_HEIGHT / 2, HALF_Z), Vector3(HALF_X - 0.6, ROOM_HEIGHT, 0.06), GLASS)
	_build.box(Vector3(0, y + (GameScale.DOOR_HEIGHT + ROOM_HEIGHT) / 2, HALF_Z),
		Vector3(1.2, ROOM_HEIGHT - GameScale.DOOR_HEIGHT, 0.06), GLASS)
	_build_core(0.0, [0.0, STAIRS_DOOR_X], INSIDE)
	_build.open_box(COUNTER_AT, COUNTER_SIZE, "-z", WOOD)
	_build.mesh_box(Vector3(-HALF_X + 0.1, y + 1.6, COUNTER_AT.z - 0.5), Vector3(0.05, 0.8, 1.2), WOOD.darkened(0.3))
	_build.open_box(MAILBOXES_AT, MAILBOXES_SIZE, "-x", STEEL)
	_build.box(MAILBOXES_AT + Vector3(0, MAILBOX_SHELF, 0), Vector3(MAILBOXES_SIZE.x - 0.1, 0.04, MAILBOXES_SIZE.z - 0.1), STEEL)
	_build.box(ARMCHAIR_AT + Vector3(0, 0.22, 0), Vector3(1.0, 0.45, 0.9), FABRIC)
	_build.box(ARMCHAIR_AT + Vector3(0, 0.6, -0.4), Vector3(1.0, 0.8, 0.15), FABRIC)
	_build.box(PLANT_AT + Vector3(0, 0.25, 0), Vector3(0.5, 0.5, 0.5), WOOD)
	_build.mesh_box(PLANT_AT + Vector3(0, 0.95, 0), Vector3(0.8, 0.9, 0.8), GREEN)
	_build.light(Vector3(0, y + 2.6, 2.0))


## The wall at CORE_Z from y0, with the elevator's opening, the fire stairs' door and `doors`, and the shaft behind it.
## The stairs' door is a shut panel; the elevator's doors are the elevator's.
func _build_core(y0: float, doors: Array, color: Color) -> void:
	_build.wall_at("x", CORE_Z, -HALF_X, HALF_X, y0, ROOM_HEIGHT, doors, color)
	for x: float in [-SHAFT_HALF, SHAFT_HALF]:
		_build.wall_at("z", x, SHAFT_BACK, CORE_Z, y0, ROOM_HEIGHT, [], STEEL)
	_build.wall_at("x", SHAFT_BACK, -SHAFT_HALF, SHAFT_HALF, y0, ROOM_HEIGHT, [], STEEL)
	var door_y := y0 + GameScale.DOOR_HEIGHT / 2 + 0.06
	_build.box(Vector3(STAIRS_DOOR_X, door_y, CORE_Z), Vector3(GameScale.DOOR_WIDTH, GameScale.DOOR_HEIGHT, 0.1), Color.DARK_RED)


## Floor 30's hallway: the carpet, the core, the doors of 30A (Doña Pepa's, shut) and 30C (for rent, locked) and the
## wall between the hallway and 30B.
func _build_hallway() -> void:
	var y := TOP_Y
	_build.mesh_box(Vector3(0, y + 0.01, (CORE_Z + HALL_FRONT) / 2), Vector3(HALF_X * 2 - 0.4, 0.02, 2.2), CARPET)
	_build_core(y, [0.0, STAIRS_DOOR_X, FLAT_A_DOOR_X, FLAT_C_DOOR_X], HALL)
	_build.box(Vector3(FLAT_A_DOOR_X, y + GameScale.DOOR_HEIGHT / 2 + 0.06, CORE_Z),
		Vector3(GameScale.DOOR_WIDTH, GameScale.DOOR_HEIGHT, 0.1), WOOD)
	for x: float in [-SHAFT_HALF, STAIRS_WALL_X]:
		_build.wall_at("z", x, -HALF_Z, CORE_Z, y, ROOM_HEIGHT, [], HALL)
	_build.wall_at("x", HALL_FRONT, -HALF_X, HALF_X, y, ROOM_HEIGHT, [FLAT_B_DOOR_X], HALL)
	for door: Array in [["30A", FLAT_A_DOOR_X, CORE_Z], ["30B", FLAT_B_DOOR_X, HALL_FRONT], ["30C", FLAT_C_DOOR_X, CORE_Z]]:
		var label := Label3D.new()
		label.text = door[0]
		label.font_size = 48
		label.pixel_size = 0.005
		label.position = Vector3(door[1], y + GameScale.DOOR_HEIGHT + 0.2, door[2] + (0.1 if door[2] == CORE_Z else -0.1))
		label.rotation.y = 0.0 if door[2] == CORE_Z else PI
		$Built.add_child(label)
	var rent := Label3D.new()
	rent.text = "APT_FOR_RENT"
	rent.font_size = 32
	rent.pixel_size = 0.005
	rent.position = Vector3(FLAT_C_DOOR_X, y + 1.5, CORE_Z + 0.12)
	$Built.add_child(rent)
	_build.light(Vector3(-4.0, y + 2.6, -2.8))
	_build.light(Vector3(5.0, y + 2.6, -2.8))


## 30B: the walls between its rooms, the big window with the balcony, and its furniture.
func _build_flat() -> void:
	var y := TOP_Y
	_build.wall_at("z", LIVING_WEST, HALL_FRONT, HALF_Z, y, ROOM_HEIGHT, [0.8, 5.6], INSIDE)
	_build.wall_at("z", BATH_EAST, HALL_FRONT, BEDROOM_Z, y, ROOM_HEIGHT, [], INSIDE)
	_build.wall_at("x", BEDROOM_Z, -HALF_X, LIVING_WEST, y, ROOM_HEIGHT, [-9.0], INSIDE)
	_build.wall_at("z", STUDY_WEST, HALL_FRONT, STUDY_FRONT, y, ROOM_HEIGHT, [], INSIDE)
	_build.wall_at("x", STUDY_FRONT, STUDY_WEST, HALF_X, y, ROOM_HEIGHT, [STUDY_DOOR_X], INSIDE)
	_build.slab(-HALF_X, LIVING_WEST, HALL_FRONT, BEDROOM_Z, y + 0.02, TILE)
	_build.slab(LIVING_WEST, HALF_X, HALL_FRONT, HALF_Z, y + 0.02, PARQUET)
	# The front: the bedroom's wall, then the big window with the balcony's door.
	_build.wall_at("x", HALF_Z, -HALF_X, LIVING_WEST, y, ROOM_HEIGHT, [], OUTSIDE)
	var glass_y := y + ROOM_HEIGHT / 2
	var west := BALCONY_DOOR_X - GameScale.DOOR_WIDTH / 2
	var east := BALCONY_DOOR_X + GameScale.DOOR_WIDTH / 2
	_build.box(Vector3((LIVING_WEST + west) / 2, glass_y, HALF_Z), Vector3(west - LIVING_WEST, ROOM_HEIGHT, 0.06), GLASS)
	_build.box(Vector3((east + HALF_X) / 2, glass_y, HALF_Z), Vector3(HALF_X - east, ROOM_HEIGHT, 0.06), GLASS)
	_build.box(Vector3(BALCONY_DOOR_X, y + (GameScale.DOOR_HEIGHT + ROOM_HEIGHT) / 2, HALF_Z),
		Vector3(GameScale.DOOR_WIDTH, ROOM_HEIGHT - GameScale.DOOR_HEIGHT, 0.06), GLASS)
	_build.slab(LIVING_WEST, HALF_X, HALF_Z, HALF_Z + BALCONY_DEPTH, y, OUTSIDE.darkened(0.2))
	var rail_y := y + RAIL_HEIGHT / 2
	# The front rail has a gap where the scaffold docks.
	var gap := [SCAFFOLD_X - HangingScaffold.OPENING / 2, SCAFFOLD_X + HangingScaffold.OPENING / 2]
	for span: Array in [[LIVING_WEST, gap[0]], [gap[1], HALF_X]]:
		_build.box(Vector3((span[0] + span[1]) / 2, rail_y, HALF_Z + BALCONY_DEPTH), Vector3(span[1] - span[0], RAIL_HEIGHT, 0.06), STEEL)
	for x: float in [LIVING_WEST, HALF_X]:
		_build.box(Vector3(x, rail_y, HALF_Z + BALCONY_DEPTH / 2), Vector3(0.06, RAIL_HEIGHT, BALCONY_DEPTH), STEEL)
	# Living room.
	_build.box(SOFA_AT + Vector3(0, SOFA_SIZE.y / 2, 0), SOFA_SIZE, FABRIC)
	_build.box(SOFA_AT + Vector3(0, 0.7, -0.38), Vector3(SOFA_SIZE.x, 0.6, 0.15), FABRIC)
	_build.box(COFFEE_TABLE_AT + Vector3(0, COFFEE_TABLE_SIZE.y / 2, 0), COFFEE_TABLE_SIZE, WOOD)
	_build.box(PAINTING_AT + Vector3(0, 0.6, 0), Vector3(0.06, 1.2, 1.2), Color(0.9, 0.7, 0.3))
	for shelf: Dictionary in SHELVES:
		_build.box(shelf.at, Vector3(SHELF_DEPTH, 0.04, shelf.length), WOOD)
	# Bedroom.
	_build.legs(BED_AT, Vector2(BED_SIZE.x, BED_SIZE.z), 0.3, WOOD)
	_build.box(BED_AT + Vector3(0, 0.4, 0), Vector3(BED_SIZE.x, 0.2, BED_SIZE.z), WHITE)
	_build.open_box(CLOSET_AT, CLOSET_SIZE, "-z", WOOD)
	# Bathroom and kitchen.
	_build.open_box(TUB_AT, TUB_SIZE, "top", WHITE)
	_build.box(TOILET_AT + Vector3(0, 0.2, 0), Vector3(0.45, 0.4, 0.6), WHITE)
	_build.open_box(TOILET_AT + Vector3(-0.35, 0.4, 0), Vector3(0.3, 0.4, 0.5), "top", WHITE)
	_build.open_box(FRIDGE_AT, FRIDGE_SIZE, "+x", WHITE)
	_build.box(FRIDGE_AT + Vector3(0, 0.9, 0), Vector3(FRIDGE_SIZE.x - 0.1, 0.04, FRIDGE_SIZE.z - 0.1), WHITE)
	_build.open_box(KITCHEN_COUNTER_AT, KITCHEN_COUNTER_SIZE, "+z", STEEL)
	# The locked study.
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.03, 0), Vector3(DESK_SIZE.x, 0.06, DESK_SIZE.z), WOOD)
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.06, WOOD)
	for at: Vector3 in [Vector3(4.0, y + 2.6, 4.0), Vector3(-7.0, y + 2.6, 5.5), Vector3(-7.0, y + 2.6, 0.8), Vector3(9.0, y + 2.6, 0.7)]:
		_build.light(at)


## The ornaments of 30B on the shelves and the coffee table: each one that breaks is a fine.
func _place_ornaments() -> void:
	var places: Array[Vector3] = []
	for shelf: Dictionary in SHELVES:
		var count: int = shelf.count
		for i in count:
			var offset: float = (i - (count - 1) / 2.0) * (shelf.length - 0.3) / (count - 1)
			places.append((shelf.at as Vector3) + Vector3(0, 0.02, offset))
	for i in TABLE_ORNAMENTS:
		places.append(COFFEE_TABLE_AT + Vector3(-0.45 + i * 0.3, COFFEE_TABLE_SIZE.y, 0))
	for i in places.size():
		var kind := i % ORNAMENT_SCENES.size()
		var ornament: Ornament = ORNAMENT_SCENES[kind].instantiate()
		ornament.position = places[i] + Vector3.UP * (ORNAMENT_HALF_HEIGHTS[kind] + 0.005)
		add_child(ornament)
		ornament.broken.connect(_on_broken)
		ornaments.append(ornament)


func _on_broken(_at: Vector3) -> void:
	broken_goods += 1
	fines += Ornament.FINE
