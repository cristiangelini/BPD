class_name SalesPitch
extends OfficePrinter

## Don Cajón's weak spot (docs/diseno/allanamiento-muebleria.md, "Su distracción"): a cop trying a sofa or a bed is a
## sale, and he goes to it and talks for a while, his back to the shop (the floor boss's fix, with no printer). It rests
## REST seconds after each pitch, and from the third on he knows the trick: he doesn't come, and the pitch says
## `noticed` instead. Every number here is (propuesta).

## Tried once he already knows the trick.
signal noticed

const REST := 45.0
## Pitches that fool him; the next ones he notices.
const TRICKS := 2

## Seconds left before it works again.
var rest_left := 0.0
## Times a cop tried something while it could work.
var offers := 0
## The piece being sold and the cop on it, while he's at it.
var seat: ShowroomSeat
var buyer: Cop


func _ready() -> void:
	pass


## Whether a cop trying something now would bring him (or give him away), telling the cop why not.
func can_offer(cop: Cop) -> bool:
	if is_jammed or rest_left > 0.0:
		cop.show_hint("HINT_PITCH_BUSY" if is_jammed else "HINT_PITCH_RESTING")
		return false
	return true


## A cop tries `on`: he comes to sell it, or notices the trick.
func offer(on: ShowroomSeat, cop: Cop) -> void:
	offers += 1
	if offers > TRICKS:
		rest_left = REST
		noticed.emit()
		return
	seat = on
	buyer = cop
	is_jammed = true
	jobs += 1
	jammed.emit()


## The pitch is over (or cut short): it rests.
func fix() -> void:
	is_jammed = false
	seat = null
	buyer = null
	rest_left = REST


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
