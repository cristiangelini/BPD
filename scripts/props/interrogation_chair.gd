class_name InterrogationChair
extends Grabbable

## One of the cops' steel chairs in the interrogation room (interrogatorio.md, "Las acciones"): loose, so a cop can
## grab it and throw it. Landing hard near the suspect, it's the bad cop's chair (+15 nerves, +12 lawyer).

## How hard it has to land, in m/s, and how close to him (propuesta).
const THROW_SPEED := 3.0
const REACH := 4.0
## A cop who let go of it this recently threw it.
const THROWN_SECONDS := 2.0

var _impacts := ImpactTracker.new()


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var speed := _impacts.hardest(state)
	if speed > THROW_SPEED and holders.is_empty() and not handling_cops(THROWN_SECONDS).is_empty():
		_landed.call_deferred()


func _landed() -> void:
	var case := InterrogationCase.active(get_tree(), self)
	if case and case.chair_thrown(self):
		# One throw counts once, however many times it bounces.
		let_go_at = -1
