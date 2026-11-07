class_name EarTrumpet
extends Grabbable

## Grandma Chola's brass ear trumpet (escena-boda.md, "La abuela sorda"), on her table. In hand, E on her
## (WeddingGrandma) gives it back, and then she hears: for whoever plays without a microphone. Every number here is
## (propuesta).

const MODEL := preload("res://assets/models/ear_trumpet.glb")


func _ready() -> void:
	mass = 0.3
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.26, 0.26, 0.5)
	shape.shape = box
	shape.position = Vector3(0, 0.13, 0.03)
	add_child(shape)
	add_child(MODEL.instantiate())


func held_prompt_key(cop: Cop) -> String:
	return "PROMPT_TRUMPET_GIVE" if cop._usable_target() is WeddingGrandma else "PROMPT_HOLDING"


## E with it in hand: back to grandma if the cop aims at her; nothing otherwise.
func use(cop: Cop) -> void:
	var grandma := cop._usable_target() as WeddingGrandma
	if not grandma:
		return
	cop.get_node("Grabber").release()
	grandma.hear()
	queue_free()
