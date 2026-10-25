class_name WantedPlan
extends RefCounted

## Which car the traffic control is after and how to tell it (control-transito.md, "Cómo se reconoce al buscado").
## From the case seed: how many cars come (TOTAL), which one is the wanted car, its 3 clues and every other car, so
## that no other car fits all 3 clues and LOOKALIKES of them fit 2. The comisario gives the first clue and the radio
## one more every RADIO_EVERY seconds. In the clown convoy (control-payasos.md) every car is the same clown car, so
## the clues are on its driver (ConvoyTraits) instead. In the fruit truck control (control-frutas.md) fewer pickups come,
## and the clues are its color, the name on its sign, its crate and its fruit seller's hat (FruitTraits); the wanted
## one's hollow watermelons hide the gold watches. In the crowded car control (control-auto-lleno.md) every car carries
## how many ride in it under "crowd": the comisario's clue is always the gang's headcount, the radio's are about the car,
## and a few packed cars carry almost as many (NEAR), so only counting tells them apart. Every number here is (propuesta).

const TOTAL := Vector2i(15, 25)
## The wanted car comes somewhere in this stretch of the queue.
const WANTED_AT := Vector2i(6, 14)
const LOOKALIKES := Vector2i(2, 3)
const CLUES := 3
const RADIO_EVERY := 60.0
## The car's paint, by its look (TrafficCar.MODELS): white, yellow, green and light blue.
const COLORS: Array[String] = ["COLOR_WHITE", "COLOR_YELLOW", "COLOR_GREEN", "COLOR_BLUE"]
const KINDS: Array[String] = ["color", "plate", "decade", "trunk"]
const CONVOY_KINDS: Array[String] = ["wig", "nose", "gloves", "horn"]
const FRUIT_KINDS: Array[String] = ["color", "sign", "crate", "hat"]
const FRUIT_TOTAL := Vector2i(10, 14)
const FRUIT_WANTED_AT := Vector2i(4, 9)
const CROWD_KINDS: Array[String] = ["color", "plate", "decade"]
const CROWD_TOTAL := Vector2i(12, 16)
const CROWD_WANTED_AT := Vector2i(4, 10)
## How many the gang are, all in the one car.
const GANG := Vector2i(14, 20)
## Packed cars off the gang's headcount by one or two.
const NEAR := Vector2i(2, 3)
const NEAR_OFF: Array[int] = [-2, -1, 1, 2]
const LETTERS := "BCDFGHJKLMNPRSTVXZ"

## The clown convoy's plan: its cars carry their driver's ConvoyTraits under "clown".
var convoy := false
## The fruit truck control's plan: its cars carry FruitTraits under "fruit", with their watermelons' kinds.
var fruit := false
## The crowded car control's plan: its cars carry how many ride in them under "crowd".
var crowd := false
var total := 0
var wanted_index := 0
## {kind, value}, in the order they're given.
var clues: Array[Dictionary] = []
## Every car that comes, in order: {look, plate, driver}.
var cars: Array[Dictionary] = []
var lookalikes: Array[int] = []


static func draw(case_seed: int, convoy := false, fruit := false, crowd := false) -> WantedPlan:
	var plan := WantedPlan.new()
	plan.convoy = convoy
	plan.fruit = fruit
	plan.crowd = crowd
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["wanted plan", case_seed])
	var span := FRUIT_TOTAL if fruit else CROWD_TOTAL if crowd else TOTAL
	var wanted_at := FRUIT_WANTED_AT if fruit else CROWD_WANTED_AT if crowd else WANTED_AT
	plan.total = rng.randi_range(span.x, span.y)
	plan.wanted_index = rng.randi_range(wanted_at.x, wanted_at.y)
	var wanted := random_car(rng, convoy, fruit, crowd)
	if crowd:
		# The gang's headcount comes first, from the comisario.
		wanted.crowd = rng.randi_range(GANG.x, GANG.y)
		plan.clues.append({"kind": "riders", "value": wanted.crowd})
	if convoy:
		# The wanted clown carries the ringmaster's safe and someone else's license.
		wanted.driver.trunk = "safe"
		wanted.driver.license_glasses = not wanted.clown.glasses
	var kinds := (CONVOY_KINDS if convoy else FRUIT_KINDS if fruit else CROWD_KINDS if crowd else KINDS).duplicate()
	for i in CLUES - plan.clues.size():
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
	if fruit:
		# Only the wanted pickup's watermelons hide the watches; set after the others are drawn, off its own rng.
		for i in plan.total:
			var car: Dictionary = plan.cars[i]
			var hollow := rng.randi_range(FruitTraits.HOLLOW.x, FruitTraits.HOLLOW.y) if i == plan.wanted_index else 0
			car.fruit = car.fruit.duplicate()
			car.fruit.melons = FruitTraits.melon_kinds(rng, QueueCar.melon_count(car.plate), hollow)
	if crowd:
		# A few more packed cars, not lookalikes, with almost the gang's headcount.
		for n in rng.randi_range(NEAR.x, NEAR.y):
			var car: Dictionary = plan.cars[others.pop_at(rng.randi() % others.size())]
			car.crowd = plan.clues[0].value + NEAR_OFF[rng.randi() % NEAR_OFF.size()]
	return plan


