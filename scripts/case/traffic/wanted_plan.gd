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
## and a few packed cars carry almost as many (NEAR), so only counting tells them apart. In the ghost car control
## (control-auto-fantasma.md) one car has nobody at the wheel ("ghost") and the wanted one is its pilot's
## ("puppeteer"), a few cars behind it; the clues are about the pilot, his shirt too. In the wedding breathalyzer check
## (control-boda.md) the cars are the wedding's convoy ("guest", "tie", "newlyweds") with a few city cars, the wanted
## one is El Colado's: he blows 0.0, like the designated drivers, and toasts the wrong couple ("couple"). In the street
## race check (control-carrera.md) the queue's cars are all city cars and the wanted one is El Turbo, in one of the
## heats of racers ("racer", "race"); the clues are about his racer. In the fog check (control-neblina.md) every car
## has its headlights on ("fog"): the wanted one is La Bruma's, the lighthouse lamp in its trunk, and the clues are its
## paint, its headlights' color, its horn ("honk") and its broken headlight. In the circus move (control-circo.md) most
## cars are the circus's trucks with a caged animal ("circus", CircusTruck.draw's), a few city cars among them
## (an empty "circus"); the wanted one is El Peludo's, in a costume ("costume") with his sneakers showing, and the clues
## are the animal he looks like, his sneakers, his truck's stripes and its plate. In the parade (control-desfile.md)
## most cars are floats with masked dancers ("parade", ParadeFloat.draw's), a few city cars among them; the wanted one
## is the float El Antifaz dances on ("thief", his place on it), and the clues are its theme, his mask, what he holds
## and the last digit of its number. Every number here is (propuesta).

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
const GHOST_KINDS: Array[String] = ["color", "plate", "shirt", "decade"]
const GHOST_TOTAL := Vector2i(12, 16)
## What each of GhostCar.SHIRTS reads as.
const SHIRTS: Array[String] = ["COLOR_RED", "COLOR_BLUE", "COLOR_WHITE", "COLOR_GREEN", "COLOR_YELLOW", "COLOR_VIOLET"]
const WEDDING_KINDS: Array[String] = ["color", "plate", "tie", "decade"]
const WEDDING_TOTAL := Vector2i(12, 16)
const WEDDING_WANTED_AT := Vector2i(3, 10)
## Other guests who didn't drink and blow 0.0, like El Colado (control-boda.md, answer 1).
const DESIGNATED := Vector2i(2, 3)
## At least this many guests blow over the limit.
const DRUNK_MIN := 2
const RACE_KINDS: Array[String] = ["color", "number", "neon", "spoiler"]
const RACE_TOTAL := Vector2i(10, 14)
## El Turbo races in one of the middle heats (control-carrera.md, step 6: the 3rd, 4th or 5th), 0 first.
const TURBO_HEAT := Vector2i(2, 4)
const FOG_KINDS: Array[String] = ["color", "lights", "honk", "broken"]
const FOG_TOTAL := Vector2i(12, 16)
const FOG_WANTED_AT := Vector2i(4, 10)
const CIRCUS_KINDS: Array[String] = ["animal", "sneakers", "stripes", "plate"]
const CIRCUS_TOTAL := Vector2i(14, 20)
const CIRCUS_WANTED_AT := Vector2i(4, 10)
const PARADE_KINDS: Array[String] = ["theme", "mask", "held", "float_number"]
const PARADE_TOTAL := Vector2i(12, 18)
const PARADE_WANTED_AT := Vector2i(4, 10)
const LETTERS := "BCDFGHJKLMNPRSTVXZ"

