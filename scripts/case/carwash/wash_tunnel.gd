class_name WashTunnel
extends Node

## The car wash's tunnel at work (docs/diseno/allanamiento-lavadero.md, "El túnel", step 2): the button by its mouth
## sets it going for RUN_SECONDS. Its conveyor drags whatever is on it (a box, a cop) toward the end at BELT_SPEED; the
## jets arch soaks what passes under it; the brushes spin, and the side ones shove what comes near them to the middle
## while the top one pats a cop on the head and pushes him back a little; the foam curtain hides everything from a cop
## going through it; and the blower at the end throws light things out and gives a cop a push. When it stops,
## everything stays where it got to. Every number here is (propuesta).

## It started a run (Don Chorro minds it, step 3).
signal started
## Something passed under the jets while they ran (the chamois gets wet, step 4).
signal soaked(body: Node3D)

const RUN_SECONDS := 30.0
const BELT_SPEED := 1.2
## The brushes' turns per second, how far past their bristles they reach and how hard they shove.
const BRUSH_SPIN := 1.5
const BRUSH_RADIUS := 0.6
const BRUSH_REACH := 0.35
const BRUSH_SHOVE := 2.5
const TOP_BRUSH_PUSH := 1.5
## How wide (along the tunnel) the jets, the curtain and the blower work.
const JETS_REACH := 0.5
const CURTAIN_REACH := 0.6
const BLOWER_REACH := 1.0
## The blower throws things up to BLOW_KG at BLOW_SPEED, and pushes a cop with BLOW_PUSH.
const BLOW_KG := 3.0
const BLOW_SPEED := 6.0
const BLOW_PUSH := 4.0
## A cop or a thing is shoved again by the same brush or blower only after HIT_EVERY seconds.
const HIT_EVERY := 1.0

var car_wash: CarWash
var run_left := 0.0
var runs := 0
## Whatever the jets soaked, once each (instance ids).
var wet := {}
## What a brush or the blower hit lately (instance id -> seconds left).
var _hit := {}
## The local player's screen under the foam.
var _foam: ColorRect


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	_foam = ColorRect.new()
	_foam.color = Color(0.95, 0.97, 1.0, 0.92)
	_foam.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_foam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_foam.hide()
	layer.add_child(_foam)
	add_child(layer)


func is_running() -> bool:
	return run_left > 0.0


func start() -> void:
	if is_running():
		return
	run_left = RUN_SECONDS
	runs += 1
	car_wash.conveyor.constant_linear_velocity = Vector3(BELT_SPEED, 0, 0)
	for spray in car_wash.sprays:
		spray.show()
	started.emit()


## Online, what the guests' tunnel takes from the host's (CarWash.net_state): started there, it starts here too, and
## it stops when the host's does.
func net_state() -> Array:
	return [runs, run_left]


func apply_net_state(state: Array) -> void:
	if state[0] > runs:
		start()
		runs = state[0]
	if is_running() and state[1] <= 0.0:
		stop()
	elif is_running():
		run_left = state[1]


func stop() -> void:
	run_left = 0.0
	car_wash.conveyor.constant_linear_velocity = Vector3.ZERO
	for spray in car_wash.sprays:
		spray.hide()
	_foam.hide()


func _physics_process(delta: float) -> void:
	if not is_running():
		return
	run_left = maxf(run_left - delta, 0.0)
	for key: String in _hit.keys():
		_hit[key] -= delta
		if _hit[key] <= 0.0:
			_hit.erase(key)
	for brush in car_wash.side_brushes:
		brush.rotate_y(BRUSH_SPIN * TAU * delta)
	car_wash.top_brush.rotate_object_local(Vector3.UP, BRUSH_SPIN * TAU * delta)
	var blinded := false
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop:
			_wash_cop(cop, delta)
			blinded = blinded or (cop.input_enabled and foam_covers(cop.global_position))
	_foam.visible = blinded
	for body in car_wash.find_children("*", "RigidBody3D", true, false):
		_wash_thing(body as RigidBody3D)
	if run_left <= 0.0:
		stop()


