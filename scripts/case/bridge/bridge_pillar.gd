class_name BridgePillar
extends StaticBody3D

## One of the bridge's pillars in the canal (politico-puente.md, step 4, decision 178). Sunk (BridgeBreaks), two cops
## holding E on it together push it straight in PUSH_TIME seconds; one alone can't. Letting go keeps how far it went.
## Every number here is (propuesta).

const PUSH_TIME := 4.0
const HANDS := 2
## A cop pushing it walks off past this (m) and lets go.
const REACH := 2.0

## Its place from the west (BridgePark.PILLARS).
var index := 0
## How far it's pushed back up (0 to 1).
var pushed := 0.0
## The cops holding E on it.
var turners: Array[Cop] = []


func _breaks() -> BridgeBreaks:
	var park := get_parent().get_parent() as BridgePark
	return park.breaks if park else null


func sunk() -> bool:
	var breaks := _breaks()
	return breaks != null and breaks.sagging.has(index)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PUSH_PILLAR" if sunk() else ""


## E pressed: this cop puts their shoulder to it until they let go of E (end_turn).
func use(cop: Cop) -> void:
	if not sunk() or turners.has(cop):
		return
	if turners.size() >= HANDS:
		return
	turners.append(cop)
	cop.turning = self
	cop.show_hint("HINT_PILLAR_PUSH" if turners.size() >= HANDS else "HINT_PILLAR_ALONE")


## E let go (or walked off).
func end_turn(cop: Cop) -> void:
	turners.erase(cop)
	if is_instance_valid(cop) and cop.turning == self:
		cop.turning = null


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	for cop in turners.duplicate():
		if not is_instance_valid(cop) or cop.turning != self \
				or Vector2(cop.global_position.x - global_position.x, cop.global_position.z - global_position.z).length() \
				> REACH:
			end_turn(cop)
	if not sunk():
		pushed = 0.0
		for cop in turners.duplicate():
			end_turn(cop)
		return
	if turners.size() < HANDS:
		return
	pushed = minf(pushed + delta / PUSH_TIME, 1.0)
	if pushed >= 1.0:
		pushed = 0.0
		_breaks().straighten(index)
		for cop in turners.duplicate():
			end_turn(cop)
			cop.show_hint("HINT_PILLAR_DONE")
