class_name TheaterLevel
extends Node3D

## The theater case's level (escena-teatro.md, step 1): the whole city with the station, the cops in the guard room
## and the patrol car at the door, the board room open with its board and stamp, and the Teatro Municipal on its lot
## (Theater). --place=theater opens it from Play. The comisario gives the case (CrimeSceneCase, theater variant, step 7).

## Same seed, same theater. 0 draws one.
@export var case_seed := 0
var theater: Theater
var case: CrimeSceneCase
var board: CrimeBoard
var stamp: BoardStamp


func _enter_tree() -> void:
	# Before the city builds itself: no ground under the stage, so the basement goes one floor down.
	($City as City).live_hole = Theater.BASEMENT_HOLE


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	theater = Theater.new()
	theater.name = "Theater"
	theater.case_seed = case_seed
	theater.transform = city.transform * CityLayout.lot("theater")
	add_child(theater)
	case = CrimeSceneCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.place = theater
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
