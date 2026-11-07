class_name GhostTraits
extends RefCounted

## The six ghost actors of Seis Fantasmas (escena-teatro.md, "Los seis fantasmas"): the same white sheet, gloves and
## plastic chains, told apart by their own hair (under the sheet), shoe size, teeth, a deep voice (the culprit's and
## one or two more, who shouted at the rehearsal) and the embroidery on their sheet's hem (one each). Drawn with the
## case seed so every match has other ghosts. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Abelardo", "Berta", "Celestino", "Delfina", "Eulalio", "Fabiola"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## The embroideries, one per ghost, none repeated (Theater.EMBROIDERIES), and the color of each one's patch.
const EMBROIDERIES := Theater.EMBROIDERIES
const EMBROIDERY_COLORS := {
	"star": Color(0.98, 0.82, 0.2), "moon": Color(0.7, 0.78, 0.95), "sun": Color(0.98, 0.55, 0.15),
	"bolt": Color(0.55, 0.3, 0.85), "heart": Color(0.9, 0.2, 0.3), "clover": Color(0.25, 0.7, 0.3),
}
## How many of the six sing with a deep voice: at least two, at most three.
const DEEP := Vector2i(2, 3)


## The six ghosts for this seed, each a Dictionary with name, hair, shoe, teeth, deep (bool) and embroidery. No two look
## the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("theater ghosts %d" % seed_value)
	var deep := {}
	var deep_count := rng.randi_range(DEEP.x, DEEP.y)
	while deep.size() < deep_count:
		deep[rng.randi_range(0, COUNT - 1)] = true
	var embroideries: Array[String] = EMBROIDERIES.duplicate()
	for i in range(embroideries.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = embroideries[i]
		embroideries[i] = embroideries[j]
		embroideries[j] = swap
	var ghosts: Array[Dictionary] = []
	var seen := {}
	while ghosts.size() < COUNT:
		var i := ghosts.size()
		var ghost := {
			"name": NAMES[i],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"deep": deep.has(i),
			"embroidery": embroideries[i],
		}
		var key := signature(ghost)
		if not seen.has(key):
			seen[key] = true
			ghosts.append(ghost)
	return ghosts


## Everything about a ghost but the name and the embroidery, to tell whether two look the same.
static func signature(ghost: Dictionary) -> String:
	return "%s %d %s %s" % [ghost.hair, ghost.shoe, ghost.teeth, ghost.deep]
