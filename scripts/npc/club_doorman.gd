class_name ClubDoorman
extends StaticBody3D

## The doorman of the grandparents' club (infiltracion.md, step 2b): he stands by the entrance and pushes back out any
## cop without a disguise (Cop.is_disguised); a disguised one he lets in with a greeting. Each PC pushes its own cop,
## the one it moves, so online it needs no syncing. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_portero.glb")
const SCALE := 1.2
## The doorway he guards, in the club's space: a cop inside this box is going in.
const DOOR_HALF_WIDTH := 0.9
const DOOR_DEPTH := 1.2
## How hard he pushes a cop back out (m/s) and how long it staggers.
const PUSH := 5.0
const PUSH_STAGGER := 0.6
const SAY_TIME := 3.0

## The doorway's middle on the floor and its outward direction, in the world (GrandpaClub sets them).
var door_at := Vector3.ZERO
var outward := Vector3.BACK
## The cops he already greeted, so he says it once.
var _greeted := {}
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.55
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * SCALE
	add_child(model)
	_bubble = Label3D.new()
	_bubble.position = Vector3(0, 2.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## A cop in the doorway, going in.
func in_doorway(cop: Cop) -> bool:
	var off := cop.global_position - door_at
	var side := outward.cross(Vector3.UP).normalized()
	var depth := -off.dot(outward)
	return absf(off.dot(side)) <= DOOR_HALF_WIDTH and depth >= -0.2 and depth <= DOOR_DEPTH


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		# Each PC looks after the cop it moves.
		if cop.sync and not cop.sync.is_multiplayer_authority():
			continue
		if cop.vehicle or not in_doorway(cop):
			continue
		if cop.is_disguised():
			if not _greeted.has(cop):
				_greeted[cop] = true
				_say("DOORMAN_WELCOME")
			continue
		cop.knock_back(outward * PUSH, PUSH_STAGGER)
		cop.show_hint("HINT_DOORMAN_NO_DISGUISE")
		_say("DOORMAN_NO_0" if cop.disguise.is_empty() else "DOORMAN_NO_1")


func _say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME
