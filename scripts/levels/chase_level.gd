class_name ChaseLevel
extends Node3D

## The chase case's level (persecucion.md): the whole city with the station, the cops in the guard room, the comisario
## in his office, the patrol car at the door and the suspect's vehicle waiting at the nearest corner, which drives off
## once a cop takes the wheel. The distance meter and the clock show at the top. --place=chase opens it from Play.

## Same seed, same suspect and route. 0 draws one.
@export var case_seed := 0
## Who's getting away (ChaseCase.SUSPECTS); empty draws him with the seed (or --suspect=<id>).
@export var suspect_id := ""
var case: ChaseCase
var truck: SuspectCar
var distance_bar: ProgressBar
var clock: Label
var damage_label: Label
## The school bus's parents' complaint, only for him.
var complaint_bar: ProgressBar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	var parking := city.transform * CityLayout.parking("station")
	$PatrolCar.global_transform = parking.translated_local(Vector3.UP * 0.05)
	if suspect_id == "":
		suspect_id = ChaseCase.pick_suspect(case_seed, OS.get_cmdline_user_args())
	truck = SuspectCar.new()
	truck.name = "SuspectCar"
	truck.kind = suspect_id
	add_child(truck)
	var start := ChaseRoute.nearest_corner(CityLayout.parking("station").origin)
	var route := ChaseRoute.draw(case_seed, ChaseRoute.CORNERS, start)
	if suspect_id == SuspectCar.HIGHWAY:
		# He heads for the highway: the planned streets only lead him to the nearest ramp.
		route.corners = HighwayRoute.city_corners(start, HighwayRoute.nearest_ramp(start))
		truck.follow_path(HighwayRoute.draw(case_seed, start), city.transform)
	else:
		truck.follow(route, city.transform)
	case = ChaseCase.new()
	case.route = route
	case.city_transform = city.transform
	case.case_seed = case_seed
	case.suspect_id = suspect_id
	case.car = $PatrolCar
	case.truck = truck
	case.station_parking = parking
	case.shift_screen = $ShiftScreen
	case.solved_label = %CaseSolved
	case.failed_label = %CaseFailed
	case.world_environment = $Environment
	case.sun = $Sun
	add_child(case)
	case.start(city.comisario)
	_add_meters()
	# The copilot's map: the patrol car, and the suspect for whoever reads it.
	city.map.setup(city, "", $PatrolCar)
	city.map.suspect = truck
	city.map.shows_suspect = func() -> bool: return case.tasks.shows_suspect() and case.weather.shows_suspect()


func _add_meters() -> void:
	var hud := CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	hud.add_child(box)
	clock = Label.new()
	clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock.add_theme_font_size_override("font_size", 32)
	clock.add_theme_constant_override("outline_size", 8)
	box.add_child(clock)
	var title := Label.new()
	title.text = "HUD_DISTANCE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	distance_bar = ProgressBar.new()
	distance_bar.custom_minimum_size = Vector2(320, 18)
	distance_bar.max_value = ChaseCase.ESCAPED
	distance_bar.show_percentage = false
	distance_bar.modulate = Color(1, 0.45, 0.35)
	box.add_child(distance_bar)
	if case.suspect_id == "school_bus":
		var parents := Label.new()
		parents.text = "HUD_PARENTS"
		parents.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(parents)
		complaint_bar = ProgressBar.new()
		complaint_bar.custom_minimum_size = Vector2(320, 18)
		complaint_bar.max_value = ChaseCase.COMPLAINT_FULL
		complaint_bar.show_percentage = false
		complaint_bar.modulate = Color(1, 0.8, 0.3)
		box.add_child(complaint_bar)
		case.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)
	damage_label = Label.new()
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.modulate = Color(1, 0.5, 0.4)
	damage_label.add_theme_constant_override("outline_size", 6)
	damage_label.hide()
	box.add_child(damage_label)
	add_child(hud)
	_show(0.0, ChaseCase.TIME_LIMIT)
	case.meters_changed.connect(_show)
	case.damages.crashed.connect(func(fines: int) -> void:
		damage_label.text = tr("HUD_DAMAGES") % fines
		damage_label.show())


func _show(distance: float, time_left: float) -> void:
	distance_bar.value = distance
	clock.text = "%d:%02d" % [int(ceilf(time_left)) / 60, int(ceilf(time_left)) % 60]
