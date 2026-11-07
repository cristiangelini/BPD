class_name Zoo
extends CrimeScenePlace

## The Zoológico Municipal (escena-zoo.md, step 1, decision 570): it fills block (7, -1), its front to +Z on the
## street, behind a fence with the entrance arch in the middle. Inside, by the entrance, the ticket booth, the
## ice-cream stand, the souvenir shop and the keepers' hut with its six lockers and the feeding log; in the middle the
## penguins' pool with Copito's empty ice floe behind the glass, ringed by the little train's track; west the monkey and
## the ostrich, east the reptile house and the elephant, and the duck pond with its pedal boat at the back. Each
## enclosure has a gate on the path (`gates`), shut until feeding time (step 5). The six keepers go about their work,
## two by the entrance, three by the enclosures and one at the lockers (step 2); Doña Jaula watches from in front of
## the penguins' glass and Don Pico sits on his perch by the hut. The case reaches the keepers (step 3, set_up_case).
## Every number here is (propuesta).

## The lot's floor, like its size in CityLayout.PLACES, and the fence just inside its edge.
const SIZE := Vector2(54, 54)
const FENCE := 26.5
const FENCE_HEIGHT := 2.2
const ENTRANCE_HALF := 3.0
const SIDEWALK_AT := Vector3(0, 0, 28.5)
const GROUND_TOP := 0.06
## The entrance area, in front of ENTRANCE_Z.
const ENTRANCE_Z := 14.0
const BOOTH_AT := Vector3(-7, 0, 22)
const ICE_CREAM_AT := Vector3(7, 0, 22)
## The buildings: x0, z0, width (x), depth (z); each with its door on DOORS' side and spot.
const SHOP := Rect2(13, 16, 10, 8)
const HUT := Rect2(-23, 16, 10, 8)
const REPTILES := Rect2(14, -4, 10, 12)
const BUILDING_HEIGHT := 3.2
## The keepers' six lockers along the hut's back (west) wall, the feeding log on its desk and Don Pico's perch outside.
const LOCKERS := 6
const LOCKER_X := -22.5
const LOCKER_FROM_Z := 17.2
const LOCKER_STEP := 1.1
const LOG_DESK_AT := Vector3(-17, 0, 22.6)
const PERCH_AT := Vector3(-11, 0, 19)
const TORTOISE_AT := Vector3(20, 0, 2)
## The enclosures, by animal (and the penguins): their fence, the gate's side and where along it.
const ENCLOSURES := {
	"penguins": {"rect": Rect2(-6, -2, 12, 10), "side": "-z", "at": 3.0},
	"monkey": {"rect": Rect2(-24, -6, 10, 12), "side": "+x", "at": 0.0},
	"ostrich": {"rect": Rect2(-24, -24, 10, 12), "side": "+x", "at": -18.0},
	"elephant": {"rect": Rect2(12, -24, 12, 14), "side": "-x", "at": -17.0},
}
const ANIMALS: Array[String] = ["monkey", "ostrich", "elephant"]
const GATE_WIDTH := 2.6
const ENCLOSURE_FENCE := 1.4
## In the penguins' enclosure: the glass in front (toward the entrance), the pool and Copito's ice floe.
const GLASS_Z := 8.0
const POOL := Rect2(-5, -1, 6, 5)
const ICE_AT := Vector3(3, 0, 1.5)
const TREE_AT := Vector3(-19, 0, 0)
const MUD_AT := Vector3(18, 0, -17)
## The duck pond at the back with the pedal boat on it.
const POND := Rect2(-8, -24, 16, 9)
const BOAT_AT := Vector3(2, 0, -19.5)
## The little train's track: a loop round the penguins.
const TRACK := Rect2(-10, -10, 20, 22)
const TRACK_WIDTH := 1.6
## Where the people are, and which way each keeper faces (a Y turn; the models face +Z): two by the entrance looking
## at the penguins, one at the monkey's and one at the ostrich's gate, one at the elephant's and one at the lockers;
## Doña Jaula in front of the penguins' glass facing the entrance; Don Pico on top of his perch.
const KEEPERS_AT: Array[Vector3] = [Vector3(-3, 0, 15.5), Vector3(4, 0, 16), Vector3(-11.5, 0, 2),
	Vector3(-11.5, 0, -16), Vector3(10.5, 0, -15), Vector3(-20.5, 0, 19)]
