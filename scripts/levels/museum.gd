class_name Museum
extends CrimeScenePlace

## The city's museum (escena-museo.md, step 1, decision 200), on its lot with the front to +Z: steps and columns at
## the front, the hall with the ticket desk, the guards' security room on its west side (the monitors and someone's
## sandwich) and their lockers on its east side. Behind the hall, the big gallery: paintings on the walls, busts on
## pedestals, the velvet rope and the empty frame where the stolen piece hung. On the gallery's west side, the storage
## room with paintings under sheets, and the bathroom: just one, tiny, with a toilet, a sink, a mirror, the paper roll
## and the hand dryer. In the gallery, the six guards alike (step 2); in the hall, the director; on the steps, the
## living statue. The case comes in step 4.
## Every number here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(30, 26)
const HALF_X := 15.0
const BACK_Z := -13.0
## The front wall, with the steps in front of it to the lot's edge.
const FRONT_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The wall between the hall's three rooms and the gallery.
const HALL_Z := 4.0
## The hall's side walls: the security room is west of it, the lockers east.
const HALL_X := 6.0
## The wall between the gallery and the storage room and bathroom.
const GALLERY_X := -8.0
## The bathroom, in the gallery's north-west corner: x from BATHROOM_X to GALLERY_X, z from BATHROOM_Z to HALL_Z.
const BATHROOM_X := -11.0
const BATHROOM_Z := 1.0
const DOOR_FRONT_X := 0.0
const DOOR_GALLERY_X := 0.0
const DOOR_SIDE_Z := 7.0
const DOOR_STORAGE_Z := -6.0
const DOOR_BATHROOM_Z := 2.5
## Where the stolen piece hung: on the gallery's back wall, behind the velvet rope.
const EMPTY_FRAME_AT := Vector3(3.5, 1.6, BACK_Z + 0.12)
const FRAME_SIZE := Vector2(2.0, 1.4)
const ROPE_Z := BACK_Z + 1.6
const ROPE_FROM := 1.5
const ROPE_TO := 5.5
## The other paintings: where each hangs (on a wall's inside face), its size and which way it faces.
const PAINTINGS := [
	{"at": Vector3(-4.5, 1.6, BACK_Z + 0.12), "size": Vector2(1.6, 1.2), "turn": 0.0},
	{"at": Vector3(10.5, 1.6, BACK_Z + 0.12), "size": Vector2(1.4, 1.8), "turn": 0.0},
	{"at": Vector3(HALF_X - 0.12, 1.6, -8.0), "size": Vector2(1.8, 1.2), "turn": -PI / 2},
	{"at": Vector3(HALF_X - 0.12, 1.6, -2.0), "size": Vector2(1.2, 1.2), "turn": -PI / 2},
	{"at": Vector3(9.0, 1.6, HALL_Z - 0.12), "size": Vector2(1.6, 1.0), "turn": PI},
	{"at": Vector3(-4.5, 1.6, HALL_Z - 0.12), "size": Vector2(1.2, 1.5), "turn": PI},
]
## The busts on their pedestals, in the gallery's middle (the alarm's lasers run between them, MuseumAlarm).
const PEDESTALS: Array[Vector3] = [Vector3(-3, 0, -7), Vector3(1, 0, -3), Vector3(6, 0, -7), Vector3(10, 0, -3)]
const PEDESTAL_SIZE := Vector3(0.6, 1.1, 0.6)
const BENCH_AT := Vector3(3.5, 0, -0.5)
## The security room: the desk against the west wall with its three monitors, and the sandwich on a plate.
const DESK_AT := Vector3(-14.2, 0, 7.0)
const DESK_SIZE := Vector3(1.0, 0.8, 3.0)
const MONITORS := 3
const SANDWICH_AT := DESK_AT + Vector3(0.1, 0.84, -1.2)
## The guards' six lockers in a row against the east wall, numbered from 1.
const LOCKERS: Array[Vector3] = [
	Vector3(14.6, 0, 4.7), Vector3(14.6, 0, 5.6), Vector3(14.6, 0, 6.5), Vector3(14.6, 0, 7.4),
	Vector3(14.6, 0, 8.3), Vector3(14.6, 0, 9.2),
]
const LOCKER_SIZE := Vector3(0.6, 1.9, 0.85)
## The paintings under sheets in the storage room.
const STORED: Array[Vector3] = [Vector3(-14, 0, -11.5), Vector3(-12, 0, -11.5), Vector3(-14.2, 0, -8), Vector3(-10, 0, -9)]
const STORED_SIZE := Vector3(0.3, 1.5, 1.2)
## The bathroom's fittings.
const TOILET_AT := Vector3(-10.4, 0, BATHROOM_Z + 0.4)
const SINK_AT := Vector3(BATHROOM_X + 0.3, 0, 3.4)
const MIRROR_AT := Vector3(BATHROOM_X + 0.09, 1.55, 3.4)
const PAPER_AT := Vector3(BATHROOM_X + 0.1, 0.7, BATHROOM_Z + 0.5)
const DRYER_AT := Vector3(-9.0, 1.3, HALL_Z - 0.15)
const DESK_HALL_AT := Vector3(-3.5, 0, 7.5)
## The saucer of coins on the ticket desk, for the living statue's hat.
const COINS_AT := DESK_HALL_AT + Vector3(0.7, 1.0, 0)
const COINS := 3
## Where the people stand: the six guards in a row across the gallery facing the hall's door, the director in the
## hall and the living statue on the steps, facing the street.
const GUARDS_AT: Array[Vector3] = [
	Vector3(-4.5, 0, 1.5), Vector3(-1.9, 0, 1.5), Vector3(1.4, 0, 1.5), Vector3(4.0, 0, 1.5), Vector3(6.6, 0, 1.5),
	Vector3(9.2, 0, 1.5),
]
const DIRECTOR_AT := Vector3(2.0, 0, 6.5)
## The statue stands on the middle step (_front), so he's that step's height up.
const STATUE_AT := Vector3(4.5, 0.12, 11.5)
## What was stolen, drawn with the seed (escena-museo.md, pregunta 1), and where it can be hidden: among the covered
## paintings in the storage room, in the culprit's locker or behind a painting in the gallery.
const LOOTS: Array[String] = ["painting", "egg", "sword"]
const LOOT_SPOTS: Array[String] = ["storage", "locker", "painting"]
const LOOT_MODELS := {
	"painting": preload("res://assets/models/museum_painting.glb"),
	"egg": preload("res://assets/models/founder_egg.glb"),
	"sword": preload("res://assets/models/prop_sword.glb"),
}
## The painting it can be behind (one of PAINTINGS).
const HIDING_PAINTING := 1
## The roll of evidence bags, on a stool in the hall by the gallery's door.
const BAGS_AT := Vector3(-2.2, 0, 4.7)
const COLUMNS_X: Array[float] = [-6.0, -2.4, 2.4, 6.0]
const STONE := Color(0.88, 0.86, 0.8)
const WAXED := Color(0.72, 0.52, 0.34)
const INSIDE := Color(0.93, 0.9, 0.84)
const GALLERY_WALL := Color(0.62, 0.15, 0.2)
const GOLD := Color(0.9, 0.72, 0.25)
const WOOD := Color(0.5, 0.33, 0.2)
const METAL := Color(0.55, 0.58, 0.62)
const TILE := Color(0.75, 0.88, 0.92)
const PORCELAIN := Color(0.97, 0.97, 0.97)
const SHEET := Color(0.92, 0.92, 0.88)
const ROPE_RED := Color(0.7, 0.08, 0.12)
const FOGGED := Color(0.95, 0.95, 0.95)
const CARDBOARD := Color(0.65, 0.5, 0.32)
const WATER := Color(0.4, 0.7, 1.0)
const LAVENDER := Color(0.7, 0.5, 0.9)
const CANVAS_COLORS: Array[Color] = [
	Color(0.3, 0.45, 0.7), Color(0.85, 0.6, 0.3), Color(0.35, 0.6, 0.35), Color(0.75, 0.4, 0.55),
	Color(0.95, 0.85, 0.4), Color(0.45, 0.35, 0.6),
]

