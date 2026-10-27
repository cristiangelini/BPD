class_name CodedDedicationsRig
extends RadioStationRig

## The coded dedications (allanamiento-radio.md, "Las dedicatorias en clave"): don Volumen sends messages to a gang in
## the song dedications. The box with the code book and the portable radio is hidden with the "listeners" list and the
## delivery clock; the dedications board on the reception's wall has one that isn't a dedication (reading it with E is
## the story's own clue), and on air, every DEDICATE_EVERY seconds, another very odd dedication goes out. Every number
## here is (propuesta).

const DEDICATE_EVERY := 60.0
## The dedications on air, in turn.
const DEDICATIONS: PackedStringArray = ["RADIO_DEDICATION_1", "RADIO_DEDICATION_2", "RADIO_DEDICATION_3"]
## The board on the reception's west wall, facing the room.
const BOARD_AT := Vector3(-RadioStation.HALF_X + 0.08, 1.5, 8.5)

var dedications_board: ClueSpot
## Dedications sent on air so far.
var dedicated := 0
var _since := 0.0


func setup(place: RadioStation) -> void:
	super.setup(place)
	dedications_board = board(BOARD_AT, PI / 2, "RADIO_DEDICATIONS_BOARD", tr("CLUE_GULL_DEDICATION"),
		"PROMPT_DEDICATIONS_BOARD", 22)
	dedications_board.name = "DedicationsBoard"


## On air, a dedication nobody understands (except the gang).
func dedicate() -> void:
	_since = 0.0
	if not radio.on_air:
		return
	radio.say_on_air(DEDICATIONS[dedicated % DEDICATIONS.size()])
	dedicated += 1


func _process(delta: float) -> void:
	_since += delta
	if _since >= DEDICATE_EVERY:
		dedicate()