## A cop in the tunnel: dragged by the conveyor, soaked by the jets, shoved by the brushes and pushed out by the
## blower.
func _wash_cop(cop: Cop, delta: float) -> void:
	var at := car_wash.to_local(cop.global_position)
	if not _beside_belt(at):
		return
	if CarWash.in_tunnel(at) and at.y < CarWash.CONVEYOR_TOP + 0.3:
		cop.global_position += car_wash.global_basis.x * BELT_SPEED * delta
	if absf(at.x - CarWash.JETS_X) < JETS_REACH:
		_soak(cop)
	for brush_at in CarWash.SIDE_BRUSHES:
		var off := Vector3(at.x - brush_at.x, 0, at.z - brush_at.z)
		if off.length() < BRUSH_RADIUS + BRUSH_REACH + 0.3 and _ready_to_hit(cop, "brush"):
			cop.knock_back(car_wash.global_basis * (Vector3(0, 0, -signf(brush_at.z)) * BRUSH_SHOVE), 0.4)
			cop.show_hint("HINT_CARWASH_BRUSH")
	if absf(at.x - CarWash.TOP_BRUSH.x) < BRUSH_RADIUS + BRUSH_REACH and _ready_to_hit(cop, "top"):
		cop.knock_back(car_wash.global_basis * (Vector3(-TOP_BRUSH_PUSH, 0, 0)), 0.3)
		cop.show_hint("HINT_CARWASH_TOP_BRUSH")
	if absf(at.x - CarWash.BLOWER_X) < BLOWER_REACH and _ready_to_hit(cop, "blower"):
		cop.knock_back(car_wash.global_basis * Vector3(BLOW_PUSH, 0, 0), 0.5)
		cop.show_hint("HINT_CARWASH_BLOWER")


## A thing in the tunnel: the conveyor drags it on its own (constant_linear_velocity); the jets soak it, the brushes
## shove it to the middle and the blower throws it out if it's light.
func _wash_thing(body: RigidBody3D) -> void:
	if body.freeze:
		return
	var at := car_wash.to_local(body.global_position)
	if at.x < CarWash.TUNNEL_X0 or at.x > CarWash.TUNNEL_X1 or absf(at.z) > CarWash.TUNNEL_HALF_Z:
		return
	if absf(at.x - CarWash.JETS_X) < JETS_REACH:
		_soak(body)
	for brush_at in CarWash.SIDE_BRUSHES:
		var off := Vector3(at.x - brush_at.x, 0, at.z - brush_at.z)
		if off.length() < BRUSH_RADIUS + BRUSH_REACH and _ready_to_hit(body, "brush"):
			body.apply_central_impulse(car_wash.global_basis * Vector3(0.5, 0.5, -signf(brush_at.z) * BRUSH_SHOVE)
				* body.mass)
	if absf(at.x - CarWash.BLOWER_X) < BLOWER_REACH and body.mass <= BLOW_KG and _ready_to_hit(body, "blower"):
		body.apply_central_impulse(car_wash.global_basis * Vector3(BLOW_SPEED, BLOW_SPEED * 0.5, 0) * body.mass)


func _soak(body: Node3D) -> void:
	if wet.has(body.get_instance_id()):
		return
	wet[body.get_instance_id()] = true
	soaked.emit(body)


func _beside_belt(at: Vector3) -> bool:
	return at.x > CarWash.TUNNEL_X0 and at.x < CarWash.TUNNEL_X1 and absf(at.z) < CarWash.TUNNEL_HALF_Z


func _ready_to_hit(body: Node3D, what: String) -> bool:
	var key := "%d:%s" % [body.get_instance_id(), what]
	if _hit.has(key):
		return false
	_hit[key] = HIT_EVERY
	return true


## Whether a cop at `at` (global) has his eyes in the foam curtain.
func foam_covers(at: Vector3) -> bool:
	var local := car_wash.to_local(at)
	return is_running() and absf(local.x - CarWash.CURTAIN_X) < CURTAIN_REACH and absf(local.z) < CarWash.TUNNEL_HALF_Z
