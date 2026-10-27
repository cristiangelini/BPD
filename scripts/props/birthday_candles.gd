class_name BirthdayCandles
extends OfficePrinter

## The matchbox by the cake at the birthday party raid (docs/diseno/allanamiento-cumple.md, "Su distracción"): E lights
## the candles, and it's cake time: the lights go off and Chispita and the kids sing round the table until the song ends
## (the floor boss's fix, on the same body). While they sing, E on it sings along. Once it's over the candles rest REST
## seconds (the trick ones that light again by themselves). A box of matches facing +z. Every number here is
## (propuesta).

## A cop sang along with the kids.
signal sang(cop: Cop)

const BOX_SIZE := Vector3(0.16, 0.05, 0.1)
const REST := 45.0
const BOX := Color(0.85, 0.2, 0.2)

## Seconds left before they can be lit again.
var rest_left := 0.0


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.box(Vector3(0, BOX_SIZE.y / 2, 0), BOX_SIZE, BOX)
	button = PushButton.new()
	button.prompt = "PROMPT_CANDLES"
	button.color = Color(1.0, 0.7, 0.2)
	button.position = Vector3(0, BOX_SIZE.y + 0.04, 0)
	button.rotation.x = -PI / 2
	button.scale = Vector3.ONE * 0.6
	add_child(button)
	button.pressed.connect(print_copies)


## Light them: cake time, unless they're still resting. During the song, the cop sings along.
func print_copies(cop: Cop = null) -> void:
	if is_jammed:
		if cop:
			sang.emit(cop)
		return
	if rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_CANDLES_RESTING")
		return
	is_jammed = true
	jobs += 1
	button.prompt = "PROMPT_SING"
	jammed.emit()


## The song is over: they blew the candles out, and the candles rest.
func fix() -> void:
	is_jammed = false
	rest_left = REST
	button.prompt = "PROMPT_CANDLES"


func is_lit() -> bool:
	return is_jammed


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
