class_name ChaseCase
extends Node

## The chase (persecucion.md, decision 94): the comisario says a suspect is getting away, and once a cop takes the
## wheel the suspect drives off (SuspectCar) and the clock starts. The distance meter fills while the patrol car is far
## and empties while it's close. Stopped for STOP_SECONDS in a row, the suspect gets out and gives up; cuffed, walked
## to the patrol car and driven back to the station, the case is solved. The distance reaching ESCAPED or the clock
## running out before he's cuffed loses it. Every number here is (propuesta), except the minute (Cristian, 20/10).

## The suspects (persecucion.md, "Los sospechosos"), each with what he leaves behind (ChaseDrops).
const SUSPECTS := ["ice_cream", "moving_truck", "school_bus", "rain", "night", "moto", "wheelchair", "highway",
	"tow_truck", "golf_cart"]
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
## The tow truck takes the patrol car (persecucion-lugares.md, "La grúa"): the cops chase him in the old one or on
## foot, so the distance counts from the nearest cop and the chase starts as they come out of the station.
const CLOSE_BY := ["wheelchair", "tow_truck"]
const START_NEAR := 25.0
## The golf thieves (persecucion-lugares.md): the drive out to the club is long, so the chase and its clock start once a
## cop goes through the gate. Stopped, one gives up and the other runs off; both go back, the runner in the trunk.
const TRUNK_SEAT := Vector3(0, 0.1, -1.3)
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
## Got away in the middle of another case, his vehicle keeps going this long (s) before it's gone.
const GONE_AFTER := 4.0
## Its meters go under the other case's own at the top of the screen (px).
const EMBEDDED_METERS_TOP := 112.0

signal meters_changed(distance: float, time_left: float)
signal complaint_changed(complaint: float)
## A chase in the middle of another case is over: caught (cuffed and in the patrol car) or got away.
signal ended(caught: bool)

var case_seed := 0
## A chase in the middle of another case (persecucion-final.md, decision 96): it starts at once, with no comisario,
## no weather and no shift of its own, and when it's over the case it ends goes on (ended). begin() sets it up.
var embedded := false
var meters: ChaseMeters
## Who gets off when he gives up (ChaseSuspect.MODELS), when it isn't the suspect's own: a raid's owner.
var who := ""
var suspect_id := "ice_cream"
var car: PatrolCar
var truck: SuspectCar
## The good patrol car the tow truck takes away, hanging behind it until a cop unhooks it; the cops drive it back.
var towed: PatrolCar
var unhooked := false
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
## The golf thief who runs off, and his walk to the patrol car.
var runner: ChaseSuspect
var runner_escort: OwnerEscort

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
## Online (docs/diseno/online.md): the host's chase decides and a guest's follows it (CaseSync); `online` is that sync.
var follower := false
var online: CaseSync
## Why it was lost (a tr() key), shown on every PC.
var failed_reason := ""
var _result := {}
var _told_on_foot := false


## The chase of the level `node` is in (online tests hold one level per PC in the same tree), if any.
static func of(node: Node) -> ChaseCase:
	for case: ChaseCase in node.get_tree().get_nodes_in_group("chase"):
		if case.get_parent().is_ancestor_of(node):
			return case
	return null


static func pick_suspect(seed_value: int, args: PackedStringArray) -> String:
	for arg in args:
		if arg.begins_with("--suspect=") and SUSPECTS.has(arg.trim_prefix("--suspect=")):
			return arg.trim_prefix("--suspect=")
	return SUSPECTS[hash("chase suspect %d" % seed_value) % SUSPECTS.size()]


