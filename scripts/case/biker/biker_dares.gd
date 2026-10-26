class_name BikerDares
extends Node

## The biker bar's courage dares (infiltracion-motos.md, step 4, decision 176): FIRST seconds in and then every EVERY
## seconds a biker shouts a dare at a cop in the bar, the next of the three kinds in the order the seed gave them:
## - "arm": arm wrestling at the patio's table, E ARM_PUSHES times in ARM_TIME seconds;
## - "lift": the heavy bike up in the air for LIFT_HOLD seconds in a row, within LIFT_TIME (it takes two cops);
## - "still": standing on the line while a biker charges at it, without moving MOVE_REACH away before he brakes.
## The cop has JOIN seconds to get to the dare's place; not showing up ("¡Gallina!") makes the bikers suspicious, and
## failing it a little less; walking off in the middle counts as not showing up. While a dare is on, the bikers out of
## the patio turn to watch it and notice nothing else: the moment for the others to search. Passing it pleases the
## biker, who tells some gossip (step 5). The host decides all of it and tells the guests (step 6). Every number here
## is (propuesta).

signal challenged(kind: String, cop: Cop)
signal started(kind: String)
signal failed(amount: float)
signal passed(kind: String)

const KINDS: Array[String] = ["arm", "lift", "still"]
const FIRST := 20.0
const EVERY := 50.0
const JOIN := 15.0
const ARM_TIME := 8.0
const ARM_PUSHES := 15
const LIFT_TIME := 20.0
const LIFT_HOLD := 5.0
const NO_SHOW := 30.0
const FAIL := 20.0
## On the line, the cop may sway this much (m on the floor) before he counts as having moved.
const MOVE_REACH := 0.5
## This close (m, on the floor) to the dare's place he's there; further than LEAVE in the middle, he walked off.
const SPOT_REACH := 1.0
const LIFT_REACH := 2.5
const LEAVE := 3.0
const IDLE := 0
const WAITING := 1
const DOING := 2

var bar: BikerBar
var case_seed := 0
var state := IDLE
## Seconds to the next dare (host), and the order of the kinds and which comes next.
var next_left := FIRST
var order: Array[String] = []
var next_kind := 0
## The dare on: its kind, the biker who shouted it and the cop.
var kind := ""
var challenger: ClubMember
var cop: Cop
## Seconds left to get there and of the dare; the pushes so far; seconds the bike has been up; where he stood on the
## line.
var join_left := 0.0
var left := 0.0
var pushes := 0
var held := 0.0
var stood_at := Vector3.ZERO
var _watching: Array[ClubMember] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = hash(["biker dares", case_seed])
	order.assign(KINDS)
	for i in range(order.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap := order[i]
		order[i] = order[j]
		order[j] = swap
	bar.arm_table.pushed.connect(_on_pushed)
	bar.charge.braked.connect(_on_braked)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	match state:
		IDLE:
			next_left -= delta
			if next_left <= 0.0:
				challenge()
		WAITING:
			join_left -= delta
			if at_spot():
				_start()
			elif join_left <= 0.0:
				_fail(NO_SHOW, "BIKER_CHICKEN")
		DOING:
			_doing(delta)


## Host: a biker dares a cop in the bar (this one: tests and the debug panel) to the next kind. Nothing if there's no
## cop in the bar.
func challenge(who: Cop = null) -> bool:
	next_left = EVERY
	if state != IDLE:
		return false
	if not who:
		var inside := bar.get_tree().get_nodes_in_group("cops").filter(func(one: Cop) -> bool:
			return bar.is_inside(one.global_position))
		if inside.is_empty():
			return false
		who = inside[_rng.randi_range(0, inside.size() - 1)]
	cop = who
	kind = order[next_kind % order.size()]
	next_kind += 1
	challenger = bar.members[_rng.randi_range(0, bar.members.size() - 1)]
	state = WAITING
	join_left = JOIN
	challenger.say("BIKER_DARE_" + kind)
	cop.show_hint("HINT_BIKER_DARE_" + kind)
	challenged.emit(kind, cop)
	return true


## Where the dare is done, in the world.
func spot() -> Vector3:
	match kind:
		"arm":
			return bar.arm_table.global_transform * Vector3(0, 0, 0.6)
		"lift":
			return bar.heavy_bike.global_position
	return bar.global_transform * bar.line_at()


## Whether the dared cop is at the dare's place.
func at_spot() -> bool:
	return cop != null and _flat(cop.global_position, spot()) < (LIFT_REACH if kind == "lift" else SPOT_REACH)


func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _start() -> void:
	state = DOING
	pushes = 0
	held = 0.0
	match kind:
		"arm":
			left = ARM_TIME
			bar.arm_table.set_wrestling(true)
		"lift":
			left = LIFT_TIME
		"still":
			left = INF
			stood_at = cop.global_position
			bar.charge.charge()
	_watch(true)
	started.emit(kind)


func _doing(delta: float) -> void:
	if _flat(cop.global_position, spot()) > LEAVE and kind != "still":
		_fail(NO_SHOW, "BIKER_CHICKEN")
		return
	left -= delta
	match kind:
		"arm":
			bar.arm_table.set_lean(float(pushes) / ARM_PUSHES - (1.0 - left / ARM_TIME))
			if left <= 0.0:
				_fail(FAIL, "BIKER_ARM_LOST")
		"lift":
			held = held + delta if bar.heavy_bike.lifted() else 0.0
			if held >= LIFT_HOLD:
				_pass()
			elif left <= 0.0:
				_fail(FAIL, "BIKER_LIFT_FAILED")
		"still":
			if _flat(cop.global_position, stood_at) > MOVE_REACH:
				_fail(FAIL, "BIKER_MOVED")


func _on_pushed(by: Cop) -> void:
	if state != DOING or kind != "arm" or by != cop:
		return
	pushes += 1
	if pushes >= ARM_PUSHES:
		_pass()


func _on_braked() -> void:
	if state == DOING and kind == "still":
		_pass()


## The dare passed: the biker is pleased and tells some gossip (step 5).
func _pass() -> void:
	var done := kind
	challenger.say(tip())
	_end()
	passed.emit(done)


## What a pleased biker says (step 5 makes it gossip about the evidence).
func tip() -> String:
	return "BIKER_RESPECT"


## The dare failed: `line` from the biker and the bikers in the bar get suspicious.
func _fail(amount: float, line: String) -> void:
	challenger.say(line)
	_end()
	for member in bar.members:
		if bar.is_inside(member.global_position + Vector3.UP):
			bar.suspicion.raise(member, amount)
	failed.emit(amount)


## While a dare is on, the bikers out of the patio turn to watch it and notice nothing else.
func _watch(on: bool) -> void:
	if on:
		for member in bar.members:
			if not member.distracted and not bar.in_patio(member.global_position + Vector3.UP):
				member.distracted = true
				_watching.append(member)
	else:
		for member in _watching:
			member.distracted = false
		_watching.clear()


func _end() -> void:
	_watch(false)
	bar.arm_table.set_wrestling(false)
	bar.charge.back()
	state = IDLE
	next_left = EVERY
	kind = ""
