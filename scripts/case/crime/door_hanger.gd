class_name DoorHanger
extends StaticBody3D

## The card on the suite's door handle (escena-hotel.md, "Las pistas"): one side says "Limpiar, por favor" and the other
## "No molestar". E turns it round. With "No molestar" out, doña Escoba doesn't go in.

const CLEAN := Color(0.45, 0.75, 0.45)
const KEEP_OUT := Color(0.85, 0.25, 0.2)

var hung := false
var _card: MeshInstance3D
var _label: Label3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.12, 0.44, 0.26)
	shape.shape = box
	add_child(shape)
	PlaceBuilder.new(self).mesh_box(Vector3.ZERO, Vector3(0.01, 0.4, 0.2), CLEAN)
	_card = get_child(get_child_count() - 1) as MeshInstance3D
	_label = Label3D.new()
	_label.name = "Card"
	_label.position = Vector3(0.01, 0, 0)
	_label.rotation.y = PI / 2
	_label.pixel_size = 0.0015
	_label.font_size = 22
	_label.width = 125.0
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_label)
	_show()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_DND_TAKE" if hung else "PROMPT_DND_HANG"


func use(cop: Cop) -> void:
	hung = not hung
	_show()
	cop.show_hint("HINT_DND_HUNG" if hung else "HINT_DND_TAKEN")


func _show() -> void:
	_label.text = "SIGN_DND" if hung else "SIGN_CLEAN"
	_card.material_override = PlaceBuilder.new(self).material(KEEP_OUT if hung else CLEAN)
