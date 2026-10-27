class_name Lucho
extends AnimatableBody3D

## Lucho, the delivery boy (docs/diseno/allanamiento-heladeria.md, "Lucho"), the shop's gossip: every VISIT_EVERY
## seconds he rides up the sidewalk to the door on his bike, waits WAIT seconds for an order and rides off. Without a
## cone he's in a hurry; a cop who gives him one (E with a cone in hand) hears where he saw doña Nieve put something away
## (`clue`, set by the story). Once per cop. The shop sets `door` and `away`, in its space. Every number here is
## (propuesta).

## A cop gave him a cone and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_lucho.glb")
const BIKE := preload("res://assets/models/delivery_bike.glb")
const VISIT_EVERY := 45.0
const WAIT := 12.0
const RIDE_SPEED := 4.0
const SIZE := Vector3(0.7, 1.7, 1.6)

## The checklist line for what he saw, and the longer thing he tells (both translated, set by the story).
var clue := ""
var clue_speech := ""
## Where he stops by the door and where he comes from and goes back to, in the parent's space.
var door := Vector3.ZERO
var away := Vector3.ZERO
## "away", "coming", "waiting" or "leaving".
var state := "away"
## Seconds until his next visit, or left of his wait at the door.
var timer := VISIT_EVERY
## The cops who already gave him a cone, and the cones he got.
var givers := {}
var cones := 0
var has_told := false
var _bubble: Label3D
var _shape: CollisionShape3D


func _ready() -> void:
	sync_to_physics = false
	collision_layer = 1
	collision_mask = 0
	_shape = CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	_shape.shape = box
	_shape.position.y = SIZE.y / 2
	add_child(_shape)
	var bike: Node3D = BIKE.instantiate()
	add_child(bike)
	var rider: Node3D = MODEL.instantiate()
	rider.position = Vector3(0, 0.3, -0.35)
	rider.scale = Vector3.ONE * 0.85
	add_child(rider)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 34
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	position = away
	_show(false)


func prompt_key(cop: Cop) -> String:
	if state != "waiting":
		return ""
	return "PROMPT_GIVE_CONE" if cop.get_node("Grabber").held is IceCone else "PROMPT_TALK_LUCHO"


## E on him while he waits: a cone buys what he saw, once per cop; without one he's in a hurry.
func use(cop: Cop) -> void:
	if state != "waiting":
		return
	var grabber: Grabber = cop.get_node("Grabber")
	var held := grabber.held
	if not held is IceCone:
		_say("LUCHO_BUSY", 3.0)
		return
	grabber.release()
	held.queue_free()
	SchoolPupil.tell_hands(cop)
	cones += 1
	if givers.has(cop):
		_say("LUCHO_AGAIN", 4.0)
		return
	givers[cop] = true
	if clue_speech == "":
		_say("LUCHO_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


## He rides up now, if he's away.
func visit_now() -> void:
	if state != "away":
		return
	state = "coming"
	position = away
	_face(door)
	_show(true)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	match state:
		"away":
			timer -= delta
			if timer <= 0.0:
				visit_now()
		"coming":
			if _ride(door, delta):
				state = "waiting"
				timer = WAIT
				_say("LUCHO_HELLO", 3.0)
		"waiting":
			timer -= delta
			if timer <= 0.0:
				state = "leaving"
				_face(away)
		"leaving":
			if _ride(away, delta):
				state = "away"
				timer = VISIT_EVERY
				_show(false)


## A step toward `to`; true once there.
func _ride(to: Vector3, delta: float) -> bool:
	var left := to - position
	if left.length() <= RIDE_SPEED * delta:
		position = to
		return true
	position += left.normalized() * RIDE_SPEED * delta
	return false


func _face(at: Vector3) -> void:
	var to := at - position
	to.y = 0.0
	if to.length() > 0.1:
		rotation.y = atan2(to.x, to.z)


func _show(on: bool) -> void:
	visible = on
	_shape.disabled = not on


func _say(key: String, seconds := 3.0) -> void:
	_bubble.text = key
	_bubble.show()
	var said_now := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said_now:
			_bubble.hide())
