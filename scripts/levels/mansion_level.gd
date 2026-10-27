class_name MansionLevel
extends Node3D

## The mansion case's level (escena-mansion.md, step 1): no city, only the Candelabro mansion on its hill (Mansion)
## under the storm (MansionStorm), with the patrol car on the drive and the cops at the front door. --place=mansion
## opens it from Play. The comisario gives the case by radio at the door (CrimeSceneCase, mansion variant, step 5),
## and the board and its stamp are in the library.

## Same seed, same mansion. 0 draws one.
@export var case_seed := 0
var mansion: Mansion
var storm: MansionStorm
var case: CrimeSceneCase
var board: CrimeBoard
var stamp: BoardStamp


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	mansion = Mansion.new()
	mansion.name = "Mansion"
	mansion.case_seed = case_seed
	add_child(mansion)
	storm = MansionStorm.new()
	storm.name = "Storm"
	storm.storm_seed = case_seed
	storm.roof_center = Vector3(0, Mansion.ROOF / 2, (Mansion.BACK_Z + Mansion.FRONT_Z) / 2)
	storm.roof_size = Vector3(Mansion.HALF_X * 2 + 0.6, Mansion.ROOF + 0.4, Mansion.FRONT_Z - Mansion.BACK_Z + 0.6)
	add_child(storm)
	$Cop.global_position = mansion.to_global(Mansion.COP_AT)
	$Cop.rotation.y = 0.0
	$PatrolCar.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), mansion.to_global(Mansion.PATROL_CAR_AT)) \
		.translated(Vector3.UP * 0.05)
	case = CrimeSceneCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.place = mansion
	board = CrimeBoard.new()
	board.name = "Board"
	board.case = case
	add_child(board)
	board.global_transform = mansion.global_transform * Mansion.BOARD_AT
	stamp = BoardStamp.new()
	stamp.name = "Stamp"
	stamp.board = board
	add_child(stamp)
	stamp.global_position = mansion.to_global(Mansion.STAMP_AT)
	case.board = board
	case.shift_screen = $ShiftScreen
	add_child(case)
	case.start()
