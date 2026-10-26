class_name SchoolPupil
extends StaticBody3D

## A pupil of the Los Girasoles school (politico-escuela.md, step 2, decision 210): a child in a white smock with a
## backpack, sitting at a desk of the classroom, one of four looks. E on them: something a child says, a different line
## each time. Step 3: they walk out to the playground for recess, back to their desk and out front for the photo
## (`walk`, along the corners the school gives). Every number here is (propuesta).

const MODELS: Array[PackedScene] = [
	preload("res://assets/models/npc_alumno.glb"), preload("res://assets/models/npc_alumna.glb"),
	preload("res://assets/models/npc_alumno_b.glb"), preload("res://assets/models/npc_alumna_b.glb"),
]
## The pear body is a grown-up's: a child is this much of it (about 1 m).
const KID_SCALE := 0.62
const LINES := 8
const SAY_TIME := 4.0
const SPEED := 1.4
const ARRIVED := 0.1

## Which of the four looks (0 to 3) and which desk (0 to 19, row by row from the front).
@export var look := 0
var desk := 0
## Which line comes next (the school draws a different start for each).
var next_line := 0
## Where they're walking (world space, corner by corner), after `_wait_left` seconds, and which way to face at the end.
var _path: Array[Vector3] = []
var _wait_left := 0.0
var _face_at_end := Vector3.ZERO
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


## Walks through `points` (world space) after `delay` seconds and ends up looking along `facing` (or wherever the last
## stretch went, with none).
func walk(points: Array[Vector3], delay := 0.0, facing := Vector3.ZERO) -> void:
	_path = points.duplicate()
	_wait_left = delay
	_face_at_end = facing


func walking() -> bool:
	return not _path.is_empty()


func _physics_process(delta: float) -> void:
	if _path.is_empty():
		return
	if _wait_left > 0.0:
		_wait_left -= delta
		return
	var to := _path[0] - global_position
	to.y = 0.0
	var step := SPEED * delta
	if to.length() <= maxf(step, ARRIVED):
		global_position = Vector3(_path[0].x, global_position.y, _path[0].z)
		_path.remove_at(0)
		if _path.is_empty() and _face_at_end.length() > 0.01:
			look_at(global_position + _face_at_end, Vector3.UP)
		return
	look_at(global_position + to, Vector3.UP)
	global_position += to.normalized() * step


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
