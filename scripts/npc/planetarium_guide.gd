class_name PlanetariumGuide
extends StaticBody3D

## One of the six guides (escena-planetario.md, "Los seis guías"): the same white astronaut suit, helmet with the visor
## down, gloves and moon boots as the other five. Under the helmet, their own hair (tinted); their moon boots
## (stretched to their size), their teeth (shown when they bite) and the pin of their planet on the chest. The glow
## paint on their gloves only shows in the dark (step 5). E on them, they tell which planet they present. Every number
## here is (propuesta).

const MODEL := preload("res://assets/models/npc_guia.glb")
## Boot sizes stretch the boots from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 4

## GuideTraits.draw: name, hair, shoe, teeth, glow, planet.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("planetarium_guides")
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
	_tint("hair", GuideTraits.HAIRS[traits.hair])
	_tint("pin", Planetarium.PLANET_COLORS[traits.planet])
	part("teeth").visible = false
	for side in ["left", "right"]:
		part("glow_%s" % side).visible = false
	var size := inverse_lerp(GuideTraits.SHOE_MIN, GuideTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_GUIDE_TALK"


## E on them: a line about their planet (a different one each time, in an order that starts at their number), which
## always says which planet they present.
func use(_cop: Cop) -> void:
	say(tr("GUIDE_LINE_%d" % ((index + _lines_said) % LINES)) % planet_name())
	_lines_said += 1


## The planet they present, translated ("Júpiter").
func planet_name() -> String:
	return tr("PLANET_%s" % traits.planet)


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


## A part of their model by name (helmet, hair, teeth, legs, pin, glove_left, glove_right, glow_left, glow_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
