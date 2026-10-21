class_name CrimePlan
extends RefCounted

## Who stole the Torre de Merengue and which clues point to him (escena-del-crimen.md, "Las pistas"): the culprit and
## 4 of the 6 clues, drawn with the case seed so that together they leave only him. Pure data. Every number here is
## (propuesta).

const CLUES_PER_CASE := 4
## Each clue and the trait of the culprit it tells.
const CLUES := {
	"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "recipe": "left", "witness": "apron",
}

## Index of the culprit among the cooks.
var culprit := 0
## The clues of this case, in CLUES order.
var clues: Array[String] = []


## The plan for these cooks and seed.
static func draw(cooks: Array[Dictionary], seed_value: int) -> CrimePlan:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("crime plan %d" % seed_value)
	var plan := CrimePlan.new()
	plan.culprit = rng.randi_range(0, cooks.size() - 1)
	var sets := _sets(CLUES.keys(), CLUES_PER_CASE)
	# Shuffled with the seed; the first set that leaves only him. One with the prints always does.
	for i in range(sets.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: Array = sets[i]
		sets[i] = sets[j]
		sets[j] = swap
	for kinds: Array in sets:
		var left := suspects_left(cooks, cooks[plan.culprit], kinds)
		if left.size() == 1:
			plan.clues.assign(kinds)
			break
	return plan


## What a clue says: the culprit's value of its trait.
static func says(kind: String, culprit_cook: Dictionary) -> Variant:
	return culprit_cook[CLUES[kind]]


## Whether a cook fits a clue about the culprit.
static func fits(cook: Dictionary, kind: String, culprit_cook: Dictionary) -> bool:
	return cook[CLUES[kind]] == says(kind, culprit_cook)


## Indexes of the cooks that fit every one of these clues.
static func suspects_left(cooks: Array[Dictionary], culprit_cook: Dictionary, kinds: Array) -> Array[int]:
	var left: Array[int] = []
	for i in cooks.size():
		if kinds.all(func(kind: String) -> bool: return fits(cooks[i], kind, culprit_cook)):
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
