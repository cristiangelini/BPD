class_name FakeChartRig
extends RadioStationRig

## The fake chart (allanamiento-radio.md, "El ranking trucho"): musicians pay don Volumen to top the station's chart.
## The box of envelopes is hidden with the cardboard gold record and the chart written in advance; next week's chart is
## already hanging next to this week's (reading it with E is the story's own clue), and on air, every REPEAT_EVERY
## seconds, the same song plays again. Every number here is (propuesta).

const REPEAT_EVERY := 120.0
## Next week's chart on the reception's wall, right of this week's, facing the reception.
const NEXT_CHART_AT := Vector3(5.2, 1.6, RadioStation.FRONT_Z + 0.14)

var next_chart: ClueSpot
## Times the same song played on air.
var repeats := 0
var _since := 0.0


func setup(place: RadioStation) -> void:
	super.setup(place)
	next_chart = board(NEXT_CHART_AT, 0.0, "RADIO_NEXT_RANKING", tr("CLUE_NEXT_RANKING"), "PROMPT_NEXT_RANKING", 22)
	next_chart.name = "NextRanking"


## On air, the paid song again.
func repeat_song() -> void:
	_since = 0.0
	if not radio.on_air:
		return
	repeats += 1
	radio.say_on_air("RADIO_SAME_SONG")


func _process(delta: float) -> void:
	_since += delta
	if _since >= REPEAT_EVERY:
		repeat_song()
