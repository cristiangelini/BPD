class_name TrunkLid
extends Grabbable

## A queued car's trunk lid (control-transito.md, "Revisar un auto"): no button, like the furniture (decision 76). A
## cop grabs its back edge and lifts it; it turns on its hinge after the hand and stays where it's let go. Past
## OPEN_AT it counts as open and the trunk shows what it carries. Its origin is the hinge; closed, it lies along -Z.
## With `side`, it's the clown car's door (control-payasos.md): its hinge is upright and it swings out toward +X, the driver's side.
## Every number here is (propuesta).

signal opened

const SIZE := Vector3(1.7, 0.06, 0.9)
const MAX_ANGLE := deg_to_rad(80.0)
const OPEN_AT := deg_to_rad(45.0)
const COLOR := Color(0.25, 0.27, 0.3)

## A clown car's lid is smaller (QueueCar.CLOWN_LID); set before it's added.
var size := SIZE
## A door on the car's left side instead of a lid; `action` is what the car does on every PC once it's open.
var side := false
var action := "open_trunk"
## What a door's prompt says: the clown car's, or a city car's (control-auto-lleno.md).
var door_prompt := "PROMPT_CLOWN_DOOR"
var angle := 0.0
var is_open := false


func _ready() -> void:
	add_to_group("trunk_lids")
	freeze = true
	collision_layer = 4
	collision_mask = 0
	mass = 8.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = Vector3(0, 0, -size.z / 2)
	add_child(shape)
	PlaceBuilder.new(self).mesh_box(Vector3(0, 0, -size.z / 2), size, COLOR)


func prompt_key(_cop: Cop) -> String:
	if side and is_open and get_parent().get("crowd") and not get_parent().get("looked_inside"):
		return "PROMPT_LOOK_INSIDE"
	return door_prompt if side else "PROMPT_TRUNK"


## E on a crowded car's open door counts who stayed in (control-auto-lleno.md, step 4); anywhere else, E is on the car.
func use(cop: Cop) -> void:
	if side and is_open and get_parent().has_method("look_inside"):
		get_parent().look_inside()
	elif get_parent().has_method("use"):
		get_parent().use(cop)


## Turns toward the hand: the hold point, seen from the hinge in the car's space, sets the angle.
func _physics_process(_delta: float) -> void:
	if holders.is_empty():
		return
	var point: Vector3 = holders.values()[0]
	var local := (get_parent() as Node3D).global_transform.affine_inverse() * point - position
	var was_open := is_open
	set_angle(atan2(local.x if side else local.y, -local.z))
	if is_open and not was_open:
		_tell_every_pc()


## Online the hand that lifted it is on one PC: its own cop has the car open the trunk on every PC (ActionSync).
func _tell_every_pc() -> void:
	for id: int in holders:
		var grabber := instance_from_id(id) as Node
		var cop := grabber.get_parent() as Cop if grabber else null
		if cop and cop.input_enabled and get_parent().has_method(action):
			cop.act(action, get_parent())
			return


func set_angle(value: float) -> void:
	angle = clampf(value, 0.0, MAX_ANGLE)
	if side:
		rotation.y = -angle
	else:
		rotation.x = angle
	if angle >= OPEN_AT and not is_open:
		is_open = true
		opened.emit()
