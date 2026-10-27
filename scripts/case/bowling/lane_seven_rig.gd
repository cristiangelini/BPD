extends BowlingRig

## Lane 7 (allanamiento-bolera.md, "La pista 7"): Don Chuza steals balls from other bowling alleys and rolls them on a
## secret lane behind a red curtain in the back wall, a lane on no plan. Every EXTRA_EVERY rolls, the ball return of
## the lane that rolled gives back one ball too many, with another alley's name on it (at most MAX of them). A cop who
## picks one up reads the name (the first time, the clue). The crate of stolen balls, the torn sign and the plan are
## hidden. Every number here is (propuesta).

const CURTAIN_MODEL := preload("res://assets/models/lane7_curtain.glb")
const CURTAIN_AT := Vector3(4.0, Bowling.FLOOR_TOP, -11.9)
const EXTRA_EVERY := 3
const MAX := 4
const BALL_KG := 6.0
const NAMES := ["BOWL_FOREIGN_1", "BOWL_FOREIGN_2", "BOWL_FOREIGN_3"]

var foreign: Array[BowlingBall] = []
var read := false
var _rolls := 0


func shared() -> Array[String]:
	return ["read"]


func setup(place: Bowling) -> void:
	super.setup(place)
	alley.main = alley.hidden[0]
	alley._model(CURTAIN_MODEL, CURTAIN_AT)
	# The lane comes out under the curtain: a strip of its wood and its foul line, painted on the floor.
	alley._build.mesh_box(CURTAIN_AT + Vector3(0, 0.005, 1.4), Vector3(Bowling.LANE_WIDTH, 0.01, 2.8), Bowling.LANE_WOOD)
	alley._build.mesh_box(CURTAIN_AT + Vector3(0, 0.012, 2.8), Vector3(Bowling.LANE_WIDTH, 0.01, 0.05), Color(0.85, 0.2, 0.2))
	alley._label("BOWL_LANE7_SIGN", CURTAIN_AT + Vector3(0, 2.2, 0.2), 48)
	alley.rolled.connect(_on_rolled)


func _on_rolled(lane: int, _knocked: int, _ball: BowlingBall) -> void:
	_rolls += 1
	if _rolls % EXTRA_EVERY == 0 and foreign.size() < MAX and multiplayer.is_server():
		extra_ball(Bowling.rack_of(lane))


## One ball too many comes up rack `rack`'s return, with another alley's name on it.
func extra_ball(rack: int) -> BowlingBall:
	var ball := BowlingBall.make(BALL_KG, foreign.size() + 3)
	ball.name = "ForeignBall%d" % foreign.size()
	ball.rack = rack
	ball.slot = 1
	ball.tag = NAMES[foreign.size() % NAMES.size()]
	alley.add_child(ball)
	ball.position = Bowling.rack_spot(rack, 1) + Vector3.UP * (BowlingBall.RADIUS * 2 + 0.05)
	foreign.append(ball)
	alley._say(Bowling.rack_spot(rack, 1) + Vector3.UP * 1.0, "BOWL_RETURN_EXTRA")
	return ball


func _physics_process(_delta: float) -> void:
	if read:
		return
	for ball in foreign:
		if ball.is_held():
			read = true
			alley.raid.add_clue(tr("BOWL_FOREIGN_CLUE"))
			return
