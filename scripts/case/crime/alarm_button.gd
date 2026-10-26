class_name AlarmButton
extends StaticBody3D

## The big button on the museum's security desk that stops the alarm (MuseumAlarm). E presses it.

const COLOR := Color(0.95, 0.75, 0.1)

var alarm: MuseumAlarm


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.14, 0.08, 0.14)
	shape.shape = box
	add_child(shape)
	var cap := CylinderMesh.new()
	cap.top_radius = 0.05
	cap.bottom_radius = 0.06
	cap.height = 0.05
	PlaceBuilder.new(self).mesh(cap, Vector3(0, 0.025, 0), COLOR)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ALARM_OFF"


func use(cop: Cop) -> void:
	if alarm:
		alarm.stop(cop)
