class_name WeddingWaltz
extends Node

## The waltz (escena-boda.md, "El vals"): every WALTZ_EVERY of the case, DJ Bombo announces it WARN before, and for
## LENGTH Rosa drags Tito to the middle of the dance floor and the five groomsmen dance around them. While they dance,
## E on a suspect gets nothing ("¡Ahora no, es el vals!"). A cop who dances on the floor (jumps twice) makes Rosa laugh
## and takes DANCE_OFF off the family's complaint, once per waltz. Timed on the case's clock, so every PC waltzes
## together. Every number here is (propuesta).

const WALTZ_EVERY := 120.0
const LENGTH := 20.0
const WARN := 3.0
## How far from the floor's middle the groomsmen dance.
const RING := 2.5
const SPIN := 1.5
const JUMPS := 2
const DANCE_OFF := 5

var hall: WeddingHall
var case: CrimeSceneCase
var dancing := false
var warned := false
## The waltz number now (or the last one), from 1.
var waltz := 0
## The cops who danced this waltz, and each cop's jumps on the floor and whether he was in the air.
var danced := {}
var _jumps := {}
var _in_air := {}
## Where each dancer stood before the waltz.
var _home := {}


## Whether a waltz is on at this many seconds of the case: from each WALTZ_EVERY, for LENGTH.
static func on_at(seconds: float) -> bool:
	return seconds >= WALTZ_EVERY and fmod(seconds, WALTZ_EVERY) < LENGTH


func _physics_process(delta: float) -> void:
	if not case.tip_given or case.accused or case.lost:
		if dancing:
			stop()
		return
	if not warned and case.elapsed + WARN >= WALTZ_EVERY * (waltz + 1):
		warned = true
		hall.dj.say("WEDDING_DJ_WALTZ")
	if on_at(case.elapsed) and not dancing:
		start()
	elif not on_at(case.elapsed) and dancing:
		stop()
	if dancing:
		_spin(delta)
		_watch_cops()


func start() -> void:
	dancing = true
	waltz += 1
	danced.clear()
	_jumps.clear()
	var middle := Vector3(PartyHall.DANCE.get_center().x, WeddingHall.FLOOR_TOP, PartyHall.DANCE.get_center().y)
	var dancers: Array[WeddingPerson] = [hall.bride]
	dancers.append_array(hall.tuxedos)
	for dancer in dancers:
		_home[dancer] = dancer.position
	hall.bride.dancing = true
	hall.bride.position = middle + Vector3(0.45, 0, 0)
	for tuxedo in hall.tuxedos:
		tuxedo.dancing = true
		if tuxedo.traits.groom:
			tuxedo.position = middle - Vector3(0.45, 0, 0)
		else:
			var turn := TAU * tuxedo.index / (hall.tuxedos.size() - 1)
			tuxedo.position = middle + Vector3(sin(turn), 0, cos(turn)) * RING


func stop() -> void:
	dancing = false
	warned = false
	for dancer: WeddingPerson in _home:
		dancer.position = _home[dancer]
		dancer.rotation.y = 0.0
	_home.clear()
	hall.bride.dancing = false
	for tuxedo in hall.tuxedos:
		tuxedo.dancing = false


func _spin(delta: float) -> void:
	for dancer: WeddingPerson in _home:
		dancer.rotation.y += SPIN * delta


## A cop on the dance floor who jumps JUMPS times danced: once per waltz, Rosa laughs and the complaint goes down.
func _watch_cops() -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var at := hall.to_local(cop.global_position)
		var on_floor := PartyHall.DANCE.has_point(Vector2(at.x, at.z))
		var up := not cop.is_on_floor()
		if on_floor and up and not _in_air.get(cop, false):
			_jumps[cop] = _jumps.get(cop, 0) + 1
		_in_air[cop] = up
		if _jumps.get(cop, 0) >= JUMPS and not danced.has(cop):
			cop_danced(cop)


func cop_danced(cop: Node) -> void:
	danced[cop] = true
	if case.follower:
		return
	case.complaint = maxi(case.complaint - DANCE_OFF, 0)
	hall.bride.say("BRIDE_LOVES_DANCE")
