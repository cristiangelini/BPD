class_name SuperCustomer
extends StaticBody3D

## A customer of the supermarket (allanamiento-super.md, step 2): a neighbor who walks a loop of the aisles pushing
## their cart, stops a while in the queue of a checkout and starts again. They never leave ("¡Estoy en la cola,
## oficial!"). If a cop's pushed cart bumps theirs faster than BUMP_SPEED they complain, once every COOLDOWN seconds,
## and the supermarket adds it to the complaint. They wait while a cop stands right in front of their cart. E on them:
## a line, a different one each time. Every number here is (propuesta).

## A cop's cart bumped this one's.
signal complained(customer: SuperCustomer)
## A cop cuffed them (the handcuffs): a customer never did anything.
signal cuffed_now(customer: SuperCustomer)

const MODELS := {
	"comprador": preload("res://assets/models/npc_comprador.glb"),
	"compradora": preload("res://assets/models/npc_compradora.glb"),
	"cliente": preload("res://assets/models/npc_cliente.glb"),
	"senora": preload("res://assets/models/npc_senora.glb"),
}
const LOOKS: Array[String] = ["comprador", "compradora", "cliente", "senora"]
const LINES := 8
const BUMPED_LINES := 4
const SAY_TIME := 4.0
const SPEED := 0.8
## Where their cart rides, in their own coordinates, and its box.
const CART_AT := Vector3(0, 0, -0.85)
const CART_SIZE := Vector3(0.6, 1.0, 0.95)
const BUMP_SPEED := 1.0
const BUMP_DISTANCE := 1.05
const COOLDOWN := 10.0
## How long they stand in a checkout's queue, and how close a cop has to be in front for them to wait.
const QUEUE_TIME := 6.0
const BLOCKED := 1.0

@export var look := "comprador"
## The loop they walk, in the supermarket's space; the queue is the point where they wait QUEUE_TIME.
var route: Array[Vector3] = []
var queue_at := -1
var next_point := 0
var next_line := 0
var complaints := 0
## A guest's copy (NpcSync, step 8): the host moves them and decides the complaints.
var follower := false
var _bubble: Label3D
var _bubble_left := 0.0
var _wait_left := 0.0
var _cooldown_left := 0.0
var _cuffed_left := 0.0


func _ready() -> void:
	add_to_group("super_customers")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var cart_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = CART_SIZE
	cart_shape.shape = box
	cart_shape.position = CART_AT + Vector3(0, CART_SIZE.y / 2, 0)
	add_child(cart_shape)
	var model: Node3D = MODELS[look].instantiate()
	# The models face +Z; the customer faces -Z, toward the cart.
	model.rotation.y = PI
	add_child(model)
	var cart: Node3D = ShoppingCart.MODEL.instantiate()
	cart.position = CART_AT
	add_child(cart)
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_SHOPPER"


func use(_cop: Cop) -> void:
	say("SUPER_CUSTOMER_%d" % (next_line % LINES))
	next_line += 1


func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	if follower:
		return
	say("NPC_POLICE_ABUSE")
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func is_queuing() -> bool:
	return _wait_left > 0.0


## Where their cart is now, in the world.
func cart_position() -> Vector3:
	return global_transform * CART_AT


## A cop's cart hit theirs: a complaint, unless they complained a moment ago.
func bumped() -> void:
	if follower or _cooldown_left > 0.0:
		return
	_cooldown_left = COOLDOWN
	complaints += 1
	say("SUPER_CUSTOMER_BUMPED_%d" % ((complaints - 1) % BUMPED_LINES))
	complained.emit(self)


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if follower:
		return
	for cart: ShoppingCart in get_tree().get_nodes_in_group("shopping_carts"):
		if cart.pusher and cart.top_speed > BUMP_SPEED \
				and cart.global_position.distance_to(cart_position()) < BUMP_DISTANCE:
			bumped()
	if route.is_empty() or is_cuffed():
		return
	if _wait_left > 0.0:
		_wait_left -= delta
		if _wait_left <= 0.0:
			next_point = (next_point + 1) % route.size()
		return
	if _blocked():
		return
	var target := (get_parent() as Node3D).to_global(route[next_point])
	var to := target - global_position
	to.y = 0.0
	if to.length() < 0.05:
		if next_point == queue_at:
			_wait_left = QUEUE_TIME
			say("SUPER_CUSTOMER_QUEUE")
		else:
			next_point = (next_point + 1) % route.size()
		return
	global_basis = Basis.looking_at(to)
	global_position += to.normalized() * minf(SPEED * delta, to.length())


## A cop standing right in front of their cart: they wait for them to move.
func _blocked() -> bool:
	var ahead := cart_position() - global_basis.z * CART_SIZE.z / 2
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var gap := cop.global_position - ahead
		gap.y = 0.0
		if gap.length() < BLOCKED:
			return true
	return false


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
