class_name CatMansion
extends CrimeScenePlace

## The Monedero mansion (escena-gato.md, step 1, decision 260), on its lot with the front to +Z: the front garden with
## the fountain, the golden railings and the gate, and the front door with the cat flap beside it. Inside, the hall in
## the middle with the stairs and Duquesa's portrait; west of it the kitchen (fridge, the cans of tuna, the jar of cat
## biscuits, the teapot) with the laundry room behind it (the litter tray, the laundry basket, the washing machine and
## the dumbwaiter's hatch in the wall between them); behind the hall the guest room with the six nephews' suitcases;
## east of it the drawing room (Duquesa's velvet armchair, the piano with the music box, the parrot's cage). Eight
## porcelain vases stand on pedestals around the house. In the drawing room, the six nephews alike in a row (step 2)
## and Don Plumas on his cage's stand; in the hall, Señora Ofelia. The cats and the case come in later steps.
## Every number here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(30, 26)
const HALF_X := 15.0
const BACK_Z := -13.0
## The front wall; the garden runs from it to the lot's edge.
const FRONT_Z := 5.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The hall's side walls: the kitchen and the laundry are west of WEST_X, the drawing room east of EAST_X.
const WEST_X := -5.0
const EAST_X := 5.0
## The wall between the hall and the guest room.
const HALL_Z := -1.0
## The wall between the kitchen (front) and the laundry (back).
const KITCHEN_Z := -3.0
const DOOR_FRONT_X := 0.0
const DOOR_SIDE_Z := 3.6
const DOOR_GUEST_X := 0.0
const DOOR_LAUNDRY_X := -12.0
## The cat flap, low in the front wall east of the door.
const CAT_FLAP_AT := Vector3(2.2, 0.2, FRONT_Z)
const CAT_FLAP_SIZE := Vector2(0.35, 0.35)
## The garden: the fountain, the railings along the lot's front edge and the gate in them.
const FOUNTAIN_AT := Vector3(-8.0, 0, 9.0)
const RAILING_Z := 12.7
const GATE_HALF := 2.0
## The hall: the stairs up against its east wall (only for the look) and Duquesa's portrait over the guest room door.
const STAIRS_AT := Vector3(3.8, 0, 2.8)
const PORTRAIT_AT := Vector3(-2.8, 1.6, HALL_Z + 0.12)
const PORTRAIT_SIZE := Vector2(1.1, 1.3)
## Where the transport crate waits (step 3), by the front door.
const CRATE_AT := Vector3(-2.5, 0, 3.8)
## The kitchen: the counter along its front wall, the fridge, the shelf with the cans of tuna, the jar of cat
## biscuits and the teapot on the counter, and the table in its middle.
const COUNTER_AT := Vector3(-10.0, 0, FRONT_Z - 0.4)
const COUNTER_SIZE := Vector3(5.0, 0.9, 0.7)
const FRIDGE_AT := Vector3(-14.4, 0, 3.6)
const TUNA_AT: Array[Vector3] = [Vector3(-12.0, 0.98, 4.65), Vector3(-11.7, 0.98, 4.65), Vector3(-11.4, 0.98, 4.65)]
const BISCUITS_AT := Vector3(-9.0, 0.9, FRONT_Z - 0.4)
const TEAPOT_AT := Vector3(-8.0, 0.9, FRONT_Z - 0.4)
const KITCHEN_TABLE_AT := Vector3(-10.0, 0, 0.5)
## The laundry: the washing machine, the laundry basket, the litter tray and the dumbwaiter's hatch in the kitchen
## wall.
const WASHER_AT := Vector3(-14.4, 0, -11.5)
const BASKET_AT := Vector3(-12.5, 0, -12.2)
const LITTER_AT := Vector3(-7.0, 0, -11.8)
const LITTER_SIZE := Vector3(0.8, 0.15, 0.6)
## The clothesline across the laundry, with the shirts hanging.
const LINE_Z := -8.0
const DUMBWAITER_AT := Vector3(-8.0, 1.0, KITCHEN_Z)
## The guest room: two beds against its back wall and the six suitcases in a row in front of them, numbered from 1.
const BEDS_AT: Array[Vector3] = [Vector3(-2.4, 0, -11.0), Vector3(2.4, 0, -11.0)]
const SUITCASES: Array[Vector3] = [
	Vector3(-3.75, 0, -7.0), Vector3(-2.25, 0, -7.0), Vector3(-0.75, 0, -7.0), Vector3(0.75, 0, -7.0),
	Vector3(2.25, 0, -7.0), Vector3(3.75, 0, -7.0),
]
const SUITCASE_SIZE := Vector3(0.9, 0.35, 0.6)
## The drawing room: Duquesa's velvet armchair, the piano with the music box on it and the parrot's cage on its stand.
const ARMCHAIR_AT := Vector3(10.0, 0, -2.0)
const PIANO_AT := Vector3(13.6, 0, -9.0)
const MUSIC_BOX_AT := PIANO_AT + Vector3(-0.2, 1.05, 0)
const CAGE_AT := Vector3(13.8, 0, 3.0)
const SOFA_AT := Vector3(10.0, 0, -6.6)
const FIREPLACE_AT := Vector3(14.6, 0, -2.0)
const RUG_AT := Vector3(10.0, 0, -4.0)
## The eight vases on their pedestals (they break in step 5).
const VASES: Array[Vector3] = [
	Vector3(-4.3, 0, 0.0), Vector3(1.8, 0, -0.5), Vector3(-14.3, 0, 0.5), Vector3(6.0, 0, -12.2),
	Vector3(14.3, 0, -5.0), Vector3(6.0, 0, 4.3), Vector3(-4.3, 0, -12.2), Vector3(4.3, 0, -4.0),
]
const PEDESTAL_SIZE := Vector3(0.45, 0.9, 0.45)
## Where the people stand: the six nephews in a row down the drawing room by its west wall, facing into it, Señora
## Ofelia in the hall facing the front door, and the parrot on top of his cage's stand.
const NEPHEWS_AT: Array[Vector3] = [
	Vector3(7.2, 0, -10.0), Vector3(7.2, 0, -8.6), Vector3(7.2, 0, -7.2), Vector3(7.2, 0, -5.8), Vector3(7.2, 0, -4.4),
	Vector3(7.2, 0, -3.0),
]
const LADY_AT := Vector3(-1.2, 0, 1.6)
const PARROT_AT := CAGE_AT + Vector3(0, 1.24, 0)
## Where the five cats start, one per room, and the spots by the furniture where a cat runs to hide.
const CATS_AT: Array[Vector3] = [
	Vector3(1.0, 0, 2.0), Vector3(-8.0, 0, 1.6), Vector3(11.5, 0, -4.0), Vector3(0.0, 0, -8.0), Vector3(-10.0, 0, -8.0),
]
const CAT_COUNT := 5
## Where the culprit hid Duquesa (escena-gato.md, "Dónde está"): in his suitcase, in the dumbwaiter or in the laundry
## basket. "suitcase" means the culprit's; every suitcase can be searched.
const HIDING_SPOTS: Array[String] = ["suitcase", "dumbwaiter", "basket"]
## Where the señora puts the cops when she throws them out: the garden path, in front of the door.
const THROWN_OUT_AT := Vector3(0, 0.1, 8.0)
const CRACKERS_AT := CAGE_AT + Vector3(-0.35, 0, 0.3)
const HIDE_AT: Array[Vector3] = [
	Vector3(-10.0, 0, 0.5), Vector3(10.0, 0, -7.4), Vector3(12.4, 0, -10.4), Vector3(0.0, 0, -11.0),
	Vector3(-13.4, 0, -12.4), Vector3(3.8, 0, 0.8),
]
const FACADE := Color(0.96, 0.9, 0.78)
const ROOF_COLOR := Color(0.45, 0.22, 0.2)
const INSIDE := Color(0.95, 0.9, 0.82)
const DRAWING_WALL := Color(0.55, 0.72, 0.62)
const PARQUET := Color(0.6, 0.42, 0.26)
const TILE := Color(0.72, 0.6, 0.46)
const GOLD := Color(0.9, 0.72, 0.25)
const WOOD := Color(0.45, 0.28, 0.16)
const VELVET := Color(0.55, 0.12, 0.35)
const WHITE := Color(0.97, 0.97, 0.97)
const BLACK := Color(0.08, 0.08, 0.1)
const METAL := Color(0.6, 0.62, 0.66)
const WATER := Color(0.4, 0.7, 1.0)
const STONE := Color(0.78, 0.76, 0.72)
const GRASS := Color(0.4, 0.66, 0.3)
const GINGER := Color(0.92, 0.55, 0.2)
const SUITCASE_COLORS: Array[Color] = [
	Color(0.3, 0.45, 0.7), Color(0.75, 0.3, 0.3), Color(0.35, 0.55, 0.35), Color(0.6, 0.45, 0.25),
	Color(0.5, 0.35, 0.6), Color(0.3, 0.3, 0.32),
]

