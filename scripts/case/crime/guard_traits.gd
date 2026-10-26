class_name GuardTraits
extends RefCounted

## The six guards of the city museum (escena-museo.md, "Los guardias iguales"): the same grey uniform, cap and thick
## mustache, told apart by their own hair (under the cap), their glasses, the size of their shoes, their teeth and
## whether the mustache is their own (one or two are fake and come off). Drawn with the case seed so every match has
## other guards. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Anselmo", "Beto", "Cirilo", "Dámaso", "Evaristo", "Fermín"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## How many of the six wear a fake mustache: at least one, at most two.
const FAKE_MUSTACHES := Vector2i(1, 2)


## The six guards for this seed, each a Dictionary with name, hair, glasses, shoe, teeth and mustache (true: his own,
## false: fake). No two are the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("museum guards %d" % seed_value)
	var fakes := {}
	var fake_count := rng.randi_range(FAKE_MUSTACHES.x, FAKE_MUSTACHES.y)
	while fakes.size() < fake_count:
		fakes[rng.randi_range(0, COUNT - 1)] = true
	var guards: Array[Dictionary] = []
	var seen := {}
	while guards.size() < COUNT:
		var guard := {
			"name": NAMES[guards.size()],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"mustache": not fakes.has(guards.size()),
		}
		var key := signature(guard)
		if not seen.has(key):
			seen[key] = true
			guards.append(guard)
	return guards


## Everything about a guard but his name, to tell whether two are the same.
static func signature(guard: Dictionary) -> String:
	return "%s %s %d %s %s" % [guard.hair, guard.glasses, guard.shoe, guard.teeth, guard.mustache]
