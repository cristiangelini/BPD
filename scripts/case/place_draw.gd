class_name PlaceDraw
extends RefCounted

## Which place a match happens in (panaderia.md, "El orden para hacerlo", step 5): Play draws a case seed and, from
## it, the grandpa's house, the bakery or the pet salon, with even odds (propuesta). --place=<id> forces one. The level then takes
## that seed, so the place, the story and the hiding spots all come from one seed.

const PLACES := {
	"grandpa": "res://scenes/levels/grandpa_house.tscn",
	"bakery": "res://scenes/levels/bakery.tscn",
	"groomer": "res://scenes/levels/groomer.tscn",
	# Not drawn yet (interrogatorio.md, step 5): only --place=interrogation opens it.
	"interrogation": "res://scenes/levels/interrogation.tscn",
}
const ORDER := ["grandpa", "bakery", "groomer"]

## The seed the next level takes (0 = none drawn; the level draws its own).
static var pending_seed := 0


## The place for this seed: from --place=<id> among the user args, or drawn. It hashes the seed instead of taking
## seed % 3, because the stories are drawn with seed % their count and the two draws would go together.
static func pick(case_seed: int, args: PackedStringArray) -> String:
	for arg in args:
		if arg.begins_with("--place=") and PLACES.has(arg.trim_prefix("--place=")):
			return arg.trim_prefix("--place=")
	return ORDER[hash("place %d" % case_seed) % ORDER.size()]


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
	tree.change_scene_to_file(PLACES[pick(pending_seed, OS.get_cmdline_user_args())])


## The seed Play drew for this level, once; 0 if the level was opened some other way.
static func take_seed() -> int:
	var drawn := pending_seed
	pending_seed = 0
	return drawn
