class_name BowlPlayer
extends StaticBody3D

## A player of the Thursday league at the bowling alley (allanamiento-bolera.md, step 2). Two to a lane, each one
## takes a ball from the lane's rack and bowls about every 20 s, even with a cop on the lane. They complain (5 to the
## complaint, at most once every 10 s each) when a cop stands in the way, takes their ball, knocks their pins down or
## breaks their lane's screen. E on one tells a line about the league. Every number here is (propuesta).

## They complained loud enough for the owner to hear it (Don Chuza adds it to the complaint, step 3).
signal complained(player: BowlPlayer)

const MODELS := {
	"bowler": preload("res://assets/models/npc_bowler.glb"),
	"bowler_b": preload("res://assets/models/npc_bowler_b.glb"),
}
const SCALE := 0.95
const THROW_EVERY := 20.0
## The pins aren't up yet, or there's no ball: they try again this much later.
const WAIT := 1.0
const COMPLAINT := 5.0
const COMPLAIN_EVERY := 10.0
const SAY_TIME := 3.5
## Walking up to the foul line, the ball leaving their hand, and walking back.
const STEP_UP := 0.8
const BACK_AFTER := 1.5
const BOWL_SPEED := 9.0
const BOWL_SIDEWAYS := 0.25
const THROW_LINES := ["BOWL_PLAYER_THROW_1", "BOWL_PLAYER_THROW_2", "BOWL_PLAYER_THROW_3"]
const TALK_LINES := ["BOWL_PLAYER_TALK_1", "BOWL_PLAYER_TALK_2", "BOWL_PLAYER_TALK_3", "BOWL_PLAYER_TALK_4"]

@export var look := "bowler"
var alley: Bowling
var lane := 0
## Where they wait between throws (alley space), and when the next throw comes.
var home := Vector3.ZERO
var next_throw := THROW_EVERY
## How long they take to walk up to the foul line (a story's wheels make it quicker).
var step_up := STEP_UP
var rng := RandomNumberGenerator.new()
## The ball they bowled last, until it's back on the rack.
var ball: BowlingBall
var complaints := 0
var _since_complaint := COMPLAIN_EVERY
var _next_talk := 0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bowl_players")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODELS[look].instantiate()
	model.scale = Vector3.ONE * SCALE
	# The models face +Z; the player faces -Z, down the lane.
	model.rotation.y = PI
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	alley.rolled.connect(_on_rolled)
	alley.screen_broken.connect(func(broken: int) -> void:
		if broken == lane:
			complain("BOWL_PLAYER_SCREEN"))


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_BOWLER"


func use(_cop: Cop) -> void:
	say(TALK_LINES[_next_talk % TALK_LINES.size()])
	_next_talk += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Says it, and it counts for the complaint unless they complained a moment ago.
func complain(key: String) -> void:
	say(key)
	if _since_complaint < COMPLAIN_EVERY:
		return
	_since_complaint = 0.0
	complaints += 1
	complained.emit(self)


func _physics_process(delta: float) -> void:
	_since_complaint += delta
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	if ball and not ball.bowled:
		ball = null
	if ball and ball.is_held():
		ball = null
		complain("BOWL_PLAYER_GRABBED")
	next_throw -= delta
	if next_throw <= 0.0:
		_try_throw()


## Their turn: with the pins up and a ball on the rack, they step up and bowl, cop in the way or not.
func _try_throw() -> void:
	if alley.lane_busy(lane):
		next_throw = WAIT
		return
	var picked := alley.rack_ball(Bowling.rack_of(lane))
	if not picked:
		next_throw = WAIT * 5
		complain("BOWL_PLAYER_NO_BALL")
		return
	next_throw = THROW_EVERY
	if alley.cop_on_lane(lane):
		complain("BOWL_PLAYER_IN_WAY")
	else:
		say(THROW_LINES[rng.randi() % THROW_LINES.size()])
	var line := Vector3(Bowling.LANE_X[lane], home.y, Bowling.FOUL_Z + 0.6)
	var walk := create_tween()
	walk.tween_property(self, "position", line, step_up)
	walk.tween_callback(func() -> void:
		ball = picked
		alley.bowl(picked, lane, Vector3(rng.randf_range(-BOWL_SIDEWAYS, BOWL_SIDEWAYS), 0, -BOWL_SPEED)))
	walk.tween_interval(BACK_AFTER)
	walk.tween_property(self, "position", home, step_up)


## A cop's ball knocked their pins down (a ball nobody bowled, or one thrown by a cop).
func _on_rolled(on_lane: int, knocked: int, rolled_ball: BowlingBall) -> void:
	if on_lane != lane or knocked == 0:
		return
	if rolled_ball == ball:
		ball = null
		return
	if rolled_ball and rolled_ball.thrower():
		complain("BOWL_PLAYER_PINS")
