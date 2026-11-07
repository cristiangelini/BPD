class_name ZooLevel
extends Node3D

## The zoo case's level (escena-zoo.md, step 1): the whole city with the station, the cops in the guard room and the
## patrol car at the door, the board room open, and the Zoológico Municipal on its block (Zoo). --place=zoo opens it
## from Play. The comisario gives the case (CrimeSceneCase, zoo variant) and the board room has its board and stamp
## (step 7).

## Same seed, same zoo. 0 draws one.
@export var case_seed := 0
var zoo: Zoo
var case: CrimeSceneCase
var board: CrimeBoard
var stamp: BoardStamp


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	zoo = Zoo.new()
	zoo.name = "Zoo"
	zoo.case_seed = case_seed
	zoo.transform = city.transform * CityLayout.lot("zoo")
	add_child(zoo)
	case = CrimeSceneCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.place = zoo
	var station := city.transform * CityLayout.lot("station")
	board = CrimeBoard.new()
	board.name = "Board"
	board.case = case
	add_child(board)
	board.global_transform = station * CrimeSceneLevel.BOARD_AT
	stamp = BoardStamp.new()
	stamp.name = "Stamp"
	stamp.board = board
	add_child(stamp)
	stamp.global_position = station * CrimeSceneLevel.STAMP_AT
	case.board = board
	case.shift_screen = $ShiftScreen
	add_child(case)
	case.start(city.comisario)
