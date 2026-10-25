class_name CityEvent
extends Node3D

## One street event (ciudad-viva.md, "Los eventos"): it starts, plays out and finishes, paying what it pays (0 when
## the cops missed it). The director (CityEvents) runs one at a time.

signal finished(money: int)

var done := false


func finish(money: int) -> void:
	if done:
		return
	done = true
	finished.emit(money)
