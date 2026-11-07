class_name Pedrusco
extends StaticBody3D

## El Pedrusco (escena-planetario.md, "La historia"): the meteorite that fell on the square a hundred years ago, a dark
## lumpy stone the size of a melon. Found in its hiding spot, it lies there until a cop takes it back to its display
## case with E (Planetarium.reveal_loot). Every number here is (propuesta).

const RADIUS := 0.2
const ROCK := Color(0.22, 0.2, 0.2)

var planetarium: Planetarium


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = RADIUS
	shape.shape = ball
	shape.position.y = RADIUS
	add_child(shape)
	var stone := StandardMaterial3D.new()
	stone.albedo_color = ROCK
	stone.roughness = 0.95
	stone.metallic = 0.4
	# A main lump and two smaller ones stuck to it, so it doesn't look like a ball.
	for lump: Array in [[Vector3(0, RADIUS, 0), Vector3(1.0, 0.8, 0.9), 1.0], [Vector3(0.1, RADIUS * 1.4, 0.05),
			Vector3(1, 1, 1), 0.55], [Vector3(-0.1, RADIUS * 0.8, -0.06), Vector3(1, 0.8, 1), 0.6]]:
		var sphere := SphereMesh.new()
		sphere.radius = RADIUS * lump[2]
		sphere.height = RADIUS * lump[2] * 2
		sphere.radial_segments = 7
		sphere.rings = 4
		var mesh := MeshInstance3D.new()
		mesh.mesh = sphere
		mesh.material_override = stone
		mesh.position = lump[0]
		mesh.scale = lump[1]
		add_child(mesh)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PEDRUSCO_RETURN"


func use(_cop: Cop) -> void:
	if planetarium:
		planetarium.reveal_loot()
