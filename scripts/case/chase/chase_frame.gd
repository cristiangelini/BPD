class_name ChaseFrame
extends RigidBody3D

## An empty gilt frame that falls out of the back of the museum's art van (escena-museo.md, "El tablero y el final";
## ChaseDrops): it lies in the street, in the patrol car's way. E (the one riding along, or anyone on foot) moves it
## aside; the patrol car going over it fast breaks it, and every broken frame is taken off the salary, because they're
## the museum's (CrimeSceneCase.frame_broken). Every number here is (propuesta).

const MODEL := preload("res://assets/models/chase_frame.glb")
const SIZE := Vector3(1.2, 0.06, 1.0)
const MASS := 8.0
## The patrol car this close to its middle, at this speed or more (m/s), breaks it.
const REACH := 1.8
const BREAK_SPEED := 2.0

## The patrol car that can run over it.
var car: Node3D
var broken := false
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_frames")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_MOVE_FRAME"


## E: leaned against a lamppost, out of the way.
func use(cop: Cop) -> void:
	if cop:
		cop.show_hint("HINT_FRAME_MOVED")
	queue_free()


## Run over: it breaks, and the museum's case hears of it.
func run_over() -> void:
	if broken:
		return
	broken = true
	get_tree().call_group("crime_scene", "frame_broken")
	queue_free()


func _physics_process(delta: float) -> void:
	if broken or not is_instance_valid(car):
		return
	var at := car.global_position
	var speed := 0.0 if _car_at == Vector3.INF else (at - _car_at).length() / delta
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and speed >= BREAK_SPEED:
		run_over()