var case: CrimeSceneCase
var nephews: Array[MansionNephew] = []
var lady: MansionLady
var parrot: MansionParrot
## The five cats; cats[duchess] is the real Duquesa (drawn with the case seed).
var cats: Array[MansionCat] = []
var duchess := 0
var crate: TransportCrate
var music_box: MusicBox
var tuna_cans: Array[TunaCan] = []
## What the case is about (CrimeSceneCase's loot rows and hints): Duquesa, back in the señora's arms.
var loot := "duchess"
var loot_found := false
## Where Duquesa is locked away: a spot of HIDING_SPOTS, the suitcase as "suitcase_N" (the culprit's number).
var duchess_spot := ""
var duchess_out := false
## The searchable places, by spot (suitcase_0 to suitcase_5, dumbwaiter, basket).
var search_spots := {}
var clues: CatClues
var patience: CatPatience
var crackers: ParrotCrackers
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("cat_mansion")
	variant = "cat"
	_builder = PlaceBuilder.new(self)
	_shell()
	_garden()
	_rooms()
	_hall()
	_kitchen()
	_laundry()
	_guest_room()
	_drawing_room()
	_vases()
	_people()
	_cats()
	_search_spots()


## The case reaches the nephews (their traits are its suspects, same seed), and one of them, drawn with the seed,
## won't take off his beanie until he gets something to eat.
func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	var stubborn := absi(hash("stubborn nephew %d" % case.case_seed)) % nephews.size()
	for nephew in nephews:
		nephew.case = case
		nephew.stubborn = nephew.index == stubborn
	var hiding: String = HIDING_SPOTS[absi(hash("duchess spot %d" % case.case_seed)) % HIDING_SPOTS.size()]
	duchess_spot = "suitcase_%d" % case.plan.culprit if hiding == "suitcase" else hiding
	var spot := search_spots[duchess_spot] as Node3D
	cats[duchess].lock_in(spot.global_position)
	clues = CatClues.new()
	clues.name = "Clues"
	clues.mansion = self
	clues.case = case
	add_child(clues)
	patience = CatPatience.new()
	patience.name = "Patience"
	patience.mansion = self
	patience.case = case
	add_child(patience)
	parrot.case = case
	parrot.knows = case.plan.clues.has("witness")


