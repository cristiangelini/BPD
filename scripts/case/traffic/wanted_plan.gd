class_name WantedPlan
extends RefCounted

## Which car the traffic control is after and how to tell it (control-transito.md, "Cómo se reconoce al buscado").
## From the case seed: how many cars come (TOTAL), which one is the wanted car, its 3 clues and every other car, so
## that no other car fits all 3 clues and LOOKALIKES of them fit 2. The comisario gives the first clue and the radio
## one more every RADIO_EVERY seconds. Every number here is (propuesta).

const TOTAL := Vector2i(15, 25)
## The wanted car comes somewhere in this stretch of the queue.
const WANTED_AT := Vector2i(6, 14)
const LOOKALIKES := Vector2i(2, 3)
const CLUES := 3
const RADIO_EVERY := 60.0
## The car's paint, by its look (TrafficCar.MODELS): white, yellow, green and light blue.
const COLORS: Array[String] = ["COLOR_WHITE", "COLOR_YELLOW", "COLOR_GREEN", "COLOR_BLUE"]
const KINDS: Array[String] = ["color", "plate", "decade", "trunk"]
const LETTERS := "BCDFGHJKLMNPRSTVXZ"

var total := 0
var wanted_index := 0
## {kind, value}, in the order they're given.
var clues: Array[Dictionary] = []
## Every car that comes, in order: {look, plate, driver}.
var cars: Array[Dictionary] = []
var lookalikes: Array[int] = []


static func draw(case_seed: int) -> WantedPlan:
	var plan := WantedPlan.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["wanted plan", case_seed])
	plan.total = rng.randi_range(TOTAL.x, TOTAL.y)
	plan.wanted_index = rng.randi_range(WANTED_AT.x, WANTED_AT.y)
	var wanted := random_car(rng)
	var kinds := KINDS.duplicate()
	for i in CLUES:
		var kind: String = kinds.pop_at(rng.randi() % kinds.size())
		if kind == "trunk":
			wanted.driver.trunk = "contraband"
		plan.clues.append({"kind": kind, "value": value_of(wanted, kind)})
	var others: Array[int] = []
	for i in plan.total:
		if i != plan.wanted_index:
			others.append(i)
	for i in rng.randi_range(LOOKALIKES.x, LOOKALIKES.y):
		plan.lookalikes.append(others.pop_at(rng.randi() % others.size()))
	for i in plan.total:
		var car := wanted
		if i != plan.wanted_index:
			car = plan._other_car(rng, i in plan.lookalikes)
		plan.cars.append(car)
	return plan


static func random_car(rng: RandomNumberGenerator) -> Dictionary:
	var plate := ""
	for i in 3:
		plate += LETTERS[rng.randi() % LETTERS.length()]
	plate += " %03d" % rng.randi_range(0, 999)
	return {"look": rng.randi() % COLORS.size(), "plate": plate, "driver": DriverTraits.draw(rng)}


static func value_of(car: Dictionary, kind: String) -> Variant:
	match kind:
		"color":
			return car.look % COLORS.size()
		"plate":
			return int((car.plate as String).right(1))
		"decade":
			return int(car.driver.year) / 10 * 10
		"trunk":
			return car.driver.trunk
	return null


## How many of the clues a car fits.
func fits(car: Dictionary) -> int:
	return clues.filter(func(clue: Dictionary) -> bool: return value_of(car, clue.kind) == clue.value).size()


## A car that fits every clue but one if it's a lookalike, and at most one otherwise.
func _other_car(rng: RandomNumberGenerator, lookalike: bool) -> Dictionary:
	while true:
		var car := random_car(rng)
		if lookalike:
			# Copy all clues but one, then make sure that one is off.
			var off := rng.randi() % clues.size()
			for i in clues.size():
				if i != off:
					_set_value(car, clues[i])
		if (lookalike and fits(car) == CLUES - 1) or (not lookalike and fits(car) <= 1):
			return car
	return {}


func _set_value(car: Dictionary, clue: Dictionary) -> void:
	match clue.kind:
		"color":
			car.look = clue.value
		"plate":
			car.plate = (car.plate as String).left(-1) + str(clue.value)
		"decade":
			car.driver.year = int(clue.value) + int(car.driver.year) % 10
		"trunk":
			car.driver.trunk = clue.value


## How clue `i` reads, for the comisario, the radio and the HUD.
func clue_text(i: int) -> String:
	var clue := clues[i]
	match clue.kind:
		"color":
			return TranslationServer.translate("CLUE_TRAFFIC_COLOR") % TranslationServer.translate(COLORS[clue.value])
		"plate":
			return TranslationServer.translate("CLUE_TRAFFIC_PLATE") % clue.value
		"decade":
			return TranslationServer.translate("CLUE_TRAFFIC_DECADE") % clue.value
		"trunk":
			return TranslationServer.translate("CLUE_TRAFFIC_TRUNK")
	return ""


## How many clues the cops have `seconds` after the case starts: one from the comisario, then the radio.
static func known_at(seconds: float) -> int:
	return mini(1 + int(seconds / RADIO_EVERY), CLUES)
