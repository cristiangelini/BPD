class_name LivingStatue
extends StaticBody3D

## The living statue on the museum's steps (escena-museo.md, "Las pistas"): a street artist painted gold who never
## moves, with his hat on the ground for coins. Without a coin, E on him gets nothing but a stare; the witness and the
## coin come with the case (step 4). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_estatua.glb")

var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("living_statue")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.3, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 800.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_STATUE"


func use(_cop: Cop) -> void:
	say("STATUE_STILL")


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
