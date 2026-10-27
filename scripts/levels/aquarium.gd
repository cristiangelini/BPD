class_name Aquarium
extends CrimeScenePlace

## The Municipal Aquarium (escena-acuario.md, step 1, decision 400), on its lot with the front to +Z: the door is a
## shark's mouth with its teeth and eyes, and a cardboard whale lies on the roof. Inside, the hall with the big tank in
## the middle (Doña Almeja open and empty on its sand), the six small tanks (sharks, jellyfish and seahorses along the
## west wall, turtles and rays along the east wall, the penguins' pool with their igloo at the back), Doña Tinta's tank
## in the dark corner and the divers' bench; in front, the gift shop to the west (the plush basket and the till) and
## the kitchen to the east (the fish-food bucket, the box of crabs and the feeding board). The six divers stand about
## the big tank and the bench (step 2), Don Anzuelo by the penguins, Bigotes waddles round the hall and Doña Tinta sits
## in her tank. The case comes in later steps. Every number here is (propuesta).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(32, 28)
const HALF_X := 15.0
const BACK_Z := -13.0
## The front wall; the square runs from it to the lot's edge.
const FRONT_Z := 7.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT + 1.5
## The gift shop is west of SHOP_X and the kitchen east of KITCHEN_X, both in front of ROOMS_Z; the rest is the hall.
const SHOP_X := -7.0
const KITCHEN_X := 7.0
const ROOMS_Z := 2.0
const DOOR_FRONT_X := 0.0
const DOOR_ROOMS_Z := 4.5
const DOOR_AT := Vector3(DOOR_FRONT_X, 0, FRONT_Z)
const SQUARE_AT := Vector3(0, 0, FRONT_Z + 3.5)
## The big tank in the middle of the hall, with Doña Almeja on its sand.
const BIG_TANK_AT := Vector3(0, 0, -3.5)
const BIG_TANK_SIZE := Vector3(6.0, 2.6, 5.0)
const CLAM_AT := BIG_TANK_AT + Vector3(0, 0.35, 0)
## The six small tanks, by the animal each holds: the three west and two east ones stand against the walls, and the
## penguins have a low pool at the back with their igloo in it.
const TANKS := {
	"sharks": Vector3(-13.2, 0, -10.0), "jellyfish": Vector3(-13.2, 0, -5.5), "seahorses": Vector3(-13.2, 0, -1.0),
	"turtles": Vector3(13.2, 0, -10.0), "rays": Vector3(13.2, 0, -5.5), "penguins": Vector3(0, 0, -11.0),
}
const TANK_SIZE := Vector3(2.6, 2.2, 3.4)
const POOL_SIZE := Vector3(7.0, 0.9, 3.4)
const IGLOO_AT := Vector3(2.0, 0.1, -11.3)
## Doña Tinta's tank, in the dark corner by the east wall.
const INK_TANK_AT := Vector3(13.2, 0, -1.0)
## The divers' bench, facing the big tank.
const BENCH_AT := Vector3(0, 0, 1.5)
## Where the people are: the six divers two at the bench and four about the big tank, facing it; Don Anzuelo by the
## penguins; the loop Bigotes waddles round the big tank.
const DIVERS_AT: Array[Vector3] = [
	Vector3(-1.0, 0, 2.3), Vector3(1.0, 0, 2.3), Vector3(-4.0, 0, -1.5), Vector3(4.0, 0, -1.5), Vector3(-4.0, 0, -6.0),
	Vector3(4.0, 0, -6.0),
]
const KEEPER_AT := Vector3(-4.5, 0, -10.0)
const SEA_LION_ROUTE: Array[Vector3] = [Vector3(-6.5, 0, 0.5), Vector3(-6.5, 0, -8.3), Vector3(6.5, 0, -8.3),
	Vector3(6.5, 0, 0.5)]
