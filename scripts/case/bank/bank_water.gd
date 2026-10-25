class_name BankWater
extends Node3D

## The flooding bank (robo-banco-inundado.md, step 1, decision 125): the duck's drill punctured the pipe behind the
## vault and a jet of water pours out of the hole in its door into the corridor. The water covers the whole bank's
## floor and rises RISE meters a second while `running`, up to MAX_LEVEL. Everyone wading in it inside the bank goes
## slower the deeper it is (factor()): the cops, the robbers and the hostages. The level sets each one's `wade` every
## physics frame; outside the bank it's 1. Online it runs on the host and a guest's follows it (`follower`, BankCase's
## snapshot). Every number here is (propuesta).

## 0.2 m a minute, up to 1 m (5 min).
const RISE := 0.2 / 60.0
const MAX_LEVEL := 1.0
## Speed by depth: (depth, factor) points, straight lines between them.
const WADE: Array[Vector2] = [Vector2(0.0, 1.0), Vector2(0.3, 0.8), Vector2(0.6, 0.6), Vector2(1.0, 0.45)]
const COLOR := Color(0.25, 0.5, 0.75, 0.55)
const JET_COLOR := Color(0.7, 0.85, 1.0, 0.8)
const JET_RADIUS := 0.12

## The bank's inside on its floor (the level's own coordinates), the floor's top and where the jet comes out from.
var area := Rect2()
var floor_top := 0.0
var jet_from := Vector3.ZERO
## How high the water stands above the floor (m), and whether the pipe still pours.
var level := 0.0
var running := true
## A guest's: only shows the host's (apply_net_state).
var follower := false
## The robbers and the hostages (the cops are found by their group).
var waders: Array[Node3D] = []
var _surface: MeshInstance3D
var _jet: MeshInstance3D


func _ready() -> void:
	_surface = MeshInstance3D.new()
	_surface.name = "Surface"
	var box := BoxMesh.new()
	box.size = Vector3(area.size.x, 1.0, area.size.y)
	box.material = _see_through(COLOR)
	_surface.mesh = box
	_surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_surface)
	# The jet: from the hole in the vault's door, falling west into the corridor.
	_jet = MeshInstance3D.new()
	_jet.name = "Jet"
	var tube := CylinderMesh.new()
	tube.top_radius = JET_RADIUS
	tube.bottom_radius = JET_RADIUS * 1.6
	tube.height = 1.0
	tube.material = _see_through(JET_COLOR)
	_jet.mesh = tube
	add_child(_jet)
	_show()


func _see_through(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.1
	return material


## How fast someone goes wading in this much water (1 out of it).
static func factor(depth: float) -> float:
	if depth <= 0.0:
		return 1.0
	for i in range(1, WADE.size()):
		if depth <= WADE[i].x:
			var from := WADE[i - 1]
			return lerpf(from.y, WADE[i].y, (depth - from.x) / (WADE[i].x - from.x))
	return WADE[-1].y


## How deep the water is where `at` stands (global): 0 out of the bank.
func depth_at(at: Vector3) -> float:
	var local := to_local(at)
	if not area.has_point(Vector2(local.x, local.z)):
		return 0.0
	return level


## How fast whoever stands at `at` goes.
func wade_at(at: Vector3) -> float:
	return factor(depth_at(at))


func _physics_process(delta: float) -> void:
	if not follower and running:
		level = minf(level + RISE * delta, MAX_LEVEL)
	_show()
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if "wade" in cop:
			cop.wade = wade_at(cop.global_position)
	for wader in waders:
		if is_instance_valid(wader):
			wader.set("wade", wade_at(wader.global_position))


func _show() -> void:
	if not _surface:
		return
	_surface.visible = level > 0.005
	_surface.scale.y = maxf(level, 0.005)
	_surface.position = Vector3(area.get_center().x, floor_top + level / 2.0, area.get_center().y)
	_jet.visible = running
	# From the hole down to the water (or the floor), leaning west.
	var to := Vector3(jet_from.x - 1.2, floor_top + level, jet_from.z)
	_jet.position = (jet_from + to) / 2.0
	var along := to - jet_from
	_jet.scale.y = maxf(along.length(), 0.05)
	_jet.basis = Basis(Quaternion(Vector3.UP, -along.normalized())).scaled(Vector3(1, _jet.scale.y, 1))


func net_state() -> Array:
	return [level, running]


func apply_net_state(state: Array) -> void:
	level = state[0]
	running = state[1]
	_show()
