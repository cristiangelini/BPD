class_name SmokeDetector
extends Node3D

## The smoke detector on a cell's ceiling in the fire drill jailbreak (docs/diseno/fuga-simulacro.md, step 1): enough
## smoke from the cell's heater (CellHeater) and it rings, and its red light blinks. The level starts the drill on
## `rang` (step 2).

signal rang

const MODEL := preload("res://assets/models/smoke_detector.glb")
const BLINK := 0.25

var ringing := false
var _model: Node3D
var _blink := 0.0


func _ready() -> void:
	add_to_group("smoke_detectors")
	_model = MODEL.instantiate()
	add_child(_model)


func ring() -> void:
	if ringing:
		return
	ringing = true
	rang.emit()


## Quiet again (the drill is over).
func hush() -> void:
	ringing = false
	_model.visible = true


func _process(delta: float) -> void:
	if not ringing:
		return
	_blink += delta
	_model.visible = int(_blink / BLINK) % 2 == 0


## Online (NpcSync): ringing or not.
func net_state() -> Variant:
	return ringing


func apply_net_state(state: Variant) -> void:
	if state and not ringing:
		ringing = true
	elif not state and ringing:
		hush()
