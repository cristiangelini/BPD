class_name ParrotCookie
extends Grabbable

## One of the parrot cookies on the plate by window 2 (escena-correo.md, "Las pistas"): E with it in hand on Cartita
## and she eats it, and then talks (PostParrot.feed). Made with the post office, so every PC has the same ones.

const DOUGH := Color(0.85, 0.66, 0.38)

var eaten := false


func _ready() -> void:
	mass = 0.05
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.12, 0.03, 0.12)
	shape.shape = box
	shape.position.y = 0.015
	add_child(shape)
	var disc := CylinderMesh.new()
	disc.top_radius = 0.06
	disc.bottom_radius = 0.06
	disc.height = 0.025
	PlaceBuilder.new(self).mesh(disc, Vector3(0, 0.0125, 0), DOUGH)


func held_prompt_key(cop: Cop) -> String:
	return "PROMPT_PARROT_FEED" if cop._usable_target() is PostParrot else "PROMPT_HOLDING"


## Gone into Cartita's beak.
func eat() -> void:
	eaten = true
	visible = false
	freeze = true
	collision_layer = 0
