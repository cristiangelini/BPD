class_name FormsOfficeLevel
extends Node3D

## The office case's level (escena-oficina.md, step 1): the whole city with the station, the cops in the guard room
## and the patrol car at the door, the board room open, and the office on its lot (FormsOffice). --place=office opens
## it from Play. The employees and the case come in later steps.

## Same seed, same office. 0 draws one.
@export var case_seed := 0
var office: FormsOffice


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	office = FormsOffice.new()
	office.name = "Office"
	office.case_seed = case_seed
	office.transform = city.transform * CityLayout.lot("office")
	add_child(office)
