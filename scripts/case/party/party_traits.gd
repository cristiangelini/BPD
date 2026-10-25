class_name PartyTraits
extends RefCounted

## What tells the costume party's guests apart (infiltracion-fiesta.md, step 2b, decision 171): four bits of each
## costume, three ways each. The seed picks the boss and dresses everyone so that every other guest differs from the
## boss in at least two of the four: whichever three the clues tell (step 4), only the boss matches them all.

const KINDS: Array[String] = ["cap", "mustache", "badge", "glasses"]
const VALUES := {
	"cap": ["blue", "black", "white"],
	"mustache": ["thin", "handlebar", "bushy"],
	"badge": ["gold", "silver", "chocolate"],
	"glasses": ["sun", "heart", "none"],
}
## A guest's bits as models, by kind and value ("none" has no model).
const MODEL := "res://assets/models/party_trait_%s_%s.glb"
## Each other guest differs from the boss in at least this many of the kinds.
const DIFFER := 2


## The guests' costumes for `case_seed`: {"traits": [ {kind: value} for each guest ], "boss": index}.
static func draw(case_seed: int, count: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["party traits", case_seed])
	var boss := rng.randi_range(0, count - 1)
	var boss_traits := _random(rng)
	var traits: Array[Dictionary] = []
	for i in count:
		if i == boss:
			traits.append(boss_traits)
			continue
		var guest := _random(rng)
		while differences(guest, boss_traits) < DIFFER:
			guest = _random(rng)
		traits.append(guest)
	return {"traits": traits, "boss": boss}


## How many kinds two costumes differ in.
static func differences(a: Dictionary, b: Dictionary) -> int:
	var count := 0
	for kind: String in KINDS:
		count += int(a[kind] != b[kind])
	return count


## The guests (indexes) whose costume has every bit in `known` ({kind: value}).
static func matching(traits: Array[Dictionary], known: Dictionary) -> Array[int]:
	var found: Array[int] = []
	for i in traits.size():
		if known.keys().all(func(kind: String) -> bool: return traits[i][kind] == known[kind]):
			found.append(i)
	return found


## The models a guest wears for their costume.
static func models_of(guest: Dictionary) -> Array[PackedScene]:
	var scenes: Array[PackedScene] = []
	for kind: String in KINDS:
		if guest[kind] != "none":
			scenes.append(load(MODEL % [kind, guest[kind]]))
	return scenes


static func _random(rng: RandomNumberGenerator) -> Dictionary:
	var guest := {}
	for kind: String in KINDS:
		guest[kind] = VALUES[kind][rng.randi_range(0, VALUES[kind].size() - 1)]
	return guest
