class_name HotelKeyBoard
extends StaticBody3D

## The key board behind the hotel's reception desk (hotel-allanamiento.md, "Cómo se entra"): E takes the master key,
## which opens every room and the suite. Don Bostezo doesn't like anyone taking it while he's awake (step 2 listens to
## `taken`). There are keys for every cop.

signal taken(at: Vector3)

const SIZE := Vector3(2.0, 0.9, 0.08)
const COLOR := Color(0.62, 0.45, 0.3)


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)


func prompt_key(cop: Cop) -> String:
	return "" if cop.has_key else "PROMPT_HOTEL_KEY_BOARD"


func use(cop: Cop) -> void:
	if cop.has_key:
		return
	cop.has_key = true
	cop.show_hint("HINT_HOTEL_KEY")
	taken.emit(global_position)
