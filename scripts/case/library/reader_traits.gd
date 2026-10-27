class_name ReaderTraits
extends RefCounted

## The six readers of the club "Los Ratones de Biblioteca" (escena-biblioteca.md, "Los seis lectores en pijama"): the
## same striped pajamas, nightcap, sleep mask and slippers, told apart by their own hair (under the nightcap), their
## glasses, the size of their slippers, their teeth, the gold dust on their hands (the culprit's and one or two more,
## who leafed through the Golden Book before sleeping) and the kind of book they read (one each). Drawn with the case
## seed so every match has other readers. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Abelardo", "Clotilde", "Facundo", "Hortensia", "Leopoldo", "Remedios"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## The kinds of book they read, one per reader, none repeated (GENRE_<id> is its name).
const GENRES: Array[String] = ["pirates", "ghosts", "cooking", "dinosaurs", "love", "detectives"]
## How many of the six have gold dust on their hands: at least two, at most three.
const DUSTED := Vector2i(2, 3)


## The six readers for this seed, each a Dictionary with name, hair, glasses, shoe, teeth, dust (bool) and genre. No
## two look the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("library readers %d" % seed_value)
	# The Golden Book's covers left their dust on whoever took it: the culprit always has it.
	var dusted := {CrimePlan.culprit_of(COUNT, seed_value): true}
	var dust_count := rng.randi_range(DUSTED.x, DUSTED.y)
	while dusted.size() < dust_count:
		dusted[rng.randi_range(0, COUNT - 1)] = true
	var genres: Array[String] = GENRES.duplicate()
	for i in range(genres.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = genres[i]
		genres[i] = genres[j]
		genres[j] = swap
	var readers: Array[Dictionary] = []
	var seen := {}
	while readers.size() < COUNT:
		var i := readers.size()
		var reader := {
			"name": NAMES[i],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"dust": dusted.has(i),
			"genre": genres[i],
		}
		var key := signature(reader)
		if not seen.has(key):
			seen[key] = true
			readers.append(reader)
	return readers


## Everything about a reader but the name and the book, to tell whether two look the same.
static func signature(reader: Dictionary) -> String:
	return "%s %s %d %s %s" % [reader.hair, reader.glasses, reader.shoe, reader.teeth, reader.dust]
