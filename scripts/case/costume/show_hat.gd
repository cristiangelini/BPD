class_name ShowHat
extends Grabbable

## The magician's show hat on the wig trunk (allanamiento-disfraces.md, "Las bombas de humo"): thrown or dropped hard
## enough on something, a colored smoke bomb hidden in it goes off (the story's clue). It can puff again after a while.

signal puffed

const MODEL := preload("res://assets/models/show_hat.glb")
const SIZE := Vector3(0.34, 0.22, 0.34)
const PUFF_SPEED := 2.0
const PUFF_REST := 5.0
const COLORS: Array[Color] = [Color(1.0, 0.48, 0.78, 0.7), Color(0.35, 0.85, 0.42, 0.7), Color(0.35, 0.54, 0.91, 0.7)]

var puffs := 0
var _rest_left := 0.0
## How fast it went last frame (a contact already slowed it down by the time it's reported).
var _speed := 0.0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.4
	contact_monitor = true
	max_contacts_reported = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	body_entered.connect(_on_hit)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_rest_left = maxf(0.0, _rest_left - delta)
	_speed = linear_velocity.length()


func _on_hit(_body: Node) -> void:
	if _rest_left > 0.0 or is_held() or _speed < PUFF_SPEED:
		return
	puff()


## A cloud of colored smoke comes out of it.
func puff() -> void:
	_rest_left = PUFF_REST
	SmokeBombsRig.cloud(get_parent(), get_parent().to_local(global_position), COLORS[puffs % COLORS.size()], 1.0)
	puffs += 1
	puffed.emit()
