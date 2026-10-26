class_name ClubDoorman
extends StaticBody3D

## The doorman of the grandparents' club (infiltracion.md, step 2b), or the lady at the chapel's door
## (infiltracion-coro.md, step 3b), or the theater's mute mime (infiltracion-mimos.md, step 2b), or the party's bouncer
## (infiltracion-fiesta.md, step 2b), or the gym's receptionist (infiltracion-gimnasio.md, step 2b): they stand by the entrance and push back out any cop without the disguise of the
## place (Cop.is_disguised with `disguise_look`); a disguised one they let in with a greeting. Each PC pushes its own cop,
## the one it moves, so online it needs no syncing. Every number here is (propuesta).

const MODELS := {
	"portero": preload("res://assets/models/npc_portero.glb"),
	"portera": preload("res://assets/models/npc_portera.glb"),
	"mimo_portero": preload("res://assets/models/npc_mimo_portero.glb"),
	"patovica": preload("res://assets/models/npc_patovica.glb"),
	"recepcionista": preload("res://assets/models/npc_recepcionista.glb"),
}
const SCALES := {"portero": 1.2, "portera": 0.9, "mimo_portero": 1.2, "patovica": 1.25, "recepcionista": 0.9}
## What each one says: the keys start with this (WELCOME, NO_0 without anything on, NO_1 with not enough), and the
## hint is HINT_ + it + NO_DISGUISE.
const LINES := {"portero": "DOORMAN_", "portera": "DOORLADY_", "mimo_portero": "MIMEDOOR_", "patovica": "PARTYDOOR_",
	"recepcionista": "GYMDOOR_"}
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
@export var look := "portero"
## Who the cops have to pass for to get in (DisguisePiece.LOOKS).
var disguise_look := "grandparent"
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
	var model: Node3D = MODELS[look].instantiate()
	model.scale = Vector3.ONE * SCALES[look]
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
		var lines: String = LINES[look]
		if cop.is_disguised(disguise_look):
			if not _greeted.has(cop):
				_greeted[cop] = true
				_say(lines + "WELCOME")
			continue
		cop.knock_back(outward * PUSH, PUSH_STAGGER)
		cop.show_hint("HINT_" + lines + "NO_DISGUISE")
		_say(lines + ("NO_0" if cop.disguise.is_empty() else "NO_1"))


func _say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME
