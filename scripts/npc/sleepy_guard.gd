class_name SleepyGuard
extends NightGuard

## The night guard of the guard dog's jailbreak (docs/diseno/fuga-perro.md, step 1): he fell asleep at his desk with
## no donuts, and the cells' key is on Mordisco's collar (GuardDog), not on his belt. Asleep he snores and sees
## nothing, for as long as nobody wakes him: WAKE_BARK seconds of the dog barking (heard_bark) or a shout near him.
## Awake he watches and gets suspicious like the donut's guard, and once he's seen nothing odd for DOZE_AFTER seconds
## he nods off again; awake, the barking turns his head to whoever the dog barks at. Singing to him (whistling) is
## what calls the dog (GuardDog.heard_whistle), so he passes it on. Every number here is (propuesta).

const WAKE_BARK := 3.0
## How fast the barking he's heard wears off while there's none.
const BARK_FADE := 0.5
const DOZE_AFTER := 20.0
const SNORE_EVERY := 5.0
const SNORE_LINES := 3
const WOKEN_LINES := 3

## Seconds of barking he's heard while asleep, and how long he's been awake with nothing odd in sight.
var barked := 0.0
var calm := 0.0
var _barking := false
## Mordisco, who hears the whistling through him (the level sets it).
var dog: GuardDog
var _snore_left := 0.0


func _ready() -> void:
	super()
	fall_asleep()


## The guard for this jailbreak's seed (he has no box: the seed only picks his lines).
func doze(case_seed: int) -> void:
	_rng.seed = hash(["sleepy guard", case_seed])


func _physics_process(delta: float) -> void:
	super(delta)
	if is_asleep():
		if not _barking:
			barked = maxf(barked - BARK_FADE * delta, 0.0)
		_barking = false
		_snore_left -= delta
		if _snore_left <= 0.0:
			_snore_left = SNORE_EVERY
			say("SLEEPY_GUARD_SNORE_%d" % _rng.randi_range(0, SNORE_LINES - 1), 3.0)
		return
	calm = calm + delta if suspicion <= 0.0 and alarm() <= 0.0 else 0.0
	if calm >= DOZE_AFTER:
		fall_asleep()


## The dog is barking for `seconds` (at whoever is at `at`): WAKE_BARK seconds of it wake him up, and awake he looks.
func heard_bark(seconds: float, at := Vector3.INF) -> void:
	if not is_asleep():
		if at != Vector3.INF and distracted_left <= 0.0:
			look_at_noise(at, NOISE_LOOK, "SLEEPY_GUARD_LOOK")
		return
	_barking = true
	barked += seconds
	if barked >= WAKE_BARK:
		wake_up()
		say("SLEEPY_GUARD_WOKEN_%d" % _rng.randi_range(0, WOKEN_LINES - 1))


## He sleeps until something wakes him (no SLEEP limit).
func fall_asleep() -> void:
	super()
	asleep_left = INF
	barked = 0.0
	calm = 0.0
	_snore_left = SNORE_EVERY
	say("SLEEPY_GUARD_DOZE", 3.0)


func wake_up() -> void:
	super()
	calm = 0.0
	barked = 0.0


## A cop whistling (singing or humming) calls the dog; it still lulls the guard as ever.
func heard_singing(cop: Node3D) -> void:
	super(cop)
	if dog and cop is Cop:
		dog.heard_whistle(cop)


## No donuts tonight.
func eat() -> void:
	eat_left = EAT_EVERY