static func random_car(rng: RandomNumberGenerator, convoy := false, fruit := false, crowd := false) -> Dictionary:
	var plate := ""
	for i in 3:
		plate += LETTERS[rng.randi() % LETTERS.length()]
	plate += " %03d" % rng.randi_range(0, 999)
	var car := {"look": rng.randi() % COLORS.size(), "plate": plate, "driver": DriverTraits.draw(rng)}
	if convoy:
		car.clown = ConvoyTraits.draw(rng)
		car.driver.trunk = ConvoyTraits.trunk(rng)
		# His license's photo, without makeup: his own, glasses and all.
		car.driver.license_glasses = car.clown.glasses
	if fruit:
		car.fruit = FruitTraits.draw(rng)
		# A pickup has no trunk to hide anything in.
		car.driver.trunk = "bags"
	if crowd:
		car.crowd = CrowdedCar.riders_of(plate)
	return car


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
		"wig", "nose", "gloves", "horn":
			return car.clown[kind]
		"sign":
			return car.driver.name
		"crate", "hat":
			return car.fruit[kind]
		"riders":
			return car.crowd
	return null


## How many of the clues a car fits.
func fits(car: Dictionary) -> int:
	return clues.filter(func(clue: Dictionary) -> bool: return value_of(car, clue.kind) == clue.value).size()


## A car that fits every clue but one if it's a lookalike, and at most one otherwise.
func _other_car(rng: RandomNumberGenerator, lookalike: bool) -> Dictionary:
	while true:
		var car := random_car(rng, convoy, fruit, crowd)
		if lookalike:
			# Copy all clues but one, then make sure that one is off.
			var off := rng.randi() % clues.size()
			for i in clues.size():
				if i != off:
					_set_value(car, clues[i])
			if clues[off].kind == "riders":
				# Packed too, but one or two off the gang's headcount.
				car.crowd = clues[off].value + NEAR_OFF[rng.randi() % NEAR_OFF.size()]
		# Only lookalikes ride exactly as many as the gang.
		if crowd and not lookalike and car.crowd == clues[0].value:
			continue
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
		"wig", "nose", "gloves", "horn":
			car.clown[clue.kind] = clue.value
		"sign":
			car.driver.name = clue.value
		"crate", "hat":
			car.fruit[clue.kind] = clue.value
		"riders":
			car.crowd = clue.value


## How clue `i` reads, for the comisario, the radio and the HUD.
func clue_text(i: int) -> String:
	var clue := clues[i]
	match clue.kind:
		"color":
			return TranslationServer.translate("CLUE_FRUIT_COLOR" if fruit else "CLUE_TRAFFIC_COLOR") \
				% TranslationServer.translate(COLORS[clue.value])
		"plate":
			return TranslationServer.translate("CLUE_TRAFFIC_PLATE") % clue.value
		"decade":
			return TranslationServer.translate("CLUE_TRAFFIC_DECADE") % clue.value
		"trunk":
			return TranslationServer.translate("CLUE_TRAFFIC_TRUNK")
		"wig", "nose", "gloves":
			return TranslationServer.translate("CLUE_CONVOY_" + (clue.kind as String).to_upper()) \
				% TranslationServer.translate(clue.value)
		"horn":
			return TranslationServer.translate("CLUE_CONVOY_HORN") \
				% TranslationServer.translate(ConvoyTraits.horn_text({"horn": clue.value}))
		"sign":
			return TranslationServer.translate("CLUE_FRUIT_SIGN") \
				% (TranslationServer.translate("FRUIT_SIGN") % clue.value)
		"crate":
			return TranslationServer.translate("CLUE_FRUIT_CRATE") \
				% TranslationServer.translate(FruitTraits.crate_text(clue.value))
		"hat":
			return TranslationServer.translate("CLUE_FRUIT_HAT") \
				% TranslationServer.translate(FruitTraits.hat_text(clue.value))
		"riders":
			return TranslationServer.translate("CLUE_CROWD_RIDERS") % clue.value
	return ""


## How many clues the cops have `seconds` after the case starts: one from the comisario, then the radio.
static func known_at(seconds: float) -> int:
	return mini(1 + int(seconds / RADIO_EVERY), CLUES)
