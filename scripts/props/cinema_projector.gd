class_name CinemaProjector
extends OfficePrinter

## The old projector in the "Cine Butaca Floja" booth (docs/diseno/allanamiento-cine.md, "Su distracción"): E on it
## cuts the tape, the screen goes white and doña Bobina runs up to splice it, her back to everything (the floor boss's
## fix, on the same body). It rests REST seconds after each splice, and from the third cut on she knows the trick: she
## doesn't come, and the projector says `noticed` instead. It faces +Z, out of the booth's window. Every number here is
## (propuesta).

## Cut once she already knows the trick.
signal noticed
## She spliced the tape: the film goes on.
signal spliced

const MODEL := preload("res://assets/models/film_projector.glb")
const REST := 45.0
## Cuts that fool her; the next ones she notices.
const TRICKS := 2

## Seconds left before it can be cut again.
var rest_left := 0.0
## Times the tape was cut while it could be.
var cuts := 0


func _ready() -> void:
	add_child(MODEL.instantiate())
	var build := PlaceBuilder.new(self)
	build.shape(build.body(Vector3(0, 0.6, 0)), Vector3(0.5, 1.2, 0.8))
	button = PushButton.new()
	button.prompt = "PROMPT_PROJECTOR"
	button.color = Color(0.85, 0.15, 0.12)
	button.position = Vector3(0.12, 1.0, -0.37)
	button.rotation.y = PI
	add_child(button)
	button.pressed.connect(print_copies)


## A cut: she comes to splice it, unless she's already at it, it's resting or she knows the trick.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_PROJECTOR_CUT" if is_jammed else "HINT_PROJECTOR_RESTING")
		return
	cuts += 1
	if cuts > TRICKS:
		rest_left = REST
		noticed.emit()
		return
	is_jammed = true
	jobs += 1
	jammed.emit()


## She spliced it: the film goes on and the projector rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST
	spliced.emit()


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
