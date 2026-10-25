class_name ToyHelicopter
extends Grabbable

## The giant toy helicopter of the roof robbery (robo-banco-techo.md, step 1, decision 126): as big as a fridge,
## yellow, waiting on the bank's roof on its helipad with its rotors humming. It weighs KG, so one cop drags it and two
## carry it. El Oso's nephew flies it from the sidewalk across (BankNephew). Its origin is on the ground under the
## mast, its front to +Z. Step 2: take_off() lifts it out of the cops' hands up to FLY_HEIGHT over its pad and flies it
## in circles for FLY_TIME, out of reach, and then it lands back on the pad. Step 3: without its pilot it crashes
## (crash()): the rotors stop and it falls wherever it is, broken for good. Step 4: trip() takes a sack of money to the
## nephew's cart and back, in TRIP_TIME. Online (step 5) the host flies it and a guest's copy only shows the host's
## (PropSync moves it; net_state says how fast its rotors turn, whether it crashed and whether it's still on the roof).
## Every number here is (propuesta).

signal landed
## On a trip: it let the sack go into the cart, and it's back on its pad.
signal dropped
signal trip_done

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
const CRASH_TILT := 0.45
## A trip to the cart and back takes this long (s), flying this high over the street, down to this over the cart.
const TRIP_TIME := 20.0
const TRIP_HEIGHT := 6.0
const OVER_CART := 1.2

## How fast they turn now.
var spin := IDLE_SPIN
## Where it lands (in its parent's space), and whether it's in the air now and for how long still.
var pad := Vector3.ZERO
var flying := false
## Its pilot was caught: it fell and won't fly again.
var crashed := false
## A guest's: only shows the host's.
var follower := false
var fly_left := 0.0
var _angle := 0.0
## A trip's points still ahead (in its parent's space), how fast it flies them, and how many there are until the drop.
var _path: Array[Vector3] = []
var _path_speed := 0.0
var _to_drop := -1
var _model: Node3D
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
	_model = MODEL.instantiate()
	add_child(_model)
	_rotor = _model.find_child("rotor", true, false) as Node3D
	_tail_rotor = _model.find_child("tail_rotor", true, false) as Node3D


## The nephew flies it: whoever holds it lets go, and up it goes.
func take_off() -> void:
	if busy() or crashed:
		return
	flying = true
	fly_left = FLY_TIME
	_lift()
	_angle = 0.0


## Out of everyone's hands and up: it flies on its own now.
func _lift() -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		var grabber := cop.get_node_or_null("Grabber") as Grabber
		if grabber and grabber.held == self:
			grabber.release()
	holders.clear()
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	spin = FLY_SPIN


## In the air, on a flight of the nephew's or on a trip.
func busy() -> bool:
	return flying or not _path.is_empty()


## A sack to the cart at `cart` (in its parent's space): up, over the street, down to the cart, and back to its pad.
func trip(cart: Vector3) -> void:
	if busy() or crashed:
		return
	var up := Vector3.UP * TRIP_HEIGHT
	_path.assign([pad + up, cart + up, cart + Vector3.UP * OVER_CART, cart + up, pad + up, pad])
	_to_drop = 3
	var length := position.distance_to(_path[0])
	for i in range(1, _path.size()):
		length += _path[i - 1].distance_to(_path[i])
	_path_speed = length / TRIP_TIME
	_lift()


func _fly_path(delta: float) -> void:
	var to := _path[0]
	position = position.move_toward(to, _path_speed * delta)
	var flat := Vector2(to.x - position.x, to.z - position.z)
	if flat.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(flat.x, flat.y), 3.0 * delta)
	if position.distance_to(to) > 0.01:
		return
	_path.pop_front()
	_to_drop -= 1
	if _to_drop == 0:
		dropped.emit()
	if _path.is_empty():
		rotation = Vector3.ZERO
		freeze = false
		spin = IDLE_SPIN
		trip_done.emit()


## No pilot: it drops from wherever it is, its rotors stopped, tipped over.
func crash() -> void:
	if crashed:
		return
	crashed = true
	flying = false
	_path.clear()
	fly_left = 0.0
	if not follower:
		freeze = false
	_show_crashed()


## Broken: it lies tipped on a skid, its rotor stopped and bent.
func _show_crashed() -> void:
	spin = 0.0
	_model.rotation.z = CRASH_TILT
	_rotor.rotation.x = 0.3


## Where it's going now: up over the pad, around it, and back down when the time is up.
func _target() -> Vector3:
	if fly_left <= 0.0:
		return pad
	return pad + Vector3(cos(_angle) * FLY_RADIUS, FLY_HEIGHT, sin(_angle) * FLY_RADIUS)


func _physics_process(delta: float) -> void:
	if follower:
		return
	if not _path.is_empty():
		_fly_path(delta)
		return
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


func net_state() -> Array:
	return [spin, crashed, visible]


func apply_net_state(state: Array) -> void:
	spin = state[0]
	if state[1] and not crashed:
		crashed = true
		_show_crashed()
	visible = state[2]
