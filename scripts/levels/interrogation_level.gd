class_name InterrogationLevel
extends Node3D

## The interrogation case's level (interrogatorio.md): the whole city with the station, the cops in the guard room,
## the comisario in his office and the suspect cuffed to the table of the interrogation wing, with the cops' two
## loose chairs, the case folder and a box of donuts on the observers' desk; with the twins, the other one in a cell. The meters show at the top. --place=interrogation opens it from Play.

const DONUTS_SCENE := preload("res://scenes/props/donut_box.tscn")
const CHAIR_SCENE := preload("res://scenes/props/interrogation_chair.tscn")
const FOLDER_SCENE := preload("res://scenes/props/case_folder.tscn")

## Same seed, same crime. 0 draws one.
@export var case_seed := 0
var case: InterrogationCase
var suspect: InterrogationSuspect
var donuts: DonutBox
var folder: CaseFolder
## The twins' case: the twin in the cell.
var twin: InterrogationSuspect
## The foreigner's case: the detainee who translates for him.
var translator: InterrogationSuspect
var chairs: Array[InterrogationChair] = []
## The station's space, where the wing's coordinates are (InterrogationWing).
var wing: Node3D
var nerves_bar: ProgressBar
var lawyer_bar: ProgressBar
var twin_bar: ProgressBar


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
	suspect.kind = InterrogationCase.pick_suspect(case_seed, OS.get_cmdline_user_args())
	# The owner brought in from the last raid takes the chair (decision 93), unless --suspect forces another.
	var held := PlaceDraw.custody_now()
	if not held.is_empty() and not _suspect_forced():
		suspect.kind = "owner_" + str(held.owner)
	suspect.position = InterrogationWing.SUSPECT_AT
	wing.add_child(suspect)
	for at: Vector3 in InterrogationWing.CHAIRS_AT:
		var chair: InterrogationChair = CHAIR_SCENE.instantiate()
		chair.position = at
		chair.rotation.y = PI
		wing.add_child(chair)
		chairs.append(chair)
	folder = FOLDER_SCENE.instantiate()
	folder.position = InterrogationWing.FOLDER_AT
	wing.add_child(folder)
	if suspect.kind == "twins":
		twin = InterrogationSuspect.new()
		twin.name = "Twin"
		twin.kind = suspect.kind
		twin.position = InterrogationWing.TWIN_AT
		twin.rotation.y = PI
		wing.add_child(twin)
	if suspect.kind == "foreigner":
		translator = InterrogationSuspect.new()
		translator.name = "Translator"
		translator.kind = "translator"
		translator.position = InterrogationWing.TRANSLATOR_AT
		translator.rotation.y = -0.7
		translator.bubble_height = 2.6
		wing.add_child(translator)
	donuts = DONUTS_SCENE.instantiate()
	donuts.position = InterrogationWing.DONUTS_AT
	wing.add_child(donuts)
	case = InterrogationCase.new()
	case.case_seed = case_seed
	case.suspect = suspect
	case.suspect_id = "owner" if suspect.kind.begins_with("owner_") else suspect.kind
	if case.suspect_id == "owner":
		case.custody = held.duplicate()
	case.twin = twin
	case.translator = translator
	case.guilty_in_cell = InterrogationCase.pick_guilty_in_cell(case_seed)
	if suspect.kind == "dangerous":
		# He can take the old patrol car parked by the station (persecucion-final.md).
		var old := SuspectCar.new()
		old.name = "OldPatrolCar"
		old.kind = SuspectCar.OLD_PATROL
		old.driving = false
		add_child(old)
		old.global_transform = city.transform * CityLayout.lot("station") * ChaseLevel.OLD_CAR_SPOT
		case.getaway = old
		if city.map:
			city.map.setup(city, "", $PatrolCar)
	case.car = $PatrolCar
	case.city = city
	case.city_map = city.map
	case.shift_screen = $ShiftScreen
	case.solved_label = %CaseSolved
	case.failed_label = %CaseFailed
	add_child(case)
	_add_meters()
	case.start(city.comisario)


func _suspect_forced() -> bool:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--suspect="):
			return true
	return false


func _add_meters() -> void:
	var hud := CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	hud.add_child(box)
	nerves_bar = _meter(box, "HUD_NERVES", Color(1, 0.8, 0.3))
	lawyer_bar = _meter(box, "HUD_LAWYER", Color(1, 0.45, 0.35))
	if twin:
		twin_bar = _meter(box, "HUD_TWIN_NERVES", Color(1, 0.8, 0.3))
		case.twin_changed.connect(func(nerves: float) -> void: twin_bar.value = nerves)
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
