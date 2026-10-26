class_name BidSeat
extends StaticBody3D

## A chair of the auction hall (infiltracion-subasta.md, step 3, decision 177): gilded, red velvet, facing the podium,
## with its bidding paddle and its number. E on it raises the paddle: on the host it's `raised` (step 4 makes it a
## bid). Any raise, a cop's or the buyer sitting in it, shows the paddle up over the chair for RAISE_TIME seconds.
## Online the host tells the guests who raised it (step 6). Every number here is (propuesta).

signal raised(cop: Cop, seat: BidSeat)

const MODEL := preload("res://assets/models/auction_chair.glb")
const PADDLE := preload("res://assets/models/auction_paddle.glb")
const SEAT := 0.45
const RAISE_TIME := 1.5
## The paddle up, over the chair.
const PADDLE_UP := Vector3(0.3, 1.5, 0.0)

## The chair's number, on its paddle (from 1).
var number := 1
var _paddle: Node3D
var _up_left := 0.0


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, SEAT, 0.5)
	shape.shape = box
	shape.position.y = SEAT / 2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.rotation.y = PI
	add_child(model)
	_paddle = PADDLE.instantiate()
	_paddle.name = "Paddle"
	_paddle.position = PADDLE_UP
	add_child(_paddle)
	var label := Label3D.new()
	label.text = str(number)
	label.font_size = 48
	label.pixel_size = 0.004
	label.modulate = Color(0.1, 0.1, 0.12)
	label.outline_size = 0
	label.position = Vector3(0, 0.38, 0.012)
	_paddle.add_child(label)
	var back := label.duplicate() as Label3D
	back.position.z = -0.012
	back.rotation.y = PI
	_paddle.add_child(back)
	_paddle.hide()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_AUCTION_BID"


## E: on the host, `raised`.
func use(cop: Cop) -> void:
	if multiplayer.is_server():
		raised.emit(cop, self)


## The paddle goes up for RAISE_TIME seconds.
func raise() -> void:
	_up_left = RAISE_TIME
	_paddle.show()


func is_raised() -> bool:
	return _paddle.visible


func _process(delta: float) -> void:
	if _up_left > 0.0:
		_up_left -= delta
		if _up_left <= 0.0:
			_paddle.hide()
