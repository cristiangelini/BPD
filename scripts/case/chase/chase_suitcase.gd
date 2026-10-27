class_name ChaseSuitcase
extends RigidBody3D

## A suitcase that falls off the roof of the hotel's shuttle (escena-hotel.md, "El tablero y el final"; ChaseDrops):
## it lands burst open in the street, the guests' clothes spilling out. E (the one riding along, or anyone on foot)
## moves it aside; the patrol car going over it fast throws the clothes up onto its windshield, which stays covered
## for LAUNDRY_SECONDS. Every number here is (propuesta).

const MODEL := preload("res://assets/models/chase_suitcase.glb")
const SIZE := Vector3(0.8, 0.2, 0.6)
const MASS := 10.0
## The patrol car this close to its middle, at this speed or more (m/s), runs over it.
const REACH := 1.8
const RUN_OVER_SPEED := 2.0
const LAUNDRY_SECONDS := 2.0

## The patrol car that can run over it, and the drops that cover its windshield.
var car: Node3D
var drops: ChaseDrops
var run_over_once := false
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_suitcases")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_MOVE_SUITCASE"


## E: closed as well as it closes and put on the sidewalk.
func use(cop: Cop) -> void:
	if cop:
		cop.show_hint("HINT_SUITCASE_MOVED")
	queue_free()


## Run over: the clothes fly up onto the patrol car's windshield.
func run_over() -> void:
	if run_over_once:
		return
	run_over_once = true
	if drops:
		drops.laundry_left = LAUNDRY_SECONDS
	queue_free()


func _physics_process(delta: float) -> void:
	if run_over_once or not is_instance_valid(car):
		return
	var at := car.global_position
	var speed := 0.0 if _car_at == Vector3.INF else (at - _car_at).length() / delta
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and speed >= RUN_OVER_SPEED:
		run_over()
