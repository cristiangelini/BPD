class_name PlaceDraw
extends RefCounted

## Which place a match happens in (panaderia.md, "El orden para hacerlo", step 5): Play draws a case seed and, from
## it, the grandpa's house, the bakery or the pet salon, with even odds (propuesta). Every third shift is an
## interrogation instead (interrogatorio.md, "Sale como un caso más"). --place=<id> forces one. The level then takes
## that seed, so the place, the story and the hiding spots all come from one seed.

const PLACES := {
	"grandpa": "res://scenes/levels/grandpa_house.tscn",
	"bakery": "res://scenes/levels/bakery.tscn",
	"groomer": "res://scenes/levels/groomer.tscn",
	"interrogation": "res://scenes/levels/interrogation.tscn",
	# Not drawn yet (persecucion.md, step 5): --place=chase opens it.
	"chase": "res://scenes/levels/chase.tscn",
}
## The raids, drawn by the seed.
const ORDER := ["grandpa", "bakery", "groomer"]
## One shift in this many is an interrogation (Cristian, 20/10): shifts 3, 6... of a campaign, or 1 in 3 by the seed
## without one.
const INTERROGATION_EVERY := 3

## The seed the next level takes (0 = none drawn; the level draws its own).
static var pending_seed := 0
## The owner brought in from the last raid without a campaign (RaidCase.custody); a campaign keeps its own.
static var custody := {}


## The place for this seed: from --place=<id> among the user args, or drawn. It hashes the seed instead of taking
## seed % 3, because the stories are drawn with seed % their count and the two draws would go together.
## `shift` is the campaign's shift (0 without a campaign).
static func pick(case_seed: int, args: PackedStringArray, shift := 0) -> String:
	for arg in args:
		if arg.begins_with("--place=") and PLACES.has(arg.trim_prefix("--place=")):
			return arg.trim_prefix("--place=")
	# An owner in custody is interrogated next, whatever the shift (decision 93).
	if is_interrogation(case_seed, shift) or not custody_now().is_empty():
		return "interrogation"
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
