class_name OfficePerson
extends StaticBody3D

## Formularios Infinitos' people (escena-oficina.md, step 2): the six employees alike in the same grey suit, el señor
## Trámite the manager, stamping papers in his office, and Benja the intern, behind his pile of papers by the copier.
## E on any of them gets one of their lines, a different one each time. An employee walks to another desk when the
## desk-change bell rings (FormsOffice.ring_desk_bell): to the aisle between the rows, along it and to the new desk.
## What they do in the case (the coffee, the files, the witness) comes in steps 3 and 4. Every number here is
## (propuesta).

## Who they can be: their model and how many lines they have (OFFICE_<WHO>_LINE_<n>).
const WHO := {
	"employee": {"model": "res://assets/models/npc_oficinista.glb", "lines": 6},
	"manager": {"model": "res://assets/models/npc_senor_tramite.glb", "lines": 4},
	"intern": {"model": "res://assets/models/npc_pasante_benja.glb", "lines": 4},
}
## How fast an employee walks to his new desk, m/s.
const WALK_SPEED := 1.2

var who := "employee"
## An employee's place in the office's order.
var index := 0
## Where an employee is walking to, in the parent's space, in order; empty when he stands at his desk.
var path: Array[Vector3] = []
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("office_people")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = (load(WHO[who].model) as PackedScene).instantiate()
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
	return "PROMPT_OFFICE_" + who.to_upper()


## E on them: their next line.
func use(_cop: Cop) -> void:
	say(line_key(index + _lines_said))
	_lines_said += 1


## The key of their line number n (it goes round).
func line_key(n: int) -> String:
	return "OFFICE_%s_LINE_%d" % [who.to_upper(), n % int(WHO[who].lines)]


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


## Walks through these points, in the parent's space, facing where he goes.
func walk(points: Array[Vector3]) -> void:
	path = points


func walking() -> bool:
	return not path.is_empty()


## A part of their model by name (hair, glasses, teeth, briefcase; stamp; papers).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	if path.is_empty():
		return
	var to := path[0] - position
	to.y = 0.0
	var step := WALK_SPEED * delta
	if to.length() <= step:
		position = Vector3(path[0].x, position.y, path[0].z)
		path.remove_at(0)
		return
	position += to.normalized() * step
	rotation.y = atan2(to.x, to.z)
