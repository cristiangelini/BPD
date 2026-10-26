class_name MuseumGuard
extends StaticBody3D

## One of the six guards of the city museum (escena-museo.md, "Los guardias iguales"): the same grey uniform, cap,
## flashlight and thick black mustache as the other five. Under the cap, his own hair (tinted); his glasses, if he
## wears them; his shoes (stretched to his size) and his teeth (shown when he bites). Whether the mustache is his own
## only shows when a cop pulls it (step 3). E on him, he swears he was in the bathroom. Every number here is
## (propuesta).

const MODEL := preload("res://assets/models/npc_guardia_museo.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 6

## GuardTraits.draw: name, hair, glasses, shoe, teeth, mustache.
var traits := {}
## His locker's number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("museum_guards")
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
	_tint("hair", GuardTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	var size := inverse_lerp(GuardTraits.SHOE_MIN, GuardTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
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
	return "PROMPT_GUARD_TALK"


## E on him: he swears he was in the bathroom, a different way each time (in an order that starts at his number).
func use(_cop: Cop) -> void:
	say("GUARD_LINE_%d" % ((index + _lines_said) % LINES))
	_lines_said += 1


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


## A part of his model by name (cap, hair, mustache, glasses, teeth, legs).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
