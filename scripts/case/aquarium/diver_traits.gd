class_name DiverTraits
extends RefCounted

## The six cleaning divers of the aquarium (escena-acuario.md, "Los seis buzos"): the same black wetsuit with a whale,
## hood, mask and flippers, told apart by their own hair (under the hood), the prescription lenses in their mask, the
## size of their flippers, their teeth, the octopus ink on their hands under the glove (the culprit's and one or two
## more, who fed Doña Tinta without care) and the tank they look after (one each). Drawn with the case seed so every
## match has other divers. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Arsenio", "Coral", "Delfino", "Marina", "Nemesio", "Perla"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## The tanks they look after, one per diver, none repeated (the keys of Aquarium.TANKS; CARE_<id> is its animals).
const TANKS: Array[String] = ["sharks", "jellyfish", "seahorses", "turtles", "rays", "penguins"]
## How many of the six have ink on their hands: at least two, at most three.
const INKED := Vector2i(2, 3)


## The six divers for this seed, each a Dictionary with name, hair, glasses, shoe, teeth, ink (bool) and tank. No two
## look the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("aquarium divers %d" % seed_value)
	var inked := {}
	var ink_count := rng.randi_range(INKED.x, INKED.y)
	while inked.size() < ink_count:
		inked[rng.randi_range(0, COUNT - 1)] = true
	var tanks: Array[String] = TANKS.duplicate()
	for i in range(tanks.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = tanks[i]
		tanks[i] = tanks[j]
		tanks[j] = swap
	var divers: Array[Dictionary] = []
	var seen := {}
	while divers.size() < COUNT:
		var i := divers.size()
		var diver := {
			"name": NAMES[i],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"ink": inked.has(i),
			"tank": tanks[i],
		}
		var key := signature(diver)
		if not seen.has(key):
			seen[key] = true
			divers.append(diver)
	return divers


## Everything about a diver but the name and the tank, to tell whether two look the same.
static func signature(diver: Dictionary) -> String:
	return "%s %s %d %s %s" % [diver.hair, diver.glasses, diver.shoe, diver.teeth, diver.ink]
