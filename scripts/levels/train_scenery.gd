class_name TrainScenery
extends Node3D

## What runs past the train's windows (escena-tren.md, step 1): the field, the rails and their sleepers, the poles,
## trees, cows and houses that come round again every LOOP meters, and, where TrainRide says, each station's platform
## with its sign and each leg's tunnel through a hill. Everything moves by the ride's distance (the train itself stands
## still), so it's only meshes, built once. Every number here is (propuesta).

const LOOP := 400.0
const SLEEPER_LOOP := 60.0
## The train's middle along X (between the back of the luggage car and the front of the locomotive).
const MIDDLE := -3.0
const PLATFORM := Vector3(60, Train.FLOOR_Y, 3.0)
const PLATFORM_Z := Train.WIDTH / 2 + 0.2 + 1.5
const HILL := Color(0.35, 0.5, 0.28)
const FIELD := Color(0.48, 0.66, 0.32)
const BALLAST := Color(0.5, 0.48, 0.45)
const RAIL := Color(0.6, 0.6, 0.62)
const WOOD := Color(0.4, 0.27, 0.16)
const LEAF := Color(0.2, 0.5, 0.22)
const STONE := Color(0.75, 0.72, 0.66)
const ROOF := Color(0.7, 0.25, 0.2)

var ride: TrainRide
## Each moving piece and its x along the loop (or, for stations and tunnels, along the whole ride).
var _looped: Array[Array] = []
var _sleepers: Array[Array] = []
var _fixed: Array[Array] = []
var _materials := {}


func _ready() -> void:
	_mesh(_box(Vector3(2000, 1, 400)), Vector3(0, -0.5, 0), FIELD)
	_mesh(_box(Vector3(2000, 0.3, 3.6)), Vector3(0, 0.1, 0), BALLAST)
	for z: float in [-0.72, 0.72]:
		_mesh(_box(Vector3(2000, 0.12, 0.08)), Vector3(0, 0.3, z), RAIL)
	for i in int(SLEEPER_LOOP):
		_sleepers.append([_mesh(_box(Vector3(0.25, 0.08, 2.4)), Vector3(0, 0.24, 0), WOOD), float(i)])
	var rng := RandomNumberGenerator.new()
	rng.seed = 202
	for i in int(LOOP / 25.0):
		var pole := Node3D.new()
		add_child(pole)
		_mesh(_cylinder(0.08, 0.08, 6.0), Vector3(0, 3.0, -3.4), WOOD, pole)
		_mesh(_box(Vector3(0.1, 0.1, 1.2)), Vector3(0, 5.7, -3.4), WOOD, pole)
		_looped.append([pole, i * 25.0])
	for i in 40:
		var tree := Node3D.new()
		add_child(tree)
		var side := -1.0 if i % 2 else 1.0
		var tall := rng.randf_range(3.0, 6.0)
		_mesh(_cylinder(0.15, 0.2, tall * 0.4), Vector3(0, tall * 0.2, 0), WOOD, tree)
		_mesh(_cylinder(0.0, tall * 0.3, tall * 0.7), Vector3(0, tall * 0.65, 0), LEAF, tree)
		tree.position.z = side * rng.randf_range(7.0, 70.0)
		_looped.append([tree, rng.randf_range(0.0, LOOP)])
	for i in 6:
		var cow := Node3D.new()
		add_child(cow)
		_mesh(_box(Vector3(1.6, 0.8, 0.6)), Vector3(0, 0.9, 0), Color(0.95, 0.95, 0.93), cow)
		_mesh(_box(Vector3(0.5, 0.45, 0.4)), Vector3(0.95, 1.2, 0), Color(0.12, 0.1, 0.1), cow)
		for dx: float in [-0.6, 0.6]:
			_mesh(_box(Vector3(0.15, 0.5, 0.5)), Vector3(dx, 0.25, 0), Color(0.12, 0.1, 0.1), cow)
		cow.position.z = rng.randf_range(10.0, 35.0)
		cow.rotation.y = rng.randf_range(0.0, TAU)
		_looped.append([cow, rng.randf_range(0.0, LOOP)])
	for i in 4:
		var house := Node3D.new()
		add_child(house)
		_mesh(_box(Vector3(5, 3, 4)), Vector3(0, 1.5, 0), STONE, house)
		_mesh(_box(Vector3(5.4, 0.4, 4.4)), Vector3(0, 3.2, 0), ROOF, house)
		house.position.z = -rng.randf_range(25.0, 60.0)
		_looped.append([house, i * LOOP / 4 + 50.0])
	for station in TrainRide.STATIONS:
		_fixed.append([_platform(station), TrainRide.station_at(station)])
	for leg in TrainRide.STATIONS:
		_fixed.append([_tunnel(), TrainRide.tunnel_at(leg) + _tunnel_length() / 2])
	_place()


