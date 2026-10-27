class_name TrainWindow
extends StaticBody3D

## The broken window at the back of the luggage car (escena-tren.md, "Las pistas"): the culprit's hair caught on its
## sill. E opens it (and shuts it): open, the wind comes in and takes whatever lies on the sill (TrainClues.blow).

const SIZE := Vector3(0.1, 0.7, 1.0)
const OUTSIDE := Color(0.62, 0.8, 0.95)
const PANE := Color(0.75, 0.88, 0.95, 0.45)
const CRACK := Color(0.1, 0.1, 0.12)

var clues: TrainClues
var open := false
## The pane hangs from its top edge: open, it swings up into the car.
var _hinge: Node3D


func _init() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0, 0), Vector3(0.01, SIZE.y, SIZE.z), OUTSIDE)
	_hinge = Node3D.new()
	_hinge.position = Vector3(0.04, SIZE.y / 2, 0)
	add_child(_hinge)
	var pane := PlaceBuilder.new(_hinge)
	pane.mesh_box(Vector3(0, -SIZE.y / 2, 0), Vector3(0.03, SIZE.y - 0.04, SIZE.z - 0.04), PANE)
	for crack: Vector3 in [Vector3(0.6, 0, 0.5), Vector3(-0.7, 0, -0.3)]:
		pane.mesh_box(Vector3(0.02, -SIZE.y / 2, crack.z * 0.4), Vector3(0.01, 0.4, 0.015), CRACK)
		(_hinge.get_child(_hinge.get_child_count() - 1) as Node3D).rotation.x = crack.x


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRAIN_WINDOW_SHUT" if open else "PROMPT_TRAIN_WINDOW_OPEN"


func use(cop: Cop) -> void:
	set_open(not open)
	if open:
		cop.show_hint("HINT_TRAIN_WINDOW_WIND")
		if clues:
			clues.blow()


## Open or shut, the pane on its hinge (a guest's window follows the host's).
func set_open(is_open: bool) -> void:
	open = is_open
	_hinge.rotation.z = 1.2 if open else 0.0
