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
