class_name ChaseYarn
extends RigidBody3D

## A ball of wool the culprit throws out of his aunt's golden limousine (escena-gato.md, "El tablero y el final";
## ChaseDrops): it rolls down the street. E (the one riding along, or anyone on foot) picks it up; the patrol car going
## over it fast gets the wool wound round its wheels and goes at half its speed for TANGLE_SECONDS. Every number here
## is (propuesta).

const MODEL := preload("res://assets/models/yarn_ball.glb")
const RADIUS := 0.25
const MASS := 0.5
## Thrown out, it rolls back this fast.
const ROLL := 3.0
## The patrol car this close to its middle, at this speed or more (m/s), runs over it.
const REACH := 1.8
const RUN_OVER_SPEED := 2.0
const TANGLE_SECONDS := 2.0

## The patrol car that can run over it, and the drops that slow it down.
var car: Node3D
var drops: ChaseDrops
var run_over_once := false
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_yarns")
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = RADIUS
	shape.shape = ball
	shape.position.y = RADIUS
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PICK_YARN"


## E: wound up and put away.
func use(cop: Cop) -> void:
	if cop:
		cop.show_hint("HINT_YARN_PICKED")
	queue_free()


## Run over: the wool winds round the patrol car's wheels.
func run_over(speed: float) -> void:
	if run_over_once:
		return
	run_over_once = true
	if drops:
		drops.tangle(speed)
	queue_free()


func _physics_process(delta: float) -> void:
	if run_over_once or not is_instance_valid(car):
		return
	var at := car.global_position
	var speed := 0.0 if _car_at == Vector3.INF else (at - _car_at).length() / delta
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and speed >= RUN_OVER_SPEED:
		run_over(speed)
