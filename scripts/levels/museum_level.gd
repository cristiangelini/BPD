class_name MuseumLevel
extends Node3D

## The museum case's level (escena-museo.md): the whole city with the station, the cops in the guard room and the
## patrol car at the door, the board room open with its board and stamp, and the museum on its lot (Museum).
## --place=museum opens it from Play. The comisario gives the case (CrimeSceneCase, museum variant).

## Same seed, same museum. 0 draws one.
@export var case_seed := 0
var museum: Museum
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
	museum = Museum.new()
	museum.name = "Museum"
	museum.case_seed = case_seed
	museum.transform = city.transform * CityLayout.lot("museum")
	add_child(museum)
	case = CrimeSceneCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.place = museum
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
