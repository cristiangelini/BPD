class_name RegularGuest
extends CharacterBody3D

## Señor Ramón, the hotel's "guests" (hotel-allanamiento.md, "El huésped de siempre"): every CROSS_EVERY seconds he
## crosses the lobby between the front door and the stairs in another disguise (mustache, hat, wig) and says hello as
## a new guest. A cop who bumps into him knocks his fake mustache off: he shouts and runs out of the front door for
## good. Every number here is (propuesta).

signal unmasked(at: Vector3)

const MODEL := preload("res://assets/models/npc_cliente.glb")
const CROSS_EVERY := 40.0
const SPEED := 1.2
const RUN := 4.0
## The two ends of his walk, in the hotel's space: just inside the front door and the foot of the stairs.
const DOOR := Vector3(0.0, Hotel.FLOOR_TOP, 6.3)
const STAIRS := Vector3(9.0, Hotel.FLOOR_TOP, 5.6)
## Out on the sidewalk, where he runs off to.
const STREET := Vector3(0.0, 0.0, 10.0)
const DISGUISES := ["mustache", "hat", "wig"]
const BUMP := 0.9

var disguise := 0
var walking := false
var fled := false
var crossings := 0
var _wait := 3.0
var _to := STAIRS
var _parts := {}
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	var model := MODEL.instantiate()
	add_child(model)
	# The customer's own cap and bread bag would give him away: only the disguises go on top.
	for own: String in ["cap", "props"]:
		var part := model.find_child(own, true, false) as Node3D
		if part:
			part.visible = false
	_parts["mustache"] = _part(BoxMesh.new(), Vector3(0.22, 0.05, 0.05), Vector3(0, 1.22, 0.24), Color(0.1, 0.1, 0.1))
	_parts["hat"] = _part(CylinderMesh.new(), Vector3(0.36, 0.22, 0.36), Vector3(0, 1.6, 0), Color(0.35, 0.22, 0.12))
	_parts["wig"] = _part(SphereMesh.new(), Vector3(0.48, 0.3, 0.46), Vector3(0, 1.48, -0.03), Color(0.91, 0.46, 0.16))
	_bubble = Label3D.new()
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	position = DOOR
	_dress()
	_hide(true)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if fled:
		_walk_to(STREET, RUN, delta)
		if _flat(position).distance_to(_flat(STREET)) < 0.3:
			queue_free()
		return
	if not walking:
		_wait -= delta
		if _wait <= 0.0:
			_start_crossing()
		return
	_walk_to(_to, SPEED, delta)
	if _flat(position).distance_to(_flat(_to)) < 0.2:
		walking = false
		_wait = CROSS_EVERY
		_hide(true)
		_bubble.hide()
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop.global_position.distance_to(global_position) < BUMP:
			unmask()
			return


## Online, what the guests' Ramón takes from the host's (NpcSync): whether he's crossing, in which disguise, and
## whether he ran off (then the guest's checklist gets the mustache too).
func net_state() -> Array:
	return [walking, disguise, fled]


func apply_net_state(state: Array) -> void:
	if state[1] != disguise:
		disguise = state[1]
		_dress()
	if state[0] != walking:
		walking = state[0]
		_hide(not walking)
	if state[2] and not fled:
		walking = true
		_hide(false)
		unmask()


## A cop bumped into him: off comes the mustache, and off he goes for good.
func unmask() -> void:
	if fled or not walking:
		return
	fled = true
	(_parts["mustache"] as Node3D).visible = false
	_say("RAMON_UNMASKED")
	unmasked.emit(global_position)


## He comes in through the front door or down the stairs, in the next disguise, and says hello as a new guest.
func _start_crossing() -> void:
	crossings += 1
	disguise = crossings % DISGUISES.size()
	_dress()
	var from := DOOR if crossings % 2 == 1 else STAIRS
	_to = STAIRS if crossings % 2 == 1 else DOOR
	position = from
	walking = true
	_hide(false)
	_say("RAMON_HELLO_" + DISGUISES[disguise].to_upper())


func _walk_to(at: Vector3, speed: float, delta: float) -> void:
	var to := at - position
	to.y = 0.0
	velocity = to.normalized() * speed if to.length() > 0.05 else Vector3.ZERO
	velocity.y = 0.0 if is_on_floor() else -GameScale.GRAVITY * delta
	if to.length() > 0.1:
		look_at(global_position + to, Vector3.UP, true)
	move_and_slide()


func _dress() -> void:
	for id: String in _parts:
		(_parts[id] as Node3D).visible = id == DISGUISES[disguise]
	# The mustache is always on: it's the one thing he never changes.
	(_parts["mustache"] as Node3D).visible = true


func _hide(hidden: bool) -> void:
	visible = not hidden
	collision_layer = 0 if hidden else 8


func _flat(at: Vector3) -> Vector2:
	return Vector2(at.x, at.z)


func _say(key: String) -> void:
	_bubble.text = key
	_bubble.show()


func _part(mesh: PrimitiveMesh, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	if mesh is BoxMesh:
		(mesh as BoxMesh).size = size
	elif mesh is CylinderMesh:
		(mesh as CylinderMesh).top_radius = size.x / 2
		(mesh as CylinderMesh).bottom_radius = size.x / 2
		(mesh as CylinderMesh).height = size.y
	elif mesh is SphereMesh:
		(mesh as SphereMesh).radius = size.x / 2
		(mesh as SphereMesh).height = size.y
	look.mesh = mesh
	look.scale = Vector3(1, 1, size.z / size.x) if mesh is SphereMesh else Vector3.ONE
	look.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	look.material_override = material
	add_child(look)
	return look
