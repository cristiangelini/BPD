class_name RobesRig
extends HotelRig

## The stolen robes (hotel-allanamiento.md, "Las batas robadas"): don Bostezo collects the embroidered robes of the
## city's fancy hotels and sells them as his own. The bag of robes is the main evidence, hidden like the extras (the
## buyers' list and the embroidery machine). Robes hang all over the hotel, one in each room and one in the suite, but
## they're worth nothing: the story's own clue is that each one has another hotel's crest. Every number here is
## (propuesta).

const ROBE_SCENE := preload("res://scenes/props/hanging_robe.tscn")
## The other hotels whose crests the robes have (ROBE_HOTEL_<n>).
const CRESTS := 4
## How high the robes hang, and how far from the door inside each room.
const HANG := 1.35
const BESIDE_DOOR := 1.25
const SUITE_ROBE_AT := Vector3(Hotel.SUITE_X - 0.14, Hotel.UP + HANG, -2.0)

var robes: Array[ClueNote] = []


func setup(place: HotelRaid) -> void:
	super.setup(place)
	var crest := place.case_seed % CRESTS
	for number: int in Hotel.GUEST_ROOMS:
		var room: Dictionary = Hotel.ROOMS[number]
		var north: bool = room.side == "n"
		var wall := -Hotel.CORRIDOR - 0.14 if north else Hotel.CORRIDOR + 0.14
		_hang(Vector3(room.door + BESIDE_DOOR, Hotel.UP + HANG, wall), PI if north else 0.0, crest)
		crest += 1
	_hang(SUITE_ROBE_AT, -PI / 2, crest)


## A robe on its hook: E reads the crest, which goes to the checklist.
func _hang(at: Vector3, turn: float, crest: int) -> void:
	var robe: ClueNote = ROBE_SCENE.instantiate()
	robe.text = tr("CLUE_ROBES_CREST") % tr("ROBE_HOTEL_%d" % (crest % CRESTS))
	robe.position = at
	robe.rotation.y = turn
	robe.read.connect(hotel_raid.raid.add_clue)
	hotel_raid.add_child(robe)
	robes.append(robe)
