class_name NurseryIrrigation
extends Node

## The nursery's watering (docs/diseno/allanamiento-vivero.md, "El riego y la Dentuda", step 2): every EVERY seconds,
## or when someone presses the valve in the shed, the yard's four sprinklers come on for RUN_SECONDS. Each one's jet
## turns around it; what the jet sweeps over, if it weighs up to PUSH_KG, flies off, and a cop it catches gets a little
## push and gets wet. When they stop, the yard's grass is mud for MUD_SECONDS, and a cop running on it slips. Every
## number here is (propuesta).

## The sprinklers came on.
signal started
## A cop or a thing got wet (the watering can and the diamonds' pot listen, steps 5 and 7).
signal soaked(body: Node3D)
## A cop slipped in the mud (Doña Hortensia sees it, step 4).
signal slipped(cop: Cop)

const EVERY := 40.0
const RUN_SECONDS := 15.0
const MUD_SECONDS := 20.0
## How far a jet reaches from its sprinkler, how wide it hits (radians each side) and how fast it turns (turns per
## second).
const JET_REACH := 3.5
const JET_HALF_ANGLE := 0.3
const SPIN := 0.4
## Things up to PUSH_KG fly off at PUSH_SPEED; a cop gets COP_PUSH.
const PUSH_KG := 3.0
const PUSH_SPEED := 4.0
const COP_PUSH := 2.0
## Running faster than SLIP_SPEED on the mud is a slip: the cop slides on with SLIP_KEEP of its speed and can't walk
## for SLIP_SECONDS.
const SLIP_SPEED := 4.0
const SLIP_KEEP := 0.8
const SLIP_SECONDS := 1.0
## The same jet catches the same cop or thing, and the mud trips the same cop, again only after HIT_EVERY seconds.
const HIT_EVERY := 1.5
const MUD := Color(0.42, 0.27, 0.13)

var nursery: Nursery
## Seconds until the next watering, while it runs and while the mud lasts.
var wait_left := EVERY
var run_left := 0.0
var mud_left := 0.0
var runs := 0
var slips := 0
## Whatever got wet, once each (instance ids).
var wet := {}
## What a jet or the mud hit lately (key -> seconds left).
var _hit := {}


func is_running() -> bool:
	return run_left > 0.0


func is_muddy() -> bool:
	return mud_left > 0.0


func start() -> void:
	if is_running():
		return
	run_left = RUN_SECONDS
	wait_left = EVERY
	mud_left = 0.0
	runs += 1
	for jet in nursery.jets:
		jet.show()
	_paint_yard()
	started.emit()


func stop() -> void:
	run_left = 0.0
	mud_left = MUD_SECONDS
	for jet in nursery.jets:
		jet.hide()
	_paint_yard()


func _physics_process(delta: float) -> void:
	tick(delta)


## Moves the watering on by `delta` seconds: the clock (a watering starts every EVERY seconds), the jets and the mud.
func tick(delta: float) -> void:
	for key: String in _hit.keys():
		_hit[key] -= delta
		if _hit[key] <= 0.0:
			_hit.erase(key)
	wait_left -= delta
	if is_running():
		run_left = maxf(run_left - delta, 0.0)
		for head in nursery.sprinkler_heads:
			head.rotate_y(SPIN * TAU * delta)
		_water()
		if run_left <= 0.0:
			stop()
	elif is_muddy():
		mud_left = maxf(mud_left - delta, 0.0)
		for node in get_tree().get_nodes_in_group("cops"):
			var cop := node as Cop
			if cop and nursery.is_ancestor_of(cop):
				_mud(cop)
		if not is_muddy():
			_paint_yard()
	if wait_left <= 0.0 and not is_running():
		start()


## Each jet sweeps over cops and things in its reach.
func _water() -> void:
	for i in nursery.sprinkler_heads.size():
		var head := nursery.sprinkler_heads[i]
		for node in get_tree().get_nodes_in_group("cops"):
			var cop := node as Cop
			if cop and nursery.is_ancestor_of(cop) and in_jet(head, cop.global_position) and _ready_to_hit(cop, i):
				cop.knock_back(_outward(head, cop.global_position) * COP_PUSH, 0.3)
				cop.show_hint("HINT_NURSERY_SPRINKLER")
				_soak(cop)
		for node in nursery.find_children("*", "RigidBody3D", true, false):
			var body := node as RigidBody3D
			if body.freeze or not in_jet(head, body.global_position) or not _ready_to_hit(body, i):
				continue
			_soak(body)
			if body.mass <= PUSH_KG:
				body.apply_central_impulse((_outward(head, body.global_position) + Vector3.UP * 0.5) * PUSH_SPEED
					* body.mass)


## Whether `at` (global) is in the reach of the jet of sprinkler `head`, inside the slice it points at.
func in_jet(head: Node3D, at: Vector3) -> bool:
	var off := at - head.global_position
	off.y = 0.0
	if off.length() > JET_REACH + 0.3 or off.length() < 0.05:
		return false
	var aim := head.global_basis.x
	aim.y = 0.0
	return absf(aim.signed_angle_to(off, Vector3.UP)) < JET_HALF_ANGLE


## A cop running on the mud slips: it slides on and can't walk for a moment.
func _mud(cop: Cop) -> void:
	if not Nursery.in_yard(nursery.to_local(cop.global_position)) or not cop.is_running or cop.is_staggered():
		return
	var speed := Vector3(cop.velocity.x, 0, cop.velocity.z)
	if speed.length() < SLIP_SPEED or not _ready_to_hit(cop, -1):
		return
	slips += 1
	cop.knock_back(speed * SLIP_KEEP, SLIP_SECONDS)
	cop.show_hint("HINT_NURSERY_MUD_SLIP")
	slipped.emit(cop)


func _outward(head: Node3D, at: Vector3) -> Vector3:
	var off := at - head.global_position
	off.y = 0.0
	return off.normalized() if off.length() > 0.01 else head.global_basis.x


func _soak(body: Node3D) -> void:
	if wet.has(body.get_instance_id()):
		return
	wet[body.get_instance_id()] = true
	soaked.emit(body)


func _ready_to_hit(body: Node3D, what: int) -> bool:
	var key := "%d:%d" % [body.get_instance_id(), what]
	if _hit.has(key):
		return false
	_hit[key] = HIT_EVERY
	return true


## The yard's grass shows wet while it runs and mud while it lasts.
func _paint_yard() -> void:
	var color := Nursery.GRASS
	if is_running():
		color = Nursery.GRASS.darkened(0.25)
	elif is_muddy():
		color = MUD
	var look := StandardMaterial3D.new()
	look.albedo_color = color
	look.roughness = 0.45 if color == MUD else 0.9
	nursery.yard_ground.material_override = look
