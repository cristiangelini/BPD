class_name TeaCup
extends Grabbable

## A cup of tea poured from the mansion's teapot (escena-gato.md, "Recuperarla"): carried to Señora Ofelia, she drinks
## it and gets some patience back, once.

const CHINA := Color(0.97, 0.95, 0.92)
const TEA := Color(0.6, 0.35, 0.15)


func _ready() -> void:
	add_to_group("tea_cups")
	collision_layer = 4
	collision_mask = 15
	mass = 0.3
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.12, 0.08, 0.12)
	shape.shape = box
	shape.position.y = 0.04
	add_child(shape)
	var cup := CylinderMesh.new()
	cup.top_radius = 0.055
	cup.bottom_radius = 0.04
	cup.height = 0.07
	var builder := PlaceBuilder.new(self)
	builder.mesh(cup, Vector3(0, 0.035, 0), CHINA)
	builder.mesh_box(Vector3(0, 0.066, 0), Vector3(0.07, 0.004, 0.07), TEA)


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_TEA"
