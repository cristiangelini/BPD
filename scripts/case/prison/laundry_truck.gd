class_name LaundryTruck
extends Node3D

## The laundry's truck from outside (carcel-lavanderia.md, step 3): the moving truck's model with a sign on its side,
## parked along the street just past the prison's gate with a ramp down to it, its side to the yard. It drives in from
## the east for each of the plan's trips, waits there while the carts go up the ramp and drives off west. Its origin is
## on the ground in its middle (level space PARKED). No collisions: the carts and the cops go through to the ramp.
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/moving_truck.glb")
## Where it parks (level space x, z) and how far along the street it comes from and goes to.
const PARKED := Vector2(0.0, PrisonLevel.HALF_Z + 2.8)
const AWAY := 40.0
const DRIVE_TIME := 3.0
const RAMP := Vector3(1.6, 0.1, 1.6)

var here := false
var _drive: Tween


func _ready() -> void:
	var model: Node3D = MODEL.instantiate()
	# The model faces +Z: turned to face +X, along the street, its side to the gate.
	model.rotation.y = PI / 2
	add_child(model)
	var ramp := CopTool.piece(CopTool.box(RAMP), PrisonLevel.STEEL, Vector3(0, 0.45, -1.9), Vector3(-0.5, 0, 0))
	ramp.name = "Ramp"
	add_child(ramp)
	var sign_label := Label3D.new()
	sign_label.text = "LAUNDRY_TRUCK_SIGN"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.008
	sign_label.outline_size = 12
	sign_label.position = Vector3(0, 2.4, -1.35)
	sign_label.rotation.y = PI
	add_child(sign_label)
	position = Vector3(AWAY, PrisonLevel.FLOOR_TOP, PARKED.y)
	hide()


## In from the east and parked by the gate.
func arrive() -> void:
	here = true
	show()
	position = Vector3(AWAY, PrisonLevel.FLOOR_TOP, PARKED.y)
	_drive_to(PARKED.x)


## Off to the west, and gone.
func leave() -> void:
	here = false
	_drive_to(-AWAY).tween_callback(hide)


func _drive_to(x: float) -> Tween:
	if _drive:
		_drive.kill()
	_drive = create_tween()
	_drive.tween_property(self, "position:x", x, DRIVE_TIME).set_trans(Tween.TRANS_SINE)
	return _drive
