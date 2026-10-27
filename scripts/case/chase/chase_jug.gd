class_name ChaseJug
extends RigidBody3D

## A water jug that comes untied off the back of the office's water truck (escena-oficina.md, "El final"; ChaseDrops):
## it rolls down the street on its side. E (the one riding along, or anyone on foot) moves it aside; the patrol car
## going over it fast bursts it, and the tires skid on the water for WET_SECONDS. Every number here is (propuesta).

const MODEL := preload("res://assets/models/chase_jug.glb")
## Lying on its side, its axis along x.
const RADIUS := 0.28
const LENGTH := 0.5
const MASS := 20.0
## The patrol car this close to its middle, at this speed or more (m/s), runs over it.
const REACH := 1.8
const RUN_OVER_SPEED := 2.0
const WET_SECONDS := 2.0

## The patrol car that can run over it, and the drops that wet its tires.
var car: Node3D
var drops: ChaseDrops
var burst := false
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_jugs")
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = RADIUS
	cylinder.height = LENGTH
	shape.shape = cylinder
	shape.rotation.z = PI / 2
	add_child(shape)
	var model := MODEL.instantiate() as Node3D
	model.rotation.z = PI / 2
	model.position.x = LENGTH / 2
	add_child(model)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_MOVE_JUG"


## E: stood up on the sidewalk, still full.
func use(cop: Cop) -> void:
	if cop:
		cop.show_hint("HINT_JUG_MOVED")
	queue_free()


## Run over: it bursts and the water wets the patrol car's tires.
func run_over() -> void:
	if burst:
		return
	burst = true
	if drops:
		drops.soaked_left = WET_SECONDS
	queue_free()


func _physics_process(delta: float) -> void:
	if burst or not is_instance_valid(car):
		return
	var at := car.global_position
	var speed := 0.0 if _car_at == Vector3.INF else (at - _car_at).length() / delta
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and speed >= RUN_OVER_SPEED:
		run_over()
