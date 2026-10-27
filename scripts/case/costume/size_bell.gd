class_name SizeBell
extends OfficePrinter

## Don Fantoche's weak spot at the costume shop (allanamiento-disfraces.md, "Su distracción, el talle"): the bell on
## the counter. E rings it, and he goes to the stock room at the back for "the biggest size", his back to the shop,
## for the floor boss's fix time. After a ring the bell rests REST seconds, and from the CATCH_ON-th ring on he sees
## through it and grows suspicious instead (`caught_on`). Every number here is (propuesta).

## A cop rang: he heads to the stock room (emitted before `jammed`).
signal rung
## "¿Tanto talle para qué?": no errand, only a complaint.
signal caught_on

const REST := 45.0
const CATCH_ON := 3
const GOLD := Color(0.95, 0.75, 0.2)
const RADIUS := 0.09

## How many rings counted, and how long until the next one counts.
var rings := 0
var rest_left := 0.0


func _ready() -> void:
	var bell := CounterBell.new()
	add_child(bell)
	bell.rang.connect(print_copies)


## A ring: off he goes, unless he's away already or the last ring was a moment ago.
func ring(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_COSTUME_BELL_WAIT")
		return
	rings += 1
	rest_left = REST
	if rings >= CATCH_ON:
		caught_on.emit()
		return
	is_jammed = true
	jobs += 1
	rung.emit()
	jammed.emit()


func print_copies(cop: Cop = null) -> void:
	ring(cop)


## He's back with the size.
func fix() -> void:
	is_jammed = false


func _process(delta: float) -> void:
	if not is_jammed:
		rest_left = maxf(rest_left - delta, 0.0)