const KEEPERS_TURN: Array[float] = [PI, PI, -PI / 2, -PI / 2, PI / 2, -PI / 2]
const DIRECTOR_AT := Vector3(-2.5, 0, 10.5)
const PARROT_AT := PERCH_AT + Vector3(0, 1.84, 0)

const GRASS := Color(0.42, 0.68, 0.32)
const PATH := Color(0.82, 0.74, 0.58)
const FENCE_COLOR := Color(0.3, 0.42, 0.25)
const BARS := Color(0.45, 0.45, 0.48)
const WOOD := Color(0.55, 0.38, 0.22)
const ROOF_COLOR := Color(0.75, 0.32, 0.22)
const WALLS := Color(0.95, 0.88, 0.7)
const WATER := Color(0.3, 0.6, 0.85)
const ICE := Color(0.92, 0.97, 1.0)
const SAND := Color(0.9, 0.8, 0.55)
const MUD := Color(0.4, 0.28, 0.16)
const LEAVES := Color(0.22, 0.52, 0.22)
const STEEL := Color(0.62, 0.65, 0.7)
const RAIL := Color(0.35, 0.3, 0.28)

## The enclosures' gates, by animal: shut bodies across the gap in each fence.
var gates := {}
var case: CrimeSceneCase
var keepers: Array[ZooKeeper] = []
var director: ZooDirector
var parrot: ZooParrot
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("zoo")
	variant = "zoo"
	_builder = PlaceBuilder.new(self)
	_grounds()
	_entrance()
	_buildings()
	for kind: String in ENCLOSURES:
		_enclosure(kind)
	_penguins()
	_animals()
	_pond()
	_people()


## The case reaches the keepers (their traits are its suspects, same seed), and one of them, drawn with the seed, won't
## take off the cap until they get something to eat.
func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	var shy := absi(hash("shy keeper %d" % case.case_seed)) % keepers.size()
	for keeper in keepers:
		keeper.case = case
		keeper.shy = keeper.index == shy


## The keeper by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return keepers[index] if index >= 0 and index < keepers.size() else null


## Whether a point in the world (ignoring height) is at the zoo, the sidewalk out front included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and local.z > -SIZE.y / 2 and local.z < SIDEWALK_AT.z + 1.5


## Whether a point in the world is inside the fence.
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < FENCE and absf(local.z) < FENCE


## Which part of the zoo a point in the world is in: "hut", "shop", "reptiles", "penguins", "monkey", "ostrich",
## "elephant", "pond", "entrance", "grounds" or "" outside the fence.
func room(world: Vector3) -> String:
	if not inside(world):
		return ""
	var local := to_local(world)
	var flat := Vector2(local.x, local.z)
	for named: Array in [["hut", HUT], ["shop", SHOP], ["reptiles", REPTILES]]:
		if (named[1] as Rect2).has_point(flat):
			return named[0]
	for kind: String in ENCLOSURES:
		if (ENCLOSURES[kind].rect as Rect2).has_point(flat):
			return kind
	if POND.has_point(flat):
		return "pond"
	if local.z > ENTRANCE_Z:
		return "entrance"
	return "grounds"


## Locker `index` (0 to 5, one per keeper), its front on the floor of the hut.
static func locker_at(index: int) -> Vector3:
	return Vector3(LOCKER_X + 0.5, 0, LOCKER_FROM_Z + index * LOCKER_STEP)


## Where an enclosure's gate is, on the ground, in the zoo's space.
static func gate_at(kind: String) -> Vector3:
	var pen: Dictionary = ENCLOSURES[kind]
	var rect: Rect2 = pen.rect
	var along: float = pen.at
	match pen.side:
		"-z":
			return Vector3(along, 0, rect.position.y)
		"+z":
			return Vector3(along, 0, rect.end.y)
		"-x":
			return Vector3(rect.position.x, 0, along)
	return Vector3(rect.end.x, 0, along)


