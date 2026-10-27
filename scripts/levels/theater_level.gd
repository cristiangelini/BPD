class_name TheaterLevel
extends Node3D

## The theater case's level (escena-teatro.md, step 1): the whole city with the station, the cops in the guard room
## and the patrol car at the door, the board room open, and the Teatro Municipal on its lot (Theater).
## --place=theater opens it from Play. The people and the case come in later steps.

## Same seed, same theater. 0 draws one.
@export var case_seed := 0
var theater: Theater


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
