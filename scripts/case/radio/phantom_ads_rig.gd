class_name PhantomAdsRig
extends RadioStationRig

## The phantom ads (allanamiento-radio.md, "Las publicidades fantasma"): don Volumen charges the neighborhood's shops for
## ads that never air. The contracts are hidden with the billing notebook and the "PAGADO" stamp; the ads grid on the
## control room's wall is empty (reading it with E is the story's own clue), and on air, every SILENCE_EVERY seconds,
## there's a silence where the ad should go. Every number here is (propuesta).

const SILENCE_EVERY := 40.0
## The grid on the control room's wall by its door, facing the room.
const GRID_AT := Vector3(3.0, 1.5, RadioStation.FRONT_Z - 0.08)

var grid: ClueSpot
## Silences on air so far.
var silences := 0
var _since := 0.0


func setup(place: RadioStation) -> void:
	super.setup(place)
	grid = board(GRID_AT, PI, "RADIO_AD_GRID", tr("CLUE_EMPTY_AD_GRID"), "PROMPT_AD_GRID")
	grid.name = "AdGrid"


## Where the ad should go: silence, on air.
func silence() -> void:
	_since = 0.0
	if not radio.on_air:
		return
	silences += 1
	radio.say_on_air("RADIO_AD_SILENCE")


func _process(delta: float) -> void:
	_since += delta
	if _since >= SILENCE_EVERY:
		silence()