## The three bathroom details that are true this match (GuardTraits.bathroom): what the bathroom shows.
var bathroom_details: Array[String] = []
var dryer: HandDryer
var case: CrimeSceneCase
## What was stolen and where it is (drawn with the case seed in set_up_case), and whether the cops found it.
var loot := "painting"
var loot_spot := "storage"
var loot_found := false
## The searchable places, by spot.
var loot_spots := {}
var guards: Array[MuseumGuard] = []
var director: MuseumDirector
var statue: LivingStatue
## The case's clues (MuseumClues), once the case comes.
var clues: MuseumClues
## The lasers between the pedestals and the alarm they set off (MuseumAlarm).
var alarm: MuseumAlarm
## A cop used the toilet: the bathroom is no longer as it was last night.
var toilet_used := false
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("museum")
	variant = "museum"
	bathroom_details = GuardTraits.bathroom(case_seed)
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_rooms()
	_gallery()
	_security()
	_lockers()
	_storage()
	_bathroom()
	_hall()
	_people()
	_bags()
	_coins()
	_loot_spots()
	alarm = MuseumAlarm.new()
	alarm.name = "Alarm"
	alarm.museum = self
	add_child(alarm)


## Draws what was stolen and where it is (the locker to search is the culprit's) and tells the guards about the case;
## one of them (by the seed) won't take off his cap until he gets something to eat. Then the clues go where they go.
func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot = LOOTS[hash(["museum loot", case.case_seed]) % LOOTS.size()]
	loot_spot = LOOT_SPOTS[hash(["museum loot spot", case.case_seed]) % LOOT_SPOTS.size()]
	(loot_spots.locker as Node3D).position = _locker_door(case.plan.culprit)
	var stubborn := hash("stubborn guard %d" % case.case_seed) % guards.size()
	for guard in guards:
		guard.case = case
		guard.stubborn = guard.index == stubborn
	statue.case = case
	statue.knows = case.plan.clues.has("witness")
	clues = MuseumClues.new()
	clues.name = "Clues"
	clues.museum = self
	clues.case = case
	add_child(clues)


