class_name ChaseCase
extends Node

## The chase (persecucion.md, decision 94): the comisario says a suspect is getting away, and once a cop takes the
## wheel the suspect drives off (SuspectCar) and the clock starts. The distance meter fills while the patrol car is far
## and empties while it's close. Stopped for STOP_SECONDS in a row, the suspect gets out and gives up; cuffed, walked
## to the patrol car and driven back to the station, the case is solved. The distance reaching ESCAPED or the clock
## running out before he's cuffed loses it. Every number here is (propuesta), except the minute (Cristian, 20/10).

## The suspects (persecucion.md, "Los sospechosos"), each with what he leaves behind (ChaseDrops).
const SUSPECTS := ["ice_cream", "moving_truck", "school_bus", "rain", "night", "moto", "wheelchair", "highway"]
## Seconds to catch him: the chase has a clock (Cristian, 20/10: "pongamos primero 1 minuto").
const TIME_LIMIT := 60.0
## Farther than this (m) the meter climbs CLIMB a second; closer it drops DROP a second. At ESCAPED he got away.
const FAR := 60.0
const CLIMB := 5.0
const DROP := 5.0
const ESCAPED := 100.0
## On the highway everything is farther (persecucion-lugares.md): the meter climbs only past this.
const HIGHWAY_FAR := 100.0
## Stopped this long in a row (cut off, boxed in), he gives up and gets out.
const STOP_SECONDS := 3.0
## He gets out by his door: this far to his vehicle's left.
const DOOR_OUT := 2.0
## The grandpa in the electric wheelchair you chase on foot (persecucion.md): the chase starts once a cop gets this
## close to him (or takes the wheel), the distance counts from the nearest cop, and only a cop on foot in his way, this
## close, makes him give up; the patrol car in his way doesn't.
const ON_FOOT := ["wheelchair"]
const START_NEAR := 25.0
const BLOCK_NEAR := 2.5
## A chase pays the salary and has its own quota, like the interrogation (decision 91).
const QUOTA := ShiftReport.SALARY
const SHIFT_DELAY := 2.5
## The school bus: every hard ram raises the parents' complaint this much, and full it loses the case.
const RAM_COMPLAINT := 35.0
const COMPLAINT_FULL := 100.0
## How close to its spot at the station the car has to stop to end the shift (RaidCase).
const STATION_RADIUS := RaidCase.STATION_RADIUS
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

signal meters_changed(distance: float, time_left: float)
signal complaint_changed(complaint: float)

var case_seed := 0
var suspect_id := "ice_cream"
var car: PatrolCar
var truck: SuspectCar
## His route, and where the city sits in the world (the route is in the city's space).
var route: ChaseRoute
var city_transform := Transform3D.IDENTITY
## Each seat's job (the map, the megaphone...).
var tasks: ChaseTasks
## The crashes into the city, and their fines.
var damages: ChaseDamages
## What the suspect leaves on the street behind him (ice cream, furniture).
var drops: ChaseDrops
## The rain or the night, when the chase has them; the level hands over its sky and sun before start().
var weather: ChaseWeather
## The highway's traffic and the backup radio, only when he takes the highway.
var highway: ChaseHighway
var world_environment: WorldEnvironment
var sun: DirectionalLight3D
var station_parking: Transform3D
var shift_screen: ShiftScreen
var solved_label: Label
var failed_label: Label
## The suspect out of his vehicle, and his walk to the patrol car.
var suspect: ChaseSuspect
var escort: OwnerEscort

var briefing: CaseBriefing
var tip_given := false
## The suspect is driving off and the clock runs.
var chasing := false
var distance := 0.0
var time_left := TIME_LIMIT
## He got out (stopped) and a cop cuffed him (caught): the clock stops once he's caught.
var stopped := false
var caught := false
var case_solved := false
var case_failed := false
## The school bus's parents' complaint.
var complaint := 0.0
var shift_over := false
var _result := {}
var _told_on_foot := false


static func pick_suspect(seed_value: int, args: PackedStringArray) -> String:
	for arg in args:
		if arg.begins_with("--suspect=") and SUSPECTS.has(arg.trim_prefix("--suspect=")):
			return arg.trim_prefix("--suspect=")
	return SUSPECTS[hash("chase suspect %d" % seed_value) % SUSPECTS.size()]


## With a comisario at the station, the case waits until a cop talks to him, and the car stays locked until then.
func start(comisario: Comisario = null) -> void:
	add_to_group("chase")
	truck.driving = false
	briefing = CaseBriefing.new()
	add_child(briefing)
	tasks = ChaseTasks.new()
	tasks.case = self
	add_child(tasks)
	damages = ChaseDamages.new()
	damages.car = car
	add_child(damages)
	damages.rammed.connect(_on_rammed)
	drops = ChaseDrops.new()
	drops.case = self
	add_child(drops)
	weather = ChaseWeather.new()
	weather.case = self
	add_child(weather)
	if suspect_id == SuspectCar.HIGHWAY:
		highway = ChaseHighway.new()
		highway.case = self
		add_child(highway)
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		car.locked_hint = "HINT_COMISARIO_FIRST"
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	shift_screen.play_again.connect(func() -> void: PlaceDraw.start(get_tree()))
	shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	car.locked_hint = ""
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_CHASE_A", "BRIEF_CHASE_" + suspect_id, "BRIEF_CHASE_C"]))
			break
	_hint_all("HINT_GO_CHASE")


