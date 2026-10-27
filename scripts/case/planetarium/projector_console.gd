class_name ProjectorConsole
extends StaticBody3D

## The star projector's console in the control room (escena-planetario.md, "El Pedrusco, escondido en el planetario"):
## its log keeps every show. The culprit paused the show at 3 in the morning to hide the stone, and the projector stayed
## on a planet. E reads the log through, which takes a while (Planetarium.read_console): the planet, if the stone is
## under a seat; otherwise, a full show with no pauses.

var planetarium: Planetarium


func _init(size := Vector3.ONE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PROJECTOR_CONSOLE"


func use(cop: Cop) -> void:
	if planetarium:
		planetarium.read_console(cop)
