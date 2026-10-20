class_name InterrogationSuspect
extends StaticBody3D

## The suspect, cuffed to the steel table of the interrogation room (interrogatorio.md). E on him with a box of
## donuts in hand gives him one; without one, the cop tells him to calm down. What he says shows over his head.

const MODEL := preload("res://assets/models/npc_sospechoso.glb")
## Seconds a line stays over his head.
const LINE_SECONDS := 3.5

var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.position.y = 1.9
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	var case := InterrogationCase.active(get_tree())
	if not case or not case.is_on():
		return ""
	return InterrogationCase.ACTIONS["give_donut" if _donuts(cop) else "calm"].prompt


func use(cop: Cop) -> void:
	var case := InterrogationCase.active(get_tree())
	if not case:
		return
	var box := _donuts(cop)
	if box:
		if case.is_on() and box.eat_one():
			case.act("give_donut", cop)
	else:
		case.act("calm", cop)


## The box of donuts in the cop's hands, if it still has one.
func _donuts(cop: Cop) -> DonutBox:
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox and (held as DonutBox).donuts > 0 else null


## Shows a line (tr() key or text) over his head for a few seconds.
func say(text: String, seconds := LINE_SECONDS) -> void:
	_bubble.text = text
	_bubble.show()
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == text:
			_bubble.hide())


func saying() -> String:
	return _bubble.text if _bubble.visible else ""
