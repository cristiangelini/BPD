class_name AirportDeputy
extends Node

## Deputy Lustre at the airport (politico-aeropuerto.md, step 4, decision 231): he starts at the glass wall looking at
## the plane. Once the belt starts, every so often he wanders off to the duty-free shop and goes from shelf to shelf
## trying on perfume and sunglasses. E takes him by the hand and he follows that cop, complaining; walked into the gate,
## he sits there and waits, until he gets bored and wanders off again. Let go anywhere else, he goes back to the shop.
## It hangs off the politician as "Errands" and moves him itself. Every number here is (propuesta).

signal wandered_off
signal at_gate

enum State { WAITING, WALKING, BROWSING, LED, SITTING }

## The first wander waits this long after the belt starts; then he waits this long (at the gate, give or take JITTER)
## before the next one.
const FIRST_WANDER := 20.0
const WANDER_EVERY := 50.0
const JITTER := 10.0
const SPEED := 1.4
const LED_SPEED := 1.8
const KEEP_AWAY := 1.2
const ARRIVED := 0.5
## In front of each shelf this long, saying one of SHOP_LINES.
const BROWSE_TIME := 7.0
const SHOP_LINES := 5
const LED_LINES := 3
const COMPLAIN_EVERY := 5.0
## Where he starts, looking at the plane through the glass wall.
const START_AT := Vector3(0, 0, 1.0)

var airport: Airport
var politician: Politician
var state := State.WAITING
var led_by: Cop
var running := false
## Online, a guest's: the host's moves him.
var follower := false
var _path: Array[Vector3] = []
var _left := FIRST_WANDER
var _complain_left := 0.0
var _line := 0
var _rng := RandomNumberGenerator.new()


static func of(body: Node) -> AirportDeputy:
	return body.get_node_or_null("Errands") as AirportDeputy


static func attach(the_airport: Airport, speaker: Politician, case_seed: int) -> AirportDeputy:
	var errands := AirportDeputy.new()
	errands.name = "Errands"
	errands.airport = the_airport
	errands.politician = speaker
	errands._rng.seed = hash(["airport deputy", case_seed])
	speaker.add_child(errands)
	return errands


## The clock is on: he starts wandering.
func start() -> void:
	running = true
	_left = FIRST_WANDER


func in_shop() -> bool:
	return airport.in_shop(politician.global_position)


func at_the_gate() -> bool:
	return airport.at_gate(politician.global_position)


func prompt_key(cop: Cop) -> String:
	if state == State.LED:
		return "PROMPT_LET_GO_POLITICIAN" if led_by == cop else "PROMPT_LEAD_POLITICIAN"
	return "PROMPT_LEAD_POLITICIAN"


## E: takes him by the hand, or lets go of him (out of the gate, he goes back to the shop).
func use(cop: Cop) -> void:
	if follower:
		return
	if led_by == cop:
		led_by = null
		if at_the_gate():
			_sit()
		else:
			wander()
		return
	led_by = cop
	state = State.LED
	_complain_left = COMPLAIN_EVERY
	_complain()


## Off to the shop now.
func wander() -> void:
	led_by = null
	state = State.WALKING
	_path = [_shelf_spot()]
	if not in_shop():
		politician.say("AIRPORT_DEPUTY_OFF")
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			cop.show_hint("HINT_AIRPORT_DEPUTY_OFF")
		wandered_off.emit()


func _physics_process(delta: float) -> void:
	if follower or not politician.visible:
		return
	match state:
		State.WAITING, State.SITTING:
			_move(Vector3.ZERO, delta)
			if running:
				_left -= delta
				if _left <= 0.0:
					wander()
		State.WALKING:
			if _follow_path(delta):
				state = State.BROWSING
				_left = BROWSE_TIME
				politician.say("AIRPORT_DEPUTY_SHOP_%d" % _rng.randi_range(1, SHOP_LINES))
		State.BROWSING:
			_move(Vector3.ZERO, delta)
			_left -= delta
			if _left <= 0.0:
				state = State.WALKING
				_path = [_shelf_spot()]
		State.LED:
			_led(delta)


func _led(delta: float) -> void:
	var to := led_by.global_position - politician.global_position
	to.y = 0.0
	_move(to.normalized() * LED_SPEED if to.length() > KEEP_AWAY else Vector3.ZERO, delta)
	if at_the_gate():
		var cop := led_by
		led_by = null
		cop.stats["deputy_to_gate"] = cop.stats.get("deputy_to_gate", 0) + 1
		_sit()
		return
	_complain_left -= delta
	if _complain_left <= 0.0:
		_complain_left = COMPLAIN_EVERY
		_complain()


func _complain() -> void:
	politician.say("POLITICIAN_LED_%d" % (_line % LED_LINES + 1), 3.0)
	_line += 1


## At the gate: he sits and waits a while.
func _sit() -> void:
	state = State.SITTING
	_left = WANDER_EVERY + _rng.randf_range(-JITTER, JITTER)
	politician.say("AIRPORT_DEPUTY_GATE")
	at_gate.emit()


## In front of a shelf he isn't at.
func _shelf_spot() -> Vector3:
	var spots: Array[Vector3] = []
	for shelf in Airport.SHELVES:
		var spot := airport.to_global(shelf + Vector3(0, Airport.FLOOR_TOP, 1.0))
		if Vector2(spot.x - politician.global_position.x, spot.z - politician.global_position.z).length() > 1.5:
			spots.append(spot)
	return spots[_rng.randi_range(0, spots.size() - 1)]


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
