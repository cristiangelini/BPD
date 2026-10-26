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
