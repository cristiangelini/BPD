class_name GiantPearl
extends StaticBody3D

## La Gorda (escena-acuario.md, "La historia"): the biggest pearl in the city, the size of a tennis ball. Found in its
## hiding spot, it lies there until a cop takes it back to Doña Almeja with E (Aquarium.reveal_loot). Every number
## here is (propuesta).

const RADIUS := 0.12
const PEARL := Color(0.97, 0.95, 0.92)

var aquarium: Aquarium


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = RADIUS
	shape.shape = ball
	shape.position.y = RADIUS
	add_child(shape)
	var sphere := SphereMesh.new()
	sphere.radius = RADIUS
	sphere.height = RADIUS * 2
	var mesh := MeshInstance3D.new()
	mesh.mesh = sphere
	var shine := StandardMaterial3D.new()
	shine.albedo_color = PEARL
	shine.metallic = 0.3
	shine.roughness = 0.15
	shine.emission_enabled = true
	shine.emission = Color(0.25, 0.22, 0.28)
	mesh.material_override = shine
	mesh.position.y = RADIUS
	add_child(mesh)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PEARL_RETURN"


func use(_cop: Cop) -> void:
	if aquarium:
		aquarium.reveal_loot()
