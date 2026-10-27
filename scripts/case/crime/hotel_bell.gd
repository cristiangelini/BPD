class_name HotelSceneBell
extends StaticBody3D

## The reception's bell (escena-hotel.md, "Las pistas"): it wakes don Bostezo, who says again who sleeps where. Rung
## more than three times in a row, he gets angry and answers nothing for 30 s. Every number here is (propuesta).

## Rings this close together count as in a row, in seconds.
const IN_A_ROW := 3.0
const TOO_MANY := 3
const ANGRY_SECONDS := 30.0

var concierge: HotelStaff
var _rings := 0
var _since := 999.0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.16, 0.08, 0.16)
	shape.shape = box
	shape.position.y = 0.04
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOTEL_BELL"


func use(_cop: Cop) -> void:
	_rings = _rings + 1 if _since <= IN_A_ROW else 1
	_since = 0.0
	if not concierge:
		return
	if _rings > TOO_MANY:
		concierge.get_angry(ANGRY_SECONDS)
	else:
		concierge.wake()


func _physics_process(delta: float) -> void:
	_since += delta
