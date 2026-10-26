class_name InspectionReport
extends Node

## The inspector's report (docs/diseno/inspeccion.md, "El informe", decision 107): it starts at START out of 100 and
## goes up and down with what she sees. Each entry keeps what it was for, so the end can read the best and the worst.
## Every number here is (propuesta).

signal changed(score: int)

const START := 50
const SOLVED := 25
const CUFFED := 5
const EVIDENCE := 3
const CRASH := -5
const BROKEN := -2
const PARTNER_CUFFED := -5
const BRIBE := -20
const HIT := -10
const LEFT_BEHIND := -3
const DONUT := -1
## The report that saves the station on the last shift (inspeccion.md, "Cómo termina").
const PASS := 60
## What she says about each kind of entry (INSPECTOR_SAW_<KIND>).
const KINDS := {
	"solved": SOLVED, "cuffed": CUFFED, "evidence": EVIDENCE, "crash": CRASH, "broken": BROKEN,
	"partner": PARTNER_CUFFED, "bribe": BRIBE, "hit": HIT, "behind": LEFT_BEHIND, "donut": DONUT,
}

var score := START
## One {"kind", "points"} per entry, in order.
var entries: Array[Dictionary] = []


## Writes down one `kind` (a key of KINDS) and returns its points.
func note(kind: String) -> int:
	var points: int = KINDS[kind]
	entries.append({"kind": kind, "points": points})
	score = clampi(score + points, 0, 100)
	changed.emit(score)
	return points


func count(kind: String) -> int:
	return entries.filter(func(entry: Dictionary) -> bool: return entry.kind == kind).size()


## What the campaign keeps of it: the score, and the kinds that added and took off the most ("" if none).
func summary() -> Dictionary:
	var sums := {}
	for entry in entries:
		sums[entry.kind] = sums.get(entry.kind, 0) + entry.points
	var best := ""
	var worst := ""
	for kind: String in sums:
		if sums[kind] > 0 and (best == "" or sums[kind] > sums[best]):
			best = kind
		if sums[kind] < 0 and (worst == "" or sums[kind] < sums[worst]):
			worst = kind
	return {"score": score, "best": best, "worst": worst}


## The final score once the case is over: solved adds SOLVED, which then is the best thing she saw if nothing beat it.
static func final(summary_now: Dictionary, solved: bool) -> Dictionary:
	var result := summary_now.duplicate()
	if solved:
		result.score = clampi(int(result.score) + SOLVED, 0, 100)
		result.best = "solved"
	result.approved = int(result.score) >= PASS
	return result
