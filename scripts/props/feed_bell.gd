class_name FeedBell
extends OfficePrinter

## The feeding bell on Don Florencio's porch (docs/diseno/allanamiento-granja.md, "Su distracción"): E on its cord rings
## it, and Don Florencio goes to feed the animals by the corral, his back to the farm, until his bucket is empty (the
## floor boss's fix, on the same body). The animals aren't hungry that often: once it's over the bell rests REST seconds
## before it calls them again. Mounted on a post, its bell to +z. Every number here is (propuesta).

const MODEL := preload("res://assets/models/feed_bell.glb")
const REST := 45.0
## How far the bell swings while it rings, and how fast.
const SWING := 0.5
const SWING_SPEED := 9.0

## Seconds left before it can ring again.
var rest_left := 0.0
var _look: Node3D
var _dong: Label3D
var _beat := 0.0


func _ready() -> void:
	_look = MODEL.instantiate()
	add_child(_look)
	button = PushButton.new()
	button.prompt = "PROMPT_FEED_BELL"
	button.color = Color(0.8, 0.25, 0.25)
	button.position = Vector3(0, 0.05, 0.3)
	add_child(button)
	button.pressed.connect(print_copies)
	_dong = Label3D.new()
	_dong.text = "FARM_BELL_DONG"
	_dong.font_size = 56
	_dong.pixel_size = 0.006
	_dong.outline_size = 10
	_dong.modulate = Color(1.0, 0.85, 0.3)
	_dong.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_dong.position = Vector3(0, 0.9, 0.3)
	_dong.visible = false
	add_child(_dong)


## Ring: feeding time, unless it already is or the animals still aren't hungry.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_BELL_FEEDING" if is_jammed else "HINT_BELL_RESTING")
		return
	is_jammed = true
	jobs += 1
	_dong.visible = true
	jammed.emit()


## Feeding time is over: the bell rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST
	_dong.visible = false
	_look.rotation.x = 0.0


func is_ringing() -> bool:
	return is_jammed


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
	if is_jammed:
		_beat += delta
		_look.rotation.x = sin(_beat * SWING_SPEED) * SWING * maxf(0.0, 1.0 - _beat / 3.0)
	else:
		_beat = 0.0
