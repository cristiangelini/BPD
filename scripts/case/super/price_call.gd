class_name PriceCall
extends OfficePrinter

## The checkouts' red "¡Precio, por favor!" buttons at the supermarket (allanamiento-super.md, "Su distracción"): E on
## one calls Don Ofertón to that checkout, where he spends the floor boss's fix time looking up a price in his giant
## binder with his back to the store. Then the buttons rest REST seconds. From the CATCH_ON-th call on he sees through
## it and gets angry instead (`caught_on`). Every number here is (propuesta).

## A cop pressed the button of checkout `index`: the manager heads there (emitted before `jammed`).
signal called(index: int)
## He saw through it: no price lookup, only a complaint.
signal caught_on

const REST := 45.0
const CATCH_ON := 3
const BUTTON_COLOR := Color(0.9, 0.12, 0.1)

## Where each button sits, in the supermarket's space (set before it's added).
var spots: Array[Vector3] = []
var buttons: Array[PushButton] = []
## Which checkout called him last, and how many times he came.
var checkout := -1
var calls := 0
var rest_left := 0.0


func _ready() -> void:
	for i in spots.size():
		var push := PushButton.new()
		push.name = "Button%d" % i
		push.prompt = "PROMPT_PRICE_BUTTON"
		push.color = BUTTON_COLOR
		push.position = spots[i]
		push.rotation.x = -PI / 2
		add_child(push)
		push.pressed.connect(call_from.bind(i))
		buttons.append(push)
	button = buttons[0] if not buttons.is_empty() else null


## The button of checkout `index`: the call, unless he's already looking up a price or the buttons rest.
func call_from(cop: Cop, index: int) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_PRICE_BUSY" if is_jammed else "HINT_PRICE_RESTING")
		return
	calls += 1
	rest_left = REST
	if calls >= CATCH_ON:
		caught_on.emit()
		return
	checkout = index
	is_jammed = true
	jobs += 1
	called.emit(index)
	jammed.emit()


func print_copies(cop: Cop = null) -> void:
	call_from(cop, 0)


## He found the price: the call is over and the buttons rest.
func fix() -> void:
	is_jammed = false
	rest_left = REST


func _process(delta: float) -> void:
	if not is_jammed:
		rest_left = maxf(rest_left - delta, 0.0)
