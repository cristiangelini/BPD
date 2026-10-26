class_name DebateProp
extends Grabbable

## What the cops carry in the TV debate (politico-debate.md, step 4, decision 230): a "card", one of the cue cards
## with a good answer that the deputy reads when it's held close to him, or the "mic", the spare microphone from the
## makeup room. Both are light. Every number here is (propuesta).

const MODELS := {"card": preload("res://assets/models/cue_card.glb"), "mic": preload("res://assets/models/spare_mic.glb")}
const SIZES := {"card": Vector3(0.5, 0.85, 0.05), "mic": Vector3(0.08, 0.08, 0.27)}
const KG := {"card": 0.4, "mic": 0.3}

@export var kind := "card"
## A card's text (a tr() key).
var text := ""


func _ready() -> void:
	add_to_group("debate_props")
	mass = KG[kind]
	collision_layer = 4
	collision_mask = 15
	var size: Vector3 = SIZES[kind]
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position.y = size.y / 2 if kind == "card" else 0.0
	add_child(shape)
	var model: Node3D = MODELS[kind].instantiate()
	model.name = "Model"
	add_child(model)
	if kind == "card":
		var label := Label3D.new()
		label.name = "Text"
		label.text = text
		label.font_size = 28
		label.pixel_size = 0.0016
		label.width = 290.0
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.modulate = Color(0.1, 0.1, 0.12)
		label.outline_size = 0
		label.position = Vector3(0, 0.66, 0.02)
		add_child(label)
