class_name NextPatientBell
extends OfficePrinter

## The next-patient bell on the dental office's reception (docs/diseno/allanamiento-dentista.md, "¡Siguiente!"): E rings
## it and Dr. Molina goes to "see" the next patient in consulting room 1, his back to the door and the drill buzzing,
## until he's done (the floor boss's fix, on the same body). Once he's back the bell rests REST seconds before he minds
## it again. Every number here is (propuesta).

const MODEL := preload("res://assets/models/next_bell.glb")
const REST := 45.0
const DING := Color(1.0, 0.85, 0.3)
const DING_TIME := 1.2

## Seconds left before it calls him again.
var rest_left := 0.0
var _ding: Label3D


func _ready() -> void:
	add_child(MODEL.instantiate())
	button = PushButton.new()
	button.prompt = "PROMPT_NEXT_BELL"
	button.position = Vector3(0, 0.06, 0)
	add_child(button)
	for part in button.get_children():
		if part is MeshInstance3D:
			part.hide()
	button.pressed.connect(print_copies)
	_ding = Label3D.new()
	_ding.text = "DING_BELL"
	_ding.font_size = 64
	_ding.pixel_size = 0.005
	_ding.outline_size = 10
	_ding.modulate = DING
	_ding.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_ding.position = Vector3(0, 0.35, 0)
	_ding.visible = false
	add_child(_ding)


## Ding: the doctor's next patient, unless he's still with one or the bell is resting.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or rest_left > 0.0:
		if cop:
			cop.show_hint("HINT_BELL_BUSY" if is_jammed else "HINT_BELL_RESTING")
		return
	is_jammed = true
	jobs += 1
	_ding.visible = true
	get_tree().create_timer(DING_TIME).timeout.connect(_ding.hide)
	jammed.emit()


## The patient is done: the bell rests.
func fix() -> void:
	is_jammed = false
	rest_left = REST


func is_ringing() -> bool:
	return is_jammed


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
