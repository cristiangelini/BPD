class_name Suitcase
extends Grabbable

## One of Lustre's identical suitcases (politico-aeropuerto.md, step 2, decision 231): black with a yellow ribbon, KG
## kilos, its number on the tag. Grabbed like anything; E opens it (and closes it): his clothes, a tie and a teddy bear.
## On the counter's scale it shows its weight. Step 3 says what the odd one has inside. Every number here is
## (propuesta).

signal opened_now(suitcase: Suitcase)

const CLOSED := preload("res://assets/models/suitcase.glb")
const OPEN := preload("res://assets/models/suitcase_open.glb")
const SIZE := Vector3(0.7, 0.25, 0.5)
const KG := 20.0

## The number on its tag: 1 to 12 for his, 13 for the one slipped in (step 3).
var number := 1
var opened := false
var _model: Node3D
var _tag: Label3D


func _ready() -> void:
	add_to_group("suitcases")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	_tag = Label3D.new()
	_tag.name = "Tag"
	_tag.text = str(number)
	_tag.font_size = 32
	_tag.pixel_size = 0.002
	_tag.modulate = Color(0.1, 0.1, 0.12)
	_tag.outline_size = 0
	_tag.position = Vector3(0.22, 0.137, 0.12)
	_tag.rotation.x = -PI / 2
	add_child(_tag)
	_show_model()


func _show_model() -> void:
	if _model:
		_model.free()
	_model = (OPEN if opened else CLOSED).instantiate()
	_model.name = "Model"
	add_child(_model)
	_tag.visible = not opened


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CLOSE_SUITCASE" if opened else "PROMPT_OPEN_SUITCASE"


func use(_cop: Cop) -> void:
	set_opened(not opened)


func set_opened(on: bool) -> void:
	if on == opened:
		return
	opened = on
	_show_model()
	if opened:
		opened_now.emit(self)


func weight() -> float:
	return mass
