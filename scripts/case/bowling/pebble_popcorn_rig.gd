extends BowlingRig

## The magic popcorn (allanamiento-bolera.md, "Las palomitas mágicas"): Don Chuza sells painted pebbles as premium
## popcorn. The machine rattles like a bag of stones and every SPIT_EVERY seconds spits a pebble that bounces across
## the floor (at most MAX lying around). A cop who picks one up bites it: «¡CRAC!» and a hurt tooth, and the first time,
## the clue. The sack of pebbles, the yellow paint and the receipt are hidden. Every number here is (propuesta).

const PEBBLE_MODEL := preload("res://assets/models/popcorn_pebble.glb")
const PEBBLE_SIZE := Vector3(0.06, 0.05, 0.05)
const PEBBLE_KG := 0.05
const SPIT_EVERY := 6.0
const MAX := 10
const SPIT_SPEED := 2.5
const BOUNCE := 0.8

var pebbles: Array[Grabbable] = []
var bitten := {}
var cracked := false
var _since_spit := 0.0
var _rng := RandomNumberGenerator.new()
var _bouncy: PhysicsMaterial


func setup(place: Bowling) -> void:
	super.setup(place)
	alley.main = alley.hidden[0]
	_rng.seed = alley.case_seed
	_bouncy = PhysicsMaterial.new()
	_bouncy.bounce = BOUNCE


## The machine coughs out one more pebble, up and away from its front.
func spit() -> Grabbable:
	var pebble := ClubEvidence.make_item("Pebble%d" % pebbles.size(), PEBBLE_MODEL, PEBBLE_SIZE, PEBBLE_KG)
	(pebble.get_child(1) as Node3D).position.y = -PEBBLE_SIZE.y / 2
	pebble.physics_material_override = _bouncy
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
		alley._say(alley.to_local(pebble.global_position) + Vector3.UP * 0.5, "BOWL_POPCORN_CRACK", 1.5)
		for cop in pebble.handling_cops(0.0):
			cop.show_hint("HINT_BOWL_POPCORN_BITE")
		if not cracked:
			cracked = true
			alley.raid.add_clue(tr("BOWL_POPCORN_CLUE"))
