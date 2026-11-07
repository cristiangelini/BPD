class_name GarageBell
extends OfficePrinter

## The service bell on the garage's counter (docs/diseno/allanamiento-taller.md, "Su distracción"): E rings it, Don
## Tuerca rolls out to the counter and spends a while with a client who isn't there, his back to the garage (the floor
## boss's fix, on the same body). It rests REST seconds after each visit, and from the third ring on he knows the trick:
## he doesn't come, and the bell says `noticed` instead. Every number here is (propuesta).

## Rung once he already knows the trick.
signal noticed

const MODEL := preload("res://assets/models/service_bell.glb")
const REST := 45.0
## Rings that fool him; the next ones he notices.
const TRICKS := 2
const GOLD := Color(0.9, 0.72, 0.29)

## Seconds left before it works again.
var rest_left := 0.0
## Times it was rung while it could be.
var rings := 0
var _ding: Label3D


func _ready() -> void:
	add_child(MODEL.instantiate())
	button = PushButton.new()
	button.prompt = "PROMPT_BELL"
	button.color = GOLD
	button.rotation.x = -PI / 2
	add_child(button)
	button.pressed.connect(print_copies)
	_ding = Label3D.new()
	_ding.text = "GARAGE_DING"
	_ding.font_size = 64
	_ding.pixel_size = 0.006
	_ding.outline_size = 10
	_ding.modulate = GOLD
	_ding.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_ding.position = Vector3(0, 0.4, 0)
	_ding.visible = false
	add_child(_ding)


## A ring: he comes to the counter, unless he's already there, the bell is resting or he knows the trick.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_BELL_BUSY" if is_jammed else "HINT_BELL_RESTING")
		return
	rings += 1
	_ding.visible = true
	get_tree().create_timer(1.0).timeout.connect(func() -> void: _ding.visible = false)
	if rings > TRICKS:
		rest_left = REST
		noticed.emit()
		return
	is_jammed = true
	jobs += 1
	jammed.emit()


## The visit is over: the bell rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