## Searching a spot: the stolen thing turns up in the right one; a sign of nothing in the others.
func search(spot: String, cop: Cop) -> void:
	if spot != loot_spot or loot_found or not case:
		if cop:
			cop.show_hint("HINT_SEARCH_NOTHING_" + spot)
		return
	reveal_loot()


## What was stolen comes out of its hiding spot, on the floor in front of it, and the case notes it.
func reveal_loot() -> void:
	if loot_found:
		return
	loot_found = true
	var item: Node3D = LOOT_MODELS[loot].instantiate()
	item.name = "Loot"
	add_child(item)
	var spot := loot_spots[loot_spot] as Node3D
	var out: Vector3 = spot.get_meta("out")
	item.position = Vector3(spot.position.x, FLOOR_TOP, spot.position.z) + out * 0.6
	item.rotation.y = atan2(out.x, out.z)
	if case:
		case.found_loot()


## The guard by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return guards[index] if index >= 0 and index < guards.size() else null


func witness_offended() -> bool:
	return statue.offended


func offend_witness() -> void:
	statue.offended = true


func shouted_by(cop: Cop) -> void:
	statue.shouted_by(cop)


## Whether a point in the world (ignoring height) is on the museum's lot, steps included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the building (not on the steps).
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## Whether a point in the world is in the bathroom.
func in_bathroom(world: Vector3) -> bool:
	var local := to_local(world)
	return local.x > BATHROOM_X and local.x < GALLERY_X and local.z > BATHROOM_Z and local.z < HALL_Z


## Whether a point in the world is in the gallery.
func in_gallery(world: Vector3) -> bool:
	var local := to_local(world)
	return local.x > GALLERY_X and local.x < HALF_X and local.z > BACK_Z and local.z < HALL_Z


## The six guards alike (GuardTraits.draw with the case seed), Señora Pincel in the hall and the living statue on the
## steps.
func _people() -> void:
	var traits := GuardTraits.draw(case_seed)
	for i in traits.size():
		var guard := MuseumGuard.new()
		guard.name = "Guard%d" % i
		guard.traits = traits[i]
		guard.index = i
		guard.position = GUARDS_AT[i] + Vector3(0, FLOOR_TOP, 0)
		add_child(guard)
		guards.append(guard)
	director = MuseumDirector.new()
	director.name = "Director"
	director.position = DIRECTOR_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(director)
	statue = LivingStatue.new()
	statue.name = "Statue"
	statue.position = STATUE_AT
	add_child(statue)


