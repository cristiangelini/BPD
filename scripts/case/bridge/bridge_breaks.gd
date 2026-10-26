class_name BridgeBreaks
extends Node

## The bridge falls apart (politico-puente.md, step 3, decision 178): FIRST seconds after the deputy starts and then
## every EVERY seconds something breaks, drawn by the seed among what's still whole. It creaks and shakes WARN seconds
## first, then:
## - a span loses its 2 planks: they fall into the canal as loose planks (LoosePlank) and leave a 2 m hole;
## - a pillar sinks SINK m and the 2 spans over it sag; if nobody straightens it (`straighten`, step 4) in TILT_FALL
##   seconds, both spans lose their planks;
## - a railing piece comes loose and falls into the water.
## Each of the deputy's jumps for the photo (BridgeCeremony.jumped) also breaks the span just ahead of him. Nothing
## breaks before he starts or after the ribbon. Online (step 7) only the host's breaks anything: a guest's follows what
## the host's bridge shows (`state`, `follow`, through BridgeCase's snapshot) and shakes what creaks there. Every
## number here is (propuesta).

signal warned(kind: String, index: int)
## `kind` "span", "pillar" or "rail", and which (a span, a pillar or a railing piece by index).
signal broke(kind: String, index: int)
## A sagging pillar's 2 spans fell because nobody straightened it.
signal collapsed(pillar: int)

const FIRST := 20.0
const EVERY := 15.0
const WARN := 3.0
const SHAKE := 0.03
const SINK := 0.4
const SAG := 0.3
const TILT_FALL := 30.0
## How often each kind is drawn, out of their sum.
const WEIGHTS := {"span": 3, "pillar": 1, "rail": 1}

var park: BridgePark
var ceremony: BridgeCeremony
## Seconds to the next break, while the deputy is on.
var next_left := FIRST
var running := false
## What's creaking now: [kind, index, seconds left]; several can (a jump during another's warning).
var warnings: Array = []
## The pillars sunk and not yet straightened: pillar index -> seconds left before its spans fall.
var sagging := {}
## How many pieces broke, all kinds.
var breaks := 0
var _rng := RandomNumberGenerator.new()
## Each shaking piece's place when whole.
var _rest := {}
## Each pillar's height when standing.
var _pillar_y: Array[float] = []


func setup(the_park: BridgePark, the_ceremony: BridgeCeremony, case_seed: int) -> void:
	park = the_park
	ceremony = the_ceremony
	_rng.seed = hash(["bridge breaks", case_seed])
	for pillar in park.pillars:
		_pillar_y.append(pillar.position.y)
	ceremony.started.connect(func() -> void: running = true)
	ceremony.finished.connect(func() -> void: running = false)
	ceremony.jumped.connect(_on_jumped)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		for warning: Array in warnings:
			_shake(warning[0], warning[1], true)
		return
	for warning: Array in warnings.duplicate():
		warning[2] -= delta
		_shake(warning[0], warning[1], warning[2] > 0.0)
		if warning[2] <= 0.0:
			warnings.erase(warning)
			_break(warning[0], warning[1])
	for pillar: int in sagging.keys():
		sagging[pillar] -= delta
		if sagging[pillar] <= 0.0:
			sagging.erase(pillar)
			for span in spans_over(pillar):
				_drop_span(span)
			collapsed.emit(pillar)
	if not running or ceremony.state == BridgeCeremony.State.OVER:
		return
	next_left -= delta
	if next_left <= 0.0:
		next_left = EVERY
		_pick()


## Whether span `span` still has both planks.
func whole(span: int) -> bool:
	return park.plank(span, 0) != null and park.plank(span, 1) != null


## The 2 spans a pillar holds up, from the west.
static func spans_over(pillar: int) -> Array[int]:
	var x := BridgePark.PILLARS[pillar]
	var east := roundi((x + BridgePark.SPANS * BridgePark.SPAN / 2) / BridgePark.SPAN)
	return [east - 1, east]


