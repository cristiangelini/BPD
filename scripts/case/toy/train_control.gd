class_name TrainControl
extends OfficePrinter

## The toy train's control box by the toy store's counter (docs/diseno/allanamiento-jugueteria.md, "Su distracción"):
## E on its lever runs the train too fast, it derails on the tunnel's curve and don Cucho goes to put it back on the
## track, bent over it with his back to everything (the floor boss's printer fix, on the same body). It rests REST
## seconds after each derail, and from the third on he knows the trick: he doesn't go, and the box says `noticed`
## instead. Every number here is (propuesta).

## Pushed once he already knows the trick.
signal noticed

const BOX_SIZE := Vector3(0.4, 1.0, 0.4)
const BOX := Color(0.16, 0.16, 0.2)
const LEVER := Color(0.91, 0.29, 0.23)
const REST := 60.0
## Derails that fool him; the next ones he notices.
const TRICKS := 2

## Seconds left before it can be pushed again.
var rest_left := 0.0
## Times it was pushed while it could.
var tries := 0


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.box(Vector3(0, BOX_SIZE.y / 2, 0), BOX_SIZE, BOX)
	button = PushButton.new()
	button.prompt = "PROMPT_TRAIN_LEVER"
	button.color = LEVER
	button.position = Vector3(0, BOX_SIZE.y - 0.15, BOX_SIZE.z / 2 + 0.02)
	add_child(button)
	button.pressed.connect(print_copies)


## The derail: he goes to put it back, unless he's already at it, it's resting or he knows the trick.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_TRAIN_DERAILED" if is_jammed else "HINT_TRAIN_RESTING")
		return
	tries += 1
	if tries > TRICKS:
		rest_left = REST
		noticed.emit()
		return
	is_jammed = true
	jobs += 1
	jammed.emit()


## He put it back on the track: it rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
