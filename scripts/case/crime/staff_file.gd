class_name StaffFile
extends RefCounted

## What one coworker of the station crime scene gives their file (escena-comisaria.md, step 4): the print kit on them
## gives their prints; a donut from a box, a bite (their teeth); E with empty hands, the first time, where and with whom
## they were last night and their signature in the cop's notebook (with the left hand or the right); the camera's
## flash, their photo (height, limp and shoes). Doña Fritanga, asked again, says how many sugars each one takes. The
## five of StationStaff and the armero (Armero) share it. Every number here is (propuesta).

var case: CrimeSceneCase
## Their place in the case's order (StaffTraits.IDS).
var index := 0
var traits := {}
## Who says it: a StationStaff (its bubble) or the armero (the cop's hint).
var body: Node
var signed := false
var _asked := 0


func _init(staff_case: CrimeSceneCase, staff_index: int, body_node: Node) -> void:
	case = staff_case
	index = staff_index
	traits = case.cooks[index]
	body = body_node


## The prompt for what E would do now, or "" when E is theirs to do as usual.
func prompt_key(cop: Cop) -> String:
	if _food(cop):
		return "PROMPT_STAFF_FEED"
	if not signed:
		return "PROMPT_STAFF_ASK"
	return ""


## E on them: food in hand, a bite; the first time, the alibi and the signature; doña Fritanga, every other time, the
## sugars. Returns whether it took the E (else it's their usual line, or the armero's list).
func use(cop: Cop) -> bool:
	var food := _food(cop)
	if food:
		feed(food, cop)
		return true
	if not signed:
		signed = true
		var hand := tr("STAFF_SIGNS_LEFT" if traits.left else "STAFF_SIGNS_RIGHT")
		_say(cop, alibi() + " " + hand)
		case.staff_part(index, "sign")
		return true
	if traits.id == "fritanga":
		_asked += 1
		if _asked % 2 == 1:
			_say(cop, sugars())
			for i in case.cooks.size():
				case.staff_part(i, "sugar")
			return true
	return false


## Where and with whom they were last night.
func alibi() -> String:
	return tr("STAFF_ALIBI") % [tr("STAFF_PLACE_" + (traits.where as String).to_upper()),
		tr("STAFF_WITH_" + StaffTraits.IDS[traits.with].to_upper())]


## Doña Fritanga's list: how many spoons of sugar each one takes.
func sugars() -> String:
	var list := PackedStringArray()
	for person in case.cooks:
		list.append("%s: %d" % [person.name, person.sugar])
	return tr("FRITANGA_SUGARS") % ", ".join(list)


func feed(food: Node, cop: Cop) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		_say(cop, "MUSEUM_GUARD_NO_DONUTS")
		return
	if body.has_method("show_teeth"):
		body.show_teeth()
	_say(cop, "GUARD_BITES")
	case.staff_part(index, "teeth")


## The print kit on them (PrintKit): their prints, clean.
func dusted() -> String:
	case.staff_part(index, "prints")
	return tr("PRINTS_COOK") % traits.name


## The camera's flash (PhotoCamera): their photo.
func photographed(cop: Cop) -> void:
	_say(cop, "STAFF_NO_FLASH")
	case.staff_part(index, "photo")


func _say(cop: Cop, text: String) -> void:
	if body.has_method("say"):
		body.say(text, 6.0)
	elif cop:
		cop.show_hint(text)


func _food(cop: Cop) -> Node:
	if not cop:
		return null
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox else null
