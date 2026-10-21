class_name ChaseDrops
extends Node

## What each suspect leaves on the street behind him (persecucion.md, "Los sospechosos"): the ice cream man drips ice
## cream every DRIP_EVERY seconds, and on a puddle the patrol car's tires lose their grip; the moving truck drops a piece
## of furniture at every corner he turns, which is in the way (a loose body: knocking it over isn't a fine, but it
## slows you down); the school bus is full of kids shouting out of the windows. Every number here is (propuesta).

const DRIP_EVERY := 3.0
## A puddle's size (m), how long it lasts, and the grip left on it.
const PUDDLE_RADIUS := 2.2
const PUDDLE_SECONDS := 25.0
const PUDDLE_GRIP := 0.2
## The furniture: model, collision size and weight (kg); at most this many on the street.
const FURNITURE := [
	{"model": preload("res://assets/models/falling_sofa.glb"), "size": Vector3(1.8, 0.9, 0.8), "mass": 60.0},
	{"model": preload("res://assets/models/falling_wardrobe.glb"), "size": Vector3(0.9, 1.5, 0.5), "mass": 70.0},
	{"model": preload("res://assets/models/falling_lamp.glb"), "size": Vector3(0.5, 1.6, 0.5), "mass": 8.0},
	{"model": preload("res://assets/models/falling_box.glb"), "size": Vector3(0.6, 0.5, 0.6), "mass": 12.0},
]
const MAX_FURNITURE := 12
## Where it falls off: this far behind his back.
const BEHIND := 3.5
## The kids shout a line every this many seconds.
const KIDS_EVERY := 2.5
const KIDS_LINES := ["CHASE_KIDS_1", "CHASE_KIDS_2", "CHASE_KIDS_3", "CHASE_KIDS_4", "CHASE_KIDS_5"]

var case: ChaseCase
## The ice cream puddles on the street: [mesh, seconds left].
var puddles: Array[Array] = []
var furniture: Array[RigidBody3D] = []
var _drip_left := DRIP_EVERY
var _kids_left := 0.0
var _kids_line := 0
var kids_bubble: Label3D
var _rng := RandomNumberGenerator.new()
var _wheels: Array[VehicleWheel3D] = []
var _grip: Array[float] = []
## The grip the weather leaves the patrol car's tires (ChaseWeather, the rain).
var weather_grip := 1.0


func _ready() -> void:
	_rng.seed = hash("drops %d" % case.case_seed)
	for child in case.car.get_children():
		if child is VehicleWheel3D:
			_wheels.append(child)
			_grip.append((child as VehicleWheel3D).wheel_friction_slip)
	case.truck.corner_passed.connect(_on_corner)
	if case.suspect_id == "school_bus":
		kids_bubble = Label3D.new()
		kids_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		kids_bubble.pixel_size = 0.006
		kids_bubble.outline_size = 12
		kids_bubble.font_size = 44
		kids_bubble.modulate = Color(1, 0.95, 0.6)
		kids_bubble.position.y = 3.6
		kids_bubble.hide()
		case.truck.add_child(kids_bubble)


func _physics_process(delta: float) -> void:
	if case.suspect_id == "ice_cream" and case.chasing and not case.stopped:
		_drip_left -= delta
		if _drip_left <= 0.0:
			_drip_left = DRIP_EVERY
			drip()
	if kids_bubble and case.chasing and not case.stopped:
		_kids_left -= delta
		if _kids_left <= 0.0:
			_kids_left = KIDS_EVERY
			kids_bubble.text = KIDS_LINES[_kids_line % KIDS_LINES.size()]
			kids_bubble.show()
			_kids_line += 1
	elif kids_bubble:
		kids_bubble.hide()
	for puddle in puddles.duplicate():
		puddle[1] -= delta
		if puddle[1] <= 0.0:
			(puddle[0] as Node).queue_free()
			puddles.erase(puddle)
	var slippery := on_puddle(case.car.global_position)
	for i in _wheels.size():
		_wheels[i].wheel_friction_slip = _grip[i] * weather_grip * (PUDDLE_GRIP if slippery else 1.0)


## Whether `at` is on an ice cream puddle.
func on_puddle(at: Vector3) -> bool:
	for puddle in puddles:
		var center: Vector3 = (puddle[0] as Node3D).global_position
		if Vector2(at.x - center.x, at.z - center.z).length() < PUDDLE_RADIUS:
			return true
	return false


## A puddle of melted ice cream on the street behind him.
func drip() -> MeshInstance3D:
	var disc := CylinderMesh.new()
	disc.top_radius = PUDDLE_RADIUS
	disc.bottom_radius = PUDDLE_RADIUS
	disc.height = 0.02
	disc.radial_segments = 10
	var colors := [Color(0.95, 0.45, 0.65), Color(0.35, 0.8, 0.62), Color(0.85, 0.65, 0.35)]
	var puddle := CopTool.piece(disc, colors[_rng.randi() % colors.size()])
	case.get_parent().add_child(puddle)
	var at := _behind()
	at.y = 0.02
	puddle.global_position = at
	puddles.append([puddle, PUDDLE_SECONDS])
	return puddle


func _on_corner(turned: bool) -> void:
	if case.suspect_id == "moving_truck" and turned and case.chasing and not case.stopped:
		drop_furniture()


## A piece of furniture falls off the back of the moving truck.
func drop_furniture() -> RigidBody3D:
	if furniture.size() >= MAX_FURNITURE:
		furniture.pop_front().queue_free()
	var piece: Dictionary = FURNITURE[_rng.randi() % FURNITURE.size()]
	var body := RigidBody3D.new()
	body.mass = piece.mass
	body.add_to_group("chase_furniture")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = piece.size
	shape.shape = box
	shape.position.y = box.size.y / 2
	body.add_child(shape)
	body.add_child((piece.model as PackedScene).instantiate())
	case.get_parent().add_child(body)
	body.global_position = _behind() + Vector3.UP * 0.6
	body.rotation.y = _rng.randf() * TAU
	furniture.append(body)
	return body


func _behind() -> Vector3:
	var truck := case.truck
	return truck.global_position - truck.global_basis.z * BEHIND
