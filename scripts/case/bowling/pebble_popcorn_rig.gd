extends BowlingRig

## The magic popcorn (allanamiento-bolera.md, "Las palomitas mágicas"): Don Chuza sells painted pebbles as premium
## popcorn. The machine rattles like a bag of stones and every SPIT_EVERY seconds spits a pebble that bounces across
## the floor (at most MAX lying around). A cop who picks one up bites it: «¡CRAC!» and a hurt tooth, and the first time,
## the clue. The sack of pebbles, the yellow paint and the receipt are hidden. Every number here is (propuesta).

const SPIT_EVERY := 6.0
const MAX := 10
const SPIT_SPEED := 2.5

var pebbles: Array[Grabbable] = []
var bitten := {}
var cracked := false
## How many pebbles were bitten and where the last one was (alley space): the guests show the «¡CRAC!» from it.
var bites := 0
var _bite_at := Vector3.ZERO
var _shown_bites := 0
var _since_spit := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: Bowling) -> void:
	super.setup(place)
	alley.main = alley.hidden[0]
	_rng.seed = alley.case_seed


func net_state() -> Variant:
	return {"cracked": cracked, "bites": bites, "at": _bite_at}


func apply_net_state(state: Variant) -> void:
	cracked = state.cracked
	if state.bites > _shown_bites:
		_shown_bites = state.bites
		_crack(state.at)


func _crack(at: Vector3) -> void:
	alley._say(at + Vector3.UP * 0.5, "BOWL_POPCORN_CRACK", 1.5)


## The machine coughs out one more pebble, up and away from its front.
func spit() -> Grabbable:
	var pebble := PopcornPebble.new()
	pebble.name = "Pebble%d" % pebbles.size()
	alley.add_child(pebble)
	pebble.position = Bowling.POPCORN_AT + Vector3(0, Bowling.POPCORN_SIZE.y + 0.1, 0)
	var out := Vector3(_rng.randf_range(-1.0, 1.0), 0, 1.0).normalized() * SPIT_SPEED
	pebble.linear_velocity = alley.global_basis * (out + Vector3.UP * SPIT_SPEED)
	pebbles.append(pebble)
	if pebbles.size() > MAX:
		var oldest: Grabbable = pebbles.pop_front()
		if not oldest.is_held():
			oldest.queue_free()
		else:
			pebbles.insert(0, oldest)
	alley._say(Bowling.POPCORN_AT + Vector3.UP * 1.4, "BOWL_POPCORN_RATTLE", 1.5)
	return pebble


func _physics_process(delta: float) -> void:
	_since_spit += delta
	if _since_spit >= SPIT_EVERY and multiplayer.is_server():
		_since_spit = 0.0
		spit()
	for pebble in pebbles:
		if not pebble.is_held() or bitten.has(pebble):
			continue
		bitten[pebble] = true
		bites += 1
		_shown_bites = bites
		_bite_at = alley.to_local(pebble.global_position)
		_crack(_bite_at)
		for cop in pebble.handling_cops(0.0):
			cop.show_hint("HINT_BOWL_POPCORN_BITE")
		if not cracked:
			cracked = true
			alley.raid.add_clue(tr("BOWL_POPCORN_CLUE"))