## Searching a spot: Duquesa jumps out of hers, the diamond necklace turns up in its own; the others have nothing
## but junk.
func search(spot: String, cop: Cop) -> void:
	if clues and spot == clues.necklace_spot and not clues.necklace_out:
		var at := search_spots[spot] as Node3D
		var out: Vector3 = at.get_meta("out")
		clues.reveal_necklace(to_global(Vector3(at.position.x, FLOOR_TOP + 0.05, at.position.z) + out * 0.6))
		if cop:
			cop.show_hint("HINT_NECKLACE_OUT")
		return
	if spot != duchess_spot or duchess_out or not case:
		if cop:
			cop.show_hint("HINT_SEARCH_NOTHING_" + spot.get_slice("_", 0))
		return
	duchess_out = true
	var at := search_spots[spot] as Node3D
	var out: Vector3 = at.get_meta("out")
	cats[duchess].let_out(to_global(Vector3(at.position.x, FLOOR_TOP + 0.02, at.position.z) + out * 0.7))
	cats[duchess].say("CAT_MEOW")
	if cop:
		cop.show_hint("HINT_DUCHESS_OUT")


## Duquesa is back in the señora's arms: the case gets what it came for, and the señora some patience back.
func _on_duchess_home() -> void:
	loot_found = true
	if case:
		case.found_loot()
	if patience:
		patience.gain(CatPatience.DUCHESS_BACK)


