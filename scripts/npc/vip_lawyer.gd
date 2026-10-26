class_name VipLawyer
extends Node3D

## Rulo Brillantina's lawyer (carcel-vip.md, step 4): called when his mood hits 0, he comes in through the gate with his
## briefcase, walks through the canteen and the block to Rulo's bars, talks with him TALK seconds (and to the cops,
## about the papers) and leaves the way he came. Every number here is (propuesta).

signal arrived
signal gone

const MODEL := preload("res://assets/models/npc_abogado.glb")
const SPEED := 1.6
const TALK := 30.0
const LINE_EVERY := 7.0
const LINES: Array[String] = ["VIP_LAWYER_TALK_1", "VIP_LAWYER_TALK_2", "VIP_LAWYER_TALK_3", "VIP_LAWYER_TALK_4"]

## The way in, in the prison's space; out is the same, backwards.
var path: Array[Vector3] = []
var talking := false
var talk_left := 0.0
var _bubble: Label3D
var _line := 0
var _line_left := 0.0
var _walk: Tween


func _ready() -> void:
	add_to_group("vip_lawyers")
	add_child(MODEL.instantiate())
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


## In through the gate to the bars.
func come() -> void:
	position = path[0]
	say("VIP_LAWYER_ARRIVE")
	_walk_along(path, _on_arrived)


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _walk_along(points: Array[Vector3], then: Callable) -> void:
	_walk = create_tween()
	var at := position
	for point in points.slice(1):
		var ahead := Vector3(point.x - at.x, 0, point.z - at.z)
		if ahead.length() > 0.01:
			_walk.tween_callback(func() -> void: basis = Basis.looking_at(ahead, Vector3.UP, true))
		_walk.tween_property(self, "position", point, at.distance_to(point) / SPEED)
		at = point
	_walk.tween_callback(then)


func _on_arrived() -> void:
	talking = true
	talk_left = TALK
	_line_left = 0.0
	arrived.emit()


func _process(delta: float) -> void:
	if not talking:
		return
	talk_left -= delta
	_line_left -= delta
	if _line_left <= 0.0:
		_line_left = LINE_EVERY
		say(LINES[_line % LINES.size()])
		_line += 1
	if talk_left <= 0.0:
		leave()


## Done talking: back out the way he came.
func leave() -> void:
	talking = false
	say("VIP_LAWYER_BYE")
	var back := path.duplicate()
	back.reverse()
	_walk_along(back, _on_out)


func _on_out() -> void:
	gone.emit()
	queue_free()
