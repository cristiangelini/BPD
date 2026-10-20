class_name MillionaireRig
extends GroomerRig

## The millionaire's dog (peluqueria.md, "El perro del millonario"): Duque, a millionaire's white greyhound, was
## kidnapped and dyed brown, and Ramiro waits for the ransom. Four brown greyhounds roam the salon, all alike; only
## Duque shows his white roots up close (the story's own clue). Duque is the main evidence (12 kg): held, he wriggles,
## and let go anywhere but the trunk he runs from cops for a while. The dye and the ransom letter are hidden like any
## extra. Every number here is (propuesta).

const DUQUE_SCENE := preload("res://scenes/npc/duque.tscn")
const GREYHOUND_SCENE := preload("res://scenes/npc/greyhound.tscn")
## Where the four greyhounds start; the seed draws which one is Duque.
const STARTS: Array[Vector3] = [
	Vector3(-6.0, Groomer.FLOOR_TOP, 5.2), Vector3(4.5, Groomer.FLOOR_TOP, 6.2), Vector3(-2.0, Groomer.FLOOR_TOP, 1.0),
	Vector3(-4.5, Groomer.GRASS_TOP, -4.5),
]
## A cop this close sees the roots.
const ROOTS_RANGE := 1.2
## Held, he jerks this hard every WRIGGLE_EVERY seconds.
const WRIGGLE := 20.0
const WRIGGLE_EVERY := 0.6
## Let go outside the trunk, he runs from cops within ESCAPE_RANGE for ESCAPE seconds.
const ESCAPE := 10.0
const ESCAPE_RANGE := 4.0

var duque: Dog
var greyhounds: Array[Dog] = []
var escaping := 0.0
var _was_held := false
var _wriggle := WRIGGLE_EVERY
var _rng := RandomNumberGenerator.new()


func setup(place: Groomer) -> void:
	super.setup(place)
	_rng.seed = place.case_seed * 13 + 1
	var duque_at := place.case_seed % STARTS.size()
	for i in STARTS.size():
		var dog: Dog = (DUQUE_SCENE if i == duque_at else GREYHOUND_SCENE).instantiate()
		dog.position = STARTS[i] + Vector3.UP * 0.02
		dog.rotation.y = i * 1.7
		dog.areas = Groomer.DOG_AREAS
		dog.den = Groomer.DOGHOUSE_AT
		dog.floor_y = Groomer.FLOOR_TOP
		dog.rng.seed = place.case_seed + i
		place.add_child(dog)
		dog.barked.connect(place.ramiro.dog_barked)
		greyhounds.append(dog)
		if i == duque_at:
			duque = dog
	place.main = duque


func _physics_process(delta: float) -> void:
	if not is_instance_valid(duque):
		return
	var held := duque.is_held()
	var delivered := groomer.car.is_delivered(duque)
	# In the trunk he lies down and stays.
	duque.caged = delivered and not held
	if held:
		_wriggle -= delta
		if _wriggle <= 0.0:
			_wriggle = WRIGGLE_EVERY
			duque.apply_central_impulse(Vector3(_rng.randf_range(-1, 1), 0.4, _rng.randf_range(-1, 1)).normalized() * WRIGGLE)
	elif _was_held and not delivered:
		escaping = ESCAPE
	_was_held = held
	escaping = maxf(escaping - delta, 0.0)
	duque.flee = ESCAPE_RANGE if escaping > 0.0 else 0.0
	for cop in get_tree().get_nodes_in_group("cops"):
		var at := (cop as Node3D).global_position
		if Vector2(at.x - duque.global_position.x, at.z - duque.global_position.z).length() < ROOTS_RANGE:
			groomer.raid.add_clue(tr("CLUE_MILLIONAIRE_ROOTS"))
			break
