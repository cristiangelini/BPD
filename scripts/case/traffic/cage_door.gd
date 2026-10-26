class_name CageDoor
extends Grabbable

## A circus truck's cage door (control-circo.md, step 3): no button, like the trunk lid (decision 76). A cop grabs it
## and swings it open; it turns on its hinge, at the cage's back right corner, after the hand. Past OPEN_AT it counts as
## open and its truck lets its animal out (QueueCar.open_cage) on every PC. Closed, it lies across the cage's back,
## toward -X; open, it swings out, toward -Z. Every number here is (propuesta).

signal opened

const MAX_ANGLE := deg_to_rad(100.0)
const OPEN_AT := deg_to_rad(40.0)

## Its truck (the cage's parent), whose `open_cage` runs when it opens.
var car: Node3D
var angle := 0.0
var is_open := false


func _ready() -> void:
	add_to_group("cage_doors")
	freeze = true
	collision_layer = 4
	collision_mask = 0
	mass = 20.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(CircusTruck.CAGE_SIZE.x, CircusTruck.CAGE_SIZE.y, 0.08)
	shape.shape = box
	shape.position = Vector3(-CircusTruck.CAGE_SIZE.x / 2, CircusTruck.CAGE_SIZE.y / 2, 0)
	add_child(shape)
	# The bars' model has its hinge at its left (x = 0) and spans +X: turned round, it spans -X from this hinge.
	var bars: Node3D = CircusTruck.DOOR_MODEL.instantiate()
	bars.name = "Bars"
	bars.rotation.y = PI
	add_child(bars)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CAGE_DOOR"


## Turns toward the hand: the hold point, seen from the hinge in the cage's space, sets the angle.
func _physics_process(_delta: float) -> void:
	if holders.is_empty():
		return
	var point: Vector3 = holders.values()[0]
	var local := (get_parent() as Node3D).global_transform.affine_inverse() * point - position
	var was_open := is_open
	set_angle(atan2(-local.z, -local.x))
	if is_open and not was_open:
		_tell_every_pc()


## Online the hand that swung it is on one PC: its own cop has the truck open the cage on every PC (ActionSync).
func _tell_every_pc() -> void:
	for id: int in holders:
		var grabber := instance_from_id(id) as Node
		var cop := grabber.get_parent() as Cop if grabber else null
		if cop and cop.input_enabled and car and car.has_method("open_cage"):
			cop.act("open_cage", car)
			return


func set_angle(value: float) -> void:
	angle = clampf(value, 0.0, MAX_ANGLE)
	rotation.y = -angle
	if angle >= OPEN_AT and not is_open:
		is_open = true
		opened.emit()


## Swung shut (the animal is back in).
func close() -> void:
	set_angle(0.0)
	is_open = false
