class_name FootballLustre
extends Node

## Deputy Lustre plays (politico-futbol.md, step 3, decision 179): he hangs around up front, runs for the ball when
## it's within CHASE of him and kicks it when it's at his feet. Badly: one kick in ON_TARGET goes at the east goal
## (more often within NEAR_GOAL of it), the rest anywhere. He shouts something every time. Step 4: a veteran within
## TOUCH of him and he throws himself on the grass, screaming, and won't get up on his own: the stretcher laid next to
## him (within LOAD), he gets on it, and two cops carry him to his bench, where he heals in HEAL seconds and goes back.
## The Tank reaching him (`hit`) sends him flying: a real injury (`injured`). Every number here is (propuesta).

signal fell
signal injured(count: int)
signal healed

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
## Falling: how close a veteran has to get, how long before he can fall again, how often he screams on the grass.
const TOUCH := 0.95
const GRACE := 3.0
const SCREAM_EVERY := 3.0
const SCREAMS := 3
## The stretcher: how close it has to be for him to get on it, and his bench (the pitch's space), how close to it is
## there, and how long he takes to heal on it.
const LOAD := 1.6
const BENCH := Vector3(-8, 0, 13.4)
const BENCH_REACH := 2.5
const HEAL := 5.0
## Sent flying by the Tank.
const FLY := Vector2(6.0, 5.0)
const LYING := 1.3

var pitch: FootballPitch
var politician: Politician
var playing := false
## Online, a guest's: the host's plays.
var follower := false
var kicks := 0
## Lying on the grass (or on the stretcher, or healing on the bench) and real injuries so far.
var down := false
var riding: FootballStretcher
var injuries := 0
var _healing := 0.0
var _grace := 0.0
var _scream := 0.0
var _screams := 0
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
	_grace = maxf(_grace - delta, 0.0)
	if down:
		_lie(delta)
		return
	var wish := Vector3.ZERO
	if playing:
		var touched := _touched()
		if touched:
			fall()
			return
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


## A veteran close enough to count as a foul (the Tank charging counts only if he arrives, `hit`).
func _touched() -> FootballPlayer:
	if _grace > 0.0:
		return null
	for player: FootballPlayer in pitch.match_clock.players:
		if player.team != FootballScore.Team.VETERANS or player.charging:
			continue
		var flat := player.global_position - politician.global_position
		flat.y = 0.0
		if flat.length() < TOUCH:
			return player
	return null


## On the grass, screaming as if they'd killed him.
func fall() -> void:
	if down:
		return
	down = true
	_scream = 0.0
	politician.get_node("Model").rotation = Vector3(-PI / 2, PI, 0)
	politician.get_node("Model").position.y = 0.35
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_FOOTBALL_DOWN")
	fell.emit()


## The Tank got him: he flies, and it's a real injury.
func hit(from: Vector3) -> void:
	var away := politician.global_position - from
	away.y = 0.0
	away = away.normalized() if away.length() > 0.01 else Vector3.RIGHT
	fall()
	politician.velocity = away * FLY.x + Vector3.UP * FLY.y
	injuries += 1
	politician.say("FOOTBALL_LUSTRE_HURT", 3.0)
	_scream = SCREAM_EVERY
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_FOOTBALL_INJURY")
	injured.emit(injuries)


func _lie(delta: float) -> void:
	if riding:
		_ride()
		return
	if _healing > 0.0:
		_healing -= delta
		if _healing <= 0.0:
			_get_up()
		return
	_scream -= delta
	if _scream <= 0.0:
		_scream = SCREAM_EVERY
		politician.say("FOOTBALL_LUSTRE_DOWN_%d" % (_screams % SCREAMS + 1), SCREAM_EVERY - 0.2)
		_screams += 1
	if politician.is_on_floor():
		politician.velocity.x = move_toward(politician.velocity.x, 0.0, LYING * 10 * delta)
		politician.velocity.z = move_toward(politician.velocity.z, 0.0, LYING * 10 * delta)
		politician.velocity.y = 0.0
	else:
		politician.velocity.y -= GameScale.GRAVITY * delta
	politician.move_and_slide()
	for stretcher: FootballStretcher in get_tree().get_nodes_in_group("football_stretchers"):
		if stretcher.global_position.distance_to(politician.global_position) < LOAD:
			_get_on(stretcher)
			return


func _get_on(stretcher: FootballStretcher) -> void:
	riding = stretcher
	stretcher.carry(true)
	politician.collision_layer = 0
	politician.collision_mask = 0
	politician.velocity = Vector3.ZERO
	politician.say("FOOTBALL_LUSTRE_STRETCHER", 3.0)
	_ride()


## On the stretcher, wherever the cops take it; at his bench he gets off to heal.
func _ride() -> void:
	politician.global_position = riding.bed()
	politician.global_rotation = Vector3(0, riding.global_rotation.y + PI / 2, 0)
	var at := pitch.to_local(riding.global_position) - BENCH
	at.y = 0.0
	if at.length() < BENCH_REACH:
		riding.carry(false)
		riding = null
		politician.collision_layer = 8
		politician.collision_mask = 1
		politician.global_position = pitch.to_global(BENCH + Vector3.UP * 0.05)
		_healing = HEAL
		politician.say("FOOTBALL_LUSTRE_HEALING", HEAL)


func _get_up() -> void:
	down = false
	_grace = GRACE
	politician.get_node("Model").rotation = Vector3(0, PI, 0)
	politician.get_node("Model").position.y = 0.0
	politician.say("FOOTBALL_LUSTRE_BACK", 3.0)
	healed.emit()


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
