class_name RoofGuard
extends NightGuard

## The night guard of the roof jailbreak (docs/diseno/fuga-techo.md, step 1): the cells' key never leaves his belt and
## there are no donuts. A skylight creaking over a cell makes him look up there, saying so, and raises his suspicion
## CREAK_SUSPICION.
## Every number here is (propuesta).

const CREAK_SUSPICION := 8.0
const CREAK_LINES := 3


func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["roof guard", case_seed])
	key_on_belt = true


## No donuts on duty.
func eat() -> void:
	eat_left = EAT_EVERY


## The key stays on his belt: there's nothing to take from him.
func prompt_key(_cop: Cop) -> String:
	return ""


func use(_cop: Cop) -> void:
	pass


## Something creaked up at `at` (a skylight being pushed).
func heard_creak(at: Vector3) -> void:
	if is_asleep():
		return
	suspicion = minf(suspicion + CREAK_SUSPICION, 100.0)
	look_at_noise(at, NOISE_LOOK, "ROOF_GUARD_CREAK_%d" % _rng.randi_range(0, CREAK_LINES - 1))
