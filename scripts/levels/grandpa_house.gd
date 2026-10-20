class_name GrandpaHouse
extends Node3D

## Case 1.1 "La casa del abuelo" (docs/diseno/allanamiento.md): a two floor house of 24 x 20 m with 14 rooms.
## A hall runs south to north through the middle of both floors, with three rooms on each side of it.
## Downstairs: living, estudio and baño to the west; comedor, cocina and lavadero to the east.
## Upstairs: dormitorio chico, cuarto de costura and baño de arriba to the west; dormitorio grande,
## cuarto de juegos and altillo to the east.
## It is built from the data below when the scene loads, and the evidence goes to hiding spots drawn with the case seed.

const WALL := 0.15
const SLAB := 0.2
const HALF_X := 12.0
const HALF_Z := 10.0
## The hall is 3 m wide; the rooms on each side are split at these z values.
const HALL := 1.5
const SPLITS := [3.0, -3.0]
## The stairs climb north along the east side of the hall, from z = 0 to z = -3.75.
const STAIR_X := 1.0
const STAIR_RUN := 3.75
## The upstairs hole over the stairs is wider than them, so a cop's head doesn't hit its edge.
const HOLE_WEST := 0.2

const FLOOR_WOOD := Color(0.66, 0.44, 0.28)
const GRASS := Color(0.45, 0.72, 0.3)
const ROAD := Color(0.32, 0.33, 0.36)
const OUTSIDE := Color(1.0, 0.84, 0.55)
const INSIDE_DOWN := Color(0.62, 0.92, 0.84)
const INSIDE_UP := Color(1.0, 0.74, 0.8)
const ROOF := Color(0.86, 0.32, 0.26)
const FURNITURE := Color(0.55, 0.36, 0.62)
const WHITE := Color(0.92, 0.92, 0.88)