func _physics_process(delta: float) -> void:
	if case_failed or case_solved or not tip_given:
		return
	if not chasing:
		# The suspect drives off once a cop takes the wheel (or, on foot, walks up to him).
		if car.driver() or (on_foot() and _nearest_cop() < START_NEAR):
			chasing = true
			truck.driving = true
		return
	if not caught:
		time_left = maxf(time_left - delta, 0.0)
	if not stopped:
		var gap := _nearest_cop() if on_foot() else _flat(car.global_position - truck.global_position).length()
		distance = clampf(distance + (CLIMB if gap > far() else -DROP) * delta, 0.0, ESCAPED)
		if truck.stuck_for >= STOP_SECONDS:
			if not on_foot() or _cop_on_foot_near():
				pull_over()
			elif not _told_on_foot:
				_told_on_foot = true
				_hint_all("HINT_CHASE_ON_FOOT")
	meters_changed.emit(distance, time_left)
	if not caught and suspect and suspect.is_cuffed():
		caught = true
		_hint_all("HINT_CHASE_CAUGHT")
	if distance >= ESCAPED:
		fail("CASE_FAILED_ESCAPED")
	elif time_left <= 0.0 and not caught:
		fail("CASE_FAILED_TIME")
	elif caught and escort.in_car and all_in_car() and car_at_station():
		case_solved = true
		solved_label.show()
		_finish_soon()


## How far the patrol car can fall behind before the meter climbs: farther with him on the highway.
func far() -> float:
	var highway := get_tree().get_first_node_in_group("highway") as Highway
	return HIGHWAY_FAR if highway and highway.covers(truck.global_position) else FAR


## This chase is on foot (the wheelchair).
func on_foot() -> bool:
	return ON_FOOT.has(suspect_id)


## Meters from the suspect to the nearest cop, on foot or in the car.
func _nearest_cop() -> float:
	var nearest := INF
	for cop in get_tree().get_nodes_in_group("cops"):
		nearest = minf(nearest, _flat((cop as Node3D).global_position - truck.global_position).length())
	return nearest


## Whether a cop on foot (not in the car) is right by him: the one in his way.
func _cop_on_foot_near() -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		if not (cop as Cop).vehicle and _flat((cop as Node3D).global_position - truck.global_position).length() < BLOCK_NEAR:
			return true
	return false


static func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)


## A hard ram on the school bus, full of kids: the parents complain.
func _on_rammed() -> void:
	if suspect_id != "school_bus" or case_failed or case_solved:
		return
	complaint = minf(complaint + RAM_COMPLAINT, COMPLAINT_FULL)
	complaint_changed.emit(complaint)
	_hint_all("HINT_CHASE_KIDS")
	if complaint >= COMPLAINT_FULL:
		fail("CASE_FAILED_PARENTS")


## He gives up: the vehicle stays where it is and he gets out by his door, ready to be cuffed.
func pull_over() -> void:
	if stopped:
		return
	stopped = true
	truck.driving = false
	truck.get_off()
	suspect = ChaseSuspect.new()
	suspect.name = "Suspect"
	suspect.kind = suspect_id
	get_parent().add_child(suspect)
	suspect.global_position = truck.global_position + truck.global_basis.x * DOOR_OUT + Vector3.UP * 0.1
	suspect.rotation.y = truck.rotation.y
	escort = OwnerEscort.attach(suspect, car)
	escort.in_car_hint = "HINT_CHASE_IN_CAR"
	_hint_all("HINT_CHASE_STOPPED")


func all_in_car() -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).vehicle != car:
			return false
	return true


func car_at_station() -> bool:
	return car.global_position.distance_to(station_parking.origin) < STATION_RADIUS


func fail(reason: String) -> void:
	if case_failed or case_solved:
		return
	case_failed = true
	truck.driving = false
	failed_label.text = reason
	failed_label.show()
	_finish_soon()


func _finish_soon() -> void:
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The end of shift screen: caught and brought in pays the salary, got away nothing.
func finish_shift() -> void:
	if shift_over:
		return
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	var report := ShiftReport.pay(case_solved, [], damages.fines)
	var result := {"solved": case_solved, "report": report, "crashes": damages.crashes,
		"awards": ShiftReport.awards(stats)}
	var campaign := Campaign.current
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.finish_shift("chase_" + suspect_id, case_solved, report, QUOTA)
		campaign.save()
		result.campaign = {"shift": played, "money": campaign.money, "over": campaign.is_over(),
			"promoted": campaign.is_promoted()}
	_show_result(result)


func _show_result(result: Dictionary) -> void:
	shift_over = true
	_result = result
	for cop in get_tree().get_nodes_in_group("cops"):
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	solved_label.hide()
	failed_label.hide()
	var awards: Array[Dictionary] = []
	awards.assign(result.awards)
	shift_screen.show_report(result.solved, result.report, result.crashes, awards, "SHIFT_FINES_CRASHES")
	var over := false
	if result.has("campaign"):
		shift_screen.show_campaign(result.campaign.shift, Campaign.SHIFTS, result.campaign.money, result.campaign.over,
			result.campaign.promoted)
		over = result.campaign.over
	shift_screen.get_node("%AgainButton").visible = not over


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
