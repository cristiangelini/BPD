class_name InternalAffairsAgent
extends CharacterBody3D

## The internal affairs agent (docs/diseno/sobornos.md, decisions 191 and 192): while the campaign is under
## investigation he comes into every case and follows the nearest cop at about FOLLOW meters, writing in his folder.
## A bribe taken within Bribes.SEEN_REACH of him, where he can see it, is caught (Cop.belt_bribe). The cuffs don't
## close on him: he shows his badge. Every PC moves its own copy after the same cops; the host's decides what he saw.

const MODEL := preload("res://assets/models/npc_asuntos_internos.glb")
## How far behind he walks, how fast, and how far a cop can get before he turns up behind them again (stuck on a wall).
const FOLLOW := 8.0
const WALK_SPEED := 1.6
const LOST := 30.0
## Where his eyes are, and how long he says things.
const EYES := 1.45
const SAY_TIME := 3.0
## Lines while he follows them, now and then (AGENT_NOTE_<n>).
const NOTE_LINES := 4
const NOTE_EVERY := 12.0

var _bubble: Label3D
var _bubble_left := 0.0
var _note_left := NOTE_EVERY


## Brings the agent into `cop`'s level if the campaign is under investigation and he isn't there yet: called by the
## player's own cop when the level opens. Online a guest knows it from the host (Net.match_investigation).
static func join(cop: Cop) -> InternalAffairsAgent:
	if not investigating() or not cop.get_parent() or of(cop) != null:
		return null
	var agent := InternalAffairsAgent.new()
	agent.name = "InternalAffairsAgent"
	cop.get_parent().add_child(agent)
	agent.global_position = cop.global_position + cop.global_basis.z * 3.0
	return agent


## The campaign being played is under investigation, outside the jailbreak's night.
static func investigating() -> bool:
	if Campaign.current:
		return Campaign.current.investigation and not Campaign.current.jailed
	return Net.is_online() and Net.match_investigation


## The agent in `node`'s level, if any.
static func of(node: Node) -> InternalAffairsAgent:
	for agent in node.get_tree().get_nodes_in_group("internal_affairs"):
		return agent as InternalAffairsAgent
	return null


func _ready() -> void:
	add_to_group("internal_affairs")
	# He never offers a bribe (Handcuffs.offer_of).
	set_meta("bribe_offered", true)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	# The models face +Z; he faces -Z like everyone else.
	model.rotation.y = PI
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.006
	_bubble.outline_size = 8
	_bubble.font_size = 40
	_bubble.width = 1000.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.modulate = Color(0.85, 0.9, 1)
	_bubble.hide()
	add_child(_bubble)


## He sees `cop`: close enough and nothing in between.
func sees(cop: Node3D) -> bool:
	var eyes := global_position + Vector3.UP * EYES
	var target := cop.global_position + Vector3.UP * GameScale.EYE_HEIGHT
	if eyes.distance_to(target) > Bribes.SEEN_REACH:
		return false
	var query := PhysicsRayQueryParameters3D.create(eyes, target)
	query.exclude = [get_rid(), (cop as CollisionObject3D).get_rid()] if cop is CollisionObject3D else [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


## He saw the bribe.
func caught_bribe() -> void:
	say("AGENT_CAUGHT")


## The cuffs don't close on him.
func cuffed(_seconds: float) -> void:
	say("AGENT_BADGE")


func is_cuffed() -> bool:
	return false


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble_left <= 0.0:
		_bubble.hide()
	var cop := _nearest_cop()
	if not cop:
		return
	var to_cop := cop.global_position - global_position
	to_cop.y = 0.0
	if to_cop.length() > LOST:
		global_position = cop.global_position + cop.global_basis.z * FOLLOW / 2.0
		velocity = Vector3.ZERO
		return
	if to_cop.length() > 0.1:
		look_at(Vector3(cop.global_position.x, global_position.y, cop.global_position.z), Vector3.UP)
	var wish := to_cop.normalized() * WALK_SPEED if to_cop.length() > FOLLOW else Vector3.ZERO
	velocity.x = wish.x
	velocity.z = wish.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - 9.8 * delta
	move_and_slide()
	_note_left -= delta
	if _note_left <= 0.0:
		_note_left = NOTE_EVERY
		say("AGENT_NOTE_%d" % (randi() % NOTE_LINES + 1))


func _nearest_cop() -> Node3D:
	var best: Node3D
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if not best or global_position.distance_to(cop.global_position) < global_position.distance_to(best.global_position):
			best = cop
	return best
