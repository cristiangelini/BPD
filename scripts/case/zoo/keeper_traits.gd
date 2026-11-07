class_name KeeperTraits
extends RefCounted

## The six keepers of the Zoológico Municipal (escena-zoo.md, "Los seis cuidadores"): the same green overalls, rubber
## boots, gloves and cap, told apart by their own hair (under the cap), boot size, teeth, a peck on the hand (the
## culprit's and one or two more, pecked by Don Pico) and the smell of the food of the animal they look after (one
## each). Drawn with the case seed so every match has other keepers. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Anselmo", "Brígida", "Cosme", "Dalila", "Ezequiel", "Filomena"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## The smells, one per keeper, none repeated: the food of the animal each looks after.
const SMELLS: Array[String] = ["fish", "banana", "grass", "lettuce", "peanut", "insects"]
## How many of the six have a band-aid from a peck: at least two, at most three.
const PECKED := Vector2i(2, 3)


## The six keepers for this seed, each a Dictionary with name, hair, shoe, teeth, pecked (bool) and smell. No two look
## the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("zoo keepers %d" % seed_value)
	var pecked := {}
	var pecked_count := rng.randi_range(PECKED.x, PECKED.y)
	while pecked.size() < pecked_count:
		pecked[rng.randi_range(0, COUNT - 1)] = true
	var smells: Array[String] = SMELLS.duplicate()
	for i in range(smells.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = smells[i]
		smells[i] = smells[j]
		smells[j] = swap
	var keepers: Array[Dictionary] = []
	var seen := {}
	while keepers.size() < COUNT:
		var i := keepers.size()
		var keeper := {
			"name": NAMES[i],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"pecked": pecked.has(i),
			"smell": smells[i],
		}
		var key := signature(keeper)
		if not seen.has(key):
			seen[key] = true
			keepers.append(keeper)
	return keepers


## Everything about a keeper but the name and the smell, to tell whether two look the same.
static func signature(keeper: Dictionary) -> String:
	return "%s %d %s %s" % [keeper.hair, keeper.shoe, keeper.teeth, keeper.pecked]