## The six keepers alike (KeeperTraits.draw with the case seed) at work, Doña Jaula by the penguins and Don Pico on his
## perch.
func _people() -> void:
	var traits := KeeperTraits.draw(case_seed)
	for i in traits.size():
		var keeper := ZooKeeper.new()
		keeper.name = "Keeper%d" % i
		keeper.traits = traits[i]
		keeper.index = i
		keeper.position = KEEPERS_AT[i]
		keeper.rotation.y = KEEPERS_TURN[i]
		add_child(keeper)
		keepers.append(keeper)
	director = ZooDirector.new()
	director.name = "Director"
	director.position = DIRECTOR_AT
	add_child(director)
	parrot = ZooParrot.new()
	parrot.name = "Parrot"
	parrot.position = PARROT_AT
	parrot.rotation.y = PI / 2
	add_child(parrot)


## The grass, the paths, the little train's track and the fence with the entrance gap.
func _grounds() -> void:
	_builder.mesh_box(Vector3(0, GROUND_TOP - 0.02, 0), Vector3(SIZE.x, 0.02, SIZE.y), GRASS)
	_builder.mesh_box(Vector3(0, GROUND_TOP, (ENTRANCE_Z + FENCE) / 2), Vector3(ENTRANCE_HALF * 2, 0.02,
		FENCE - ENTRANCE_Z), PATH)
	_builder.mesh_box(Vector3(0, GROUND_TOP, 13.0), Vector3(FENCE * 2 - 2, 0.02, 2.4), PATH)
	_builder.mesh_box(Vector3(-11.5, GROUND_TOP, -6), Vector3(2.4, 0.02, 38), PATH)
	_builder.mesh_box(Vector3(11, GROUND_TOP, -6), Vector3(2.4, 0.02, 38), PATH)
	for edge: Array in [[Vector3(0, 0, TRACK.position.y), Vector3(TRACK.size.x, 0, TRACK_WIDTH)],
			[Vector3(0, 0, TRACK.end.y), Vector3(TRACK.size.x, 0, TRACK_WIDTH)],
			[Vector3(TRACK.position.x, 0, TRACK.get_center().y), Vector3(TRACK_WIDTH, 0, TRACK.size.y)],
			[Vector3(TRACK.end.x, 0, TRACK.get_center().y), Vector3(TRACK_WIDTH, 0, TRACK.size.y)]]:
		var at: Vector3 = edge[0]
		var size: Vector3 = edge[1]
		_builder.mesh_box(at + Vector3(0, GROUND_TOP + 0.01, 0), size + Vector3(0, 0.02, 0), RAIL)
	_builder.wall_at("x", -FENCE, -FENCE, FENCE, 0, FENCE_HEIGHT, [], FENCE_COLOR)
	_builder.wall_at("z", -FENCE, -FENCE, FENCE, 0, FENCE_HEIGHT, [], FENCE_COLOR)
	_builder.wall_at("z", FENCE, -FENCE, FENCE, 0, FENCE_HEIGHT, [], FENCE_COLOR)
	_builder.wall_at("x", FENCE, -FENCE, -ENTRANCE_HALF, 0, FENCE_HEIGHT, [], FENCE_COLOR)
	_builder.wall_at("x", FENCE, ENTRANCE_HALF, FENCE, 0, FENCE_HEIGHT, [], FENCE_COLOR)


