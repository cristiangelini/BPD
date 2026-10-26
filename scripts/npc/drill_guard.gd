class_name DrillGuard
extends NightGuard

## The day guard of the fire drill jailbreak (docs/diseno/fuga-simulacro.md, step 1): at his desk watching the cells,
## with the cells' key on his belt and no donuts. Smoke he sees coming out of a cell's heater (CellHeater) raises his
## suspicion SMOKE_SUSPICION a second ("¿Qué están quemando ahí?"). Every number here is (propuesta).

const SMOKE_SUSPICION := 20.0
const SMOKE_LINES := 3
## The smoke is a cloud over the heater: he sees it if he sees any of these points of it (the cell's bars hide some).
const SMOKE_CLOUD: Array[Vector3] = [Vector3(0, 0.85, 0), Vector3(0, 1.4, 0), Vector3(0, 2.0, 0), Vector3(0.3, 1.4, 0.3),
	Vector3(-0.3, 1.4, 0.3)]

var _saw_smoke := false


## The guard for this jailbreak's seed, the key on his belt.
func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["drill guard", case_seed])
	key_on_belt = true


## No donuts on duty.
func eat() -> void:
	eat_left = EAT_EVERY


## What he sees, plus the smoke of a heater with a blanket on it.
func alarm() -> float:
	var rate := super()
	var smoke := false
	for heater: CellHeater in get_tree().get_nodes_in_group("cell_heaters"):
		if heater.is_smoking() and _sees_smoke(heater):
			smoke = true
	if smoke and not _saw_smoke:
		say("DRILL_GUARD_SMOKE_%d" % _rng.randi_range(0, SMOKE_LINES - 1))
	_saw_smoke = smoke
	return rate + (SMOKE_SUSPICION if smoke else 0.0)


func _sees_smoke(heater: CellHeater) -> bool:
	return SMOKE_CLOUD.any(func(at: Vector3) -> bool: return sees(heater.global_transform * at))
