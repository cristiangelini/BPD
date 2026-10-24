class_name PrisonEscort
extends OwnerEscort

## Walking a cuffed ringleader to the punishment cell (carcel-motin.md, step 4, decision 104): the owner's escort
## (OwnerEscort) with the cell instead of the patrol car. Walked in through its barred door, the ringleader stays
## there, out of the riot, at one of SPOTS so three fit. Every number here is (propuesta).

## Where they end up in the cell (level space, on its floor) by how many are in already.
const SPOTS: Array[Vector2] = [Vector2(-11.5, -6.4), Vector2(-10.6, -6.4), Vector2(-10.6, -5.2)]
## Walked this far into the cell's rectangle (grown by it), they count as in.
const IN_REACH := 0.4

var prison: PrisonLevel


static func to_cell(inmate: PrisonInmate, level: PrisonLevel) -> PrisonEscort:
	var escort := PrisonEscort.new()
	escort.name = "Escort"
	escort.npc = inmate
	escort.prison = level
	escort.in_car_hint = "HINT_RINGLEADER_JAILED"
	inmate.add_child(escort)
	return escort


func prompt_key(cop: Cop) -> String:
	if in_car:
		return ""
	return "PROMPT_LET_GO_INMATE" if escorted_by == cop else "PROMPT_ESCORT_INMATE"


func _physics_process(delta: float) -> void:
	if in_car:
		return
	super(delta)


## In the cell: their feet inside its rectangle, seen from above.
func near_car() -> bool:
	var local := prison.global_transform.affine_inverse() * npc.global_position
	return PrisonLevel.PUNISHMENT.grow(IN_REACH).has_point(Vector2(local.x, local.z))


func board() -> void:
	in_car = true
	escorted_by = null
	var inside := prison.riot.jailed if prison.riot else 0
	var spot := SPOTS[mini(inside, SPOTS.size() - 1)]
	npc.global_position = prison.global_transform * Vector3(spot.x, PrisonLevel.FLOOR_TOP, spot.y)
	npc.set_physics_process(true)
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(in_car_hint)
	boarded.emit()
