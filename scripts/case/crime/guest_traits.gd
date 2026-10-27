class_name GuestTraits
extends RefCounted

## The six guests of the Hotel Gran Siesta (escena-hotel.md, "Los huéspedes iguales"): all in bathrobe, towel and
## cucumbers, told apart by their hair, their glasses, their shoe size, their teeth and whether they're left-handed.
## Each sleeps in one of the six guest rooms, drawn with the seed, and the concierge says who sleeps where: right for
## four and swapped for two, the culprit's room with another guest's (the culprit left him a tip). Pure data. Every
## number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Aurelio", "Bárbara", "Casimiro", "Delfina", "Eusebio", "Filomena"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX


## The six guests for this seed, each a Dictionary with name, hair, glasses, shoe, teeth, left (left-handed), room
## (where they really sleep) and said (the room the concierge says). No two are the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("hotel guests %d" % seed_value)
	var rooms: Array[int] = Hotel.GUEST_ROOMS.duplicate()
	for i in range(rooms.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := rooms[i]
		rooms[i] = rooms[j]
		rooms[j] = swap
	var culprit := CrimePlan.culprit_of(COUNT, seed_value)
	var other := (culprit + rng.randi_range(1, COUNT - 1)) % COUNT
	var guests: Array[Dictionary] = []
	var seen := {}
	while guests.size() < COUNT:
		var index := guests.size()
		var said := rooms[index]
		if index == culprit:
			said = rooms[other]
		elif index == other:
			said = rooms[culprit]
		var guest := {
			"name": NAMES[index],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"left": rng.randf() < 0.5,
			"room": rooms[index],
			"said": said,
		}
		var key := signature(guest)
		if not seen.has(key):
			seen[key] = true
			guests.append(guest)
	return guests


## The guest who really sleeps in a room, by index (-1 if nobody does).
static func sleeper(guests: Array[Dictionary], room: int) -> int:
	for i in guests.size():
		if guests[i].room == room:
			return i
	return -1


## Everything about a guest but the name and the rooms, to tell whether two are the same.
static func signature(guest: Dictionary) -> String:
	return "%s %s %d %s %s" % [guest.hair, guest.glasses, guest.shoe, guest.teeth, guest.left]
