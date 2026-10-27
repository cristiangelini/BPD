class_name PostOfficeLevel
extends Node3D

## The post office case's level (escena-correo.md, step 1): the whole city with the station, the cops in the guard
## room and the patrol car at the door, the board room open, and the Correo Central on its lot (PostOffice).
## --place=post_office opens it from Play. The people and the case come in later steps.

## Same seed, same post office. 0 draws one.
@export var case_seed := 0
var post_office: PostOffice


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	post_office = PostOffice.new()
	post_office.name = "PostOffice"
	post_office.case_seed = case_seed
	post_office.transform = city.transform * CityLayout.lot("post_office")
	add_child(post_office)
