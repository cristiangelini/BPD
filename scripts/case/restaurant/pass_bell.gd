class_name PassBell
extends StaticBody3D

## The bell on the pass's counter (infiltracion-restaurante.md, step 4): E rings it, and the host sends out the plates
## on the counter against the Chef's orders (RestaurantOrders.ring).

const RADIUS := 0.07

var orders: RestaurantOrders
var _ding: AudioStreamPlayer3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(RADIUS * 3, RADIUS * 1.5, RADIUS * 3)
	shape.shape = box
	shape.position.y = RADIUS * 0.75
	add_child(shape)
	var dome := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = RADIUS
	mesh.height = RADIUS
	mesh.is_hemisphere = true
	dome.mesh = mesh
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color(0.95, 0.8, 0.3)
	gold.metallic = 0.6
	gold.roughness = 0.3
	dome.material_override = gold
	add_child(dome)
	var base := MeshInstance3D.new()
	var plinth := CylinderMesh.new()
	plinth.top_radius = RADIUS * 1.3
	plinth.bottom_radius = RADIUS * 1.3
	plinth.height = 0.015
	base.mesh = plinth
	base.position.y = 0.0075
	add_child(base)
	_ding = AudioStreamPlayer3D.new()
	_ding.stream = ding_stream()
	_ding.max_distance = 30.0
	add_child(_ding)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PASS_BELL"


## Ding, and the host sends the plates out.
func use(cop: Cop) -> void:
	_ding.play()
	if multiplayer.is_server() and orders:
		orders.ring(cop)


## One bright "ding" that fades.
static func ding_stream() -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * 0.8)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / rate
		var value := (sin(TAU * 2100.0 * t) + 0.4 * sin(TAU * 5300.0 * t)) * 0.4 * exp(-5.0 * t)
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 30000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream
