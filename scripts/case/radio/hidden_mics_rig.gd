class_name HiddenMicsRig
extends RadioRig

## The hidden mics (allanamiento-radio.md, "Los micrófonos ocultos"): don Volumen records the neighbors with mics hidden
## in flowerpots and airs their gossip. The box of recordings is hidden with a mic in a pot and the neighborhood map
## with crosses; the reception's big flowerpot has a mic with a cable (looking at it with E is the story's own clue),
## and on air, every GOSSIP_EVERY seconds, some neighbor's gossip goes out. Every number here is (propuesta).

const PLANT_MODEL := preload("res://assets/models/reception_plant.glb")
const GOSSIP_EVERY := 35.0
## The gossip lines on air, in turn.
const GOSSIP: PackedStringArray = ["RADIO_GOSSIP_1", "RADIO_GOSSIP_2", "RADIO_GOSSIP_3"]
## The big flowerpot in the reception's corner by the front wall, the mic facing the room.
const PLANT_AT := Vector3(-8.3, RadioStation.FLOOR_TOP, 10.3)

var plant: ClueSpot
## Gossip lines aired so far.
var gossips := 0
var _since := 0.0


func setup(place: RadioStation) -> void:
	super.setup(place)
	plant = fixed_clue(PLANT_MODEL, PLANT_AT, Vector3(0.5, 1.3, 0.5), PI, "PROMPT_RECEPTION_PLANT",
		tr("CLUE_PLANT_MIC"))
	plant.name = "ReceptionPlant"


## On air, a neighbor's gossip nobody should know.
func gossip() -> void:
	_since = 0.0
	if not radio.on_air:
		return
	radio.say_on_air(GOSSIP[gossips % GOSSIP.size()])
	gossips += 1


func _process(delta: float) -> void:
	_since += delta
	if _since >= GOSSIP_EVERY:
		gossip()
