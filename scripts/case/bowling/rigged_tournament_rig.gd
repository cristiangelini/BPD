extends BowlingRig

## The fixed tournament (allanamiento-bolera.md, "El torneo arreglado"): this year's cup already has the winner's name
## engraved, Don Chuza's team. Lane 1's screen adds BONUS points to every roll on top of the pins, and a cop near the
## lane when it counts one notices (the first time, the clue). The trophy case's plate says the same team won every
## year. The cup, the fake score sheet and the judge's envelope are hidden. Every number here is (propuesta).

const LANE := 0
const BONUS := 10
## How close to lane 1's approach (its middle, behind the foul line) a cop has to be to see the screen add.
const NOTICE := 4.0
const APPROACH := 2.0

var noticed := false


func shared() -> Array[String]:
	return ["noticed"]


func setup(place: Bowling) -> void:
	super.setup(place)
	alley.main = alley.hidden[0]
	alley.score_bonus[LANE] = BONUS
	alley._label("BOWL_CUP_PLATE", Bowling.CASE_AT + Vector3(-Bowling.CASE_SIZE.x / 2 - 0.03, Bowling.CASE_SIZE.y + 0.15, 0),
		36, -PI / 2, 0.004)
	alley.rolled.connect(_on_rolled)


## A roll counted on lane 1: the screen adds its gift, and a cop close enough sees the sum is wrong.
func _on_rolled(lane: int, knocked: int, _ball: BowlingBall) -> void:
	if lane != LANE or alley.broken_screens.has(LANE):
		return
	var screen := Vector3(Bowling.LANE_X[LANE], Bowling.SCREEN_Y - 0.6, Bowling.SCREEN_Z + 0.4)
	alley._say(screen, "BOWL_SCORE_PLUS")
	if noticed or not _cop_near():
		return
	noticed = true
	alley._say(screen + Vector3.DOWN * 0.5, tr("BOWL_SCORE_ODD") % [knocked, knocked + BONUS], 4.0)
	alley.raid.add_clue(tr("BOWL_SCORE_CLUE"))


func _cop_near() -> bool:
	var spot := Vector3(Bowling.LANE_X[LANE], 0, Bowling.FOUL_Z + APPROACH)
	for cop: Node3D in alley.get_tree().get_nodes_in_group("cops"):
		var at := alley.to_local(cop.global_position)
		if Vector2(at.x - spot.x, at.z - spot.z).length() < NOTICE:
			return true
	return false