## The floor, the roof with its lights and the outer walls, with the front door.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, STONE)
	_builder.slab(-HALF_X - 0.2, HALF_X + 0.2, BACK_Z - 0.2, FRONT_Z + 0.2, ROOF, STONE.darkened(0.35))
	_builder.wall("x", BACK_Z, -HALF_X, HALF_X, 0, [], GALLERY_WALL)
	_builder.wall("x", FRONT_Z, -HALF_X, HALF_X, 0, [DOOR_FRONT_X], STONE)
	_builder.wall("z", -HALF_X, BACK_Z, FRONT_Z, 0, [], INSIDE)
	_builder.wall("z", HALF_X, BACK_Z, FRONT_Z, 0, [], GALLERY_WALL)
	for x: float in [-11.5, -3.0, 4.0, 11.0]:
		for z: float in [-9.0, -2.0, 7.0]:
			_builder.light(Vector3(x, ROOF - 0.5, z))


## The steps up to the door (flat enough to walk, only for the look), four columns, the pediment and the sign.
func _front() -> void:
	var depth := SIZE.y / 2 - FRONT_Z
	for i in 3:
		var z := FRONT_Z + depth * (i + 0.5) / 3
		_builder.mesh_box(Vector3(0, 0.03 * (3 - i), z), Vector3(16.0 - i * 1.5, 0.06 * (3 - i), depth / 3), STONE)
	for x in COLUMNS_X:
		_builder.box(Vector3(x, ROOF / 2, FRONT_Z + 0.8), Vector3(0.5, ROOF, 0.5), STONE)
	_builder.box(Vector3(0, ROOF + 0.1, FRONT_Z + 0.8), Vector3(13.5, 0.2, 1.2), STONE)
	var pediment := PrismMesh.new()
	pediment.size = Vector3(13.5, 1.4, 1.0)
	_builder.mesh(pediment, Vector3(0, ROOF + 0.9, FRONT_Z + 0.8), STONE)
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = "SIGN_MUSEUM"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = GOLD
	sign_label.position = Vector3(0, ROOF + 0.55, FRONT_Z + 1.35)
	add_child(sign_label)


## The inner walls: the hall's back wall with the gallery's door, its two side walls with the doors to the security
## room and the lockers, the wall to the storage room and the bathroom, and the bathroom's own two walls.
func _rooms() -> void:
	_builder.wall("x", HALL_Z, -HALF_X, HALF_X, 0, [DOOR_GALLERY_X], INSIDE)
	_builder.wall("z", -HALL_X, HALL_Z, FRONT_Z, 0, [DOOR_SIDE_Z], INSIDE)
	_builder.wall("z", HALL_X, HALL_Z, FRONT_Z, 0, [DOOR_SIDE_Z], INSIDE)
	_builder.wall("z", GALLERY_X, BACK_Z, HALL_Z, 0, [DOOR_STORAGE_Z, DOOR_BATHROOM_Z], INSIDE)
	_builder.wall("x", BATHROOM_Z, BATHROOM_X, GALLERY_X, 0, [], TILE)
	_builder.wall("z", BATHROOM_X, BATHROOM_Z, HALL_Z, 0, [], TILE)


