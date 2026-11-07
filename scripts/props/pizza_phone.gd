class_name PizzaPhone
extends OfficePrinter

## The phone on the pizzeria's counter (docs/diseno/allanamiento-pizzeria.md, "¡Una grande de muzza!"): E calls in an
## order and Don Muzza goes to the dough table to make it, his back to the kitchen and singing, until it's done (the
## floor boss's fix, on the same body). Once he's back the phone rests REST seconds before he answers it again. Every
## number here is (propuesta).

const MODEL := preload("res://assets/models/desk_phone.glb")
const REST := 45.0
const RING := Color(1.0, 0.85, 0.3)
const RING_TIME := 1.5

## Seconds left before he answers it again.
var rest_left := 0.0
var _ring: Label3D


func _ready() -> void:
	add_child(MODEL.instantiate())
	button = PushButton.new()
	button.prompt = "PROMPT_PIZZA_PHONE"
	button.position = Vector3(0, 0.06, 0)
	add_child(button)
	for part in button.get_children():
		if part is MeshInstance3D:
			part.hide()
	button.pressed.connect(print_copies)
	_ring = Label3D.new()
	_ring.text = "RING_PHONE"
	_ring.font_size = 64
	_ring.pixel_size = 0.005
	_ring.outline_size = 10
	_ring.modulate = RING
	_ring.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_ring.position = Vector3(0, 0.35, 0)
	_ring.visible = false
	add_child(_ring)


## Ring: an order for Don Muzza, unless he's still making one or the phone is resting.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_PHONE_BUSY" if is_jammed else "HINT_PHONE_RESTING")
		return
	is_jammed = true
	jobs += 1
	_ring.visible = true
	get_tree().create_timer(RING_TIME).timeout.connect(_ring.hide)
	jammed.emit()


## The order is done: the phone rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST


func is_ringing() -> bool:
	return is_jammed


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
