class_name PlaceDraw
extends RefCounted

## Which place a match happens in (panaderia.md, "El orden para hacerlo", step 5): Play draws a case seed and, from
## it, the grandpa's house, the bakery or the pet salon, with even odds (propuesta). Every third shift is an
## interrogation instead (interrogatorio.md, "Sale como un caso más"), and of the rest half are chases
## (persecucion.md, "Sale como un caso más"). Of the shifts left, one in CRIME_EVERY is the crime scene
## (escena-del-crimen.md, propuesta), then one in TRAFFIC_EVERY the traffic control (control-transito.md), then one in
## INFILTRATION_EVERY an infiltration (infiltracion.md), half at the grandparents' club and half at the church choir
## (infiltracion-coro.md), then one in BANK_EVERY the bank robbery (robo-banco.md), and the rest are raids. A
## campaign whose cops missed the quota goes to the jailbreak first (fuga.md). --place=<id> forces one. The level then
## takes that seed, so the place, the story and the hiding spots all come from one seed.

const PLACES := {
	"grandpa": "res://scenes/levels/grandpa_house.tscn",
	"bakery": "res://scenes/levels/bakery.tscn",
	"groomer": "res://scenes/levels/groomer.tscn",
	"interrogation": "res://scenes/levels/interrogation.tscn",
	"chase": "res://scenes/levels/chase.tscn",
	"crime_scene": "res://scenes/levels/crime_scene.tscn",
	"traffic": "res://scenes/levels/traffic_control.tscn",
	"jailbreak": "res://scenes/levels/jailbreak.tscn",
	"club": "res://scenes/levels/grandpa_club.tscn",
	"choir": "res://scenes/levels/church_choir.tscn",
	"bank": "res://scenes/levels/bank.tscn",
	"plaza": "res://scenes/levels/plaza_rally.tscn",
}
## The raids, drawn by the seed.
const ORDER := ["grandpa", "bakery", "groomer"]
## One shift in this many is an interrogation (Cristian, 20/10): shifts 3, 6... of a campaign, or 1 in 3 by the seed
## without one.
const INTERROGATION_EVERY := 3
## Of the shifts that aren't interrogations, one in this many is a chase (Cristian, 20/10: half and half).
const CHASE_EVERY := 2
## Of the shifts that are neither, one in this many is the crime scene, and of the rest one in TRAFFIC_EVERY is the
## traffic control (propuesta: each as often as each raid).
const CRIME_EVERY := 5
const TRAFFIC_EVERY := 4
## Of the rest, one in this many is an infiltration (propuesta: as often as each raid), at one of these by the seed.
const INFILTRATION_EVERY := 4
const INFILTRATIONS := ["club", "choir"]
## Of the rest, one in this many is the bank robbery (robo-banco.md, propuesta: as often as each raid).
const BANK_EVERY := 4

## The seed the next level takes (0 = none drawn; the level draws its own).
static var pending_seed := 0
## The owner brought in from the last raid without a campaign (RaidCase.custody); a campaign keeps its own.
static var custody := {}


## The place for this seed: from --place=<id> among the user args, or drawn. It hashes the seed instead of taking
## seed % 3, because the stories are drawn with seed % their count and the two draws would go together.
## `shift` is the campaign's shift (0 without a campaign). Without `chases` every shift that isn't an interrogation is
## a raid.
static func pick(case_seed: int, args: PackedStringArray, shift := 0, chases := true) -> String:
	for arg in args:
		if arg.begins_with("--place=") and PLACES.has(arg.trim_prefix("--place=")):
			return arg.trim_prefix("--place=")
	# A missed quota locks the cops up before anything else (decision 99, fuga.md).
	if Campaign.current and Campaign.current.jailed:
		return "jailbreak"
	# An owner in custody is interrogated next, whatever the shift (decision 93).
	if is_interrogation(case_seed, shift) or not custody_now().is_empty():
		return "interrogation"
	if chases and hash("case kind %d" % case_seed) % CHASE_EVERY == 0:
		return "chase"
	# Hashed as an array: string hashes of the same seed with another prefix go together in their low bits.
	if chases and hash(["crime scene", case_seed]) % CRIME_EVERY == 0:
		return "crime_scene"
	if chases and hash(["traffic control", case_seed]) % TRAFFIC_EVERY == 0:
		return "traffic"
	if chases and hash(["infiltration", case_seed]) % INFILTRATION_EVERY == 0:
		return INFILTRATIONS[hash(["infiltration place", case_seed]) % INFILTRATIONS.size()]
	if chases and hash(["bank robbery", case_seed]) % BANK_EVERY == 0:
		return "bank"
	return ORDER[hash("place %d" % case_seed) % ORDER.size()]


static func is_interrogation(case_seed: int, shift: int) -> bool:
	if shift > 0:
		return shift % INTERROGATION_EVERY == 0
	return hash("interrogation %d" % case_seed) % INTERROGATION_EVERY == 0


## The owner waiting to be interrogated: the campaign's, or the one from the last raid without one.
static func custody_now() -> Dictionary:
	if Campaign.current and not Campaign.current.is_over():
		return Campaign.current.custody
	return custody


## Lets the owner go once he's been interrogated.
static func release_custody() -> void:
	custody = {}
	if Campaign.current:
		Campaign.current.custody = {}


## The shift being played, or 0 without a campaign.
static func shift_now() -> int:
	if Campaign.current and not Campaign.current.is_over():
		return Campaign.current.shift
	return 0


## A new case seed: never 0 (0 means "none"), and odd or even, so every story can come up (seed % count).
static func new_seed() -> int:
	return randi_range(1, 0x7fffffff)


## The seed of the next case: the current campaign's shift (docs/diseno/guardado.md), or a new one without a campaign.
static func next_seed() -> int:
	if Campaign.current and not Campaign.current.is_over():
		return Campaign.current.case_seed()
	return new_seed()


## Takes the next case seed and opens its place.
static func start(tree: SceneTree) -> void:
	pending_seed = next_seed()
	tree.change_scene_to_file(PLACES[pick(pending_seed, OS.get_cmdline_user_args(), shift_now())])


## The seed Play drew for this level, once; 0 if the level was opened some other way.
static func take_seed() -> int:
	var drawn := pending_seed
	pending_seed = 0
	return drawn
