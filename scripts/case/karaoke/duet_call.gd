class_name DuetCall
extends OfficePrinter

## Rosaura's weak spot at the karaoke (allanamiento-karaoke.md, "Su distracción, el dueto"): nobody sings without her.
## A cop up on the stage with microphone 2 calls her to sing along by their side, facing the lyrics screen with her
## back to the room, for the floor boss's fix time. After a duet the duets rest REST seconds, and from the CATCH_ON-th
## one on she sees through it and gets angry instead (`caught_on`). Every number here is (propuesta).

## A cop wants a duet: she heads to the stage (emitted before `jammed`).
signal called
## "Ustedes no son fans de verdad…": no duet, only a complaint.
signal caught_on

const REST := 45.0
const CATCH_ON := 3

## How many duets the cops asked for, and how long until the next one counts.
var calls := 0
var rest_left := 0.0


func _ready() -> void:
	pass


## A cop with microphone 2 on the stage.
func duet() -> void:
	if is_jammed or rest_left > 0.0:
		return
	calls += 1
	rest_left = REST
	if calls >= CATCH_ON:
		caught_on.emit()
		return
	is_jammed = true
	jobs += 1
	called.emit()
	jammed.emit()


func print_copies(_cop: Cop = null) -> void:
	duet()


## The duet is over.
func fix() -> void:
	is_jammed = false


func _process(delta: float) -> void:
	if not is_jammed:
		rest_left = maxf(rest_left - delta, 0.0)
