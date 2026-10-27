class_name GymStereo
extends OfficePrinter

## The reception's stereo at the gym raid (docs/diseno/allanamiento-gimnasio.md, "Su distracción"): E on its play
## button puts on the aerobics song, and the profe gives a class to the mirror until it ends (the floor boss's fix, on
## the same body). Once it's over the stereo rests REST seconds before it plays again. Built like a boombox, its front to
## +z. Every number here is (propuesta).

const MODEL := preload("res://assets/models/gym_stereo.glb")
const STEREO_SIZE := Vector3(0.8, 0.4, 0.22)
const REST := 45.0
const NOTES := Color(1.0, 0.35, 0.75)

## Seconds left before it can play again.
var rest_left := 0.0
var _notes: Label3D
var _beat := 0.0


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.shape(build.body(Vector3(0, STEREO_SIZE.y / 2, 0)), STEREO_SIZE)
	add_child(MODEL.instantiate())
	button = PushButton.new()
	button.prompt = "PROMPT_STEREO"
	button.color = Color(0.25, 0.8, 0.4)
	button.position = Vector3(0, 0.45, 0.05)
	button.rotation.x = -PI / 2
	add_child(button)
	button.pressed.connect(print_copies)
	_notes = Label3D.new()
	_notes.text = "♪ ♫ ♪"
	_notes.font_size = 64
	_notes.pixel_size = 0.006
	_notes.outline_size = 10
	_notes.modulate = NOTES
	_notes.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_notes.position = Vector3(0, 0.75, 0)
	_notes.visible = false
	add_child(_notes)


## Play: the song and the class, unless it's already on or still resting.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_STEREO_PLAYING" if is_jammed else "HINT_STEREO_RESTING")
		return
	is_jammed = true
	jobs += 1
	_notes.visible = true
	jammed.emit()


## The class is over: the song stops and the stereo rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST
	_notes.visible = false


func is_playing() -> bool:
	return is_jammed


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
	if is_jammed:
		_beat += delta
		_notes.position.y = 0.75 + absf(sin(_beat * 6.0)) * 0.15
