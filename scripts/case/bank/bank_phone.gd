class_name BankPhone
extends StaticBody3D

## The phone on the patrol car's side to talk to El Oso (robo-banco.md, step 5, decision 102). E on it calls the
## bank: El Oso answers and asks for something absurd, a different one each call (REQUESTS, in an order the seed
## draws). E again within ASK_TIME promises it; if nobody does, he hangs up. A promise kept within PROMISE_TIME stops
## the drill for PAUSE seconds and he lets a hostage go; a promise not kept was a lie, and the drill hurries. The
## requests: a box of donuts at the bank's door (the armero sells them), singing him "happy birthday" on the phone
## (the voice or H, as with the jailbreak's guard) and taking the patrol car away to another block (only asked for
## while it's near the bank: called from afar, he asks for the next thing). While a promise
## is pending there's no other call. Online the host's phone decides and a guest's shows it (`follower`, BankCase's
## snapshot); a guest's E and singing reach the host's (ActionSync, VoiceChat). Every number here is (propuesta).

signal kept(request: String)
signal lied(request: String)

const REQUESTS: Array[String] = ["donuts", "birthday", "car_away"]
const ASK_TIME := 12.0
const PROMISE_TIME := 90.0
const PAUSE := 30.0
const LIE_HURRY := 30.0
## Donuts: a box this close to the outside of the entrance.
const DOOR_REACH := 2.5
## Birthday: this many seconds of singing within SING_REACH of the phone.
const SING_NEEDED := 4.0
const SING_REACH := 3.0
## The patrol car this far from the bank's entrance.
const CAR_AWAY := 40.0
const SAY_TIME := 6.0
## The grandpa Oso (robo-banco-abuelos.md, step 4) doesn't hear well: the first E on each request only gets a "What?",
## and asks in his own words.
const DEAF_LINES := 3

var bank: BankLevel
## Where the phone hangs on the car (the level sets it).
var car: PatrolCar
## What El Oso asks for now, and whether it was promised: "" when nobody's on the phone.
var request := ""
var promised := false
## Seconds left to promise (asking) or to keep the promise.
var left := 0.0
var sung := 0.0
## The grandpa Oso, who has to hear it twice; whether this request's first "yes" was already said.
var deaf := false
var said_once := false
## A guest's: only shows the host's (apply_net_state).
var follower := false
var _order: Array[String] = []
var _next := 0
var _bubble: Label3D
var _bubble_left := 0.0


func setup(bank_level: BankLevel, patrol_car: PatrolCar, case_seed: int) -> void:
	bank = bank_level
	car = patrol_car
	_order = REQUESTS.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["bank phone", case_seed])
	for i in range(_order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := _order[i]
		_order[i] = _order[j]
		_order[j] = swap


func _ready() -> void:
	add_to_group("bank_phone")
	collision_layer = 8
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.25, 0.3, 0.2)
	shape.shape = box
	add_child(shape)
	var handset := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = box.size
	handset.mesh = mesh
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.8, 0.12, 0.16)
	handset.material_override = red
	add_child(handset)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 0.6, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.modulate = Color(1, 0.85, 0.6)
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	if request == "":
		return "PROMPT_PHONE_CALL"
	if promised:
		return ""
	return "PROMPT_PHONE_LOUDER" if said_once else "PROMPT_PHONE_PROMISE"


## E: calls the bank, or promises what El Oso just asked for.
func use(_cop: Cop) -> void:
	if follower:
		return
	if request == "":
		request = _order[_next % _order.size()]
		_next += 1
		if request == "car_away" and car_away():
			request = _order[_next % _order.size()]
			_next += 1
		promised = false
		said_once = false
		left = ASK_TIME
		sung = 0.0
		say(("BEAR_GRANDPA_ASK_" if deaf else "BEAR_PHONE_ASK_") + request.to_upper())
	elif deaf and not said_once:
		said_once = true
		left = ASK_TIME
		say("BEAR_GRANDPA_WHAT_%d" % ((_next - 1) % DEAF_LINES + 1))
	elif not promised:
		promised = true
		left = PROMISE_TIME
		say("BEAR_PHONE_DEAL")


## VoiceChat: a cop is singing (every half second while they sing or hum with H).
func heard_singing(cop: Node3D) -> void:
	if not follower and request == "birthday" and promised and cop.global_position.distance_to(global_position) < SING_REACH:
		sung += VoiceChat.SING_EVERY


## Whether what was promised is done now.
func done() -> bool:
	match request:
		"donuts":
			var door := bank.global_transform * Vector3(BankLevel.ENTRANCE_X, 0, BankLevel.HALF_Z + 1.0)
			for box: Node3D in get_tree().get_nodes_in_group("donut_boxes"):
				if Vector2(box.global_position.x - door.x, box.global_position.z - door.z).length() < DOOR_REACH:
					return true
		"birthday":
			return sung >= SING_NEEDED
		"car_away":
			return car_away()
	return false


func car_away() -> bool:
	var door := bank.global_transform * Vector3(BankLevel.ENTRANCE_X, 0, BankLevel.HALF_Z)
	return car.global_position.distance_to(door) > CAR_AWAY


func _physics_process(delta: float) -> void:
	if request == "" or follower:
		return
	if promised and done():
		_keep()
		return
	left -= delta
	if left > 0.0:
		return
	if promised:
		say("BEAR_PHONE_LIED")
		bank.drill.hurry(LIE_HURRY)
		lied.emit(request)
	else:
		say("BEAR_PHONE_HANGUP")
	request = ""


func _keep() -> void:
	say("BEAR_PHONE_KEPT_" + request.to_upper())
	bank.drill.pause(PAUSE)
	bank.release_hostage()
	kept.emit(request)
	request = ""


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## What a guest's phone shows (BankCase.snapshot): what El Oso asks for, whether it was promised, the time left and
## his bubble, and whether the grandpa Oso already heard the first "yes".
func net_state() -> Array:
	return [request, promised, snappedf(left, 0.1), _bubble.text, _bubble.visible, said_once]


func apply_net_state(state: Array) -> void:
	request = state[0]
	promised = state[1]
	left = state[2]
	_bubble.text = state[3]
	_bubble.visible = state[4]
	if state.size() > 5:
		said_once = state[5]


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
