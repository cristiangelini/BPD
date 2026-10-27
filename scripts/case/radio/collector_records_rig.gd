class_name CollectorRecordsRig
extends RadioRig

## The collector's records (allanamiento-radio.md, "Los discos de colección"): don Volumen stole a collector's vinyls
## and plays them on air as "gems". The crate of stolen vinyls is hidden with the collector's catalog and the golden
## record player; one record leaning on the archive's shelf says "Colección privada · no prestar" (looking at it with E
## is the story's own clue), and on air, every PRESENT_EVERY seconds, he presents another rarity. Every number here is
## (propuesta).

const RECORD_MODEL := preload("res://assets/models/private_record.glb")
const PRESENT_EVERY := 45.0
## What he says on air, in turn.
const GEMS: PackedStringArray = ["RADIO_GEM_1", "RADIO_GEM_2", "RADIO_GEM_3"]
## The record on the floor, leaning on the front shelves of the archive, its label facing the archive's door.
const RECORD_AT := Vector3(-3.5, RadioStation.FLOOR_TOP, -5.95)

var record: ClueSpot
## Rarities presented on air so far.
var presented := 0
var _since := 0.0


func setup(place: RadioStation) -> void:
	super.setup(place)
	record = fixed_clue(RECORD_MODEL, RECORD_AT, Vector3(0.34, 0.34, 0.12), 0.0, "PROMPT_PRIVATE_RECORD",
		tr("CLUE_PRIVATE_RECORD"))
	record.name = "PrivateRecord"


## On air, another gem from someone else's collection.
func present() -> void:
	_since = 0.0
	if not radio.on_air:
		return
	radio.say_on_air(GEMS[presented % GEMS.size()])
	presented += 1


func _process(delta: float) -> void:
	_since += delta
	if _since >= PRESENT_EVERY:
		present()
