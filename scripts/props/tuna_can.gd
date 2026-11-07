class_name TunaCan
extends StaticBody3D

## A can of tuna on the mansion's kitchen counter (escena-gato.md, "La lata de atún"). E opens it, once: every cat
## within MansionCat.LURE_RANGE runs to eat it, but a cat locked away only meows from her hiding place.

const METAL := Color(0.75, 0.77, 0.8)

var open := false
## Where the cats eat it: the floor in front of the counter (world), set by the mansion.
var feed_at := Vector3.INF
var _lid: MeshInstance3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.08
	cylinder.height = 0.1
	shape.shape = cylinder
	add_child(shape)
	var can := CylinderMesh.new()
	can.top_radius = 0.07
	can.bottom_radius = 0.07
	can.height = 0.08
	var body := MeshInstance3D.new()
	body.mesh = can
	var material := StandardMaterial3D.new()
	material.albedo_color = METAL
	body.material_override = material
	add_child(body)
	var lid := CylinderMesh.new()
	lid.top_radius = 0.068
	lid.bottom_radius = 0.068
	lid.height = 0.005
	_lid = MeshInstance3D.new()
	_lid.name = "Lid"
	_lid.mesh = lid
	_lid.position.y = 0.043
	_lid.material_override = material
	add_child(_lid)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TUNA_CAN_OPEN" if open else "PROMPT_TUNA_CAN"


func use(_cop: Cop) -> void:
	if open:
		return
	open = true
	# The lid rolled back, showing the tuna.
	_lid.position = Vector3(0.06, 0.07, 0)
	_lid.rotation.z = PI / 2.5
	get_tree().call_group("mansion_cats", "lure", global_position if feed_at == Vector3.INF else feed_at)
