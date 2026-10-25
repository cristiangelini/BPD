class_name Handcuffs
extends CopTool

## The handcuffs (herramientas.md): left click cuffs whoever is within reach for a while, any person or animal in the
## game (decision 87). A partner can't grab or use anything until someone frees them with E; an NPC stays put (the
## place's owner complains, a customer runs off once free). The cuffs show on whoever wears them.

## Seconds someone stays cuffed, and between two tries (propuesta).
const SECONDS := 20.0
const COOLDOWN := 1.0

var _wait := 0.0
## The cuffs shown on someone, and who: [model, cuffed one].
var _worn: Array[Array] = []
## The bribe on offer right now: from whom (the body aimed at and who it belongs to), how much and for how long.
var _offer_body: Node
var _offer_from: Node
var _offer_amount := 0
var _offer_left := 0.0


func _init() -> void:
	name_key = "TOOL_HANDCUFFS"


func prompt_key() -> String:
	if has_offer():
		return tr("PROMPT_BRIBE") % _offer_amount
	return "PROMPT_HANDCUFFS"


func press() -> void:
	if _wait > 0.0:
		return
	var hit := cop.aim_hit(GameScale.GRAB_REACH)
	var target: Node = cuffable(hit.collider) if not hit.is_empty() else null
	if not target:
		_wait = COOLDOWN
		return
	if target != _offer_from and _offers(target):
		_start_offer(hit.collider, target)
		return
	# Cuffed anyway: a refused bribe.
	_clear_offer()
	# Online the cuffs close on every PC, on whoever this PC aimed at.
	cop.act("belt_cuff", cop, [hit.collider, hit.position])


## A bribe is on offer and the cop can still take it.
func has_offer() -> bool:
	return _offer_left > 0.0 and is_instance_valid(_offer_from)


## E with the cuffs in hand while a bribe is on offer: takes it, on every PC (Cop.belt_bribe). Returns true if taken.
func take_offer() -> bool:
	if not has_offer():
		return false
	cop.act("belt_bribe", cop, [_offer_body, _offer_amount])
	_clear_offer()
	return true


## How much `target` offers instead of being cuffed: never a partner, and only once each.
static func offer_of(target: Node) -> int:
	if target is Cop or target.has_meta("bribe_offered"):
		return 0
	var case_seed := Campaign.current.case_seed() if Campaign.current else 0
	return Bribes.offer(case_seed, str(target.get_path()))


func _offers(target: Node) -> bool:
	return offer_of(target) > 0


func _start_offer(body: Node, target: Node) -> void:
	_offer_body = body
	_offer_from = target
	_offer_amount = offer_of(target)
	_offer_left = Bribes.CHOICE_SECONDS
	# Offered once, on every PC: if the cop lets the time run out, the next try cuffs, and no partner gets it again.
	cop.act("belt_bribe_offered", cop, [body])
	var case_seed := Campaign.current.case_seed() if Campaign.current else 0
	cop.show_hint(tr(Bribes.phrase_key(case_seed, str(target.get_path()))) % _offer_amount)


func _clear_offer() -> void:
	_offer_body = null
	_offer_from = null
	_offer_amount = 0
	_offer_left = 0.0


func _physics_process(delta: float) -> void:
	_wait = maxf(_wait - delta, 0.0)
	_offer_left = maxf(_offer_left - delta, 0.0)
	for pair in _worn.duplicate():
		if not is_instance_valid(pair[0]) or not is_instance_valid(pair[1]) or not pair[1].is_cuffed():
			if is_instance_valid(pair[0]):
				pair[0].queue_free()
			_worn.erase(pair)


## Cuffs what the camera points at within reach. Returns who got cuffed (or scared off), or null.
func cuff() -> Object:
	if _wait > 0.0:
		return null
	_wait = COOLDOWN
	var hit := cop.aim_hit(GameScale.GRAB_REACH)
	if hit.is_empty():
		return null
	return cuff_body(hit.collider, hit.position)


## Cuffs whoever `body` belongs to, with the cuffs shown at `at`. Returns who, or null.
func cuff_body(body: Node, at: Vector3) -> Object:
	_wait = COOLDOWN
	var target := cuffable(body) if body else null
	if not target:
		return null
	# Whoever was cuffed doesn't offer anymore, on any PC.
	(target as Node).set_meta("bribe_offered", true)
	target.cuffed(SECONDS)
	var worn := build_model()
	(body as Node3D).add_child(worn)
	worn.global_position = at
	_worn.append([worn, target])
	return target


## Who gets cuffed when aiming at `body`: itself, its walker (a turtle) or its owner (the neighbor behind her
## window, the gossip). Null for things that aren't anyone.
static func cuffable(body: Object) -> Object:
	if body.has_method("cuffed"):
		return body
	var walker := (body as Node).get_node_or_null("Walk")
	if walker and walker.has_method("cuffed"):
		return walker
	var parent := (body as Node).get_parent()
	return parent if parent and parent.has_method("cuffed") else null


func build_model() -> Node3D:
	var root := Node3D.new()
	for side: float in [-1.0, 1.0]:
		var ring := TorusMesh.new()
		ring.inner_radius = 0.03
		ring.outer_radius = 0.042
		ring.rings = 8
		ring.ring_segments = 6
		root.add_child(piece(ring, Color(0.75, 0.77, 0.8), Vector3(side * 0.05, 0, 0), Vector3(PI / 2, 0, 0)))
	root.add_child(piece(box(Vector3(0.03, 0.01, 0.01)), Color(0.75, 0.77, 0.8)))
	return root
