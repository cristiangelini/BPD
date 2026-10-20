class_name Handcuffs
extends CopTool

## The handcuffs (herramientas.md): left click cuffs whoever is within reach for a while. A partner can't grab or
## use anything until someone frees them with E; the place's owner stays put but complains; a customer runs off.

## Seconds someone stays cuffed, and between two tries (propuesta).
const SECONDS := 20.0
const COOLDOWN := 1.0

var _wait := 0.0


func _init() -> void:
	name_key = "TOOL_HANDCUFFS"


func prompt_key() -> String:
	return "PROMPT_HANDCUFFS"


func press() -> void:
	cuff()


func _physics_process(delta: float) -> void:
	_wait = maxf(_wait - delta, 0.0)


## Cuffs what the camera points at within reach. Returns who got cuffed (or scared off), or null.
func cuff() -> Object:
	if _wait > 0.0:
		return null
	_wait = COOLDOWN
	var hit := cop.aim_hit(GameScale.GRAB_REACH)
	var target: Object = null if hit.is_empty() else hit.collider
	if target is Cop:
		(target as Cop).cuff(SECONDS)
	elif target is Cat:
		cop.show_hint("HINT_CUFF_CAT")
		return null
	elif target is BakeryCustomer:
		(target as BakeryCustomer).scare()
	elif target and target.has_method("cuffed"):
		target.cuffed(SECONDS)
	else:
		return null
	return target


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
