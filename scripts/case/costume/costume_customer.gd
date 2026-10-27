class_name CostumeCustomer
extends StaticBody3D

## A customer of the costume shop (allanamiento-disfraces.md, step 2). They look at the costumes until the shop gives
## them their turn, walk along the front aisle to a fitting room with a costume, stay inside about FITTING_TIME seconds
## asking how it looks, then walk back. They complain (5 to the complaint, at most once every COMPLAIN_EVERY seconds
## each) when a cop is inside the fitting room they go to, or a mannequin falls less than CRUSH_RANGE from them.
## E on one tells a line about the shop. Every number here is (propuesta).

## They complained loud enough for the owner to hear it (Don Fantoche adds it to the complaint, step 3).
signal complained(customer: CostumeCustomer)
## Their turn is over and they're back where they look at costumes.
signal turn_over(customer: CostumeCustomer)

const MODELS := {
	"cliente": preload("res://assets/models/npc_cliente.glb"),
	"clienta": preload("res://assets/models/npc_clienta.glb"),
	"vecina": preload("res://assets/models/npc_vecina.glb"),
	"invitado": preload("res://assets/models/npc_invitado.glb"),
}
const SCALE := 0.95
const FITTING_TIME := 15.0
const LINE_EVERY := 5.0
const COMPLAINT := 5.0
const COMPLAIN_EVERY := 10.0
const CRUSH_RANGE := 2.0
const SAY_TIME := 3.5
## Seconds for each stretch of the walk to the fitting room (and back).
const STRETCH := 1.5
const TRY_LINES := ["COSTUME_TRY_1", "COSTUME_TRY_2", "COSTUME_TRY_3", "COSTUME_TRY_4", "COSTUME_TRY_5"]
const TALK_LINES := ["COSTUME_CUSTOMER_TALK_1", "COSTUME_CUSTOMER_TALK_2", "COSTUME_CUSTOMER_TALK_3"]

@export var look := "cliente"
var shop: CostumeShop
## Where they look at costumes (shop space), whether it's their turn (walking or inside) and whether they're inside.
var home := Vector3.ZERO
var on_turn := false
var trying := false
var room := 0
var try_left := 0.0
var rng := RandomNumberGenerator.new()
var complaints := 0
## Online, a guest's copy: the host's customer tries on and complains, this one only follows (NpcSync).
var follower := false
var _since_complaint := COMPLAIN_EVERY
var _line_left := 0.0
var _next_talk := 0
var _bubble: Label3D
var _bubble_left := 0.0
var _walk: Tween


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODELS[look].instantiate()
	model.scale = Vector3.ONE * SCALE
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	# They look at the racks behind them (-Z); the models face +Z.
	rotation.y = PI


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_CUSTOMER"


func use(_cop: Cop) -> void:
	say(TALK_LINES[_next_talk % TALK_LINES.size()])
	_next_talk += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Says it, and it counts for the complaint unless they complained a moment ago.
func complain(key: String) -> void:
	say(key)
	if follower or _since_complaint < COMPLAIN_EVERY:
		return
	_since_complaint = 0.0
	complaints += 1
	complained.emit(self)


## A mannequin fell with its middle at `where` (global): too close, and they complain.
func near_fall(where: Vector3) -> void:
	var here := global_position
	if Vector2(where.x - here.x, where.z - here.z).length() < CRUSH_RANGE:
		complain("COSTUME_CUSTOMER_CRUSH")


## Their turn: to the front of fitting room `index`, then inside unless a cop is there.
func start_turn(index: int) -> void:
	on_turn = true
	room = index
	_go(shop.aisle_path(home, index), _at_curtain)


func _at_curtain() -> void:
	if shop.cop_in_fitting(room):
		complain("COSTUME_CUSTOMER_BUSY")
		_end_turn()
		return
	_go([shop.fitting_inside(room)], func() -> void:
		trying = true
		try_left = FITTING_TIME
		_line_left = 0.0)


## Done (or stopped): back out and along the aisle to where they look at costumes.
func _end_turn() -> void:
	trying = false
	var back := shop.aisle_path(home, room)
	back.reverse()
	back.append(home)
	_go(back, func() -> void:
		rotation.y = PI
		on_turn = false
		turn_over.emit(self))


## Walks through `points` (shop space) one stretch at a time, then calls `done`.
func _go(points: Array, done: Callable) -> void:
	if _walk:
		_walk.kill()
	_walk = create_tween()
	for point: Vector3 in points:
		_walk.tween_property(self, "position", point, STRETCH)
	_walk.tween_callback(done)


func _physics_process(delta: float) -> void:
	_since_complaint += delta
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	if not trying:
		return
	try_left -= delta
	_line_left -= delta
	if _line_left <= 0.0 and _bubble_left <= 0.0:
		_line_left = LINE_EVERY
		say(TRY_LINES[rng.randi() % TRY_LINES.size()])
	if try_left <= 0.0:
		_end_turn()
