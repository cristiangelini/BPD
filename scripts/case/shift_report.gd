class_name ShiftReport
extends RefCounted

## End of shift numbers (docs/diseno/allanamiento.md, "Cómo se gana y cómo se pierde"): pay, quota and joke awards.

## Week 1 has a single case, so its pay is the whole shift (decision 69).
const SALARY := 500
const QUOTA := 800

## Joke awards (decision 41): the stat each one goes by, and its text key. Only handed out above 0.
const AWARDS := [
	{"stat": "ram_misses", "key": "AWARD_RAM_MISSES"},
	{"stat": "story_seconds", "key": "AWARD_STORY_SECONDS"},
	{"stat": "meters_driven", "key": "AWARD_METERS_DRIVEN"},
]


## Pay for one case. A solved case pays the salary and what is left of each delivered evidence;
## a failed one pays nothing of that (propuesta), but the fines are still taken off.
static func pay(solved: bool, evidence_values: Array, fines: int) -> Dictionary:
	var evidence := 0
	if solved:
		for value: float in evidence_values:
			evidence += roundi(value)
	var salary := SALARY if solved else 0
	var total := salary + evidence - fines
	return {"salary": salary, "evidence": evidence, "fines": fines, "total": total, "quota": QUOTA,
		"approved": total >= QUOTA}


## For each award, the index of the cop with the highest stat (first one on a tie), or nothing if all are 0.
static func awards(cop_stats: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for award: Dictionary in AWARDS:
		var best := -1
		for i in cop_stats.size():
			var value: float = cop_stats[i].get(award.stat, 0)
			if value > 0 and (best < 0 or value > cop_stats[best][award.stat]):
				best = i
		if best >= 0:
			result.append({"key": award.key, "cop": best, "value": cop_stats[best][award.stat]})
	return result
