class_name RadioRig
extends StoryRig

## The pirate radio (historias.md): the grandpa broadcasts radio soap operas from a transmitter too heavy for one
## cop. Holding the cop radio (T) crackles with static all over the house, and the closer the transmitter, the louder.

## Evidence order in radio_story.tres: the transmitter.
const TRANSMITTER := 0
## Static bars go from 1 anywhere (the interference) to 5 right next to the transmitter (propuesta).
const MAX_BARS := 5
const BASE_BARS := 1
## Further than this the static is just the interference (propuesta).
const STATIC_RANGE := 15.0

var listener: RadioStatic


func setup(house: GrandpaHouse) -> void:
	listener = RadioStatic.new()
	listener.name = "RadioStatic"
	listener.transmitter = house.evidence[TRANSMITTER]
	house.add_child(listener)


## How many static bars a cop radio picks up at `at`, with the transmitter at `transmitter`.
static func static_level(at: Vector3, transmitter: Vector3) -> int:
	var near := 1.0 - at.distance_to(transmitter) / STATIC_RANGE
	return clampi(BASE_BARS + ceili(near * (MAX_BARS - BASE_BARS)), BASE_BARS, MAX_BARS)


func extras(house: GrandpaHouse) -> Array[Dictionary]:
	var car := house.car
	var tapes := house.drawer_evidence
	var delivered := tapes.filter(func(t: Evidence) -> bool: return car.is_delivered(t)).size()
	return [{"text": house.tr("OBJ_EXTRA_TAPES") % [delivered, tapes.size()],
		"done": not tapes.is_empty() and delivered == tapes.size()}]
