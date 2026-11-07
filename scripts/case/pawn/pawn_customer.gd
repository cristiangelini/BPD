class_name PawnCustomer
extends StaticBody3D

## A customer of the pawn shop (allanamiento-empenos.md, step 2). They browse the shelves until the shop gives them
## their turn, walk to the counter with something to pawn (a watch, a toaster, grandpa's teeth), haggle there about
## HAGGLE_TIME seconds and walk back. They complain (5 to the complaint, at most once every COMPLAIN_EVERY seconds each)
## when a cop stands at the counter where they go, or a glass case or the armor breaks less than CRUSH_RANGE from them.
## E on one tells a line about the shop, or every other time what they know about the story. Every number here is
## (propuesta).

## They complained loud enough for the owner to hear it (Don Regateo adds it to the complaint, step 3).
signal complained(customer: PawnCustomer)
## Their turn is over and they're back where they browse.
signal turn_over(customer: PawnCustomer)
## They told what they know about the story (`rumor`): the checklist line, already translated.
signal rumored(text: String)

const MODELS := {
	"cliente": preload("res://assets/models/npc_cliente.glb"),
	"clienta": preload("res://assets/models/npc_clienta.glb"),
	"abuelo": preload("res://assets/models/npc_abuelo.glb"),
}
const SCALE := 0.95
const HAGGLE_TIME := 10.0
const LINE_EVERY := 3.5
const COMPLAINT := 5.0
const COMPLAIN_EVERY := 10.0
const CRUSH_RANGE := 2.0
## How close to their spot at the counter a cop is in the way.
const BLOCK_RANGE := 0.9
const SAY_TIME := 3.0
## Seconds for each stretch of the walk to the counter (and back).
const STRETCH := 1.5
const HAGGLE_LINES := ["PAWN_HAGGLE_1", "PAWN_HAGGLE_2", "PAWN_HAGGLE_3", "PAWN_HAGGLE_4", "PAWN_HAGGLE_5"]
const TALK_LINES := ["PAWN_CUSTOMER_TALK_1", "PAWN_CUSTOMER_TALK_2", "PAWN_CUSTOMER_TALK_3"]

@export var look := "cliente"
## What they know about the story, set by its rig: every other time a cop talks to them, that's what they say.
var rumor := ""
var shop: PawnShop
## Where they browse (shop space), whether it's their turn (walking or at the counter) and whether they're haggling.
var home := Vector3.ZERO
var on_turn := false
var haggling := false
var haggle_left := 0.0
var rng := RandomNumberGenerator.new()
var complaints := 0
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
	# They look at the shelves behind them (-Z); the models face +Z.
	rotation.y = PI


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_PAWN_CUSTOMER"


func use(_cop: Cop) -> void:
	if rumor != "" and _next_talk % 2 == 0:
		say(rumor)
		rumored.emit(tr(rumor))
	else:
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
	if _since_complaint < COMPLAIN_EVERY:
		return
	_since_complaint = 0.0
	complaints += 1
	complained.emit(self)


## Something broke with its middle at `where` (global): too close, and they complain.
func near_crash(where: Vector3) -> void:
	var here := global_position
	if Vector2(where.x - here.x, where.z - here.z).length() < CRUSH_RANGE:
		complain("PAWN_CUSTOMER_CRASH")


## Their turn: to their spot at the counter, and haggle there unless a cop is in the way.
func start_turn() -> void:
	on_turn = true
	_go(shop.counter_path(home), _at_counter)


func _at_counter() -> void:
	if shop.cop_near(PawnShop.COUNTER_SPOT, BLOCK_RANGE):
		complain("PAWN_CUSTOMER_BLOCKED")
		_end_turn()
		return
	rotation.y = 0.0
	haggling = true
	haggle_left = HAGGLE_TIME
	_line_left = 0.0


## Done (or stopped): back the same way to where they browse.
func _end_turn() -> void:
	haggling = false
	var back := shop.counter_path(home)
	back.reverse()
	back.append(home)
	_go(back.slice(1), func() -> void:
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
	if not haggling:
		return
	haggle_left -= delta
	_line_left -= delta
	if _line_left <= 0.0 and _bubble_left <= 0.0:
		_line_left = LINE_EVERY
		say(HAGGLE_LINES[rng.randi() % HAGGLE_LINES.size()])
	if haggle_left <= 0.0:
		_end_turn()