## The waxed floor, the paintings and the empty frame, the busts on their pedestals, the velvet rope and a bench.
func _gallery() -> void:
	var width := HALF_X - GALLERY_X
	var waxed := Vector3((GALLERY_X + HALF_X) / 2, FLOOR_TOP + 0.005, (BACK_Z + HALL_Z) / 2)
	_builder.mesh_box(waxed, Vector3(width - 0.2, 0.01, HALL_Z - BACK_Z - 0.2), WAXED)
	for i in PAINTINGS.size():
		var painting: Dictionary = PAINTINGS[i]
		_frame(painting.at, painting.size, painting.turn, CANVAS_COLORS[i % CANVAS_COLORS.size()])
	_frame(EMPTY_FRAME_AT, FRAME_SIZE, 0.0, GALLERY_WALL.darkened(0.25))
	for at in PEDESTALS:
		_builder.box(at + Vector3(0, PEDESTAL_SIZE.y / 2, 0), PEDESTAL_SIZE, STONE)
		var head := SphereMesh.new()
		head.radius = 0.2
		head.height = 0.45
		_builder.mesh(head, at + Vector3(0, PEDESTAL_SIZE.y + 0.3, 0), PORCELAIN)
		_builder.mesh_box(at + Vector3(0, PEDESTAL_SIZE.y + 0.06, 0), Vector3(0.35, 0.12, 0.25), PORCELAIN)
	var posts := 3
	for i in posts:
		var x := lerpf(ROPE_FROM, ROPE_TO, float(i) / (posts - 1))
		_builder.box(Vector3(x, 0.5, ROPE_Z), Vector3(0.1, 1.0, 0.1), GOLD)
	_builder.mesh_box(Vector3((ROPE_FROM + ROPE_TO) / 2, 0.85, ROPE_Z), Vector3(ROPE_TO - ROPE_FROM, 0.06, 0.06),
		ROPE_RED)
	_builder.box(BENCH_AT + Vector3(0, 0.22, 0), Vector3(2.4, 0.44, 0.6), WOOD)


## A gilt frame with a canvas in it, hanging on a wall's face at `at`, turned to face the room.
func _frame(at: Vector3, size: Vector2, turn: float, canvas: Color) -> void:
	var facing := Basis(Vector3.UP, turn)
	var bars := [
		[Vector3(0, size.y / 2, 0), Vector3(size.x + 0.16, 0.08, 0.06)],
		[Vector3(0, -size.y / 2, 0), Vector3(size.x + 0.16, 0.08, 0.06)],
		[Vector3(size.x / 2, 0, 0), Vector3(0.08, size.y, 0.06)],
		[Vector3(-size.x / 2, 0, 0), Vector3(0.08, size.y, 0.06)],
	]
	for bar: Array in bars:
		var box_mesh := BoxMesh.new()
		box_mesh.size = bar[1]
		_builder.mesh(box_mesh, at + facing * bar[0], GOLD, Vector3(0, turn, 0))
	var canvas_mesh := BoxMesh.new()
	canvas_mesh.size = Vector3(size.x, size.y, 0.02)
	_builder.mesh(canvas_mesh, at, canvas, Vector3(0, turn, 0))


## The desk against the west wall with three monitors and a chair, and the plate where the sandwich goes.
func _security() -> void:
	_builder.box(DESK_AT + Vector3(0, DESK_SIZE.y / 2, 0), DESK_SIZE, WOOD)
	for i in MONITORS:
		var z := DESK_AT.z + (i - (MONITORS - 1) / 2.0) * 0.9
		_builder.mesh_box(Vector3(DESK_AT.x - 0.2, DESK_SIZE.y + 0.3, z), Vector3(0.1, 0.45, 0.7), METAL.darkened(0.5))
		_builder.mesh_box(Vector3(DESK_AT.x - 0.14, DESK_SIZE.y + 0.3, z), Vector3(0.02, 0.38, 0.62),
			Color(0.3, 0.55, 0.45))
	_builder.box(DESK_AT + Vector3(1.0, 0.25, 0), Vector3(0.5, 0.5, 0.5), METAL)
	var plate := CylinderMesh.new()
	plate.top_radius = 0.16
	plate.bottom_radius = 0.14
	plate.height = 0.02
	_builder.mesh(plate, SANDWICH_AT, PORCELAIN)


## The six numbered lockers against the east wall, doors to the room.
func _lockers() -> void:
	for i in LOCKERS.size():
		var at := LOCKERS[i]
		_builder.box(at + Vector3(0, LOCKER_SIZE.y / 2, 0), LOCKER_SIZE, METAL)
		var number := Label3D.new()
		number.name = "Locker%d" % (i + 1)
		number.text = str(i + 1)
		number.font_size = 48
		number.pixel_size = 0.01
		number.position = at + Vector3(-LOCKER_SIZE.x / 2 - 0.01, 1.6, 0)
		number.rotation.y = -PI / 2
		add_child(number)


## Paintings standing under white sheets in the storage room.
func _storage() -> void:
	for at in STORED:
		_builder.box(at + Vector3(0, STORED_SIZE.y / 2, 0), STORED_SIZE, SHEET)


