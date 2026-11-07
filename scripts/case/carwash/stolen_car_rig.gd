class_name StolenCarRig
extends CarWashRig

## The stolen car (allanamiento-lavadero.md, "El auto robado"): the first car in line is a stolen one, with a fake plate
## taped over the real one, and a cop this close to its back sees the tape, the story's own clue (on the checklist the
## first time). The car rides through the tunnel on its own again and again, to wash off its old paint. Every number
## here is (propuesta).

const NOTICE_RANGE := 2.5
const CHECK_EVERY := 0.5
## It sets off again RIDE_EVERY seconds after it got back to its place in line, and waits WAIT_OUT seconds out.
const RIDE_EVERY := 20.0
const WAIT_OUT := 4.0
const PLATE := Color(0.95, 0.95, 0.92)
const TAPE := Color(0.75, 0.7, 0.55)

var noticed := false
var rides := 0
var plate: MeshInstance3D
var _since := 0.0
var _home_for := 0.0
var _out_for := 0.0


func setup(place: CarWash) -> void:
	super.setup(place)
	var rear := -CarWash.CAR_SIZE.x / 2 - 0.06
	plate = _box(Vector3(rear, 0.8, 0), Vector3(0.02, 0.16, 0.55), PLATE)
	for z: float in [-0.15, 0.15]:
		var tape := _box(Vector3(rear - 0.01, 0.8, z), Vector3(0.02, 0.24, 0.07), TAPE)
		tape.rotation.x = 0.6 if z > 0 else -0.6


## A box on the stolen car, in its space, so it rides along.
func _box(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	look.mesh = box
	var paint := StandardMaterial3D.new()
	paint.albedo_color = color
	look.material_override = paint
	look.position = at
	car_wash.cars[0].add_child(look)
	return look


func _physics_process(delta: float) -> void:
	var premium := car_wash.premium
	if premium.is_home() and not premium.is_drying():
		_home_for += delta
		if _home_for >= RIDE_EVERY and premium.ride_alone():
			_home_for = 0.0
			rides += 1
	if premium.is_out() and not premium.is_drying():
		_out_for += delta
		if _out_for >= WAIT_OUT:
			_out_for = 0.0
			premium.ride_home()
	_since += delta
	if noticed or _since < CHECK_EVERY:
		return
	_since = 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(plate.global_position) <= NOTICE_RANGE:
			notice()
			return


## A cop sees the plate taped on: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	car_wash.raid.add_clue(tr("CLUE_TAPED_PLATE"))
	car_wash.raid.float_label(tr("CARWASH_TAPED_PLATE"), plate.global_position + Vector3.UP * 0.8, TAPE)
