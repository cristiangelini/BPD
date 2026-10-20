class_name PrintKit
extends CopTool

## The fingerprint kit (herramientas.md): hold left click on something within reach to dust it. It shows fresh
## prints of the place's owner if case evidence is close (so a drawer can be checked without opening it) and the
## prints of every cop who grabbed it (usually their own).

## Seconds of dusting, and how close evidence leaves the owner's fresh prints, in meters (propuesta).
const DUST_TIME := 1.5
const OWNER_RANGE := 1.2
## The cops' skin colors, by player index (decision 72).
const COP_COLORS := ["COLOR_PINK", "COLOR_ORANGE", "COLOR_LIME", "COLOR_VIOLET"]

var dusting := 0.0
var _target: Object
var _point := Vector3.ZERO


func _init() -> void:
	name_key = "TOOL_PRINT_KIT"


func prompt_key() -> String:
	return "PROMPT_PRINT_KIT_DUSTING" if _target else "PROMPT_PRINT_KIT"


func press() -> void:
	var hit := cop.aim_hit(GameScale.GRAB_REACH)
	if hit.is_empty():
		return
	_target = hit.collider
	_point = hit.position
	dusting = 0.0


func release() -> void:
	_target = null


func _physics_process(delta: float) -> void:
	if not _target:
		return
	var hit := cop.aim_hit(GameScale.GRAB_REACH)
	if hit.is_empty() or hit.collider != _target:
		_target = null
		return
	dusting += delta
	if dusting >= DUST_TIME:
		# Online the prints show on every PC (Cop.act), so the owner's prints go on everyone's checklist.
		cop.act("belt_prints", cop, [_target, _point])
		_target = null


## Shows whose prints are on `target` (dusted at `point`) and notes the owner's on the checklist.
## Returns {"owner": fresh prints of the place's owner, "cops": player indexes}.
func reveal(target: Object, point: Vector3) -> Dictionary:
	var found := prints_at(target, point)
	var lines: PackedStringArray = []
	var raid := get_tree().get_first_node_in_group("raid") as RaidCase
	var owner_key := raid.prints_key if raid else "PRINTS_OWNER"
	if found.owner:
		lines.append(tr("PRINTS_FRESH") % tr(owner_key))
		if raid:
			raid.add_clue(tr("CLUE_PRINTS") % tr(owner_key))
	if not found.cops.is_empty():
		lines.append(tr("PRINTS_COPS") % ", ".join(found.cops.map(func(i: int) -> String: return tr(COP_COLORS[i % 4]))))
	cop.show_hint(" · ".join(lines) if not lines.is_empty() else "PRINTS_NONE")
	return found


static func prints_at(target: Object, point: Vector3) -> Dictionary:
	var fresh := false
	for item in (target as Node).get_tree().get_nodes_in_group("evidence"):
		if not (item as Evidence).is_broken and (item as Node3D).global_position.distance_to(point) <= OWNER_RANGE:
			fresh = true
	var cops: Array = target.touched_by.keys() if target is Grabbable else []
	cops.sort()
	return {"owner": fresh, "cops": cops}


func build_model() -> Node3D:
	var root := Node3D.new()
	root.add_child(piece(cylinder(0.035, 0.07), Color(0.25, 0.25, 0.3), Vector3(0, -0.02, 0)))
	root.add_child(piece(cylinder(0.008, 0.12), Color(0.55, 0.38, 0.2), Vector3(0.06, 0.03, -0.02), Vector3(0, 0, -0.5)))
	root.add_child(piece(cylinder(0.02, 0.04), Color(0.95, 0.92, 0.85), Vector3(0.09, 0.09, -0.02), Vector3(0, 0, -0.5)))
	return root
