class_name InterrogationSuspect
extends StaticBody3D

## The suspect, cuffed to the steel table of the interrogation room (interrogatorio.md). E on him with a box of
## donuts in hand gives him one; without one, the cop tells him to calm down. What he says shows over his head.

## Which of the suspects he is (InterrogationCase.SUSPECTS): it picks his model.
var kind := "talker"
## How high over him his lines show (the foreigner's translator talks higher, so the two don't overlap).
var bubble_height := 1.9
## Seconds a line stays over his head.
const LINE_SECONDS := 3.5
## The dangerous one loose runs this fast (m/s), half as fast with a cop holding on (propuesta): faster than a walk,
## slower than a run.
const RUN_SPEED := 4.5
const HELD_FACTOR := 0.5

## Loose and running round the wing (InterrogationWing.RUN_ROUTE), and whether a cop is holding on to him.
var running := false
var slowed := false
var _next := 0

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
	add_child((load(InterrogationCase.SUSPECT_MODELS[kind]) as PackedScene).instantiate())
	_bubble = Label3D.new()
	# Online his lines go to the guests by this name (NpcSync).
	_bubble.name = "Bubble"
	_bubble.position.y = bubble_height
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Over the hanging lamp, which hangs right between the cops and his head.
	_bubble.no_depth_test = true
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	var case := InterrogationCase.active(get_tree(), self)
	if not case or not case.is_on():
		return ""
	if case.loose:
		return "PROMPT_GRAB_SUSPECT"
	return InterrogationCase.ACTIONS["give_donut" if _donuts(cop) else "calm"].prompt


func use(cop: Cop) -> void:
	var case := InterrogationCase.active(get_tree(), self)
	if not case:
		return
	if case.loose:
		case.grab_loose(cop)
		return
	var box := _donuts(cop)
	if box:
		if case.is_on() and box.eat_one():
			case.act("give_donut", cop)
	else:
		case.act("calm", cop)


## He slipped the cuffs: off he runs.
func run() -> void:
	running = true
	slowed = false
	_next = 0


## Caught (or the lawyer came): back in his chair, cuffed again.
func sit() -> void:
	running = false
	slowed = false
	position = InterrogationWing.SUSPECT_AT
	rotation = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if not running:
		return
	var route := InterrogationWing.RUN_ROUTE
	var to := route[_next] - position
	to.y = 0.0
	var step := RUN_SPEED * (HELD_FACTOR if slowed else 1.0) * delta
	if to.length() <= step:
		position = route[_next]
		_next = _next + 1 if _next + 1 < route.size() else InterrogationWing.RUN_LOOP_FROM
		return
	position += to.normalized() * step
	rotation.y = atan2(to.x, to.z)


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
