class_name FakeShampooRig
extends CarWashRig

## The fake shampoo (allanamiento-lavadero.md, "El champú trucho"): Don Chorro fills bottles with something that isn't
## shampoo and sells them as the real brand. The foam comes out green: the foam tank's and, while the tunnel runs, the
## jets'. A cop this close to the tank or to the running jets smells it, the story's own clue (on the checklist the
## first time). While the tunnel runs, giant bubbles float out of its end and drift up through the hall until they pop.
## Every number here is (propuesta).

const SMELL_RANGE := 3.0
const CHECK_EVERY := 0.5
const GREEN := Color(0.45, 0.9, 0.35)
const GREEN_WATER := Color(0.45, 0.95, 0.4, 0.4)
## While the tunnel runs, a bubble every BUBBLE_EVERY seconds, BUBBLE_RISE meters up in BUBBLE_LIFE seconds.
const BUBBLE_EVERY := 1.5
const BUBBLE_LIFE := 6.0
const BUBBLE_RISE := 3.5
const BUBBLE := Color(0.75, 1.0, 0.75, 0.35)

var smelled := false
var bubbles := 0
var _since := 0.0
var _since_bubble := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: CarWash) -> void:
	super.setup(place)
	_rng.seed = car_wash.case_seed
	var foam := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = CarWash.FOAM_TANK_SIZE - Vector3(0.1, CarWash.FOAM_TANK_SIZE.y - 0.12, 0.1)
	foam.mesh = box
	foam.material_override = _paint(GREEN)
	foam.position = CarWash.FOAM_TANK_AT + Vector3(0, CarWash.FOAM_TANK_SIZE.y - 0.08, 0)
	car_wash.add_child(foam)
	for spray in car_wash.sprays:
		spray.material_override = _paint(GREEN_WATER)


func _paint(color: Color) -> StandardMaterial3D:
	var paint := StandardMaterial3D.new()
	paint.albedo_color = color
	if color.a < 1.0:
		paint.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return paint


func _physics_process(delta: float) -> void:
	var running := car_wash.tunnel.is_running()
	if running:
		_since_bubble += delta
		if _since_bubble >= BUBBLE_EVERY:
			_since_bubble = 0.0
			bubble()
	_since += delta
	if smelled or _since < CHECK_EVERY:
		return
	_since = 0.0
	var tank := car_wash.to_global(CarWash.FOAM_TANK_AT)
	var jets := car_wash.to_global(Vector3(CarWash.JETS_X, CarWash.FLOOR_TOP, 0))
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var at := cop.global_position
		if at.distance_to(tank) <= SMELL_RANGE or (running and at.distance_to(jets) <= SMELL_RANGE):
			smell(at)
			return


## A cop smells the green foam: the first time it's a clue.
func smell(at: Vector3) -> void:
	if smelled:
		return
	smelled = true
	car_wash.raid.add_clue(tr("CLUE_GREEN_FOAM"))
	car_wash.raid.float_label(tr("CARWASH_SMELL"), at + Vector3.UP * 2.0, GREEN)


## A giant bubble floats out of the tunnel's end, drifts up and pops.
func bubble() -> void:
	bubbles += 1
	var ball := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	var radius := _rng.randf_range(0.3, 0.6)
	sphere.radius = radius
	sphere.height = radius * 2
	ball.mesh = sphere
	ball.material_override = _paint(BUBBLE)
	ball.position = Vector3(CarWash.TUNNEL_X1 + 0.5, CarWash.FLOOR_TOP + 1.5, _rng.randf_range(-1.2, 1.2))
	car_wash.add_child(ball)
	var to := ball.position + Vector3(_rng.randf_range(1.0, 5.0), BUBBLE_RISE, _rng.randf_range(-3.0, 3.0))
	var drift := ball.create_tween()
	drift.tween_property(ball, "position", to, BUBBLE_LIFE).set_trans(Tween.TRANS_SINE)
	drift.tween_property(ball, "scale", Vector3.ONE * 1.3, 0.15)
	drift.tween_callback(ball.queue_free)
