class_name TrainLevel
extends Node3D

## The train case's level (escena-tren.md, step 1): no city, only the train El Lento (Train) with the scenery running
## past, and the cops already on board in first class. --place=train opens it from Play. The case comes in step 4.

## Same seed, same train.
@export var case_seed := 0
var train: Train


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	train = Train.new()
	train.name = "Train"
	train.case_seed = case_seed
	add_child(train)
	$Cop.global_position = train.to_global(Train.SPAWN_AT)
	$Cop.rotation.y = -PI / 2
