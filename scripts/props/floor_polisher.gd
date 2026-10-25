class_name FloorPolisher
extends Grabbable

## The floor polisher of the cleaning crew's jailbreak (docs/diseno/fuga-limpieza.md, step 5): heavy, it stands in the
## cleaning closet and E turns it on and off, in hand or on the floor. On, its disc scrubs the stains under it
## SCRUB_FACTOR times as fast as a mop (FloorStains) and it counts as cleaning for the early comisario, but it pulls
## whoever holds it this way and that, a new way every WANDER_EVERY seconds; let go while it's on, it spins and wanders
## off on its own until it hits something or someone turns it off. Every number here is (propuesta).

const MODEL := preload("res://assets/models/floor_polisher.glb")
const KG := 14.0
const SCRUB_FACTOR := 3.0
## How far from its middle the disc scrubs.
const DISC := 0.4
const WANDER_EVERY := 0.6
## How hard it pulls its holder (m/s) and how fast it goes on its own, and its spin on its own (rad/s).
const PULL := 1.6
const LOOSE_SPEED := 1.2
const LOOSE_SPIN := 6.0

var is_on := false
var _wander := Vector3.ZERO
var _wander_left := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("floor_scrubbers")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var disc := CylinderShape3D.new()
	disc.radius = 0.27
	disc.height = 0.34
	shape.shape = disc
	shape.position.y = 0.17
	add_child(shape)
	var handle := CollisionShape3D.new()
	var bar := BoxShape3D.new()
	bar.size = Vector3(0.5, 0.1, 0.1)
	handle.shape = bar
	handle.position = Vector3(0, 1.1, -0.45)
	add_child(handle)
	add_child(MODEL.instantiate())
	_rng.seed = hash(["floor polisher", get_path()])


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_POLISHER_OFF" if is_on else "PROMPT_POLISHER_ON"


func held_prompt_key(cop: Cop) -> String:
	return prompt_key(cop)


## E on it, or with it in hand: on or off.
func use(_cop: Cop = null) -> void:
	is_on = not is_on


## Where its disc scrubs the floor, and whether it does now.
func scrub_point() -> Vector3:
	return global_position


func scrub_reach() -> float:
	return DISC


func scrub_factor() -> float:
	return SCRUB_FACTOR


func is_scrubbing() -> bool:
	return is_on


## For the early comisario: working is having it on.
func is_working() -> bool:
	return is_on and is_held()


func _physics_process(delta: float) -> void:
	super(delta)
	if not is_on:
		return
	_wander_left -= delta
	if _wander_left <= 0.0:
		_wander_left = WANDER_EVERY
		var angle := _rng.randf() * TAU
		_wander = Vector3(cos(angle), 0, sin(angle))
	for cop: Cop in handling_cops(0.0):
		# Each PC pulls its own cop around.
		if not cop.sync or cop.sync.is_multiplayer_authority():
			cop.knock_back(_wander * PULL, 0.0)
	if not is_held() and multiplayer.is_server():
		linear_velocity = Vector3(_wander.x * LOOSE_SPEED, linear_velocity.y, _wander.z * LOOSE_SPEED)
		angular_velocity = Vector3.UP * LOOSE_SPIN
