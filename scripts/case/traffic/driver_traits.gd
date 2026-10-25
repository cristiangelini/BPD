class_name DriverTraits
extends RefCounted

## Who drives each car that comes to the traffic control (control-transito.md, "Revisar un auto"): a name for the
## license, the year on it, the absurd line they say when they're stopped and what's in the trunk. Drawn from the
## case seed. Names are made up and belong nowhere. Every number here is (propuesta).

const NAMES: Array[String] = ["Aurelio", "Benita", "Casimiro", "Dalia", "Eusebio", "Felisa", "Gumersindo", "Hilda",
	"Isidoro", "Jacinta", "Leandro", "Marcela"]
const SURNAMES: Array[String] = ["Bizcocho", "Tornillo", "Pomelo", "Calcetín", "Ventilador", "Pepino", "Cucharón",
	"Paraguas", "Membrillo", "Tetera", "Bigote", "Zapallo"]
## The lines they say when stopped: DRIVER_LINE_0 to _11.
const LINES := 12
## What's in the trunk, by weight: mostly bags, sometimes something odd, now and then a grandpa.
const TRUNKS := {"bags": 6, "contraband": 3, "grandpa": 1}


static func draw(rng: RandomNumberGenerator) -> Dictionary:
	var trunk := ""
	var roll := rng.randi_range(1, TRUNKS.values().reduce(func(a: int, b: int) -> int: return a + b))
	for kind: String in TRUNKS:
		roll -= TRUNKS[kind]
		if roll <= 0:
			trunk = kind
			break
	return {
		"name": NAMES[rng.randi() % NAMES.size()],
		"surname": SURNAMES[rng.randi() % SURNAMES.size()],
		"year": rng.randi_range(1950, 2004),
		"line": "DRIVER_LINE_%d" % (rng.randi() % LINES),
		"trunk": trunk,
	}


## What the license says. A clown's says how his photo looks, without makeup (control-payasos.md).
static func license_text(driver: Dictionary) -> String:
	var text := TranslationServer.translate("LICENSE_TEXT") % [driver.name, driver.surname, driver.year]
	if driver.has("license_glasses"):
		text += " " + TranslationServer.translate("LICENSE_PHOTO_GLASSES" if driver.license_glasses
			else "LICENSE_PHOTO_NO_GLASSES")
	return text
