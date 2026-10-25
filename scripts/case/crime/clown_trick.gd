class_name ClownTrick
extends Node

## "¡El truco!" (escena-circo.md, "Se mezclan"): every TRICK_EVERY seconds of the case the ringmaster calls it, the
## clowns in the ring run around in a circle and each ends up in another clown's spot, drawn with the seed. Without a
## sign or their makeup off, there's no telling who's who anymore; and in the run, a sign may come off its clown and
## fall to the sawdust (Circus.drop_sign). Every number here is (propuesta).

signal started
signal finished(round_number: int)

## Seconds between tricks, counted while the case is on, and the warning before one.
const TRICK_EVERY := 90.0
const WARNING := 3.0
## Seconds they run around, and how many laps.
const RUN := 3.0
const LAPS := 1
## One in this many signs falls off in a trick.
const SIGN_FALLS := 3

var circus: Circus
var case: CrimeSceneCase
## Which spot of the circle each clown is in (clown index -> spot), and how many tricks they did.
var spots: Array[int] = []
var rounds := 0
## A guest's trick follows the host's (step 8).
var follower := false
var _until := TRICK_EVERY
var _warned := false
var _running := 0.0
var _from: Array[int] = []


func _ready() -> void:
	spots.assign(range(circus.clowns.size()))


## Whether the clowns are running around right now.
func running() -> bool:
	return _running > 0.0


func _physics_process(delta: float) -> void:
	if not case or not case.tip_given or case.accused or case.lost:
		return
	if _running > 0.0:
		_running = maxf(_running - delta, 0.0)
		_place(1.0 - _running / RUN)
		if _running == 0.0:
			finished.emit(rounds)
		return
	# Online only the host's clowns decide when; a guest's follow (Circus.apply_net_state).
	if follower or case.follower:
		return
	_until -= delta
	if not _warned and _until <= WARNING:
		_warned = true
		circus.ringmaster.say("RINGMASTER_TRICK", WARNING + RUN)
	if _until <= 0.0:
		perform()


## The trick, now: new spots for the clowns still here, drawn with the seed and the round, and some signs fall.
func perform() -> void:
	rounds += 1
	_until = TRICK_EVERY
	_warned = false
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["clown trick", circus.case_seed, rounds])
	var here := _here()
	var open_spots := here.map(func(i: int) -> int: return spots[i])
	# Shuffled until nobody stays put (with two or more).
	for attempt in 20:
		for i in range(open_spots.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var swap: int = open_spots[i]
			open_spots[i] = open_spots[j]
			open_spots[j] = swap
		var moved := true
		for k in here.size():
			moved = moved and (open_spots[k] != spots[here[k]] or here.size() < 2)
		if moved:
			break
	_from.assign(spots)
	for k in here.size():
		spots[here[k]] = open_spots[k]
	for index in here:
		var clown := circus.clowns[index]
		clown.joke()
		if circus.sign_of(index) >= 0 and rng.randi_range(1, SIGN_FALLS) == 1:
			circus.drop_sign(clown)
	_running = RUN
	started.emit()


## The clowns still in the ring (not gone home).
## Online, on a guest: the host's clowns did the trick (round `round_number`) and ended up at `new_spots`.
func follow(round_number: int, new_spots: Array) -> void:
	if round_number <= rounds:
		return
	rounds = round_number
	_until = TRICK_EVERY
	_warned = false
	_from.assign(spots)
	spots.assign(new_spots)
	for index in _here():
		circus.clowns[index].joke()
	_running = RUN
	started.emit()


func _here() -> Array[int]:
	var here: Array[int] = []
	for clown in circus.clowns:
		if clown.visible:
			here.append(clown.index)
	return here


## Each clown along the circle from his old spot to his new one, LAPS around and then some, at `t` (0 to 1).
func _place(t: float) -> void:
	var count := circus.clowns.size()
	for index in _here():
		var a := (_from[index] + 0.5) * TAU / count
		var b := (spots[index] + 0.5) * TAU / count
		while b < a:
			b += TAU
		var turn := lerpf(a, b + LAPS * TAU, t)
		var clown := circus.clowns[index]
		clown.position = Circus.TENT_AT + Vector3(sin(turn), 0, cos(turn)) * Circus.CLOWNS_RADIUS
		clown.rotation.y = turn if t >= 1.0 else turn + PI / 2