func _on_wrong_cat(_cat: MansionCat) -> void:
	if patience:
		patience.lose("wrong_cat", true)


## A cop shouted (VoiceChat): the señora hears it in her house, and Don Plumas gets scared if it was close.
func shouted_by(cop: Cop) -> void:
	if patience and inside(cop.global_position):
		patience.lose("shout")
	parrot.shouted_by(cop)


func witness_offended() -> bool:
	return parrot.scared


func offend_witness() -> void:
	parrot.scare()


## The nephew by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return nephews[index] if index >= 0 and index < nephews.size() else null


## Whether a point in the world (ignoring height) is on the mansion's lot, garden included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the house (not in the garden).
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## Which room a point in the world is in: "hall", "kitchen", "laundry", "guest", "drawing", or "" outside the house.
func room(world: Vector3) -> String:
	if not inside(world):
		return ""
	var local := to_local(world)
	if local.x < WEST_X:
		return "kitchen" if local.z > KITCHEN_Z else "laundry"
	if local.x > EAST_X:
		return "drawing"
	return "hall" if local.z > HALL_Z else "guest"


## The five ginger cats loose around the house (one of them Duquesa) and the transport crate in the hall.
func _cats() -> void:
	duchess = absi(hash("mansion duchess %d" % case_seed)) % CAT_COUNT
	var spots: Array[Vector3] = []
	for spot in HIDE_AT:
		spots.append(to_global(spot + Vector3(0, FLOOR_TOP, 0)))
	for i in CAT_COUNT:
		var cat := MansionCat.new()
		cat.name = "Cat%d" % i
		cat.duchess = i == duchess
		cat.cat_name = "DUCHESS" if cat.duchess else "CAT_NAME_%d" % (i if i < duchess else i - 1)
		cat.hide_spots = spots
		cat.position = CATS_AT[i] + Vector3(0, FLOOR_TOP + 0.02, 0)
		add_child(cat)
		cats.append(cat)
	crate = TransportCrate.new()
	crate.name = "Crate"
	crate.position = CRATE_AT + Vector3(0, FLOOR_TOP + 0.01, 0)
	add_child(crate)


## Every suitcase, the dumbwaiter's hatch (from the kitchen or the laundry) and the laundry basket can be searched.
## `out` is where a cat jumps out to.
func _search_spots() -> void:
	for i in SUITCASES.size():
		_search_spot("suitcase_%d" % i, SUITCASES[i] + Vector3(0, SUITCASE_SIZE.y / 2, 0),
			SUITCASE_SIZE + Vector3.ONE * 0.04, Vector3.BACK)
	_search_spot("dumbwaiter", DUMBWAITER_AT, Vector3(0.7, 0.6, 0.25), Vector3.BACK)
	_search_spot("basket", BASKET_AT + Vector3(0, 0.3, 0), Vector3(0.74, 0.6, 0.54), Vector3.BACK)


func _search_spot(spot: String, at: Vector3, size: Vector3, out: Vector3) -> void:
	var body := LootSpot.new(size)
	body.name = "Search_" + spot
	body.spot = spot
	body.place = self
	body.position = at
	if spot.begins_with("suitcase"):
		body.prompt = "PROMPT_SEARCH_suitcase"
	body.set_meta("out", out)
	add_child(body)
	search_spots[spot] = body


## The six nephews alike (NephewTraits.draw with the case seed), Señora Ofelia in the hall and Don Plumas on his stand.
func _people() -> void:
	var traits := NephewTraits.draw(case_seed)
	for i in traits.size():
		var nephew := MansionNephew.new()
		nephew.name = "Nephew%d" % i
		nephew.traits = traits[i]
		nephew.index = i
		nephew.position = NEPHEWS_AT[i] + Vector3(0, FLOOR_TOP, 0)
		nephew.rotation.y = PI / 2
		add_child(nephew)
		nephews.append(nephew)
	lady = MansionLady.new()
	lady.name = "Lady"
	lady.got_duchess.connect(_on_duchess_home)
	lady.got_wrong_cat.connect(_on_wrong_cat)
	lady.position = LADY_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(lady)
	parrot = MansionParrot.new()
	parrot.name = "Parrot"
	parrot.position = PARROT_AT
	add_child(parrot)
	crackers = ParrotCrackers.new()
	crackers.name = "ParrotCrackers"
	crackers.parrot = parrot
	crackers.position = CRACKERS_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(crackers)


