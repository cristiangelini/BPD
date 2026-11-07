class_name StaffTraits
extends RefCounted

## The six coworkers of the station crime scene (escena-comisaria.md, "Los compañeros iguales"): the armero and the
## five of StationStaff, in the same uniform and cap, told apart by their shoe size, how many spoons of sugar they take
## in their coffee, their teeth, whether they're left-handed, their height and whether they limp. Last night they were
## in pairs, each pair somewhere in the station, and each one says where and with whom; the culprit and the coworker
## who covers for him (he owes him money) say they were together, and that pair is the lie. Drawn with the case seed so
## every match has other coworkers. Pure data. Every number here is (propuesta).

const COUNT := 6
## Who they are, in the case's order: their ids (StationStaff.WHO, and the armero).
const IDS: Array[String] = ["armero", "ronquido", "sellito", "mopa", "fritanga", "polilla"]
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
const SUGARS: Array[int] = [0, 1, 2, 5]
## How much taller or shorter than the others the tall and the short ones look.
const TALL_SCALE := 1.12
const SHORT_SCALE := 0.9
## Where a pair can say they were last night (STAFF_PLACE_<WHERE>).
const PLACES: Array[String] = ["break", "guard", "armory", "cells", "archive", "parking"]


## The six coworkers for this seed, each a Dictionary with id, name (their name key), shoe, sugar, teeth, left, tall,
## limp, silhouette (what the security tape shows: tall or short, and limping or not), with (the index of who they say
## they were with), where (where they say they were) and liar (the culprit and his cover). No two are the same in
## everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("station staff %d" % seed_value)
	var culprit := CrimePlan.culprit_of(COUNT, seed_value)
	var cover := (culprit + rng.randi_range(1, COUNT - 1)) % COUNT
	# The pairs: the culprit with his cover, and the other four two by two.
	var others: Array[int] = []
	for i in COUNT:
		if i != culprit and i != cover:
			others.append(i)
	for i in range(others.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := others[i]
		others[i] = others[j]
		others[j] = swap
	var pairs: Array = [[culprit, cover], [others[0], others[1]], [others[2], others[3]]]
	var places: Array[String] = PLACES.duplicate()
	for i in range(places.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := places[i]
		places[i] = places[j]
		places[j] = swap
	var with := {}
	var where := {}
	for p in pairs.size():
		var pair: Array = pairs[p]
		with[pair[0]] = pair[1]
		with[pair[1]] = pair[0]
		where[pair[0]] = places[p]
		where[pair[1]] = places[p]
	var staff: Array[Dictionary] = []
	var seen := {}
	while staff.size() < COUNT:
		var index := staff.size()
		var person := {
			"id": IDS[index],
			"name": name_key(IDS[index]),
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"sugar": SUGARS[rng.randi_range(0, SUGARS.size() - 1)],
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"left": rng.randf() < 0.5,
			"tall": rng.randf() < 0.5,
			"limp": rng.randf() < 0.35,
			"with": with[index],
			"where": where[index],
			"liar": index == culprit or index == cover,
		}
		person["silhouette"] = silhouette(person)
		var key := signature(person)
		if not seen.has(key):
			seen[key] = true
			staff.append(person)
	return staff


## The name key of a coworker by id (the armero's is his own).
static func name_key(id: String) -> String:
	return "STAFF_NAME_" + id.to_upper()


## What the security tape shows of someone: tall or short, limping or not.
static func silhouette(person: Dictionary) -> String:
	return ("tall" if person.tall else "short") + (" limp" if person.limp else "")


## Everything about a coworker but the name and the alibi, to tell whether two are the same.
static func signature(person: Dictionary) -> String:
	return "%d %d %s %s %s %s" % [person.shoe, person.sugar, person.teeth, person.left, person.tall, person.limp]
