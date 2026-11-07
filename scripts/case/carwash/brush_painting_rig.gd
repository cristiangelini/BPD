class_name BrushPaintingRig
extends CarWashRig

## The painting in the brush (allanamiento-lavadero.md, "El cuadro en el cepillo"): Don Chorro hid a stolen painting
## rolled up inside one of the tunnel's side brushes for a while, and the brush has turned crooked: it leans, wobbles
## when it spins, and its bristles are smeared with paint. A cop this close to it notices, the story's own clue (on
## the checklist the first time). The car that rides through the tunnel comes out with stains of paint. Every number
## here is (propuesta).

const NOTICE_RANGE := 2.5
const CHECK_EVERY := 0.5
const LEAN := 0.18
const PAINTS: Array[Color] = [Color(0.2, 0.4, 0.9), Color(0.95, 0.65, 0.15), Color(0.85, 0.2, 0.25),
	Color(0.3, 0.8, 0.4)]
## Stains a car gets each time it rides past the crooked brush.
const STAINS_EACH := 6

var noticed := false
var brush: Node3D
var stains := 0
var _since := 0.0
var _car_x := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: CarWash) -> void:
	super.setup(place)
	_rng.seed = car_wash.case_seed
	brush = car_wash.side_brushes[1]
	brush.rotate_object_local(Vector3.RIGHT, -LEAN)
	for i in 6:
		var smear := _box(Vector3(0.6, 0.4 + i * 0.35, 0.0).rotated(Vector3.UP, i * 1.1), Vector3(0.05, 0.2, 0.25),
			PAINTS[i % PAINTS.size()])
		smear.rotation.y = i * 1.1
		brush.add_child(smear)
	_car_x = car_wash.cars[0].position.x


func _box(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	look.mesh = box
	var paint := StandardMaterial3D.new()
	paint.albedo_color = color
	look.material_override = paint
	look.position = at
	return look


func _physics_process(delta: float) -> void:
	var car := car_wash.cars[0]
	var brush_x := CarWash.SIDE_BRUSHES[1].x
	if _car_x < brush_x and car.position.x >= brush_x:
		stain(car)
	_car_x = car.position.x
	_since += delta
	if noticed or _since < CHECK_EVERY:
		return
	_since = 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(brush.global_position) <= NOTICE_RANGE:
			notice()
			return


## A cop sees the crooked brush smeared with paint: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	car_wash.raid.add_clue(tr("CLUE_CROOKED_BRUSH"))
	car_wash.raid.float_label(tr("CARWASH_CROOKED_BRUSH"), brush.global_position + Vector3.UP * 2.8, PAINTS[1])


## The car riding past the brush gets a few stains of paint on its sides.
func stain(car: Node3D) -> void:
	for i in STAINS_EACH:
		stains += 1
		var side := 1.0 if i % 2 == 0 else -1.0
		var at := Vector3(_rng.randf_range(-1.8, 1.8), _rng.randf_range(0.4, 1.1),
			side * (CarWash.CAR_SIZE.z / 2 + 0.05))
		var size := Vector3(_rng.randf_range(0.3, 0.6), _rng.randf_range(0.15, 0.35), 0.03)
		car.add_child(_box(at, size, PAINTS[_rng.randi_range(0, PAINTS.size() - 1)]))
