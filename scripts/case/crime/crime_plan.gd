class_name CrimePlan
extends RefCounted

## Who did it and which clues point to him (escena-del-crimen.md, "Las pistas"): the culprit and 4 of the 6 clues,
## drawn with the case seed so that together they leave only him. Each variant says which trait each clue tells
## (CLUES for the pastry; CrimeSceneCase.VARIANTS). Pure data. Every number here is (propuesta).

const CLUES_PER_CASE := 4
## Each clue of the pastry case and the trait of the culprit it tells.
const CLUES := {
	"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "recipe": "left", "witness": "apron",
}

## Index of the culprit among the cooks.
var culprit := 0
## The clues of this case, in the order of `traits`.
var clues: Array[String] = []
## Each clue this variant can have and the trait it tells.
var traits := CLUES


## The plan for these suspects and seed, with the clues of a variant (the pastry's by default).
static func draw(cooks: Array[Dictionary], seed_value: int, clue_traits: Dictionary = CLUES) -> CrimePlan:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("crime plan %d" % seed_value)
	var plan := CrimePlan.new()
	plan.traits = clue_traits
	# The first draw of the seed, like culprit_of.
	plan.culprit = rng.randi_range(0, cooks.size() - 1)
	var sets := _sets(clue_traits.keys(), CLUES_PER_CASE)
	# Shuffled with the seed; the first set that leaves only him. One with the prints always does.
	for i in range(sets.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: Array = sets[i]
		sets[i] = sets[j]
		sets[j] = swap
	for kinds: Array in sets:
		var left := suspects_left(cooks, cooks[plan.culprit], kinds, clue_traits)
		if left.size() == 1:
			plan.clues.assign(kinds)
			break
	return plan


## Who the culprit will be among `count` suspects for this seed, before their traits are drawn (the museum's guards
## need it: the culprit always lies about the bathroom).
static func culprit_of(count: int, seed_value: int) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("crime plan %d" % seed_value)
	return rng.randi_range(0, count - 1)


## What a clue says: the culprit's value of its trait.
static func says(kind: String, culprit_cook: Dictionary, clue_traits: Dictionary = CLUES) -> Variant:
	return culprit_cook[clue_traits[kind]]


## Whether a suspect fits a clue about the culprit.
static func fits(cook: Dictionary, kind: String, culprit_cook: Dictionary, clue_traits: Dictionary = CLUES) -> bool:
	return cook[clue_traits[kind]] == says(kind, culprit_cook, clue_traits)


## Indexes of the suspects that fit every one of these clues.
static func suspects_left(cooks: Array[Dictionary], culprit_cook: Dictionary, kinds: Array,
		clue_traits: Dictionary = CLUES) -> Array[int]:
	var left: Array[int] = []
	for i in cooks.size():
		if kinds.all(func(kind: String) -> bool: return fits(cooks[i], kind, culprit_cook, clue_traits)):
			left.append(i)
	return left


## Every way of taking `count` of `items`, keeping their order.
static func _sets(items: Array, count: int) -> Array[Array]:
	if count == 0:
		return [[]]
	var all: Array[Array] = []
	for i in range(items.size() - count + 1):
		for rest: Array in _sets(items.slice(i + 1), count - 1):
			all.append([items[i]] + rest)
	return all
