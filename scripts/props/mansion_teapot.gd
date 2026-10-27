class_name MansionTeapot
extends StaticBody3D

## The teapot on the mansion's kitchen counter (escena-gato.md, "Recuperarla"): E pours a cup of tea (TeaCup) next to
## it, one at a time, for the señora.

const WHITE := Color(0.96, 0.96, 0.98)

var cup: TeaCup


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.26, 0.22, 0.26)
	shape.shape = box
	shape.position.y = 0.11
	add_child(shape)
	var pot := SphereMesh.new()
	pot.radius = 0.12
	pot.height = 0.2
	var builder := PlaceBuilder.new(self)
	builder.mesh(pot, Vector3(0, 0.1, 0), WHITE)
	builder.mesh_box(Vector3(0.15, 0.12, 0), Vector3(0.1, 0.03, 0.03), WHITE)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TEAPOT"


## Pours a cup beside it, unless the last one is still around.
func use(cop: Cop) -> void:
	if is_instance_valid(cup) and cup.is_inside_tree():
		if cop:
			cop.show_hint("HINT_TEA_POURED")
		return
	cup = TeaCup.new()
	cup.name = "TeaCup"
	get_parent().add_child(cup)
	cup.global_position = to_global(Vector3(-0.3, 0.02, 0))
