class_name LaundryMachine
extends StaticBody3D

## A washer (or a dryer) of the prison's laundry (carcel-lavanderia.md, step 5), against the east wall with its round
## glass door toward the room. An inmate can squeeze in to wait for the next trip (LaundryPlan puts them in): while
## inside, the machine shakes and every AY_EVERY seconds they moan ("¡Ay, ay, ay!"). E opens the door: whoever was in
## falls out dizzy (`opened`, with someone), else it's just laundry going round. Its origin is on the ground in its
## middle. Online the host decides who's in. Every number here is (propuesta).

signal opened(machine: LaundryMachine, had_someone: bool)

const SIZE := Vector3(0.7, 0.85, 0.7)
const WHITE := Color(0.92, 0.93, 0.95)
const GLASS := Color(0.35, 0.45, 0.55)
const AY_EVERY := Vector2(6.0, 10.0)
const SAY_TIME := 2.0
## How hard it shakes with someone inside, and how long the door stays open.
const SHAKE := 0.04
const SHAKE_TIME := 0.07
const OPEN_TIME := 1.2

var dryer := false
## Someone squeezed in.
var occupied := false
## A guest's copy (step 7): the host decides.
var follower := false
var _body: Node3D
var _door: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _ay_left := 0.0
var _shake: Tween
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("laundry_machines")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_body = Node3D.new()
	_body.name = "Body"
	add_child(_body)
	_body.add_child(CopTool.piece(CopTool.box(SIZE), WHITE.darkened(0.15) if dryer else WHITE, Vector3(0, SIZE.y / 2, 0)))
	_body.add_child(CopTool.piece(CopTool.box(Vector3(0.12, 0.06, SIZE.z - 0.1)), PrisonLevel.BARS,
		Vector3(-SIZE.x / 2 + 0.05, SIZE.y - 0.03, 0)))
	# The round door, hinged on its +Z side so it swings out toward the room.
	_door = Node3D.new()
	_door.name = "Door"
	_door.position = Vector3(-SIZE.x / 2 - 0.02, SIZE.y * 0.5, 0.22)
	_body.add_child(_door)
	_door.add_child(CopTool.piece(CopTool.cylinder(0.22, 0.04), GLASS, Vector3(0, 0, -0.22), Vector3(0, 0, PI / 2)))
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, SIZE.y + 0.5, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.hide()
	add_child(_bubble)
	_rng.seed = hash([name, position])


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_OPEN_MACHINE"


## E: the door swings open (and shuts again); whoever was in falls out.
func use(cop: Cop) -> void:
	var swing := create_tween()
	swing.tween_property(_door, "rotation:y", PI / 2, 0.25)
	swing.tween_interval(OPEN_TIME)
	swing.tween_property(_door, "rotation:y", 0.0, 0.25)
	if follower:
		return
	var had := occupied
	if occupied:
		set_occupied(false)
	else:
		cop.show_hint("HINT_MACHINE_EMPTY")
	opened.emit(self, had)


## Someone squeezes in (or gets out): it starts (or stops) shaking.
func set_occupied(on: bool) -> void:
	occupied = on
	if _shake:
		_shake.kill()
		_shake = null
	_body.rotation = Vector3.ZERO
	if on:
		_ay_left = _rng.randf_range(AY_EVERY.x, AY_EVERY.y)
		_shake = create_tween().set_loops()
		_shake.tween_property(_body, "rotation:z", SHAKE, SHAKE_TIME)
		_shake.tween_property(_body, "rotation:z", -SHAKE, SHAKE_TIME)


func say(key: String, seconds := SAY_TIME) -> void:
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
	if not occupied:
		return
	_ay_left -= delta
	if _ay_left <= 0.0:
		_ay_left = _rng.randf_range(AY_EVERY.x, AY_EVERY.y)
		say("MACHINE_AY")
