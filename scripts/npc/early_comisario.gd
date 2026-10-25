class_name EarlyComisario
extends NightGuard

## The comisario who came in early (docs/diseno/fuga-limpieza.md, "Disfrazados de limpieza", step 1): in the cleaning
## crew's jailbreak there's no night guard, but he has an inspection today. He walks his ROUND (his office, the coffee
## maker in the guard room and the door of the cells room), stopping STOP_MIN to STOP_MAX seconds at each stop, drawn by
## the seed, and watches like the night guard (NightGuard.sees and its suspicion), so the level catches the cops the
## same way. Walking, he looks ahead; stopped, his head sweeps around. He doesn't eat donuts and singing doesn't put
## him to sleep. What he sees in a cop out of the cells (step 3, offence): without the cleaning disguise, a cop; in it,
## someone of the crew, who only worries him idle (not working with a mop or duster) or running. A stain mopped clean
## in front of him calms him down (step 4, saw_cleaning). Someone of the crew passing close by makes him stop and
## squint for SQUINT seconds ("¿Te conozco?"): working through most of it, he lets it go; if not, KNOWN suspicion at
## once. Every number here is (propuesta).

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
## Suspicion per second from someone of the cleaning crew he sees idle, and running.
const SUSPICION_IDLE := 15.0
const SUSPICION_RUNNING := 25.0
const RUN_SPEED := (GameScale.WALK_SPEED + GameScale.RUN_SPEED) / 2
## A stain mopped clean where he sees it takes this much suspicion off.
const SHINE := 20.0
## "¿Te conozco?": how close, for how long, how much of it working lets him go, what not working costs, and how long
## until he squints at the same cop again.
const SQUINT_REACH := 2.5
const SQUINT := 3.0
const SQUINT_PASS := 2.0
const KNOWN := 40.0
const SQUINT_AGAIN := 15.0
const SQUINT_LINES := 3

## The station's lot, where ROUND is.
var station := Transform3D.IDENTITY
## The point of ROUND he's going to (or stopped at).
var target := 0
## Seconds he still stays at his stop (0 while he walks).
var wait_left := 0.0
## Each cop -> [where it was last tick, how fast it went]: a guest's cop on the host has no velocity of its own.
var _speeds := {}
## The cop he squints at, for how long still, and how long it worked meanwhile; cop -> seconds until he squints at it
## again.
var squinting: Cop
var squint_left := 0.0
var _squint_worked := 0.0
var _squinted := {}


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
	_track_speeds(delta)
	_squint(delta)
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
	if squinting:
		return
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


## How much suspicion he gains per second from the cops he sees out of the cells (no box or donuts here).
func alarm() -> float:
	var rate := 0.0
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if outside_cells.call(cop.global_position) and sees(cop.global_position + Vector3.UP, cop):
			rate += offence(cop)
	return rate


## What `cop`, seen out of the cells, adds per second.
func offence(cop: Cop) -> float:
	if not cop.is_disguised("cleaner"):
		return SUSPICION_COP
	var rate := 0.0
	if not is_cleaning(cop):
		rate += SUSPICION_IDLE
	if speed_of(cop) > RUN_SPEED:
		rate += SUSPICION_RUNNING
	return rate


func _track_speeds(delta: float) -> void:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var at := cop.global_position
		var last: Array = _speeds.get(cop, [at, 0.0])
		_speeds[cop] = [at, Vector2(at.x - last[0].x, at.z - last[0].z).length() / delta]


## How fast `cop` goes on the ground (m/s).
func speed_of(cop: Node3D) -> float:
	return _speeds[cop][1] if _speeds.has(cop) else 0.0


## Whether he takes `cop` for someone cleaning: working with a mop or a feather duster.
func is_cleaning(cop: Cop) -> bool:
	var tool := CleaningTool.held_by(cop)
	return tool != null and tool.is_working()


## A stain was mopped clean at `at` (FloorStains): if he sees it, he likes it.
func saw_cleaning(at: Vector3) -> void:
	if sees(at + Vector3.UP * 0.05):
		suspicion = maxf(suspicion - SHINE, 0.0)
		say("EARLY_SHINE_%d" % _rng.randi_range(0, STOP_LINES - 1))


## "¿Te conozco?": someone of the crew close in front of him makes him stop and look; the cop must keep working.
func _squint(delta: float) -> void:
	for cop: Variant in _squinted.keys():
		_squinted[cop] -= delta
		if _squinted[cop] <= 0.0 or not is_instance_valid(cop):
			_squinted.erase(cop)
	if squinting:
		if not is_instance_valid(squinting):
			squinting = null
			return
		squint_left -= delta
		if is_cleaning(squinting):
			_squint_worked += delta
		if squint_left <= 0.0:
			_end_squint()
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if _squinted.has(cop) or not cop.is_disguised("cleaner") or not outside_cells.call(cop.global_position):
			continue
		if _flat(cop.global_position).length() <= SQUINT_REACH and sees(cop.global_position + Vector3.UP, cop):
			squinting = cop
			squint_left = SQUINT
			_squint_worked = 0.0
			say("EARLY_SQUINT_%d" % _rng.randi_range(0, SQUINT_LINES - 1), SQUINT)
			return


func _end_squint() -> void:
	_squinted[squinting] = SQUINT_AGAIN
	if _squint_worked >= SQUINT_PASS:
		say("EARLY_SQUINT_OK_%d" % _rng.randi_range(0, SQUINT_LINES - 1))
	else:
		suspicion = minf(suspicion + KNOWN, 100.0)
		say("EARLY_SQUINT_HMM")
	squinting = null


## Singing doesn't put him to sleep.
func heard_singing(_cop: Node3D) -> void:
	pass


func catch() -> void:
	suspicion = 0.0
	times_caught += 1
	say("EARLY_CAUGHT_%d" % _rng.randi_range(0, EARLY_CAUGHT_LINES - 1), 5.0)
	caught.emit(times_caught)
