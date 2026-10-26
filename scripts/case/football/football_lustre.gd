class_name FootballLustre
extends Node

## Deputy Lustre plays (politico-futbol.md, step 3, decision 179): he hangs around up front, runs for the ball when
## it's within CHASE of him and kicks it when it's at his feet. Badly: one kick in ON_TARGET goes at the east goal
## (more often within NEAR_GOAL of it), the rest anywhere. He shouts something every time. Every number here is
## (propuesta).

const SPEED := 2.6
const CHASE := 9.0
## Where he hangs around, in the pitch's space.
const HOME := Vector3(8, 0, 1)
const THERE := 0.4
const ON_TARGET := 3
const NEAR_GOAL := 14.0
const SHOT := 14.0
const WILD := Vector2(5.0, 16.0)
const KICK_WAIT := 1.0
const KICK_LINES := 4
const GOAL_SPREAD := 2.2

var pitch: FootballPitch
var politician: Politician
var playing := false
## Online, a guest's: the host's plays.
var follower := false
var kicks := 0
var _kick_wait := 0.0
var _rng := RandomNumberGenerator.new()


func setup(the_pitch: FootballPitch, deputy: Politician, case_seed: int) -> void:
	pitch = the_pitch
	politician = deputy
	_rng.seed = hash(["lustre kicks", case_seed])


func _physics_process(delta: float) -> void:
	if follower or politician == null:
		return
	_kick_wait = maxf(_kick_wait - delta, 0.0)
	var wish := Vector3.ZERO
	if playing:
		var ball := pitch.ball
		var near := ball.global_position.distance_to(politician.global_position) < CHASE
		var target := ball.global_position if near else pitch.to_global(HOME)
		if ball.at_feet(politician) and _kick_wait <= 0.0 and not ball.is_held():
			kick()
		var to := target - politician.global_position
		to.y = 0.0
		if to.length() > THERE:
			wish = to.normalized() * SPEED
	_move(wish, delta)


## His kick: at the goal now and then, anywhere the rest of the time.
func kick() -> void:
	var ball := pitch.ball
	_kick_wait = KICK_WAIT
	kicks += 1
	var odds := ON_TARGET
	if ball.global_position.distance_to(pitch.to_global(FootballPitch.goal_at(1.0))) < NEAR_GOAL:
		odds = 2
	var direction: Vector3
	var power := SHOT
	if _rng.randi() % odds == 0:
		var goal := pitch.to_global(FootballPitch.goal_at(1.0) + Vector3(0, 0.4, _rng.randf_range(-GOAL_SPREAD,
			GOAL_SPREAD)))
		direction = (goal - ball.global_position).normalized() + Vector3.UP * 0.08
	else:
		var angle := _rng.randf() * TAU
		direction = Vector3(cos(angle), _rng.randf_range(0.05, 0.6), sin(angle))
		power = _rng.randf_range(WILD.x, WILD.y)
	ball.kick(politician, direction.normalized(), power)
	politician.say("FOOTBALL_LUSTRE_KICK_%d" % (kicks % KICK_LINES + 1), 3.0)


func _move(wish: Vector3, delta: float) -> void:
	if wish.length() > 0.05:
		politician.look_at(politician.global_position + wish, Vector3.UP)
	politician.velocity.x = wish.x
	politician.velocity.z = wish.z
	if politician.is_on_floor():
		politician.velocity.y = 0.0
	else:
		politician.velocity.y -= GameScale.GRAVITY * delta
	politician.move_and_slide()
