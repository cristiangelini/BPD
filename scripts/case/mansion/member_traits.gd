class_name MemberTraits
extends RefCounted

## The six members of the Mystery Club at the mansion (escena-mansion.md, "Los socios iguales y sus fichas"): the same
## Detective Pipa costume, told apart by their own hair (under the cap), their glasses, the size of their shoes, their
## teeth and the room where they were at midnight (their alibi, one of Mansion.BELL_ROOMS; two can share one). Drawn
## with the case seed so every match has other members. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Aurelio", "Bárbara", "Casimiro", "Dorotea", "Eusebio", "Florinda"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX


## The six members for this seed, each a Dictionary with name, hair, glasses, shoe, teeth and room. No two are the same
## in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("mansion members %d" % seed_value)
	var members: Array[Dictionary] = []
	var seen := {}
	while members.size() < COUNT:
		var member := {
			"name": NAMES[members.size()],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"room": Mansion.BELL_ROOMS[rng.randi_range(0, Mansion.BELL_ROOMS.size() - 1)],
		}
		var key := signature(member)
		if not seen.has(key):
			seen[key] = true
			members.append(member)
	return members


## Everything about a member but the name, to tell whether two are the same.
static func signature(member: Dictionary) -> String:
	return "%s %s %d %s %s" % [member.hair, member.glasses, member.shoe, member.teeth, member.room]
