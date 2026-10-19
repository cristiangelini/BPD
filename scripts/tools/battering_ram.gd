class_name BatteringRam
extends Node3D

## The battering ram in the cop's hands (docs/diseno/allanamiento.md, "Herramientas de la semana 1").
## Hold left click to charge, let go to hit. A charged hit counts on the front door (3 break it);
## hitting nothing makes the cop stagger for a second. While carried it slows the cop down.

## Seconds to reach a full charge (proposal).
const CHARGE_TIME := 0.8
## Share of a full charge a hit needs to count on a door (proposal).
const MIN_CHARGE := 0.5
const REACH := 2.0
const STAGGER_TIME := 1.0
## Walking speed while carrying its 15 kg (proposal).
const SPEED_FACTOR := 0.75
## Impulse on a loose object at full charge, in N·s (proposal).
const PUSH := 60.0

const REST := Vector3(0.35, -0.45, -0.7)
const PULLED := Vector3(0.35, -0.4, -0.4)
const THRUST := Vector3(0.3, -0.35, -1.3)

var charge := 0.0
var is_charging := false

## Set by the cop that carries it.
var cop: Cop


func _physics_process(delta: float) -> void:
	if cop.input_enabled:
		if Input.is_action_just_pressed("grab"):
			start_charge()
		elif Input.is_action_just_released("grab"):
			swing()
	if is_charging:
		charge = minf(charge + delta / CHARGE_TIME, 1.0)
		position = REST.lerp(PULLED, charge)


func start_charge() -> void:
	if cop.is_busy():
		return
	is_charging = true
	charge = 0.0


## Hits what is in front of the camera with the current charge. Returns what it hit, or null.
func swing() -> Object:
	if not is_charging:
		return null
	is_charging = false
	var power := charge
	charge = 0.0
	var tween := create_tween()
	tween.tween_property(self, "position", THRUST, 0.08)
	tween.tween_property(self, "position", REST, 0.25)
	var hit := cop.aim_hit(REACH)
	if hit.is_empty():
		cop.stagger(STAGGER_TIME)
		return null
	var target: Object = hit.collider
	var door := (target as Node).get_parent() as FrontDoor
	if door and power >= MIN_CHARGE:
		door.ram_hit()
	elif target is Grandpa:
		(target as Grandpa).struck()
	elif target is RigidBody3D:
		(target as RigidBody3D).apply_impulse(-cop.camera.global_transform.basis.z * PUSH * power, hit.position - (target as Node3D).global_position)
	return target
