class_name TalcPrint
extends FlourPrint

## The culprit's footprint in the talc on the back of the stage (escena-teatro.md, "Las pistas"): out of sight until
## the turntable turns the first time (`uncover`). A photo of it notes the shoe size; a cop who steps on it wipes it
## out, and the next change sweeps it away under the flat (`cover`).

const TALC := Color(0.96, 0.95, 0.97)

var uncovered := false


func _init() -> void:
	dust = TALC


func _ready() -> void:
	super()
	visible = false


## The first turn brought it into view.
func uncover() -> void:
	if wiped:
		return
	uncovered = true
	visible = true


## A later change before anyone photographed it: the flat sweeps it away.
func cover() -> void:
	if wiped or not uncovered:
		return
	visible = false
	wipe()


func photo_clues() -> Dictionary:
	return super() if uncovered and visible else {}


func _physics_process(delta: float) -> void:
	if uncovered:
		super(delta)
