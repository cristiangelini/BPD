class_name WeddingLevel
extends Node3D

## The wedding crime scene's level (escena-boda.md): the whole city with the station, the cop in the guard room and
## the patrol car at the door, and Rosa and Tito's party in the Salón Gala on its lot (WeddingHall). --place=wedding
## opens it from Play. The case comes in step 4.

## Same seed, same wedding. 0 draws one.
@export var case_seed := 0
var hall: WeddingHall


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	hall = WeddingHall.new()
	hall.name = "WeddingHall"
	hall.case_seed = case_seed
	hall.transform = city.transform * CityLayout.lot("party_hall")
	add_child(hall)
