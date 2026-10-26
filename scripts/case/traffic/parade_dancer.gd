class_name ParadeDancer
extends StaticBody3D

## A masked dancer on a parade float (control-desfile.md, step 3). Asked for the dance (E on the float), every dancer
## does their float's step for DANCE_SECONDS, but El Antifaz does another float's, and a clumsy one starts late. E on
## a dancer takes them down from the float, onto the street behind it: a real dancer complains and climbs back after
## DOWN_SECONDS (the parade queen's complaint, TrafficCase); El Antifaz stays down. Every number here is (propuesta).

## Each theme's step, in ParadeFloat.THEMES' order: the dragon flaps its wings, the ship rows, the cake spins, the
## castle salutes, the volcano jumps, the whale swims and the rocket points at the sky.
const STEPS: Array[String] = ["wings", "row", "spin", "salute", "jump", "swim", "launch"]
const DANCE_SECONDS := 3.0
## A clumsy dancer starts the right step this late.
const CLUMSY_DELAY := 0.8
## Taken down, a real dancer climbs back after this long (s).
const DOWN_SECONDS := 4.0
## Taken down, where they stand: on the street behind the float, this far back from its tail.
const DOWN_BACK := 0.9
const HEIGHT := 1.1

## Its float, its place on it and its traits (ParadeFloat.draw's: mask and what it holds).
var car: QueueCar
var index := 0
var traits := {}
## El Antifaz (step 4 says who): he dances another float's step and stays down once taken down.
var thief := false
var step := ""
var dance_left := 0.0
var delay_left := 0.0
var is_down := false
var down_left := 0.0
var _look: Node3D
var _on_deck := Vector3.ZERO
var _t := 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.55, HEIGHT, 0.45)
	shape.shape = box
	shape.position = Vector3(0, HEIGHT / 2, 0)
	add_child(shape)
	_look = get_node_or_null("Look") as Node3D
	_on_deck = position


func prompt_key(_cop: Cop) -> String:
	return "" if is_down else "PROMPT_PARADE_TAKE_DOWN"


## E on them: taken down from the float (QueueCar.take_down).
func use(_cop: Cop = null) -> void:
	if not is_down and car:
		car.take_down(index)


## Does `dance_step` for DANCE_SECONDS, `delay` seconds from now.
func dance(dance_step: String, delay := 0.0) -> void:
	step = dance_step
	delay_left = delay
	dance_left = DANCE_SECONDS
	_t = 0.0


func dancing() -> bool:
	return dance_left > 0.0


## Down onto the street behind the float; a real one climbs back after DOWN_SECONDS.
func go_down() -> void:
	is_down = true
	dance_left = 0.0
	down_left = DOWN_SECONDS
	position = Vector3(_on_deck.x, 0.0, -ParadeFloat.SIZE.z / 2 - DOWN_BACK)
	_pose("", 0.0)


func climb_back() -> void:
	is_down = false
	position = _on_deck


func _process(delta: float) -> void:
	if is_down and not thief:
		down_left -= delta
		if down_left <= 0.0:
			climb_back()
	if delay_left > 0.0:
		delay_left -= delta
		_pose("", 0.0)
		return
	if dance_left > 0.0:
		dance_left -= delta
		_t += delta
		_pose(step if dance_left > 0.0 else "", _t)


## Its arms and body at time `t` of `dance_step` ("" stands still).
func _pose(dance_step: String, t: float) -> void:
	if not _look:
		return
	var pose := pose_of(dance_step, t)
	var right := _look.get_node_or_null("ArmRight") as Node3D
	var left := _look.get_node_or_null("ArmLeft") as Node3D
	if right:
		right.rotation = pose.right
	if left:
		# The left arm is the right one mirrored (scale.x = -1): its sideways turn goes the other way.
		left.rotation = Vector3(pose.left.x, -pose.left.y, -pose.left.z)
	_look.rotation.y = pose.turn
	_look.position.y = pose.bob


## The arms' rotations (the left as if it were a right one), the body's turn and its hop at time `t` of `dance_step`.
static func pose_of(dance_step: String, t: float) -> Dictionary:
	var beat := sin(t * TAU)
	var right := Vector3.ZERO
	var left := Vector3.ZERO
	var turn := 0.0
	var bob := 0.0
	match dance_step:
		"wings":
			right = Vector3(0, 0, 0.7 + 0.6 * sin(t * TAU * 1.5))
			left = right
		"row":
			right = Vector3(-0.9 * beat, 0, 0.2)
			left = right
		"spin":
			right = Vector3(0, 0, 1.3)
			left = right
			turn = t * TAU * 0.75
		"salute":
			right = Vector3(-2.5, 0, 0.4)
		"jump":
			right = Vector3(0, 0, 0.4)
			left = right
			bob = absf(sin(t * TAU * 1.5)) * 0.25
		"swim":
			right = Vector3(-1.6 * beat, 0, 0.2)
			left = Vector3(1.6 * beat, 0, 0.2)
		"launch":
			right = Vector3(0, 0, 2.9)
			left = right
			bob = absf(beat) * 0.08
	return {"right": right, "left": left, "turn": turn, "bob": bob}
