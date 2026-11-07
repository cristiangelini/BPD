class_name TrainLevel
extends Node3D

## The train case's level (escena-tren.md): no city, only the train El Lento (Train) with the scenery running past,
## and the cops already on board in first class. --place=train opens it from Play. The comisario gives the case by
## radio as the train leaves (CrimeSceneCase, train variant), and the portable board hangs in the dining car.

## Same seed, same train.
@export var case_seed := 0
var train: Train
var case: CrimeSceneCase
var board: CrimeBoard
var stamp: BoardStamp


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
	case = CrimeSceneCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.place = train
	board = CrimeBoard.new()
	board.name = "Board"
	board.case = case
	add_child(board)
	board.global_transform = train.global_transform * Train.BOARD_AT
	stamp = BoardStamp.new()
	stamp.name = "Stamp"
	stamp.board = board
	add_child(stamp)
	stamp.global_position = train.to_global(Train.STAMP_AT)
	case.board = board
	case.shift_screen = $ShiftScreen
	add_child(case)
	case.start()
