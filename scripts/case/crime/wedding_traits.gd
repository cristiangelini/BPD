class_name WeddingTraits
extends RefCounted

## Tito and his five groomsmen (escena-boda.md, "Los seis trajes iguales"): the same rented tuxedo, top hat and slicked
## hair, told apart by their own hair (under the hat), their glasses, the size of their shoes, their teeth and their
## cologne (lavender, lemon or cinnamon). Tito, always the first, wears a white carnation and the groomsmen a red one.
## One of the six won't take off the top hat until he gets something to eat. Drawn with the case seed so every match has
## other suspects. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Tito", "Ramiro", "Saúl", "Teodoro", "Ulises", "Valentín"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
const COLOGNES: Array[String] = ["lavender", "lemon", "cinnamon"]
## Tito's index: the one with the white carnation.
const GROOM := 0


## The six for this seed, each a Dictionary with name, hair, glasses, shoe, teeth, cologne, groom (Tito) and stubborn
## (keeps the top hat on until fed). No two are the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("wedding tuxedos %d" % seed_value)
	var stubborn := rng.randi_range(0, COUNT - 1)
	var suspects: Array[Dictionary] = []
	var seen := {}
	while suspects.size() < COUNT:
		var suspect := {
			"name": NAMES[suspects.size()],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"cologne": COLOGNES[rng.randi_range(0, COLOGNES.size() - 1)],
			"groom": suspects.size() == GROOM,
			"stubborn": suspects.size() == stubborn,
		}
		var key := signature(suspect)
		if not seen.has(key):
			seen[key] = true
			suspects.append(suspect)
	return suspects


## Everything about a suspect but his name, to tell whether two are the same.
static func signature(suspect: Dictionary) -> String:
	return "%s %s %d %s %s" % [suspect.hair, suspect.glasses, suspect.shoe, suspect.teeth, suspect.cologne]
