class_name ZooTrain
extends Node3D

## The zoo's little train (escena-zoo.md, "La hora de comer"): an engine and two cars going round its track
## (Zoo.TRACK) and never stopping. A cop in its way gets shoved aside and drops what they carry; it doesn't hurt.
## Every number here is (propuesta).

const SPEED := 3.0
const CARS := 3
const CAR_GAP := 2.4
const CAR_SIZE := Vector3(1.4, 1.2, 2.0)
## How close to a car's middle a cop gets shoved, how hard (m/s) and for how long they stagger.
const HIT_REACH := 1.3
const PUSH := 5.0
const STAGGER := 1.0
const COLORS: Array[Color] = [Color(0.85, 0.2, 0.2), Color(0.25, 0.5, 0.9), Color(0.95, 0.8, 0.2)]

## How far round the track the engine is (m), from the track's corner at -x -z.
var along := 0.0
var track := Rect2(-10, -10, 20, 22)
var cars: Array[Node3D] = []


func _ready() -> void:
	for i in CARS:
		var car := Node3D.new()
		car.name = "Car%d" % i
		add_child(car)
		var box := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = CAR_SIZE
		box.mesh = mesh
		box.position.y = CAR_SIZE.y / 2 + 0.15
		var paint := StandardMaterial3D.new()
		paint.albedo_color = COLORS[i % COLORS.size()]
		box.material_override = paint
		car.add_child(box)
		if i == 0:
			var chimney := MeshInstance3D.new()
			var pipe := CylinderMesh.new()
			pipe.top_radius = 0.15
			pipe.bottom_radius = 0.2
			pipe.height = 0.7
			chimney.mesh = pipe
			chimney.position = Vector3(0, CAR_SIZE.y + 0.5, 0.5)
			chimney.material_override = paint
			car.add_child(chimney)
		cars.append(car)
	_place()


func _physics_process(delta: float) -> void:
	along = fmod(along + SPEED * delta, perimeter())
	_place()
	for cop in get_tree().get_nodes_in_group("cops"):
		_check(cop as Cop)


func perimeter() -> float:
	return 2.0 * (track.size.x + track.size.y)


## The point `distance` metres round the track (in the zoo's space) and which way it goes there.
func point_on(distance: float) -> Array:
	var d := fposmod(distance, perimeter())
	var w := track.size.x
	var h := track.size.y
	var p := track.position
	if d < w:
		return [Vector3(p.x + d, 0, p.y), Vector3.RIGHT]
	d -= w
	if d < h:
		return [Vector3(p.x + w, 0, p.y + d), Vector3.BACK]
	d -= h
	if d < w:
		return [Vector3(p.x + w - d, 0, p.y + h), Vector3.LEFT]
	d -= w
	return [Vector3(p.x, 0, p.y + h - d), Vector3.FORWARD]


## A cop by a car: shoved off the track, staggered, and what they carried falls.
func _check(cop: Cop) -> void:
	if cop.is_staggered():
		return
	var local := get_parent_node_3d().to_local(cop.global_position) if get_parent_node_3d() else cop.global_position
	for car in cars:
		var off := Vector3(local.x - car.position.x, 0, local.z - car.position.z)
		if off.length() > HIT_REACH:
			continue
		var heading: Vector3 = point_on(along - cars.find(car) * CAR_GAP)[1]
		var aside := heading.cross(Vector3.UP).normalized()
		if aside.dot(off) < 0.0:
			aside = -aside
		var world := get_parent_node_3d().global_transform.basis * aside if get_parent_node_3d() else aside
		cop.get_node("Grabber").release()
		cop.knock_back(world * PUSH, STAGGER)
		cop.show_hint("HINT_ZOO_TRAIN")
		return


func _place() -> void:
	for i in cars.size():
		var at: Array = point_on(along - i * CAR_GAP)
		cars[i].position = at[0]
		cars[i].rotation.y = atan2((at[1] as Vector3).x, (at[1] as Vector3).z)