## The gift shop: the plush basket, the till on its counter and the shelf of plushes.
const BASKET_AT := Vector3(-11.0, 0, 5.0)
const TILL_AT := Vector3(-9.0, 0, 3.0)
## The kitchen: the fish-food bucket, the box of crabs and the feeding board on the east wall.
const BUCKET_AT := Vector3(10.0, 0, 4.5)
const CRABS_AT := Vector3(12.5, 0, 6.0)
const BOARD_AT := Vector3(HALF_X - 0.12, 1.6, 4.5)
const PAINT := Color(0.25, 0.55, 0.75)
const SHARK := Color(0.42, 0.47, 0.52)
const ROOF_COLOR := Color(0.2, 0.3, 0.45)
const INSIDE := Color(0.82, 0.9, 0.95)
const TILES := Color(0.58, 0.6, 0.64)
const STONE := Color(0.18, 0.24, 0.35)
const WOOD := Color(0.5, 0.34, 0.2)
const GLASS := Color(0.75, 0.9, 0.95, 0.3)
const WATER := Color(0.1, 0.5, 0.9, 0.55)
const SAND := Color(0.9, 0.8, 0.55)
const SHELL := Color(0.85, 0.75, 0.82)
const SNOW := Color(0.96, 0.97, 1.0)
const WHITE := Color(0.97, 0.97, 0.97)
const BLACK := Color(0.08, 0.08, 0.1)
const METAL := Color(0.6, 0.62, 0.66)
const ANIMAL_COLORS := {
	"sharks": Color(0.45, 0.5, 0.55), "jellyfish": Color(0.95, 0.55, 0.8), "seahorses": Color(0.98, 0.78, 0.2),
	"turtles": Color(0.3, 0.6, 0.3), "rays": Color(0.3, 0.32, 0.4), "penguins": Color(0.1, 0.1, 0.12),
}
const PLUSH_COLORS: Array[Color] = [Color(0.95, 0.6, 0.2), Color(0.3, 0.7, 0.85), Color(0.95, 0.5, 0.6),
	Color(0.98, 0.85, 0.3), Color(0.6, 0.45, 0.85)]

var divers: Array[AquariumDiver] = []
var keeper: AquariumKeeper
var sea_lion: SeaLion
var octopus: AquariumOctopus
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("aquarium")
	variant = "aquarium"
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_rooms()
	_big_tank()
	_builder.box(BENCH_AT + Vector3(0, 0.42, 0), Vector3(3.0, 0.08, 0.5), WOOD)
	_builder.legs(BENCH_AT, Vector2(3.0, 0.5), 0.38, METAL)
	_small_tanks()
	_penguins()
	_ink_tank()
	_shop()
	_kitchen()
	_people()


## The diver by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return divers[index] if index >= 0 and index < divers.size() else null


## Whether a point in the world (ignoring height) is on the aquarium's lot, square included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the building.
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## Which room a point in the world is in: "hall", "shop", "kitchen", or "" outside the building.
func room(world: Vector3) -> String:
	if not inside(world):
		return ""
	var local := to_local(world)
	if local.z > ROOMS_Z and local.x < SHOP_X:
		return "shop"
	if local.z > ROOMS_Z and local.x > KITCHEN_X:
		return "kitchen"
	return "hall"


## The small tank a point in the world is in front of (a key of TANKS), or "" away from them.
func tank(world: Vector3) -> String:
	var local := to_local(world)
	for animal: String in TANKS:
		var at: Vector3 = TANKS[animal]
		var size: Vector3 = POOL_SIZE if animal == "penguins" else TANK_SIZE
		if absf(local.x - at.x) < size.x / 2 + 1.2 and absf(local.z - at.z) < size.z / 2 + 1.2:
			return animal
	return ""


## The six divers alike (DiverTraits.draw with the case seed) about the big tank, Don Anzuelo by the penguins, Bigotes on
## his loop and Doña Tinta in her tank.
func _people() -> void:
	var traits := DiverTraits.draw(case_seed)
	for i in traits.size():
		var diver := AquariumDiver.new()
		diver.name = "Diver%d" % i
		diver.traits = traits[i]
		diver.index = i
		var at: Vector3 = DIVERS_AT[i]
		diver.position = at + Vector3(0, FLOOR_TOP, 0)
		var to := BIG_TANK_AT - at
		diver.rotation.y = atan2(to.x, to.z)
		add_child(diver)
		divers.append(diver)
	keeper = AquariumKeeper.new()
	keeper.name = "Keeper"
	keeper.position = KEEPER_AT + Vector3(0, FLOOR_TOP, 0)
	keeper.rotation.y = PI / 2
	add_child(keeper)
	sea_lion = SeaLion.new()
	sea_lion.name = "SeaLion"
	for point in SEA_LION_ROUTE:
		sea_lion.route.append(point + Vector3(0, FLOOR_TOP, 0))
	sea_lion.position = sea_lion.route[0]
	add_child(sea_lion)
	octopus = AquariumOctopus.new()
	octopus.name = "Octopus"
	octopus.glass = TANK_SIZE
	octopus.position = INK_TANK_AT + Vector3(0, 0.4, 0)
	octopus.rotation.y = -PI / 2
	add_child(octopus)


