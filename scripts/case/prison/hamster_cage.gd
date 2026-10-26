class_name HamsterCage
extends StaticBody3D

## The hamster's cage in one of the block's cells (carcel-tunel.md, step 4): a false lead. Its hamster scratches at the
## cage's floor, and a cop close by hears it just like the digging ("Rasc, rasc..."; TunnelPlan says when). E has a
## look: it's just a hamster. Its origin is on the floor in its middle. Every number here is (propuesta).

const SIZE := Vector3(0.45, 0.3, 0.3)
const WIRE := Color(0.75, 0.75, 0.78)
const FUR := Color(0.85, 0.65, 0.4)
const SHAVINGS := Color(0.9, 0.8, 0.55)

var cell := 0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("hamster_cages")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x, 0.04, SIZE.z)), SHAVINGS, Vector3(0, 0.02, 0)))
	for x: float in [-SIZE.x / 2, SIZE.x / 2]:
		for z: float in [-SIZE.z / 2, SIZE.z / 2]:
			add_child(CopTool.piece(CopTool.box(Vector3(0.015, SIZE.y, 0.015)), WIRE, Vector3(x, SIZE.y / 2, z)))
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x, 0.015, SIZE.z)), WIRE, Vector3(0, SIZE.y, 0)))
	var hamster := CopTool.piece(CopTool.box(Vector3(0.1, 0.07, 0.13)), FUR, Vector3(0.05, 0.075, 0))
	hamster.name = "Hamster"
	add_child(hamster)
	var scurry := create_tween().set_loops()
	scurry.tween_property(hamster, "position:x", -0.1, 0.6)
	scurry.tween_interval(0.8)
	scurry.tween_property(hamster, "position:x", 0.1, 0.5)
	scurry.tween_interval(1.1)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 0.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 32
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_HAMSTER"


func use(cop: Cop) -> void:
	cop.show_hint("HINT_HAMSTER")


func say(key: String, seconds := 1.5) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