## The clown convoy's plan: its cars carry their driver's ConvoyTraits under "clown".
var convoy := false
## The fruit truck control's plan: its cars carry FruitTraits under "fruit", with their watermelons' kinds.
var fruit := false
## The crowded car control's plan: its cars carry how many ride in them under "crowd".
var crowd := false
## The ghost car control's plan: its cars carry their driver's shirt, and whether they're the ghost or its pilot.
var ghost := false
var ghost_index := -1
## The wedding check's plan: which couple got married (WeddingCar.BRIDES and GROOMS), and where their car comes.
var wedding := false
var couple := 0
var newlyweds_index := -1
## The street race's plan: its heats of racers ({look, plate, driver, racer, race}), El Turbo's flagged "wanted".
var race := false
## The fog check's plan: every car's headlights and horn ("fog"), La Bruma's lamp in the wanted one's trunk.
var fog := false
## The circus move's plan: every car's circus traits ("circus"), El Peludo's in a costume.
var circus := false
## The parade's plan: every car's float ("parade"), El Antifaz on the wanted one ("thief").
var parade := false
var heats: Array[Array] = []
var turbo_heat := -1
var turbo_slot := -1
var total := 0
var wanted_index := 0
## {kind, value}, in the order they're given.
var clues: Array[Dictionary] = []
## Every car that comes, in order: {look, plate, driver}.
var cars: Array[Dictionary] = []
var lookalikes: Array[int] = []


static func draw(case_seed: int, convoy := false, fruit := false, crowd := false, ghost := false,
		wedding := false, race := false, fog := false, circus := false, parade := false) -> WantedPlan:
	var plan := WantedPlan.new()
	plan.circus = circus
	plan.parade = parade
	plan.race = race
	plan.fog = fog
	plan.wedding = wedding
	plan.convoy = convoy
	plan.fruit = fruit
	plan.crowd = crowd
	plan.ghost = ghost
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["wanted plan", case_seed])
	if race:
		plan._draw_race(rng)
		return plan
	var span := FRUIT_TOTAL if fruit else CROWD_TOTAL if crowd else GHOST_TOTAL if ghost \
		else WEDDING_TOTAL if wedding else FOG_TOTAL if fog else CIRCUS_TOTAL if circus \
		else PARADE_TOTAL if parade else TOTAL
	var wanted_at := FRUIT_WANTED_AT if fruit else CROWD_WANTED_AT if crowd \
		else WEDDING_WANTED_AT if wedding else FOG_WANTED_AT if fog else CIRCUS_WANTED_AT if circus \
		else PARADE_WANTED_AT if parade else WANTED_AT
	plan.total = rng.randi_range(span.x, span.y)
	if ghost:
		# The ghost car up front, its pilot a few cars behind.
		plan.ghost_index = rng.randi_range(GhostCar.AT.x, GhostCar.AT.y)
		plan.wanted_index = plan.ghost_index + rng.randi_range(GhostCar.PILOT_BEHIND.x, GhostCar.PILOT_BEHIND.y)
	else:
		plan.wanted_index = rng.randi_range(wanted_at.x, wanted_at.y)
	var wanted := random_car(rng, convoy, fruit, crowd, ghost, wedding, false, fog)
	if circus:
		# El Peludo, in one of the costumes a person fits, his sneakers showing; the jewels in his cage's straw.
		wanted.circus = CircusTruck.costume(rng)
		wanted.driver.trunk = "jewels"
	if parade:
		# El Antifaz dances on a float, one of its dancers; the queen's crown hidden in it.
		wanted.parade = ParadeFloat.draw(rng)
		wanted.parade.thief = rng.randi() % wanted.parade.dancers.size()
		wanted.driver.trunk = "crown"
	if fog:
		# La Bruma carries the lighthouse's lamp.
		wanted.driver.trunk = "lamp"
	if crowd:
		# The gang's headcount comes first, from the comisario.
		wanted.crowd = rng.randi_range(GANG.x, GANG.y)
		plan.clues.append({"kind": "riders", "value": wanted.crowd})
	if convoy:
		# The wanted clown carries the ringmaster's safe and someone else's license.
		wanted.driver.trunk = "safe"
		wanted.driver.license_glasses = not wanted.clown.glasses
	var kinds := (CONVOY_KINDS if convoy else FRUIT_KINDS if fruit else CROWD_KINDS if crowd
		else GHOST_KINDS if ghost else WEDDING_KINDS if wedding else FOG_KINDS if fog else CIRCUS_KINDS if circus
		else PARADE_KINDS if parade else KINDS).duplicate()
	for i in CLUES - plan.clues.size():
		var kind: String = kinds.pop_at(rng.randi() % kinds.size())
		if kind == "trunk":
			wanted.driver.trunk = "contraband"
		plan.clues.append({"kind": kind, "value": value_of(wanted, kind)})
	var others: Array[int] = []
	for i in plan.total:
		if i != plan.wanted_index and i != plan.ghost_index:
			others.append(i)
	for i in rng.randi_range(LOOKALIKES.x, LOOKALIKES.y):
		plan.lookalikes.append(others.pop_at(rng.randi() % others.size()))
	for i in plan.total:
		var car := wanted
		if i != plan.wanted_index:
			car = plan._other_car(rng, i in plan.lookalikes)
		plan.cars.append(car)
		if ghost:
			car.ghost = i == plan.ghost_index
			car.puppeteer = i == plan.wanted_index
	if fruit:
		# Only the wanted pickup's watermelons hide the watches; set after the others are drawn, off its own rng.
		for i in plan.total:
			var car: Dictionary = plan.cars[i]
			var hollow := rng.randi_range(FruitTraits.HOLLOW.x, FruitTraits.HOLLOW.y) if i == plan.wanted_index else 0
			car.fruit = car.fruit.duplicate()
			car.fruit.melons = FruitTraits.melon_kinds(rng, QueueCar.melon_count(car.plate), hollow)
	if wedding:
		plan._seat_the_wedding(rng)
	if crowd:
		# A few more packed cars, not lookalikes, with almost the gang's headcount.
		for n in rng.randi_range(NEAR.x, NEAR.y):
			var car: Dictionary = plan.cars[others.pop_at(rng.randi() % others.size())]
			car.crowd = plan.clues[0].value + NEAR_OFF[rng.randi() % NEAR_OFF.size()]
	return plan