## The tiny bathroom: tiled floor, toilet, sink with the mirror over it, the paper roll and the hand dryer. It shows
## this match's three true details (GuardTraits.DETAILS) and the opposite of the other three: the roll empty or full,
## the mirror fogged or clear, a drop hanging from the tap, a spider from the ceiling, the lavender freshener on the
## sink, and the dryer (HandDryer) that blows or not.
func _bathroom() -> void:
	var middle := Vector3((BATHROOM_X + GALLERY_X) / 2, FLOOR_TOP + 0.005, (BATHROOM_Z + HALL_Z) / 2)
	_builder.mesh_box(middle, Vector3(GALLERY_X - BATHROOM_X - 0.2, 0.01, HALL_Z - BATHROOM_Z - 0.2), TILE)
	_builder.box(TOILET_AT + Vector3(0, 0.2, 0), Vector3(0.4, 0.4, 0.55), PORCELAIN)
	_builder.mesh_box(TOILET_AT + Vector3(0, 0.6, -0.22), Vector3(0.4, 0.4, 0.15), PORCELAIN)
	_builder.box(SINK_AT + Vector3(0, 0.8, 0), Vector3(0.45, 0.15, 0.55), PORCELAIN)
	_builder.mesh_box(SINK_AT + Vector3(0, 0.4, 0), Vector3(0.12, 0.7, 0.12), PORCELAIN)
	_detail("mirror", MIRROR_AT, BoxMesh.new(), Vector3(0.02, 0.6, 0.5), FOGGED, Color(0.8, 0.9, 0.95))
	var roll := CylinderMesh.new()
	roll.top_radius = 0.06
	roll.bottom_radius = 0.06
	roll.height = 0.12
	var tube := CylinderMesh.new()
	tube.top_radius = 0.025
	tube.bottom_radius = 0.025
	tube.height = 0.12
	_detail_node("paper", tube if has_detail("paper") else roll, PAPER_AT,
		CARDBOARD if has_detail("paper") else PORCELAIN, Vector3(PI / 2, 0, 0))
	if has_detail("tap"):
		var drop := SphereMesh.new()
		drop.radius = 0.02
		drop.height = 0.05
		_detail_node("tap", drop, SINK_AT + Vector3(0.12, 0.84, 0), WATER)
	if has_detail("spider"):
		var spider := SphereMesh.new()
		spider.radius = 0.05
		spider.height = 0.08
		var at := Vector3(-9.3, ROOF - 0.9, 2.2)
		_detail_node("spider", spider, at, Color(0.08, 0.08, 0.1))
		_builder.mesh_box(at + Vector3(0, 0.4, 0), Vector3(0.005, 0.75, 0.005), Color(0.9, 0.9, 0.9))
	if has_detail("lavender"):
		var can := CylinderMesh.new()
		can.top_radius = 0.035
		can.bottom_radius = 0.035
		can.height = 0.18
		_detail_node("lavender", can, SINK_AT + Vector3(0, 0.96, -0.18), LAVENDER)
	dryer = HandDryer.new()
	dryer.name = "Dryer"
	dryer.broken = has_detail("dryer")
	dryer.position = DRYER_AT
	add_child(dryer)
	_bathroom_spot("toilet", TOILET_AT + Vector3(0, 0.3, -0.05), Vector3(0.46, 0.6, 0.66))
	_bathroom_spot("sink", SINK_AT + Vector3(0, 0.8, 0), Vector3(0.5, 0.2, 0.6))
	_builder.light(Vector3((BATHROOM_X + GALLERY_X) / 2, ROOF - 0.5, (BATHROOM_Z + HALL_Z) / 2))


func _bathroom_spot(kind: String, at: Vector3, size: Vector3) -> void:
	var spot := BathroomSpot.new(kind, size)
	spot.name = "Bathroom_" + kind
	spot.museum = self
	spot.position = at
	add_child(spot)


## A good look at the bathroom from the sink: its three true details, and the alibi clue if the toilet wasn't used.
func look_at_bathroom(cop: Cop) -> void:
	if toilet_used:
		cop.show_hint("HINT_BATHROOM_MESSED")
		return
	var shown := bathroom_details.map(func(detail: String) -> String: return tr("ALIBI_SHORT_" + detail))
	cop.show_hint(tr("HINT_BATHROOM_LOOK") % shown)
	if case:
		case.found("alibi")


