class_name RallyCrowd
extends Node

## The crowd in front of deputy Lustre's stage (proteccion-politico.md, step 2, decision 103): FANS neighbors in two
## rows between the stage and the fountain, a different set for each seed, and HECKLERS of them, drawn by the seed,
## who throw. While the speech goes on, each heckler throws an egg or a tomato every THROW_EVERY seconds or so, aimed
## at the politician's chest but up to MISS off; the rest cheer now and then. Every number here is (propuesta).

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

var fans: Array[RallyFan] = []
var hecklers: Array[RallyFan] = []
var politician: Politician
var speech: PoliticianSpeech
## Heckler -> seconds to their next throw.
var _next_throw := {}
var _cheer_left := CHEER_EVERY
var _rng := RandomNumberGenerator.new()


## Puts the fans in the level around `plaza` (the plaza's middle, world space).
func setup(level: Node3D, plaza: Vector3, speaker: Politician, the_speech: PoliticianSpeech, case_seed: int) -> void:
	politician = speaker
	speech = the_speech
	_rng.seed = hash(["rally crowd", case_seed])
	var looks := LOOKS.duplicate()
	var spots: Array[Vector3] = []
	for z in ROW_ZS:
		for x in ROW_XS:
			spots.append(Vector3(x, 0, z))
	for i in FANS:
		var fan := RallyFan.new()
		fan.name = "Fan%d" % i
		fan.look = looks[_rng.randi_range(0, looks.size() - 1)]
		level.add_child(fan)
		fan.global_position = plaza + spots[i % spots.size()] + Vector3(_rng.randf_range(-0.3, 0.3), 0.05, 0)
		# Facing the stage, to the north.
		fan.rotation.y = 0.0
		fans.append(fan)
	var order: Array = range(FANS)
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


func _physics_process(delta: float) -> void:
	if not speech or not speech.speaking:
		return
	for heckler: RallyFan in hecklers:
		_next_throw[heckler] -= delta
		if _next_throw[heckler] <= 0.0:
			_next_throw[heckler] = THROW_EVERY + _rng.randf_range(-THROW_JITTER, THROW_JITTER)
			throw_from(heckler)
	_cheer_left -= delta
	if _cheer_left <= 0.0:
		_cheer_left = CHEER_EVERY
		var fan := fans[_rng.randi_range(0, fans.size() - 1)]
		if not fan.heckler:
			fan.say("FAN_CHEER_%d" % _rng.randi_range(1, CHEERS))


## `heckler` throws now: an egg or a tomato at the politician's chest, a little off.
func throw_from(heckler: RallyFan) -> RallyThrowable:
	var kind := "egg" if _rng.randf() < 0.5 else "tomato"
	var miss := Vector3(_rng.randf_range(-MISS, MISS), _rng.randf_range(-MISS, MISS) * 0.5, 0)
	return heckler.throw_at(politician.global_position + Vector3.UP * CHEST + miss, kind)
