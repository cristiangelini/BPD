class_name InfiltrationPlace
extends Node3D

## What every infiltration place has in common (infiltracion-coro.md, step 1): the grandparents' club and the church
## choir are both one of these. The place builds itself and its people, and InfiltrationCase plays the case on top of
## it: the people who watch (members, with their suspicion), the boss to cuff, the evidence, where the boss runs off
## from and the patrol car. `variant` picks the case's texts and the boss's getaway (InfiltrationCase.VARIANTS).

## Same seed, same place (the people and the evidence). 0 draws one.
@export var case_seed := 0
## Which case this place plays: a key of InfiltrationCase.VARIANTS.
var variant := ""
## The people who watch the cops, and the boss (also watching), the one to cuff.
var members: Array[ClubMember] = []
var boss: ClubMember
var suspicion: ClubSuspicion
var evidence: ClubEvidence
var case: InfiltrationCase
var station_parking: Transform3D

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


## Draws the seed if there's none, from Play's draw or a new one.
func take_seed() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()


## Moves the city so the place's lot sits here, and the cops and the patrol car to the station, where the disguises
## are.
func place_in_city(lot: String) -> void:
	city.transform = CityLayout.anchor(lot)
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)


## Creates the case on top of the place, once the people and the evidence are in.
func start_case() -> void:
	case = InfiltrationCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.place = self
	case.shift_screen = $ShiftScreen
	add_child(case)
	evidence.found.connect(func(kind: String) -> void: case.found(kind))
	case.start(city.comisario)


## Where the boss's getaway waits when they find the cops out, in the world. Each place says where.
func getaway_at() -> Transform3D:
	return global_transform


## The planilla's row of what the clues found say about the boss, or "" (the party's guests look alike: the clues tell
## the boss's costume, infiltracion-fiesta.md). `bonus` is the clue the cops got on their own (seeing the boss).
func clue_row(_found: Array[String], _bonus: bool) -> String:
	return ""


## What the cops bought here and pay out of the shift's pay (the art auction's lots, infiltracion-subasta.md): how
## many and how much. Nothing anywhere else.
func bought() -> int:
	return 0


func spent() -> int:
	return 0
