class_name SoftServeMachine
extends OfficePrinter

## The soft-serve machine in the ice cream shop's kitchen (docs/diseno/allanamiento-heladeria.md, "Su distracción"): E
## on its lever jams it and it pours ice cream without stopping, and doña Nieve fights it for a while, her back to
## everything (the floor boss's printer fix, on the same body). It rests REST seconds after each jam, and from the
## third on she knows the trick: she doesn't go, and the machine says `noticed` instead. It faces +Z. Every number here
## is (propuesta).

## Jammed once she already knows the trick.
signal noticed

const MODEL := preload("res://assets/models/soft_serve_machine.glb")
const MACHINE_SIZE := Vector3(0.7, 1.7, 0.7)
const REST := 60.0
## Jams that fool her; the next ones she notices.
const TRICKS := 2

## Seconds left before it can be jammed again.
var rest_left := 0.0
## Times it was jammed while it could.
var tries := 0


func _ready() -> void:
	add_child(MODEL.instantiate())
	var build := PlaceBuilder.new(self)
	build.shape(build.body(Vector3(0, MACHINE_SIZE.y / 2, 0)), MACHINE_SIZE)
	button = PushButton.new()
	button.prompt = "PROMPT_SOFT_MACHINE"
	button.color = Color(0.95, 0.45, 0.62)
	button.position = Vector3(0, 1.1, MACHINE_SIZE.z / 2 + 0.02)
	add_child(button)
	button.pressed.connect(print_copies)


## The jam: she goes to fight it, unless she's already at it, it's resting or she knows the trick.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_SOFT_MACHINE_JAMMED" if is_jammed else "HINT_SOFT_MACHINE_RESTING")
		return
	tries += 1
	if tries > TRICKS:
		rest_left = REST
		noticed.emit()
		return
	is_jammed = true
	jobs += 1
	jammed.emit()


## She got it to stop: it rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
