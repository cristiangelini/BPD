class_name ListeningGuard
extends NightGuard

## The night guard of the spoon tunnel jailbreak (docs/diseno/fuga-tunel.md, step 1): awake at his desk with no donuts
## and the cells' key on his belt, bored, watching like the donut's guard. What he hears comes in step 2. Every number
## here is (propuesta).


## The guard for this jailbreak's seed (no box: the key is on his belt from the start).
func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["listening guard", case_seed])
	key_on_belt = true


## No donuts tonight.
func eat() -> void:
	eat_left = EAT_EVERY