## The floors, the roof with its lights and a pitched top, and the outer walls with the front door.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, PARQUET)
	_builder.mesh_box(Vector3((WEST_X - HALF_X) / 2, FLOOR_TOP + 0.005, (KITCHEN_Z + FRONT_Z) / 2),
		Vector3(HALF_X + WEST_X - 0.2, 0.01, FRONT_Z - KITCHEN_Z - 0.2), TILE)
	_builder.mesh_box(Vector3((WEST_X - HALF_X) / 2, FLOOR_TOP + 0.005, (BACK_Z + KITCHEN_Z) / 2),
		Vector3(HALF_X + WEST_X - 0.2, 0.01, KITCHEN_Z - BACK_Z - 0.2), TILE.darkened(0.1))
	_builder.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, ROOF, INSIDE)
	var top := PrismMesh.new()
	top.size = Vector3(SIZE.x + 0.6, 2.2, FRONT_Z - BACK_Z + 0.6)
	_builder.mesh(top, Vector3(0, ROOF + 1.1, (BACK_Z + FRONT_Z) / 2), ROOF_COLOR, Vector3(0, PI / 2, 0))
	_builder.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [], FACADE)
	_builder.wall("x", FRONT_Z, -HALF_X, HALF_X, 0, [DOOR_FRONT_X], FACADE)
	_builder.wall("z", -HALF_X, BACK_Z, FRONT_Z, 0, [], FACADE)
	_builder.wall("z", HALF_X, BACK_Z, FRONT_Z, 0, [], FACADE)
	# The cat flap: a dark square low in the front wall, with its little swinging door on both faces.
	for side: float in [-1.0, 1.0]:
		_builder.mesh_box(CAT_FLAP_AT + Vector3(0, 0, side * 0.085), Vector3(CAT_FLAP_SIZE.x, CAT_FLAP_SIZE.y, 0.01),
			WOOD.darkened(0.4))
	for x: float in [-10.0, 0.0, 10.0]:
		for z: float in [-8.0, 2.0]:
			_builder.light(Vector3(x, ROOF - 0.5, z))


## The lawn, the path to the door, the fountain, and the golden railings along the front edge with the gate open.
func _garden() -> void:
	var depth := SIZE.y / 2 - FRONT_Z
	_builder.mesh_box(Vector3(0, 0.02, FRONT_Z + depth / 2), Vector3(SIZE.x, 0.04, depth), GRASS)
	_builder.mesh_box(Vector3(0, 0.03, FRONT_Z + depth / 2), Vector3(2.0, 0.04, depth), STONE)
	var basin := CylinderMesh.new()
	basin.top_radius = 1.4
	basin.bottom_radius = 1.5
	basin.height = 0.5
	_builder.mesh(basin, FOUNTAIN_AT + Vector3(0, 0.25, 0), STONE)
	var pool := CylinderMesh.new()
	pool.top_radius = 1.25
	pool.bottom_radius = 1.25
	pool.height = 0.02
	_builder.mesh(pool, FOUNTAIN_AT + Vector3(0, 0.46, 0), WATER)
	_builder.box(FOUNTAIN_AT + Vector3(0, 0.25, 0), Vector3(2.0, 0.5, 2.0), STONE)
	_builder.mesh_box(FOUNTAIN_AT + Vector3(0, 0.9, 0), Vector3(0.25, 0.9, 0.25), STONE)
	# A ginger cat statue on top: the mansion is all about the cats.
	_builder.mesh_box(FOUNTAIN_AT + Vector3(0, 1.45, 0), Vector3(0.3, 0.25, 0.45), GINGER)
	_builder.mesh_box(FOUNTAIN_AT + Vector3(0, 1.65, 0.2), Vector3(0.22, 0.2, 0.18), GINGER)
	for side: float in [-1.0, 1.0]:
		var from := GATE_HALF * side
		var to := HALF_X * side
		var middle := (from + to) / 2
		var length := absf(to - from)
		# One shape keeps everyone in; the bars are only for the look.
		_builder.shape(_builder.body(Vector3(middle, 0.6, RAILING_Z)), Vector3(length, 1.2, 0.08))
		_builder.mesh_box(Vector3(middle, 1.15, RAILING_Z), Vector3(length, 0.06, 0.06), GOLD)
		_builder.mesh_box(Vector3(middle, 0.15, RAILING_Z), Vector3(length, 0.06, 0.06), GOLD)
		var bars := int(length / 0.35)
		for i in bars:
			var x := lerpf(from, to, (i + 0.5) / bars)
			_builder.mesh_box(Vector3(x, 0.6, RAILING_Z), Vector3(0.04, 1.2, 0.04), GOLD)
		_builder.box(Vector3(from, 1.4, RAILING_Z), Vector3(0.35, 2.8, 0.35), STONE)
	# The arch over the gate with the mansion's name.
	_builder.mesh_box(Vector3(0, 2.75, RAILING_Z), Vector3(GATE_HALF * 2 + 0.35, 0.12, 0.12), GOLD)
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = "SIGN_CAT_MANSION"
	sign_label.font_size = 48
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 12
	sign_label.modulate = GOLD
	sign_label.position = Vector3(0, 3.1, RAILING_Z + 0.1)
	add_child(sign_label)