## Starts a chase in the middle of another case: `kind` (SuspectCar.MODELS) drives off from `at` and on through the
## city's streets in `patrol_car`'s level, with the clock and the distance meter at the top while it lasts. The copilot's
## `map`, if the level has one, shows him to whoever reads it. A vehicle already parked there (`parked`) is the one he
## takes.
static func begin(parent: Node, kind: String, at: Transform3D, patrol_car: PatrolCar, city: Node3D, seed_value: int,
		map: CityMap = null, parked: SuspectCar = null) -> ChaseCase:
	var fleeing := parked
	if not fleeing:
		fleeing = SuspectCar.new()
		fleeing.name = "FleeingCar"
		fleeing.kind = kind
		parent.add_child(fleeing, true)
	var to_city := city.global_transform
	var start_corner := ChaseRoute.nearest_corner(to_city.affine_inverse() * at.origin)
	var drawn := ChaseRoute.draw(seed_value, ChaseRoute.CORNERS, start_corner)
	fleeing.drive_from(at, drawn, to_city)
	var case := ChaseCase.new()
	case.name = "Chase"
	case.embedded = true
	case.route = drawn
	case.city_transform = to_city
	case.case_seed = seed_value
	case.suspect_id = kind
	case.car = patrol_car
	case.truck = fleeing
	case.station_parking = to_city * CityLayout.parking("station")
	parent.add_child(case, true)
	case.start()
	case.meters = ChaseMeters.new()
	case.meters.case = case
	case.meters.top = EMBEDDED_METERS_TOP
	case.add_child(case.meters)
	if map:
		map.suspect = fleeing
		map.shows_suspect = func() -> bool: return is_instance_valid(case) and case.chasing and case.tasks.shows_suspect()
	return case


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
	for barrier: TollBarrier in _barriers():
		barrier.broken.connect(_on_barrier_broken.bind(barrier))
	if embedded:
		tip_given = true
		chasing = true
		truck.driving = true
		_hint_all("HINT_CHASE_FLEES")
		return
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		car.locked_hint = "HINT_COMISARIO_FIRST"
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if not shift_screen:
		return
	shift_screen.play_again.connect(_play_again)
	shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func _play_again() -> void:
	if online:
		online.play_again()
	else:
		PlaceDraw.start(get_tree())


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	car.locked_hint = ""
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			# The golf thieves aren't driving past the door: the comisario goes straight to them.
			var lines := PackedStringArray(["BRIEF_CHASE_A", "BRIEF_CHASE_" + suspect_id, "BRIEF_CHASE_C"])
			if suspect_id == SuspectCar.GOLF:
				lines.remove_at(0)
			briefing.start(lines)
			break
	_hint_all("HINT_GO_CHASE")


func _physics_process(delta: float) -> void:
	if towed and not unhooked and not follower:
		towed.global_transform = truck.towed_transform()
	if follower:
		_escort_copies()
		return
	if case_failed or case_solved or not tip_given:
		return
	if not chasing:
		# The suspect drives off once a cop takes the wheel (or, on foot, walks up to him; at the golf club, goes in).
		var go := car.driver() != null or (CLOSE_BY.has(suspect_id) and _nearest_cop() < START_NEAR)
		if suspect_id == SuspectCar.GOLF:
			go = _cop_in_club()
		if go:
			chasing = true
			truck.driving = true
			if suspect_id == SuspectCar.GOLF:
				_hint_all("HINT_GOLF_CLOCK")
		return
	if not caught:
		time_left = maxf(time_left - delta, 0.0)
	if not stopped:
		var gap := _nearest_cop() if CLOSE_BY.has(suspect_id) else _flat(car.global_position - truck.global_position).length()
		distance = clampf(distance + (CLIMB if gap > far() else -DROP) * delta, 0.0, ESCAPED)
		if truck.stuck_for >= STOP_SECONDS:
			if not on_foot() or _cop_on_foot_near():
				pull_over()
			elif not _told_on_foot:
				_told_on_foot = true
				_hint_all("HINT_CHASE_ON_FOOT")
	meters_changed.emit(distance, time_left)
	if not caught and suspect and suspect.was_cuffed and (not runner or runner.was_cuffed):
		caught = true
		_hint_all("HINT_CHASE_CAUGHT_HERE" if embedded else "HINT_CHASE_CAUGHT")
	if embedded and caught and escort.in_car and (not runner_escort or runner_escort.in_car):
		_end(true)
	elif distance >= ESCAPED:
		fail("CASE_FAILED_ESCAPED")
	elif time_left <= 0.0 and not caught:
		fail("CASE_FAILED_TIME")
	elif caught and (unhooked or not towed) and escort.in_car and (not runner_escort or runner_escort.in_car) \
			and all_in_car() and car_at_station():
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


