class_name ParrotCrackers
extends StaticBody3D

## The tin of parrot crackers at the foot of Don Plumas's cage (escena-gato.md, "Las pistas"): E gives him one.

const TIN := Color(0.85, 0.3, 0.25)

var parrot: MansionParrot


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.22, 0.2, 0.22)
	shape.shape = box
	shape.position.y = 0.1
	add_child(shape)
	var tin := CylinderMesh.new()
	tin.top_radius = 0.1
	tin.bottom_radius = 0.1
	tin.height = 0.18
	PlaceBuilder.new(self).mesh(tin, Vector3(0, 0.09, 0), TIN)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PARROT_CRACKERS"


func use(_cop: Cop) -> void:
	if parrot:
		parrot.feed()
