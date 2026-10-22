class_name TrunkLid
extends Grabbable

## A queued car's trunk lid (control-transito.md, "Revisar un auto"): no button, like the furniture (decision 76). A
## cop grabs its back edge and lifts it; it turns on its hinge after the hand and stays where it's let go. Past
## OPEN_AT it counts as open and the trunk shows what it carries. Its origin is the hinge; closed, it lies along -Z.
## Every number here is (propuesta).

signal opened

const SIZE := Vector3(1.7, 0.06, 0.9)
const MAX_ANGLE := deg_to_rad(80.0)
const OPEN_AT := deg_to_rad(45.0)
const COLOR := Color(0.25, 0.27, 0.3)

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
	box.size = SIZE
	shape.shape = box
	shape.position = Vector3(0, 0, -SIZE.z / 2)
	add_child(shape)
	PlaceBuilder.new(self).mesh_box(Vector3(0, 0, -SIZE.z / 2), SIZE, COLOR)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRUNK"


## Turns toward the hand: the hold point, seen from the hinge in the car's space, sets the angle.
func _physics_process(_delta: float) -> void:
	if holders.is_empty():
		return
	var point: Vector3 = holders.values()[0]
	var local := (get_parent() as Node3D).global_transform.affine_inverse() * point - position
	set_angle(atan2(local.y, -local.z))


func set_angle(value: float) -> void:
	angle = clampf(value, 0.0, MAX_ANGLE)
	rotation.x = angle
	if angle >= OPEN_AT and not is_open:
		is_open = true
		opened.emit()
