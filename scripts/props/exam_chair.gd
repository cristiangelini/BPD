class_name ExamChair
extends Node3D

## The exam chair at the optician's (docs/diseno/allanamiento-optica.md, "El sillón de examen"): E on the pedal at
## its foot sends the seat up to LIFT_MAX, or back down. A cop standing on the seat rides it up, high enough to reach
## the exam room's high shelf. The seat itself is kept for sitting down (Doña Visia's exam, step 2). Its front is +Z.
## Every number here is (propuesta).

signal moved(up: bool)

const MODEL := preload("res://assets/models/exam_chair.glb")
const LIFT_MAX := 1.5
const LIFT_SPEED := 0.6
const PEDAL_AT := Vector3(0.32, 0.05, 0.3)
const PEDAL_SIZE := Vector3(0.18, 0.1, 0.14)
const CHROME := Color(0.78, 0.8, 0.82)


## The pedal: E on it works the chair.
class Pedal extends StaticBody3D:
	var chair: ExamChair

	func prompt_key(_cop: Cop) -> String:
		return "PROMPT_EXAM_CHAIR_DOWN" if chair.going_up else "PROMPT_EXAM_CHAIR_UP"

	func use(_cop: Cop) -> void:
		chair.toggle()


## How high the seat is over its lowest, and whether it's headed up (or down).
var lift := 0.0
var going_up := false
var seat: AnimatableBody3D
var pedal: Pedal
var _column: MeshInstance3D


func _ready() -> void:
	var base := StaticBody3D.new()
	_shape(base, Vector3(0, 0.03, 0), Vector3(0.5, 0.06, 0.5))
	add_child(base)
	seat = AnimatableBody3D.new()
	seat.name = "Seat"
	seat.sync_to_physics = true
	_shape(seat, Vector3(0, 0.25, 0), Vector3(0.12, 0.4, 0.12))
	_shape(seat, Vector3(0, 0.53, 0), Vector3(0.6, 0.14, 0.6))
	_shape(seat, Vector3(0, 1.0, -0.28), Vector3(0.6, 0.8, 0.14))
	seat.add_child(MODEL.instantiate())
	add_child(seat)
	# The chrome column that grows under the seat as it goes up.
	_column = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.1, 1.0, 0.1)
	_column.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = CHROME
	material.metallic = 0.7
	_column.material_override = material
	_column.visible = false
	add_child(_column)
	pedal = Pedal.new()
	pedal.name = "Pedal"
	pedal.chair = self
	pedal.position = PEDAL_AT
	_shape(pedal, Vector3.ZERO, PEDAL_SIZE)
	var look := MeshInstance3D.new()
	var pedal_mesh := BoxMesh.new()
	pedal_mesh.size = PEDAL_SIZE
	look.mesh = pedal_mesh
	look.material_override = material
	pedal.add_child(look)
	add_child(pedal)


## The pedal: up if it's down or going down, down if it's up or going up.
func toggle() -> void:
	going_up = not going_up
	moved.emit(going_up)


func _physics_process(delta: float) -> void:
	var target := LIFT_MAX if going_up else 0.0
	if is_equal_approx(lift, target):
		return
	lift = move_toward(lift, target, LIFT_SPEED * delta)
	seat.position.y = lift
	_column.visible = lift > 0.01
	_column.scale.y = maxf(lift, 0.01)
	_column.position.y = 0.06 + lift / 2


func _shape(body: CollisionObject3D, at: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	body.add_child(shape)