## The arch over the entrance with the zoo's sign and Copito's birthday banner, the ticket booth and the ice-cream stand.
func _entrance() -> void:
	for x: float in [-ENTRANCE_HALF - 0.3, ENTRANCE_HALF + 0.3]:
		_builder.box(Vector3(x, 2.5, FENCE), Vector3(0.6, 5.0, 0.6), WOOD)
	_builder.mesh_box(Vector3(0, 5.2, FENCE), Vector3(ENTRANCE_HALF * 2 + 1.8, 0.8, 0.5), WOOD)
	_label("Sign", "SIGN_ZOO", Vector3(0, 5.2, FENCE + 0.27), 0.0, 0.012, 64)
	_builder.mesh_box(Vector3(0, 4.2, FENCE + 0.1), Vector3(ENTRANCE_HALF * 2, 0.6, 0.04), Color(1.0, 0.85, 0.3))
	_label("Banner", "SIGN_ZOO_COPITO", Vector3(0, 4.2, FENCE + 0.14), 0.0, 0.006, 48)
	_builder.box(BOOTH_AT + Vector3(0, 1.2, 0), Vector3(2.4, 2.4, 1.8), WOOD)
	_builder.mesh_box(BOOTH_AT + Vector3(0, 2.55, 0), Vector3(2.8, 0.3, 2.2), ROOF_COLOR)
	_label("Booth", "SIGN_ZOO_BOOTH", BOOTH_AT + Vector3(0, 1.9, 0.92), 0.0)
	_builder.box(ICE_CREAM_AT + Vector3(0, 0.55, 0), Vector3(2.0, 1.1, 1.0), WALLS)
	_builder.mesh_box(ICE_CREAM_AT + Vector3(0, 1.12, 0), Vector3(1.8, 0.04, 0.8), STEEL)
	_builder.mesh_box(ICE_CREAM_AT + Vector3(0, 2.4, 0), Vector3(2.4, 0.1, 1.4), Color(0.95, 0.5, 0.7))
	for sx: float in [-1.0, 1.0]:
		_builder.mesh_box(ICE_CREAM_AT + Vector3(sx * 1.0, 1.75, 0), Vector3(0.06, 1.3, 0.06), STEEL)
	_label("IceCream", "SIGN_ZOO_ICE_CREAM", ICE_CREAM_AT + Vector3(0, 1.6, 0.52), 0.0)


## The souvenir shop and the keepers' hut by the entrance, and the reptile house: walls, roof and a door to the path.
func _buildings() -> void:
	_building(SHOP, "-x", SHOP.get_center().y, "SIGN_ZOO_SHOP", Color(0.85, 0.75, 0.95))
	_building(HUT, "+x", HUT.get_center().y, "SIGN_ZOO_HUT", WALLS)
	_building(REPTILES, "-x", REPTILES.get_center().y, "SIGN_ZOO_REPTILES", Color(0.55, 0.7, 0.45))
	for i in LOCKERS:
		var at := locker_at(i)
		_builder.box(Vector3(LOCKER_X, 1.0, at.z), Vector3(0.6, 2.0, 0.9), STEEL)
		_label("Locker%d" % i, "%d" % (i + 1), Vector3(LOCKER_X + 0.31, 1.6, at.z), PI / 2, 0.006, 32)
	_builder.box(LOG_DESK_AT + Vector3(0, 0.45, 0), Vector3(2.0, 0.9, 0.9), WOOD)
	_builder.mesh_box(LOG_DESK_AT + Vector3(0.3, 0.95, 0), Vector3(0.5, 0.08, 0.35), Color(0.2, 0.45, 0.3))
	_builder.mesh_box(PERCH_AT + Vector3(0, 0.9, 0), Vector3(0.1, 1.8, 0.1), WOOD)
	_builder.mesh_box(PERCH_AT + Vector3(0, 1.8, 0), Vector3(0.9, 0.08, 0.08), WOOD)
	for i in 6:
		_builder.box(Vector3(SHOP.position.x + 2.0 + (i % 3) * 2.5, 0.5, SHOP.position.y + 1.5 + (i / 3) * 4.5),
			Vector3(1.6, 1.0, 0.8), WOOD.lightened(0.2))
	var shell := SphereMesh.new()
	shell.radius = 1.0
	shell.height = 1.2
	shell.is_hemisphere = true
	_builder.shape(_builder.body(TORTOISE_AT + Vector3(0, 0.5, 0)), Vector3(1.8, 1.0, 1.8))
	_builder.mesh(shell, TORTOISE_AT, Color(0.4, 0.45, 0.25))
	for z: float in [-2.5, 6.5]:
		_builder.box(Vector3(REPTILES.end.x - 0.5, 0.6, z), Vector3(0.8, 1.2, 2.0), Color(0.35, 0.55, 0.5))


