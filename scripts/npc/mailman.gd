class_name Mailman
extends Node3D

## Don Sobre, the mailman of the wrong house (docs/diseno/casa-equivocada.md, step 4): every RIDE_EVERY seconds he
## rides his bike down the sidewalk in front of the two houses, one way and then the other, stopping STOP seconds at
## each mailbox. E on him stops him: he says who lives where (`clue`, set by the place), the door clue that never lies,
## and it goes to the checklist the first time. Shown his stolen letters (step 7), he tells where the rare stamps are
## instead. It runs on the host. Every number here is (propuesta).

## He told the clue for the first time: the checklist line, already translated.
signal told(text: String)

enum State { WAITING, RIDING, STOPPED, TALKING }

const MODEL := preload("res://assets/models/npc_cartero.glb")
const BIKE := preload("res://assets/models/delivery_bike.glb")
const RIDE_EVERY := 60.0
const FIRST_RIDE := 5.0
const SPEED := 3.5
const STOP := 4.0
const TALK := 5.0
## Closer than this, he recognizes `bag` (the stolen letters story).
const BAG_NEAR := 2.5

var state := State.WAITING
## The checklist line he says, already translated.
var clue := ""
var was_told := false
## His stolen letters, if that's the story: shown to him (near him when a cop talks), he says `bag_line` instead.
var bag: Grabbable
var bag_line := ""
var bag_told := false
## The sidewalk he rides along (z) between two ends (x), and the mailboxes he stops at (x).
var route_z := 0.0
var ends := Vector2(-20.0, 20.0)
var stops: Array[float] = []
## +1 rides toward ends.y, -1 toward ends.x.
var heading := 1.0
var _wait_left := FIRST_RIDE
var _stop_left := 0.0
var _next_stop := 0
var _bubble: Label3D


func _ready() -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	body.add_child(shape)
	var bike: Node3D = BIKE.instantiate()
	# The bike is the pastry cook's: the mail goes in his bag, not with the bread.
	var basket := bike.find_child("basket*", true, false)
	if basket:
		(basket as Node3D).hide()
	body.add_child(bike)
	var rider: Node3D = MODEL.instantiate()
	rider.position = Vector3(0, 0.3, -0.35)
	body.add_child(rider)
	add_child(body)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.3, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	position = Vector3(ends.x if heading > 0 else ends.y, position.y, route_z)
	_face()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_MAILMAN"


## E: he brakes and tells who lives where.
func use(_cop: Cop) -> void:
	if state != State.WAITING:
		state = State.TALKING
	_stop_left = TALK
	if sees_bag():
		_say(bag_line, TALK)
		if not bag_told:
			bag_told = true
			told.emit(bag_line)
		return
	_say(clue, TALK)
	if not was_told:
		was_told = true
		told.emit(clue)


func sees_bag() -> bool:
	return bag != null and is_instance_valid(bag) and bag.global_position.distance_to(global_position) < BAG_NEAR


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	match state:
		State.WAITING:
			_wait_left -= delta
			if _wait_left <= 0.0:
				_start_ride()
		State.STOPPED, State.TALKING:
			_stop_left -= delta
			if _stop_left <= 0.0:
				state = State.RIDING
		State.RIDING:
			_ride(delta)


func _start_ride() -> void:
	state = State.RIDING
	_wait_left = RIDE_EVERY
	_next_stop = 0
	_face()


## The mailboxes left on this ride, in the order he meets them.
func _stops_ahead() -> Array[float]:
	var ahead := stops.duplicate()
	ahead.sort()
	if heading < 0:
		ahead.reverse()
	return ahead


func _ride(delta: float) -> void:
	_wait_left -= delta
	var ahead := _stops_ahead()
	var goal := ends.y if heading > 0 else ends.x
	var stopping := _next_stop < ahead.size()
	if stopping:
		goal = ahead[_next_stop]
	var step := SPEED * delta
	if absf(goal - position.x) <= step:
		position.x = goal
		if stopping:
			_next_stop += 1
			state = State.STOPPED
			_stop_left = STOP
		else:
			# At the end of the sidewalk: he waits there and comes back the other way next time.
			heading = -heading
			state = State.WAITING
			_wait_left = maxf(_wait_left, 0.0)
		return
	position.x += signf(goal - position.x) * step


func _face() -> void:
	rotation.y = PI / 2 if heading > 0 else -PI / 2


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _say(text: String, seconds: float) -> void:
	_bubble.text = text
	_bubble.show()
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == text:
			_bubble.hide())
