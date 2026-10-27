class_name NephewTraits
extends RefCounted

## The six nephews of Señora Ofelia Monedero (escena-gato.md, "Los seis sobrinos iguales"): the same sweater their aunt
## knitted, the same wool beanie and scarf, told apart by their own hair (under the beanie), their glasses, the size of
## their shoes, their teeth, the scratch on one hand (the culprit's and one or two more, from the rose bush) and their
## catchphrase (one each, the one the parrot repeats). Drawn with the case seed so every match has other nephews. Pure
## data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Bautista", "Casimiro", "Delfina", "Eulalia", "Gaspar", "Ramona"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## The hands a scratch can be on; "" is none.
const HANDS: Array[String] = ["left", "right"]
## How many of the six have a scratch: at least two, at most three.
const SCRATCHED := Vector2i(2, 3)
## How many catchphrases there are (NEPHEW_TIC_0...): one per nephew, none repeated.
const TICS := 6


## The six nephews for this seed, each a Dictionary with name, hair, glasses, shoe, teeth, scratch ("left", "right"
## or "") and tic (the index of the catchphrase). No two are the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("mansion nephews %d" % seed_value)
	var scratched := {}
	var scratch_count := rng.randi_range(SCRATCHED.x, SCRATCHED.y)
	while scratched.size() < scratch_count:
		scratched[rng.randi_range(0, COUNT - 1)] = HANDS[rng.randi_range(0, HANDS.size() - 1)]
	var tics: Array[int] = []
	for i in TICS:
		tics.append(i)
	for i in range(TICS - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := tics[i]
		tics[i] = tics[j]
		tics[j] = swap
	var nephews: Array[Dictionary] = []
	var seen := {}
	while nephews.size() < COUNT:
		var i := nephews.size()
		var nephew := {
			"name": NAMES[i],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"scratch": scratched.get(i, ""),
			"tic": tics[i],
		}
		var key := signature(nephew)
		if not seen.has(key):
			seen[key] = true
			nephews.append(nephew)
	return nephews


## Everything about a nephew but the name and the catchphrase, to tell whether two look the same.
static func signature(nephew: Dictionary) -> String:
	return "%s %s %d %s %s" % [nephew.hair, nephew.glasses, nephew.shoe, nephew.teeth, nephew.scratch]
