class_name CircusClown
extends StaticBody3D

## One of the six clowns of the Cascabel Brothers' circus (escena-circo.md, "Los payasos iguales"): the same wig,
## nose, white makeup, gloves and giant shoes as the other five. Under them, his own hair (tinted), his glasses (shown
## only without makeup), his real feet (stretched to his size) and his teeth. E on him: he tells a joke. Taking off what
## hides him comes in step 4. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_payaso.glb")
## Real feet sizes stretch the feet from this much (the smallest) to this much (the biggest).
const FEET_SCALE := Vector2(0.85, 1.3)
const JOKES := 6

## ClownTraits.draw: name, hair, glasses, shoe, teeth, honk.
var traits := {}
## His caravan's number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var makeup_on := true
var wig_on := true
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _jokes_told := 0


func _ready() -> void:
	add_to_group("circus_clowns")
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
	_tint("hair", ClownTraits.HAIRS[traits.hair])
	part("teeth").visible = false
	var size := inverse_lerp(ClownTraits.SHOE_MIN, ClownTraits.SHOE_MAX, traits.shoe)
	(_model.find_child("legs", true, false) as Node3D).scale.z = lerpf(FEET_SCALE.x, FEET_SCALE.y, size)
	_show_disguise()
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CLOWN_TALK"


## E on him: a joke, a different one each time (in an order that starts at his number).
func use(_cop: Cop) -> void:
	say("CLOWN_JOKE_%d" % ((index + _jokes_told) % JOKES))
	_jokes_told += 1


## Whether he looks like the other five: makeup and wig on, gloves and both giant shoes too.
func disguised() -> bool:
	return makeup_on and wig_on


## What shows depends on what he still has on: his glasses only without the white makeup, his hair only without the
## wig.
func _show_disguise() -> void:
	part("makeup").visible = makeup_on
	part("glasses").visible = traits.glasses and not makeup_on
	part("wig").visible = wig_on
	part("hair").visible = not wig_on


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


## A part of his model by name (makeup, wig, hair, glasses, gloves, shoe_left, shoe_right, nose, teeth, legs...).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
