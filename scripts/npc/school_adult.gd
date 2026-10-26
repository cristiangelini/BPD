class_name SchoolAdult
extends StaticBody3D

## A grown-up of the Los Girasoles school (politico-escuela.md, step 2, decision 210): Señorita Rosa, the teacher, by
## her desk, or Don Tito, the janitor, with his broom. E on them: one of their lines, a different one each time. Every
## number here is (propuesta).

const MODELS := {
	"maestra": preload("res://assets/models/npc_maestra.glb"),
	"conserje": preload("res://assets/models/npc_conserje.glb"),
}
## Lines each: TEACHER_0.. and JANITOR_0..
const LINES := 4
const SAY_TIME := 4.0

@export var look := "maestra"
var next_line := 0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("school_adults")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODELS[look].instantiate()
	model.name = "Model"
	model.rotation.y = PI
	add_child(model)
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)


func is_janitor() -> bool:
	return look == "conserje"


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_JANITOR" if is_janitor() else "PROMPT_TALK_TEACHER"


func use(_cop: Cop) -> void:
	say("%s_%d" % ["JANITOR" if is_janitor() else "TEACHER", next_line % LINES])
	next_line += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
