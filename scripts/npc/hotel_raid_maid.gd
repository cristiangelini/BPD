class_name HotelRaidMaid
extends HotelStaff

## Doña Escoba in the hotel raid (hotel-allanamiento.md, "Doña Escoba, la mucama"): the crime scene's maid with her
## cart, walking the upstairs corridor end to end. She only talks to whoever helps her: when a cop starts making an
## unmade bed she comes to that room's door, and when the bed is made she tells where she saw don Bostezo hide
## something (`clue`, from the case in step 4). Once per cop. Every number here is (propuesta).

## What she tells, already translated (the case fills it).
signal told(text: String)

const SPEED := 0.7
## Called to a room's door, she hurries.
const HURRY := 2.0
## The corridor stretch she walks, at its middle (her cart goes ahead of her).
const WEST_X := Hotel.SUITE_X + 1.6
const EAST_X := Hotel.HALF_X - 1.6
const HELPED_LINES := ["HOTEL_MAID_HELP_1", "HOTEL_MAID_HELP_2"]

## Where she saw something hidden, already translated; empty, she saw nothing.
var clue := ""
var told_cops: Array[Cop] = []
## Where she stands still to talk (a room's door), or null while she walks.
var _talk_at: Variant = null
var _heading := -1.0


func _init() -> void:
	who = "maid"


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOTEL_MAID"


## E on her: she's busy, unless someone gives her a hand with a bed.
func use(cop: Cop) -> void:
	say("HOTEL_MAID_THANKS" if told_cops.has(cop) else "HOTEL_MAID_BUSY")


## A cop started making a bed in `room`: she comes to its door to chat.
func helping(cop: Cop, room: int) -> void:
	var door: float = Hotel.ROOMS[room].door
	_talk_at = Vector3(clampf(door, WEST_X, EAST_X), position.y, position.z)
	say(HELPED_LINES[told_cops.size() % HELPED_LINES.size()] if not told_cops.has(cop) else "HOTEL_MAID_THANKS")


## The bed is made: the first time for this cop, she tells what she saw.
func helped(cop: Cop) -> void:
	_talk_at = null
	if told_cops.has(cop):
		return
	told_cops.append(cop)
	var text := clue if clue != "" else tr("HOTEL_MAID_SAW_NOTHING")
	say(text, 6.0)
	told.emit(text)


func _physics_process(delta: float) -> void:
	super(delta)
	var target: float = (_talk_at as Vector3).x if _talk_at != null else (WEST_X if _heading < 0.0 else EAST_X)
	var step := target - position.x
	if absf(step) < 0.05:
		if _talk_at == null:
			_heading = -_heading
		return
	_heading = signf(step)
	var speed := HURRY if _talk_at != null else SPEED
	position.x += signf(step) * minf(speed * delta, absf(step))
	rotation.y = -PI / 2 if _heading < 0.0 else PI / 2
