class_name OddCargo
extends Node3D

## What's inside the odd suitcase, the 13th one Fina Embrollo slipped in (politico-aeropuerto.md, step 3, decision
## 231). It hangs off that suitcase as "Odd" and gives it away, one of KINDS drawn by the seed:
## - "rooster": the suitcase jolts every JOLT_EVERY seconds and crows every CROW_EVERY.
## - "alarm": an alarm clock rings every RING_EVERY seconds for RING seconds.
## - "paint": an open can of yellow paint, it leaves a spot under it every DRIP meters it moves.
## - "newspapers": a pile of old newspapers, it weighs twice as much (the counter's scale shows it).
## A cop within SEE when it gives itself away notices (`noticed`, a hint for them); opened, everybody sees what's
## inside. Every number here is (propuesta).

signal noticed(kind: String, cop: Cop)

const KINDS: Array[String] = ["rooster", "alarm", "paint", "newspapers"]
const SEE := 3.5
const JOLT_EVERY := 4.0
const JOLT := 30.0
const CROW_EVERY := 12.0
const RING_EVERY := 20.0
const RING := 2.0
const DRIP := 0.6
const SPOTS := 40
const HEAVY := 2.0
const SAY_TIME := 2.0
const PAINT := Color(0.98, 0.85, 0.15)

var kind := "rooster"
var spots: Array[MeshInstance3D] = []
## Online, a guest's: the host's gives it away and jolts it; here it only crows, rings and drips.
var follower := false
var _suitcase: Suitcase
var _bubble: Label3D
var _bubble_left := 0.0
var _jolt_left := JOLT_EVERY
var _crow_left := CROW_EVERY
var _ring_left := RING_EVERY
var _last_drip := Vector3.INF
var _inside: Node3D
var _seen := {}


static func attach(suitcase: Suitcase, what: String) -> OddCargo:
	var odd := OddCargo.new()
	odd.name = "Odd"
	odd.kind = what
	suitcase.add_child(odd)
	return odd


static func of(suitcase: Node) -> OddCargo:
	return suitcase.get_node_or_null("Odd") as OddCargo


func _ready() -> void:
	_suitcase = get_parent() as Suitcase
	if kind == "newspapers":
		_suitcase.mass = Suitcase.KG * HEAVY
	_bubble = MarketShopper.make_bubble()
	_bubble.top_level = true
	add_child(_bubble)
	_inside = _build_inside()
	_inside.visible = false
	add_child(_inside)
	_suitcase.opened_now.connect(func(_s: Suitcase) -> void: _give_away(true))


## What it says from inside, over the suitcase.
func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


## Gives it away to the cops close enough (all of them if it was opened). The host's decides.
func _give_away(opened := false) -> void:
	if follower:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if opened or cop.global_position.distance_to(_suitcase.global_position) < SEE:
			if not _seen.has(cop):
				_seen[cop] = true
				cop.show_hint("HINT_ODD_%s" % kind.to_upper())
			noticed.emit(kind, cop)


## The counter's scale weighed it (AirportBelt).
func weighed() -> void:
	if kind == "newspapers":
		_give_away()


func _physics_process(delta: float) -> void:
	_inside.visible = _suitcase.opened
	if not _suitcase.visible:
		return
	match kind:
		"rooster":
			_jolt_left -= delta
			if _jolt_left <= 0.0 and not follower:
				_jolt_left = JOLT_EVERY
				_suitcase.apply_central_impulse(Vector3(randf_range(-1, 1), 1.0, randf_range(-1, 1)).normalized() * JOLT)
				_give_away()
			_crow_left -= delta
			if _crow_left <= 0.0:
				_crow_left = CROW_EVERY
				say("ODD_ROOSTER_CROW")
				_give_away()
		"alarm":
			_ring_left -= delta
			if _ring_left <= 0.0:
				_ring_left = RING_EVERY
				say("ODD_ALARM_RING")
				_bubble_left = RING
				_give_away()
		"paint":
			if _last_drip.distance_to(_suitcase.global_position) > DRIP:
				_drip()


## A yellow spot on whatever is under it.
func _drip() -> void:
	_last_drip = _suitcase.global_position
	var query := PhysicsRayQueryParameters3D.create(_last_drip, _last_drip + Vector3.DOWN * 4.0)
	query.collision_mask = 1
	query.exclude = [_suitcase.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var spot := MeshInstance3D.new()
	spot.name = "PaintSpot"
	var disc := CylinderMesh.new()
	disc.top_radius = randf_range(0.12, 0.2)
	disc.bottom_radius = disc.top_radius
	disc.height = 0.01
	spot.mesh = disc
	var material := StandardMaterial3D.new()
	material.albedo_color = PAINT
	# Bright yellow under any light.
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spot.material_override = material
	_suitcase.get_parent().add_child(spot)
	spot.global_position = hit.position + Vector3.UP * 0.006
	spots.append(spot)
	if spots.size() > SPOTS:
		spots.pop_front().queue_free()
	_give_away()


func _process(delta: float) -> void:
	_bubble.global_position = _suitcase.global_position + Vector3.UP * 0.6
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()


## What's seen inside once it's open, over the clothes.
func _build_inside() -> Node3D:
	var inside := Node3D.new()
	inside.name = "Inside"
	match kind:
		"rooster":
			inside.add_child(_part(SphereMesh.new(), Vector3(0.18, 0.18, 0.18), Vector3(0, 0.15, 0), Color(0.85, 0.45, 0.15)))
			inside.add_child(_part(SphereMesh.new(), Vector3(0.1, 0.1, 0.1), Vector3(0.12, 0.27, 0), Color(0.85, 0.45, 0.15)))
			inside.add_child(_part(BoxMesh.new(), Vector3(0.06, 0.06, 0.02), Vector3(0.12, 0.34, 0), Color(0.85, 0.1, 0.1)))
			inside.add_child(_part(BoxMesh.new(), Vector3(0.04, 0.02, 0.02), Vector3(0.18, 0.27, 0), Color(0.95, 0.75, 0.2)))
		"alarm":
			inside.add_child(_part(CylinderMesh.new(), Vector3(0.16, 0.04, 0.16), Vector3(0, 0.15, 0), Color(0.75, 0.78, 0.82)))
			for x: float in [-0.06, 0.06]:
				inside.add_child(_part(SphereMesh.new(), Vector3(0.06, 0.06, 0.06), Vector3(x, 0.2, -0.04), Color(0.95, 0.75, 0.2)))
		"paint":
			inside.add_child(_part(CylinderMesh.new(), Vector3(0.18, 0.2, 0.18), Vector3(0, 0.16, 0), Color(0.75, 0.78, 0.82)))
			inside.add_child(_part(CylinderMesh.new(), Vector3(0.16, 0.01, 0.16), Vector3(0, 0.265, 0), PAINT))
		"newspapers":
			for i in 4:
				inside.add_child(_part(BoxMesh.new(), Vector3(0.45, 0.04, 0.32), Vector3(0, 0.08 + i * 0.045, 0),
					Color(0.88, 0.86, 0.8).darkened(i * 0.05)))
	return inside


func _part(mesh: PrimitiveMesh, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.scale = size
	part.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	part.material_override = material
	return part