static func random_car(rng: RandomNumberGenerator, convoy := false, fruit := false, crowd := false,
		ghost := false, wedding := false, racer := false, fog := false, circus := false, parade := false) -> Dictionary:
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
	if ghost:
		car.shirt = rng.randi() % SHIRTS.size()
	if wedding:
		car.guest = true
		car.tie = rng.randi() % SHIRTS.size()
	if racer:
		car.racer = true
		car.race = RaceCar.draw(rng)
	if fog:
		car.fog = FogCar.draw(rng)
	if circus:
		car.circus = CircusTruck.draw(rng) if rng.randf() < CircusTruck.SHARE else {}
	if parade:
		car.parade = ParadeFloat.draw(rng) if rng.randf() < ParadeFloat.SHARE else {}
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
		"shirt":
			return car.shirt
		"tie":
			return car.get("tie", -1)
		"number", "neon", "spoiler":
			return car.race[kind] if car.has("race") else -1
		"lights", "broken":
			return car.fog[kind] if car.has("fog") else -1
		"honk":
			return car.fog.horn if car.has("fog") else -1
		"animal":
			return car.get("circus", {}).get("animal", "")
		"sneakers", "stripes":
			return car.get("circus", {}).get(kind, -1)
		"theme":
			return car.get("parade", {}).get("theme", "")
		"float_number":
			return int(car.parade.number) % 10 if car.get("parade", {}).has("number") else -1
		"mask", "held":
			var dancer := ParadeFloat.compared(car.get("parade", {}))
			return dancer.get(kind, -1)
	return null


## How many of the clues a car fits. A float without El Antifaz fits as much as its best fitting dancer does.
func fits(car: Dictionary) -> int:
	var float_traits: Dictionary = car.get("parade", {})
	if float_traits.is_empty() or float_traits.has("thief"):
		return _fits(car)
	var best := 0
	var compared: int = float_traits.get("double", 0)
	for i in float_traits.dancers.size():
		float_traits.double = i
		best = maxi(best, _fits(car))
	float_traits.double = compared
	return best


func _fits(car: Dictionary) -> int:
	return clues.filter(func(clue: Dictionary) -> bool: return value_of(car, clue.kind) == clue.value).size()