## The tiled floor, the roof with its lights (none over Doña Tinta's corner) and the outer walls with the door.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, BACK_Z, FRONT_Z, FLOOR_TOP, TILES)
	_builder.mesh_box(Vector3(0, FLOOR_TOP + 0.005, (BIG_TANK_AT.z + FRONT_Z) / 2 + 1.0),
		Vector3(2.4, 0.01, FRONT_Z - BIG_TANK_AT.z - 2.0), PAINT)
	_builder.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, ROOF, INSIDE)
	_builder.mesh_box(Vector3(0, ROOF + 0.4, (BACK_Z + FRONT_Z) / 2), Vector3(SIZE.x - 1.2, 0.5, FRONT_Z - BACK_Z + 0.8),
		ROOF_COLOR)
	_builder.wall_at("x", BACK_Z, -HALF_X, HALF_X, 0, ROOF, [], PAINT)
	_builder.wall_at("x", FRONT_Z, -HALF_X, HALF_X, 0, ROOF, [DOOR_FRONT_X], PAINT)
	_builder.wall_at("z", -HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], PAINT)
	_builder.wall_at("z", HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], PAINT)
	for at: Vector3 in [Vector3(-10, 0, -8), Vector3(-10, 0, -1), Vector3(0, 0, -8), Vector3(0, 0, 0),
			Vector3(10, 0, -8), Vector3(-11, 0, 4.5), Vector3(11, 0, 4.5)]:
		_builder.light(at + Vector3(0, ROOF - 0.5, 0))


## The shark's mouth around the door (the jaw, the teeth and the eyes), the sign and the cardboard whale on the roof.
func _front() -> void:
	var face := FRONT_Z + 0.12
	_builder.mesh_box(Vector3(0, GameScale.DOOR_HEIGHT + 0.6, face), Vector3(5.0, 1.2, 0.08), SHARK)
	for side: float in [-1.0, 1.0]:
		_builder.mesh_box(Vector3(side * 1.6, GameScale.DOOR_HEIGHT / 2, face), Vector3(1.8, GameScale.DOOR_HEIGHT, 0.08),
			SHARK)
		var eye := SphereMesh.new()
		eye.radius = 0.22
		eye.height = 0.44
		_builder.mesh(eye, Vector3(side * 1.9, GameScale.DOOR_HEIGHT + 1.0, face + 0.05), WHITE)
		_builder.mesh(eye, Vector3(side * 1.9, GameScale.DOOR_HEIGHT + 1.0, face + 0.15), BLACK)
	var tooth := PrismMesh.new()
	tooth.size = Vector3(0.3, 0.35, 0.06)
	for i in 5:
		var x := -0.6 + i * 0.3
		_builder.mesh(tooth, Vector3(x, GameScale.DOOR_HEIGHT - 0.12, face + 0.06), WHITE, Vector3(0, 0, PI))
	for side: float in [-1.0, 1.0]:
		for i in 3:
			_builder.mesh(tooth, Vector3(side * (1.0 + i * 0.45), 0.2, face + 0.06), WHITE)
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = "SIGN_AQUARIUM"
	sign_label.font_size = 48
	sign_label.pixel_size = 0.008
	sign_label.outline_size = 12
	sign_label.modulate = SNOW
	sign_label.position = Vector3(0, ROOF - 0.5, face + 0.06)
	add_child(sign_label)
	# The cardboard whale lying on the roof, with its tail up and a spout of painted water.
	var whale := SphereMesh.new()
	whale.radius = 1.0
	whale.height = 2.0
	var body := MeshInstance3D.new()
	body.name = "Whale"
	body.mesh = whale
	body.material_override = _builder.material(PAINT.darkened(0.2))
	body.scale = Vector3(4.5, 1.3, 1.6)
	body.position = Vector3(0, ROOF + 1.6, FRONT_Z - 2.0)
	add_child(body)
	var tail := PrismMesh.new()
	tail.size = Vector3(2.0, 1.4, 0.3)
	_builder.mesh(tail, Vector3(-5.0, ROOF + 2.6, FRONT_Z - 2.0), PAINT.darkened(0.2), Vector3(0, 0, PI / 2))
	_builder.mesh_box(Vector3(2.5, ROOF + 3.3, FRONT_Z - 2.0), Vector3(0.15, 0.9, 0.15), WATER)
	var whale_eye := SphereMesh.new()
	whale_eye.radius = 0.15
	whale_eye.height = 0.3
	_builder.mesh(whale_eye, Vector3(3.2, ROOF + 1.9, FRONT_Z - 0.45), BLACK)


