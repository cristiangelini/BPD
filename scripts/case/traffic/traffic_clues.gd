class_name TrafficClues
extends Node

## The wanted car's clues as the cops get them (control-transito.md, "Cómo se reconoce al buscado"): the first one
## when the case starts and one more from the radio every WantedPlan.RADIO_EVERY seconds, until the three are known.

signal clue_given(index: int, text: String)

var plan: WantedPlan
var known := 0
var elapsed := 0.0


func _ready() -> void:
	_catch_up()


func _physics_process(delta: float) -> void:
	elapsed += delta
	_catch_up()


func _catch_up() -> void:
	while known < WantedPlan.known_at(elapsed):
		known += 1
		clue_given.emit(known - 1, plan.clue_text(known - 1))


## The clues known so far, one per line.
func known_text() -> String:
	var lines: Array[String] = []
	for i in known:
		lines.append("· " + plan.clue_text(i))
	return "\n".join(lines)
