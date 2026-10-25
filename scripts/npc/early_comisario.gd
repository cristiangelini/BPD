class_name EarlyComisario
extends NightGuard

## The comisario who came in early (docs/diseno/fuga-limpieza.md, "Disfrazados de limpieza", step 1): in the cleaning
## crew's jailbreak there's no night guard, but he has an inspection today. He walks his ROUND (his office, the coffee
## maker in the guard room and the door of the cells room), stopping STOP_MIN to STOP_MAX seconds at each stop, drawn by
## the seed, and watches like the night guard (NightGuard.sees and its suspicion), so the level catches the cops the
## same way. Walking, he looks ahead; stopped, his head sweeps around. He doesn't eat donuts and singing doesn't put
## him to sleep. Every number here is (propuesta).

## His round in the station's own space (StationRooms): [where, which way he faces there (radians, 0 = +Z), what he
## says when he stops there ("" = he walks on)].
const ROUND := [
	[Vector3(0, 0, -6.1), 0.0, "EARLY_OFFICE"],
	[Vector3(0, 0, 0.0), 0.0, ""],
	[Vector3(0, 0, 2.2), 0.0, ""],
	[Vector3(4.5, 0, 2.4), PI, "EARLY_COFFEE"],
	[Vector3(5.0, 0, 6.4), PI / 2, "EARLY_CELLS"],
	[Vector3(0, 0, 2.2), 0.0, ""],
	[Vector3(0, 0, 0.0), 0.0, ""],
]
const STOP_MIN := 4.0
const STOP_MAX := 8.0
const WALK_SPEED := 1.3
## Lines for each stop and for catching them.
const STOP_LINES := 3
const EARLY_CAUGHT_LINES := 3

## The station's lot, where ROUND is.
var station := Transform3D.IDENTITY
## The point of ROUND he's going to (or stopped at).
var target := 0
## Seconds he still stays at his stop (0 while he walks).
var wait_left := 0.0


## Starts his round at a stop drawn by the seed.
func setup_round(case_seed: int, station_lot: Transform3D) -> void:
	station = station_lot
	_rng.seed = hash(["early comisario", case_seed])
	var stops: Array[int] = []
	for i in ROUND.size():
		if ROUND[i][2] != "":
			stops.append(i)
	target = stops[_rng.randi_range(0, stops.size() - 1)]
	global_transform = Transform3D(station.basis * Basis(Vector3.UP, ROUND[target][1]), station * ROUND[target][0])
	wait_left = _rng.randf_range(STOP_MIN, STOP_MAX)


func _model_scene() -> PackedScene:
	return Comisario.MODEL


func _physics_process(delta: float) -> void:
	_tick_bubble(delta)
	_walk(delta)
	_listen(delta)
	if is_walking() and distracted_left <= 0.0:
		look = rotate_toward(look, 0.0, TURN_SPEED * delta)
		_model.rotation.y = look
	else:
		_turn_head(delta)
	_watch(delta)


func is_walking() -> bool:
	return wait_left <= 0.0


## Where he's going now, in the world.
func goal() -> Vector3:
	return station * (ROUND[target][0] as Vector3)


func _walk(delta: float) -> void:
	if wait_left > 0.0:
		wait_left -= delta
		if wait_left <= 0.0:
			target = (target + 1) % ROUND.size()
		return
	var to := goal() - global_position
	to.y = 0.0
	var step := WALK_SPEED * delta
	if to.length() > step:
		global_position += to.normalized() * step
		global_rotation.y = atan2(to.x, to.z)
		return
	global_position = Vector3(goal().x, global_position.y, goal().z)
	var line: String = ROUND[target][2]
	if line == "":
		target = (target + 1) % ROUND.size()
		return
	global_basis = station.basis * Basis(Vector3.UP, ROUND[target][1])
	wait_left = _rng.randf_range(STOP_MIN, STOP_MAX)
	say("%s_%d" % [line, _rng.randi_range(0, STOP_LINES - 1)])


## Singing doesn't put him to sleep.
func heard_singing(_cop: Node3D) -> void:
	pass


func catch() -> void:
	suspicion = 0.0
	times_caught += 1
	say("EARLY_CAUGHT_%d" % _rng.randi_range(0, EARLY_CAUGHT_LINES - 1), 5.0)
	caught.emit(times_caught)
