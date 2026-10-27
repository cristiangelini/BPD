class_name LaunderedMoneyRig
extends CarWashRig

## The laundered money (allanamiento-lavadero.md, "La plata lavada"): Don Chorro washes stolen bills in the tunnel. A
## few of them hang drying among the towels on the line, and a cop this close to the line notices, the story's own
## clue (on the checklist the first time). While the tunnel runs, the blower throws bills up into the air. Every number
## here is (propuesta).

const NOTICE_RANGE := 3.0
const CHECK_EVERY := 0.5
const LINE_BILLS := 5
const BILL := Color(0.5, 0.78, 0.48)
const BILL_SIZE := Vector3(0.3, 0.14, 0.01)
## While the tunnel runs, BLOWN_EACH bills fly up from the blower every BLOW_EVERY seconds, for BILL_LIFE seconds.
const BLOW_EVERY := 1.0
const BLOWN_EACH := 3
const BILL_LIFE := 2.5

var noticed := false
var bills_blown := 0
var line_bills: Array[MeshInstance3D] = []
var _since := 0.0
var _since_blow := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: CarWash) -> void:
	super.setup(place)
	_rng.seed = car_wash.case_seed
	for i in LINE_BILLS:
		var x := CarWash.LINE_XS[0] + 1.1 + i * 1.15
		line_bills.append(_bill(Vector3(x, CarWash.FLOOR_TOP + 1.85, CarWash.LINE_Z + 0.02), 0.0))


func _bill(at: Vector3, tilt: float) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = BILL_SIZE
	look.mesh = box
	var paint := StandardMaterial3D.new()
	paint.albedo_color = BILL
	look.material_override = paint
	look.position = at
	look.rotation.z = tilt
	car_wash.add_child(look)
	return look


func _physics_process(delta: float) -> void:
	_since += delta
	if not noticed and _since >= CHECK_EVERY:
		_since = 0.0
		var line_at := car_wash.to_global(Vector3((CarWash.LINE_XS[0] + CarWash.LINE_XS[1]) / 2, 1.5, CarWash.LINE_Z))
		for cop: Node3D in get_tree().get_nodes_in_group("cops"):
			if _near_line(car_wash.to_local(cop.global_position)):
				notice(line_at)
				break
	if car_wash.tunnel.is_running():
		_since_blow += delta
		if _since_blow >= BLOW_EVERY:
			_since_blow = 0.0
			blow()


func _near_line(at: Vector3) -> bool:
	var x := clampf(at.x, CarWash.LINE_XS[0], CarWash.LINE_XS[1])
	return Vector2(at.x - x, at.z - CarWash.LINE_Z).length() <= NOTICE_RANGE


## A cop sees the bills drying among the towels: the first time it's a clue.
func notice(at: Vector3) -> void:
	if noticed:
		return
	noticed = true
	car_wash.raid.add_clue(tr("CLUE_BILLS_DRYING"))
	car_wash.raid.float_label(tr("CARWASH_BILLS"), at + Vector3.UP * 0.6, BILL)


## The blower throws a handful of bills up into the air; they flutter and are gone.
func blow() -> void:
	for i in BLOWN_EACH:
		bills_blown += 1
		var from := Vector3(CarWash.BLOWER_X + 0.3, CarWash.FLOOR_TOP + 2.4, _rng.randf_range(-1.0, 1.0))
		var bill := _bill(from, _rng.randf_range(-1.0, 1.0))
		var to := from + Vector3(_rng.randf_range(1.5, 4.0), _rng.randf_range(0.5, 1.8), _rng.randf_range(-1.5, 1.5))
		var flight := bill.create_tween().set_parallel()
		flight.tween_property(bill, "position", to, BILL_LIFE).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		flight.tween_property(bill, "rotation", Vector3(_rng.randf() * TAU, _rng.randf() * TAU, 0), BILL_LIFE)
		flight.chain().tween_callback(bill.queue_free)
