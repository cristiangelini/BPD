class_name FarmPig
extends StaticBody3D

## One of Don Florencio's pigs (docs/diseno/allanamiento-granja.md, "Los chanchos"): it wallows around the pigsty's mud
## and shoves whoever comes into its way, like the gym's dummies. Every number here is (propuesta).

signal shoved(cop: Cop)
## E on it: a cop takes a close look at its snout.
signal looked(cop: Cop)

const MODEL := preload("res://assets/models/farm_pig.glb")
const SPEED := 0.6
const WANDER_EVERY := 3.0
## A cop this close gets shoved PUSH m/s away, once every SHOVE_EVERY seconds.
const REACH := 1.0
const PUSH := 4.0
const STAGGER := 0.6
const SHOVE_EVERY := 2.0

## Where it wallows, in the farm's space (set before it's added).
var mud := Rect2()
var farm: Node3D
var rng := RandomNumberGenerator.new()
var _target := Vector3.ZERO
var _wander_left := 0.0
var _shove_wait := 0.0
var _beat := 0.0
var _model: Node3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 0.6, 0.9)
	shape.shape = box
	shape.position.y = 0.3
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_target = position


func _physics_process(delta: float) -> void:
	_beat += delta
	_shove_wait = maxf(_shove_wait - delta, 0.0)
	if farm:
		_wander_left -= delta
		if _wander_left <= 0.0:
			_wander_left = WANDER_EVERY * rng.randf_range(0.5, 1.5)
			_target = Vector3(rng.randf_range(mud.position.x, mud.end.x), position.y,
				rng.randf_range(mud.position.y, mud.end.y))
		var to := _target - position
		to.y = 0.0
		if to.length() > 0.2:
			position += to.normalized() * SPEED * delta
			rotation.y = atan2(to.x, to.z)
			_model.rotation.z = sin(_beat * 8.0) * 0.08
	if _shove_wait <= 0.0:
		_shove()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_LOOK_PIG"


func use(cop: Cop) -> void:
	looked.emit(cop)


func _shove() -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var away := cop.global_position - global_position
		away.y = 0.0
		if cop.vehicle or away.length() > REACH:
			continue
		_shove_wait = SHOVE_EVERY
		cop.knock_back((away.normalized() if away.length() > 0.01 else Vector3.BACK) * PUSH, STAGGER)
		cop.show_hint("HINT_PIG_SHOVE")
		shoved.emit(cop)
		return
