class_name RallyCrowd
extends Node

## The crowd in front of deputy Lustre's stage (proteccion-politico.md, step 2, decision 103): FANS neighbors in two
## rows between the stage and the fountain, a different set for each seed, and HECKLERS of them, drawn by the seed,
## who throw. While the speech goes on, each heckler throws an egg or a tomato every THROW_EVERY seconds or so, aimed
## at the politician's chest but up to MISS off; the rest cheer now and then. Step 4: the hecklers carry a market bag
## with eggs and tomatoes and SHOPPERS innocents a shopping bag that looks the same from afar; a cop looking at a heckler
## as they throw (within SEE_ANGLE of their view, SEE_REACH away, nothing in between) marks them. Cuffed, a heckler is
## walked to the patrol car (OwnerEscort, the bank robbers' seats) and `jailed` goes off; the ones left throw more often.
## Every number here is (propuesta).
## At the parade (politico-descapotable.md, step 2, decision 222) the level hands it the fans' `spots` (with the way
## each one faces) along the route's sidewalks, and a heckler throws only with the deputy within `throw_reach`.

signal jailed(heckler: RallyFan)

const FANS := 16
const HECKLERS := 4
const LOOKS: Array[String] = ["vecina", "clienta", "cliente", "senora", "abuelo", "abuela", "repartidor", "heladero",
	"periodista"]
## The rows, from the plaza's middle: across (x) and how far north (z) of the fountain.
const ROW_XS: Array[float] = [-7.0, -5.0, -3.0, -1.0, 1.0, 3.0, 5.0, 7.0]
const ROW_ZS: Array[float] = [-7.5, -5.2]
const THROW_EVERY := 24.0
const THROW_JITTER := 8.0
## The first throws wait this long after the speech starts, so the cops can get in place.
const FIRST_THROW := 8.0
## Aimed a bit over the lectern, at his chest.
const CHEST := 1.3
const MISS := 0.6
const CHEER_EVERY := 7.0
const CHEERS := 8
const SHOPPERS := 3
const SEE_ANGLE := 30.0
const SEE_REACH := 30.0
## With fewer hecklers left, each one throws this much sooner: THROW_EVERY times (SOLO_SHARE + the rest's share).
const SOLO_SHARE := 0.5

var fans: Array[RallyFan] = []
var hecklers: Array[RallyFan] = []
var politician: Politician
var speech: PoliticianSpeech
var detained := 0
## Where the fans stand (on the ground, from the plaza's middle) and the way each one faces (around Y), when the level
## gives them; empty, the two rows in front of the stage.
var spots: Array[Vector3] = []
var turns: Array[float] = []
## Throws only with the politician this close (m); 0 for anywhere.
var throw_reach := 0.0
## Heckler -> seconds to their next throw.
var _next_throw := {}
var _cheer_left := CHEER_EVERY
var _rng := RandomNumberGenerator.new()


## Puts the fans in the level around `plaza` (the plaza's middle, world space).
## Hecklers who get cuffed are walked to `car`.
func setup(level: Node3D, plaza: Vector3, speaker: Politician, the_speech: PoliticianSpeech, case_seed: int,
		car: PatrolCar = null) -> void:
	politician = speaker
	speech = the_speech
	_rng.seed = hash(["rally crowd", case_seed])
	var looks := LOOKS.duplicate()
	var rows := spots.is_empty()
	if rows:
		for z in ROW_ZS:
			for x in ROW_XS:
				spots.append(Vector3(x, 0, z))
	var count := FANS if rows else spots.size()
	for i in count:
		var fan := RallyFan.new()
		fan.name = "Fan%d" % i
		fan.look = looks[_rng.randi_range(0, looks.size() - 1)]
		level.add_child(fan)
		fan.global_position = plaza + spots[i % spots.size()] + Vector3(_rng.randf_range(-0.3, 0.3), 0.05, 0)
		# Facing the stage, to the north, or the way the level says.
		fan.rotation.y = 0.0 if rows else turns[i]
		fans.append(fan)
	var order: Array = range(count)
	for i in range(order.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for i in HECKLERS:
		var heckler := fans[order[i]]
		heckler.heckler = true
		hecklers.append(heckler)
		_next_throw[heckler] = FIRST_THROW + _rng.randf_range(0.0, THROW_EVERY)
		heckler.carry_bag("market")
		if car:
			var escort := OwnerEscort.attach(heckler, car)
			escort.seat_shift = BankLevel.ROBBER_SEATS[i]
			escort.in_car_hint = "HINT_HECKLER_IN_CAR"
			escort.boarded.connect(_on_boarded.bind(heckler))
	for i in SHOPPERS:
		fans[order[HECKLERS + i]].carry_bag("shopping")


func _physics_process(delta: float) -> void:
	if not speech or not speech.speaking:
		return
	for heckler: RallyFan in hecklers:
		if not heckler.free_to_throw():
			continue
		_next_throw[heckler] -= delta
		if throw_reach > 0.0 and heckler.global_position.distance_to(politician.global_position) > throw_reach:
			continue
		if _next_throw[heckler] <= 0.0:
			_next_throw[heckler] = throw_every() + _rng.randf_range(-THROW_JITTER, THROW_JITTER)
			throw_from(heckler)
	_cheer_left -= delta
	if _cheer_left <= 0.0:
		_cheer_left = CHEER_EVERY
		var fan := fans[_rng.randi_range(0, fans.size() - 1)]
		if not fan.heckler:
			fan.say("FAN_CHEER_%d" % _rng.randi_range(1, CHEERS))


## Seconds between one heckler's throws now: sooner with fewer of them still out of the patrol car.
func throw_every() -> float:
	var left := HECKLERS - detained
	return THROW_EVERY * (SOLO_SHARE + (1.0 - SOLO_SHARE) * left / HECKLERS)


## `heckler` throws now: an egg or a tomato at the politician's chest, a little off. Cops looking at them see it.
func throw_from(heckler: RallyFan) -> RallyThrowable:
	var kind := "egg" if _rng.randf() < 0.5 else "tomato"
	var miss := Vector3(_rng.randf_range(-MISS, MISS), _rng.randf_range(-MISS, MISS) * 0.5, 0)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if sees_throw(cop, heckler):
			if not heckler.marked:
				cop.show_hint("HINT_HECKLER_SEEN")
			heckler.mark()
	return heckler.throw_at(politician.global_position + Vector3.UP * CHEST + miss, kind)


## Whether `cop` is looking at `heckler`: within SEE_ANGLE of the view's middle, SEE_REACH away, no wall in between.
func sees_throw(cop: Cop, heckler: RallyFan) -> bool:
	var eye := cop.camera.global_position
	var at := heckler.global_position + Vector3.UP * 1.2
	var to := at - eye
	if to.length() > SEE_REACH or to.length() < 0.01:
		return false
	if (-cop.camera.global_basis.z).angle_to(to) > deg_to_rad(SEE_ANGLE):
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, [cop.get_rid()])
	return cop.get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


## The last heckler still loose (neither cuffed nor taken away), who runs off when the speech ends; null if none.
func loose_heckler() -> RallyFan:
	for i in range(hecklers.size() - 1, -1, -1):
		if hecklers[i].free_to_throw():
			return hecklers[i]
	return null


func _on_boarded(heckler: RallyFan) -> void:
	detained += 1
	jailed.emit(heckler)
