class_name TrainMagician
extends StaticBody3D

## One of the six magicians on the train El Lento (escena-tren.md, "Los magos iguales"): the same black cape, top hat,
## long fake beard and white gloves as the other five. Under the hat, his own hair (tinted); his glasses, if he wears
## them; his shoes (stretched to his size) and his teeth (shown when he bites). E on him: a trick, a different one
## each time (a dove, a long hanky, a coin from behind the cop's ear), and he says his stage name. His file for the
## board comes in step 3. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_mago.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const TRICKS: Array[String] = ["dove", "hanky", "coin"]
## Seconds a trick's prop shows.
const TRICK_SECONDS := 2.0

## MagicianTraits.draw: name, hair, glasses, left, shoe, teeth.
var traits := {}
## His place in the case's traits, from 0.
var index := 0
var tricks_done := 0
var _trick_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("train_magicians")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", MagicianTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	for trick in TRICKS:
		part(trick).visible = false
	var size := inverse_lerp(MagicianTraits.SHOE_MIN, MagicianTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.3, 0)
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
	return "PROMPT_MAGICIAN_TALK"


func use(_cop: Cop) -> void:
	trick()


## The next trick: its prop shows for a moment and he says his stage name.
func trick() -> void:
	var kind := TRICKS[tricks_done % TRICKS.size()]
	tricks_done += 1
	for other in TRICKS:
		part(other).visible = other == kind
	_trick_left = TRICK_SECONDS
	say(tr("MAGICIAN_TRICK_" + kind) % traits.name)


## The trick showing now, or "".
func showing() -> String:
	for kind in TRICKS:
		if part(kind).visible:
			return kind
	return ""


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	if _trick_left > 0.0:
		_trick_left -= delta
		if _trick_left <= 0.0:
			for kind in TRICKS:
				part(kind).visible = false
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## A part of his model by name (hat, hair, beard, glasses, teeth, legs, gloves, wand, dove, hanky, coin).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
