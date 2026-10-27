class_name WrongHouseRig
extends Node

## What only one of the guilty neighbor's stories adds (casa-equivocada.md, "Las historias"), like GroomerRig for the
## pet salon. The wrong house adds the story's rig as a child once its hidden items are placed and calls setup; the
## rig can then set the main evidence, add the story's own clue and run its mechanic every frame.

var place: WrongHouse


func setup(wrong_house: WrongHouse) -> void:
	place = wrong_house


## A clue fixed to the place that goes to the checklist the first time a cop reads it.
func clue_spot(where: Vector3, size: Vector3, prompt: String, text_key: String) -> ClueSpot:
	var spot := ClueSpot.new()
	spot.size = size
	spot.prompt = prompt
	spot.text = tr(text_key)
	spot.position = where
	spot.read.connect(place._on_clue)
	place.add_child(spot)
	return spot


## A flat colored piece over something (a bill on the mailbox, a hole in the grass), only for the look.
func patch(parent: Node3D, offset: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	mesh.position = offset
	parent.add_child(mesh)
	return mesh
