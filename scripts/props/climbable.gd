class_name Climbable
extends StaticBody3D

## A fence a cop (or a runaway suspect) climbs over (ciudad-viva.md, step 4): the backyards' wooden fences and the
## alleys' chain-link fences. Jump against it and you're over in CLIMB_TIME. `top` is its height over the ground
## at its base, and its body sits at the middle of that height. Every number here is (propuesta).

const CLIMB_TIME := 1.0
## How far ahead of the middle of the cop's chest a fence counts (their body is 0.5 m wide each way), and how far past
## it they land.
const REACH := 1.2
const LAND_PAST := 1.1

@export var top := 1.8


## The climb for someone at `from` facing `ahead`: {over: the top they pass, to: where they land}, or empty if
## there's no fence right in front. `exclude` are the climber's own bodies.
static func find(space: PhysicsDirectSpaceState3D, from: Vector3, ahead: Vector3, exclude: Array[RID]) -> Dictionary:
	ahead.y = 0.0
	ahead = ahead.normalized()
	var chest := from + Vector3.UP * 0.9
	var query := PhysicsRayQueryParameters3D.create(chest, chest + ahead * REACH)
	query.exclude = exclude
	var hit := space.intersect_ray(query)
	if hit.is_empty() or not hit.collider is Climbable:
		return {}
	var fence: Climbable = hit.collider
	var over: Vector3 = hit.position
	over.y = fence.global_position.y + fence.top / 2 + 0.1
	var to: Vector3 = hit.position + ahead * LAND_PAST
	to.y = from.y
	return {"over": over, "to": to}


## Where a climber is `t` (0 to 1) into a climb from `from`: up to the top first, then over and down.
static func along(from: Vector3, climb: Dictionary, t: float) -> Vector3:
	var over: Vector3 = climb.over
	var to: Vector3 = climb.to
	if t < 0.6:
		var up := t / 0.6
		var at := from.lerp(Vector3(over.x, from.y, over.z), up * 0.5)
		at.y = lerpf(from.y, over.y, up)
		return at
	var down := (t - 0.6) / 0.4
	var at := Vector3(over.x, 0, over.z).lerp(Vector3(to.x, 0, to.z), down)
	at.y = lerpf(over.y, to.y, down * down)
	return at
