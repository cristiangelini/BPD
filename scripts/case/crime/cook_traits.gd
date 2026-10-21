class_name CookTraits
extends RefCounted

## The six cooks of the pastry contest (escena-del-crimen.md, "El primer caso: el pastel robado"): what tells them
## apart, drawn with the case seed so every match has other cooks. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Bruno", "Clara", "Dora", "Emilio", "Fabiola", "Gaspar"]
const APRONS := {"pink": Color(0.95, 0.55, 0.7), "mint": Color(0.45, 0.82, 0.65), "yellow": Color(0.98, 0.82, 0.3),
	"lilac": Color(0.68, 0.58, 0.9)}
const HAIRS := {"black": Color(0.12, 0.1, 0.1), "red": Color(0.72, 0.28, 0.15), "blond": Color(0.95, 0.8, 0.4),
	"white": Color(0.95, 0.94, 0.9)}
const TEETH: Array[String] = ["normal", "gap", "gold", "braces"]
const SHOE_MIN := 38
const SHOE_MAX := 45


## The six cooks for this seed, each a Dictionary with name, apron, hair, glasses, left (handed), shoe and teeth. No two
## are the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("pastry cooks %d" % seed_value)
	var cooks: Array[Dictionary] = []
	var seen := {}
	while cooks.size() < COUNT:
		var cook := {
			"name": NAMES[cooks.size()],
			"apron": APRONS.keys()[rng.randi_range(0, APRONS.size() - 1)],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"left": rng.randf() < 0.35,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
		}
		var key := signature(cook)
		if not seen.has(key):
			seen[key] = true
			cooks.append(cook)
	return cooks


## Everything about a cook but his name, to tell whether two are the same.
static func signature(cook: Dictionary) -> String:
	return "%s %s %s %s %d %s" % [cook.apron, cook.hair, cook.glasses, cook.left, cook.shoe, cook.teeth]
