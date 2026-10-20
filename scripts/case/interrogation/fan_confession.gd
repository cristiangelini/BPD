class_name FanConfession
extends StaticBody3D

## One of the police fan's three confessions, held up on the interrogation table (interrogatorio.md, suspect 9): E on
## the true one solves the case, a wrong one brings his lawyer closer (InterrogationCase.pick_confession).

const SIZE := Vector2(0.4, 0.28)

## The crime it confesses (InterrogationCase.CRIMES).
var crime := ""


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SIZE.x, SIZE.y, 0.02)
	shape.shape = box
	add_child(shape)
	var paper := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = SIZE
	paper.mesh = quad
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.97, 0.96, 0.9)
	# Readable from the cops' side, with the lamp behind it.
	white.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	paper.material_override = white
	add_child(paper)
	var text := Label3D.new()
	text.text = "CONFESS_" + crime
	text.position.z = 0.002
	text.pixel_size = 0.0009
	text.font_size = 32
	text.modulate = Color(0.15, 0.15, 0.2)
	text.outline_size = 0
	text.width = 400.0
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(text)


func prompt_key(_cop: Cop) -> String:
	var case := InterrogationCase.active(get_tree(), self)
	return "PROMPT_PICK_CONFESSION" if case and case.is_on() else ""


func use(cop: Cop) -> void:
	var case := InterrogationCase.active(get_tree(), self)
	if case:
		case.pick_confession(self, cop)
