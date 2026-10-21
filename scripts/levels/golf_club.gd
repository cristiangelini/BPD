class_name GolfClub
extends Node3D

## The golf club (persecucion-lugares.md, step 4), built from GolfLayout at its CENTER in the city's space: the lawn
## inside a hedge with a gate on the ring's east side, the holes with their green and flag, the concrete path, the
## bunkers and the lakes, and a golfer by each hole. In the sand the patrol car goes at half speed and slides
## (PatrolCar asks `in_bunker`); a car that drives into a lake sinks and, SINK_SECONDS later, turns up wet at the
## gate (`sunk`, a fine in a chase). Every number here is (propuesta).

signal sunk(car: PatrolCar)

const LAWN := Color(0.3, 0.6, 0.24)
const GREEN := Color(0.42, 0.75, 0.32)
const SAND := Color(0.86, 0.72, 0.42)
const WATER := Color(0.2, 0.45, 0.85)
const CONCRETE := Color(0.6, 0.6, 0.58)
const FLAG := Color(0.95, 0.2, 0.15)
const POLE := Color(0.95, 0.95, 0.95)
const SINK_SECONDS := 5.0
const SINK_RATE := 0.3
## Where a sunk car turns up: just inside the gate, facing into the club.
const COMES_BACK := Vector3(GolfLayout.GATE.x + 8.0, 0.6, 0)

var city: City
var golfers: Array[Golfer] = []
## Cars under water and the seconds they've been sinking.
var _sinking := {}


func _ready() -> void:
	add_to_group("golf_club")
	position = GolfLayout.CENTER
	var half := GolfLayout.HALF
	city._mesh_box(Vector3(0, 0.004, 0), Vector3(half.x * 2, 0.01, half.y * 2), LAWN, self)
	_fence()
	city._mesh_box(Vector3(GolfLayout.GATE.x - 3.0, 0.006, 0), Vector3(6.0, 0.01, GolfLayout.GATE_WIDTH), City.ROAD, self)
	for piece in GolfLayout.path():
		_strip(piece[0], piece[1])
	for bunker: Array in GolfLayout.BUNKERS:
		_ellipse(bunker, SAND, 0.012)
	for lake: Array in GolfLayout.LAKES:
		_ellipse(lake, WATER, 0.014)
	for i in GolfLayout.HOLES.size():
		_hole(GolfLayout.HOLES[i], i)


## The hedge around the club, open at the gate.
func _fence() -> void:
	var half := GolfLayout.HALF
	var h := City.HEDGE_HEIGHT
	for z: float in [-half.y, half.y]:
		city._box(Vector3(0, h / 2, z), Vector3(half.x * 2 + 1, h, 1), City.HEDGE, self)
	city._box(Vector3(half.x, h / 2, 0), Vector3(1, h, half.y * 2), City.HEDGE, self)
	var side := half.y - GolfLayout.GATE_WIDTH / 2
	for s: float in [-1.0, 1.0]:
		city._box(Vector3(-half.x, h / 2, s * (GolfLayout.GATE_WIDTH / 2 + side / 2)), Vector3(1, h, side), City.HEDGE, self)
	var sign := Label3D.new()
	sign.text = "SIGN_GOLF"
	sign.font_size = 96
	sign.pixel_size = 0.01
	sign.outline_size = 18
	sign.double_sided = false
	sign.position = Vector3(-half.x - 0.6, h + 0.8, -GolfLayout.GATE_WIDTH / 2 - 2.0)
	sign.rotation.y = -PI / 2
	add_child(sign)


func _strip(from: Vector3, to: Vector3) -> void:
	var holder := Node3D.new()
	holder.position = (from + to) / 2 + Vector3.UP * 0.008
	holder.basis = Basis(Vector3.UP, atan2(to.x - from.x, to.z - from.z))
	add_child(holder)
	var length := from.distance_to(to) + GolfLayout.PATH_WIDTH
	city._mesh_box(Vector3.ZERO, Vector3(GolfLayout.PATH_WIDTH, 0.01, length), CONCRETE, holder)


## A flat ellipse on the lawn (a bunker or a lake): a thin cylinder, squashed.
func _ellipse(ellipse: Array, color: Color, height: float) -> void:
	var disc := CylinderMesh.new()
	disc.top_radius = 1.0
	disc.bottom_radius = 1.0
	disc.height = 0.01
	disc.radial_segments = 24
	city._mesh(disc, ellipse[0] + Vector3.UP * height, color, self)
	var shown := get_child(get_child_count() - 1) as Node3D
	shown.scale = Vector3(ellipse[1], 1, ellipse[2])


func _hole(at: Vector3, index: int) -> void:
	var green := CylinderMesh.new()
	green.top_radius = GolfLayout.GREEN_RADIUS
	green.bottom_radius = GolfLayout.GREEN_RADIUS
	green.height = 0.01
	city._mesh(green, at + Vector3.UP * 0.01, GREEN, self)
	city._mesh_box(at + Vector3(0, 1.25, 0), Vector3(0.08, 2.5, 0.08), POLE, self)
	city._mesh_box(at + Vector3(0.4, 2.25, 0), Vector3(0.7, 0.45, 0.03), FLAG, self)
	var golfer := Golfer.new()
	golfer.name = "Golfer%d" % index
	golfer.position = at + Vector3(4, 0, 3)
	golfer.wait = index * 1.3
	add_child(golfer)
	golfers.append(golfer)


## Whether a point in the world is in a bunker, or in a lake.
func in_bunker(world: Vector3) -> bool:
	return GolfLayout.in_bunker(to_local(world))


func in_lake(world: Vector3) -> bool:
	return GolfLayout.in_lake(to_local(world))


## The gate in the world, where the chase's clock starts (step 5).
func gate() -> Vector3:
	return to_global(GolfLayout.GATE)


func inside(world: Vector3) -> bool:
	return GolfLayout.inside(to_local(world))


func _physics_process(delta: float) -> void:
	for car in get_tree().get_nodes_in_group("patrol_cars"):
		if not _sinking.has(car) and not (car as PatrolCar).freeze and in_lake((car as PatrolCar).global_position):
			_sinking[car] = 0.0
			(car as PatrolCar).freeze = true
	for car: PatrolCar in _sinking.keys():
		if not is_instance_valid(car):
			_sinking.erase(car)
			continue
		_sinking[car] += delta
		car.global_position += Vector3.DOWN * SINK_RATE * delta
		if _sinking[car] >= SINK_SECONDS:
			_sinking.erase(car)
			_come_back(car)


## The sunk car turns up at the gate, still, facing into the club.
func _come_back(car: PatrolCar) -> void:
	car.global_transform = global_transform * Transform3D(Basis(Vector3.UP, PI / 2), COMES_BACK)
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	car.freeze = false
	for cop in car.passengers():
		cop.show_hint("HINT_GOLF_SUNK")
	sunk.emit(car)
