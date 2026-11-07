class_name DustPrint
extends FlourPrint

## The culprit's footprint in the sorting room's dust (escena-correo.md, "Las pistas"): under the loose letters until
## the sorting machine runs the first time (`uncover`), pointing to where the stamp went. A photo of it notes the shoe
## size; a cop who steps on it wipes it out, and the next run covers it with letters again (`cover`).

const DUST := Color(0.66, 0.62, 0.55)

var uncovered := false


func _init() -> void:
	dust = DUST


func _ready() -> void:
	super()
	visible = false


## The first run blew the letters off it.
func uncover() -> void:
	if wiped:
		return
	uncovered = true
	visible = true


## A later run before anyone photographed it: letters all over it, and it's lost.
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
