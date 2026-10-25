class_name Bribes
extends RefCounted

## Bribes and internal affairs (docs/diseno/sobornos.md, decisions 190 to 192): who offers, how much, and the
## numbers of the investigation. The campaign keeps the record (Campaign.take_bribe).

## One in OFFER_ODDS people offer money the first time a cop cuffs them, one of AMOUNTS.
const OFFER_ODDS := 4
const AMOUNTS: Array[int] = [100, 150, 200, 250]
## Seconds the cop has to choose.
const CHOICE_SECONDS := 5.0
## Bribes taken in a campaign that open an investigation.
const INVESTIGATION_AT := 3
## Clean shifts of investigation that close it.
const CLEAN_SHIFTS := 2
## The agent sees a bribe within this many meters, and fines it this much; his second catch suspends the cops.
const SEEN_REACH := 15.0
const CAUGHT_FINE := 300
const CATCHES_TO_SUSPEND := 2
## How many ways the one offering says it (BRIBE_OFFER_<n>).
const PHRASES := 10


## What `who` (a stable key of the person, the same on every PC: its path) offers in the case with `case_seed`:
## 0 if they let themselves be cuffed.
static func offer(case_seed: int, who: String) -> int:
	var roll := hash("bribe %d %s" % [case_seed, who]) & 0x7fffffff
	if roll % OFFER_ODDS != 0:
		return 0
	return AMOUNTS[(roll / OFFER_ODDS) % AMOUNTS.size()]


## The text key of how `who` offers it.
static func phrase_key(case_seed: int, who: String) -> String:
	return "BRIBE_OFFER_%d" % ((hash("bribe phrase %d %s" % [case_seed, who]) & 0x7fffffff) % PHRASES + 1)
