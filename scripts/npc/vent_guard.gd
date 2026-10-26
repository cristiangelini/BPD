class_name VentGuard
extends NightGuard

## The night guard of the vent jailbreak (docs/diseno/fuga-ventilacion.md, step 1): awake at his desk with no donuts,
## watching the cells like the donut's guard, and without the cells' key: it hangs on the key board behind him
## (step 3). Someone scrambling in the duct over his head (heard_duct, step 2) turns his eyes to the ceiling and
## raises his suspicion DUCT_NOISE a second, for as long as it lasts. Every number here is (propuesta).

const DUCT_NOISE := 15.0
## How long a scramble he heard keeps counting after the last one.
const DUCT_MEMORY := 0.3
const CEILING_LINES := 3

var _duct_left := 0.0


## The guard for this jailbreak's seed (no box, no key on his belt).
func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["vent guard", case_seed])
	key_on_belt = false


## No donuts tonight.
func eat() -> void:
	eat_left = EAT_EVERY


func _physics_process(delta: float) -> void:
	_duct_left = maxf(_duct_left - delta, 0.0)
	super(delta)


## A cop scrambling in the duct at `at`: he hears it if it's in range, and looks up that way.
func heard_duct(at: Vector3) -> void:
	if is_asleep() or _flat(at).length() > HEAR_RANGE:
		return
	if _duct_left <= 0.0 and distracted_left <= 0.0:
		look_at_noise(at, NOISE_LOOK, "VENT_GUARD_CEILING_%d" % _rng.randi_range(0, CEILING_LINES - 1))
	_duct_left = DUCT_MEMORY


func hears_duct() -> bool:
	return _duct_left > 0.0


func alarm() -> float:
	return super() + (DUCT_NOISE if hears_duct() else 0.0)
