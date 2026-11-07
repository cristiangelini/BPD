class_name WeddingPerson
extends StaticBody3D

## Someone at Rosa and Tito's wedding (escena-boda.md): a model, a body to bump into and a bubble. E on them says one
## of their lines (line_key with the number), a different one each time. Rosa, the DJ, grandma Chola and the guests
## are just this for now; the tuxedos (TuxedoGuest) add their traits. Every number here is (propuesta).

var model: PackedScene
## The prompt's key and the lines' key, which gets the line's number at the end (WEDDING_DJ_LINE_0, ...).
var prompt := "PROMPT_WEDDING_TALK"
var line_key := "WEDDING_GUEST_LINE_"
var lines := 1
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("wedding_people")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = model.instantiate()
	add_child(_model)
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
	return prompt


func use(_cop: Cop) -> void:
	talk()


## Says the next of their lines.
func talk() -> void:
	say(line_key + str(_lines_said % lines))
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


## A part of the model by name.
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
