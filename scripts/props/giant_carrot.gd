class_name GiantCarrot
extends StaticBody3D

## The giant carrot in Don Florencio's vegetable garden (docs/diseno/allanamiento-granja.md, "Las zanahorias
## gigantes"): taller than a cop and stuck fast. E on it is a tug, and one cop alone can't pull it out: it only comes
## out when two different cops tug within PULL_WINDOW of each other. Online the host decides (the rig syncs it).
## Every number here is (propuesta).

## A tug that didn't pull it out (alone, or the other cop was too late).
signal tugged(cop: Cop)
signal pulled_out(cops: Array[Cop])

const PULL_WINDOW := 1.0

var out := false
## Cop -> when (ms) it last tugged.
var _tugs := {}


func prompt_key(_cop: Cop) -> String:
	return "" if out else "PROMPT_PULL_CARROT"


func use(cop: Cop) -> void:
	if out or not multiplayer.is_server():
		return
	var now := Time.get_ticks_msec()
	_tugs[cop] = now
	var pulling: Array[Cop] = []
	for other: Cop in _tugs:
		if is_instance_valid(other) and now - int(_tugs[other]) <= PULL_WINDOW * 1000.0:
			pulling.append(other)
	if pulling.size() < 2:
		tugged.emit(cop)
		return
	out = true
	pulled_out.emit(pulling)