## Whether a cop (on foot or in the car) is inside the golf club.
func _cop_in_club() -> bool:
	var golf := get_tree().get_first_node_in_group("golf_club") as GolfClub
	for cop in get_tree().get_nodes_in_group("cops"):
		if golf and golf.inside((cop as Node3D).global_position):
			return true
	return false


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
	if suspect_id != "school_bus" or case_failed or case_solved or follower:
		return
	complaint = minf(complaint + RAM_COMPLAINT, COMPLAINT_FULL)
	complaint_changed.emit(complaint)
	_hint_all("HINT_CHASE_KIDS")
	if complaint >= COMPLAINT_FULL:
		fail("CASE_FAILED_PARENTS")


## A guest: the host's suspect (and the golf runner) got out, copied by NpcSync; here they get an escort that only
## rides along, so they sit in the back of the patrol car like on the host.
func _escort_copies() -> void:
	if not stopped:
		return
	if not suspect:
		suspect = get_parent().get_node_or_null("Suspect") as ChaseSuspect
		if suspect:
			escort = _follower_escort(suspect, "HINT_CHASE_BACK_TO_CASE" if embedded else "HINT_CHASE_IN_CAR")
	if suspect_id == SuspectCar.GOLF and not runner:
		runner = get_parent().get_node_or_null("Runner") as ChaseSuspect
		if runner:
			runner_escort = _follower_escort(runner, "HINT_CHASE_IN_CAR")
			runner_escort.seat_shift = TRUNK_SEAT


func _follower_escort(who_got_out: ChaseSuspect, hint: String) -> OwnerEscort:
	var made := OwnerEscort.attach(who_got_out, home_car())
	made.follower = true
	made.in_car_hint = hint
	return made


## He gives up: the vehicle stays where it is and he gets out by his door, ready to be cuffed.
func pull_over() -> void:
	if stopped or follower:
		return
	stopped = true
	truck.driving = false
	truck.get_off()
	suspect = ChaseSuspect.new()
	suspect.name = "Suspect"
	suspect.kind = who if who != "" else suspect_id
	get_parent().add_child(suspect)
	suspect.global_position = truck.global_position + truck.global_basis.x * DOOR_OUT + Vector3.UP * 0.1
	suspect.rotation.y = truck.rotation.y
	escort = OwnerEscort.attach(suspect, home_car())
	escort.in_car_hint = "HINT_CHASE_BACK_TO_CASE" if embedded else "HINT_CHASE_IN_CAR"
	_hint_all("HINT_CHASE_STOPPED")
	if suspect_id == SuspectCar.GOLF:
		runner = ChaseSuspect.new()
		runner.name = "Runner"
		runner.kind = "golf_runner"
		runner.runs = true
		get_parent().add_child(runner)
		runner.global_position = truck.global_position - truck.global_basis.x * DOOR_OUT + Vector3.UP * 0.1
		runner_escort = OwnerEscort.attach(runner, home_car())
		runner_escort.in_car_hint = "HINT_CHASE_IN_CAR"
		runner_escort.seat_shift = TRUNK_SEAT
		_hint_all("HINT_GOLF_RUNNER")


## The car the cops bring him back in: the good patrol car, also when the tow truck took it.
func home_car() -> PatrolCar:
	return towed if towed else car


## The tow truck takes the patrol car: it hangs behind him, locked, and the tow truck doesn't bump into it.
func tow(patrol_car: PatrolCar) -> void:
	towed = patrol_car
	towed.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	towed.freeze = true
	towed.locked_hint = "HINT_CHASE_TOWED"
	truck.add_collision_exception_with(towed)
	towed.global_transform = truck.towed_transform()