## The inner walls: the hall's sides with the doors to the kitchen and the drawing room, the hall's back with the door
## to the guest room, and the wall between the kitchen and the laundry with its door and the dumbwaiter's hatch.
func _rooms() -> void:
	_builder.wall("z", WEST_X, BACK_Z, FRONT_Z, 0, [DOOR_SIDE_Z], INSIDE)
	_builder.wall("z", EAST_X, BACK_Z, FRONT_Z, 0, [DOOR_SIDE_Z], DRAWING_WALL)
	_builder.wall("x", HALL_Z, WEST_X, EAST_X, 0, [DOOR_GUEST_X], INSIDE)
	_builder.wall("x", KITCHEN_Z, -HALF_X, WEST_X, 0, [DOOR_LAUNDRY_X], INSIDE)
	# The dumbwaiter: a little hatch in the wall, framed in wood, on both faces.
	for side: float in [-1.0, 1.0]:
		_builder.mesh_box(DUMBWAITER_AT + Vector3(0, 0, side * 0.085), Vector3(0.7, 0.6, 0.01), WOOD)


## The stairs up (only for the look: the floor above is closed), Duquesa's portrait and a sign to the drawing room.
func _hall() -> void:
	for i in 8:
		var step := Vector3(STAIRS_AT.x, 0.1 + i * 0.2, STAIRS_AT.z - i * 0.35)
		_builder.box(step, Vector3(1.4, 0.2, 0.35), WOOD)
	_frame(PORTRAIT_AT, PORTRAIT_SIZE, GINGER)
	var to_drawing := Label3D.new()
	to_drawing.name = "ToDrawing"
	to_drawing.text = "SIGN_CAT_MANSION_DRAWING"
	to_drawing.font_size = 28
	to_drawing.pixel_size = 0.01
	to_drawing.position = Vector3(EAST_X - 0.1, GameScale.DOOR_HEIGHT + 0.16, DOOR_SIDE_Z)
	to_drawing.rotation.y = -PI / 2
	add_child(to_drawing)


## A gilt frame with a canvas in it on the hall's back wall, facing the front door.
func _frame(at: Vector3, size: Vector2, canvas: Color) -> void:
	_builder.mesh_box(at, Vector3(size.x + 0.16, size.y + 0.16, 0.04), GOLD)
	_builder.mesh_box(at + Vector3(0, 0, 0.03), Vector3(size.x, size.y, 0.02), canvas)
	# Duquesa herself, a round ginger face with two ears and a pink bow.
	var face := SphereMesh.new()
	face.radius = 0.28
	face.height = 0.5
	_builder.mesh(face, at + Vector3(0, -0.05, 0.06), canvas.lightened(0.25))
	for side: float in [-1.0, 1.0]:
		_builder.mesh_box(at + Vector3(side * 0.18, 0.22, 0.06), Vector3(0.1, 0.14, 0.02), canvas.lightened(0.25))
	_builder.mesh_box(at + Vector3(0, -0.36, 0.07), Vector3(0.22, 0.08, 0.02), Color(1.0, 0.55, 0.7))


