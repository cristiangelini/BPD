class_name ChaseIce
extends RigidBody3D

## A block of ice that slides out of the back of the aquarium's frozen fish truck (escena-acuario.md, "El tablero y el
## final"; ChaseDrops): it lies in the street, in the patrol car's way. E (anyone on foot) shoves it off the street;
## the patrol car going over it fast breaks it and skids (ChaseDrops.ice_hit). Every number here is (propuesta).

const MODEL := preload("res://assets/models/chase_ice.glb")
const SIZE := Vector3(0.5, 0.4, 0.5)
const MASS := 20.0
## The patrol car this close to its middle, at this speed or more (m/s), runs it over.
const REACH := 1.6
const SKID_SPEED := 2.0
## E shoves it this hard, away from the cop, and it's out of the way.
const SHOVE := 60.0

## The patrol car that can run over it, and the chase that makes it skid.
var car: Node3D
var drops: ChaseDrops
var broken := false
## Shoved off the street with E: the patrol car no longer skids on it.
var shoved := false
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_ice")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(_cop: Cop) -> String:
	return "" if shoved else "PROMPT_PUSH_ICE"


## E: shoved to the side of the street, away from the cop.
func use(cop: Cop) -> void:
	if shoved:
		return
	shoved = true
	var away := global_position - cop.global_position if cop else Vector3.RIGHT
	away.y = 0
	apply_central_impulse(away.normalized() * SHOVE)
	if cop:
		cop.show_hint("HINT_ICE_PUSHED")


## Run over: it breaks and the patrol car skids.
func run_over() -> void:
	if broken:
		return
	broken = true
	if is_instance_valid(drops):
		drops.ice_hit()
	queue_free()


func _physics_process(delta: float) -> void:
	if broken or shoved or not is_instance_valid(car):
		return
	var at := car.global_position
	var speed := 0.0 if _car_at == Vector3.INF else (at - _car_at).length() / delta
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and speed >= SKID_SPEED:
		run_over()
