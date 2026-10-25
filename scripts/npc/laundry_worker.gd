class_name LaundryWorker
extends CharacterBody3D

## An inmate working in the prison's laundry (carcel-lavanderia.md, step 2): the riot's model in its orange jumpsuit,
## standing at a station (a washer, a dryer, the folding table, the clothesline) and leaning over it as it works, once
## LaundryPlan starts. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_preso.glb")
const SAY_TIME := 3.0
## Leaning over the work: this far, every WORK_EVERY seconds (each worker a little off the others).
const LEAN := 0.35
const WORK_EVERY := 1.6

var prison: PrisonLevel
## Their station (level space x, z) and where they face from it.
var station := Vector2.ZERO
var face := Vector2.ZERO
var working := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _work: Tween


func _ready() -> void:
	add_to_group("laundry_workers")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## Stands at their station, facing their work.
func place() -> void:
	global_position = prison.global_transform * Vector3(station.x, PrisonLevel.FLOOR_TOP, station.y)
	var toward := prison.global_transform * Vector3(face.x, PrisonLevel.FLOOR_TOP, face.y)
	# Their model faces +Z: turn so that's toward the work.
	look_at(global_position - (toward - global_position), Vector3.UP)


## Gets to work: leaning over it and back, over and over, `offset` seconds after the others.
func work(offset: float) -> void:
	if working:
		return
	working = true
	_work = create_tween().set_loops()
	_work.tween_interval(offset)
	_work.tween_property(_model, "rotation:x", LEAN, WORK_EVERY / 2).set_trans(Tween.TRANS_SINE)
	_work.tween_property(_model, "rotation:x", 0.0, WORK_EVERY / 2).set_trans(Tween.TRANS_SINE)


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