## The counter with the cans and the biscuit jar and the teapot on it, the fridge and the table.
func _kitchen() -> void:
	_builder.box(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0), COUNTER_SIZE, WHITE)
	_builder.box(FRIDGE_AT + Vector3(0, 0.95, 0), Vector3(0.8, 1.9, 0.75), METAL)
	for i in TUNA_AT.size():
		var can := TunaCan.new()
		can.name = "Tuna%d" % i
		can.position = TUNA_AT[i]
		add_child(can)
		can.feed_at = to_global(Vector3(TUNA_AT[i].x, FLOOR_TOP, COUNTER_AT.z - COUNTER_SIZE.z / 2 - 0.4))
		tuna_cans.append(can)
	var jar := CylinderMesh.new()
	jar.top_radius = 0.12
	jar.bottom_radius = 0.12
	jar.height = 0.25
	_builder.mesh(jar, BISCUITS_AT + Vector3(0, 0.125, 0), Color(0.8, 0.9, 0.95, 0.6))
	var pot := SphereMesh.new()
	pot.radius = 0.12
	pot.height = 0.2
	_builder.mesh(pot, TEAPOT_AT + Vector3(0, 0.1, 0), WHITE)
	_builder.box(KITCHEN_TABLE_AT + Vector3(0, 0.74, 0), Vector3(1.8, 0.06, 1.0), WOOD)
	_builder.legs(KITCHEN_TABLE_AT, Vector2(1.8, 1.0), 0.72, WOOD)


## The washing machine, the laundry basket, the litter tray (sand in a low box) and a sign on its wall.
func _laundry() -> void:
	_builder.box(WASHER_AT + Vector3(0, 0.45, 0), Vector3(0.7, 0.9, 0.7), WHITE)
	var porthole := CylinderMesh.new()
	porthole.top_radius = 0.2
	porthole.bottom_radius = 0.2
	porthole.height = 0.02
	_builder.mesh(porthole, WASHER_AT + Vector3(0.36, 0.5, 0), BLACK.lightened(0.3), Vector3(0, 0, PI / 2))
	_builder.open_box(BASKET_AT, Vector3(0.7, 0.55, 0.5), "top", Color(0.85, 0.72, 0.45))
	_builder.mesh_box(BASKET_AT + Vector3(0, 0.45, 0), Vector3(0.6, 0.1, 0.4), Color(0.7, 0.75, 0.9))
	_builder.open_box(LITTER_AT, LITTER_SIZE, "top", Color(0.4, 0.6, 0.8))
	_builder.mesh_box(LITTER_AT + Vector3(0, 0.12, 0), Vector3(LITTER_SIZE.x - 0.1, 0.04, LITTER_SIZE.z - 0.1),
		Color(0.95, 0.88, 0.62))
	# The clothesline from wall to wall, with the shirts and a sweater with a cat on it (the aunt knits them).
	_builder.mesh_box(Vector3(-10.0, 2.0, LINE_Z), Vector3(10.0, 0.02, 0.02), WHITE)
	var clothes: Array[Color] = [Color(0.9, 0.4, 0.4), WHITE, Color(0.85, 0.75, 0.3), Color(0.4, 0.55, 0.85)]
	for i in clothes.size():
		_builder.mesh_box(Vector3(-13.0 + i * 2.0, 1.65, LINE_Z), Vector3(0.7, 0.7, 0.03), clothes[i])
	_builder.mesh_box(Vector3(-11.0, 1.6, LINE_Z + 0.02), Vector3(0.25, 0.2, 0.01), GINGER)


## Two beds against the back wall and the nephews' six suitcases in a row, each with its number on the lid.
func _guest_room() -> void:
	for at in BEDS_AT:
		_builder.box(at + Vector3(0, 0.25, 0), Vector3(1.6, 0.5, 2.1), WOOD)
		_builder.mesh_box(at + Vector3(0, 0.55, 0.15), Vector3(1.5, 0.12, 1.7), WHITE)
		_builder.mesh_box(at + Vector3(0, 0.65, -0.8), Vector3(1.2, 0.15, 0.35), WHITE)
	for i in SUITCASES.size():
		var at := SUITCASES[i]
		_builder.box(at + Vector3(0, SUITCASE_SIZE.y / 2, 0), SUITCASE_SIZE, SUITCASE_COLORS[i])
		var number := Label3D.new()
		number.name = "Suitcase%d" % (i + 1)
		number.text = str(i + 1)
		number.font_size = 48
		number.pixel_size = 0.008
		number.position = at + Vector3(0, SUITCASE_SIZE.y + 0.01, 0)
		number.rotation.x = -PI / 2
		add_child(number)


