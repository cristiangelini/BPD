class_name KaraokeMic
extends Grabbable

## A microphone of the karaoke (allanamiento-karaoke.md, step 2): it waits in the clip of its stand until a cop grabs
## it, and its cable goes back to the stand's foot. The cable stops it CABLE meters from there, held or thrown, and
## lying on the floor it trips a cop who runs over it, like a banana peel. Let go near its clip, it goes back in. Every
## number here is (propuesta).

## It tripped a cop running over its cable.
signal tripped(cop: Cop)

const MODEL := preload("res://assets/models/karaoke_mic.glb")
const SIZE := Vector3(0.06, 0.22, 0.06)
const KG := 0.4
## The clip is this high over the stand's foot, and the mic goes back in when let go this close to it.
const CLIP_HEIGHT := 1.45
const BACK_IN := 0.5
const CABLE := 4.0
## A cop running closer than this to the cable on the floor trips, at most once every TRIP_AGAIN seconds.
const TRIP_RANGE := 0.25
const TRIP_PUSH := 2.5
const TRIP_TIME := 1.2
const TRIP_AGAIN := 2.0

## The stand's foot (world space), and whether the mic is in its clip.
var foot := Vector3.ZERO
var in_stand := true
var _tripped := {}
var _cable: MeshInstance3D
var _drop: MeshInstance3D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.position.y = -SIZE.y / 2
	add_child(model)
	_cable = _cable_piece()
	_drop = _cable_piece()
	if in_stand:
		_clip()


func _cable_piece() -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	piece.top_level = true
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.025, 0.025, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.08, 0.08, 0.1)
	mesh.material = material
	piece.mesh = mesh
	piece.hide()
	add_child(piece)
	return piece


## Where the clip holds it (world space).
func clip_point() -> Vector3:
	return foot + Vector3.UP * (CLIP_HEIGHT + SIZE.y / 2)


func _clip() -> void:
	in_stand = true
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = Transform3D(Basis.IDENTITY, clip_point())


func hold(holder_id: int, point: Vector3) -> void:
	in_stand = false
	freeze = false
	super.hold(holder_id, point)


func let_go(holder_id: int) -> void:
	super.let_go(holder_id)
	if holders.is_empty() and global_position.distance_to(clip_point()) < BACK_IN:
		_clip()


## How far the cable lets it go from the stand's foot, along the floor.
func reach() -> float:
	return Vector2(global_position.x - foot.x, global_position.z - foot.z).length()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	for cop: Variant in _tripped.keys():
		_tripped[cop] -= delta
		if _tripped[cop] <= 0.0 or not is_instance_valid(cop):
			_tripped.erase(cop)
	if in_stand:
		return
	var flat := Vector3(global_position.x - foot.x, 0, global_position.z - foot.z)
	if flat.length() > CABLE:
		global_position = foot + flat.normalized() * CABLE + Vector3.UP * (global_position.y - foot.y)
		var out := linear_velocity.project(flat.normalized())
		if out.dot(flat) > 0.0:
			linear_velocity -= out
	_trip_cops()


## The cable, on every PC (a guest's copy only follows the host's, so it shows it out of its clip by where it is).
func _process(_delta: float) -> void:
	if global_position.distance_to(clip_point()) < 0.05:
		_cable.hide()
		_drop.hide()
	else:
		_lay_cable()


## The cable along the floor from the stand's foot to under the mic, and up to it.
func _lay_cable() -> void:
	var under := Vector3(global_position.x, foot.y + 0.02, global_position.z)
	_place(_cable, foot + Vector3.UP * 0.02, under)
	_place(_drop, under, global_position)


static func _place(piece: MeshInstance3D, from: Vector3, to: Vector3) -> void:
	var length := from.distance_to(to)
	piece.visible = length > 0.05
	if not piece.visible:
		return
	var up := Vector3.UP if absf((to - from).normalized().dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
	piece.global_transform = Transform3D(Basis.looking_at(to - from, up), (from + to) / 2).scaled_local(
		Vector3(1, 1, length))


## A cop running over the cable on the floor trips. Online the host's microphone moves (the guests' copies only
## follow), so a guest's cop trips on the host, which tells that guest's PC to knock it down too.
func _trip_cops() -> void:
	var under := Vector3(global_position.x, foot.y, global_position.z)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if not cop.is_running or _tripped.has(cop) or handling_cops(0.0).has(cop):
			continue
		var at := cop.global_position
		if absf(at.y - foot.y) > 0.5 or Geometry3D.get_closest_point_to_segment(at, foot, under).distance_to(
				Vector3(at.x, foot.y, at.z)) > TRIP_RANGE:
			continue
		_tripped[cop] = TRIP_AGAIN
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		var push := flat.normalized() * TRIP_PUSH if flat.length() > 0.1 else Vector3.ZERO
		cop.knock_back(push, TRIP_TIME)
		if cop.sync and cop.sync.is_inside_tree() and not cop.sync.is_multiplayer_authority() and cop.sync.net.actions:
			cop.sync.net.actions.tell_guests(cop, "knock_back", cop, [push, TRIP_TIME])
		cop.show_hint("HINT_KARAOKE_CABLE", true)
		tripped.emit(cop)
