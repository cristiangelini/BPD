class_name VentGuard
extends NightGuard

## The night guard of the vent jailbreak (docs/diseno/fuga-ventilacion.md, step 1): awake at his desk with no donuts,
## watching the cells like the donut's guard, and without the cells' key: it hangs on the key board behind him
## (step 3). Every number here is (propuesta).


## The guard for this jailbreak's seed (no box, no key on his belt).
func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["vent guard", case_seed])
	key_on_belt = false


## No donuts tonight.
func eat() -> void:
	eat_left = EAT_EVERY