## The walls of the gift shop and the kitchen, with their doors to the hall and their signs over them.
func _rooms() -> void:
	_builder.wall_at("z", SHOP_X, ROOMS_Z, FRONT_Z, 0, ROOF, [DOOR_ROOMS_Z], INSIDE)
	_builder.wall_at("x", ROOMS_Z, -HALF_X, SHOP_X, 0, ROOF, [], INSIDE)
	_builder.wall_at("z", KITCHEN_X, ROOMS_Z, FRONT_Z, 0, ROOF, [DOOR_ROOMS_Z], INSIDE)
	_builder.wall_at("x", ROOMS_Z, KITCHEN_X, HALF_X, 0, ROOF, [], INSIDE)
	for room_sign: Array in [["SIGN_AQUARIUM_SHOP", SHOP_X + 0.12, PI / 2], ["SIGN_AQUARIUM_KITCHEN", KITCHEN_X - 0.12,
			-PI / 2]]:
		var label := Label3D.new()
		label.text = room_sign[0]
		label.pixel_size = 0.006
		label.outline_size = 8
		label.position = Vector3(room_sign[1], 2.6, DOOR_ROOMS_Z)
		label.rotation.y = room_sign[2]
		add_child(label)


## A tank on its stone base: the glass box, the water in it, the sand at the bottom and the stone rim on top.
## A tank that isn't solid leaves its glass to whoever lives in it (Doña Tinta's body is her glass).
func _tank(at: Vector3, size: Vector3, water := WATER, solid := true) -> void:
	_builder.box(at + Vector3(0, 0.2, 0), Vector3(size.x + 0.2, 0.4, size.z + 0.2), STONE)
	if solid:
		_builder.box(at + Vector3(0, 0.4 + size.y / 2, 0), size, GLASS)
	else:
		_builder.mesh_box(at + Vector3(0, 0.4 + size.y / 2, 0), size, GLASS)
	_builder.mesh_box(at + Vector3(0, 0.4 + (size.y - 0.3) / 2, 0), size - Vector3(0.1, 0.3, 0.1), water)
	_builder.mesh_box(at + Vector3(0, 0.45, 0), Vector3(size.x - 0.1, 0.1, size.z - 0.1), SAND)
	_builder.mesh_box(at + Vector3(0, 0.4 + size.y + 0.1, 0), Vector3(size.x + 0.2, 0.2, size.z + 0.2), STONE)


## The big tank, with rocks, weed and Doña Almeja wide open and empty on the sand.
func _big_tank() -> void:
	_tank(BIG_TANK_AT, BIG_TANK_SIZE)
	var rock := SphereMesh.new()
	rock.radius = 0.4
	rock.height = 0.6
	for offset: Vector3 in [Vector3(-2.2, 0.6, -1.6), Vector3(2.1, 0.6, 1.5), Vector3(-1.8, 0.6, 1.7)]:
		_builder.mesh(rock, BIG_TANK_AT + offset, STONE.lightened(0.3))
	for x: float in [-2.4, 2.4, 1.6]:
		_builder.mesh_box(BIG_TANK_AT + Vector3(x, 1.3, -2.0), Vector3(0.08, 1.6, 0.08), Color(0.2, 0.6, 0.3))
	var shell := SphereMesh.new()
	shell.radius = 0.7
	shell.height = 0.7
	shell.is_hemisphere = true
	var clam := Node3D.new()
	clam.name = "Clam"
	clam.position = CLAM_AT
	add_child(clam)
	var bottom := MeshInstance3D.new()
	bottom.mesh = shell
	bottom.material_override = _builder.material(SHELL)
	bottom.rotation = Vector3(PI, 0, 0)
	bottom.position = Vector3(0, 0.35, 0)
	bottom.scale = Vector3(1, 0.45, 1)
	clam.add_child(bottom)
	var top := MeshInstance3D.new()
	top.mesh = shell
	top.material_override = _builder.material(SHELL)
	top.rotation = Vector3(-1.2, 0, 0)
	top.scale = Vector3(1, 0.45, 1)
	top.position = Vector3(0, 0.95, -0.62)
	clam.add_child(top)
	var bed := MeshInstance3D.new()
	var pink := CylinderMesh.new()
	pink.top_radius = 0.5
	pink.bottom_radius = 0.5
	pink.height = 0.04
	bed.mesh = pink
	bed.material_override = _builder.material(Color(0.95, 0.6, 0.65))
	bed.position = Vector3(0, 0.36, 0)
	clam.add_child(bed)


