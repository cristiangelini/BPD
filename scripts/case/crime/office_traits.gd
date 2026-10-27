class_name OfficeTraits
extends RefCounted

## The six employees of Formularios Infinitos (escena-oficina.md, "Los empleados iguales"): the same grey suit, tie,
## briefcase and badge, told apart by their glasses, their shoe size, their teeth, their hair, how they take their
## coffee and the hand they hold the cup with. Pure data. Every number here is (propuesta).

const COUNT := 6
const NAMES: Array[String] = ["Anselmo", "Berta", "Cornelio", "Dorotea", "Evaristo", "Fermina"]
const HAIRS := CookTraits.HAIRS
const TEETH := CookTraits.TEETH
const SHOE_MIN := CookTraits.SHOE_MIN
const SHOE_MAX := CookTraits.SHOE_MAX
## How each one takes their coffee: what the coffee machine's screen says (COFFEE_<kind>).
const COFFEES: Array[String] = ["black", "milk", "cortado", "sugar"]


## The six employees for this seed, each a Dictionary with name, hair, glasses, shoe, teeth, left (left-handed) and
## coffee. No two are the same in everything.
static func draw(seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("office employees %d" % seed_value)
	var employees: Array[Dictionary] = []
	var seen := {}
	while employees.size() < COUNT:
		var employee := {
			"name": NAMES[employees.size()],
			"hair": HAIRS.keys()[rng.randi_range(0, HAIRS.size() - 1)],
			"glasses": rng.randf() < 0.5,
			"shoe": rng.randi_range(SHOE_MIN, SHOE_MAX),
			"teeth": TEETH[rng.randi_range(0, TEETH.size() - 1)],
			"left": rng.randf() < 0.5,
			"coffee": COFFEES[rng.randi_range(0, COFFEES.size() - 1)],
		}
		var key := signature(employee)
		if not seen.has(key):
			seen[key] = true
			employees.append(employee)
	return employees


## Everything about an employee but the name, to tell whether two are the same.
static func signature(employee: Dictionary) -> String:
	return "%s %s %d %s %s %s" % [employee.hair, employee.glasses, employee.shoe, employee.teeth, employee.left,
		employee.coffee]
