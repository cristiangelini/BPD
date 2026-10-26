class_name VipRequests
extends Node

## What Rulo Brillantina asks for during his day (carcel-vip.md, step 3). Once the first cop walks through the gate he
## rings his little bell every EVERY seconds and asks for the next of his REQUESTS (6 of the 10, drawn by the seed), in
## his bubble and on the board over his bars, with LIMIT seconds to bring it. Things go on the shelf of his bars
## (VipTray); the foot massage is MASSAGE presses of E on the shelf, the applause two cops pressing it at once (one,
## playing alone), the song a cop singing or humming (H) near his bars for SONG_TIME seconds. His mood starts at
## MOOD_START out of 100: ON_TIME more for each one brought in time, LATE less and a tantrum for each one that runs
## out. Every number here is (propuesta).

signal asked_for(kind: Kind)
signal fulfilled(kind: Kind, item: Grabbable)
signal ran_out(kind: Kind)
## His mood hit 0 (step 4: he calls his lawyer).
signal mood_zero
## His last request was brought or ran out (step 5: his manager comes for him).
signal all_done

enum Kind { WATER, PILLOW, CAKE, MIRROR, GUITAR, FLOWERS, GLASSES, MASSAGE, APPLAUSE, SONG }

const REQUESTS := 6
const FIRST := 3.0
const EVERY := 45.0
const LIMIT := 60.0
const MOOD_START := 60
const MOOD_MAX := 100
const ON_TIME := 20
const LATE := 25
const MASSAGE := 5
const CLAP_WINDOW := 2.0
const SONG_TIME := 5.0
const SING_RANGE := 4.0

var plan: VipPlan
## The seed's 6, in order.
var order: Array[Kind] = []
var asked := 0
## The open ones: {"kind": Kind, "left": seconds}.
var open: Array[Dictionary] = []
var on_time := 0
var late := 0
var mood := MOOD_START
var started := false
var finished := false
## A guest's copy (step 7): the host's one decides.
var follower := false
var next_left := FIRST
var _massage := 0
var _claps := {}
var _sung := 0.0
var board: Label3D


