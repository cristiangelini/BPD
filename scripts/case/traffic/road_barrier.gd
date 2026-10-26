class_name RoadBarrier
extends Grabbable

## The road barrier (control-transito.md, step 1): a striped sawhorse 3.2 m wide, 18 kg, so one cop drags it and two
## carry it comfortably. Its board runs along its local X; the checkpoint wants it across the lane. Its origin is on
## the ground. Every number here is (propuesta).

## E on it lets the first car in the queue through (control-transito.md, "Dejar pasar o detener").
signal lifted(cop: Cop)

const KG := 18.0
const SIZE := Vector3(3.2, 1.1, 0.5)
const MODEL := "res://assets/models/road_barrier.glb"
## A racer that clips it sends it flying (control-carrera.md, step 2); BACK_SECONDS later it's back where it stood.
const BACK_SECONDS := 5.0

var knocked_left := 0.0
var _home := Transform3D.IDENTITY


func _ready() -> void:
	add_to_group("road_barriers")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child((load(MODEL) as PackedScene).instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_LET_THROUGH"


func use(cop: Cop) -> void:
	lifted.emit(cop)


## A racer sent it flying with `push`: it lands where it lands and is back up where it stood in BACK_SECONDS.
func knock(push: Vector3) -> void:
	if knocked_left > 0.0:
		return
	_home = global_transform
	knocked_left = BACK_SECONDS
	linear_velocity = push
	angular_velocity = Vector3(randf_range(-4, 4), randf_range(-2, 2), randf_range(-4, 4))


func knocked() -> bool:
	return knocked_left > 0.0


func _physics_process(delta: float) -> void:
	super(delta)
	if knocked_left <= 0.0:
		return
	knocked_left -= delta
	if knocked_left <= 0.0 and not is_held():
		global_transform = _home
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