func _process(_delta: float) -> void:
	_place()


func _place() -> void:
	var gone := ride.distance() if ride else 0.0
	for piece in _looped:
		piece[0].position.x = MIDDLE + fposmod(piece[1] - gone + LOOP / 2, LOOP) - LOOP / 2
	for piece in _sleepers:
		piece[0].position.x = MIDDLE + fposmod(piece[1] - gone + SLEEPER_LOOP / 2, SLEEPER_LOOP) - SLEEPER_LOOP / 2
	for piece in _fixed:
		var x: float = MIDDLE + piece[1] - gone
		piece[0].position.x = x
		piece[0].visible = absf(x) < LOOP


## Where a station's platform is now along X (its middle), or where a tunnel's is.
func fixed_x(index: int) -> float:
	return _fixed[index][0].position.x


static func _tunnel_length() -> float:
	return TrainRide.SPEED * TrainRide.TUNNEL


## A station: the platform along the train's +Z side, its roof on posts and the sign with its name.
func _platform(station: int) -> Node3D:
	var root := Node3D.new()
	root.name = "Station%d" % (station + 1)
	add_child(root)
	_mesh(_box(PLATFORM), Vector3(0, PLATFORM.y / 2, PLATFORM_Z), STONE, root)
	_mesh(_box(Vector3(PLATFORM.x * 0.6, 0.15, PLATFORM.z)), Vector3(0, 3.8, PLATFORM_Z + 0.4), ROOF, root)
	for x in range(-15, 16, 6):
		_mesh(_box(Vector3(0.15, 2.8, 0.15)), Vector3(x, 2.4, PLATFORM_Z + 1.2), WOOD, root)
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = TrainRide.NAMES[station]
	sign_label.font_size = 72
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.modulate = Color(1, 1, 1)
	sign_label.position = Vector3(0, 2.6, PLATFORM_Z + 1.1)
	sign_label.rotation.y = PI
	root.add_child(sign_label)
	return root


## A hill the rails go through: two walls beside the train and a roof over it, as long as the tunnel lasts.
func _tunnel() -> Node3D:
	var root := Node3D.new()
	root.name = "Tunnel"
	add_child(root)
	var length := _tunnel_length()
	for side: float in [-1.0, 1.0]:
		_mesh(_box(Vector3(length, 8, 20)), Vector3(0, 4, side * 12.6), HILL, root)
	_mesh(_box(Vector3(length, 10, 45.2)), Vector3(0, 9.5, 0), HILL, root)
	return root


func _box(size: Vector3) -> BoxMesh:
	var box := BoxMesh.new()
	box.size = size
	return box


func _cylinder(top: float, bottom: float, height: float) -> CylinderMesh:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = top
	cylinder.bottom_radius = bottom
	cylinder.height = height
	cylinder.radial_segments = 8
	return cylinder


func _mesh(new_mesh: Mesh, at: Vector3, color: Color, parent: Node3D = self) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = new_mesh
	instance.position = at
	if not _materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.95
		_materials[color] = material
	instance.material_override = _materials[color]
	parent.add_child(instance)
	return instance
