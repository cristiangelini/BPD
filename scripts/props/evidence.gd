class_name Evidence
extends Grabbable

## Evidence for a case (docs/diseno/allanamiento.md, "La evidencia"): a grabbable object with a value.
## Every hit faster than SAFE_SPEED takes value off, more the harder the hit; at 0 it breaks and no longer counts.

signal damaged(loss: float)
signal broken

## Hits at or below this relative speed do nothing (m/s).
const SAFE_SPEED := 3.0
## Share of the full value lost per m/s above SAFE_SPEED (proposal: a 7 m/s drop costs 40%).
const LOSS_PER_SPEED := 0.1

@export var full_value := 1000.0

var value := 0.0
var is_broken := false

## Colliders touching last physics step, so only new contacts count as hits.
var _touching := {}
var _last_velocity := Vector3.ZERO


@onready var _label: Label3D = get_node_or_null("ValueLabel")


func _ready() -> void:
	value = full_value
	contact_monitor = true
	max_contacts_reported = 8
	_show_value()


## Placeholder feedback until the HUD exists: the value floats over the object (a number, so no text key).
func _show_value() -> void:
	if _label:
		_label.text = "%d" % roundi(value)
		_label.modulate = Color.WHITE.lerp(Color(1, 0.25, 0.2), 1.0 - value / full_value)


## Applies a hit at `speed` m/s and returns the value lost.
func hit(speed: float) -> float:
	if is_broken or speed <= SAFE_SPEED:
		return 0.0
	var loss := minf(value, full_value * LOSS_PER_SPEED * (speed - SAFE_SPEED))
	value -= loss
	_show_value()
	damaged.emit(loss)
	if value <= 0.0:
		value = 0.0
		is_broken = true
		broken.emit()
	return loss


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var now := {}
	var hardest := 0.0
	for i in state.get_contact_count():
		var id := state.get_contact_collider_id(i)
		now[id] = true
		if _touching.has(id):
			continue
		var relative := _last_velocity - state.get_contact_collider_velocity_at_position(i)
		hardest = maxf(hardest, absf(relative.dot(state.get_contact_local_normal(i))))
	_touching = now
	_last_velocity = state.linear_velocity
	if hardest > 0.0:
		hit(hardest)
