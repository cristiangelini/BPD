class_name TunnelHole
extends StaticBody3D

## The hole by a cell's bunk in the spoon tunnel jailbreak (docs/diseno/fuga-tunel.md, step 1): a cop with a Spoon in
## hand digs it with E, a scoop at most every SCOOP_EVERY seconds, and after `needed` scoops (drawn by the seed between
## NEEDED_MIN and NEEDED_MAX) the tunnel is through. The hole looks deeper and the dirt beside it piles up as it goes.
## Every scoop is a noise (`scooped`), which the listening guard hears unless someone covers it. Every number here is
## (propuesta).

signal scooped(hole: TunnelHole, cop: Cop)
signal dug_through(hole: TunnelHole)

const NEEDED_MIN := 70
const NEEDED_MAX := 90
const SCOOP_EVERY := 0.6
const RADIUS := 0.35
const DIRT := Color(0.42, 0.3, 0.18)
const DARK := Color(0.08, 0.06, 0.05)

## Which cell it's in (0 or 1).
@export var cell := 0
var needed := 80
var scoops := 0
## Under the bunk's mattress, out of the guard's sight (step 3).
var covered := false
var _next_scoop_ms := 0
var _hole: MeshInstance3D
var _pile: MeshInstance3D


func _ready() -> void:
	add_to_group("tunnel_holes")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(RADIUS * 2, 0.04, RADIUS * 2)
	shape.shape = box
	shape.position.y = 0.02
	add_child(shape)
	_hole = _disc(RADIUS, DARK, Vector3(0, 0.011, 0))
	_pile = _disc(0.25, DIRT, Vector3(RADIUS + 0.3, 0.0, 0))
	_refresh()


func _disc(radius: float, color: Color, at: Vector3) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.02
	mesh.radial_segments = 12
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material = material
	var disc := MeshInstance3D.new()
	disc.mesh = mesh
	disc.position = at
	add_child(disc)
	return disc


## How many scoops this seed's hole needs.
func setup(case_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["tunnel hole", case_seed, cell])
	needed = rng.randi_range(NEEDED_MIN, NEEDED_MAX)
	_refresh()


func progress() -> float:
	return clampf(float(scoops) / needed, 0.0, 1.0)


## Dug into and not covered: the guard sees it when he looks in.
func is_showing() -> bool:
	return scoops > 0 and not covered


func is_through() -> bool:
	return scoops >= needed


func prompt_key(cop: Cop) -> String:
	if is_through():
		return ""
	return "PROMPT_DIG_TUNNEL" if cop.get_node("Grabber").held is Spoon else "PROMPT_NEED_SPOON"


func use(cop: Cop) -> void:
	if is_through() or not cop.get_node("Grabber").held is Spoon:
		return
	var now := Time.get_ticks_msec()
	if now < _next_scoop_ms:
		return
	_next_scoop_ms = now + int(SCOOP_EVERY * 1000.0)
	scoop(cop)


## One scoop more: deeper, more dirt, and a noise.
func scoop(cop: Cop = null) -> void:
	if is_through():
		return
	scoops += 1
	_refresh()
	scooped.emit(self, cop)
	if is_through():
		dug_through.emit(self)


## The guard caught them: a part of what was dug falls back in.
func fill(share: float) -> void:
	if is_through():
		return
	scoops = maxi(scoops - int(ceil(needed * share)), 0)
	_refresh()


## A dug-in hole is darker and wider; the dirt pile grows with it.
func _refresh() -> void:
	var p := progress()
	_hole.visible = scoops > 0
	_hole.scale = Vector3.ONE * (0.4 + 0.6 * p)
	_pile.visible = scoops > 0
	_pile.scale = Vector3(0.5 + p, 1.0 + 6.0 * p, 0.5 + p)


## Online: how far it's dug (NpcSync).
func net_state() -> Variant:
	return scoops


func apply_net_state(state: Variant) -> void:
	scoops = state
	_refresh()