## [axis, fixed, from, to, level, door centers, color]. Axis "x" runs along x at z = fixed; "z" along z at x = fixed.
## The east middle doors sit at z = 1.5 so they don't open onto the foot of the stairs.
const WALLS := [
	["x", HALF_Z, -HALF_X, HALF_X, 0, [0.0], OUTSIDE],
	["x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE],
	["z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE],
	["z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE],
	["z", -HALL, -HALF_Z, HALF_Z, 0, [6.5, 0.0, -6.5], INSIDE_DOWN],
	["z", HALL, -HALF_Z, HALF_Z, 0, [6.5, 1.5, -6.5], INSIDE_DOWN],
	["x", 3.0, -HALF_X, -HALL, 0, [-7.0], INSIDE_DOWN],
	["x", -3.0, -HALF_X, -HALL, 0, [], INSIDE_DOWN],
	["x", 3.0, HALL, HALF_X, 0, [7.0], INSIDE_DOWN],
	["x", -3.0, HALL, HALF_X, 0, [7.0], INSIDE_DOWN],
	["x", HALF_Z, -HALF_X, HALF_X, 1, [], OUTSIDE],
	["x", -HALF_Z, -HALF_X, HALF_X, 1, [], OUTSIDE],
	["z", -HALF_X, -HALF_Z, HALF_Z, 1, [], OUTSIDE],
	["z", HALF_X, -HALF_Z, HALF_Z, 1, [], OUTSIDE],
	["z", -HALL, -HALF_Z, HALF_Z, 1, [6.5, 0.0, -6.5], INSIDE_UP],
	["z", HALL, -HALF_Z, HALF_Z, 1, [6.5, 1.5, -6.5], INSIDE_UP],
	["x", 3.0, -HALF_X, -HALL, 1, [], INSIDE_UP],
	["x", -3.0, -HALF_X, -HALL, 1, [], INSIDE_UP],
	["x", 3.0, HALL, HALF_X, 1, [], INSIDE_UP],
	["x", -3.0, HALL, HALF_X, 1, [], INSIDE_UP],
]

## Twelve hiding spots: where the evidence rests, and whether a heavy item (the 40 kg safe) fits there.
const SPOTS := [
	{"id": "under_sofa", "at": Vector3(-8.0, 0.0, 9.3), "heavy": false},
	{"id": "behind_picture", "at": Vector3(-11.72, 1.025, 6.5), "heavy": false},
	{"id": "in_oven", "at": Vector3(11.5, 0.05, -1.5), "heavy": false},
	{"id": "in_cupboard", "at": Vector3(5.0, 1.025, -2.6), "heavy": false},
	{"id": "under_table", "at": Vector3(7.0, 0.0, 6.5), "heavy": true},
	{"id": "in_bathtub", "at": Vector3(-10.8, 0.05, -9.2), "heavy": true},
	{"id": "under_stairs", "at": Vector3(1.0, 0.0, -3.3), "heavy": true},
	{"id": "under_desk", "at": Vector3(-9.0, 0.0, -1.0), "heavy": true},
	{"id": "in_washer", "at": Vector3(11.4, 0.05, -9.4), "heavy": true},
	{"id": "under_bed", "at": Vector3(-8.0, 2.7, 7.5), "heavy": false},
	{"id": "in_attic", "at": Vector3(8.0, 2.7, -8.5), "heavy": true},
	{"id": "in_wardrobe", "at": Vector3(11.5, 2.75, 5.0), "heavy": true},
]

## The door key hides in one of these pots by the front door.
const POTS := [Vector3(-2.5, 0.0, 10.8), Vector3(2.5, 0.0, 10.8), Vector3(4.5, 0.0, 11.6)]

const POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const CLUTTER_SCENE := preload("res://scenes/props/clutter.tscn")

## Dressers (cómodas): floor point at the middle of the front and the way the front faces (rotation around y).
const DRESSERS := [
	{"at": Vector3(-11.42, 2.7, 5.0), "turn": PI / 2},  # dormitorio chico
	{"at": Vector3(11.42, 2.7, 8.5), "turn": -PI / 2},  # dormitorio grande
	{"at": Vector3(-5.0, 0.0, 2.42), "turn": PI},  # estudio
	{"at": Vector3(-11.42, 2.7, 0.0), "turn": PI / 2},  # cuarto de costura
	{"at": Vector3(4.0, 0.0, 9.42), "turn": PI},  # comedor
]
## Chance that a drawer also holds an ornament, which breaks if the drawer is yanked out (propuesta).
const DRAWER_ORNAMENT := 0.3

## What the comisario says before the raid: an anonymous tip, since the cops have to find out the story (decision 79).
const TIP_BRIEFING: PackedStringArray = ["BRIEF_1_1_A", "BRIEF_TIP_B", "BRIEF_TIP_C", "BRIEF_TIP_D", "BRIEF_1_1_E"]

## The illegal bingo (investigacion.md): the betting book is the main evidence; the bingo cage and the safe with the
## takings are extras that need two cops. They go to hiding spots; the bingo cards go into drawers.
const BINGO := preload("res://scenes/case/bingo_story.tres")
## The turtle races (historias.md): Relámpago is the main evidence, with the betting board and trophies as extras.
const TURTLES := preload("res://scenes/case/turtle_story.tres")

const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
const CAT_SCENE := preload("res://scenes/npc/cat.tscn")
const TUPPER_SCENE := preload("res://scenes/props/tupperware.tscn")
## The vecina's house, west of the grandpa's, its window toward the front yard (propuesta).
const NEIGHBOR_AT := Vector3(-17.5, 0.0, 8.0)
## The kitchen calendar hangs on the kitchen's south wall, facing north.
const CALENDAR_AT := Vector3(9.0, 1.5, 2.91)
## Surfaces where the grandpa's notes can lie (one note per place at most).
const NOTE_PLACES := [
	Vector3(-9.0, 0.81, -1.0), Vector3(11.5, 0.92, -1.5), Vector3(11.4, 0.92, -9.4), Vector3(-7.0, 3.52, 0.0),
	Vector3(7.3, 3.5, 0.3), Vector3(-8.0, 3.32, 7.2), Vector3(7.0, 3.32, 6.6), Vector3(-2.3, 0.42, -9.5),
	Vector3(-2.3, 3.12, -9.5), Vector3(0.0, 0.01, -8.5), Vector3(-5.0, 0.01, 5.0), Vector3(10.5, 3.31, -5.0),
]
## Mud footprints start at the back of the hall; cookie crumbs start at the kitchen counter.
const FOOTPRINTS_FROM := Vector3(0.0, 0.0, -9.3)
const CRUMBS_FROM := Vector3(6.4, 0.0, -2.0)
const FOOTPRINT_STEP := 0.6
## A cop this close to a trail has seen it (propuesta).
const SEE_TRAIL := 2.5
const MUD := Color(0.36, 0.24, 0.14)

## 0 draws a new seed. Online, the host will send it to everyone.
@export var case_seed := 0
## The stories this house can tell (historias.md). One is drawn with the seed unless `story` is set or the game runs
## with --story=<id>.
const STORIES: Array[CaseStory] = [BINGO, TURTLES]

## The story this raid tells; null draws one from STORIES.
@export var story: CaseStory
## What only this story adds (see StoryRig).
var rig: StoryRig

## Spot index of each placed evidence, in story.evidence order.
var evidence_spots: Array = []
var evidence: Array[Node3D] = []
var key_pot := 0
var pots: Array[KeyPot] = []
var ornaments_total := 0
var broken_ornaments := 0
## The case flow every raid shares (RaidCase); the house's names for it stay so its rigs and tests read the same.
var raid: RaidCase
var fines: int:
	get: return raid.fines
var case_failed: bool:
	get: return raid.case_failed
var case_solved: bool:
	get: return raid.case_solved
var suspicions: Array[String]:
	get: return raid.suspicions
var wrong_marks: Array[String]:
	get: return raid.wrong_marks
var story_known: bool:
	get: return raid.story_known
var main_found: bool:
	get: return raid.main_found
var briefing: CaseBriefing:
	get: return raid.briefing
var checklist: CaseChecklist:
	get: return raid.checklist
var shift_over: bool:
	get: return raid.shift_over
var clues_found: Array[String]:
	get: return raid.clues_found
var station_parking: Transform3D:
	get: return raid.station_parking

var _materials := {}
var _drawer_ornaments := 0
var dressers: Array[Dresser] = []
## The story's small evidence, one in each of story.drawer_count drawers drawn from the seed (the bingo cards).
var drawer_evidence: Array[Evidence] = []
var clue_plan := {}
var notes: Array[ClueNote] = []
var michi: Cat
var neighbor: Neighbor
## The vecina's tupperware, in the drawer after the bingo cards' ones.
var tupperware: RigidBody3D
## Trail marks (footprints, crumbs) and the checklist line each trail gives when a cop sees it.
var trails := {}
@onready var _built: Node3D = $Built
@onready var grandpa: Grandpa = $Grandpa
@onready var car: PatrolCar = $PatrolCar
var city_map: CityMap


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	if story == null:
		story = pick_story(case_seed, OS.get_cmdline_user_args())
	rig = story.rig.new() if story.rig != null else StoryRig.new()
	raid = RaidCase.new()
	raid.case_seed = case_seed
	raid.story_id = story.id
	raid.story_briefing = story.briefing
	raid.find_key = story.find_key
	raid.car = car
	raid.solved_label = %CaseSolved
	raid.failed_label = %CaseFailed
	raid.shift_screen = $ShiftScreen
	raid.place_facts = _place_facts
	add_child(raid)
	_place_in_city()
	_build()
	_place_dressers()
	_bake_navigation()
	grandpa.complaint_changed.connect(func(value: float) -> void: %ComplaintBar.value = value)
	grandpa.lawyer_called.connect(raid.fail.bind("CASE_FAILED_LAWYER"))
	$FrontDoor.broken.connect(func() -> void: grandpa.door_broken($FrontDoor.global_position))
	var spot_heavy := SPOTS.map(func(s: Dictionary) -> bool: return s.heavy)
	var result := HidingDraw.draw(case_seed, spot_heavy, Array(story.heavy), POTS.size())
	evidence_spots = result.spots
	key_pot = result.key_pot
	pots[key_pot].has_key = true
	for i in story.evidence.size():
		var item: Node3D = story.evidence[i].instantiate()
		item.position = SPOTS[evidence_spots[i]].at + Vector3.UP * (story.half_heights[i] + 0.02)
		$Evidence.add_child(item)
		evidence.append(item)
	for place: Dictionary in OrnamentLayout.places(case_seed):
		var ornament: Ornament = OrnamentLayout.KINDS[place.kind].instantiate()
		ornament.position = place.at
		ornament.rotation.y = place.turn
		ornament.broken.connect(_on_ornament_broken)
		$Ornaments.add_child(ornament)
	ornaments_total = $Ornaments.get_child_count() + _drawer_ornaments
	rig.setup(self)
	_place_notes()
	_give_slips()
	raid.main_evidence = main_evidence()
	raid.start(TIP_BRIEFING)
	_place_suspicion_clues()
	_place_michi()
	_place_neighbor()
	_place_trails()
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup($City, "grandpa", car)


## Shows the end of shift screen with the pay and the awards, and stops everyone's controls.
func finish_shift() -> void:
	raid.finish_shift()


func _process(_delta: float) -> void:
	for line: String in trails:
		if _a_cop_sees(trails[line]):
			add_clue(line)


## What the checklist needs to know about the case right now.
func objective_facts() -> Dictionary:
	return raid.objective_facts()


## The house's own checklist facts, over the ones every raid has.
func _place_facts() -> Dictionary:
	var door: FrontDoor = $FrontDoor
	return {
		"door_open": door.is_open or door.is_broken,
		"extras": rig.extras(self) if story_known else [],
		"tupper_asked": neighbor.was_asked,
		"tupper_returned": neighbor.returned,
		"broken": broken_ornaments,
		"complaint": grandpa.complaint,
	}


## The story with that id from --story=<id> among the user args, or one drawn from the seed.
static func pick_story(case_seed: int, args: PackedStringArray) -> CaseStory:
	for arg: String in args:
		if arg.begins_with("--story="):
			for candidate: CaseStory in STORIES:
				if candidate.id == arg.trim_prefix("--story="):
					return candidate
	return STORIES[case_seed % STORIES.size()]


func _place_notes() -> void:
	clue_plan = CluePlan.draw(case_seed, NOTE_PLACES.size(), story.evidence.size(), rig.trail_item())
	for entry: Dictionary in clue_plan.notes:
		var note: ClueNote = NOTE_SCENE.instantiate()
		note.text = CluePlan.note_text(story.item_keys[entry.item], SPOTS[evidence_spots[entry.item]].id, entry.precise)
		note.position = NOTE_PLACES[entry.place] + Vector3.UP * 0.01
		note.rotation.y = entry.place * 0.7
		note.read.connect(_on_clue)
		$Evidence.add_child(note)
		notes.append(note)


## What the grandpa lets slip when asked: where each hidden item is, in an order drawn from the seed.
func _give_slips() -> void:
	var order: Array = range(story.evidence.size())
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed * 13 + 1
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for item: int in order:
		grandpa.slips.append(tr("GRANDPA_SLIP") % tr("LOC_" + SPOTS[evidence_spots[item]].id))
	grandpa.slipped.connect(_on_clue)


## Marks suspicion `index` as the cops' guess (RaidCase.mark). Returns whether it was right.
func mark(index: int) -> bool:
	return raid.mark(index)


## One clue for each suspicion, the true one too, on note places the grandpa's notes left free.
func _place_suspicion_clues() -> void:
	var spare: Array = clue_plan.spare
	for i in suspicions.size():
		var note: ClueNote = NOTE_SCENE.instantiate()
		note.text = tr("CLUE_SUSPECT_" + suspicions[i])
		note.position = NOTE_PLACES[spare[i]] + Vector3.UP * 0.01
		note.rotation.y = spare[i] * 0.9
		note.read.connect(_on_clue)
		$Evidence.add_child(note)


## Michi sleeps on top of the story's cat_item (the betting book in the bingo).
func _place_michi() -> void:
	michi = CAT_SCENE.instantiate()
	var item := story.cat_item
	michi.position = SPOTS[evidence_spots[item]].at + Vector3.UP * (story.half_heights[item] * 2 + 0.05)
	michi.rotation.y = case_seed % 4 * PI / 2
	michi.meowed.connect(grandpa.cat_upset)
	michi.tripped.connect(func(cop: Cop) -> void: grandpa.cat_upset(cop.global_position))
	$Evidence.add_child(michi)


## The vecina saw the grandpa hide one of the three items, drawn from the seed.
func _place_neighbor() -> void:
	neighbor = Neighbor.new()
	neighbor.position = NEIGHBOR_AT
	neighbor.rotation.y = PI / 2
	var where := tr("LOC_" + SPOTS[evidence_spots[case_seed % story.evidence.size()]].id)
	neighbor.clue = tr("CLUE_NEIGHBOR") % where
	neighbor.clue_speech = tr("NEIGHBOR_CLUE") % where
	neighbor.told.connect(_on_clue)
	_built.add_child(neighbor)


func _on_clue(text: String) -> void:
	add_clue(text)


## Adds a found clue to the checklist, once.
func add_clue(text: String) -> void:
	raid.add_clue(text)


## Mud footprints and the story's own trail follow the navigation path to their item; the map is ready a few frames
## after baking.
func _place_trails() -> void:
	var map := get_world_3d().navigation_map
	for i in 30:
		await get_tree().physics_frame
		if NavigationServer3D.map_get_path(map, FOOTPRINTS_FROM, CRUMBS_FROM, true).size() > 1:
			break
	var mud: int = clue_plan.footprints
	trails[tr("CLUE_FOOTPRINTS")] = trail(map, FOOTPRINTS_FROM, evidence[mud].global_position, FOOTPRINT_STEP, true, MUD)
	rig.place_trails(self, map)


## Marks every `step` meters along the path; footprints alternate left and right and point along the way.
func trail(map: RID, from: Vector3, to: Vector3, step: float, feet: bool, color: Color,
		mark_size := Vector3(0.04, 0.01, 0.04)) -> Array[Node3D]:
	var path := NavigationServer3D.map_get_path(map, from, to, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed
	var marks: Array[Node3D] = []
	var left := 0.0
	for i in range(1, path.size()):
		var a := path[i - 1]
		var b := path[i]
		var length := a.distance_to(b)
		var dir := (b - a) / maxf(length, 0.001)
		var side := dir.cross(Vector3.UP).normalized()
		while left <= length:
			var at := a + dir * left
			var mark := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(0.11, 0.004, 0.26) if feet else mark_size
			mark.mesh = box
			mark.material_override = _material(color)
			var jitter := Vector3(rng.randf_range(-0.1, 0.1), 0, rng.randf_range(-0.1, 0.1))
			mark.position = at + (side * (0.12 if marks.size() % 2 == 0 else -0.12) if feet else jitter) + Vector3.UP * 0.012
			$Evidence.add_child(mark)
			if feet:
				mark.look_at(mark.global_position + Vector3(dir.x, 0, dir.z), Vector3.UP)
			marks.append(mark)
			left += step
		left -= length
	return marks


func _a_cop_sees(marks: Array) -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		for mark: Node3D in marks:
			if (cop as Cop).global_position.distance_to(mark.global_position) < SEE_TRAIL:
				return true
	return false


func _material(color: Color) -> StandardMaterial3D:
	if not _materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.9
		_materials[color] = material
	return _materials[color]


## Dressers whose drawers hold folded clothes and, sometimes, an ornament (contents come from the case seed).
func _place_dressers() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed + 17
	var drawer_count: int = DRESSERS.size() * Dresser.DRAWERS
	var order: Array = range(drawer_count)
	for i in range(drawer_count - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	var with_card := order.slice(0, story.drawer_count)
	var with_tupper: int = order[story.drawer_count]
	var n := 0
	for place: Dictionary in DRESSERS:
		var dresser := Dresser.new()
		var fill := []
		for i in Dresser.DRAWERS:
			var items := [CLUTTER_SCENE]
			if with_card.has(n):
				items.append(story.drawer_evidence)
			elif n == with_tupper:
				items.append(TUPPER_SCENE)
			elif rng.randf() < DRAWER_ORNAMENT:
				items.append(OrnamentLayout.KINDS[rng.randi_range(0, OrnamentLayout.KINDS.size() - 1)])
			else:
				items.append(CLUTTER_SCENE)
			fill.append(items)
			n += 1
		dresser.contents = fill
		dresser.position = place.at
		dresser.rotation.y = place.turn
		_built.add_child(dresser)
		dressers.append(dresser)
		for drawer in dresser.drawers:
			drawer.ripped.connect(grandpa.saw_break)
			for item in drawer.contents:
				if item is Ornament:
					(item as Ornament).broken.connect(_on_ornament_broken)
					_drawer_ornaments += 1
				elif item is Evidence:
					drawer_evidence.append(item)
				elif item.is_in_group("tupperware"):
					tupperware = item


## The betting book, the evidence the case is about.
func main_evidence() -> Evidence:
	return evidence[0]


## The house stays at the origin and the city goes around it. The shift starts at the station: the scene puts
## the car on its spot out front and the cop by the driver's door.
func _place_in_city() -> void:
	var city: Node3D = $City
	city.transform = CityLayout.anchor("grandpa")
	raid.station_parking = city.transform * CityLayout.parking("station")


func car_at_station() -> bool:
	return raid.car_at_station()


## The grandpa walks on a navigation mesh baked from the built house when the scene loads.
func _bake_navigation() -> void:
	var nav: NavigationRegion3D = $Navigation
	NavigationServer3D.map_set_cell_size(get_world_3d().navigation_map, nav.navigation_mesh.cell_size)
	NavigationServer3D.map_set_cell_height(get_world_3d().navigation_map, nav.navigation_mesh.cell_height)
	_built.add_to_group("navigation_source")
	nav.bake_navigation_mesh(false)


func _on_ornament_broken(at: Vector3) -> void:
	grandpa.saw_break(at)
	broken_ornaments += 1
	raid.fines += Ornament.FINE
	raid.float_label("-%d" % Ornament.FINE, at, Color(1, 0.3, 0.25))


func _build() -> void:
	var up := GameScale.FLOOR_HEIGHT
	# The garden; the street in front and the rest of the town come from the city around the house.
	_box(Vector3(0, -0.1, 4), Vector3(60, 0.2, 52), GRASS)
	_box(Vector3(0, 0.01, 0), Vector3(HALF_X * 2, 0.02, HALF_Z * 2), FLOOR_WOOD)
	# Upstairs floor, with the hole over the stairs.
	var hole_east := STAIR_X + GameScale.STAIR_WIDTH / 2
	var hole_north := -STAIR_RUN
	_slab(-HALF_X, HOLE_WEST, -HALF_Z, HALF_Z, up)
	_slab(HOLE_WEST, HALF_X, 0.0, HALF_Z, up)
	_slab(HOLE_WEST, HALF_X, -HALF_Z, hole_north, up)
	_slab(hole_east, HALF_X, hole_north, 0.0, up)
	_slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, up * 2)
	# Gable roof, just for the look from outside.
	var roof := PrismMesh.new()
	roof.size = Vector3(HALF_X * 2 + 0.6, 2.2, HALF_Z * 2 + 0.6)
	_mesh(roof, Vector3(0, up * 2 + 1.1, 0), ROOF)
	for w: Array in WALLS:
		_wall(w[0], w[1], w[2], w[3], w[4], w[5], w[6])
	# Railing around the stair hole upstairs.
	_box(Vector3(HOLE_WEST, up + 0.5, hole_north / 2), Vector3(0.08, 1.0, STAIR_RUN), WHITE)
	_box(Vector3((HOLE_WEST + hole_east) / 2, up + 0.5, 0.0), Vector3(hole_east - HOLE_WEST, 1.0, 0.08), WHITE)
	_stairs()
	_furniture()
	for unit: Dictionary in OrnamentLayout.SHELVES:
		for box: Array in OrnamentLayout.shelf_boxes(unit):
			_box(box[0], box[1], FURNITURE)
	for p: Vector3 in POTS:
		var pot: KeyPot = POT_SCENE.instantiate()
		pot.position = p
		_built.add_child(pot)
		pots.append(pot)
	_lights()


## A ramp to walk on (a capsule can't climb 18 cm steps) under treads that are only for the look.
func _stairs() -> void:
	var rise := GameScale.FLOOR_HEIGHT
	var steps := roundi(rise / GameScale.STEP_HEIGHT)
	var depth := STAIR_RUN / steps
	for i in steps:
		var top := (i + 1) * GameScale.STEP_HEIGHT
		_mesh_box(Vector3(STAIR_X, top - 0.03, -(i + 0.5) * depth), Vector3(GameScale.STAIR_WIDTH, 0.06, depth), WHITE)
	var ramp := _body(Vector3(STAIR_X, rise / 2, -STAIR_RUN / 2))
	ramp.rotation.x = atan2(rise, STAIR_RUN)
	_shape(ramp, Vector3(GameScale.STAIR_WIDTH, 0.05, Vector2(STAIR_RUN, rise).length()))


func _furniture() -> void:
	var up := GameScale.FLOOR_HEIGHT
	# Living: sofa on legs against the south wall and a picture with a shelf behind it on the west wall.
	_legs(Vector3(-8.0, 0, 9.3), Vector2(2.2, 0.8), 0.3, FURNITURE)
	_box(Vector3(-8.0, 0.45, 9.3), Vector3(2.2, 0.3, 0.8), FURNITURE)
	_box(Vector3(-8.0, 0.85, 9.65), Vector3(2.2, 0.5, 0.15), FURNITURE)
	_box(Vector3(-11.72, 1.0, 6.5), Vector3(0.4, 0.05, 0.6), FURNITURE)
	_box(Vector3(-11.45, 1.35, 6.5), Vector3(0.05, 0.8, 0.9), Color(0.95, 0.75, 0.2))
	# Estudio: desk on legs.
	_legs(Vector3(-9.0, 0, -1.0), Vector2(1.6, 0.9), 0.74, FURNITURE)
	_box(Vector3(-9.0, 0.77, -1.0), Vector3(1.6, 0.06, 0.9), FURNITURE)
	# Cocina: oven open to the west, cupboard with a shelf and a counter, against the north wall.
	_open_box(Vector3(11.5, 0, -1.5), Vector3(0.8, 0.9, 0.7), "-x", WHITE)
	_open_box(Vector3(5.0, 0, -2.6), Vector3(1.2, 2.0, 0.6), "+z", FURNITURE)
	_box(Vector3(5.0, 1.0, -2.6), Vector3(1.1, 0.05, 0.55), FURNITURE)
	_box(Vector3(6.4, 0.45, -2.6), Vector3(1.2, 0.9, 0.6), WHITE)
	# Comedor: table on legs.
	_legs(Vector3(7.0, 0, 6.5), Vector2(2.0, 1.1), 0.72, FURNITURE)
	_box(Vector3(7.0, 0.75, 6.5), Vector3(2.0, 0.06, 1.1), FURNITURE)
	# Lavadero: washing machine open to the west.
	_open_box(Vector3(11.4, 0, -9.4), Vector3(0.9, 0.9, 0.9), "-x", WHITE)
	# Baño: bathtub and toilet.
	_open_box(Vector3(-10.8, 0, -9.2), Vector3(1.7, 0.6, 0.8), "top", WHITE)
	_box(Vector3(-2.3, 0.2, -9.5), Vector3(0.45, 0.4, 0.6), WHITE)
	# Dormitorios: a bed in each, wardrobe in the big one.
	_bed(Vector3(-8.0, up, 7.5))
	_bed(Vector3(7.0, up, 7.0))
	_open_box(Vector3(11.5, up, 5.0), Vector3(0.8, 2.0, 1.2), "-x", FURNITURE)
	# Cuarto de costura: sewing table. Cuarto de juegos: card table. Baño de arriba: toilet.
	_legs(Vector3(-7.0, up, 0.0), Vector2(1.2, 0.7), 0.74, FURNITURE)
	_box(Vector3(-7.0, up + 0.77, 0.0), Vector3(1.2, 0.06, 0.7), FURNITURE)
	_legs(Vector3(7.0, up, 0.0), Vector2(1.4, 1.4), 0.72, FURNITURE)
	_box(Vector3(7.0, up + 0.75, 0.0), Vector3(1.4, 0.06, 1.4), Color(0.2, 0.55, 0.3))
	_box(Vector3(-2.3, up + 0.2, -9.5), Vector3(0.45, 0.4, 0.6), WHITE)
	# Altillo: junk boxes.
	_box(Vector3(10.5, up + 0.3, -5.0), Vector3(0.8, 0.6, 0.8), Color(0.7, 0.55, 0.35))
	_box(Vector3(5.5, up + 0.4, -9.4), Vector3(1.0, 0.8, 0.8), Color(0.7, 0.55, 0.35))


func _bed(foot_center: Vector3) -> void:
	_legs(foot_center, Vector2(1.5, 2.1), 0.34, FURNITURE)
	_box(foot_center + Vector3(0, 0.37, 0), Vector3(1.5, 0.06, 2.1), FURNITURE)
	_box(foot_center + Vector3(0, 0.5, 0), Vector3(1.4, 0.2, 2.0), WHITE)
	_box(foot_center + Vector3(0, 0.6, 1.05), Vector3(1.5, 1.2, 0.08), FURNITURE)


## One light in the middle of each room and two along each hall.
func _lights() -> void:
	var up := GameScale.FLOOR_HEIGHT
	for level in 2:
		var y := level * up + 2.2
		for x: float in [-6.75, 6.75]:
			for z: float in [6.5, 0.0, -6.5]:
				_light(Vector3(x, y, z))
		for z: float in [5.0, -5.0]:
			_light(Vector3(-0.5, y, z))


func _light(at: Vector3) -> void:
	var light := OmniLight3D.new()
	light.position = at
	light.light_color = Color(1.0, 0.82, 0.6)
	light.light_energy = 0.7
	light.omni_range = 8.0
	_built.add_child(light)


func _wall(axis: String, fixed: float, from: float, to: float, level: int, doors: Array, color: Color) -> void:
	var y0 := level * GameScale.FLOOR_HEIGHT
	var height := GameScale.FLOOR_HEIGHT - SLAB
	var start := from
	# Doors must go in order along the wall, or a later piece covers an earlier door.
	var sorted_doors := doors.duplicate()
	sorted_doors.sort()
	for d: float in sorted_doors:
		var a := d - GameScale.DOOR_WIDTH / 2
		var b := d + GameScale.DOOR_WIDTH / 2
		_wall_piece(axis, fixed, start, a, y0, height, color)
		_wall_piece(axis, fixed, a, b, y0 + GameScale.DOOR_HEIGHT, height - GameScale.DOOR_HEIGHT, color)
		start = b
	_wall_piece(axis, fixed, start, to, y0, height, color)


func _wall_piece(axis: String, fixed: float, a: float, b: float, y0: float, height: float, color: Color) -> void:
	if b - a < 0.01 or height < 0.01:
		return
	var mid := (a + b) / 2
	if axis == "x":
		_box(Vector3(mid, y0 + height / 2, fixed), Vector3(b - a, height, WALL), color)
	else:
		_box(Vector3(fixed, y0 + height / 2, mid), Vector3(WALL, height, b - a), color)


## A floor slab whose top is at y = top.
func _slab(x0: float, x1: float, z0: float, z1: float, top: float) -> void:
	_box(Vector3((x0 + x1) / 2, top - SLAB / 2, (z0 + z1) / 2), Vector3(x1 - x0, SLAB, z1 - z0), FLOOR_WOOD)


## Four thin legs under a footprint, from the floor up to height.
func _legs(center: Vector3, footprint: Vector2, height: float, color: Color) -> void:
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var at := center + Vector3(sx * (footprint.x / 2 - 0.06), height / 2, sz * (footprint.y / 2 - 0.06))
			_box(at, Vector3(0.08, height, 0.08), color)


## A box open on one face ("top", "-x", "+x", "-z" or "+z"), standing on bottom_center.
func _open_box(bottom_center: Vector3, size: Vector3, open: String, color: Color) -> void:
	var t := 0.05
	var center := bottom_center + Vector3(0, size.y / 2, 0)
	var faces := {
		"bottom": [Vector3(0, -size.y / 2 + t / 2, 0), Vector3(size.x, t, size.z)],
		"top": [Vector3(0, size.y / 2 - t / 2, 0), Vector3(size.x, t, size.z)],
		"-x": [Vector3(-size.x / 2 + t / 2, 0, 0), Vector3(t, size.y, size.z)],
		"+x": [Vector3(size.x / 2 - t / 2, 0, 0), Vector3(t, size.y, size.z)],
		"-z": [Vector3(0, 0, -size.z / 2 + t / 2), Vector3(size.x, size.y, t)],
		"+z": [Vector3(0, 0, size.z / 2 - t / 2), Vector3(size.x, size.y, t)],
	}
	for face: String in faces:
		if face != open:
			_box(center + faces[face][0], faces[face][1], color)


func _box(center: Vector3, size: Vector3, color: Color) -> void:
	_shape(_body(center), size)
	_mesh_box(center, size, color)


func _body(at: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	_built.add_child(body)
	return body


func _shape(body: StaticBody3D, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)


func _mesh_box(center: Vector3, size: Vector3, color: Color) -> void:
	var box := BoxMesh.new()
	box.size = size
	_mesh(box, center, color)


func _mesh(mesh: Mesh, at: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _material(color)
	instance.position = at
	_built.add_child(instance)
