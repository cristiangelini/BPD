class_name HumanCustomer
extends StaticBody3D

## A human customer of Ramiro's secret salon (peluqueria.md, "Peluquería de humanos clandestina"): walks in along
## `route`, waits under the dryer with a towel over the head for CUT seconds and walks back out. A cop who lifts the
## towel (E) unmasks them: they run out, and that's the story's clue. Every number here is (propuesta).

signal seated
signal unmasked(customer: HumanCustomer)
signal gone

enum State { ENTERING, SEATED, LEAVING, FLEEING }

const TOWEL_MODEL := preload("res://assets/models/customer_towel.glb")
const SPEED := 1.3
const FLEE_SPEED := 4.0
## Seconds under the towel.
const CUT := 25.0
## The towel sits on top of the head and, a bit bigger than the model, hides it down to the shoulders.
const HEAD_TOP := 1.8
const TOWEL_SCALE := 1.4

## Points from the street to the dryer.
var route: Array[Vector3] = []
var state := State.ENTERING
var towel: Node3D
var _next := 0
var _left := 0.0


func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	var model: Node3D = BakeryCustomer.MODELS[get_index() % BakeryCustomer.MODELS.size()].instantiate()
	model.scale = Vector3.ONE * 0.95
	add_child(model)
	towel = TOWEL_MODEL.instantiate()
	towel.position.y = HEAD_TOP
	towel.scale = Vector3.ONE * TOWEL_SCALE
	towel.hide()
	add_child(towel)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_LIFT_TOWEL" if state == State.SEATED else ""


## E on the towel: off it comes and they run.
func use(_cop: Cop) -> void:
	if state != State.SEATED:
		return
	towel.hide()
	state = State.FLEEING
	_next = route.size() - 1
	unmasked.emit(self)


## Ramiro throws the towel over them.
func cover() -> void:
	towel.show()


func _physics_process(delta: float) -> void:
	match state:
		State.ENTERING:
			if _walk(route[_next], SPEED, delta):
				_next += 1
				if _next >= route.size():
					state = State.SEATED
					_next = route.size() - 1
					_left = CUT
					seated.emit()
		State.SEATED:
			_left -= delta
			if _left <= 0.0:
				towel.hide()
				state = State.LEAVING
				_next = route.size() - 2
		State.LEAVING, State.FLEEING:
			if _walk(route[_next], SPEED if state == State.LEAVING else FLEE_SPEED, delta):
				_next -= 1
				if _next < 0:
					gone.emit()
					queue_free()


## One step toward `at`; true once there.
func _walk(at: Vector3, speed: float, delta: float) -> bool:
	var to := at - position
	to.y = 0.0
	if to.length() <= speed * delta:
		position = Vector3(at.x, position.y, at.z)
		return true
	position += to.normalized() * speed * delta
	rotation.y = atan2(to.x, to.z)
	return false
