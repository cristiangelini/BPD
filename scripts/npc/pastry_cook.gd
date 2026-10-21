class_name PastryCook
extends StaticBody3D

## One of the six cooks of the pastry contest (escena-del-crimen.md): all floury and alike, told apart by the color of
## the apron, the glasses, the hand that holds the whisk, the size of the shoes and, under the hat, the hair.

const MODEL := preload("res://assets/models/npc_pastelero.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)

## CookTraits.draw: name, apron, hair, glasses, left, shoe, teeth.
var traits := {}
var _model: Node3D


func _ready() -> void:
	add_to_group("pastry_cooks")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("apron", CookTraits.APRONS[traits.apron])
	_tint("hair", CookTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	# A lefty holds the whisk in the other hand.
	part("whisk").scale.x = -1.0 if traits.left else 1.0
	var size := inverse_lerp(CookTraits.SHOE_MIN, CookTraits.SHOE_MAX, traits.shoe)
	(_model.find_child("legs_cook_shoes", true, false) as Node3D).scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)


## A part of his model by name (apron, hair, glasses, whisk, cap...).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
