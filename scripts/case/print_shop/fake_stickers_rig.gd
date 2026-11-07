class_name FakeStickersRig
extends PrintShopRig

## The fake stickers (allanamiento-imprenta.md, "Las figuritas truchas"): Don Renglón prints the album's hard sticker,
## the goalkeeper. Around where the plate was hidden the floor is covered in repeated stickers, all the same one, and
## a cop this close to them notices, the story's own clue (on the checklist the first time). And while the rotativa
## runs it spits stickers that stick to the face of the cops near its tray: one in front of the eyes for FACE_TIME
## seconds. Every number here is (propuesta).

signal face_stuck(cop: Cop)

const NOTICE_RANGE := 1.5
const CHECK_EVERY := 0.25
## The repeated stickers on the floor around the hiding spot: how many and how far.
const FLOOR_STICKERS := 20
const SPREAD := 1.2
const STICKER_SIZE := Vector3(0.07, 0.003, 0.09)
## How near the tray a cop gets one on the face, how often while it runs, and for how long.
const FACE_RANGE := 4.0
const SPIT_EVERY := 3.0
const FACE_TIME := 4.0
const GOALIE_GREEN := Color(0.18, 0.6, 0.29)

var noticed := false
var floor_stickers: Array[MeshInstance3D] = []
## The cops with a sticker on the face now: Cop -> {"node": MeshInstance3D, "left": float}.
var on_face := {}
var faces := 0
var _since := 0.0
var _spit_left := 0.0
var _rng := RandomNumberGenerator.new()


func setup(place: PrintShop) -> void:
	super.setup(place)
	_rng.seed = shop.case_seed * 7 + 11
	var spot := hiding_spot()
	for i in FLOOR_STICKERS:
		var angle := _rng.randf() * TAU
		var away := Vector3(cos(angle), 0, sin(angle)) * _rng.randf_range(0.35, SPREAD)
		var sticker := _sticker()
		var inside := Vector2(PrintShop.HALF_X - 0.15, PrintShop.HALF_Z - 0.15)
		sticker.position = Vector3(clampf(spot.x + away.x, -inside.x, inside.x), PrintShop.FLOOR_TOP + 0.003,
			clampf(spot.z + away.z, -inside.y, inside.y))
		sticker.rotation.y = _rng.randf() * TAU
		sticker.scale = Vector3(1.8, 1.0, 1.8)
		shop.add_child(sticker)
		floor_stickers.append(sticker)
	shop.press.started.connect(func(_cop: Cop) -> void: _spit_left = 0.0)


## Where the plate was hidden, in the shop's space (on the floor under it).
func hiding_spot() -> Vector3:
	return PrintShop.SPOTS[shop.hidden_spots[0]].at


func _physics_process(delta: float) -> void:
	for cop: Cop in on_face.keys():
		on_face[cop].left -= delta
		if on_face[cop].left <= 0.0 or not is_instance_valid(cop):
			unstick(cop)
	if shop.press.is_moving():
		_spit_left -= delta
		if _spit_left <= 0.0:
			_spit_left = SPIT_EVERY
			spit()
	_since += delta
	# Online the host sees the cops come close: the guests' rig shows the clue when it says (net_state).
	if noticed or _since < CHECK_EVERY or not multiplayer.is_server():
		return
	_since = 0.0
	var spot := shop.to_global(hiding_spot())
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var flat := Vector2(cop.global_position.x - spot.x, cop.global_position.z - spot.z)
		if flat.length() <= SPREAD + NOTICE_RANGE:
			notice()
			break


## A cop sees the floor full of the same sticker: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	shop.raid.add_clue(tr("CLUE_REPEATED_STICKERS"))
	shop.raid.float_label(tr("PRINT_SHOP_REPEATED"), shop.to_global(hiding_spot() + Vector3(0, 1.2, 0)),
		GOALIE_GREEN)


## The press spits: every cop near its tray without one gets a sticker on the face (online, each PC its own cop's).
func spit() -> void:
	var tray := shop.to_global(PrintShop.PRESS_AT + Vector3(PrintShop.TRAY_X.y, 0, 0))
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop is Cop and is_mine(cop as Cop) and not on_face.has(cop) and cop.global_position.distance_to(tray) <= FACE_RANGE:
			stick_on_face(cop as Cop)


## A sticker lands on the cop's face: in front of the camera, a bit to one side, for FACE_TIME.
func stick_on_face(cop: Cop) -> void:
	var sticker := _sticker()
	sticker.name = "FaceSticker"
	sticker.scale = Vector3.ONE * 2.0
	sticker.position = Vector3(_rng.randf_range(-0.06, 0.06), _rng.randf_range(-0.03, 0.04), -0.2)
	sticker.rotation = Vector3(PI / 2, 0, _rng.randf_range(-0.4, 0.4))
	cop.camera.add_child(sticker)
	on_face[cop] = {"node": sticker, "left": FACE_TIME}
	faces += 1
	cop.show_hint("HINT_STICKER_FACE")
	face_stuck.emit(cop)


func unstick(cop: Cop) -> void:
	var node: Node = on_face[cop].node
	if is_instance_valid(node):
		node.queue_free()
	on_face.erase(cop)


## One copy of the hard sticker: the goalkeeper on green, white frame.
func _sticker() -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = STICKER_SIZE
	var node := MeshInstance3D.new()
	node.mesh = mesh
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color(0.98, 0.98, 0.95)
	node.material_override = paint
	var inner := MeshInstance3D.new()
	var inner_mesh := BoxMesh.new()
	inner_mesh.size = Vector3(STICKER_SIZE.x - 0.016, STICKER_SIZE.y + 0.001, STICKER_SIZE.z - 0.016)
	inner.mesh = inner_mesh
	var green := StandardMaterial3D.new()
	green.albedo_color = GOALIE_GREEN
	inner.material_override = green
	node.add_child(inner)
	var face := MeshInstance3D.new()
	var face_mesh := BoxMesh.new()
	face_mesh.size = Vector3(0.025, STICKER_SIZE.y + 0.002, 0.03)
	face.mesh = face_mesh
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.93, 0.76, 0.62)
	face.material_override = skin
	node.add_child(face)
	var mustache := MeshInstance3D.new()
	var mustache_mesh := BoxMesh.new()
	mustache_mesh.size = Vector3(0.02, STICKER_SIZE.y + 0.003, 0.005)
	mustache.mesh = mustache_mesh
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.1, 0.08, 0.06)
	mustache.material_override = black
	mustache.position = Vector3(0, 0, 0.004)
	node.add_child(mustache)
	return node