## A building on `rect` with a door on `side` ("-x" or "+x") at z = `door_z`, its sign over the door and a light.
func _building(rect: Rect2, side: String, door_z: float, sign_key: String, color: Color) -> void:
	var x0 := rect.position.x
	var x1 := rect.end.x
	var z0 := rect.position.y
	var z1 := rect.end.y
	_builder.slab(x0, x1, z0, z1, GROUND_TOP + 0.02, color.darkened(0.3))
	_builder.wall_at("x", z0, x0, x1, 0, BUILDING_HEIGHT, [], color)
	_builder.wall_at("x", z1, x0, x1, 0, BUILDING_HEIGHT, [], color)
	_builder.wall_at("z", x0, z0, z1, 0, BUILDING_HEIGHT, [door_z] if side == "-x" else [], color)
	_builder.wall_at("z", x1, z0, z1, 0, BUILDING_HEIGHT, [door_z] if side == "+x" else [], color)
	_builder.slab(x0 - 0.3, x1 + 0.3, z0 - 0.3, z1 + 0.3, BUILDING_HEIGHT + 0.2, ROOF_COLOR)
	var face := x0 - 0.1 if side == "-x" else x1 + 0.1
	_label("", sign_key, Vector3(face, 2.6, door_z), -PI / 2 if side == "-x" else PI / 2)
	_builder.light(Vector3(rect.get_center().x, BUILDING_HEIGHT - 0.4, rect.get_center().y))


## An enclosure's fence with the gap for its gate on the path, the gate shut across it and its sign.
func _enclosure(kind: String) -> void:
	var pen: Dictionary = ENCLOSURES[kind]
	var rect: Rect2 = pen.rect
	var side: String = pen.side
	var along: float = pen.at
	var sides := {
		"-z": ["x", rect.position.y, rect.position.x, rect.end.x],
		"+z": ["x", rect.end.y, rect.position.x, rect.end.x],
		"-x": ["z", rect.position.x, rect.position.y, rect.end.y],
		"+x": ["z", rect.end.x, rect.position.y, rect.end.y],
	}
	for each: String in sides:
		var line: Array = sides[each]
		if kind == "penguins" and each == "+z":
			continue
		if each == side:
			_builder.wall_at(line[0], line[1], line[2], along - GATE_WIDTH / 2, 0, ENCLOSURE_FENCE, [], BARS)
			_builder.wall_at(line[0], line[1], along + GATE_WIDTH / 2, line[3], 0, ENCLOSURE_FENCE, [], BARS)
		else:
			_builder.wall_at(line[0], line[1], line[2], line[3], 0, ENCLOSURE_FENCE, [], BARS)
	var at := gate_at(kind)
	var gate := _builder.body(at + Vector3(0, ENCLOSURE_FENCE / 2, 0))
	gate.name = "Gate_" + kind
	var across := Vector3(GATE_WIDTH, ENCLOSURE_FENCE, 0.12) if sides[side][0] == "x" \
		else Vector3(0.12, ENCLOSURE_FENCE, GATE_WIDTH)
	_builder.shape(gate, across)
	var bars := MeshInstance3D.new()
	var bars_mesh := BoxMesh.new()
	bars_mesh.size = across
	bars.mesh = bars_mesh
	bars.material_override = _builder.material(Color(0.85, 0.65, 0.2))
	gate.add_child(bars)
	gates[kind] = gate
	var sign_at := Vector3(along + GATE_WIDTH, ENCLOSURE_FENCE + 0.5, rect.end.y + 0.1)
	match side:
		"-z":
			sign_at = Vector3(along + GATE_WIDTH, ENCLOSURE_FENCE + 0.5, rect.position.y - 0.1)
		"+x":
			sign_at = Vector3(rect.end.x + 0.1, ENCLOSURE_FENCE + 0.5, along + GATE_WIDTH)
		"-x":
			sign_at = Vector3(rect.position.x - 0.1, ENCLOSURE_FENCE + 0.5, along + GATE_WIDTH)
	var turn := {"-z": PI, "+z": 0.0, "-x": -PI / 2, "+x": PI / 2}[side] as float
	_label("Sign_" + kind, "SIGN_ZOO_" + kind.to_upper(), sign_at, turn)


