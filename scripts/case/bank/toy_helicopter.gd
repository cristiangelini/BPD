class_name ToyHelicopter
extends Grabbable

## The giant toy helicopter of the roof robbery (robo-banco-techo.md, step 1, decision 126): as big as a fridge,
## yellow, waiting on the bank's roof on its helipad with its rotors humming. It weighs KG, so one cop drags it and two
## carry it. El Oso's nephew flies it from the sidewalk across (BankNephew). Its origin is on the ground under the
## mast, its front to +Z. Step 2: take_off() lifts it out of the cops' hands up to FLY_HEIGHT over its pad and flies it
## in circles for FLY_TIME, out of reach, and then it lands back on the pad. Every number here is (propuesta).

signal landed

const KG := 40.0
const MODEL := preload("res://assets/models/toy_helicopter.glb")
## Its body without the rotors and the tail, which don't knock anything.
const SIZE := Vector3(1.0, 1.0, 1.4)
## How fast the rotors turn waiting on the ground (radians a second).
const IDLE_SPIN := 6.0
const FLY_SPIN := 30.0
## The flight: up this high over the pad (m), around it this wide, this long (s), at this speed (m/s).
const FLY_HEIGHT := 5.0
const FLY_RADIUS := 6.0
const FLY_TIME := 20.0
const FLY_SPEED := 4.0

## How fast they turn now.
var spin := IDLE_SPIN
## Where it lands (in its parent's space), and whether it's in the air now and for how long still.
var pad := Vector3.ZERO
var flying := false
var fly_left := 0.0
var _angle := 0.0
var _rotor: Node3D
var _tail_rotor: Node3D


func _ready() -> void:
	add_to_group("toy_helicopters")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var model := MODEL.instantiate()
	add_child(model)
	_rotor = model.find_child("rotor", true, false) as Node3D
	_tail_rotor = model.find_child("tail_rotor", true, false) as Node3D


## The nephew flies it: whoever holds it lets go, and up it goes.
func take_off() -> void:
	if flying:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		var grabber := cop.get_node_or_null("Grabber") as Grabber
		if grabber and grabber.held == self:
			grabber.release()
	holders.clear()
	flying = true
	fly_left = FLY_TIME
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	spin = FLY_SPIN
	_angle = 0.0


## Where it's going now: up over the pad, around it, and back down when the time is up.
func _target() -> Vector3:
	if fly_left <= 0.0:
		return pad
	return pad + Vector3(cos(_angle) * FLY_RADIUS, FLY_HEIGHT, sin(_angle) * FLY_RADIUS)


func _physics_process(delta: float) -> void:
	if not flying:
		super(delta)
		return
	fly_left -= delta
	_angle += FLY_SPEED / FLY_RADIUS * delta
	var to := _target()
	position = position.move_toward(to, FLY_SPEED * delta)
	rotation.y = lerp_angle(rotation.y, -_angle, 2.0 * delta)
	if fly_left <= 0.0 and position.distance_to(pad) < 0.05:
		position = pad
		rotation = Vector3.ZERO
		flying = false
		freeze = false
		spin = IDLE_SPIN
		landed.emit()


func _process(delta: float) -> void:
	if _rotor:
		_rotor.rotate_y(spin * delta)
	if _tail_rotor:
		_tail_rotor.rotate_x(spin * 1.5 * delta)
