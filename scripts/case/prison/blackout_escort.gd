class_name BlackoutEscort
extends OwnerEscort

## Walking a cuffed inmate back to a cell in the blackout (carcel-corte-de-luz.md, step 4): the owner's escort
## (OwnerEscort) with any cell of the block (or the punishment cell, step 5: where El Chispa pays the extra) instead of
## the patrol car. Walked into a cell, the inmate stays there
## while its door is shut (E on the bars, by hand: without power the lock doesn't catch); with the door open, once
## the cuffs run out they walk out again and wander the canteen. Every number here is (propuesta).

var prison: PrisonLevel
## The cell they were walked into (0 to 7, or PrisonLevel.PUNISHMENT_CELL), -1 out of one.
var cell := -1


static func to_block(inmate: BlackoutInmate, level: PrisonLevel) -> BlackoutEscort:
	var escort := BlackoutEscort.new()
	escort.name = "Escort"
	escort.npc = inmate
	escort.prison = level
	escort.in_car_hint = "HINT_INMATE_IN_CELL"
	inmate.add_child(escort)
	return escort


func prompt_key(cop: Cop) -> String:
	if in_car:
		return ""
	return "PROMPT_LET_GO_INMATE" if escorted_by == cop else "PROMPT_ESCORT_INMATE_CELL"


## Whether their cell's door is shut.
func locked_in() -> bool:
	return in_car and not prison.cell_door(cell).is_open


func _physics_process(delta: float) -> void:
	if in_car:
		if not follower and not npc.is_cuffed() and prison.cell_door(cell).is_open:
			_walk_out()
		return
	super(delta)


## In a cell: their feet inside one of the block's cells or the punishment cell.
func near_car() -> bool:
	return _cell_here() != -1


func _cell_here() -> int:
	if prison.in_punishment(npc.global_position):
		return PrisonLevel.PUNISHMENT_CELL
	return prison.cell_at(npc.global_position)


func board() -> void:
	in_car = true
	escorted_by = null
	cell = _cell_here()
	npc.set_physics_process(true)
	(npc as BlackoutInmate).jail(cell)
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(in_car_hint)
	boarded.emit()


## The door was left open and the cuffs are off: out again, round the canteen.
func _walk_out() -> void:
	in_car = false
	var from := cell
	cell = -1
	(npc as BlackoutInmate).walk_out(from)
