class_name BankWater
extends Node3D

## The flooding bank (robo-banco-inundado.md, step 1, decision 125): the duck's drill punctured the pipe behind the
## vault and a jet of water pours out of the hole in its door into the corridor. The water covers the whole bank's
## floor and rises RISE meters a second while `running`, up to MAX_LEVEL. Step 2: the valve out back stops it
## (shut_off). The front door, shut in this robbery, holds it in: open with the pipe pouring, the water stays where it
## is; open with the pipe shut, it drains DRAIN meters a second. Every time the door opens on WAVE_MIN or more water, a
## wave rushes out: the level drops WAVE_DROP at once and it shoves what's near the door out to the sidewalk. Step 3:
## over DRILL_WET the drill gets wet and slows down (BankDrill.wet), and the duck says so once; at PERCH_LEVEL the
## hostages still inside get up on the counter (BankHostage.climb), each on their perch, and come down again below
## DOWN_LEVEL. Step 4: loose things in the water float (BUOYANCY), slowed down by it (DRAG). Everyone wading in it inside the bank goes
## slower the deeper it is (factor()): the cops, the robbers and the hostages. The level sets each one's `wade` every
## physics frame; outside the bank it's 1. Online it runs on the host and a guest's follows it (`follower`, BankCase's
## snapshot). Every number here is (propuesta).

## 0.2 m a minute, up to 1 m (5 min).
const RISE := 0.2 / 60.0
const MAX_LEVEL := 1.0
## 0.1 m every 10 s out of the open front door, with the pipe shut.
const DRAIN := 0.01
const WAVE_MIN := 0.2
const WAVE_DROP := 0.1
## The wave shoves cops and loose things within this of the door (m), out to the sidewalk this hard.
const WAVE_REACH := 3.5
const WAVE_PUSH := 6.0
const WAVE_IMPULSE := 4.0
const WAVE_KNOCK := 0.6
const DRILL_WET := 0.5
const PERCH_LEVEL := 0.6
const DOWN_LEVEL := 0.5
## How much of their weight the water holds up under the surface (over 1 floats), and how much of their speed it takes
## each second.
const BUOYANCY := 1.4
const DRAG := 2.0
## How deep the bottom of a thing has to be to be all in the water (m).
const SUBMERGED := 0.3
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
## The level when the valve stopped it (-1 while it pours): shut before it got to MAX_LEVEL pays more (step 4).
var shut_at := -1.0
## The bank's front door (shut in this robbery) and where its doorway is (global).
var door: FrontDoor
var door_at := Vector3.ZERO
## A guest's: only shows the host's (apply_net_state).
var follower := false
## The robbers and the hostages (the cops are found by their group).
var waders: Array[Node3D] = []
## The drill and the duck at it; the hostages, and for each one where on the counter they get up to and where they
## hop down to (global).
var drill: BankDrill
var duck: BankRobber
var hostages: Array[BankHostage] = []
var perches: Array[Vector3] = []
var down_at: Array[Vector3] = []
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


## The valve is shut: the pipe stops pouring.
func shut_off() -> void:
	if not running:
		return
	running = false
	shut_at = level
	_show()


## Whether the pipe was shut before the water got to the top.
func shut_early() -> bool:
	return shut_at >= 0.0 and shut_at < MAX_LEVEL


func watch_door(front: FrontDoor, at: Vector3) -> void:
	door = front
	door_at = at
	door.opened.connect(_on_door_opened)


func _on_door_opened() -> void:
	if level < WAVE_MIN:
		return
	# Every PC knocks its own cop; the host's water and props decide the rest.
	var out := global_basis.z
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.has_method("knock_back") and _near_door(cop.global_position):
			cop.knock_back(out * WAVE_PUSH, WAVE_KNOCK)
	if follower:
		return
	level -= WAVE_DROP
	for body in _loose_things():
		if _near_door(body.global_position):
			body.apply_central_impulse(out * WAVE_IMPULSE * body.mass)


## Whether a thing floats: loose, not in anyone's hands.
static func floats(body: RigidBody3D) -> bool:
	return not body.freeze and not (body is Grabbable and not (body as Grabbable).holders.is_empty())


func _float_things() -> void:
	if level <= 0.02:
		return
	var surface := global_position.y + floor_top + level
	for body in _loose_things():
		if not floats(body) or depth_at(body.global_position) <= 0.0:
			continue
		var under := clampf((surface - body.global_position.y) / SUBMERGED + 0.5, 0.0, 1.0)
		if under <= 0.0:
			continue
		# As forces, so the wave's push on the same frame still counts.
		body.apply_central_force(Vector3.UP * body.mass * GameScale.GRAVITY * BUOYANCY * under
			- body.linear_velocity * body.mass * DRAG * under)


func _wet_drill() -> void:
	if not drill:
		return
	var wet := level >= DRILL_WET
	if wet and not drill.wet and duck and not duck.is_cuffed():
		duck.say("DUCK_DRILL_WET")
	drill.wet = wet


func _perch() -> void:
	for i in hostages.size():
		var hostage := hostages[i]
		if hostage.freed or hostage.is_cuffed():
			continue
		if level >= PERCH_LEVEL and not hostage.perched and not hostage.duck_float \
				and depth_at(hostage.global_position) > 0.0:
			hostage.climb(perches[i], down_at[i])
		elif level < DOWN_LEVEL and hostage.perched:
			hostage.climb_down()


func _near_door(at: Vector3) -> bool:
	return at.distance_to(door_at) <= WAVE_REACH and depth_at(at) > 0.0


func _loose_things() -> Array[RigidBody3D]:
	var things: Array[RigidBody3D] = []
	for node in get_parent().find_children("*", "RigidBody3D", true, false):
		if not (node as RigidBody3D).freeze:
			things.append(node)
	return things


func _physics_process(delta: float) -> void:
	if not follower:
		var door_open := door != null and door.is_open
		if door_open and not running:
			level = maxf(level - DRAIN * delta, 0.0)
		elif running and not door_open:
			level = minf(level + RISE * delta, MAX_LEVEL)
		_wet_drill()
		_perch()
		_float_things()
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
	return [level, running, shut_at]


func apply_net_state(state: Array) -> void:
	level = state[0]
	running = state[1]
	shut_at = state[2]
	_show()