## E on the hook: once he gave up, the patrol car comes down and can be driven again.
func unhook(cop: Cop) -> void:
	if not towed or unhooked:
		return
	if not stopped:
		cop.show_hint("HINT_CHASE_HOOK_MOVING")
		return
	unhooked = true
	if follower:
		# The host lowers it; here it follows the host's (PropSync).
		return
	var flat := Basis(Vector3.UP, truck.rotation.y)
	towed.global_transform = Transform3D(flat, truck.towed_transform().origin + Vector3.UP * 0.2)
	towed.freeze = false
	towed.locked_hint = ""
	_hint_all("HINT_CHASE_UNHOOKED")


func all_in_car() -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).vehicle != home_car():
			return false
	return true


func car_at_station() -> bool:
	return home_car().global_position.distance_to(station_parking.origin) < STATION_RADIUS


func fail(reason: String) -> void:
	if case_failed or case_solved or follower:
		return
	if embedded:
		_end(false)
		return
	case_failed = true
	failed_reason = reason
	truck.driving = false
	failed_label.text = reason
	failed_label.show()
	_finish_soon()


## The chase in the middle of another case is over: the meters go, and if he got away so does his vehicle.
func _end(was_caught: bool) -> void:
	chasing = false
	case_solved = was_caught
	case_failed = not was_caught
	if meters:
		meters.queue_free()
	if not was_caught:
		_hint_all("HINT_CHASE_GOT_AWAY")
		get_tree().create_timer(GONE_AFTER).timeout.connect(truck.queue_free)
	ended.emit(was_caught)


func _finish_soon() -> void:
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The end of shift screen: caught and brought in pays the salary, got away nothing.
func finish_shift() -> void:
	if shift_over or follower:
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
	# Online only the host starts the next case.
	shift_screen.get_node("%AgainButton").visible = not over and not follower


## Online (CaseSync.tell): what the host's tasks just did, shown on a guest.
func shown_shout() -> void:
	tasks.shown_shout()


func shown_trap(kind: String, at: Transform3D) -> void:
	tasks.shown_trap(kind, at)


func shown_puddle(color: int, at: Vector3) -> void:
	drops.puddle_at(color, at)


## The toll barrier that `index` names among the level's (in tree order, the same on every PC) broke on the host.
func shown_barrier_broken(index: int) -> void:
	var barriers := _barriers()
	if index < barriers.size() and not (barriers[index] as TollBarrier).is_broken:
		(barriers[index] as TollBarrier).knock_down()


func _barriers() -> Array[Node]:
	return get_parent().find_children("*", "TollBarrier", true, false)


## Host: a barrier broke; the guests see it broken too.
func _on_barrier_broken(_by: Node3D, barrier: TollBarrier) -> void:
	if online and not follower:
		online.tell("shown_barrier_broken", [_barriers().find(barrier)])


## What every guest's chase shows (CaseSync, 5 times a second when it changes).
func snapshot() -> Dictionary:
	return {"tip": tip_given, "chasing": chasing, "distance": snappedf(distance, 0.1),
		"time_left": snappedf(time_left, 0.1), "stopped": stopped, "caught": caught, "solved": case_solved,
		"failed": failed_reason, "complaint": complaint, "unhooked": unhooked, "result": _result}


## A guest's chase takes the host's.
func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	chasing = state.chasing
	distance = state.distance
	time_left = state.time_left
	stopped = state.stopped
	caught = state.caught
	unhooked = state.unhooked
	meters_changed.emit(distance, time_left)
	if not is_equal_approx(complaint, state.complaint):
		complaint = state.complaint
		complaint_changed.emit(complaint)
	if state.solved and not case_solved:
		case_solved = true
		if solved_label:
			solved_label.show()
	if state.failed != "" and not case_failed:
		case_failed = true
		failed_reason = state.failed
		if failed_label:
			failed_label.text = failed_reason
			failed_label.show()
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
