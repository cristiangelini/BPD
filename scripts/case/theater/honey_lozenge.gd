class_name HoneyLozenge
extends Grabbable

## One of the honey lozenges on the little table by the ticket booth (escena-teatro.md, "Las pistas"): E with it in
## hand on Don Susurro and he sucks it and talks (TheaterPrompter.feed); on a ghost who hasn't sung yet, it clears
## their voice and the note says nothing (TheaterGhost.take_lozenge). Made with the theater, so every PC has the same
## ones.

const HONEY := Color(0.95, 0.68, 0.15)

var eaten := false


func _ready() -> void:
	mass = 0.03
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.08, 0.04, 0.08)
	shape.shape = box
	shape.position.y = 0.02
	add_child(shape)
	var drop := SphereMesh.new()
	drop.radius = 0.035
	drop.height = 0.04
	PlaceBuilder.new(self).mesh(drop, Vector3(0, 0.02, 0), HONEY)


func held_prompt_key(cop: Cop) -> String:
	var aimed := cop._usable_target()
	if aimed is TheaterPrompter:
		return "PROMPT_LOZENGE_PROMPTER"
	if aimed is TheaterGhost:
		return "PROMPT_LOZENGE_GHOST"
	return "PROMPT_HOLDING"


## Gone into someone's mouth.
func eat() -> void:
	eaten = true
	visible = false
	freeze = true
	collision_layer = 0
