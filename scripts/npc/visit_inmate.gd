class_name VisitInmate
extends CharacterBody3D

## An inmate on the prison's visiting day (carcel-visitas.md, step 5): sitting at a canteen table across from their
## visitor, waiting. Whatever the visitor slips them under the table goes into their jumpsuit (`received`); when the
## bell rings at the end of the visit, the ones who got something stand up and stroll out through the gate with it.
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_preso.glb")
const SPEED := 1.6
const REACH := 0.3
const SAY_TIME := 3.0

var prison: PrisonLevel
## Their seat (level space x, z): across the table from their visitor's.
var seat := Vector2.ZERO
## The Contraband.Kind of each thing they were slipped.
var received: Array[int] = []
var is_gone := false
var route: Array[Vector2] = []
var _next := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("visit_inmates")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z, and so do they: toward the table and their visitor beyond it.
	add_child(_model)
	_model.position.y = -PrisonVisitor.SIT_DROP
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


## Slipped `kind` (a Contraband.Kind) under the table.
func receive(kind: int) -> void:
	received.append(kind)
	say("INMATE_GOT_IT")


## The bell: off they go through the gate, if they got something.
func leave_if_slipped() -> bool:
	if received.is_empty():
		return false
	_model.position.y = 0.0
	route = VisitPlan.way_out(seat)
	_next = 0
	say("INMATE_LEAVES")
	return true


## What a guest's copy needs besides where they are and what they say (NpcSync, step 7).
func net_state() -> Array:
	return [received.size(), is_gone, not route.is_empty()]


func apply_net_state(net: Variant) -> void:
	while received.size() < net[0]:
		received.append(-1)
	_model.position.y = 0.0 if net[2] else -PrisonVisitor.SIT_DROP
	if net[1] and not is_gone:
		is_gone = true
		hide()
		collision_layer = 0


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	if is_gone or _next >= route.size():
		return
	var local := prison.global_transform.affine_inverse() * global_position
	var to := route[_next] - Vector2(local.x, local.z)
	if to.length() < REACH:
		_next += 1
		if _next >= route.size():
			is_gone = true
			hide()
			collision_layer = 0
		return
	var step := to.normalized() * SPEED
	velocity = prison.global_basis * Vector3(step.x, 0, step.y)
	velocity.y = 0.0
	# Their model faces +Z: turn so that's where they walk.
	look_at(global_position - velocity, Vector3.UP)
	move_and_slide()
