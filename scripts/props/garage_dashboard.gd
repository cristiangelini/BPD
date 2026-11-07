class_name GarageDashboard
extends StaticBody3D

## A client's car's dashboard seen through the driver's window (docs/diseno/allanamiento-taller.md, "El cuentakilómetros
## mágico"): E on it shows the cop what its odometer says (`reading`, a text key the story sets). Facing -x, on the car's
## left side. Every number here is (propuesta).

## A cop read it.
signal read(cop: Cop)

const SIZE := Vector3(0.06, 0.3, 0.5)

## What the cop reads: a tr() key.
var reading := "HINT_ODOMETER"


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_DASHBOARD"


func use(cop: Cop) -> void:
	cop.show_hint(reading)
	read.emit(cop)
