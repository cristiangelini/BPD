class_name PatrolCar
extends VehicleBody3D

## The patrol car (allanamiento.md, "Patrullero"): 4 seats, only the driver drives, arcade handling, no damage.
## E next to a door gets in the nearest free seat; E inside gets out by that seat's door. Forward is +Z.
## Evidence left in the trunk counts as delivered at once ("Entrega"); taking it out undoes that.

signal seats_changed
signal evidence_delivered(item: Evidence)
signal evidence_removed(item: Evidence)

## 60 km/h in the city, 110 on the ring highway (propuesta).
const MAX_SPEED := 60.0 / 3.6
const HIGHWAY_SPEED := 110.0 / 3.6
const MAX_REVERSE := 5.0
const ENGINE := 6000.0
const BRAKE := 60.0
const HANDBRAKE := 120.0
const STEER := 0.55
## At top speed the wheels turn this share of STEER, so a hard turn slides instead of tipping over.
const STEER_AT_TOP := 0.35
## Steering eases toward the target this many radians per second.
const STEER_RATE := 2.5
## Getting out puts the cop this far from the side of the car.
const DOOR_OUT := 1.6
const SIREN_FLASH := 0.25

## Cop in each seat, null if free. Seat 0 drives.
var seated: Array[Cop] = [null, null, null, null]
var siren_on := false
var throttle := 0.0
var steer_input := 0.0
var handbrake := false
var _siren_time := 0.0
## Unbroken evidence in the trunk right now.
var delivered: Array[Evidence] = []
## The place's owner riding in the back to be interrogated (OwnerEscort), if any.
var prisoner: Node3D
var _highway: Highway

@onready var _seats: Array[Node3D] = [$Seats/Driver, $Seats/Front, $Seats/BackLeft, $Seats/BackRight]
@onready var _rear: Array[VehicleWheel3D] = [$WheelRearLeft, $WheelRearRight]
@onready var _siren_red: OmniLight3D = $SirenRed
@onready var _siren_blue: OmniLight3D = $SirenBlue


func _ready() -> void:
	$Trunk.body_entered.connect(_on_trunk_entered)
	$Trunk.body_exited.connect(_on_trunk_exited)


func is_delivered(item: Evidence) -> bool:
	return delivered.has(item)


## Cops sitting in the car.
func passengers() -> Array[Cop]:
	var cops: Array[Cop] = []
	for cop in seated:
		if cop:
			cops.append(cop)
	return cops


func _on_trunk_entered(body: Node3D) -> void:
	# Things worth nothing (a dog that isn't a story's) aren't evidence for the trunk.
	if body is Evidence and body.full_value > 0.0 and not body.is_broken and not delivered.has(body):
		delivered.append(body)
		evidence_delivered.emit(body)


func _on_trunk_exited(body: Node3D) -> void:
	if body is Evidence and delivered.has(body):
		delivered.erase(body)
		evidence_removed.emit(body)


func driver() -> Cop:
	return seated[0]


func seat_of(cop: Cop) -> int:
	return seated.find(cop)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CAR"


## While set (a tr() key), E on the car only shows this hint: nobody leaves before hearing the comisario.
var locked_hint := ""


## E in the car gets out; E next to it gets in `seat` (-1: the free seat whose door is closest).
func use(cop: Cop, seat := -1) -> void:
	if locked_hint != "" and seat_of(cop) < 0:
		cop.show_hint(locked_hint)
		return
	if seat_of(cop) >= 0:
		exit(cop)
	else:
		enter(cop, seat)


## What use() needs from the cop's own PC, so it picks the same seat on every PC online (ActionSync).
func use_args(cop: Cop) -> Array:
	return [] if seat_of(cop) >= 0 else [nearest_free_seat(cop)]


## The free seat whose door is closest to the cop, or -1 if the car is full.
func nearest_free_seat(cop: Cop) -> int:
	var best := -1
	for i in seated.size():
		if seated[i] == null and (best < 0 or _door(i).distance_to(cop.global_position) < _door(best).distance_to(cop.global_position)):
			best = i
	return best


