class_name GuardTraits
extends RefCounted

## The six guards of the city museum (escena-museo.md, "Los guardias iguales"): the same grey uniform, cap and thick
## mustache, told apart by their own hair (under the cap), their glasses, the size of their shoes, their teeth and
## whether the mustache is their own (one or two are fake and come off). And all of them swear they were in the
## bathroom (escena-museo.md, "La coartada del baño"), each with one detail of it: the ones who really were there say
## a true one, the culprit and one or two more (asleep in the security room) a false one. The bathroom has three of
## the six details, drawn with the seed. Drawn with the case seed so every match has other guards. Pure data. Every
## number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Anselmo", "Beto", "Cirilo", "Dámaso", "Evaristo", "Fermín"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## How many of the six wear a fake mustache: at least one, at most two.
const FAKE_MUSTACHES := Vector2i(1, 2)
## What a guard can say about the bathroom: no paper, a fogged mirror, a broken dryer, a dripping tap, a spider on the
## ceiling, a smell of lavender. Three are true each match.
const DETAILS: Array[String] = ["paper", "mirror", "dryer", "tap", "spider", "lavender"]
const TRUE_DETAILS := 3
## How many lie besides the culprit: one or two.
const OTHER_LIARS := Vector2i(1, 2)


## The six guards for this seed, each a Dictionary with name, hair, glasses, shoe, teeth, mustache (true: his own,
## false: fake), liar (his alibi is false) and detail (what he says about the bathroom). No two are the same in
## everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("museum guards %d" % seed_value)
	var fakes := {}
	var fake_count := rng.randi_range(FAKE_MUSTACHES.x, FAKE_MUSTACHES.y)
	while fakes.size() < fake_count:
		fakes[rng.randi_range(0, COUNT - 1)] = true
	var liars := {CrimePlan.culprit_of(COUNT, seed_value): true}
	var liar_count := 1 + rng.randi_range(OTHER_LIARS.x, OTHER_LIARS.y)
	while liars.size() < liar_count:
		liars[rng.randi_range(0, COUNT - 1)] = true
	var true_details := bathroom(seed_value)
	var false_details := DETAILS.filter(func(d: String) -> bool: return not true_details.has(d))
	var guards: Array[Dictionary] = []
	var seen := {}
	while guards.size() < COUNT:
		var liar: bool = liars.has(guards.size())
		var said: Array = false_details if liar else true_details
		var guard := {
			"name": NAMES[guards.size()],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"mustache": not fakes.has(guards.size()),
			"liar": liar,
			"detail": said[rng.randi_range(0, said.size() - 1)],
		}
		var key := signature(guard)
		if not seen.has(key):
			seen[key] = true
			guards.append(guard)
	return guards


## The three details that are true in this match's bathroom.
static func bathroom(seed_value: int) -> Array[String]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("museum bathroom %d" % seed_value)
	var details: Array[String] = DETAILS.duplicate()
	for i in range(details.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := details[i]
		details[i] = details[j]
		details[j] = swap
	return details.slice(0, TRUE_DETAILS)


## Everything about a guard but his name and his alibi, to tell whether two are the same.
static func signature(guard: Dictionary) -> String:
	return "%s %s %d %s %s" % [guard.hair, guard.glasses, guard.shoe, guard.teeth, guard.mustache]
