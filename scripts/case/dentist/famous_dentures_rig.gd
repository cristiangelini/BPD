class_name FamousDenturesRig
extends DentistRaidRig

## The famous dentures (allanamiento-dentista.md, "Las dentaduras famosas"): Dr. Molina copies his famous patients'
## dentures and sells the copies to their fans. The briefcase of copies is hidden; a chattering denture on his desk
## clacks by itself, the story's own clue (on the checklist the first time a cop comes close); and WALKERS wind-up
## dentures walk the front of the office (drawn with the seed) and bite the shoes of a cop they reach: it walks slowly
## for BITE_TIME seconds. Every number here is (propuesta).

const TEETH_MODEL := preload("res://assets/models/chatter_teeth.glb")
const F := DentistRaid.FLOOR_TOP
const WALKERS := 4
## Where they walk: the corridor and the waiting room, in the office's space.
const AREA := Rect2(-10.0, 1.4, 20.0, 6.0)
const SPEED := 0.6
const REACH := 0.1
const BITE_RANGE := 0.45
const BITE_TIME := 3.0
const BITE_SLOW := 0.4
const BITE_AGAIN := 6.0
## The chattering denture on the desk: how often it clacks, for how long, and how close a cop notices it.
const DESK_TEETH := DentistRaid.DESK_AT + Vector3(-0.6, DentistRaid.DESK_SIZE.y, 0.2)
const CLACK_EVERY := 3.0
const CLACK_TIME := 1.0
const CLACK_RANGE := 2.0

var walkers: Array[Node3D] = []
var bites := 0
var heard_clacks := false
var desk_teeth: Node3D
var clack: Label3D
var _targets: Array[Vector3] = []
var _rng := RandomNumberGenerator.new()
## Cop -> seconds left walking slowly, and seconds until it can be bitten again.
var _slow := {}
var _wait := {}
var _since_clack := 0.0


func setup(place: DentistRaid) -> void:
	super.setup(place)
	_rng.seed = hash(["famous dentures", place.case_seed])
	for i in WALKERS:
		var walker: Node3D = TEETH_MODEL.instantiate()
		walker.scale = Vector3.ONE * 1.5
		walker.position = _random_point()
		place.add_child(walker)
		walkers.append(walker)
		_targets.append(_random_point())
	desk_teeth = TEETH_MODEL.instantiate()
	desk_teeth.position = DESK_TEETH
	place.add_child(desk_teeth)
	clack = Label3D.new()
	clack.text = "DESK_CLACK"
	clack.font_size = 48
	clack.pixel_size = 0.003
	clack.outline_size = 10
	clack.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	clack.position = DESK_TEETH + Vector3.UP * 0.35
	clack.visible = false
	place.add_child(clack)


func _physics_process(delta: float) -> void:
	_clack(delta)
	_tick_bites(delta)
	# The host's dentures walk; the guests' ones follow (net_state).
	if multiplayer.is_server():
		_walk(delta)
	for walker: Node3D in walkers:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if is_mine(cop) and not _wait.has(cop) and _near_floor(cop, walker.position, BITE_RANGE):
				bite(cop)


## Bites `cop`'s shoe: it walks slowly for BITE_TIME seconds.
func bite(cop: Cop) -> void:
	bites += 1
	_slow[cop] = BITE_TIME
	_wait[cop] = BITE_AGAIN
	cop.slow_factor = BITE_SLOW
	cop.show_hint("HINT_DENTURE_BITE")


func is_slowed(cop: Cop) -> bool:
	return _slow.has(cop)


func _walk(delta: float) -> void:
	for i in walkers.size():
		var to := _targets[i] - walkers[i].position
		to.y = 0.0
		if to.length() <= REACH:
			_targets[i] = _random_point()
			continue
		walkers[i].position += to.normalized() * minf(SPEED * delta, to.length())
		walkers[i].look_at(office.to_global(_targets[i]), Vector3.UP, true)


func _tick_bites(delta: float) -> void:
	for cop: Variant in _slow.keys():
		_slow[cop] -= delta
		if _slow[cop] <= 0.0 or not is_instance_valid(cop):
			_slow.erase(cop)
			if is_instance_valid(cop):
				(cop as Cop).slow_factor = 1.0
	for cop: Variant in _wait.keys():
		_wait[cop] -= delta
		if _wait[cop] <= 0.0 or not is_instance_valid(cop):
			_wait.erase(cop)


## The desk's denture clacks now and then; the first time a cop is close it's a clue.
func _clack(delta: float) -> void:
	_since_clack = fmod(_since_clack + delta, CLACK_EVERY)
	var on := _since_clack < CLACK_TIME
	clack.visible = on
	desk_teeth.rotation.y = sin(_since_clack * 40.0) * 0.3 if on else 0.0
	if heard_clacks:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if office.to_local(cop.global_position).distance_to(DESK_TEETH) < CLACK_RANGE:
			heard_clacks = true
			office.raid.add_clue(tr("CLUE_DESK_CHATTER"))
			return


func _random_point() -> Vector3:
	return Vector3(_rng.randf_range(AREA.position.x, AREA.end.x), F, _rng.randf_range(AREA.position.y, AREA.end.y))


func _near_floor(cop: Cop, at: Vector3, within: float) -> bool:
	var from := office.to_local(cop.global_position)
	return Vector2(from.x - at.x, from.z - at.z).length() < within and absf(from.y - at.y) < 0.6


## This PC's player's cop (offline, every cop): the bite only slows a player's own body.
static func is_mine(cop: Cop) -> bool:
	return not cop.sync or not cop.sync.is_inside_tree() or cop.sync.is_multiplayer_authority()


func net_state() -> Variant:
	return walkers.map(func(walker: Node3D) -> Vector3: return walker.position)


func apply_net_state(state: Variant) -> void:
	for i in mini(state.size(), walkers.size()):
		walkers[i].position = state[i]