func setup(vip: VipPlan, rng: RandomNumberGenerator) -> void:
	plan = vip
	add_to_group("vip_requests")
	var all: Array = Kind.values()
	for i in range(all.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = all[i]
		all[i] = all[j]
		all[j] = swap
	for kind: int in all.slice(0, REQUESTS):
		order.append(kind as Kind)
	board = Label3D.new()
	board.name = "Board"
	board.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	board.pixel_size = 0.004
	board.outline_size = 8
	board.font_size = 32
	board.modulate = Color(1.0, 0.85, 0.4)
	board.position = plan.cell_point(0.0) + Vector3.UP * 2.4
	plan.add_child(board)
	_show_board()


## Which request a thing brought is (-1 for anything else).
static func kind_of(item: Node) -> int:
	if item is VipGift:
		return [Kind.WATER, Kind.PILLOW, Kind.MIRROR, Kind.GLASSES][(item as VipGift).kind]
	if item is VisitItem:
		return {VisitItem.Kind.CAKE: Kind.CAKE, VisitItem.Kind.GUITAR: Kind.GUITAR,
			VisitItem.Kind.FLOWERS: Kind.FLOWERS}.get((item as VisitItem).kind, -1)
	return -1


func is_open(kind: Kind) -> bool:
	return open.any(func(each: Dictionary) -> bool: return each.kind == kind)


func start() -> void:
	started = true


func _process(delta: float) -> void:
	if follower or finished:
		return
	if not started:
		if plan.prison.get_tree().get_nodes_in_group("cops").any(
				func(cop: Node3D) -> bool: return plan.prison.inside_walls(cop.global_position)):
			start()
		return
	next_left -= delta
	if next_left <= 0.0 and asked < REQUESTS:
		next_left = EVERY
		ask_next()
	for each in open.duplicate():
		each.left -= delta
		if each.left <= 0.0:
			_run_out(each)
	if asked == REQUESTS and open.is_empty():
		finished = true
		all_done.emit()
	_show_board()


## The bell, and the next request (the debug panel's shortcut, once it exists).
func ask_next() -> void:
	if asked >= REQUESTS:
		return
	var kind := order[asked]
	asked += 1
	open.append({"kind": kind, "left": LIMIT})
	if kind == Kind.MASSAGE:
		_massage = 0
	if kind == Kind.SONG:
		_sung = 0.0
	plan.rulo.say("VIP_ASK_%s" % Kind.keys()[kind], 5.0)
	asked_for.emit(kind)
	_show_board()


## Something left on the shelf: his if it's one of the open ones, or he wants none of it.
func offered(item: Grabbable) -> void:
	if follower:
		return
	var kind := kind_of(item)
	if kind < 0 or not is_open(kind):
		plan.rulo.say("VIP_RULO_NOT_THAT")
		return
	plan.take(item)
	_fulfill(kind, item)


## E on the shelf with nothing in hand: the massage or the applause, whichever he asked for first.
func pressed(cop: Cop) -> void:
	if follower:
		return
	for each in open:
		if each.kind == Kind.MASSAGE:
			_massage += 1
			plan.rulo.say("VIP_RULO_MASSAGE", 1.5)
			if _massage >= MASSAGE:
				_fulfill(Kind.MASSAGE, null)
			return
		if each.kind == Kind.APPLAUSE:
			var now := Time.get_ticks_msec()
			_claps[cop] = now
			var cops := plan.prison.get_tree().get_nodes_in_group("cops").size()
			var clapping := _claps.values().filter(func(at: int) -> bool: return now - at <= CLAP_WINDOW * 1000.0)
			plan.rulo.say("VIP_RULO_CLAP", 1.5)
			if clapping.size() >= mini(2, maxi(cops, 1)):
				_claps.clear()
				_fulfill(Kind.APPLAUSE, null)
			return
	plan.rulo.say("VIP_RULO_WHAT")


## A cop singing or humming (VoiceChat, every SING_EVERY seconds): near his bars, it's his song.
func heard_singing(cop: Node3D) -> void:
	if follower or not is_open(Kind.SONG):
		return
	if cop.global_position.distance_to(plan.tray.global_position) > SING_RANGE:
		return
	_sung += VoiceChat.SING_EVERY
	if _sung >= SONG_TIME:
		_fulfill(Kind.SONG, null)


func tray_prompt(cop: Cop) -> String:
	if cop.get_node("Grabber").held:
		return "PROMPT_VIP_TRAY_PUT"
	if is_open(Kind.MASSAGE):
		return "PROMPT_VIP_MASSAGE"
	if is_open(Kind.APPLAUSE):
		return "PROMPT_VIP_APPLAUD"
	return ""


func _fulfill(kind: Kind, item: Grabbable) -> void:
	for each in open:
		if each.kind == kind:
			open.erase(each)
			break
	on_time += 1
	_set_mood(mood + ON_TIME)
	plan.rulo.say("VIP_THANKS_%s" % Kind.keys()[kind], 4.0)
	fulfilled.emit(kind, item)
	_show_board()


func _run_out(each: Dictionary) -> void:
	open.erase(each)
	late += 1
	_set_mood(mood - LATE)
	plan.rulo.tantrum()
	ran_out.emit(each.kind)


func _set_mood(to: int) -> void:
	var was := mood
	mood = clampi(to, 0, MOOD_MAX)
	if mood == 0 and was > 0:
		mood_zero.emit()


func _show_board() -> void:
	var lines: Array[String] = [tr("VIP_BOARD") % mood]
	for each in open:
		lines.append("%s  %d s" % [tr("VIP_WANT_%s" % Kind.keys()[each.kind]), ceili(each.left)])
	board.text = "\n".join(lines)
