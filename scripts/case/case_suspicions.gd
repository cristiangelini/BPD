class_name CaseSuspicions
extends RefCounted

## The cops guess the raid's story among three suspicions (historias.md, "Resolver con las pruebas"; decision 79).

## Every story the grandpa's house can be suspected of, playable or not yet: SUSPECT_<id> names it and
## CLUE_SUSPECT_<id> is the clue that hints at it.
const POOL := ["bingo", "turtles", "museum", "dentures", "radio", "fight"]
const COUNT := 3
## Seconds to hold 1, 2 or 3 with the checklist open to mark a suspicion (propuesta).
const MARK_SECONDS := 2.0
## A wrong mark halves the salary; this many wrong marks fail the case.
const WRONG_TO_FAIL := 2


## The true story and two others from the pool (the place's own, POOL for the grandpa's house), in an order drawn
## from the seed.
static func draw(case_seed: int, true_id: String, pool: Array = POOL) -> Array[String]:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed * 23 + 11
	var others: Array = pool.filter(func(id: String) -> bool: return id != true_id)
	var picked: Array[String] = [true_id]
	while picked.size() < COUNT:
		picked.append(others.pop_at(rng.randi_range(0, others.size() - 1)))
	for i in range(picked.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := picked[i]
		picked[i] = picked[j]
		picked[j] = swap
	return picked
