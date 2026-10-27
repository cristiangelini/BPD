class_name LibraryReader
extends StaticBody3D

## One of the six readers of the club (escena-biblioteca.md, "Los seis lectores en pijama"): the same striped pajamas
## with a mouse, nightcap, sleep mask and slippers as the other five, a book open in their hands. Under the nightcap,
## their own hair (tinted); their glasses, if they wear them; their slippers (stretched to their size) and their teeth
## (shown when they bite). The gold dust on their hands only shows under the flashlight (step 3). E on them, they
## whisper what they are reading. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_lector.glb")
## Slipper sizes stretch the slippers from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 4

## ReaderTraits.draw: name, hair, glasses, shoe, teeth, dust, genre.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("library_readers")
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
	_tint("hair", ReaderTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	for side in ["left", "right"]:
		part("dust_%s" % side).visible = false
	var size := inverse_lerp(ReaderTraits.SHOE_MIN, ReaderTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_READER_TALK"


## E on them: a whisper about their book (a different line each time, in an order that starts at their number), which
## always says what kind of book it is.
func use(_cop: Cop) -> void:
	say(tr("READER_LINE_%d" % ((index + _lines_said) % LINES)) % genre_name())
	_lines_said += 1


## The kind of book they read, translated ("piratas").
func genre_name() -> String:
	return tr("GENRE_%s" % traits.genre)


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


## A part of their model by name (nightcap, hair, glasses, teeth, legs, mask, book, dust_left, dust_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
