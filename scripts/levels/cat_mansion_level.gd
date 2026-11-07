class_name CatMansionLevel
extends Node3D

## The cat case's level (escena-gato.md, step 1): the whole city with the station, the cops in the guard room and the
## patrol car at the door, the board room open, and the Monedero mansion on its lot (CatMansion). --place=cat_mansion
## opens it from Play. The comisario gives the case (CrimeSceneCase, cat variant).

## Same seed, same mansion. 0 draws one.
@export var case_seed := 0
var mansion: CatMansion
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
	mansion = CatMansion.new()
	mansion.name = "CatMansion"
	mansion.case_seed = case_seed
	mansion.transform = city.transform * CityLayout.lot("cat_mansion")
	add_child(mansion)
	case = CrimeSceneCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.place = mansion
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
