class_name BlackoutInmate
extends CharacterBody3D

## An inmate loose in the prison's blackout (carcel-corte-de-luz.md, step 3): out of their open cell, walking a route
## of points in the prison's space (BlackoutPlan): to a hiding spot where they crouch, round and round the canteen,
## or out to the yard's gate, where they escape. Lit by a cop's flashlight they freeze where they stand, with a line,
## and walk on UNFREEZE seconds after the light leaves them. In the dark only their eyes show, blinking. Cuffed they
## stay put; E then walks them by the arm (BlackoutEscort) into any cell, where they stay while its door is shut (step
## 4). Every number here is (propuesta).

signal escaped(inmate: BlackoutInmate)

enum Role { HIDE, WANDER, GATE }

const MODEL := preload("res://assets/models/npc_preso.glb")
## How fast each role walks: slower than a walking cop, so the one at the gate can be caught.
const SPEEDS := {Role.HIDE: 2.4, Role.WANDER: 1.6, Role.GATE: 2.2}
## Close enough to a route point to head for the next one.
const REACH := 0.35
const UNFREEZE := 1.0
## Walking but this stuck for STUCK_TIME seconds (pushed against a table, a door), they give up on that point.
const STUCK_TIME := 1.5
const STUCK_MOVE := 0.1
const FROZEN_LINES := 4
const SAY_TIME := 2.5
## Hidden, they crouch this much lower.
const CROUCH := 0.5
## The eyes, about the head's front (the inmate's front is -Z), and how they blink.
const EYES := Vector3(0.09, 1.45, -0.3)
const BLINK_EVERY := 3.5
const BLINK_TIME := 0.15

var role := Role.WANDER
## The route, in level space (x, z), walked once (a hide or the gate) or looped (wandering).
var route: Array[Vector2] = []
var loop := false
## Looping, they go back to this point of the route (past the way out of their cell).
var loop_from := 0
## Seconds after the blackout starts before they set off (the ones going for the gate wait a little).
var delay := 0.0
var prison: PrisonLevel
## Set by BlackoutPlan.start: they walk.
var active := false
var frozen := false
var hidden := false
var is_escaped := false
## The cell they were walked into (BlackoutEscort), -1 while loose.
var jailed_in := -1
## A guest's copy (step 7): the host walks them.
var follower := false
var _next := 0
var _dark_left := 0.0
var _cuffed_left := 0.0
var _blink_left := 0.0
var _stuck_left := STUCK_TIME
var _stuck_at := Vector3.ZERO
var _model: Node3D
var _eyes: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("blackout_inmates")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z; the inmate's front is -Z, like the other NPCs placed by code.
	_model.rotation.y = PI
	add_child(_model)
	_eyes = Node3D.new()
	_eyes.name = "Eyes"
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = Color(1, 1, 0.92)
	for side: float in [-1.0, 1.0]:
		var dot := SphereMesh.new()
		dot.radius = 0.045
		dot.height = 0.09
		var eye := MeshInstance3D.new()
		eye.mesh = dot
		eye.material_override = glow
		eye.position = Vector3(side * EYES.x, EYES.y, EYES.z)
		_eyes.add_child(eye)
	add_child(_eyes)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.85, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	_blink_left = randf_range(0.5, BLINK_EVERY)


func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	velocity = Vector3.ZERO
	say("INMATE_CUFFED")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func is_jailed() -> bool:
	return jailed_in != -1


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return ""


## E: cuffed, the escort (by the arm to a cell, or let go).
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)


## Walked into `cell` (BlackoutEscort): they stop there, standing up.
func jail(cell: int) -> void:
	jailed_in = cell
	velocity = Vector3.ZERO
	_stand()
	say("BLACKOUT_IN_CELL")


## The cell's door was left open: out of `cell` and round the canteen, like the ones wandering.
func walk_out(cell: int) -> void:
	jailed_in = -1
	role = Role.WANDER
	route = BlackoutPlan.wander_route(cell, 0)
	loop = true
	loop_from = BlackoutPlan.WAY_OUT
	_next = 0
	_stand()
	say("BLACKOUT_WALK_OUT")


func _stand() -> void:
	hidden = false
	_model.position.y = 0.0
	_eyes.position.y = 0.0


## What the escort calls (OwnerEscort): a line, and being taken by the arm upsets no one.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key, seconds)


func _raise(_points: float) -> void:
	pass


## Where they're headed next, in level space, or the last point when the route is done.
func target() -> Vector2:
	return route[mini(_next, route.size() - 1)]


func route_done() -> bool:
	return not loop and _next >= route.size()


## Lit or not (BlackoutPlan.lit): lit, they freeze at once; dark again, they wait UNFREEZE seconds and walk on.
func set_lit(lit: bool) -> void:
	if lit:
		_dark_left = UNFREEZE
		if not frozen and active and not hidden:
			say("BLACKOUT_FROZEN_%d" % randi_range(1, FROZEN_LINES))
		frozen = true
	elif frozen and _dark_left <= 0.0:
		frozen = false


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	_dark_left = maxf(_dark_left - delta, 0.0)
	if frozen and _dark_left <= 0.0:
		frozen = false
	if not active or follower or is_escaped or is_jailed() or is_cuffed() or frozen or hidden:
		velocity = Vector3.ZERO
		return
	if delay > 0.0:
		delay -= delta
		return
	if route.is_empty() or route_done():
		_arrive()
		return
	var local := prison.global_transform.affine_inverse() * global_position
	var to := target() - Vector2(local.x, local.z)
	if to.length() < REACH:
		_advance()
		return
	var step := to.normalized() * float(SPEEDS[role])
	velocity = prison.global_basis * Vector3(step.x, 0, step.y)
	velocity.y = 0.0
	look_at(global_position + velocity, Vector3.UP)
	move_and_slide()
	_stuck_left -= delta
	if _stuck_left <= 0.0:
		if global_position.distance_to(_stuck_at) < STUCK_MOVE:
			_advance()
		_stuck_left = STUCK_TIME
		_stuck_at = global_position
	if role == Role.GATE and local.z > BlackoutPlan.ESCAPE_Z:
		_escape()


func _advance() -> void:
	_next += 1
	if loop and _next >= route.size():
		_next = loop_from


## At the end of the route: the ones hiding crouch there; the ones for the gate are out.
func _arrive() -> void:
	velocity = Vector3.ZERO
	if role == Role.HIDE and not hidden:
		hidden = true
		_model.position.y = -CROUCH
		_eyes.position.y = -CROUCH
	elif role == Role.GATE:
		_escape()


func _escape() -> void:
	if is_escaped:
		return
	is_escaped = true
	active = false
	hide()
	collision_layer = 0
	escaped.emit(self)


func _process(delta: float) -> void:
	_blink_left -= delta
	if _blink_left <= 0.0:
		_eyes.visible = not _eyes.visible
		_blink_left = BLINK_EVERY + randf_range(-1.0, 1.0) if _eyes.visible else BLINK_TIME
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
