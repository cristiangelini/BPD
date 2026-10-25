class_name ChaseGhost
extends CharacterBody3D

## The ghost car in the chase (control-auto-fantasma.md, "Cómo es", step 8): it follows its pilot's runaway car and,
## at every corner he turns, cuts in across the street behind him, right where the patrol car is coming, and stays
## there in the way, honking, until the next corner. Nobody at its wheel, so there's nobody to cuff: driving around it
## is all there is. It moves without physics, like the queue's cars; the patrol car bumps into it. Every number here is
## (propuesta).

## Crossing, it moves this far along its own +Z, this fast.
const CROSS := 3.0
const CROSS_SPEED := 6.0
const HONK_SECONDS := 2.0

## Its paint (TrafficCar.MODELS), the queue's ghost car's.
var look := 0
var _left := 0.0
var _haunt := 0.0
var _honk_left := 0.0
var _bubble: Label3D


func _ready() -> void:
	add_to_group("chase_ghosts")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.1, 1.4, QueueCar.LENGTH)
	shape.shape = box
	shape.position.y = 0.9
	add_child(shape)
	var model: Node3D = TrafficCar.MODELS[look % TrafficCar.MODELS.size()].instantiate()
	model.name = "Model"
	add_child(model)
	for i in SuspectCar.SEDAN_WHEELS.size():
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.name = "Wheel%d" % i
		wheel.position = SuspectCar.SEDAN_WHEELS[i]
		add_child(wheel)
	GhostCar.rig(self)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.6, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.006
	_bubble.outline_size = 12
	_bubble.font_size = 44
	_bubble.hide()
	add_child(_bubble)


## It shows up at `from` and drives CROSS along its own +Z, then stops there.
func cut_in(from: Transform3D, honk: String) -> void:
	global_transform = from
	_left = CROSS
	show()
	_bubble.text = honk
	_bubble.show()
	_honk_left = HONK_SECONDS


func crossing() -> bool:
	return _left > 0.0


func _physics_process(delta: float) -> void:
	_haunt += delta
	GhostCar.haunt(self, _haunt)
	_honk_left -= delta
	if _bubble.visible and _honk_left <= 0.0:
		_bubble.hide()
	if _left <= 0.0:
		return
	var step := minf(CROSS_SPEED * delta, _left)
	_left -= step
	global_position += global_basis.z * step
