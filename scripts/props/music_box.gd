class_name MusicBox
extends StaticBody3D

## The golden music box on Señora Ofelia's piano (escena-gato.md, "La Duquesa y las otras cuatro gatas"). E winds it up
## and it plays for a while; Duquesa, and only she, purrs near it. Every number here is (propuesta).

const PLAY_SECONDS := 12.0
const GOLD := Color(0.95, 0.75, 0.25)

var _left := 0.0
var _notes: Label3D


func _ready() -> void:
	add_to_group("music_boxes")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.3, 0.2, 0.24)
	shape.shape = box
	shape.position.y = 0.08
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = Vector3(0.25, 0.16, 0.18)
	mesh.mesh = cube
	mesh.position.y = 0.08
	var material := StandardMaterial3D.new()
	material.albedo_color = GOLD
	material.metallic = 0.6
	mesh.material_override = material
	add_child(mesh)
	_notes = MarketShopper.make_bubble()
	_notes.position.y = 0.45
	_notes.text = "MUSIC_BOX_NOTES"
	_notes.hide()
	add_child(_notes)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_MUSIC_BOX"


func use(_cop: Cop) -> void:
	_left = PLAY_SECONDS
	_notes.show()


func playing() -> bool:
	return _left > 0.0


func _physics_process(delta: float) -> void:
	if _left <= 0.0:
		return
	_left -= delta
	if _left <= 0.0:
		_notes.hide()
