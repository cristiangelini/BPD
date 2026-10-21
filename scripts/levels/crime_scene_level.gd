class_name CrimeSceneLevel
extends Node3D

## The crime scene case's level (escena-del-crimen.md): the whole city with the station, the cops in the guard room
## and the patrol car at the door, the board room open with its board and stamp, and the pastry contest's tent in the
## plaza with its six cooks. --place=crime_scene opens it from Play. The comisario gives the case (CrimeSceneCase).

## In the station's space: the board on the board room's west wall, facing the room, and the stamp's desk in a corner.
const BOARD_AT := Transform3D(Basis(Vector3.UP, PI / 2), Vector3(-14.75, 0, -4))
const STAMP_AT := Vector3(-7, 0, -7.6)

## Same seed, same cooks. 0 draws one.
@export var case_seed := 0
var contest: PastryContest
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
	contest = PastryContest.new()
	contest.name = "PastryContest"
	contest.case_seed = case_seed
	contest.position = city.transform * (CityLayout.block_center(CityLayout.PLAZA) + PastryContest.OFFSET)
	add_child(contest)
	case = CrimeSceneCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.contest = contest
	var station := city.transform * CityLayout.lot("station")
	board = CrimeBoard.new()
	board.name = "Board"
	board.case = case
	add_child(board)
	board.global_transform = station * BOARD_AT
	stamp = BoardStamp.new()
	stamp.name = "Stamp"
	stamp.board = board
	add_child(stamp)
	stamp.global_position = station * STAMP_AT
	case.board = board
	add_child(case)
	case.start(city.comisario)
