class_name SchoolPupil
extends StaticBody3D

## A pupil of the Los Girasoles school (politico-escuela.md, step 2, decision 210): a child in a white smock with a
## backpack, sitting at a desk of the classroom, one of four looks. E on them: something a child says, a different line
## each time. Every number here is (propuesta).

const MODELS: Array[PackedScene] = [
	preload("res://assets/models/npc_alumno.glb"), preload("res://assets/models/npc_alumna.glb"),
	preload("res://assets/models/npc_alumno_b.glb"), preload("res://assets/models/npc_alumna_b.glb"),
]
## The pear body is a grown-up's: a child is this much of it (about 1 m).
const KID_SCALE := 0.62
const LINES := 8
const SAY_TIME := 4.0

## Which of the four looks (0 to 3) and which desk (0 to 19, row by row from the front).
@export var look := 0
var desk := 0
## Which line comes next (the school draws a different start for each).
var next_line := 0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("school_pupils")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.0
	shape.shape = capsule
	shape.position.y = 0.5
	add_child(shape)
	var model: Node3D = MODELS[look % MODELS.size()].instantiate()
	model.name = "Model"
	# The models face +Z; the pupil faces -Z like everyone else.
	model.rotation.y = PI
	model.scale = Vector3.ONE * KID_SCALE
	add_child(model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.3
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_PUPIL"


func use(_cop: Cop) -> void:
	say("PUPIL_%d" % (next_line % LINES))
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