## The five small tanks against the walls, each with a few of its animals, and the label with the animal's name.
func _small_tanks() -> void:
	for animal: String in TANKS:
		if animal == "penguins":
			continue
		var at: Vector3 = TANKS[animal]
		_tank(at, TANK_SIZE)
		var facing := -signf(at.x)
		for i in 3:
			_builder.mesh(_animal_mesh(animal), at + Vector3(0.2 * (i - 1), 1.0 + 0.45 * i, -1.0 + i), ANIMAL_COLORS[animal])
		_tank_label(animal, at + Vector3(facing * (TANK_SIZE.x / 2 + 0.12), 2.85, 0), facing * PI / 2)


## The low pool of the penguins at the back, with the ice and the igloo, and two penguins on the ice.
func _penguins() -> void:
	var at: Vector3 = TANKS["penguins"]
	_builder.box(at + Vector3(0, POOL_SIZE.y / 2, POOL_SIZE.z / 2), Vector3(POOL_SIZE.x, POOL_SIZE.y, 0.2), STONE)
	_builder.box(at + Vector3(-POOL_SIZE.x / 2, POOL_SIZE.y / 2, 0), Vector3(0.2, POOL_SIZE.y, POOL_SIZE.z), STONE)
	_builder.box(at + Vector3(POOL_SIZE.x / 2, POOL_SIZE.y / 2, 0), Vector3(0.2, POOL_SIZE.y, POOL_SIZE.z), STONE)
	_builder.mesh_box(at + Vector3(-1.5, 0.35, 0), Vector3(3.6, 0.5, POOL_SIZE.z - 0.2), WATER)
	_builder.box(at + Vector3(1.8, 0.3, 0), Vector3(3.2, 0.6, POOL_SIZE.z - 0.2), SNOW)
	var dome := SphereMesh.new()
	dome.radius = 0.9
	dome.height = 0.9
	dome.is_hemisphere = true
	var igloo := MeshInstance3D.new()
	igloo.name = "Igloo"
	igloo.mesh = dome
	igloo.material_override = _builder.material(SNOW.darkened(0.05))
	igloo.position = IGLOO_AT + Vector3(0, 0.5, 0)
	add_child(igloo)
	_builder.mesh_box(IGLOO_AT + Vector3(0, 0.75, 0.62), Vector3(0.45, 0.45, 0.3), BLACK)
	for x: float in [0.6, 2.8]:
		_builder.mesh(_animal_mesh("penguins"), at + Vector3(x, 0.95, 0.9), ANIMAL_COLORS["penguins"])
	_tank_label("penguins", at + Vector3(0, 1.3, POOL_SIZE.z / 2 + 0.12), 0.0)


## Doña Tinta's tank in the dark corner: dark water, a rock cave and a dim purple light.
func _ink_tank() -> void:
	_tank(INK_TANK_AT, TANK_SIZE, Color(0.15, 0.2, 0.4, 0.6), false)
	var cave := SphereMesh.new()
	cave.radius = 0.8
	cave.height = 0.8
	cave.is_hemisphere = true
	_builder.mesh(cave, INK_TANK_AT + Vector3(0.4, 0.45, -0.6), STONE.lightened(0.15))
	var lamp := _builder.light(INK_TANK_AT + Vector3(-1.6, 2.4, 0))
	lamp.light_color = Color(0.6, 0.4, 0.9)
	lamp.light_energy = 0.35
	lamp.omni_range = 4.0
	_tank_label("octopus", INK_TANK_AT + Vector3(-(TANK_SIZE.x / 2 + 0.12), 2.85, 0), -PI / 2)


