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
## Rubber gloves from the armory (comisaria.md): hits while a gloved cop holds it, or just after one let go or threw
## it, take this share of the loss (propuesta).
const GLOVES_FACTOR := 0.5
const GLOVES_GRACE := 2.0

@export var full_value := 1000.0
## Hits at or below this speed do nothing; tougher things (a gold ring) raise it.
@export var safe_speed := SAFE_SPEED

var value := 0.0
var is_broken := false

var _impacts := ImpactTracker.new()

@onready var _label: Label3D = get_node_or_null("ValueLabel")


func _ready() -> void:
	add_to_group("evidence")
	value = full_value
	contact_monitor = true
	max_contacts_reported = 8
	_show_value()


## Placeholder feedback until the HUD exists: the value floats over the object (a number, so no text key).
func _show_value() -> void:
	if _label and full_value > 0.0:
		_label.text = "%d" % roundi(value)
		_label.modulate = Color.WHITE.lerp(Color(1, 0.25, 0.2), 1.0 - value / full_value)


## Applies a hit at `speed` m/s and returns the value lost.
func hit(speed: float) -> float:
	# Things worth nothing (a dog that isn't a story's) never break.
	if is_broken or full_value <= 0.0 or speed <= safe_speed:
		return 0.0
	var loss := full_value * LOSS_PER_SPEED * (speed - safe_speed)
	if handling_cops(GLOVES_GRACE).any(func(c: Cop) -> bool: return c.gloves):
		loss *= GLOVES_FACTOR
	loss = minf(value, loss)
	value -= loss
	_show_value()
	damaged.emit(loss)
	if value <= 0.0:
		value = 0.0
		is_broken = true
		broken.emit()
	return loss


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var speed := _impacts.hardest(state)
	if speed > 0.0:
		hit(speed)