## A cop used the toilet: the bathroom is as he left it, and the alibi clue is lost if nobody had looked yet.
func use_toilet(cop: Cop) -> void:
	cop.show_hint("HINT_TOILET_USED")
	toilet_used = true
	if case:
		case.ruin("alibi")


## Whether this detail is true in this match's bathroom.
func has_detail(detail: String) -> bool:
	return bathroom_details.has(detail)


## A box that looks one way if its detail is true and another if not.
func _detail(detail: String, at: Vector3, box: BoxMesh, size: Vector3, if_true: Color, if_false: Color) -> void:
	box.size = size
	_detail_node(detail, box, at, if_true if has_detail(detail) else if_false)


## A mesh named after its bathroom detail ("Detail_paper"), so the case and the tests can find it.
func _detail_node(detail: String, mesh: Mesh, at: Vector3, color: Color, turn := Vector3.ZERO) -> void:
	var instance := MeshInstance3D.new()
	instance.name = "Detail_" + detail
	instance.mesh = mesh
	instance.rotation = turn
	instance.material_override = _builder.material(color)
	instance.position = at
	add_child(instance)


## A stool with the roll of evidence bags for the clues the cops carry.
func _bags() -> void:
	_builder.box(BAGS_AT + Vector3(0, 0.25, 0), Vector3(0.5, 0.5, 0.4), WOOD)
	bags = EvidenceBags.new()
	bags.name = "EvidenceBags"
	bags.position = BAGS_AT + Vector3(0, 0.5, 0)
	add_child(bags)


## The saucer on the ticket desk with a few coins, for the statue's hat.
func _coins() -> void:
	var saucer := CylinderMesh.new()
	saucer.top_radius = 0.12
	saucer.bottom_radius = 0.1
	saucer.height = 0.004
	_builder.mesh(saucer, COINS_AT + Vector3(0, 0.002, 0), PORCELAIN)
	for i in COINS:
		var coin := StatueCoin.new()
		coin.name = "Coin%d" % i
		coin.position = COINS_AT + Vector3(-0.05 + i * 0.05, 0.03 + i * 0.01, 0)
		add_child(coin)


## The three places to search: a covered painting in the storage room, a locker's door (the culprit's, set when the
## case comes) and a painting in the gallery. `out` is the way into the room, where the stolen thing falls.
func _loot_spots() -> void:
	var stored := STORED[0]
	_loot_spot("storage", stored + Vector3(0.25, STORED_SIZE.y / 2, 0), Vector3(0.2, STORED_SIZE.y, STORED_SIZE.z),
		Vector3.RIGHT)
	_loot_spot("locker", _locker_door(0), Vector3(0.1, LOCKER_SIZE.y, LOCKER_SIZE.z), Vector3.LEFT)
	var painting: Dictionary = PAINTINGS[HIDING_PAINTING]
	_loot_spot("painting", painting.at + Vector3(0, 0, 0.05), Vector3(painting.size.x, painting.size.y, 0.1),
		Vector3.BACK)


func _loot_spot(spot: String, at: Vector3, size: Vector3, out: Vector3) -> void:
	var body := LootSpot.new(size)
	body.name = "Search_" + spot
	body.spot = spot
	body.place = self
	body.position = at
	body.set_meta("out", out)
	add_child(body)
	loot_spots[spot] = body


## Where a locker's door is, in front of it.
func _locker_door(index: int) -> Vector3:
	return LOCKERS[index] + Vector3(-LOCKER_SIZE.x / 2 - 0.06, LOCKER_SIZE.y / 2, 0)


## The ticket desk in the hall and a sign pointing to the gallery.
func _hall() -> void:
	_builder.box(DESK_HALL_AT + Vector3(0, 0.5, 0), Vector3(2.4, 1.0, 0.7), WOOD)
	var to_gallery := Label3D.new()
	to_gallery.name = "ToGallery"
	to_gallery.text = "SIGN_MUSEUM_GALLERY"
	to_gallery.font_size = 28
	to_gallery.pixel_size = 0.01
	to_gallery.position = Vector3(DOOR_GALLERY_X, GameScale.DOOR_HEIGHT + 0.16, HALL_Z + 0.1)
	add_child(to_gallery)
