class_name ChaseTasks
extends Node

## Each patrol car seat's job in a chase (persecucion.md, "Las cuatro tareas", decision 24): the driver drives, the
## copilot sees the suspect on the map (M) and calls it out, and the back right seat has the siren (H) and the
## megaphone (click: "¡Deténgase!"), which makes the suspect nervous and sometimes take a wrong turn. A seat nobody
## sat in hands its job to the copilot, and then to the driver, so playing alone the driver does it all. The back left
## seat's spikes and net come next. Every number here is (propuesta).

## Who does each job: the first of these seats with a cop in it.
const MAP_SEATS: Array[int] = [1, 0]
const MEGAPHONE_SEATS: Array[int] = [3, 1, 0]
## Seconds between two shouts, how long he stays nervous and the chance he turns the wrong way.
const MEGAPHONE_COOLDOWN := 4.0
const NERVOUS_SECONDS := 2.5
const WRONG_TURN := 0.5
const SHOUT_SECONDS := 1.5

var case: ChaseCase
var shouts := 0
var _cooldown := 0.0
var _rng := RandomNumberGenerator.new()
var _shout_label: Label3D


func _ready() -> void:
	_rng.seed = hash("megaphone %d" % case.case_seed)


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
	if does(cop, MEGAPHONE_SEATS) and Input.is_action_just_pressed("grab"):
		shout()
	# From the back, the siren too (the driver keeps his own H).
	if case.car.seat_of(cop) == 3 and Input.is_action_just_pressed("siren"):
		cop.act("toggle_siren", case.car)


## "¡Deténgase!" through the megaphone: he gets nervous and slows down, and sometimes turns the wrong way at the next
## corner. Returns whether he took the wrong turn.
func shout() -> bool:
	if _cooldown > 0.0 or case.stopped or not case.chasing:
		return false
	_cooldown = MEGAPHONE_COOLDOWN
	shouts += 1
	_show_shout()
	case.truck.scare(NERVOUS_SECONDS)
	if _rng.randf() >= WRONG_TURN:
		return false
	return wrong_turn()


## From the corner he's heading for, he drives off a new way, never the one he had planned.
func wrong_turn() -> bool:
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
