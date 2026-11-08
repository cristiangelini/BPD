class_name PhoneBackpackRig
extends PizzaRaidRig

## The phones in the backpack (allanamiento-pizzeria.md, "Los celulares en la mochila"): Don Muzza's delivery boys
## steal phones at the doors they deliver to. The orders notebook on the counter has addresses that don't exist, the
## story's own clue, and every RING_EVERY seconds all the stolen phones ring at once: a "¡RIIING!" floats RING_SHOW
## seconds over the backpack, wherever it is. Every number here is (propuesta).

const NOTEBOOK_MODEL := preload("res://assets/models/orders_notebook.glb")
## On the counter, between the stacks of plates and the tower of boxes.
const NOTEBOOK_AT := Vector3(-3.4, PizzaRaid.FLOOR_TOP + 1.02, 3.2)
const RING_EVERY := 40.0
const RING_SHOW := 3.0
const RING_COLOR := Color(1.0, 0.85, 0.2)

var notebook: ClueNote
## How many times the phones rang, and seconds since they last did.
var rings := 0
var since_rang := 0.0
## The "¡RIIING!" over the backpack while it shows.
var ring_label: Label3D
var _label_left := 0.0


func setup(place: PizzaRaid) -> void:
	super.setup(place)
	notebook = clue_item("OrdersNotebook", NOTEBOOK_MODEL, Vector3(0.2, 0.03, 0.15), NOTEBOOK_AT,
		"PROMPT_ORDERS_NOTEBOOK", "CLUE_ORDERS_NOTEBOOK")
	ring_label = Label3D.new()
	ring_label.text = tr("PHONES_RIIING")
	ring_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	ring_label.modulate = RING_COLOR
	ring_label.outline_size = 10
	ring_label.pixel_size = 0.006
	ring_label.no_depth_test = true
	ring_label.visible = false
	pizzeria.add_child(ring_label)


func _physics_process(delta: float) -> void:
	if ring_label.visible:
		_label_left -= delta
		if not is_instance_valid(pizzeria.main):
			_label_left = 0.0
		else:
			ring_label.global_position = pizzeria.main.global_position + Vector3.UP * 0.9
		if _label_left <= 0.0:
			ring_label.hide()
	# The host rings the phones; the guests take how many times (net_state).
	if not multiplayer.is_server():
		return
	since_rang += delta
	if since_rang >= RING_EVERY:
		since_rang = 0.0
		ring()


## Every stolen phone rings at once: the "¡RIIING!" shows over the backpack for RING_SHOW seconds.
func ring() -> void:
	rings += 1
	if not is_instance_valid(pizzeria.main):
		return
	_label_left = RING_SHOW
	ring_label.global_position = pizzeria.main.global_position + Vector3.UP * 0.9
	ring_label.show()


func net_state() -> Variant:
	return rings


func apply_net_state(state: Variant) -> void:
	if state > rings:
		rings = state - 1
		ring()
