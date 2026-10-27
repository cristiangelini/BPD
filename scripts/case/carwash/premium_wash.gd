class_name PremiumWash
extends OfficePrinter

## The token machine's golden button (docs/diseno/allanamiento-lavadero.md, "Su distracción, el lavado premium"): E on
## it pays a premium wash. The first car in line rides alone through the tunnel to the drying area, and Don Chorro
## goes to dry it by hand with his back to everything (the floor boss's fix, on the same body); when he's done, the car
## backs up to its place in line. He comes once every REST seconds, and the third time he catches on. Built in the
## token machine's space: its front to +z. Every number here is (propuesta).

## A premium was paid but this time he knows what's going on.
signal caught_on

const BUTTON_AT := Vector3(-0.18, 1.1, 0.28)
const GOLD := Color(0.95, 0.78, 0.29)
const REST := 45.0
## The premiums that take him away; from the next one on he catches on.
const FOOLS := 2
## How fast the car rides through the tunnel and back, in m/s.
const RIDE_SPEED := 2.5
## Online, a guest's car further than this from the host's (m) jumps to it.
const SYNC_SLACK := 1.0

## The car that rides, where it waits in line and where it gets dried (in the car wash's space), and the tunnel it
## starts.
var car: Node3D
var home := Vector3.ZERO
var dry_at := Vector3.ZERO
var tunnel: WashTunnel
## Seconds left before a premium takes him away again.
var rest_left := 0.0
var presses := 0
var distractions := 0
## Where the car is going now (its parent's space), or Vector3.INF while it stands.
var _ride_to := Vector3.INF


func _ready() -> void:
	button = PushButton.new()
	button.prompt = "PROMPT_CARWASH_PREMIUM"
	button.color = GOLD
	button.position = BUTTON_AT
	add_child(button)
	button.pressed.connect(press)


## A premium wash: the car rides to the drying area and he goes to dry it, unless he dried one less than REST seconds
## ago, or it's the third time and he catches on.
func press(_cop: Cop = null) -> void:
	presses += 1
	if is_jammed or rest_left > 0.0:
		return
	if distractions >= FOOLS:
		caught_on.emit()
		rest_left = REST
		return
	distractions += 1
	is_jammed = true
	jobs += 1
	rest_left = REST
	if car and is_home():
		_ride_to = dry_at
		if tunnel:
			tunnel.start()
	jammed.emit()


## He's done drying: the car backs up to its place in line.
func fix() -> void:
	is_jammed = false
	if car:
		ride_home()


## The car rides through the tunnel to the drying area on its own, with nobody paying (the stolen car, step 6): only
## from its place in line.
func ride_alone() -> bool:
	if not car or not is_home():
		return false
	_ride_to = dry_at
	if tunnel:
		tunnel.start()
	return true


## The car backs up to its place in line.
func ride_home() -> void:
	_ride_to = home


## Online, what the guests' premium wash takes from the host's (CarWash.net_state): Don Chorro is the host's, so
## when he's done drying there the car backs up here too; a car further than SYNC_SLACK from the host's jumps to it.
func net_state() -> Array:
	return [presses, distractions, rest_left, is_jammed, car.position if car else Vector3.ZERO, _ride_to]


func apply_net_state(state: Array) -> void:
	presses = state[0]
	distractions = state[1]
	rest_left = state[2]
	if is_jammed and not state[3]:
		fix()
	is_jammed = state[3]
	if car and car.position.distance_to(state[4]) > SYNC_SLACK:
		car.position = state[4]
		_ride_to = state[5]


func is_drying() -> bool:
	return is_jammed


func is_home() -> bool:
	return car.position.distance_to(home) < 0.05 and _ride_to == Vector3.INF


## Whether the car stands in the drying area.
func is_out() -> bool:
	return car.position.distance_to(dry_at) < 0.05 and _ride_to == Vector3.INF


func is_riding() -> bool:
	return _ride_to != Vector3.INF


func _physics_process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
	if not is_riding():
		return
	var to := _ride_to - car.position
	if to.length() <= RIDE_SPEED * delta:
		car.position = _ride_to
		_ride_to = Vector3.INF
	else:
		car.position += to.normalized() * RIDE_SPEED * delta
