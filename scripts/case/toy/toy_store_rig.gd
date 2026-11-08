class_name ToyStoreRig
extends Node

## What only one of the toy store's stories adds (allanamiento-jugueteria.md, "Las historias"), like IceCreamRig for
## the ice cream shop. The store adds the story's rig as a child once its hidden items are placed and calls setup; the
## rig can then run its own mechanic.

var store: ToyStore


func setup(place: ToyStore) -> void:
	store = place


## A small sign standing at `at`, facing `turn` around Y, with `title` on it and a clue a cop reads with E (`text`, on
## the checklist the first time).
func sign_spot(at: Vector3, turn: float, title: String, text: String, size := Vector3(0.5, 0.3, 0.06)) -> ClueSpot:
	var spot := ClueSpot.new()
	spot.size = size
	spot.text = text
	spot.position = at
	spot.rotation.y = turn
	spot.read.connect(store.raid.add_clue)
	store.add_child(spot)
	var face := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, size.y, 0.02)
	face.mesh = box
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color(0.98, 0.96, 0.9)
	face.material_override = paint
	spot.add_child(face)
	var label := Label3D.new()
	label.text = title
	label.font_size = 24
	label.pixel_size = 0.0025
	label.modulate = Color(0.2, 0.3, 0.75)
	label.outline_size = 0
	label.width = size.x / 0.0025 * 0.9
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.position = Vector3(0, 0, 0.015)
	spot.add_child(label)
	return spot
