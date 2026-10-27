class_name RadioRecordPlayer
extends OfficePrinter

## The record player in the radio's control room (docs/diseno/allanamiento-radio.md, "Su distracción"): E on it puts
## on "the seven-minute song", the "AL AIRE" light goes off and don Volumen goes to the kitchen for a coffee, his back
## to everything (the floor boss's fix, on the same body). It rests REST seconds after each song, and from the third on
## he knows the trick: he doesn't go, and the player says `noticed` instead. It faces +Z. Every number here is
## (propuesta).

## Put on once he already knows the trick.
signal noticed
## The song ended and he's back with his coffee: on air again.
signal song_ended

const MODEL := preload("res://assets/models/record_player.glb")
const PLAYER_SIZE := Vector3(0.6, 0.9, 0.5)
const REST := 60.0
## Songs that fool him; the next ones he notices.
const TRICKS := 2

## Seconds left before the long song can go on again.
var rest_left := 0.0
## Times the long song went on while it could.
var songs := 0


func _ready() -> void:
	add_child(MODEL.instantiate())
	var build := PlaceBuilder.new(self)
	build.shape(build.body(Vector3(0, PLAYER_SIZE.y / 2, 0)), PLAYER_SIZE)
	button = PushButton.new()
	button.prompt = "PROMPT_RECORD_PLAYER"
	button.color = Color(0.85, 0.15, 0.12)
	button.position = Vector3(0.2, PLAYER_SIZE.y + 0.04, PLAYER_SIZE.z / 2)
	add_child(button)
	button.pressed.connect(print_copies)


## The long song: he goes for his coffee, unless he's already at it, it's resting or he knows the trick.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_RECORD_PLAYING" if is_jammed else "HINT_RECORD_RESTING")
		return
	songs += 1
	if songs > TRICKS:
		rest_left = REST
		noticed.emit()
		return
	is_jammed = true
	jobs += 1
	jammed.emit()


## He's back with his coffee: the song ends and the player rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST
	song_ended.emit()


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
