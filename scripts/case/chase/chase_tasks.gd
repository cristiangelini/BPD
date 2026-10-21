class_name ChaseTasks
extends Node

## Each patrol car seat's job in a chase (persecucion.md, "Las cuatro tareas", decision 24): the driver drives, the
## copilot sees the suspect on the map (M) and calls it out, and the back right seat has the siren (H) and the
## megaphone (click: "¡Deténgase!"), which makes the suspect nervous and sometimes take a wrong turn, and the back left
## seat throws things out of the window: click drops a spike strip behind the car, right click throws the net ahead
## (ChaseTrap), SPIKES and NETS of them; against the delivery scooter, click puts a row of cones across the street
## ahead instead of the spikes, CONES of them. A seat nobody sat in hands its job to the copilot, and then to the driver, so
## playing alone the driver does it all; a cop with two click jobs picks one with 1 and 2. Every number here is
## (propuesta).

## Who does each job: the first of these seats with a cop in it.
const MAP_SEATS: Array[int] = [1, 0]
const MEGAPHONE_SEATS: Array[int] = [3, 1, 0]
const SPIKE_SEATS: Array[int] = [2, 1, 0]
## What each passenger seat is told on sitting down.
const SEAT_HINTS := {1: "HINT_CHASE_MAP", 2: "HINT_CHASE_WINDOW", 3: "HINT_CHASE_MEGAPHONE"}
const CONES_HINT := "HINT_CHASE_WINDOW_CONES"
const EMPTY_TRUNK_HINT := "HINT_CHASE_WINDOW_EMPTY"
## How many of each there are, and where they land from the patrol car (m behind, m ahead).
const SPIKES := 3
const NETS := 3
const CONES := 4
const SPIKES_BEHIND := 4.5
const NET_AHEAD := 12.0
## Seconds between two shouts, how long he stays nervous and the chance he turns the wrong way.
const MEGAPHONE_COOLDOWN := 4.0
const NERVOUS_SECONDS := 2.5
const WRONG_TURN := 0.5
const SHOUT_SECONDS := 1.5
## Each job a cop asks for online, and the seats that do it.
const JOBS := {"shout": MEGAPHONE_SEATS, "throw_spikes": SPIKE_SEATS, "throw_net": SPIKE_SEATS,
	"throw_cones": SPIKE_SEATS, "call_backup": MAP_SEATS}

var case: ChaseCase
var shouts := 0
var spikes_left := SPIKES
var nets_left := NETS
var cones_left := CONES
## With both click jobs (the megaphone and the window), the one picked with 1 and 2.
var window_picked := false
var _cooldown := 0.0
var _rng := RandomNumberGenerator.new()
var _shout_label: Label3D


func _ready() -> void:
	_rng.seed = hash("megaphone %d" % case.case_seed)
	# The old patrol car's trunk is empty: the spikes and the net stayed in the good one (persecucion-lugares.md).
	if case.car.old:
		spikes_left = 0
		nets_left = 0
		cones_left = 0
	case.car.seats_changed.connect(_tell_jobs)


## Whoever just sat in a passenger seat hears what that seat does.
func _tell_jobs() -> void:
	for seat: int in SEAT_HINTS:
		var cop := case.car.seated[seat]
		if cop and cop.input_enabled:
			cop.show_hint(_window_hint() if seat == 2 else SEAT_HINTS[seat])


## The seat whose cop does the job that `seats` lists, or -1 with the car empty.
func seat_for(seats: Array[int]) -> int:
	for seat in seats:
		if case.car.seated[seat] != null:
			return seat
	return -1


## Whether `cop` is the one doing that job.
func does(cop: Cop, seats: Array[int]) -> bool:
	return cop != null and case.car.seat_of(cop) >= 0 and case.car.seat_of(cop) == seat_for(seats)


## This PC's cop (the one with a player at the keys), if any.
func local_cop() -> Cop:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			return cop
	return null


## The map shows the suspect only to whoever reads it (CityMap.shows_suspect).
func shows_suspect() -> bool:
	return does(local_cop(), MAP_SEATS)


func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	var cop := local_cop()
	if not cop or not case.chasing:
		return
	var shouts_here := does(cop, MEGAPHONE_SEATS)
	var throws_here := does(cop, SPIKE_SEATS)
	if shouts_here and throws_here:
		if Input.is_action_just_pressed("slot_1"):
			window_picked = false
			cop.show_hint("HINT_CHASE_MEGAPHONE")
		elif Input.is_action_just_pressed("slot_2"):
			window_picked = true
			cop.show_hint(_window_hint())
	var at_window := throws_here and (window_picked or not shouts_here)
	if at_window and Input.is_action_just_pressed("grab"):
		do_job("throw_cones" if uses_cones() else "throw_spikes")
	elif at_window and Input.is_action_just_pressed("throw"):
		do_job("throw_net")
	elif shouts_here and not at_window and Input.is_action_just_pressed("grab"):
		do_job("shout")
	# From the back, the siren too (the driver keeps his own H).
	if case.car.seat_of(cop) == 3 and Input.is_action_just_pressed("siren"):
		cop.act("toggle_siren", case.car)


## Does a job (one of JOBS) of this PC's cop: online a guest asks the host, whose chase decides (CaseSync).
func do_job(job: String) -> void:
	if case.online and case.follower:
		case.online.request_job(job)
	elif job == "call_backup":
		case.highway.call_backup()
	else:
		call(job)


