class_name RoofGuard
extends NightGuard

## The night guard of the roof jailbreak (docs/diseno/fuga-techo.md, step 1): the cells' key never leaves his belt and
## there are no donuts. A skylight creaking over a cell makes him look up there, saying so, and raises his suspicion
## CREAK_SUSPICION. Step 2: a box falling in the storage room upstairs (THUMP_SUSPICION) and running on the roof
## (STEPS_SUSPICION) too; with his suspicion at GO_UP after a thump, he goes up to look with his flashlight and counts
## heads in the cells: anyone missing is a catch.
## Every number here is (propuesta).

const CREAK_SUSPICION := 8.0
const CREAK_LINES := 3
const THUMP_SUSPICION := 15.0
const THUMP_LINES := 3
const STEPS_SUSPICION := 10.0
const STEPS_LINES := 3
const GO_UP := 50.0
## After counting everyone there, he calms down to this.
const CALM_AFTER_LOOK := 25.0


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


## A box fell upstairs at `at`: he looks up and, suspicious enough, goes up to count heads.
func heard_thump(at: Vector3) -> void:
	if is_asleep():
		return
	suspicion = minf(suspicion + THUMP_SUSPICION, 100.0)
	look_at_noise(at, NOISE_LOOK, "ROOF_GUARD_THUMP_%d" % _rng.randi_range(0, THUMP_LINES - 1))
	if suspicion >= GO_UP:
		count_heads()


## Running on the roof over him.
func heard_steps(at: Vector3) -> void:
	if is_asleep():
		return
	suspicion = minf(suspicion + STEPS_SUSPICION, 100.0)
	look_at_noise(at, NOISE_LOOK, "ROOF_GUARD_STEPS_%d" % _rng.randi_range(0, STEPS_LINES - 1))


## With his flashlight in the cells: anyone out of them (upstairs, on the roof) is a catch; all there, he calms down.
func count_heads() -> void:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if outside_cells.call(cop.global_position):
			catch()
			say("ROOF_GUARD_MISSING", 5.0)
			return
	suspicion = minf(suspicion, CALM_AFTER_LOOK)
	say("ROOF_GUARD_ALL_THERE", 5.0)
