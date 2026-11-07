class_name MansionClues
extends Node

## The mansion case's clues where they go (escena-mansion.md, "Las pistas"), put by Mansion when the case comes: the
## prints on the safe's door, the footprint in the dust of one passage (drawn with the seed; a cop crossing it steps on
## it), the hair caught on the armour (lost if someone pushes it over), the bitten chocolate beside doña Clotilde's box,
## the bell that rang at midnight (Ceferino tells it; pulling any bell cord mixes up the board) and Lorenzo, who saw
## the culprit's glasses. Every number here is (propuesta).

const DUST := Color(0.5, 0.47, 0.44)
## The safe's open door, beside the safe (Mansion.SAFE_AT): its middle and its size (thin side along the wall).
const SAFE_DOOR_AT := Vector3(0.55, 0.5, 0.45)
const SAFE_DOOR_SIZE := Vector2(0.54, 0.82)
## The hair, on top of the armour's helmet; the bitten chocolate, on the table beside the box.
const HAIR_AT := Vector3(0, MansionArmour.SIZE.y + 0.12, 0)
const BITE_AT := Mansion.TABLE_AT + Vector3(1.2, Mansion.TABLE_SIZE.y + 0.01, 0.2)
## A hair this far from where it was caught is no longer on the armour, in meters.
const HAIR_REACH := 0.5

var mansion: Mansion
var case: CrimeSceneCase
var safe: SafeDoor
var cords := {}
## Which passage the footprint is in ("" without one).
var footprint_in := ""


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	safe = SafeDoor.new(SAFE_DOOR_SIZE)
	safe.name = "SafeDoor"
	safe.case = case
	safe.has_prints = plan.clues.has("prints")
	safe.position = Mansion.SAFE_AT + SAFE_DOOR_AT
	safe.rotation.y = PI / 2
	mansion.add_child(safe)
	if plan.clues.has("footprint"):
		footprint_in = Mansion.PASSAGES.keys()[hash(["mansion footprint", case.case_seed]) % Mansion.PASSAGES.size()]
		var footprint := FlourPrint.new()
		footprint.name = "DustPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		footprint.dust = DUST
		var middle := mansion.passage_door(footprint_in, "in", -1.0) + mansion.passage_door(footprint_in, "out", -1.0)
		middle /= 2.0
		footprint.position = middle + Vector3(0, Mansion.FLOOR_TOP - 0.04, 0)
		mansion.add_child(footprint)
		case.flour_print = footprint
	mansion.armour.fell.connect(drop_hair)
	if plan.clues.has("hair"):
		_clue_item("hair", mansion.armour.position + HAIR_AT)
	if plan.clues.has("bite"):
		_clue_item("bite", BITE_AT)
	for room in Mansion.BELL_ROOMS:
		var cord := BellCord.new()
		cord.name = "BellCord_" + room
		cord.room = room
		cord.position = Mansion.BELL_CORDS[room] + Vector3(0, Mansion.FLOOR_TOP, 0)
		cord.pulled.connect(mix_bells.unbind(1))
		mansion.add_child(cord)
		cords[room] = cord
	mansion.butler.case = case
	mansion.butler.knows = plan.clues.has("bells")
	mansion.butler.bell_room = who.room
	mansion.parrot.case = case
	mansion.parrot.knows = plan.clues.has("witness")


func _clue_item(kind: String, at: Vector3) -> void:
	var item := CrimeClueItem.new()
	item.name = "Clue_" + kind
	item.kind = kind
	item.look = "mansion"
	item.case = case
	item.hair_color = MemberTraits.HAIRS[case.culprit().hair]
	item.position = at
	mansion.add_child(item)
	case.items[kind] = item


## The armour came down: the hair caught on it falls and is lost, unless it was already taken.
func drop_hair() -> void:
	if not case.items.has("hair"):
		return
	var hair: CrimeClueItem = case.items.hair
	if mansion.to_local(hair.global_position).distance_to(mansion.armour.position + HAIR_AT) <= HAIR_REACH:
		hair.wash()


## Someone pulled a bell cord: the board's flags are mixed up and Ceferino can't tell which rang at midnight.
func mix_bells() -> void:
	mansion.butler.mixed = true
	case.ruin("bells")
