class_name MarketVendor
extends StaticBody3D

## A vendor behind a market stall's counter (politico-mercado.md, step 1): the puestero in an apron of their stall's
## color. E on them: they praise what they sell. Cuffed, they complain. Later steps make one of them the spiteful one.

const MODEL := preload("res://assets/models/npc_puestero.glb")
const SAY_TIME := 4.0

## What the stall sells (MarketLevel.KINDS).
var kind := "fruit"
var apron := Color(0.25, 0.55, 0.35)
var _bubble: Label3D
var _bubble_left := 0.0
var _cuffed_left := 0.0


func _ready() -> void:
	add_to_group("market_vendors")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.name = "Model"
	# The models face +Z; the vendor faces -Z like everyone else.
	model.rotation.y = PI
	add_child(model)
	var material := StandardMaterial3D.new()
	material.albedo_color = apron
	for mesh in model.find_child("apron", true, false).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_VENDOR"


func use(_cop: Cop) -> void:
	say("VENDOR_%s" % kind.to_upper())


## The handcuffs: stays behind the counter and complains.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	say("VENDOR_CUFFED")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