## A car that fits every clue but one if it's a lookalike, and at most one otherwise.
func _other_car(rng: RandomNumberGenerator, lookalike: bool) -> Dictionary:
	while true:
		var car := random_car(rng, convoy, fruit, crowd, ghost, wedding, race, fog, circus, parade)
		# The circus's lookalikes are its trucks, real animals: never his sneakers.
		if circus and lookalike and car.circus.is_empty():
			continue
		# The parade's are floats, with one dancer who looks like him.
		if parade and lookalike:
			if car.parade.is_empty():
				continue
			car.parade.double = rng.randi() % car.parade.dancers.size()
		if lookalike:
			# Copy all clues but one, then make sure that one is off.
			var off := rng.randi() % clues.size()
			if circus:
				var sneakers := clues.map(func(clue: Dictionary) -> String: return clue.kind).find("sneakers")
				if sneakers >= 0:
					off = sneakers
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
		"shirt":
			car.shirt = clue.value
		"tie":
			car.tie = clue.value
		"number", "neon", "spoiler":
			car.race[clue.kind] = clue.value
		"lights", "broken":
			car.fog[clue.kind] = clue.value
		"honk":
			car.fog.horn = clue.value
		"animal", "stripes":
			car.circus[clue.kind] = clue.value
		"theme":
			car.parade.theme = clue.value
		"float_number":
			var tens := int(car.parade.number) / 10 * 10
			car.parade.number = tens + int(clue.value) if tens + int(clue.value) > 0 else 10
		"mask", "held":
			ParadeFloat.compared(car.parade)[clue.kind] = clue.value


## The wedding's convoy (control-boda.md): the couple, their car up front, a few city cars (never El Colado's or the
## lookalikes'), what each driver blows, El Colado and the designated drivers at 0.0, and the couple each one toasts.
func _seat_the_wedding(rng: RandomNumberGenerator) -> void:
	couple = rng.randi() % WeddingCar.BRIDES.size()
	# Up front, and never a lookalike: its white paint mustn't make it fit every clue.
	var fronts: Array[int] = []
	for i in total:
		if i != wanted_index and not i in lookalikes:
			fronts.append(i)
	newlyweds_index = fronts[rng.randi() % mini(WeddingCar.NEWLYWEDS_AT, fronts.size())]
	var guests: Array[int] = []
	for i in total:
		var car: Dictionary = cars[i]
		car.newlyweds = i == newlyweds_index
		car.couple = couple
		if car.newlyweds:
			car.look = WeddingCar.NEWLYWEDS_LOOK
		elif i != wanted_index and not i in lookalikes and rng.randi() % WeddingCar.CITY_EVERY == 0:
			car.guest = false
			car.tie = -1
		car.alcohol = WeddingCar.drink(rng) if car.guest else 0.0
		if car.guest and i != wanted_index and not car.newlyweds:
			guests.append(i)
	# El Colado wasn't at the party: sober, and he gets the couple wrong.
	var wanted: Dictionary = cars[wanted_index]
	wanted.alcohol = 0.0
	wanted.driver = (wanted.driver as Dictionary).duplicate()
	wanted.driver.trunk = "envelopes"
	wanted.couple = (couple + 1 + rng.randi() % (WeddingCar.BRIDES.size() - 1)) % WeddingCar.BRIDES.size()
	for n in mini(rng.randi_range(DESIGNATED.x, DESIGNATED.y), guests.size()):
		(cars[guests.pop_at(rng.randi() % guests.size())] as Dictionary).alcohol = 0.0
	# Always a few keys to take.
	var drunk := guests.filter(func(i: int) -> bool: return cars[i].alcohol > WeddingCar.DRUNK_ABOVE)
	guests = guests.filter(func(i: int) -> bool: return cars[i].alcohol <= WeddingCar.DRUNK_ABOVE)
	while drunk.size() < DRUNK_MIN and not guests.is_empty():
		var i: int = guests.pop_at(rng.randi() % guests.size())
		cars[i].alcohol = snappedf(WeddingCar.DRUNK_ABOVE + 0.1 + float(rng.randi() % 15) / 10.0, 0.1)
		drunk.append(i)


