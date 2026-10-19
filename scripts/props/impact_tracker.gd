class_name ImpactTracker
extends RefCounted

## Measures how hard a rigid body just hit something: the speed along the contact normal of contacts that are new
## this physics step (resting contacts don't count again). The body needs contact_monitor on.

## Colliders touching last physics step.
var _touching := {}
var _last_velocity := Vector3.ZERO


## Call from _integrate_forces. Returns the hardest new impact this step in m/s, or 0.
func hardest(state: PhysicsDirectBodyState3D) -> float:
	var now := {}
	var result := 0.0
	for i in state.get_contact_count():
		var id := state.get_contact_collider_id(i)
		now[id] = true
		if _touching.has(id):
			continue
		var relative := _last_velocity - state.get_contact_collider_velocity_at_position(i)
		result = maxf(result, absf(relative.dot(state.get_contact_local_normal(i))))
	_touching = now
	_last_velocity = state.linear_velocity
	return result
