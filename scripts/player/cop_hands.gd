class_name CopHands
extends Node3D

## The player's own sleeves and mitten hands in first person (Cristian picked the mittens on 19/10). They hang under
## the camera, sway while walking, reach forward while holding something, pull back near walls and hide behind the
## battering ram. Only the cop with a player at the keys has them; the others see the whole body instead.

const MODELS: Array[PackedScene] = [
	preload("res://assets/models/cop_hands_0.glb"), preload("res://assets/models/cop_hands_1.glb"),
	preload("res://assets/models/cop_hands_2.glb"), preload("res://assets/models/cop_hands_3.glb"),
]
## Holding something: the hands go this far forward and up, toward it (propuesta).
const REACH := Vector3(0.0, 0.06, -0.12)
## A wall closer than this pushes the hands back so they don't go through it.
const WALL_NEAR := 0.75
const PULL_BACK := 0.25
## Sway while walking: height and side in meters, and steps per second at walking speed.
const BOB_UP := 0.012
const BOB_SIDE := 0.008
const BOB_RATE := 1.8
const EASE := 10.0

var cop: Cop
var model: Node3D
var _bob := 0.0


func _init(owner_cop: Cop) -> void:
	cop = owner_cop
	name = "Hands"


func _ready() -> void:
	set_skin(cop.uniform)


## Swaps the mittens for the skin of player `index` (0 to 3), like Cop.set_uniform.
func set_skin(index: int) -> void:
	if model:
		model.queue_free()
	model = MODELS[index % MODELS.size()].instantiate()
	# Built looking +Z; the camera looks -Z.
	model.rotation.y = PI
	add_child(model)
	for mesh in model.find_children("*", "GeometryInstance3D", true, false):
		(mesh as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Where the hands rest right now, relative to the camera, without the sway.
func target_offset() -> Vector3:
	var offset := Vector3.ZERO
	if cop.get_node("Grabber").held:
		offset += REACH
	if not cop.aim_hit(WALL_NEAR).is_empty():
		offset.z += PULL_BACK
	return offset


func _process(delta: float) -> void:
	visible = cop.ram == null
	if not visible:
		return
	var speed := Vector2(cop.velocity.x, cop.velocity.z).length()
	if speed > 0.2 and cop.is_on_floor():
		_bob += delta * BOB_RATE * TAU * speed / GameScale.WALK_SPEED
	var sway := Vector3(sin(_bob * 0.5) * BOB_SIDE, -absf(sin(_bob)) * BOB_UP, 0.0) if speed > 0.2 else Vector3.ZERO
	position = position.lerp(target_offset() + sway, clampf(delta * EASE, 0.0, 1.0))