## Starts the creak of `kind` `index`: it breaks WARN seconds later.
func warn(kind: String, index: int) -> void:
	for warning: Array in warnings:
		if warning[0] == kind and warning[1] == index:
			return
	warnings.append([kind, index, WARN])
	warned.emit(kind, index)


## A pillar straightened (step 4): back up, the spans level again and they no longer fall.
func straighten(pillar: int) -> void:
	if not sagging.has(pillar):
		return
	sagging.erase(pillar)
	park.pillars[pillar].position.y += SINK
	sag(pillar, 0.0)


func _on_jumped(_index: int, at: Vector3) -> void:
	var x := park.to_local(at).x
	for span in BridgePark.SPANS:
		if BridgePark.span_x(span) - BridgePark.SPAN / 2 > x and whole(span) and not _warned("span", span):
			warn("span", span)
			return


## Draws what breaks next among what's whole and not already creaking.
func _pick() -> void:
	var choices := {"span": [], "pillar": [], "rail": []}
	for span in BridgePark.SPANS:
		if whole(span) and not _warned("span", span):
			choices.span.append(span)
	for pillar in BridgePark.PILLARS.size():
		if not sagging.has(pillar) and not _warned("pillar", pillar) and spans_over(pillar).all(whole):
			choices.pillar.append(pillar)
	for rail in park.rails.size():
		if park.rails[rail] != null and not _warned("rail", rail):
			choices.rail.append(rail)
	var total := 0
	for kind: String in WEIGHTS:
		if not choices[kind].is_empty():
			total += WEIGHTS[kind]
	if total == 0:
		return
	var roll := _rng.randi_range(1, total)
	for kind: String in WEIGHTS:
		if choices[kind].is_empty():
			continue
		roll -= WEIGHTS[kind]
		if roll <= 0:
			var list: Array = choices[kind]
			warn(kind, list[_rng.randi_range(0, list.size() - 1)])
			return


func _warned(kind: String, index: int) -> bool:
	return warnings.any(func(w: Array) -> bool: return w[0] == kind and w[1] == index)


func _break(kind: String, index: int) -> void:
	match kind:
		"span":
			if not whole(index):
				return
			_drop_span(index)
		"pillar":
			park.pillars[index].position.y -= SINK
			sag(index, SAG)
			sagging[index] = TILT_FALL
		"rail":
			var rail := park.rails[index]
			if rail == null:
				return
			park.rails[index] = null
			_fall(rail)
	breaks += 1
	broke.emit(kind, index)


## Both planks of `span` fall into the canal.
func _drop_span(span: int) -> void:
	for slot in BridgePark.PLANKS_PER_SPAN:
		var plank := park.plank(span, slot)
		if plank == null:
			continue
		park.planks[span * BridgePark.PLANKS_PER_SPAN + slot] = null
		var loose := LoosePlank.new()
		loose.name = "Loose%s" % plank.name
		park.add_child(loose)
		loose.global_transform = plank.global_transform
		# Tipped up on its edge so it slips between the stringers it rested on.
		loose.rotate(park.global_basis.x, 1.2 * (1 if slot == 0 else -1))
		# Away from the pillars at the span's ends, toward its middle.
		var inward := signf(BridgePark.span_x(span) - plank.position.x)
		loose.apply_central_impulse(park.global_basis.x * inward * LoosePlank.KG * 1.5)
		loose.apply_torque_impulse(Vector3(_rng.randf_range(-3, 3), 0, _rng.randf_range(-3, 3)))
		_rest.erase(plank)
		plank.queue_free()


