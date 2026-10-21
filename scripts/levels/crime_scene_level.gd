class_name CrimeSceneLevel
extends Node3D

## The crime scene case's level (escena-del-crimen.md): the whole city with the station, the cops in the guard room
## and the patrol car at the door, and the pastry contest's tent in the plaza with its six cooks. --place=crime_scene
## opens it from Play; the case itself comes in the next steps.

## Same seed, same cooks. 0 draws one.
@export var case_seed := 0
var contest: PastryContest


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
