class_name ChaseLevel
extends Node3D

## The chase case's level (persecucion.md): the whole city with the station, the cops in the guard room, the comisario
## in his office, the patrol car at the door and the suspect's vehicle waiting at the nearest corner, which drives off
## once a cop takes the wheel. The distance meter and the clock show at the top. --place=chase opens it from Play.

## Same seed, same suspect and route. 0 draws one.
@export var case_seed := 0
## Who's getting away (ChaseCase.SUSPECTS); empty draws him with the seed (or --suspect=<id>).
@export var suspect_id := ""
const PATROL_CAR := preload("res://scenes/vehicles/patrol_car.tscn")
## Where the old patrol car waits, in the station's lot: beside it, by the back, its nose to the front street.
const OLD_CAR_SPOT := Transform3D(Basis.IDENTITY, Vector3(-21, 0.05, -2))

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
	if suspect_id == SuspectCar.GOLF:
		# The thieves wait at a hole of the golf club and drive hole to hole.
		truck.follow_path(GolfLayout.cart_route(case_seed), city.transform)
		for golfer in get_tree().get_nodes_in_group("golfers"):
			truck.add_collision_exception_with(golfer)
	elif suspect_id == SuspectCar.HIGHWAY:
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
	var old_car: PatrolCar = null
	if suspect_id == SuspectCar.TOW:
		# The tow truck takes the patrol car from the door: the old one waits beside the station.
		old_car = PATROL_CAR.instantiate()
		old_car.name = "OldPatrolCar"
		old_car.old = true
		add_child(old_car)
		old_car.global_transform = city.transform * CityLayout.lot("station") * OLD_CAR_SPOT
		case.car = old_car
	case.station_parking = parking
	case.shift_screen = $ShiftScreen
	case.solved_label = %CaseSolved
	case.failed_label = %CaseFailed
	case.world_environment = $Environment
	case.sun = $Sun
	add_child(case)
	case.start(city.comisario)
	if old_car:
		case.tow($PatrolCar)
	_add_meters()
	# The copilot's map: the patrol car, and the suspect for whoever reads it.
	city.map.setup(city, "", case.car)
	city.map.suspect = truck
	city.map.shows_suspect = func() -> bool: return case.tasks.shows_suspect() and case.weather.shows_suspect()


func _add_meters() -> void:
	var meters := ChaseMeters.new()
	meters.case = case
	add_child(meters)
	distance_bar = meters.distance_bar
	clock = meters.clock
	damage_label = meters.damage_label
	complaint_bar = meters.complaint_bar
