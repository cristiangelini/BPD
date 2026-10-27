class_name MagicianTraits
extends RefCounted

## The six magicians on the train El Lento (escena-tren.md, "Los magos iguales"): the same cape, top hat, fake
## beard and gloves, told apart by their stage name, their own hair (under the hat), their glasses, the size of their
## shoes, their teeth and which hand they tie knots with. Each starts in his seat (1 to 6, in the order of the
## traits). Drawn with the case seed so every match has other magicians. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Abracadabrín", "Bolsillo", "Chispazo", "Don Conejo", "Mandrágora", "Zigzag"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## Each clue of the train case and the trait of the culprit it tells (escena-tren.md, "Las pistas").
const CLUES := {
	"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "witness": "glasses", "knot": "left",
}


## The six magicians for this seed, each a Dictionary with name, hair, glasses, left (handed), shoe and teeth. No two
## are the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["train magicians", seed_value])
	var magicians: Array[Dictionary] = []
	var seen := {}
	while magicians.size() < COUNT:
		var magician := {
			"name": NAMES[magicians.size()],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"left": rng.randf() < 0.35,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
		}
		var key := signature(magician)
		if not seen.has(key):
			seen[key] = true
			magicians.append(magician)
	return magicians


## Everything about a magician but his name, to tell whether two are the same.
static func signature(magician: Dictionary) -> String:
	return "%s %s %s %d %s" % [magician.hair, magician.glasses, magician.left, magician.shoe, magician.teeth]