## The rug, Duquesa's velvet armchair, the black piano with the music box on it and the parrot's cage on its stand.
func _drawing_room() -> void:
	_builder.mesh_box(RUG_AT + Vector3(0, FLOOR_TOP + 0.01, 0), Vector3(5.0, 0.02, 4.0), Color(0.75, 0.3, 0.3))
	_builder.box(ARMCHAIR_AT + Vector3(0, 0.25, 0), Vector3(1.0, 0.5, 0.9), VELVET)
	_builder.box(ARMCHAIR_AT + Vector3(0, 0.75, -0.4), Vector3(1.0, 0.9, 0.2), VELVET)
	for side: float in [-1.0, 1.0]:
		_builder.box(ARMCHAIR_AT + Vector3(side * 0.45, 0.6, 0), Vector3(0.15, 0.3, 0.9), VELVET)
	_builder.box(ARMCHAIR_AT + Vector3(0, 0.53, 0.05), Vector3(0.7, 0.06, 0.6), GOLD)
	_builder.box(PIANO_AT + Vector3(0, 0.5, 0), Vector3(1.4, 1.0, 1.8), BLACK)
	_builder.mesh_box(PIANO_AT + Vector3(-0.72, 0.78, 0), Vector3(0.05, 0.05, 1.4), WHITE)
	music_box = MusicBox.new()
	music_box.name = "MusicBox"
	music_box.position = MUSIC_BOX_AT
	add_child(music_box)
	_builder.box(CAGE_AT + Vector3(0, 0.6, 0), Vector3(0.1, 1.2, 0.1), GOLD)
	for i in 8:
		var turn := TAU * i / 8
		var bar := Vector3(cos(turn), 0, sin(turn)) * 0.3
		_builder.mesh_box(CAGE_AT + bar + Vector3(0, 1.55, 0), Vector3(0.025, 0.7, 0.025), GOLD)
	var cage_top := SphereMesh.new()
	cage_top.radius = 0.32
	cage_top.height = 0.3
	_builder.mesh(cage_top, CAGE_AT + Vector3(0, 1.9, 0), GOLD)
	_builder.mesh_box(CAGE_AT + Vector3(0, 1.22, 0), Vector3(0.62, 0.04, 0.62), GOLD)
	# The sofa facing the fireplace, a low table, and the fireplace on the east wall.
	_builder.box(SOFA_AT + Vector3(0, 0.25, 0), Vector3(2.4, 0.5, 0.9), VELVET.lightened(0.2))
	_builder.box(SOFA_AT + Vector3(0, 0.7, -0.38), Vector3(2.4, 0.5, 0.15), VELVET.lightened(0.2))
	_builder.box(RUG_AT + Vector3(0, 0.2, 0), Vector3(1.2, 0.4, 0.7), WOOD)
	_builder.box(FIREPLACE_AT + Vector3(0, 0.6, 0), Vector3(0.6, 1.2, 1.8), STONE)
	_builder.mesh_box(FIREPLACE_AT + Vector3(-0.31, 0.45, 0), Vector3(0.02, 0.6, 1.0), BLACK)
	_builder.mesh_box(FIREPLACE_AT + Vector3(-0.32, 0.3, 0), Vector3(0.02, 0.2, 0.6), Color(1.0, 0.5, 0.15))


## The eight pedestals with a white and blue porcelain vase on each.
func _vases() -> void:
	for at in VASES:
		_builder.box(at + Vector3(0, PEDESTAL_SIZE.y / 2, 0), PEDESTAL_SIZE, WHITE)
		var vase := CylinderMesh.new()
		vase.top_radius = 0.1
		vase.bottom_radius = 0.13
		vase.height = 0.45
		_builder.mesh(vase, at + Vector3(0, PEDESTAL_SIZE.y + 0.23, 0), Color(0.3, 0.45, 0.85))
		_builder.mesh_box(at + Vector3(0, PEDESTAL_SIZE.y + 0.28, 0), Vector3(0.24, 0.08, 0.24), WHITE)
