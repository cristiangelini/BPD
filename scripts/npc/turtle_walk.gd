class_name TurtleWalk
extends Node

## Makes its parent turtle (a Grabbable) wander slowly around the house (historias.md, "Carreras de tortugas").
## A sleeping turtle stays put until a cop comes close; a cop right next to it makes it hide in its shell for a while,
## which is the moment to grab it. A held turtle doesn't walk.

## Speeds and distances (propuesta).
const SPEED := 0.3
const WAKE_RANGE := 3.0
const SHELL_RANGE := 1.2
const SHELL_SECONDS := 3.0
## It picks a new heading every few seconds, or right away when something stops it.
const TURN_MIN := 3.0
const TURN_MAX := 6.0
const STUCK_SPEED := 0.05

@export var asleep := false
@export var walk_seed := 1

var in_shell := false
var _heading := 0.0
var _turn_left := 0.0
var _shell_left := 0.0
var _rng := RandomNumberGenerator.new()
@onready var _body: Grabbable = get_parent()


func _ready() -> void:
	_rng.seed = walk_seed
	_heading = _rng.randf() * TAU
	_body.axis_lock_angular_x = true
	_body.axis_lock_angular_z = true


func _physics_process(delta: float) -> void:
	if _body.is_held():
		asleep = false
		in_shell = false
		return
	var near := _nearest_cop_distance()
	if asleep:
		if near < WAKE_RANGE:
			asleep = false
		return
	_shell_left = maxf(_shell_left - delta, 0.0)
	if near < SHELL_RANGE:
		_shell_left = SHELL_SECONDS
	in_shell = _shell_left > 0.0
	if in_shell:
		return
	_turn_left -= delta
	var flat := Vector2(_body.linear_velocity.x, _body.linear_velocity.z).length()
	if _turn_left <= 0.0 or (_turn_left < TURN_MIN - 0.5 and flat < STUCK_SPEED):
		_turn_left = _rng.randf_range(TURN_MIN, TURN_MAX)
		_heading += _rng.randf_range(PI / 2, PI * 1.5)
	var wish := Vector3(sin(_heading), 0.0, cos(_heading)) * SPEED
	_body.linear_velocity.x = wish.x
	_body.linear_velocity.z = wish.z
	_body.rotation.y = _heading


func _nearest_cop_distance() -> float:
	var best := INF
	for cop in get_tree().get_nodes_in_group("cops"):
		best = minf(best, (cop as Node3D).global_position.distance_to(_body.global_position))
	return best
