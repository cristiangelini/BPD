class_name SoundConsole
extends StaticBody3D

## The sound guy's console at the karaoke (allanamiento-karaoke.md, step 4): E on it turns the music down for LOW_TIME
## seconds. Toto hears for the first time in years and talks, and every customer complains once that the music is
## gone. The music comes back up by itself. Every number here is (propuesta).

## A cop turned the volume down.
signal turned_down(cop: Cop)

const SIZE := Vector3(2.4, 1.0, 0.8)
const LOW_TIME := 10.0

var low_left := 0.0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "" if is_low() else "PROMPT_VOLUME_DOWN"


func use(cop: Cop) -> void:
	if is_low():
		return
	low_left = LOW_TIME
	cop.show_hint("HINT_KARAOKE_VOLUME")
	turned_down.emit(cop)


func is_low() -> bool:
	return low_left > 0.0


func _process(delta: float) -> void:
	low_left = maxf(low_left - delta, 0.0)
