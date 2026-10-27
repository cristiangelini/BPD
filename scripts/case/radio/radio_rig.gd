class_name RadioRig
extends Node

## What only one of the radio's stories adds (allanamiento-radio.md, "Las historias"), like CinemaRig for the cinema.
## The radio adds the story's rig as a child once its hidden items are placed and calls setup; the rig can then set the
## radio's main evidence and run its own mechanic.

var radio: RadioStation


func setup(place: RadioStation) -> void:
	radio = place


## A board on a wall, facing `turn` around Y, with `title` on it and a clue a cop reads with E (`text`, on the
## checklist the first time).
func board(at: Vector3, turn: float, title: String, text: String, prompt := "PROMPT_NOTE") -> ClueSpot:
	var spot := ClueSpot.new()
	spot.size = Vector3(1.2, 0.8, 0.1)
	spot.prompt = prompt
	spot.text = text
	spot.position = at
	spot.rotation.y = turn
	spot.read.connect(radio.raid.add_clue)
	radio.add_child(spot)
	var face := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.2, 0.8, 0.04)
	face.mesh = box
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color(0.95, 0.95, 0.92)
	face.material_override = paint
	spot.add_child(face)
	var label := Label3D.new()
	label.text = title
	label.font_size = 32
	label.pixel_size = 0.004
	label.modulate = Color(0.15, 0.15, 0.2)
	label.outline_size = 0
	label.width = 280.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.position = Vector3(0, 0.0, 0.03)
	spot.add_child(label)
	return spot


## A clue fixed to the place with its model (`model`'s origin at its foot): a box of `size` a cop aims at, standing on
## `at` and facing `turn` around Y, with the clue `text` read with E (on the checklist the first time).
func fixed_clue(model: PackedScene, at: Vector3, size: Vector3, turn: float, prompt: String, text: String) -> ClueSpot:
	var spot := ClueSpot.new()
	spot.size = size
	spot.prompt = prompt
	spot.text = text
	spot.position = at + Vector3.UP * size.y / 2
	spot.rotation.y = turn
	spot.read.connect(radio.raid.add_clue)
	radio.add_child(spot)
	var shown: Node3D = model.instantiate()
	shown.position = Vector3.DOWN * size.y / 2
	spot.add_child(shown)
	return spot
