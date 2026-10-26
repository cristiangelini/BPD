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
## The key the cops have doesn't fit this door (the bank's manager who is the boss gave a wrong one).
var wrong_key := false

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
		if wrong_key:
			cop.show_hint("HINT_DOOR_WRONG_KEY")
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


## Swung shut by someone (the party's boss back from the office), still unlocked.
func close() -> void:
	if is_open and not is_broken:
		_swing(false)


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
