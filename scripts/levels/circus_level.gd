class_name CircusLevel
extends Node3D

## The circus case's level (escena-circo.md): the whole city with the station, the cops in the guard room and the
## patrol car at the door, the board room open with its board and stamp, and the Cascabel Brothers' circus on its lot
## (Circus). --place=circus opens it from Play. The comisario gives the case (CrimeSceneCase, circus variant).

## Same seed, same circus. 0 draws one.
@export var case_seed := 0
var circus: Circus
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
	circus = Circus.new()
	circus.name = "Circus"
	circus.case_seed = case_seed
	circus.transform = city.transform * CityLayout.lot("circus")
	add_child(circus)
	case = CrimeSceneCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.place = circus
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
