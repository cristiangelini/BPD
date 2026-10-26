class_name BankClerk
extends Grabbable

## Don Plácido, the town bank's only clerk (robo-banco-pueblo.md, step 1, decision 127): asleep on his stool behind
## the wooden counter, slumped forward with his head on the counter, snoring ("Zzz..." over his head). He's the only
## one to get out of the bank, and he's carried asleep: he weighs KG, so one cop drags him and two carry him. He waits
## still on his stool (frozen) until a cop takes hold of him. The back door's key sticks out of his vest pocket.
## Every number here is (propuesta).

const KG := 70.0
const MODEL := preload("res://assets/models/npc_empleado.glb")
## His body, upright, seated on his stool; the model leans forward from it onto the counter.
const SIZE := Vector3(0.8, 1.2, 0.7)
const LEAN := 0.45
const SNORE_HEIGHT := 1.75
## How far the snore bobs (m) and how fast (radians a second).
const SNORE_BOB := 0.06
const SNORE_SPEED := 2.5

var asleep := true
var _model: Node3D
var _key: Node3D
var _bubble: Label3D
var _bob := 0.0


func _ready() -> void:
	add_to_group("bank_clerks")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_model = MODEL.instantiate()
	_model.rotation.x = LEAN
	add_child(_model)
	_key = _model.find_child("key", true, false) as Node3D
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.font_size = 48
	_bubble.pixel_size = 0.006
	_bubble.outline_size = 10
	_bubble.position.y = SNORE_HEIGHT
	_bubble.text = "CLERK_SNORE"
	add_child(_bubble)


## A cop takes hold of him: off his stool he goes, carried like anything heavy.
func hold(holder_id: int, point: Vector3) -> void:
	freeze = false
	super.hold(holder_id, point)


func has_key() -> bool:
	return _key != null and _key.visible


func _process(delta: float) -> void:
	_bubble.visible = asleep
	if asleep:
		_bob += delta * SNORE_SPEED
		_bubble.position.y = SNORE_HEIGHT + sin(_bob) * SNORE_BOB
