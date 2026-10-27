class_name IceVisitor
extends Node3D

## Someone who steps in through the ice cream shop's door, says one line and leaves (allanamiento-heladeria.md, "Qué
## cambia" in some stories): the customer asking whether "the cold" arrived, the one who says it isn't a kilo, the kid
## with no prize. Only a look and a line: cops walk through. Every number here is (propuesta).

const STAY := 6.0

## Times they came in.
var visits := 0
var _bubble: Label3D
var _left := 0.0


func _init(model: PackedScene) -> void:
	add_child(model.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 34
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_bubble)
	visible = false


## They come in and say `key` for STAY seconds.
func come(key: String) -> void:
	visits += 1
	_bubble.text = key
	_left = STAY
	visible = true


## Online: whether they're in, so a guest's copy comes and goes with the host's.
func net_state() -> Variant:
	return visible


func apply_net_state(value: Variant) -> void:
	visible = value


func said() -> String:
	return _bubble.text if visible else ""


func _process(delta: float) -> void:
	if not visible:
		return
	_left -= delta
	if _left <= 0.0:
		visible = false