## The penguins: the glass in front, the pool and Copito's empty ice floe.
func _penguins() -> void:
	var rect: Rect2 = ENCLOSURES.penguins.rect
	var glass := StaticBody3D.new()
	glass.name = "PenguinGlass"
	glass.position = Vector3(rect.get_center().x, 1.1, GLASS_Z)
	add_child(glass)
	_builder.shape(glass, Vector3(rect.size.x, 2.2, 0.1))
	var pane := MeshInstance3D.new()
	var pane_mesh := BoxMesh.new()
	pane_mesh.size = Vector3(rect.size.x, 2.2, 0.1)
	pane.mesh = pane_mesh
	var see_through := StandardMaterial3D.new()
	see_through.albedo_color = Color(0.8, 0.95, 1.0, 0.25)
	see_through.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pane.material_override = see_through
	glass.add_child(pane)
	_builder.mesh_box(Vector3(POOL.get_center().x, GROUND_TOP + 0.02, POOL.get_center().y),
		Vector3(POOL.size.x, 0.02, POOL.size.y), WATER)
	var floe := StaticBody3D.new()
	floe.name = "IceFloe"
	floe.position = ICE_AT + Vector3(0, 0.3, 0)
	add_child(floe)
	_builder.shape(floe, Vector3(2.0, 0.6, 1.6))
	var floe_mesh := MeshInstance3D.new()
	var block := BoxMesh.new()
	block.size = Vector3(2.0, 0.6, 1.6)
	floe_mesh.mesh = block
	floe_mesh.material_override = _builder.material(ICE)
	floe.add_child(floe_mesh)
	_label("Plaque", "SIGN_ZOO_COPITO_HOME", Vector3(rect.get_center().x, 0.4, GLASS_Z + 0.08), 0.0, 0.004, 32)


## The monkey's tree, the ostrich's sand and the elephant's mud.
func _animals() -> void:
	_builder.box(TREE_AT + Vector3(0, 1.8, 0), Vector3(0.6, 3.6, 0.6), WOOD)
	var crown := SphereMesh.new()
	crown.radius = 2.0
	crown.height = 3.0
	_builder.mesh(crown, TREE_AT + Vector3(0, 4.2, 0), LEAVES)
	var sand: Rect2 = ENCLOSURES.ostrich.rect
	_builder.mesh_box(Vector3(sand.get_center().x, GROUND_TOP + 0.01, sand.get_center().y),
		Vector3(sand.size.x - 0.4, 0.02, sand.size.y - 0.4), SAND)
	_builder.mesh_box(MUD_AT + Vector3(0, GROUND_TOP + 0.02, 0), Vector3(4.0, 0.02, 4.0), MUD)


## The duck pond and the pedal boat.
func _pond() -> void:
	_builder.mesh_box(Vector3(POND.get_center().x, GROUND_TOP + 0.01, POND.get_center().y),
		Vector3(POND.size.x, 0.02, POND.size.y), WATER)
	_builder.box(BOAT_AT + Vector3(0, 0.35, 0), Vector3(1.6, 0.6, 2.4), Color(0.95, 0.95, 0.95))
	var head := SphereMesh.new()
	head.radius = 0.35
	head.height = 0.7
	_builder.mesh(head, BOAT_AT + Vector3(0, 1.0, 0.9), Color(1.0, 0.85, 0.2))
	_label("Sign_pond", "SIGN_ZOO_POND", Vector3(POND.get_center().x, 1.4, POND.end.y + 0.3), 0.0)


func _label(label_name: String, key: String, at: Vector3, turn: float, pixel := 0.006, font := 32) -> void:
	var label := Label3D.new()
	if label_name != "":
		label.name = label_name
	label.text = key
	label.pixel_size = pixel
	label.font_size = font
	label.outline_size = 8
	label.position = at
	label.rotation.y = turn
	add_child(label)
