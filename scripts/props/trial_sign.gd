class_name TrialSign
extends StaticBody3D

## One of the three answer signs on the witness stand's rail (docs/diseno/fuga-juicio.md, step 2): it shows answer
## `index` of the detail the judge is asking about (TrialAlibi.choices), and E on it, the witness on the stand answers
## that (TrialJudge.answer).

const SIZE := Vector3(0.42, 0.3, 0.03)

var index := 0
var judge: TrialJudge
var _label: Label3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var board := BoxMesh.new()
	board.size = SIZE
	mesh.mesh = board
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.92, 0.9, 0.82)
	mesh.material_override = white
	add_child(mesh)
	_label = Label3D.new()
	_label.position = Vector3(0, 0, SIZE.z / 2 + 0.005)
	_label.pixel_size = 0.0012
	_label.font_size = 30
	_label.outline_size = 0
	_label.modulate = Color(0.1, 0.1, 0.12)
	_label.width = 340.0
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_label)


## The text key it shows now ("" while the judge isn't asking).
func answer_key() -> String:
	if not judge or judge.asking() == "":
		return ""
	return TrialAlibi.choices(judge.alibi, judge.asking())[index]


func _process(_delta: float) -> void:
	_label.text = answer_key()


func prompt_key(cop: Cop) -> String:
	return "PROMPT_TRIAL_ANSWER" if answer_key() != "" and judge.is_witness(cop) else ""


func use(cop: Cop) -> void:
	if multiplayer.is_server() and prompt_key(cop) != "":
		judge.answer(cop, answer_key())
