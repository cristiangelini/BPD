class_name CarrierTraits
extends RefCounted

## The six mail carriers of the post office (escena-correo.md, "Los seis carteros"): the same cap, yellow vest, leather
## bag and gloves, told apart by their own hair (under the cap), shoe size, teeth, the blue tongue (the culprit's and
## one or two more, who licked old stamps that afternoon) and the route they cover (one each, on their bag's tag).
## Drawn with the case seed so every match has other carriers. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Anselmo", "Brígida", "Casimiro", "Dorotea", "Fermín", "Genoveva"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## The routes they cover, one per carrier, none repeated (the keys of PostOffice.ROUTE_BOXES; ROUTE_<id> is its name).
const ROUTES: Array[String] = ["red", "green", "yellow", "blue", "orange", "purple"]
## How many of the six have a blue tongue: at least two, at most three.
const BLUE := Vector2i(2, 3)


## The six carriers for this seed, each a Dictionary with name, hair, shoe, teeth, blue (bool) and route. No two look
## the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("post office carriers %d" % seed_value)
	# The culprit licked La Vaquita Azul to see if it was real: they always have it.
	var blue := {CrimePlan.culprit_of(COUNT, seed_value): true}
	var blue_count := rng.randi_range(BLUE.x, BLUE.y)
	while blue.size() < blue_count:
		blue[rng.randi_range(0, COUNT - 1)] = true
	var routes: Array[String] = ROUTES.duplicate()
	for i in range(routes.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: String = routes[i]
		routes[i] = routes[j]
		routes[j] = swap
	var carriers: Array[Dictionary] = []
	var seen := {}
	while carriers.size() < COUNT:
		var i := carriers.size()
		var carrier := {
			"name": NAMES[i],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"blue": blue.has(i),
			"route": routes[i],
		}
		var key := signature(carrier)
		if not seen.has(key):
			seen[key] = true
			carriers.append(carrier)
	return carriers


## Everything about a carrier but the name and the route, to tell whether two look the same.
static func signature(carrier: Dictionary) -> String:
	return "%s %d %s %s" % [carrier.hair, carrier.shoe, carrier.teeth, carrier.blue]
