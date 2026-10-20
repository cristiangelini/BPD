class_name InterrogationLevel
extends Node3D

## The interrogation case's level (interrogatorio.md): the whole city with the station, the cops in the guard room,
## the comisario in his office and the suspect cuffed to the table of the interrogation wing, with a box of donuts on
## the observers' desk. The meters show at the top. --place=interrogation opens it from Play.

const DONUTS_SCENE := preload("res://scenes/props/donut_box.tscn")

## Same seed, same crime. 0 draws one.
@export var case_seed := 0
var case: InterrogationCase
var suspect: InterrogationSuspect
var donuts: DonutBox
## The station's space, where the wing's coordinates are (InterrogationWing).
var wing: Node3D
var nerves_bar: ProgressBar
var lawyer_bar: ProgressBar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	wing = Node3D.new()
	wing.name = "Wing"
	wing.transform = city.transform * CityLayout.lot("station")
	add_child(wing)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	suspect = InterrogationSuspect.new()
	suspect.name = "Suspect"
	suspect.position = InterrogationWing.SUSPECT_AT
	wing.add_child(suspect)
	donuts = DONUTS_SCENE.instantiate()
	donuts.position = InterrogationWing.DONUTS_AT
	wing.add_child(donuts)
	case = InterrogationCase.new()
	case.case_seed = case_seed
	case.suspect = suspect
	case.shift_screen = $ShiftScreen
	case.solved_label = %CaseSolved
	case.failed_label = %CaseFailed
	add_child(case)
	_add_meters()
	case.start(city.comisario)


func _add_meters() -> void:
	var hud := CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	hud.add_child(box)
	nerves_bar = _meter(box, "HUD_NERVES", Color(1, 0.8, 0.3))
	lawyer_bar = _meter(box, "HUD_LAWYER", Color(1, 0.45, 0.35))
	add_child(hud)
	case.meters_changed.connect(func(nerves: float, lawyer: float) -> void:
		nerves_bar.value = nerves
		lawyer_bar.value = lawyer)


func _meter(box: VBoxContainer, key: String, color: Color) -> ProgressBar:
	var title := Label.new()
	title.text = key
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.show_percentage = false
	bar.modulate = color
	box.add_child(bar)
	return bar
