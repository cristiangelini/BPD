class_name CatMansionLevel
extends Node3D

## The cat case's level (escena-gato.md, step 1): the whole city with the station, the cops in the guard room and the
## patrol car at the door, the board room open, and the Monedero mansion on its lot (CatMansion). --place=cat_mansion
## opens it from Play. The people, the cats and the case come in later steps.

## Same seed, same mansion. 0 draws one.
@export var case_seed := 0
var mansion: CatMansion


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
