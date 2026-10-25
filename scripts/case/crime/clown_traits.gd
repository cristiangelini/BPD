class_name ClownTraits
extends RefCounted

## The six clowns of the Cascabel Brothers' circus (escena-circo.md, "Los payasos iguales"): all with the same wig,
## nose, makeup, gloves and giant shoes, and told apart only by what those hide: their own hair, glasses, the size of
## their real feet, their teeth and the note their nose honks. Drawn with the case seed so every match has other
## clowns. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Pirulo", "Chispita", "Bombón", "Tallarín", "Cascarita", "Rulito"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const HONKS: Array[String] = ["low", "mid", "high"]
## The note each honk plays, as a pitch scale.
const HONK_PITCH := {"low": 0.7, "mid": 1.0, "high": 1.45}
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX


## The six clowns for this seed, each a Dictionary with name, hair, glasses, shoe, teeth and honk. No two are the same
## in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("circus clowns %d" % seed_value)
	var clowns: Array[Dictionary] = []
	var seen := {}
	while clowns.size() < COUNT:
		var clown := {
			"name": NAMES[clowns.size()],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"honk": HONKS[rng.randi_range(0, HONKS.size() - 1)],
		}
		var key := signature(clown)
		if not seen.has(key):
			seen[key] = true
			clowns.append(clown)
	return clowns


## Everything about a clown but his name, to tell whether two are the same.
static func signature(clown: Dictionary) -> String:
	return "%s %s %d %s %s" % [clown.hair, clown.glasses, clown.shoe, clown.teeth, clown.honk]
