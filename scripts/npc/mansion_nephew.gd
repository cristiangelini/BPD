class_name MansionNephew
extends StaticBody3D

## One of Señora Ofelia's six nephews (escena-gato.md, "Los seis sobrinos iguales"): the same green sweater with the
## ginger cat, red beanie and scarf as the other five. Under the beanie, their own hair (tinted); their glasses, if they
## wear them; their shoes (stretched to their size) and their teeth (shown when they bite). The scratch on one hand only
## shows with the sleeves rolled up (step 4). E on them, they talk about the inheritance and end with their catchphrase.
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_sobrino_tia.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 5

## NephewTraits.draw: name, hair, glasses, shoe, teeth, scratch, tic.
var traits := {}
## Their suitcase's number, from 0 (the order of the case's traits).
var index := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("mansion_nephews")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", NephewTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	for hand in NephewTraits.HANDS:
		part("scratch_%s" % hand).visible = false
	var size := inverse_lerp(NephewTraits.SHOE_MIN, NephewTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_NEPHEW_TALK"


## E on them: a line about the inheritance (a different one each time, in an order that starts at their number) and
## their catchphrase.
func use(_cop: Cop) -> void:
	say(tr("NEPHEW_LINE_%d" % ((index + _lines_said) % LINES)) % catchphrase())
	_lines_said += 1


## Their catchphrase, translated.
func catchphrase() -> String:
	return tr("NEPHEW_TIC_%d" % traits.tic)


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


## A part of their model by name (beanie, hair, glasses, teeth, legs, scratch_left, scratch_right, cuff_left...).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
