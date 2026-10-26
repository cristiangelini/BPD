class_name TrainSticker
extends Grabbable

## A numbered sticker from the roll on the ticket machine (escena-tren.md, "Las calcomanías"): with it in hand, E on a
## magician sticks it on his cape (Train.stick_sticker) and his file on the board follows the number, whatever seat
## he ends up in after a tunnel. A sticker peeled off lies here again.

const SIZE := Vector3(0.14, 0.14, 0.01)
const PAPER := Color(1.0, 0.85, 0.2)

## The number on it, from 0 (it shows number + 1).
var number := 0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.02
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE + Vector3(0, 0, 0.02)
	shape.shape = box
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = SIZE
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = PAPER
	mesh.material_override = material
	add_child(mesh)


func _ready() -> void:
	add_to_group("train_stickers")
	for side: float in [1.0, -1.0]:
		var label := Label3D.new()
		label.text = str(number + 1)
		label.font_size = 64
		label.pixel_size = 0.002
		label.modulate = Color(0.1, 0.1, 0.12)
		label.outline_size = 0
		label.position = Vector3(0, 0, side * (SIZE.z / 2 + 0.002))
		label.rotation.y = 0.0 if side > 0 else PI
		add_child(label)


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRAIN_STICKER_HELD"
