class_name FrontDoor
extends Node3D

## The grandpa's locked front door (docs/diseno/allanamiento.md, "La casa del abuelo").
## It opens with the key from a pot, or breaks after RAM_HITS hits of the battering ram.

signal opened
signal broken

const RAM_HITS := 3
const SWING := deg_to_rad(100.0)
const SWING_TIME := 0.5

var locked := true
var is_open := false
var is_broken := false
var hits := 0

@onready var _panel: AnimatableBody3D = $Panel


func prompt_key(cop: Cop) -> String:
	if is_broken:
		return ""
	if locked and not cop.has_key:
		return "PROMPT_DOOR_LOCKED"
	return "PROMPT_DOOR"


func use(cop: Cop) -> void:
	if is_broken:
		return
	if locked:
		if not cop.has_key:
			cop.show_hint("HINT_DOOR_LOCKED")
			return
		locked = false
		cop.show_hint("HINT_DOOR_UNLOCKED")
	_swing(not is_open)


## Unlocked and opened by someone inside (the bank's sorry robber), with no key.
func open_from_inside() -> void:
	if is_broken:
		return
	locked = false
	if not is_open:
		_swing(true)


## One battering ram hit; at RAM_HITS the door comes off. Returns true if this hit broke it.
func ram_hit() -> bool:
	if is_broken or is_open:
		return false
	hits += 1
	if hits < RAM_HITS:
		return false
	is_broken = true
	locked = false
	# The panel falls flat inside the house, out of the way.
	_panel.collision_layer = 0
	var tween := create_tween()
	tween.tween_property(_panel, "rotation:x", -PI / 2, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	broken.emit()
	return true


func _swing(open: bool) -> void:
	is_open = open
	var tween := create_tween()
	tween.tween_property(self, "rotation:y", SWING if open else 0.0, SWING_TIME).set_trans(Tween.TRANS_SINE)
	if open:
		opened.emit()
