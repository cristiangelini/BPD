class_name AquariumLevel
extends Node3D

## The aquarium case's level (escena-acuario.md, step 1): the whole city with the station, the cops in the guard room
## and the patrol car at the door, the board room open, and the Municipal Aquarium on its lot (Aquarium).
## --place=aquarium opens it from Play. The people and the case come in later steps.

## Same seed, same aquarium. 0 draws one.
@export var case_seed := 0
var aquarium: Aquarium


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	aquarium = Aquarium.new()
	aquarium.name = "Aquarium"
	aquarium.case_seed = case_seed
	aquarium.transform = city.transform * CityLayout.lot("aquarium")
	add_child(aquarium)
