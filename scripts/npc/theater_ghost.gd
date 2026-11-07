class_name TheaterGhost
extends StaticBody3D

## One of the six ghost actors (escena-teatro.md, "Los seis fantasmas"): the same white sheet with two eye holes,
## gloves and plastic chains as the other five. Under the sheet, their own hair (tinted); their shoes peeking out (stretched
## to their size), their teeth (shown when they bite) and the patch of their embroidery on the hem. E on them, they
## tell which embroidery is theirs and why. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_fantasma.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)

## GhostTraits.draw: name, hair, shoe, teeth, deep, embroidery.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("theater_ghosts")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", GhostTraits.HAIRS[traits.hair])
	_tint("embroidery", GhostTraits.EMBROIDERY_COLORS[traits.embroidery])
	part("teeth").visible = false
	var size := inverse_lerp(GhostTraits.SHOE_MIN, GhostTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_GHOST_TALK"


## E on them: their embroidery and why it is theirs.
func use(_cop: Cop) -> void:
	say(tr("GHOST_EMBROIDERY_%s" % traits.embroidery))


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## A part of their model by name (sheet, hair, teeth, legs, embroidery, glove_left, glove_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
