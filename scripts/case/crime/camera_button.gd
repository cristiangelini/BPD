class_name CameraButton
extends StaticBody3D

## One of the two buttons on the ringmaster's camera (RingmasterCamera) or the museum's monitors (SecurityMonitors):
## "play" or "delete". E presses it.

var button := "play"
var camera: RingmasterCamera


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.08, 0.06, 0.08)
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return (camera.prompts if camera else "PROMPT_CAMERA_") + button


func use(cop: Cop) -> void:
	if not camera:
		return
	if button == "play":
		camera.play(cop)
	else:
		camera.delete(cop)