## What a guest's bridge needs to look like the host's: which planks and railing pieces are still on, each pillar
## (0 standing, 1 sunk and sagging, 2 sunk with its spans fallen) and what's creaking.
func state() -> Dictionary:
	var planks := []
	for plank in park.planks:
		planks.append(plank != null)
	var rails := []
	for rail in park.rails:
		rails.append(rail != null)
	var pillars := []
	for i in park.pillars.size():
		pillars.append(1 if sagging.has(i) else (2 if park.pillars[i].position.y < _pillar_y[i] - SINK / 2 else 0))
	var creaking := []
	for warning: Array in warnings:
		creaking.append([warning[0], warning[1]])
	return {"planks": planks, "rails": rails, "pillars": pillars, "warnings": creaking}


## A guest's bridge: made like the host's. The planks that fell come as loose planks from the host (PropSync), so here
## they only go; the railing pieces fall here as they did there.
func follow(host: Dictionary) -> void:
	for i in park.planks.size():
		var on: bool = host.planks[i]
		var plank := park.planks[i]
		if on and plank == null:
			park.restore_plank(i / BridgePark.PLANKS_PER_SPAN, i % BridgePark.PLANKS_PER_SPAN)
		elif not on and plank != null:
			park.planks[i] = null
			_rest.erase(plank)
			plank.queue_free()
	for i in park.rails.size():
		if not host.rails[i] and park.rails[i] != null:
			var rail := park.rails[i]
			park.rails[i] = null
			_fall(rail)
	for i in park.pillars.size():
		var level: int = host.pillars[i]
		park.pillars[i].position.y = _pillar_y[i] - (SINK if level > 0 else 0.0)
		if level == 1:
			sagging[i] = TILT_FALL
		else:
			sagging.erase(i)
		sag(i, SAG if level == 1 else 0.0)
	var now := []
	for warning: Array in host.warnings:
		now.append([warning[0], warning[1], WARN])
	for warning: Array in warnings:
		if not now.any(func(w: Array) -> bool: return w[0] == warning[0] and w[1] == warning[1]):
			_shake(warning[0], warning[1], false)
	warnings = now


## A railing piece falls as it is: its static body becomes a falling one with the same shape and look.
func _fall(piece: StaticBody3D) -> void:
	var body := RigidBody3D.new()
	body.name = "Fallen%s" % piece.name
	body.mass = 4.0
	body.collision_layer = 4
	body.collision_mask = 1
	park.add_child(body)
	body.global_transform = piece.global_transform
	for child in piece.get_children():
		child.reparent(body, false)
	body.linear_velocity = park.global_basis.z * signf(park.to_local(body.global_position).z)
	_rest.erase(piece)
	piece.queue_free()


## The 4 planks over a pillar sink by up to `depth`, most over the pillar, tilting toward it.
func sag(pillar: int, depth: float) -> void:
	var x := BridgePark.PILLARS[pillar]
	for span in spans_over(pillar):
		for slot in BridgePark.PLANKS_PER_SPAN:
			var plank := park.plank(span, slot)
			if plank == null:
				continue
			var near := 1.0 - absf(plank.position.x - x) / BridgePark.SPAN
			plank.position.y = BridgePark.DECK_TOP - BridgePark.PLANK.y / 2 - depth * near
			plank.rotation.z = signf(plank.position.x - x) * depth * 0.15


## Shakes what's creaking, or puts it back where it was once it stops.
func _shake(kind: String, index: int, on: bool) -> void:
	var pieces: Array[Node3D] = []
	match kind:
		"span":
			for slot in BridgePark.PLANKS_PER_SPAN:
				pieces.append(park.plank(index, slot))
		"pillar":
			pieces.append(park.pillars[index])
		"rail":
			pieces.append(park.rails[index])
	for piece in pieces:
		if piece == null:
			continue
		if not _rest.has(piece):
			_rest[piece] = piece.position
		piece.position = _rest[piece] + (Vector3(_rng.randf_range(-SHAKE, SHAKE), 0, _rng.randf_range(-SHAKE, SHAKE))
			if on else Vector3.ZERO)
		if not on:
			_rest.erase(piece)
