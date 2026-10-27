class_name AquariumCrab
extends Grabbable

## A crab from the box in the aquarium's kitchen (escena-acuario.md, "Las pistas"). In hand, E on Doña Tinta's glass
## (AquariumOctopus) gives it to her, and then she draws. Every number here is (propuesta).

const RED := Color(0.9, 0.3, 0.2)


func _ready() -> void:
	mass = 0.2
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.2, 0.08, 0.15)
	shape.shape = box
	shape.position.y = 0.04
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.04, 0), Vector3(0.16, 0.06, 0.12), RED)
	for side: float in [-1.0, 1.0]:
		builder.mesh_box(Vector3(side * 0.1, 0.05, 0.07), Vector3(0.05, 0.04, 0.04), RED.darkened(0.15))
		builder.mesh_box(Vector3(side * 0.03, 0.08, 0.05), Vector3(0.015, 0.03, 0.015), Color(0.08, 0.08, 0.1))


func held_prompt_key(cop: Cop) -> String:
	return "PROMPT_GIVE_CRAB" if cop._usable_target() is AquariumOctopus else "PROMPT_HOLDING_CRAB"


## E with it in hand: to Doña Tinta if the cop aims at her and she takes it; nothing otherwise.
func use(cop: Cop) -> void:
	var octopus := cop._usable_target() as AquariumOctopus
	if not octopus or not octopus.feed(cop):
		return
	cop.get_node("Grabber").release()
	queue_free()
