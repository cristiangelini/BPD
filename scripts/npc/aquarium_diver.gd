class_name AquariumDiver
extends StaticBody3D

## One of the six cleaning divers (escena-acuario.md, "Los seis buzos"): the same black wetsuit with a whale, hood,
## mask up on the forehead, gloves and flippers as the other five. Under the hood, their own hair (tinted); in the mask,
## prescription lenses if they need them; their flippers (stretched to their size) and their teeth (shown when they
## bite). The ink on their hands only shows with the glove off (step 3). E on them, they tell which tank they look
## after. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_buzo.glb")
## Flipper sizes stretch the flippers from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 4

## DiverTraits.draw: name, hair, glasses, shoe, teeth, ink, tank.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("aquarium_divers")
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
	_tint("hair", DiverTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	for side in ["left", "right"]:
		part("ink_%s" % side).visible = false
	var size := inverse_lerp(DiverTraits.SHOE_MIN, DiverTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_DIVER_TALK"


## E on them: a line about their tank (a different one each time, in an order that starts at their number), which
## always says which animals they look after.
func use(_cop: Cop) -> void:
	say(tr("DIVER_LINE_%d" % ((index + _lines_said) % LINES)) % tank_name())
	_lines_said += 1


## The animals of the tank they look after, translated ("los tiburones").
func tank_name() -> String:
	return tr("CARE_%s" % traits.tank)


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


## A part of their model by name (hood, hair, mask, glasses, teeth, legs, glove_left, glove_right, ink_left,
## ink_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