## The plush basket, the counter with the till and the shelf of plushes along the west wall.
func _shop() -> void:
	_builder.open_box(BASKET_AT, Vector3(1.2, 0.6, 1.0), "top", Color(0.75, 0.6, 0.35))
	var plush := SphereMesh.new()
	plush.radius = 0.2
	plush.height = 0.4
	for i in 7:
		_builder.mesh(plush, BASKET_AT + Vector3(-0.35 + (i % 3) * 0.35, 0.55 + (i / 3) * 0.12, -0.25 + (i % 2) * 0.5),
			PLUSH_COLORS[i % PLUSH_COLORS.size()])
	_builder.box(TILL_AT + Vector3(0, 0.5, 0), Vector3(2.0, 1.0, 0.7), WOOD)
	_builder.mesh_box(TILL_AT + Vector3(0.4, 1.15, 0), Vector3(0.5, 0.3, 0.4), METAL)
	_builder.box(Vector3(-HALF_X + 0.35, 1.0, 4.5), Vector3(0.5, 2.0, 4.0), WOOD)
	for i in 8:
		_builder.mesh(plush, Vector3(-HALF_X + 0.45, 0.5 + (i % 2) * 0.9, 3.0 + (i / 2) * 1.0), PLUSH_COLORS[i % 5])


## The fish-food bucket, the box of crabs, the fridge, the sink and the feeding board.
func _kitchen() -> void:
	var bucket := CylinderMesh.new()
	bucket.top_radius = 0.35
	bucket.bottom_radius = 0.28
	bucket.height = 0.6
	var body := _builder.body(BUCKET_AT + Vector3(0, 0.3, 0))
	_builder.shape(body, Vector3(0.6, 0.6, 0.6))
	_builder.mesh(bucket, BUCKET_AT + Vector3(0, 0.3, 0), METAL)
	for i in 4:
		_builder.mesh_box(BUCKET_AT + Vector3(-0.15 + i * 0.1, 0.62, 0), Vector3(0.06, 0.04, 0.3), Color(0.6, 0.65, 0.7))
	_builder.open_box(CRABS_AT, Vector3(0.9, 0.4, 0.7), "top", Color(0.7, 0.55, 0.35))
	for i in 3:
		_builder.mesh_box(CRABS_AT + Vector3(-0.25 + i * 0.25, 0.42, 0), Vector3(0.2, 0.08, 0.15), Color(0.9, 0.3, 0.2))
	_builder.box(Vector3(HALF_X - 0.5, 1.0, 2.8), Vector3(0.8, 2.0, 1.2), WHITE)
	_builder.box(Vector3(9.5, 0.45, FRONT_Z - 0.45), Vector3(3.0, 0.9, 0.7), METAL)
	_builder.mesh_box(BOARD_AT, Vector3(0.05, 1.0, 1.6), Color(0.15, 0.25, 0.2))
	var board := Label3D.new()
	board.name = "FeedingBoard"
	board.text = "SIGN_FEEDING_BOARD"
	board.pixel_size = 0.004
	board.outline_size = 6
	board.position = BOARD_AT + Vector3(-0.04, 0.35, 0)
	board.rotation.y = -PI / 2
	add_child(board)


## A small mesh for an animal of a tank: a fin, a bell, a seahorse, a shell, a ray or a penguin.
func _animal_mesh(animal: String) -> Mesh:
	match animal:
		"sharks":
			var fin := PrismMesh.new()
			fin.size = Vector3(0.6, 0.3, 0.15)
			return fin
		"jellyfish":
			var bell := SphereMesh.new()
			bell.radius = 0.2
			bell.height = 0.2
			bell.is_hemisphere = true
			return bell
		"turtles":
			var back := SphereMesh.new()
			back.radius = 0.3
			back.height = 0.25
			return back
		"rays":
			var ray := BoxMesh.new()
			ray.size = Vector3(0.6, 0.04, 0.5)
			return ray
	var body := CapsuleMesh.new()
	body.radius = 0.1 if animal == "seahorses" else 0.15
	body.height = 0.35 if animal == "seahorses" else 0.5
	return body


func _tank_label(animal: String, at: Vector3, turn: float) -> void:
	var label := Label3D.new()
	label.name = "Tank" + animal.capitalize()
	label.text = "TANK_" + animal.to_upper()
	label.pixel_size = 0.005
	label.outline_size = 8
	label.position = at
	label.rotation.y = turn
	add_child(label)
