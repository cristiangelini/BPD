class_name PoliticianWalks
extends Node

## Deputy Lustre's walks off the stage (proteccion-politico.md, step 5, decision 103): during the speech, every
## WALK_EVERY seconds or so he leaves the lectern, goes down the ramp and greets the crowd, a fan after another, a
## handshake or a selfie each; down there the lectern doesn't cover him. E takes him by the hand and he follows that cop,
## complaining; walked back onto the stage near the lectern, he goes back to it and the speech goes on. Let go
## anywhere else, he goes back to greeting. It hangs off the politician as "Walks" and moves him while he's off.
## Every number here is (propuesta).

signal walked_off
signal back

enum State { SPEAKING, WALKING, GREETING, LED, RETURNING }

const WALK_EVERY := 55.0
const WALK_JITTER := 15.0
## The first walk waits this long after the speech starts.
const FIRST_WALK := 40.0
const SPEED := 1.6
## Led by the hand, this fast and this far behind the cop.
const LED_SPEED := 1.8
const KEEP_AWAY := 1.2
const ARRIVED := 0.5
## He stops this far from the fan he greets, for this long.
const GREET_AWAY := 1.0
const GREET_TIME := 6.0
const GREETS := 4
const SELFIES := 3
const LED_LINES := 3
const COMPLAIN_EVERY := 5.0
## Led onto the stage this close to the lectern's spot, he goes back to it.
const BACK_REACH := 2.0

var politician: Politician
var speech: PoliticianSpeech
var fans: Array[RallyFan] = []
## Where he speaks (behind the lectern), the ramp's top and its foot, in world space.
var podium: Vector3
var ramp_top: Vector3
var ramp_foot: Vector3
var state := State.SPEAKING
var led_by: Cop
var _path: Array[Vector3] = []
var _greeting: RallyFan
var _greet_left := 0.0
var _walk_left := FIRST_WALK
var _complain_left := 0.0
var _line := 0
var _rng := RandomNumberGenerator.new()


static func of(body: Node) -> PoliticianWalks:
	return body.get_node_or_null("Walks") as PoliticianWalks


static func attach(speaker: Politician, the_speech: PoliticianSpeech, crowd: Array[RallyFan], spot: Vector3,
		top: Vector3, foot: Vector3, case_seed: int) -> PoliticianWalks:
	var walks := PoliticianWalks.new()
	walks.name = "Walks"
	walks.politician = speaker
	walks.speech = the_speech
	walks.fans = crowd
	walks.podium = spot
	walks.ramp_top = top
	walks.ramp_foot = foot
	walks._rng.seed = hash(["politician walks", case_seed])
	speaker.add_child(walks)
	return walks


func off_stage() -> bool:
	return state != State.SPEAKING


func prompt_key(cop: Cop) -> String:
	if state == State.SPEAKING or state == State.RETURNING:
		return "PROMPT_TALK_POLITICIAN"
	return "PROMPT_LET_GO_POLITICIAN" if led_by == cop else "PROMPT_LEAD_POLITICIAN"


## E while he's off: takes him by the hand, or lets go (he goes greeting again). False when it's not for the walks.
func use(cop: Cop) -> bool:
	if state == State.SPEAKING or state == State.RETURNING:
		return false
	if led_by == cop:
		led_by = null
		_greet_next()
		return true
	led_by = cop
	state = State.LED
	_complain_left = COMPLAIN_EVERY
	politician.say("POLITICIAN_LED_%d" % (_line % LED_LINES + 1), 3.0)
	_line += 1
	return true


## He leaves the lectern now: down the ramp to greet the crowd.
func walk_off() -> void:
	if state != State.SPEAKING:
		return
	politician.say("POLITICIAN_OFF")
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_POLITICIAN_OFF")
	walked_off.emit()
	_greet_next()


func _physics_process(delta: float) -> void:
	match state:
		State.SPEAKING:
			if speech.speaking:
				_walk_left -= delta
				if _walk_left <= 0.0:
					_walk_left = WALK_EVERY + _rng.randf_range(-WALK_JITTER, WALK_JITTER)
					walk_off()
		State.WALKING, State.RETURNING:
			if _follow_path(delta):
				if state == State.RETURNING:
					_at_podium()
				else:
					state = State.GREETING
					_greet_left = GREET_TIME
					var selfie := _rng.randf() < 0.4
					politician.say("POLITICIAN_SELFIE_%d" % _rng.randi_range(1, SELFIES) if selfie
						else "POLITICIAN_GREET_%d" % _rng.randi_range(1, GREETS))
		State.GREETING:
			_greet_left -= delta
			if _greet_left <= 0.0:
				_greet_next()
		State.LED:
			_led(delta)


func _led(delta: float) -> void:
	if _near_podium():
		var cop := led_by
		led_by = null
		if cop:
			cop.stats["politician_returns"] = cop.stats.get("politician_returns", 0) + 1
		state = State.RETURNING
		_path = [podium]
		return
	var to := led_by.global_position - politician.global_position
	to.y = 0.0
	_move(to.normalized() * LED_SPEED if to.length() > KEEP_AWAY else Vector3.ZERO, delta)
	_complain_left -= delta
	if _complain_left <= 0.0:
		_complain_left = COMPLAIN_EVERY
		politician.say("POLITICIAN_LED_%d" % (_line % LED_LINES + 1), 3.0)
		_line += 1


## On the stage's top and near the lectern.
func _near_podium() -> bool:
	var at := politician.global_position
	return at.y > podium.y - 0.3 and Vector2(at.x - podium.x, at.z - podium.z).length() < BACK_REACH


func _at_podium() -> void:
	state = State.SPEAKING
	politician.global_position = podium
	politician.rotation.y = PI
	politician.velocity = Vector3.ZERO
	politician.say("POLITICIAN_BACK")
	back.emit()


## Off to the next fan: down the ramp first if he's still up on the stage.
func _greet_next() -> void:
	state = State.WALKING
	_greeting = fans[_rng.randi_range(0, fans.size() - 1)] if not fans.is_empty() else null
	_path.clear()
	if politician.global_position.y > ramp_foot.y + 0.5:
		_path.append(ramp_top)
		_path.append(ramp_foot)
	if _greeting:
		var away := politician.global_position - _greeting.global_position
		away.y = 0.0
		var side := away.normalized() if away.length() > 0.01 else Vector3.BACK
		_path.append(_greeting.global_position + side * GREET_AWAY)
	if _path.is_empty():
		_path.append(ramp_foot)


## Walks along _path; true once at its end.
func _follow_path(delta: float) -> bool:
	var to := _path[0] - politician.global_position
	to.y = 0.0
	if to.length() < ARRIVED:
		_path.remove_at(0)
		if _path.is_empty():
			_move(Vector3.ZERO, delta)
			return true
		return false
	_move(to.normalized() * SPEED, delta)
	return false


func _move(wish: Vector3, delta: float) -> void:
	if wish.length() > 0.05:
		politician.look_at(politician.global_position + wish, Vector3.UP)
	politician.velocity.x = wish.x
	politician.velocity.z = wish.z
	politician.velocity.y = 0.0 if politician.is_on_floor() else politician.velocity.y - GameScale.GRAVITY * delta
	politician.move_and_slide()