## The street race (control-carrera.md): the queue's city cars, then the heats of racers with El Turbo in one of the
## middle ones, his 3 clues, LOOKALIKES racers that fit 2 and the other racers at most 1.
func _draw_race(rng: RandomNumberGenerator) -> void:
	total = rng.randi_range(RACE_TOTAL.x, RACE_TOTAL.y)
	wanted_index = -1
	for i in total:
		cars.append(random_car(rng))
	var sizes: Array[int] = []
	for i in rng.randi_range(RaceCar.HEATS.x, RaceCar.HEATS.y):
		sizes.append(rng.randi_range(RaceCar.HEAT_SIZE.x, RaceCar.HEAT_SIZE.y))
	turbo_heat = rng.randi_range(TURBO_HEAT.x, mini(TURBO_HEAT.y, sizes.size() - 1))
	turbo_slot = rng.randi() % sizes[turbo_heat]
	var turbo := random_car(rng, false, false, false, false, false, true)
	turbo.wanted = true
	turbo.driver.trunk = "trophy"
	var kinds := RACE_KINDS.duplicate()
	for i in CLUES:
		var kind: String = kinds.pop_at(rng.randi() % kinds.size())
		clues.append({"kind": kind, "value": value_of(turbo, kind)})
	# The other racers, by their place in the heats, the lookalikes among them.
	var others := 0
	for size in sizes:
		others += size
	others -= 1
	var spots: Array[int] = []
	spots.assign(range(others))
	for i in rng.randi_range(LOOKALIKES.x, LOOKALIKES.y):
		lookalikes.append(spots.pop_at(rng.randi() % spots.size()))
	var n := 0
	for heat in sizes.size():
		var racers: Array[Dictionary] = []
		for slot in sizes[heat]:
			if heat == turbo_heat and slot == turbo_slot:
				racers.append(turbo)
				continue
			racers.append(_other_car(rng, n in lookalikes))
			n += 1
		heats.append(racers)


## El Turbo's racer.
func turbo() -> Dictionary:
	return heats[turbo_heat][turbo_slot] if turbo_heat >= 0 else {}


## The other guests the designated drivers are among: guests who blow 0.0 but aren't El Colado.
func designated() -> Array[int]:
	var out: Array[int] = []
	for i in total:
		if i != wanted_index and cars[i].get("guest", false) and cars[i].get("alcohol", -1.0) == 0.0:
			out.append(i)
	return out


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
		"shirt":
			return TranslationServer.translate("CLUE_GHOST_SHIRT") % TranslationServer.translate(SHIRTS[clue.value])
		"tie":
			return TranslationServer.translate("CLUE_WEDDING_TIE") % TranslationServer.translate(SHIRTS[clue.value])
		"number":
			return TranslationServer.translate("CLUE_RACE_NUMBER") % clue.value
		"neon":
			return TranslationServer.translate("CLUE_RACE_NEON") \
				% TranslationServer.translate(RaceCar.NEON_NAMES[clue.value])
		"spoiler":
			return TranslationServer.translate("CLUE_RACE_SPOILER") \
				% TranslationServer.translate(RaceCar.SPOILERS[clue.value])
		"lights":
			return TranslationServer.translate("CLUE_FOG_LIGHTS") \
				% TranslationServer.translate(FogCar.LIGHT_NAMES[clue.value])
		"honk":
			return TranslationServer.translate("CLUE_FOG_HONK") \
				% TranslationServer.translate(FogCar.horn_text(clue.value))
		"broken":
			return TranslationServer.translate("CLUE_FOG_BROKEN") \
				% TranslationServer.translate(FogCar.BROKEN[clue.value])
		"animal":
			return TranslationServer.translate("CLUE_CIRCUS_ANIMAL") \
				% TranslationServer.translate(CircusTruck.animal_name(clue.value))
		"sneakers":
			return TranslationServer.translate("CLUE_CIRCUS_SNEAKERS") \
				% TranslationServer.translate(CircusTruck.SNEAKER_NAMES[clue.value])
		"stripes":
			return TranslationServer.translate("CLUE_CIRCUS_STRIPES") \
				% TranslationServer.translate(CircusTruck.STRIPE_NAMES[clue.value])
		"theme":
			return TranslationServer.translate("CLUE_PARADE_THEME") \
				% TranslationServer.translate(ParadeFloat.theme_name(clue.value))
		"mask":
			return TranslationServer.translate("CLUE_PARADE_MASK") \
				% TranslationServer.translate(ParadeFloat.MASK_NAMES[clue.value])
		"held":
			return TranslationServer.translate("CLUE_PARADE_HELD") \
				% TranslationServer.translate(ParadeFloat.HELD_NAMES[clue.value])
		"float_number":
			return TranslationServer.translate("CLUE_PARADE_NUMBER") % clue.value
	return ""


## How many clues the cops have `seconds` after the case starts: one from the comisario, then the radio.
static func known_at(seconds: float) -> int:
	return mini(1 + int(seconds / RADIO_EVERY), CLUES)
