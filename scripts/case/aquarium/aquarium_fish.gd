class_name AquariumFish
extends Grabbable

## A fish from the tray on the aquarium's kitchen counter (escena-acuario.md, "Bigotes"). In hand, E on Bigotes
## (SeaLion) gives it to him, and he gives back what he stole. Every number here is (propuesta).

const SILVER := Color(0.75, 0.8, 0.86)


func _ready() -> void:
	mass = 0.3
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.32, 0.06, 0.1)
	shape.shape = box
	shape.position.y = 0.03
	add_child(shape)
	# A fat silver body lying on its side, a forked tail and an eye on top.
	var body := SphereMesh.new()
	body.radius = 0.05
	body.height = 0.1
	_part(body, Vector3(-0.02, 0.035, 0), Vector3(2.4, 0.7, 1.0), Vector3.ZERO, SILVER)
	var tail := PrismMesh.new()
	tail.size = Vector3(0.1, 0.08, 0.02)
	_part(tail, Vector3(0.14, 0.035, 0), Vector3.ONE, Vector3(PI / 2, 0, PI / 2), SILVER.darkened(0.25))
	var eye := SphereMesh.new()
	eye.radius = 0.012
	eye.height = 0.024
	_part(eye, Vector3(-0.09, 0.06, 0.02), Vector3.ONE, Vector3.ZERO, Color(0.05, 0.05, 0.08))


func _part(mesh: Mesh, at: Vector3, size: Vector3, turn: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = at
	part.scale = size
	part.rotation = turn
	var paint := StandardMaterial3D.new()
	paint.albedo_color = color
	paint.metallic = 0.4
	paint.roughness = 0.35
	part.material_override = paint
	add_child(part)


func held_prompt_key(cop: Cop) -> String:
	return "PROMPT_GIVE_FISH" if cop._usable_target() is SeaLion else "PROMPT_HOLDING_FISH"


## E with it in hand: to Bigotes if the cop aims at him; nothing otherwise.
func use(cop: Cop) -> void:
	var sea_lion := cop._usable_target() as SeaLion
	if not sea_lion:
		return
	cop.get_node("Grabber").release()
	sea_lion.feed(cop)
	queue_free()