## Sits the cop in `seat` (-1: the free seat whose door is closest to it). Returns the seat, or -1 if it can't.
func enter(cop: Cop, seat := -1) -> int:
	var best := seat if seat >= 0 and seated[seat] == null else nearest_free_seat(cop)
	if best < 0:
		cop.show_hint("HINT_CAR_FULL")
		return -1
	seated[best] = cop
	cop.sit_in(self, _seats[best])
	cop.show_hint("HINT_CAR_DRIVER" if best == 0 else "HINT_CAR_PASSENGER")
	seats_changed.emit()
	return best


func exit(cop: Cop) -> void:
	var i := seat_of(cop)
	if i < 0:
		return
	seated[i] = null
	cop.stand_up(_door(i), global_basis.get_euler().y + PI)
	if i == 0:
		drive(0.0, 0.0, true)
	seats_changed.emit()


## Driver controls: throttle -1 (S) to 1 (W), steer -1 (D) to 1 (A), handbrake (Space).
func drive(new_throttle: float, new_steer: float, new_handbrake: bool) -> void:
	throttle = clampf(new_throttle, -1.0, 1.0)
	steer_input = clampf(new_steer, -1.0, 1.0)
	handbrake = new_handbrake


func toggle_siren() -> void:
	siren_on = not siren_on
	_siren_time = 0.0
	_siren_red.visible = siren_on
	_siren_blue.visible = false


## Speed along the car's forward axis in m/s (negative when reversing).
func forward_speed() -> float:
	return linear_velocity.dot(global_basis.z)


func _physics_process(delta: float) -> void:
	var cop := driver()
	if cop and cop.input_enabled:
		drive(Input.get_axis("move_back", "move_forward"), Input.get_axis("move_right", "move_left"),
			Input.is_action_pressed("jump"))
		if Input.is_action_just_pressed("siren"):
			cop.act("toggle_siren", self)
		# Online on a guest, the host drives the car for everyone with these controls.
		if cop.sync:
			cop.sync.send_controls(throttle, steer_input, handbrake)
	elif not cop:
		drive(0.0, 0.0, true)
	_apply_controls(delta)
	if cop:
		cop.stats["meters_driven"] += absf(forward_speed()) * delta
	# Evidence that breaks in the trunk (the car flipped) no longer counts.
	for item in delivered.duplicate():
		if item.is_broken:
			_on_trunk_exited(item)
	if siren_on:
		_siren_time += delta
		var red := int(_siren_time / SIREN_FLASH) % 2 == 0
		_siren_red.visible = red
		_siren_blue.visible = not red


func _apply_controls(delta: float) -> void:
	var speed := forward_speed()
	var top := top_speed()
	var reach := lerpf(1.0, STEER_AT_TOP, clampf(absf(speed) / MAX_SPEED, 0.0, 1.0))
	steering = move_toward(steering, steer_input * STEER * reach, STEER_RATE * delta)
	engine_force = 0.0
	brake = 0.0
	if throttle > 0.0:
		if speed < -0.5:
			brake = BRAKE
		elif speed < top:
			engine_force = ENGINE * throttle
	elif throttle < 0.0:
		if speed > 0.5:
			brake = BRAKE
		elif speed > -MAX_REVERSE:
			engine_force = ENGINE * throttle
	for wheel in _rear:
		wheel.brake = HANDBRAKE if handbrake else brake


## How fast the car goes here: faster on the highway's road.
func top_speed() -> float:
	if not is_instance_valid(_highway):
		_highway = get_tree().get_first_node_in_group("highway") as Highway
	return HIGHWAY_SPEED if _highway and _highway.covers(global_position) else MAX_SPEED


## Where the owner rides: in the back, between the two back seats, so he takes no cop's seat. A bit sunk, since he
## stands (no NPC sits yet) and would go through the roof.
const PRISONER_SINK := 0.3


func prisoner_seat() -> Transform3D:
	var middle := (_seats[2].position + _seats[3].position) / 2.0 + Vector3.DOWN * PRISONER_SINK
	return Transform3D(global_basis, to_global(middle))


## Where the cop in seat `i` stands after getting out, beside that seat's door.
func _door(i: int) -> Vector3:
	var local := _seats[i].position
	local.x += signf(local.x) * DOOR_OUT
	local.y = 0.0
	return to_global(local)
