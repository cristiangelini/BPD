class_name GuideTraits
extends RefCounted

## The six guides of the planetarium (escena-planetario.md, "Los seis guías"): the same white astronaut suit, helmet with
## the visor down, gloves and moon boots, told apart by their own hair (under the helmet), the size of their moon boots,
## their teeth, the glow paint on their gloves (the culprit's and one or two more, who painted stars that afternoon)
## and the planet they present in the show (one each, on a pin). Drawn with the case seed so every match has other
## guides. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Astor", "Celeste", "Estela", "Orión", "Selene", "Lucero"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## The planets they present, one per guide, none repeated (the keys of Planetarium.PLANET_SEATS; PLANET_<id> is its
## name).
const PLANETS: Array[String] = ["mercury", "venus", "mars", "jupiter", "saturn", "neptune"]
## How many of the six have glow paint on their gloves: at least two, at most three.
const GLOWING := Vector2i(2, 3)


## The six guides for this seed, each a Dictionary with name, hair, shoe, teeth, glow (bool) and planet. No two look the
## same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("planetarium guides %d" % seed_value)
	var glowing := {}
	var glow_count := rng.randi_range(GLOWING.x, GLOWING.y)
	while glowing.size() < glow_count:
		glowing[rng.randi_range(0, COUNT - 1)] = true
	var planets: Array[String] = PLANETS.duplicate()
	for i in range(planets.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = planets[i]
		planets[i] = planets[j]
		planets[j] = swap
	var guides: Array[Dictionary] = []
	var seen := {}
	while guides.size() < COUNT:
		var i := guides.size()
		var guide := {
			"name": NAMES[i],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"glow": glowing.has(i),
			"planet": planets[i],
		}
		var key := signature(guide)
		if not seen.has(key):
			seen[key] = true
			guides.append(guide)
	return guides


## Everything about a guide but the name and the planet, to tell whether two look the same.
static func signature(guide: Dictionary) -> String:
	return "%s %d %s %s" % [guide.hair, guide.shoe, guide.teeth, guide.glow]
