class_name PrisonInmate
extends CharacterBody3D

## An inmate in the prison's canteen (carcel-motin.md, step 2, decision 104): standing at their place by a table, with
## an `anger` from 0 to MAX_ANGER. It goes up with what upsets them (raise: food on them, step 2b) and, once the riot
## is on, drifts down DECAY a second after CALM_AFTER seconds left alone. At ANGRY or more they're angry: red steam over
## their head and shouts; step 2b has them throw food. Every number here is (propuesta).

## They got angry, or calmed down below ANGRY.
signal angry_changed(inmate: PrisonInmate, angry: bool)

const MODEL := preload("res://assets/models/npc_preso.glb")
const MAX_ANGER := 100.0
const ANGRY := 60.0
const DECAY := 3.0
const CALM_AFTER := 5.0
const SHOUTS := 6
const SHOUT_EVERY := 5.0
const SAY_TIME := 3.0
const STEAM_COLOR := Color(0.95, 0.2, 0.15)

var anger := 0.0
## The riot is on: anger drifts down and the angry ones shout (PrisonRiot.start).
var active := false
## A guest's copy (NpcSync): the host's says how angry they are.
var follower := false
var _quiet_left := 0.0
var _shout_left := 0.0
var _next_shout := 0
var _was_angry := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _steam: Label3D


func _ready() -> void:
	add_to_group("prison_inmates")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z; the inmate's front is -Z, like the other NPCs placed by code.
	_model.rotation.y = PI
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.85, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	_steam = Label3D.new()
	_steam.name = "Steam"
	_steam.text = "#@!"
	_steam.font_size = 90
	_steam.pixel_size = 0.004
	_steam.outline_size = 14
	_steam.modulate = STEAM_COLOR
	_steam.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_steam.position = Vector3(0, 1.6, 0)
	add_child(_steam)
	_update()


func is_angry() -> bool:
	return anger >= ANGRY


## Something upset them: `points` more anger, and they stay upset a while before it starts going down.
func raise(points: float) -> void:
	anger = minf(anger + points, MAX_ANGER)
	_quiet_left = CALM_AFTER
	_update()


## Something calmed them: `points` less anger.
func calm(points: float) -> void:
	anger = maxf(anger - points, 0.0)
	_update()


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## What a guest's copy needs besides where they are and what they say (NpcSync).
func net_state() -> Array:
	return [snappedf(anger, 0.5), active]


func apply_net_state(state: Variant) -> void:
	anger = state[0]
	active = state[1]
	_update()


func _update() -> void:
	if not is_node_ready():
		return
	var angry := is_angry()
	_steam.visible = angry
	if angry != _was_angry:
		_was_angry = angry
		if angry:
			_shout_left = 0.0
		angry_changed.emit(self, angry)


func _physics_process(delta: float) -> void:
	if not active or follower:
		return
	_quiet_left -= delta
	if _quiet_left <= 0.0 and anger > 0.0:
		calm(DECAY * delta)
	if is_angry():
		_shout_left -= delta
		if _shout_left <= 0.0:
			_shout_left = SHOUT_EVERY + randf_range(0.0, 2.0)
			say("INMATE_SHOUT_%d" % (_next_shout % SHOUTS + 1))
			_next_shout += 1


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