## Host: `cop` (a guest's) asked for `job`; it's done only if that cop is the one doing it.
func job_by(cop: Cop, job: String) -> void:
	if JOBS.has(job) and does(cop, JOBS[job]) and case.chasing:
		if job == "call_backup":
			if case.highway:
				case.highway.call_backup()
		else:
			call(job)


## "¡Deténgase!" through the megaphone: he gets nervous and slows down, and sometimes turns the wrong way at the next
## corner. Returns whether he took the wrong turn.
func shout() -> bool:
	if _cooldown > 0.0 or case.stopped or not case.chasing:
		return false
	_cooldown = MEGAPHONE_COOLDOWN
	shouts += 1
	_show_shout()
	_tell_guests("shown_shout")
	case.truck.scare(NERVOUS_SECONDS)
	if _rng.randf() >= WRONG_TURN:
		return false
	return wrong_turn()


## Drops a spike strip on the street behind the patrol car. Returns it, or null with none left.
func throw_spikes() -> ChaseTrap:
	if spikes_left <= 0 or case.stopped:
		return null
	spikes_left -= 1
	return _drop(ChaseTrap.SPIKES, -SPIKES_BEHIND)


## Against the delivery scooter the window has cones instead of spikes.
func uses_cones() -> bool:
	return case.suspect_id == "moto"


func _window_hint() -> String:
	if case.car.old:
		return EMPTY_TRUNK_HINT
	return CONES_HINT if uses_cones() else SEAT_HINTS[2]


## Puts a row of cones across the street ahead of the patrol car, from one building front to the other, so he can't
## get past on the sidewalk either. Returns it, or null with none left.
func throw_cones() -> ChaseTrap:
	if cones_left <= 0 or case.stopped:
		return null
	cones_left -= 1
	var trap := ChaseTrap.new()
	trap.kind = ChaseTrap.CONES
	case.get_parent().add_child(trap)
	var car := case.car
	var city := case.city_transform
	var at := city.affine_inverse() * (car.global_position + car.global_basis.z * NET_AHEAD)
	var heading := city.basis.inverse() * car.global_basis.z
	# Across the street the car is on: lined up with its middle, square to it.
	var crossing := ChaseRoute.corner_point(ChaseRoute.nearest_corner(at))
	var along_x := absf(heading.x) > absf(heading.z)
	if along_x:
		at.z = crossing.z
	else:
		at.x = crossing.x
	at.y = 0.0
	trap.global_transform = city * Transform3D(Basis(Vector3.UP, PI / 2 if along_x else 0.0), at)
	_tell_guests("shown_trap", [trap.kind, trap.global_transform])
	return trap


## Throws the net onto the street ahead of the patrol car. Returns it, or null with none left.
func throw_net() -> ChaseTrap:
	if nets_left <= 0 or case.stopped:
		return null
	nets_left -= 1
	return _drop(ChaseTrap.NET, NET_AHEAD)


func _drop(kind: String, along: float) -> ChaseTrap:
	var trap := ChaseTrap.new()
	trap.kind = kind
	case.get_parent().add_child(trap)
	var car := case.car
	var at := car.global_position + car.global_basis.z * along
	at.y = 0.0
	trap.global_transform = Transform3D(Basis(Vector3.UP, car.global_basis.get_euler().y), at)
	_tell_guests("shown_trap", [kind, trap.global_transform])
	return trap


## Online, the host shows the guests what it just did (CaseSync.tell).
func _tell_guests(method: String, args := []) -> void:
	if case.online and not case.follower:
		case.online.tell(method, args)


## Guest: the host's megaphone shouted.
func shown_shout() -> void:
	shouts += 1
	_show_shout()


## Guest: the host threw a trap; this one only shows (the host's catches him).
func shown_trap(kind: String, at: Transform3D) -> void:
	var trap := ChaseTrap.new()
	trap.kind = kind
	trap.shown_only = true
	case.get_parent().add_child(trap)
	trap.global_transform = at


## From the corner he's heading for, he drives off a new way, never the one he had planned.
func wrong_turn() -> bool:
	# The sports car knows where he's going (the highway), and the golf cart has no streets to turn into.
	if case.suspect_id in [SuspectCar.HIGHWAY, SuspectCar.GOLF]:
		return false
	var route := case.route
	var k := case.truck.next
	if k < 1 or k + 1 >= route.corners.size():
		return false
	var at := route.corners[k]
	var planned := route.corners[k + 1]
	for attempt in 8:
		var fresh := ChaseRoute.draw(case.case_seed + shouts * 31 + attempt, ChaseRoute.CORNERS, at, at - route.corners[k - 1])
		if fresh.corners[1] != planned:
			route.corners.assign(route.corners.slice(0, k) + fresh.corners)
			case.truck.retake(route, case.city_transform)
			return true
	return false


func _show_shout() -> void:
	if not _shout_label:
		_shout_label = Label3D.new()
		_shout_label.text = "CHASE_MEGAPHONE"
		_shout_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_shout_label.pixel_size = 0.006
		_shout_label.outline_size = 12
		_shout_label.font_size = 48
		_shout_label.modulate = Color(1, 0.9, 0.3)
		_shout_label.position.y = 2.6
		case.car.add_child(_shout_label)
	_shout_label.show()
	var shown := shouts
	get_tree().create_timer(SHOUT_SECONDS).timeout.connect(func() -> void:
		if shouts == shown and is_instance_valid(_shout_label):
			_shout_label.hide())
