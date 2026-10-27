class_name DjSong
extends OfficePrinter

## The rink's DJ booth (docs/diseno/allanamiento-pista.md, "Su distracción, su canción"): E on its red button plays "El
## vals del pingüino", and Doña Pirueta skates to the middle of the ice to dance her whole routine with her eyes closed
## (the floor boss's fix, on the same body). She comes once every REST seconds, and the third time she catches on. Built
## in the booth's space: the DJ's side to -z, the crowd's (the ice) to +z. Every number here is (propuesta).

## Her song played but this time she knows what's going on.
signal caught_on

const MODEL := preload("res://assets/models/dj_booth.glb")
const DESK := Vector3(2.2, 1.2, 0.8)
const BUTTON_AT := Vector3(0, 1.06, -0.15)
const REST := 45.0
## The songs that take her to the ice; from the next one on she catches on.
const FOOLS := 2
## How long the notes float over the booth.
const NOTES_TIME := 20.0

## Seconds left before her song takes her away again.
var rest_left := 0.0
var plays := 0
var distractions := 0
var _notes: Label3D


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.shape(build.body(Vector3(0, DESK.y / 2, 0)), DESK)
	add_child(MODEL.instantiate())
	button = PushButton.new()
	button.prompt = "PROMPT_RINK_SONG"
	button.position = BUTTON_AT
	button.rotation.x = -PI / 2
	add_child(button)
	button.pressed.connect(play)
	_notes = Label3D.new()
	_notes.text = "RINK_SONG_PLAYING"
	_notes.font_size = 64
	_notes.pixel_size = 0.008
	_notes.outline_size = 12
	_notes.modulate = Color(1.0, 0.6, 0.85)
	_notes.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_notes.position = Vector3(0, 2.4, 0)
	_notes.visible = false
	add_child(_notes)


## Her song: she skates off to dance it, unless she danced less than REST seconds ago, or it's the third time and she
## catches on.
func play(_cop: Cop = null) -> void:
	plays += 1
	_show_notes()
	if is_jammed or rest_left > 0.0:
		return
	if distractions >= FOOLS:
		caught_on.emit()
		rest_left = REST
		return
	distractions += 1
	is_jammed = true
	jobs += 1
	rest_left = REST
	jammed.emit()


func _show_notes() -> void:
	_notes.visible = true
	var shown := plays
	get_tree().create_timer(NOTES_TIME).timeout.connect(func() -> void:
		if plays == shown:
			_notes.visible = false)


## Her routine is over: back to her round.
func fix() -> void:
	is_jammed = false


func is_dancing() -> bool:
	return is_jammed


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
