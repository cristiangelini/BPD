class_name TrainBrake
extends StaticBody3D

## The emergency brake's lever in the locomotive (escena-tren.md, "El freno de emergencia"): E pulls it and the train
## stops in the middle of the field (Train.pull_brake). Twice per case at most: then don Silbato padlocks it.

const SIZE := Vector3(0.3, 1.1, 0.3)
const RED := Color(0.85, 0.15, 0.1)

var train: Train
var _lever: Node3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_lever = Node3D.new()
	add_child(_lever)
	PlaceBuilder.new(_lever).mesh_box(Vector3(0, SIZE.y / 2, 0), Vector3(0.06, SIZE.y, 0.06), RED)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRAIN_BRAKE"


func use(cop: Cop) -> void:
	if train.brake_left > 0.0:
		cop.show_hint("HINT_TRAIN_BRAKE_ON")
	elif train.brake_pulls >= Train.BRAKE_PULLS:
		cop.show_hint("HINT_TRAIN_BRAKE_JAMMED")
	else:
		train.pull_brake()
		cop.show_hint(tr("HINT_TRAIN_BRAKE") % [int(Train.BRAKE_SECONDS), Train.BRAKE_FINE])


func _physics_process(_delta: float) -> void:
	_lever.rotation.x = -0.7 if train and train.brake_left > 0.0 else 0.0
